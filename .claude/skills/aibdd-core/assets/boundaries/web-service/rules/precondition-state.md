# Rule Type: 前置（狀態）

1. Role
   1. 本檔是 web-service boundary 中 `前置（狀態）` rule type 的整體立法包。
   2. 本檔只擁有 `Given` 與 `Then` 兩個 building block。

2. Given Block
   1. `Given` 的目標是建出「不滿足 rule condition」但「仍足以進入主操作」的受測前置狀態。
   2. `Given` 只能使用當前 `# candidates:` 中已存在的 `candidate_specs`。
   3. 除了被測條件本身之外，其餘 aggregate invariant 應盡量維持合法，避免失敗來源混雜。
   4. 先做 legality gate，再做 optimization。
   5. 優先選最小 state scope、最短 state path、最少額外心證的 arrangement。
   6. 允許一條或多條 `Given` / `And`；若單條過胖或語意不清，優先拆成多條。
   7. 不得把主操作偷跑進 `Given`。

3. Then Block
   1. `Then` 的主驗證是操作失敗，且錯誤訊息必須是具體 failure outcome。
   2. 若當前 form 還帶有 `state-verifier` slot，該 slot 用來證明 failure path 沒有偷偷改變既有 persisted state。
   3. `Then` 驗 unchanged state 時，優先選最小且最直接能證明 no-change 的 verifier scope。
   4. 不得把 response failure 訊號誤當成 state unchanged 證明。

4. Hard Rejections
   1. 拒絕會讓主操作在 `Given` 內先被執行的 arrangement。
   2. 拒絕把不相干的違規狀態混進同一個 `Given`，導致無法確定 failure source。
   3. 拒絕與當前 failure path 無直接關聯的 sibling verifier。

5. Output Expectation
   1. `Given` 應產出一個 `selected_plan`，將 `<dsl>` 替換為對應 step 序列，並遵守 shared precondition trace schema。
   2. `Then` 若存在動態 verifier slot，應選出最小 no-change verifier，並在 `# @decision:` / `# @rationale:` 交代採用原因。
