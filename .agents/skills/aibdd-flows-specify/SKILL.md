---
name: aibdd-flows-specify
description: "AIBDD Flows Specify SOP。把本輪需求敘事收斂為 spec.md SSOT、掃描 boundary truth、維護 impact matrix、拆分 function package charters，先依 API 級顆粒度把每段需求流程萃取成業務 Action、編織成可獨立驗收的 UAT flow 並交 /aibdd-form-activity 產出 `.activity` 活動圖，再把每個 Action 落成 business-action `.feature` 清單（rule-less 骨架）。TRIGGER when 使用者下 /aibdd-flows-specify、要開始需求探索／盤點本輪要做哪些 feature 與其範圍切分、或被 /aibdd-reconcile cascade 委派最上游 planner。SKIP when CWD 下找不到 arguments.yml（請先 /aibdd-kickoff）、或本輪只是要為既有 `.feature` 列舉 atomic rule（改用 /aibdd-rules-specify）。"
metadata:
  user-invocable: true
  source: project-level
---

# AIxBDD - Flows Specify

嚴格遵照底下 Principles 來執行 SOP。本 skill 是 plan 迭代的最上游 planner：先收斂需求真相與影響範圍（Phase 01），依 API 級顆粒度萃取業務 Action 並建模成可獨立驗收的 UAT flow、交 `/aibdd-form-activity` 產出 `.activity` 活動圖（Phase 02），再把每個 Action 落成 rule-less feature file 清單（Phase 03）。完成後交棒 `/aibdd-rules-specify` 為每個 `.feature` 列舉 atomic rules。

## PRINCIPLE: CWD 為產出錨點

- 本 skill 與其 sub-SOP **所有經授權產生或修改的 artifact**，**一律**落在當次執行的工作目錄 **`CWD`** 所涵蓋之專案／規格樹內（相對路徑自 **`CWD`** 解析；本檔所列 `${SPECS_ROOT_DIR}`、`${CURRENT_PLAN_PACKAGE}`、`${PLAN_REPORTS_DIR}`、`${ACTIVITIES_DIR}`、`${TRUTH_*}` 等皆以 **`CWD`** 為錨。
- 【嚴禁】把應屬本流程的產物寫到 **`CWD` 外**的任意絕對路徑，或以「方便」為由落到未載明於當步 SOP 的其他根目錄。

## PRINCIPLE: Artifact output contract（硬限制）

- 本 SOP **唯一允許產生、修改或刪除**的 artifact，**只能**來自於下述 SOP 中透過 CREATE / WRITE / UPDATE / DELETE 明確標注的產出物。
- DELETE 僅及依 `$ENTRIES_BEFORE`／`$ENTRIES_AFTER` 對照判定應淘汰的 `.feature`／`.activity`——即 `$ENTRIES_AFTER` 標 `change_type=remove` 者、或 `$ENTRIES_BEFORE` 有而 `$ENTRIES_AFTER` 無且檔已落地者（NEW 路徑 `$ENTRIES_BEFORE` 視為空集合）；其餘任何情況不得刪檔。
- 【嚴禁】除上述 target 外，**其他任何 READ / SEARCH / THINK / DERIVE 所觀察到的路徑，都只可作為分析依據，不得被順手建立、寫入、更新、刪除或補骨架。**

## PRINCIPLE: STRICT SOP

1. **依序不漏步**：自底下列 SOP 逐一執行；每做一步，在訊息中**明示該步編號**。

2. **連續執行不停步**：sub-SOP（phase）跑完、或 DELEGATE 的 formulation skill（`/aibdd-form-*`）回傳，**都不是停點**——立即將對應待辦標為完成並續跑下一步，**不得**停下來等待使用者指示或詢問「是否繼續」。本 skill 唯一合法的暫停點只有三種：SOP 明文 STOP、澄清提問等待回覆、以及 `# SOP` 最後一步的結尾報告。

