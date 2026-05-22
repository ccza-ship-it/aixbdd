Feature: 開房或加入遊戲房

    玩家透過 HTTP 呼叫 openOrJoinRoom，以四位房號開新房或加入現有房。

    Rule: 前置（參數） - 房號必須為四位數字（0–9）
        Scenario Outline: <參數名> = <無效值> 時 <操作> 失敗
          # @dsl
          # handler-candidate-kinds: state-builder | operation-invoke | time-control | external-stub
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/precondition-param.md
          # candidates:
          #   - rooms.state-builder
          #   - games.state-builder
          #   - bosses.state-builder
          #   - player_guesses.state-builder
          #   - boss_rounds.state-builder
          #   - boss_hits.state-builder
          #   - openOrJoinRoom.operation-invoke
          #   - markPlayerReady.operation-invoke
          #   - startGame.operation-invoke
          #   - setPlayerSecret.operation-invoke
          #   - submitPlayerGuess.operation-invoke
          #   - clock.time-control
          Given <dsl>
          When 以房號 {房號} 與名稱 {顯示名稱} 開房或加入
          Then 操作失敗，錯誤為 "<具體驗證錯誤訊息>"

    Rule: 前置（狀態） - 加入現有房時房間人數必須少於 10
        Example: <主詞> 不滿足 <條件> 時 <操作> 失敗
          # @dsl
          # handler-candidate-kinds: state-builder | operation-invoke | time-control | external-stub
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/precondition-state.md
          # candidates:
          #   - rooms.state-builder
          #   - games.state-builder
          #   - bosses.state-builder
          #   - player_guesses.state-builder
          #   - boss_rounds.state-builder
          #   - boss_hits.state-builder
          #   - openOrJoinRoom.operation-invoke
          #   - markPlayerReady.operation-invoke
          #   - startGame.operation-invoke
          #   - setPlayerSecret.operation-invoke
          #   - submitPlayerGuess.operation-invoke
          #   - clock.time-control
          Given <dsl>
          When 以房號 {房號} 與名稱 {顯示名稱} 開房或加入
          Then 操作失敗，錯誤為 "<具體錯誤訊息>"
          # @dsl
          # handler-candidate-kinds: state-verifier
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/precondition-state.md
          # candidates:
          #   - rooms.state-verifier
          #   - games.state-verifier
          #   - bosses.state-verifier
          #   - player_guesses.state-verifier
          #   - boss_rounds.state-verifier
          #   - boss_hits.state-verifier
          And <dsl>

    Rule: 後置（狀態） - 若房號不存在，應建立新房間
        Example: <操作> 後 <狀態主詞> 變為 <新狀態>
          # @dsl
          # handler-candidate-kinds: state-builder | operation-invoke | time-control | external-stub
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-builder
          #   - games.state-builder
          #   - bosses.state-builder
          #   - player_guesses.state-builder
          #   - boss_rounds.state-builder
          #   - boss_hits.state-builder
          #   - openOrJoinRoom.operation-invoke
          #   - markPlayerReady.operation-invoke
          #   - startGame.operation-invoke
          #   - setPlayerSecret.operation-invoke
          #   - submitPlayerGuess.operation-invoke
          #   - clock.time-control
          Given <dsl>
          When 以房號 {房號} 與名稱 {顯示名稱} 開房或加入
          Then 操作成功
          # @dsl
          # handler-candidate-kinds: state-verifier
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-verifier
          #   - games.state-verifier
          #   - bosses.state-verifier
          #   - player_guesses.state-verifier
          #   - boss_rounds.state-verifier
          #   - boss_hits.state-verifier
          And <dsl>

    Rule: 後置（狀態） - 若房號不存在，玩家應成為房主（P1）
        Example: <操作> 後 <狀態主詞> 變為 <新狀態>
          # @dsl
          # handler-candidate-kinds: state-builder | operation-invoke | time-control | external-stub
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-builder
          #   - games.state-builder
          #   - bosses.state-builder
          #   - player_guesses.state-builder
          #   - boss_rounds.state-builder
          #   - boss_hits.state-builder
          #   - openOrJoinRoom.operation-invoke
          #   - markPlayerReady.operation-invoke
          #   - startGame.operation-invoke
          #   - setPlayerSecret.operation-invoke
          #   - submitPlayerGuess.operation-invoke
          #   - clock.time-control
          Given <dsl>
          When 以房號 {房號} 與名稱 {顯示名稱} 開房或加入
          Then 操作成功
          # @dsl
          # handler-candidate-kinds: state-verifier
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-verifier
          #   - games.state-verifier
          #   - bosses.state-verifier
          #   - player_guesses.state-verifier
          #   - boss_rounds.state-verifier
          #   - boss_hits.state-verifier
          And <dsl>

    Rule: 後置（狀態） - 若房號已存在，玩家應加入該房間
        Example: <操作> 後 <狀態主詞> 變為 <新狀態>
          # @dsl
          # handler-candidate-kinds: state-builder | operation-invoke | time-control | external-stub
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-builder
          #   - games.state-builder
          #   - bosses.state-builder
          #   - player_guesses.state-builder
          #   - boss_rounds.state-builder
          #   - boss_hits.state-builder
          #   - openOrJoinRoom.operation-invoke
          #   - markPlayerReady.operation-invoke
          #   - startGame.operation-invoke
          #   - setPlayerSecret.operation-invoke
          #   - submitPlayerGuess.operation-invoke
          #   - clock.time-control
          Given <dsl>
          When 以房號 {房號} 與名稱 {顯示名稱} 開房或加入
          Then 操作成功
          # @dsl
          # handler-candidate-kinds: state-verifier
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-verifier
          #   - games.state-verifier
          #   - bosses.state-verifier
          #   - player_guesses.state-verifier
          #   - boss_rounds.state-verifier
          #   - boss_hits.state-verifier
          And <dsl>

    Rule: 後置（狀態） - 若房號已存在，玩家應依序取得最小未使用的玩家編號

        Example: <操作> 後 <狀態主詞> 變為 <新狀態>
          # @dsl
          # handler-candidate-kinds: state-builder | operation-invoke | time-control | external-stub
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-builder
          #   - games.state-builder
          #   - bosses.state-builder
          #   - player_guesses.state-builder
          #   - boss_rounds.state-builder
          #   - boss_hits.state-builder
          #   - openOrJoinRoom.operation-invoke
          #   - markPlayerReady.operation-invoke
          #   - startGame.operation-invoke
          #   - setPlayerSecret.operation-invoke
          #   - submitPlayerGuess.operation-invoke
          #   - clock.time-control
          Given <dsl>
          When 以房號 {房號} 與名稱 {顯示名稱} 開房或加入
          Then 操作成功
          # @dsl
          # handler-candidate-kinds: state-verifier
          # rule: ${SKILL_HOME}/aibdd-core/assets/boundaries/web-service/rules/postcondition-state.md
          # candidates:
          #   - rooms.state-verifier
          #   - games.state-verifier
          #   - bosses.state-verifier
          #   - player_guesses.state-verifier
          #   - boss_rounds.state-verifier
          #   - boss_hits.state-verifier
          And <dsl>
