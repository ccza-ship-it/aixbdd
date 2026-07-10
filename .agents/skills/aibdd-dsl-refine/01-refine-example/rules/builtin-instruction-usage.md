# 內建指令完整用法（能力與界限）

選型看 [builtin-instruction-decision-tree.md](builtin-instruction-decision-tree.md)、符號語法看
[symbol-system-usage.md](symbol-system-usage.md)；本檔是六個內建型別「實際能做到什麼、做不到什麼」
的用法真相（依框架 specformula 原始碼驗證），推 isa_steps 與判斷 custom 前先對照這裡的界限。

## time_control

- 設定情境模擬時間（MockTime）；之後 `@time("now±…")` 與 CAS 時間約束都以它為基準。
- 陷阱：`&withinDays(n)` 以真實時鐘為基準、不吃 MockTime；要相對模擬時間請改用
  `&after/&before/&between/&timeRange` 搭 `now±` 相對語法。

## entity_setup

- 語意：對 entity 對應的表（經 `entity_to_table_mapping.yml`）動態組 INSERT，一列 DataTable＝一筆。
- 值：`$var`／`${…}` 插值／`@time()` 皆可；型別依 DDL 自動轉換（UUID／整數系／DECIMAL／BOOLEAN／
  TIMESTAMP／DATE／TIME）；JSON/JSONB 欄位可用 dot/bracket path 當表頭（`profile.city`、
  `orderItems[0].productId`）由框架重組成 JSON 寫入。
- VAR：`>contextKey` 表頭配 `<executionKey` 資料列成對；INSERT 後以 generated key 回查整筆，
  故可擷取含 DB 產生值（id、default 欄）在內的任何欄位。
- 界限：空字串＝跳過該欄（交給 DB default／NULL），**沒有「顯式塞 NULL 覆蓋 default」的語法**。

## entity_validate

- 語意：DataTable **逐列**驗證，每列必須在 DB 定位到**恰好一筆**（0 筆 fail、>1 筆也 fail）。
  這是隱含斷言：查詢條件要能唯一定位（count=1 語意免費取得）。
- 定位：PK 欄位優先；否則以「非 CAS 欄位」做**等值 AND** probe——只有等值，
  無 LIKE／區間／JOIN／ORDER／LIMIT。`&…`（CAS）欄位不進查詢條件、只做定位後的斷言；
  整列若只有 CAS 欄位、沒有任何等值欄位 → 直接 fail「缺少查詢條件」。
- 值比對語意：時間型別自動截斷到秒；數值跨型別語意比較（"50000.00" == 50000.0000）；
  Boolean 接受 true/false 與 "0"/"1"；其餘 fallback 字串比較。
- NULL：用 `&isNull`／`&isNotNull`。
- JSON 欄位：表頭 dot/bracket path 深入巢狀；陣列值配 `&hasItem/&size/&isEmpty`。
- VAR：可用 `>`/`<` **從 DB 實際值擷取變數**——這是跨表一致性組合的基礎（見拆解模式）。

## entity_non_existence_validate

- 語意：PK 或等值 probe，查到任何一筆即 fail（count=0 語意）。
- 界限：**只支援等值條件**；不支援 CAS（`&…` 欄位被忽略）、不支援 VAR。
  「不存在任何 status != DONE 的列」這類否定／範圍條件不可表達；
  有限值域可拆多條等值枚舉，開放值域（範圍、regex）不可。

## api_call

- 語意：句中 summary **精確比對** contracts（OpenAPI）的 operation summary → 取 method＋path。
  僅支援 get/post/put/delete/patch（**HEAD/OPTIONS 對不上**）。
- 參數位置：無前綴欄位＝request body，與 OpenAPI parameters 同名時自動帶入 path/query/header；
  `P:`/`Q:`/`H:` 顯式指定（可覆寫同名自動歸類）；`B:` 整包 body（完整 JSON 或裸值）。
- body 形狀：dot-notation＋`[i]` 索引組巢狀／陣列；頂層陣列用 `[0].field` 或 `B:`；
  空表 `| |` ＝無參數無 body 的呼叫。
- 身分：`UID="$alias.id"` → 解析變數 → Authenticator 取 token → 自動帶 `Authorization: Bearer`；
  `No Actor` 不帶。每次呼叫各自解析 → 多使用者交錯天然支援。
  非 Bearer 認證（API key 等）用 `H:Authorization`／`H:X-Api-Key` 直帶。
- 回應：存單一槽（lastResponse，逐次覆寫）；`>ctx` 配 `<jsonPath` 擷取回應欄位、
  `<H:HeaderName` 擷取回應 header、`<B:` 擷取裸值 body。
- 界限：body 全程是字串管線——**multipart 檔案上傳、binary 內容不可表達**（框架明示走 custom）；
  同名 query 參數多值（`?tag=a&tag=b`）不可表達（Map 後值覆寫）。

## response_validate

- 語意：狀態碼寫進句子 `(201)`，任意三碼皆可；body 為**部分比對**——只比 table 列出的欄位，
  但每次驗證另跑 OpenAPI response schema 結構全檢（型別、required、**拒絕 schema 未定義欄位**）。
- 路徑：dot-notation／陣列索引／頂層陣列 `[0].id`；索引定址即「順序敏感」。
- `H:` 驗證回應 header（同名多值只取第一個）；`B:` 驗證整包 body（JSON 語意相等，可搭 `&size` 等 CAS）。
- 空表 `| |` ＝只驗狀態碼。
- 界限：**非 JSON 回應（text/plain）只能驗狀態碼**，內容斷言不可表達（宣告 text/plain 時
  框架跳過全部欄位驗證；未宣告的非 JSON 直接錯）；物件陣列的**順序無關比對**不可表達
  （`&hasItem` 只比純量、無 unordered 約束）。