3. **限縮延長推理**：僅當 sub-SOP 當步**明文**標示須 **`THINK / REASONING`** 時，才拉長內省與推演；否則以**最直接**可做之 `READ`／`PARSE`／`DERIVE`／`WRITE`／`UPDATE`／工具呼叫達成該步，省略與該步授權範圍無關的冗長鋪墊，以降低往返等待時間。

## PRINCIPLE: 長流程待辦（兩層）

長流程會跨多輪對話；在 **conversation compact**（對話摘要壓縮）之後，執行者仍要靠**同一套待辦**還原：目前卡在哪個 **phase**，該 phase 內細項又到哪一格。底下為**兩層**約定：**外層只列 phase**，**進入該 phase** 再把該 sub-SOP 第一層編號步驟拆成子項。尚未開始的 phase 不必預先展開成檔案級細項，以免待辦與實際 `SOP.md` 脫節。

- **必須工具化**：Tier 0／Tier 1 對應的勾選項，**要以執行環境提供的任務／待辦建立與更新能力實體化**（例如 **`TODOCREATE`**、**`TASKCREATE`** 等 tool；或宿主 IDE／Agent 內與之等效的待辦 API），在跑 sub-SOP **當下**就建好清單並隨步驟推進更新狀態。**禁止**只靠聊天裡口頭列點、不經工具建立的「心裡待辦」——壓縮後無法還原，也無法核對漏步。
- **Tier 0（phase）**：對應本檔 `# SOP` 最外層每一項；每一項對應一個 sub-SOP 目錄（例：`aibdd-flows-specify/01-sourcing-and-packaging/`）。這一層的勾選語意是「該 phase 的細項已全部展開**且**依 `SOP.md` 跑完」。
- **Tier 1（phase 內細項）**：僅在目前執行中的 phase 建立；對應該 phase `SOP.md` 裡**第一層編號步驟**拆解出的動作（`READ`／`WRITE`／`DERIVE` 等）。編號建議：`(phase序)`、`(phase序-子序)`（例：`1`、`1-1`），跨輪可對照；**進入該 phase 時**以 **`TODOCREATE`／`TASKCREATE`（或等效）** 補齊子項。

**Tier 0 範例**（語意範本；實務請用 **`TODOCREATE`／`TASKCREATE`（或等效）** 建立對應任務，結構對齊即可）：

```markdown
- [ ] (1) 上下文解析
- [ ] (2) 展開並執行至完成：`aibdd-flows-specify/01-sourcing-and-packaging/SOP.md`（NEW）或 `aibdd-flows-specify/01-amending-and-repackaging/SOP.md`（UPDATE）。
- [ ] (3) 展開並執行至完成：`aibdd-flows-specify/02-activity-analyze/SOP.md`。
- [ ] (4) 展開並執行至完成：`aibdd-flows-specify/03-feature-file-list-analyze/SOP.md`。
```

**進入 (2) 後**才把 (2) 拆成 Tier 1，依路由結果照抄對應文案；其餘 phase 在 Tier 0 維持單列。

`NEW` 路徑（`aibdd-flows-specify/01-sourcing-and-packaging/SOP.md`）：

```markdown
- [ ] (2) 展開並執行至完成：`aibdd-flows-specify/01-sourcing-and-packaging/SOP.md`。
    - [ ] (2-1) 步驟 0：RESOLVE arguments、READ `aibdd-flows-specify/rules/specs-root-layout.md`、DERIVE `$package_naming_language`。
    - [ ] (2-2) 步驟 1：ANCHOR + SEARCH——WRITE 需求敘事全文至 `${PLAN_SPEC}`、SEARCH boundary truth。
    - [ ] (2-3) 步驟 2：CREATE DIR `${PLAN_PACKAGES_DIR}/$plan_package_slug/`。
    - [ ] (2-4) 步驟 3：EXECUTE `aibdd-flows-specify/01-sourcing-and-packaging/steps/maintain-impact-matrix.md`。
    - [ ] (2-5) 步驟 4：WRITE `${PLAN_REPORTS_DIR}/discovery-sourcing.md`、UPDATE `${PLAN_SPEC}`。
    - [ ] (2-6) 步驟 5–6：THINK function package 拆分、CREATE DIRS ONLY `${FEATURE_SPECS_DIR}` 骨架。
    - [ ] (2-7) 步驟 7：UPDATE `discovery-sourcing.md` 與 `${PLAN_SPEC}` 收尾。
- [ ] (3) 展開並執行至完成：`aibdd-flows-specify/02-activity-analyze/SOP.md`。
- [ ] (4) 展開並執行至完成：`aibdd-flows-specify/03-feature-file-list-analyze/SOP.md`。
```

