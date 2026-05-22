# SOP

緣由：上一步已在每個 `# @dsl` block 補齊 `# candidates:`；本步只在 `${FEATURE_SPECS_DIR}` 內依 atomic rule demand 淘汰並選定 DSL、替換 `<dsl>` placeholder，不再回頭探索 boundary truth。

0. RESOLVE arguments——將本 SOP 引用的 `${VAR}` 透過 sibling resolver 綁定，並把 resolver stdout（每行一筆 `KEY=value`）原樣 EMIT 給用戶。Resolver 非 0 退出時，停止本 SOP 並把 stderr 透傳給用戶。

   ```bash
   python3 .claude/skills/aibdd-core/scripts/python/resolve_args.py <<'EOF'
   FEATURE_SPECS_DIR=${FEATURE_SPECS_DIR}
   CONTRACTS_DIR=${CONTRACTS_DIR}
   DATA_DIR=${DATA_DIR}
   BOUNDARY_SHARED_DSL=${BOUNDARY_SHARED_DSL}
   EOF
   ```

1. LIST `${FEATURE_SPECS_DIR}/**/*.feature`。

2. [LOOP] FOR EACH 上述 `.feature` 內每個 `# @dsl` block：
   1. 載入上文：
      1. READ 本 block 的 `# rule:` 指向之 selection-criteria markdown（展開 `${SKILL_HOME}` 後解析路徑）。
      2. PARSE 當前 placeholder step keyword，決定 `$slot_kind`：
         1. `Given` + `precondition-state.md` / `precondition-param.md` / `postcondition-response.md` / `postcondition-state.md` → `precondition-construction`
         2. `And` + `precondition-state.md` / `postcondition-state.md` → `state-verification`
         3. `And` + `postcondition-response.md` → `response-verification`
         4. 其餘組合 → `generic-selection`
      3. EXTRACT 本 block 的 `# handler-candidate-kinds:` 與 `# candidates:`。
      4. READ 父 `Rule:` 的 atomic rule 文字與當前 `Example` 意圖。
      5. QUERY DSL catalog——對 `# handler-candidate-kinds:` 各 kind 執行 `dsl_cli query`，掃描 `${CONTRACTS_DIR}/*.dsl.yml`、`${DATA_DIR}/*.dsl.yml` 與 `${BOUNDARY_SHARED_DSL}`（`time-control` / `external-stub` 僅查 shared；其餘查 regular；與 phase 02 相同 routing）：
         ```bash
         PYTHONPATH=.claude/skills/aibdd-core/scripts python3 -m dsl_cli query \
           --handler <kind> \
           --dsl "${CONTRACTS_DIR}/<file>.dsl.yml" \
           --shared-dsl "${BOUNDARY_SHARED_DSL}" \
           --source-scope <regular|shared|all>
         ```
      6. INTERSECT query matches 與 `# candidates:` 名單，整理為 `candidate_specs`（每筆含 `name`、`handler`、`format`、`target_part_path`、`param_bindings`、`datatable_bindings`）。
      7. 若 `# candidates:` 任一名稱無法 resolve：以 unresolved 名稱組成 `$questions`，針對 `$questions` 直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.1。
   2. 完整定義和滿足 rule demand（此 Rule 需要什麼樣子的測試 DSL 編排，才有足夠的測試合法性、完整度？）：
      1. 從父 `Rule:` 抽出 `rule_type`、`subject`、`condition`、`expected_effect`。
      2. 從 `subject + condition + Example intent` 決定 `tested_target`；無法唯一決定：組成 `$questions`，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.2。
      3. READ `rules/equivalence-partition.md`，CLASSIFY `predicate_shape` 並 SELECT `ep_classes`；不得自造 shape name；無法判定：組成 `$questions`，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.2。
      4. 從 `rule_type` 與 `Example intent` DETERMINE `test_direction`。
      5. READ `rules/boundary-value-analysis.md`，SELECT `bva_points`。
      6. BUILD `required_test_values`（`tested_target`、`predicate_shape`、`test_direction`、`ep_classes`、`bva_points`）；若 `ep_classes` 與 `bva_points` 皆空：組成 `$questions`，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.2。
   3. BRANCH by `$slot_kind`：
      1. 若 `$slot_kind == precondition-construction`：
         1. READ `.claude/skills/aibdd-core/assets/boundaries/shared/precondition-construction-template.md` 與 `.claude/skills/aibdd-core/assets/boundaries/shared/precondition-construction-trace-schema.md`。
         2. 依當前 `# rule:` entrypoint 繼續 READ boundary-specific family：`strategy-catalog.md`、`legality-gate.md`、`optimization.md`、`arrangement-rules.md`；若 arrangement shape 仍不清楚，再 READ relevant `examples/*.md`。
         3. ENUMERATE `construction_plans`——從 `candidate_specs` 推出可行之前置建構 plans；每個 plan 至少含 `strategy`、`ordered_candidates`、`supporting_candidates`、`constructed_state_summary`。
         4. APPLY legality gate——淘汰讓 `When` 不可執行、不能控制 `tested_target`、破壞 aggregate invariant、或把主操作偷跑進 `Given` 的 plan；餘者為 `legal_plans`；若為空：組成 `$questions` 並列出主要淘汰理由，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.3.1。
         5. APPLY optimization——對 `legal_plans` 依 boundary-specific optimization tie-break，選出 `selected_plan`；若仍無法決定：組成 `$questions`，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.3.1。
         6. arrange DSL——依 `selected_plan` 產出一條或多條 `Given` / `And` steps；多條 ordering 依 arrangement rules 決定；將 `<dsl>` 替換為所選 step 序列，值仍保留 placeholder。
         7. EMIT trace——在 `Example` 上方 EMIT `# @test-values`（內容來自 `required_test_values`）；在 `# @dsl` block 內 EMIT shared trace schema 定義的 precondition trace；並同步保留 `# @decision:`（列出 `selected_plan.ordered_candidates`）與 `# @rationale:`（摘要為何此 plan 勝出）。
      2. 否則：
         1. coverage filter——淘汰 `handler` 與 slot 或 selection-criteria 明顯不相容者；淘汰 `target_part_path` / bindings 碰不到 `tested_target` 者；淘汰 `format` 無法表達 block 意圖者；餘者為 `coverage_survivors`；若為空：組成 `$questions` 並列出各 candidate 淘汰理由，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.3.2。
         2. feasibility filter——對每筆 `coverage_survivor` READ 其 `target_part_path` 與 binding `target` 指向之 OpenAPI / DBML truth；判斷 SSOT 能否承載 `required_test_values`；不能者標 `infeasible` 並記原因；餘者為 `feasible_candidates`；若為空：組成 `$questions` 並列出各 candidate 淘汰理由，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.3.2。
         3. SELECT survivors——對 `feasible_candidates` 套用 `# rule:` selection-criteria；零筆 survive：組成 `$questions`，直接 DELEGATE `/clarify-loop` 提問來修正當前 block 所需資訊；修正完成後重複執行 2.3.2；一筆直接採用；多筆依序 tie-break：`minimum cardinality` → `aggregate invariant satisfaction` → `state path shortest`；結果記為 `selected_candidates`。
         4. arrange DSL——依 `selected_candidates` 決定一條或多條 DSL；多條 ordering 依 selection-criteria 與語意相依順序；將 `<dsl>` 替換為選定 `format` 句型，值仍保留 placeholder。
         5. EMIT trace——在 `Example` 上方 EMIT `# @test-values`（內容來自 `required_test_values`）；在 `# @dsl` block 內 EMIT `# @decision:`（列出 `selected_candidates`）與 `# @rationale:`（survive 與主要淘汰理由）；保留原 `# @dsl` block 供下游 evaluator 審 trace。
