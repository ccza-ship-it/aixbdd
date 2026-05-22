# Rule Type: 前置（參數）

1. Role
   1. 本檔是 web-service boundary 中 `前置（參數）` rule type 的整體立法包。
   2. 本檔只定義 `Given` 與 `Then` 的 rule-specific legislation。

2. Given Block
   1. `Given` 的目標是建出一個最小且合法的背景，使主操作可以被正常呼叫。
   2. 失敗來源必須收斂在 `When` 帶入的無效參數，不得提前藏進 state。
   3. `Given` 只能使用當前 `# candidates:` 中已存在的 `candidate_specs`。
   4. 先做 legality gate，再做 optimization。
   5. 若 rule 採 `Scenario Outline`，無效值應集中在 `Examples` / `When`，不要回滲進 `Given`。
   6. 允許一條或多條 `Given` / `And`；若單條足夠清楚，優先保持最小句數。

3. Then Block
   1. `Then` 的主驗證是 validation failure，且錯誤訊息必須具體對應被測參數條件。
   2. 若未來此 rule type 增加動態 verifier slot，應優先證明 side effect 不得發生。
   3. 不得用過大的 state scope 間接猜測 validation failure。
   4. 不得把 unrelated state drift 混入 failure path 驗證。

4. Hard Rejections
   1. 拒絕會讓主操作在送入無效參數前就先失敗的 `Given`。
   2. 拒絕把同一個無效參數條件重複寫進 state 與 input，造成責任不清。
   3. 拒絕需要額外心證才能看出其為主操作的 `When` candidate。

5. Output Expectation
   1. `Given` 應產出最小合法背景的 `selected_plan`，並遵守 shared precondition trace schema。
   2. 當前 form 下 `Then` 多為固定 failure sentence；若未來存在動態 verifier slot，仍應輸出最小 no-op verifier 與對應 rationale。