`UPDATE` 路徑（`aibdd-flows-specify/01-amending-and-repackaging/SOP.md`）：

```markdown
- [ ] (2) 展開並執行至完成：`aibdd-flows-specify/01-amending-and-repackaging/SOP.md`。
    - [ ] (2-1) 步驟 0：RESOLVE arguments 並驗證 plan package 已鎖定、READ `aibdd-flows-specify/rules/specs-root-layout.md`、DERIVE `$package_naming_language`。
    - [ ] (2-2) 步驟 1：ANCHOR + SEARCH——CHECK baseline 補缺、AMEND `${PLAN_SPEC}` 追加遞增批次、SEARCH boundary truth。
    - [ ] (2-3) 步驟 2：ASSERT DIR `${PLAN_PACKAGES_DIR}/<NNN-plan-slug>/`。
    - [ ] (2-4) 步驟 3：EXECUTE `aibdd-flows-specify/01-amending-and-repackaging/steps/maintain-impact-matrix.md` amend 模式。
    - [ ] (2-5) 步驟 4：UPDATE `${PLAN_REPORTS_DIR}/discovery-sourcing.md` 就地更新既有章節反映當前真相、UPDATE `${PLAN_SPEC}`。
    - [ ] (2-6) 步驟 5–6：THINK charter 影響、CREATE DIRS ONLY 僅新開的 function package。
    - [ ] (2-7) 步驟 7：UPDATE `discovery-sourcing.md` 與 `${PLAN_SPEC}` 收尾。
- [ ] (3) 展開並執行至完成：`aibdd-flows-specify/02-activity-analyze/SOP.md`。
- [ ] (4) 展開並執行至完成：`aibdd-flows-specify/03-feature-file-list-analyze/SOP.md`。
```

**(2)** 的子項全部完成後，以 **`TODOCREATE`／`TASKCREATE`（或等效）** 將 Tier 0 之 **(2)** 標為完成，再對 **(3)** 重複「展開 → 跑完」，依序往後。**未完成當前 phase** 前，**不要**為後續 phase 預開檔案層級的細項。

# SOP

請執行到哪讀到哪，千萬不要提早閱讀後續文件，這會讓用戶起始體驗到的延遲度很久，SOP 寫啥就做啥，沒叫你 [THINK/REASONING] 就絕對不准啟用 EXTENDED THINKING。

0. 在 CWD 底下 grep 搜尋 `**/arguments.yml` 檔案，做 parameters binding for all following phases，這些參數後續每一 phase 都會用到。此檔案一定存在，如不存在請直接停止執行，向使用者回報：「我在 ${CWD} 底下找不到 **/arguments.yml 檔案，你是否已經執行過 /aibdd-kickoff 了？」