## 填 table 慣例（各型通用）

- data_format 忠實對應：扁平欄位用 `table`；巢狀／貼近 request body 用 `json`。
  輸出 DataTable 或 DocString 由該 instruction 在 isa.yml 的 `data_format` 決定，不可自選。
- DataTable 完整性（NOT NULL 預設值）：`entity_setup` 與 `api_call` 的 table 必須讓
  NOT NULL／required 欄位都有值，否則違反 DB 約束或 API 回 400。
  - NOT NULL 來源：entity_setup 看 data DDL（經 entity_to_table_mapping 對表）；api_call 看 contracts 的 required。
  - 欄位與當前測試情境相關（被 Then 斷言、或驅動本例行為）→ 帶真實資料：`{{name}}`／`$alias`／業務值。
  - NOT NULL 但與情境無關 → 填合理預設值（集中放 dsl_step 的 `params`，table 用 `{{name}}` 取），
    別留空、也別硬塞會誤導讀者的值。
- 值域來源（每個欄位照它所屬那層的宣告值域）：`entity_setup` 寫入與 `entity_validate` 斷言的 DB 欄位，
  值一律取 data-spec 值域——DDL 欄位註解／CHECK、`entity_to_table_mapping`、option code 表（`tb_option_code`）。
  `api_call` request body 的欄位照 OpenAPI schema 宣告的值域：該欄位有 `enum:` 才用那組 enum 代碼；
  沒有 `enum:` 的欄位（例如只描述「穩定選項值／代碼」的一般字串）用 contract／option-code 表的既有值域，
  不得自創代碼。同一概念在 DB 層與 API 層值域不同時要分流，不可把某層的值直填另一層
  （填錯值域，寫入或後續 `entity_validate`／查詢會對不上）。
  - 例：`tb_credit_application.application_type` DDL 值域為中文「新客授信／額度變更」；createCreditApplication
    body 的 `applicationType` 宣告 `enum: [NEW_CLIENT, LIMIT_CHANGE]`。`entity_setup` 用「新客授信」、
    `api_call` body 用 `NEW_CLIENT`，兩者不可互換。
  - 反例：body 的 `companyType` 在 OpenAPI 無 `enum:` 宣告（只註明是選項代碼）→ 不可自創 `COMPANY_TYPE_GENERAL`，
    用 contract／option-code 表既有的值域。

## 界限總表（對不上就走 custom）

以下已驗證為框架表達力之外；dsl_step 落在這些語意時不要硬拆，依
[custom-isa-placement.md](custom-isa-placement.md) 宣告 custom：

| 界限 | 面向 | 說明 |
|------|------|------|
| 精確筆數 N≥2 | data | N 列只證下界，無法排除第 N+1 筆（count=0/1 可表達，見拆解模式） |
| 聚合值 SUM/AVG/GROUP BY | data | 查詢只有 PK／等值兩種模板，無聚合 |
| 排序語意（最新一筆） | data | 無 ORDER BY/LIMIT；time_control 下可退化為等值定位（見拆解模式） |
| 否定／範圍條件的不存在 | data | non_existence 只收等值 |
| multipart／binary | api | body 管線僅字串 |
| text/plain 內容斷言 | api | 只能驗狀態碼 |
| HEAD/OPTIONS | api | spec reader 不解析 |
| 同名參數多值／多值 header | api | Map 覆寫／只取第一值 |
| 物件陣列順序無關比對 | api | 僅索引定址 |

CAS 約束全集與語法見 symbol-system-usage.md；注意約束名是 `&ge/&le`（寫 `&gte/&lte` 會炸
「未知的約束條件」，部分框架文件寫錯，以此為準）。

## Good

```yaml
# entity_setup：status NOT NULL 但本例不驗它 → 預設 ACTIVE（放 params）；name 是情境主角 → 帶值
- instruction: '準備一個使用者, with table:'
  table:
    '>{{alias}}.id': '<userId'
    name: '{{alias}}'
    status: '{{defaultStatus}}'      # params.defaultStatus: ACTIVE
```
```yaml
# 值域分流：DB 欄位用 DDL 值域、api body 用 API enum（同概念、兩層不同值）
- instruction: '準備一個tb_credit_application, with table:'
  table:
    application_type: 新客授信              # DB 欄位 → DDL 值域（中文）
- instruction: '(UID="$業務.id") 建立授信申請, call JSON:'
  table:
    applicationType: NEW_CLIENT             # api body → OpenAPI enum
```

## Bad

```yaml
# 漏填 NOT NULL 的 status → 寫入違反約束 / 測試非預期失敗
- instruction: '準備一個使用者, with table:'
  table:
    name: '{{alias}}'
# 刪除案例卻用 entity_validate（「應該存在…」）驗刪除後狀態；應改 entity_non_existence_validate
- instruction: '應該存在一個待辦事項, with table:'
  table:
    todoId: '$todo1.id'
# 把 API enum 直填 DB 欄位 → 值域錯置（DDL 值域是「新客授信」，寫入/斷言對不上）
- instruction: '準備一個tb_credit_application, with table:'
  table:
    application_type: NEW_CLIENT      # 應為 新客授信（DDL 值域）；NEW_CLIENT 只該出現在 api body
```
