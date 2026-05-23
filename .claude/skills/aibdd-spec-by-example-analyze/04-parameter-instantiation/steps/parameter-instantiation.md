針對單一 `.feature` 做 canonical exemplar instantiation。

# Task

1. READ 當前 `.feature` 全文。

2. ASSUME 本 step 由單 feature worker 執行：
   1. 一個 worker 只處理一個 `.feature`。
   2. worker 只負責 canonical exemplar instantiation，不負責新的 discovery、handler 搜尋、DSL arrangement 或 coverage expansion。

3. INVENTORY 本 `.feature` 內所有尚未落地的 placeholder：
   1. `Rule:` headline、`Example:` / `Scenario Outline:` 標題中的 placeholder。
   2. `Given` / `When` / `Then` / `And` / `But` step 文字中的 placeholder。
   3. DataTable、DocString 與 assertion payload 中的 placeholder。
   4. `<>` 與 `{}` 兩種 placeholder 都要一起盤點；不得只處理其中一種。
   - 請注意！此步驟不像 `03-dsl-arrangement` 的 scope 誤縮只有 `Given` / `Then`，本步驟不只是包含 Given, Then， scope 也明確包含 `When` 的區塊。

4. DERIVE feature-level canonical binding map：
   1. 先從當前 `.feature` 內已存在的 concrete literals、actor 關係、resource 關係與前序 step 因果，推出哪些 placeholder 應沿用既有值。
   2. 若同一個語意 placeholder 在同一個 `.feature` 內重複出現，優先綁成同一個 concrete exemplar。
   3. 若某 placeholder 尚無既有來源，為它選一個低認知成本、可直接閱讀的 canonical exemplar；此 exemplar 只需支撐當前 scenario，不得藉機擴 coverage。
   4. 若某 `Scenario Outline` 目前只是 skeleton，且尚未承載多組變化，為它落一組 canonical exemplar 即可；不得在此步擴成多組 examples。

5. INSTANTIATE 當前 `.feature`：
   1. 將步驟 4 得到的 binding map 回寫到 title、steps、tables 與 assertion payload。
   2. 若 concrete exemplar 代表字串參數，落地時一律 resolve 成 Gherkin 內可直接閱讀的 `"..."`；若 concrete exemplar 代表整數參數，優先直接落成裸值，不必額外補引號。
   3. 若某 step 使用 Gherkin DataTable，第一列必須是欄位名稱 header row，第二列開始才是 data row；不得把欄位名和值攤成同一列，也不得改寫成 column-oriented 的 key/value 形狀。
   4. 例：
      1. `Given 使用者以識別碼 "{識別碼}" 查詢資源` 應落成 `Given 使用者以識別碼 "item-123" 查詢資源`。
      2. `And 系統以權杖 "{權杖}" 存取租戶 "{租戶編號}" 並限制為 {上限值} 筆` 應落成 `And 系統以權杖 "credential-abc" 存取租戶 "tenant-01" 並限制為 10 筆`。
      3. `When 玩家以權杖 "{玩家權杖}" 於房間 "{房間編號}" 標記準備` 應落成 `When 玩家以權杖 "guest-token-1" 於房間 "101" 標記準備`。
      4. `Then 操作失敗，錯誤為 "{錯誤訊息}"` 應落成 `Then 操作失敗，錯誤為 "房間已滿"`。
      5. `And 統計結果應如預期：` 加上 data table
         ```
         | 類別 | 項目數 |
         | "{類別}" | {項目數} |
         ```
         應落成
         ```
         | 類別 | 項目數 |
         | "standard" | 2 |
         ```
      6. 不得把上例落成
         ```
         | 類別 | "standard" | 項目數 | 2 |
         ```
         這種把欄位名和值攤在同一列的 form。
      7. 若 header row 某欄對應整數 exemplar，不得把 data row 寫成 `"2"` 這類字串字面值；應直接落成 `2`。
   5. 保留 scenario 的原本 intent、assertion shape 與 actor/resource handoff，不得因為換值而改變此 scenario 想證明的事。
   6. 若某 `Scenario Outline` 在 instantiation 後不再需要多組 placeholders，可正規化成單一 `Example`，只保留當前這組 exemplar。
   7. 同一個 `.feature` 內的 naming 要前後一致，避免 `房號`、`房間編號`、`權杖` 各自掉成不同世界觀。
   8. 完成前必須逐條自檢：凡 `Given` / `When` / `Then` / `And` / `But` 行內原先承載 DSL 參數者，都不得殘留 `{...}` 或 `<...>` 形式的未綁定 placeholder；若仍有殘留，視為本 phase 尚未完成。

6. 若有任一 placeholder 在不改變 spec meaning 的前提下仍無法唯一決定：
   1. 組成 `$questions`。
   2. STOP 本 worker。
   3. 交回外層 phase 走 `/clarify-loop`，不得自行發明值。

# Worker hard limits
1. 不得變更 `When` step 的行為意圖；若 `When` 內含 placeholder，只能把值落成 concrete exemplar，不得改寫該操作想表達的業務語意。
2. 不得新增新的 Scenario、不得新增新的 Examples rows。
3. 不得改寫 scope 外的 `.feature`，也不得回頭改寫 `01`、`02`、`03` 已接受的決策。
4. 不得把同一個 `.feature` 內已存在的 concrete 值重新發明成另一套 naming；同一語意 placeholder 應盡量落成同一組值。
5. 字串 exemplar 不得去掉引號；凡屬字串參數，落地時必須保留 `"..."` 形式。
6. 整數 exemplar 不得包成字串；凡屬整數參數，落地時不得寫成 `"2"`、`"10"` 這類字串字面值。
7. 若某 placeholder 的值無法在不改變 spec meaning 的前提下唯一決定，必須 EMIT `$questions` 並提議最根本的解法；不得硬猜。

# Completion contract
1. 每個 `.feature` 完成後，該檔內所有尚未落地的 placeholder 都應已被 instantiation 成一版 concrete exemplar，包含 `{...}` 與 `<...>`；尤其 `Given` / `When` / `Then` / `And` / `But` 的 DSL 參數不得殘留未綁定值。
2. 若某 `Scenario Outline` 在 instantiation 後只剩單一 exemplar，且不再承載多組變化，可被正規化為單一 `Example`。
3. 同一個 `.feature` 內相同 actor、resource、identifier 與 expected value 的 naming 應保持一致，讓讀者能直接看出誰生出誰、誰沿用誰。
4. 本步完成後的 feature files 應可直接銜接 `/aibdd-tasks`；若要再做 coverage 擴寫、EP / BVA 或額外 examples，屬於 optional enhancement，不屬本 phase。