1. 上下文解析（本步只做路由判斷；不寫任何 artifact、不改寫 arguments.yml）

   1.1 DECIDE plan package 指向。`arguments.yml` 的 `CURRENT_PLAN_PACKAGE` 永遠保持 `<<NNN-plan-slug>>` 借位形態，**判據不在 yaml，而在對話上下文**：
   - **上下文已明確指向**：本輪對話已出現具體的 `NNN-<slug>`——例如上游 orchestrator 稍早從本 skill 取得的回傳值、使用者點名 `${PLAN_PACKAGES_DIR}/NNN-<slug>`、或「繼續／重跑 NNN 那包」這類指涉 → SET `$ENTRY_TYPE = UPDATE`：ASSERT `${PLAN_PACKAGES_DIR}/NNN-<slug>/` 於 filesystem 存在；不存在則改走下方釐清。鎖定的 slug 即本輪 caller-context 提供的 plan slug；後續各 phase 解析 `<<NNN-plan-slug>>` 借位時以其為準。
   - **上下文沒有明確指向、但需求敘事明確指名要建立新的 plan package**（例：「開新的 plan」「建立新 package」「這是一個新需求，開新包」這類**明示**字句）→ SET `$ENTRY_TYPE = NEW`：本步不建包，交由步驟 `2a` 的 Phase 01 DERIVE 新 slug 並建立。僅限**明示指名**；從敘事內容**推測**「看起來像新功能」不算。
   - **其餘情況（無指向且未明示開新包）**：**一律向使用者釐清**，不得自行判定。列出 `${PLAN_PACKAGES_DIR}/*/` 全部候選，直接詢問——是變更哪個既有包（→ `UPDATE` 並鎖定該 slug），還是開新包（→ `NEW`）；取得回覆前 STOP。**候選僅一個、甚至為空，也必須釐清**：唯一既有包不等於唯一答案（本次也可能是要開新 plan package），不得因候選唯一或語意「顯而易見」而自行鎖定或自行開新包。

   1.2 DECIDE 使用者是否已提供需求描述（足以收斂 discovery 的需求敘事，而非只有「跑一下 /aibdd-flows-specify」一句）：
   - **無** → 直接向使用者提問本輪需求（不使用 /clarify-loop）；取得前 STOP，不進入步驟 2。
   - **有** → 路由：`NEW` → 步驟 `2a`；`UPDATE` → 步驟 `2b`。

   1.3 路由確定後、進入步驟 2 前，**立即**以 `TASKCREATE`（或等效）建立 Tier 0 待辦——文案照抄上方 Tier 0 範例，(2) 依 `$ENTRY_TYPE` 擇一填入對應 sub-SOP 路徑。**不得**先跑 phase 步驟再補建待辦。

2a. [僅 `$ENTRY_TYPE == NEW`] EXECUTE the sub-sop: `aibdd-flows-specify/01-sourcing-and-packaging/SOP.md`——進入時**先**以 `TASKCREATE`（或等效）補齊本 phase 之 Tier 1 子項（文案照抄上方「`NEW` 路徑」區塊），再逐步執行；完成後**不停步**，直接進入步驟 3。

2b. [僅 `$ENTRY_TYPE == UPDATE`] EXECUTE the sub-sop: `aibdd-flows-specify/01-amending-and-repackaging/SOP.md`——進入時**先**以 `TASKCREATE`（或等效）補齊本 phase 之 Tier 1 子項（文案照抄上方「`UPDATE` 路徑」區塊），再逐步執行；完成後**不停步**，直接進入步驟 3。

3. EXECUTE the sub-sop: `aibdd-flows-specify/02-activity-analyze/SOP.md`——進入時**先**以 `TASKCREATE`（或等效）依該 `SOP.md` 第一層編號步驟補齊 Tier 1 子項，再逐步執行；完成後**不停步**，直接進入步驟 4。

4. EXECUTE the sub-sop: `aibdd-flows-specify/03-feature-file-list-analyze/SOP.md`——進入時**先**以 `TASKCREATE`（或等效）依該 `SOP.md` 第一層編號步驟補齊 Tier 1 子項，再逐步執行；完成後**不停步**，直接進入步驟 5。

5. 和用戶說道（可使用不同詞彙但維持語意）：
   - `NEW` 路徑：「OK，/aibdd-flows-specify 已完成需求收斂、影響矩陣、function package 拆分、UAT flow 活動圖（`.activity`）與 feature file 清單（rule-less 骨架）。如沒問題，接著執行 /aibdd-rules-specify，為每個 `.feature` 列舉其驗收用的 atomic rules。」
   - `UPDATE` 路徑：「OK，/aibdd-flows-specify 已把本輪需求變更套用到既有 plan package（更新 spec.md、影響矩陣前後對照、受影響的 UAT flow 活動圖與 feature file 清單）。如沒問題，接著執行 /aibdd-rules-specify，為受影響的 `.feature` 補列 atomic rules。」
