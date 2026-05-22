Feature: 玩家準備

    Rule: 前置（狀態） - 觸發者必須為房客（非房主）
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
          When 玩家 {玩家} 在房間 {房間} 標記準備
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

    Rule: 後置（狀態） - 玩家應標記為已準備

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
          When 玩家 {玩家} 在房間 {房間} 標記準備
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
