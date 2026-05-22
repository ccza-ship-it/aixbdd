# Rule Type: 後置（狀態）

1. Role
   1. 本檔是 web-service boundary 中 `後置（狀態）` rule type 的整體立法包。
   2. 本檔同時擁有 success path 下的 `Given` 與 `Then` legislation。

2. Given Block
   1. `Given` 的目標是建出一個可量測的 before-state，讓 `Then` 能清楚觀察 expected delta。
   2. `Given` 只能使用當前 `# candidates:` 中已存在的 `candidate_specs`。
   3. 若 rule 需要觀察 `資料`、`外發`、`資源`、`行為` 其中一類狀態變化，`Given` 必須讓該子類的 before-state 可被明確對照。
   4. 先做 legality gate，再做 optimization。
   5. 優先選最小 state scope、最短 state path、最少額外推論的 arrangement。

3. Then Block
   1. `Then` 的主 assertion source 是 changed state，不是 response success。
   2. `Then` 應依 `後置（狀態）` 子類選 verifier：
      1. `資料`：優先 persisted row / entity state verifier。
      2. `外發`：優先 external stub / outbox / inbox / emission record verifier。
      3. `資源`：優先餘額、額度、鎖、庫存等 resource-facing verifier。
      4. `行為`：優先能直接證明指定行為或冪等差異的 verifier。
   3. 若 direct owner verifier 可用，優先 direct owner；不可用時，才退到最小可證明變化的 proxy verifier。
   4. 不得拿 `Then 操作成功` 或 response payload 充當 state change 證明。

4. Hard Rejections
   1. 拒絕無法提供明確 before-state baseline 的 `Given`。
   2. 拒絕只能證明「操作成功」卻不能證明「狀態改變」的 verifier。
   3. 拒絕與當前 `tested_target` 無直接關聯的 sibling verifier。

5. Output Expectation
   1. `Given` 應產出可量測 before-state 的 `selected_plan`，並遵守 shared precondition trace schema。
   2. `Then` 應選出最小 changed-state verifier，並在 `# @decision:` / `# @rationale:` 交代採用原因與主要淘汰理由。
