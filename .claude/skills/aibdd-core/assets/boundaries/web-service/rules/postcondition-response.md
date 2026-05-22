# Rule Type: 後置（回應）

1. Role
   1. 本檔是 web-service boundary 中 `後置（回應）` rule type 的整體立法包。
   2. 本檔定義成功路徑下 `Given` 與 `Then` 的 arrangement law。

2. Given Block
   1. `Given` 的目標是建出操作成功所需的最小前置狀態。
   2. 只保留與回應欄位可判定性直接相關的背景；無關 state 不應混入。
   3. `Given` 只能使用當前 `# candidates:` 中已存在的 `candidate_specs`。
   4. 若回應值依賴既有資料、時間或 external stub，該依賴必須在 `Given` 中可追溯。
   5. 先做 legality gate，再做 optimization。

3. Then Block
   1. `Then` 的主 assertion source 是 response surface，不是 persisted state。
   2. 先確立 `Then 操作成功`，再驗與 atomic rule 直接對應的 response field。
   3. 優先選 assertion scope 最小、最少額外推論的 response verifier。
   4. 不得拿 DB row、readmodel 或其他 persisted state 來替代 response verification。

4. Hard Rejections
   1. 拒絕需要先偷看 persisted state 才能判定 response 正確的 verifier。
   2. 拒絕與當前 response field 無直接對應的 broad snapshot assertion。
   3. 拒絕與 success path 無關的 sibling operation 或 sibling verifier。

5. Output Expectation
   1. `Given` 應產出成功路徑所需的最小 `selected_plan`，並遵守 shared precondition trace schema。
   2. `Then` 應選出最小 response verifier，並在 `# @decision:` / `# @rationale:` 交代採用原因與主要淘汰理由。
