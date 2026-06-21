# SOP

1. 解析 arguments: EXECUTE command 以 resolver 綁定本 SOP 引用的變數並對使用者輸出 resolver stdout（每行一筆 `KEY=value`），resolver 非 0 退出時 STOP 並對使用者輸出其 stderr；resolver 輸出含 `<<NNN-plan-slug>>` 者由 `$PLAN_PACKAGE_SLUG` 解析，`${TRUTH_FUNCTION_PACKAGE}`、`${FEATURE_SPECS_DIR}`、`${ACTIVITIES_DIR}` 另含 `<<NN-functional-module>>` 由各 spec 所屬 function package 的 `NN-<slug>` 解析。

   ```bash
   python3 .claude/skills/aibdd-core/scripts/cli/resolve_args.py <<'EOF'
   ACTIVITIES_DIR=${ACTIVITIES_DIR}
   FEATURE_SPECS_DIR=${FEATURE_SPECS_DIR}
   IMPACT_MATRIX_YML=${IMPACT_MATRIX_YML}
   PLAN_SPEC=${PLAN_SPEC}
   PROJECT_SPEC_LANGUAGE=${PROJECT_SPEC_LANGUAGE}
   TRUTH_BOUNDARY_ROOT=${TRUTH_BOUNDARY_ROOT}
   TRUTH_FUNCTION_PACKAGE=${TRUTH_FUNCTION_PACKAGE}
   EOF
   ```

2. 載入建模基準

   2.1 設 `$WORKLIST_QUOTES` 為 `$WORKLIST` 各 impact 的 quotes 聯集，每句標註其來源 impact id，為本批次要 formulate 成 spec 的需求句。

   2.2 設 `$STALE_ACTIVITIES` 為 `$WORKLIST` 中 spec status 為 inconsistent 且以 `.activity` 結尾的 spec，為既有待重新建模的 UAT flow。

   2.3 READ `${PLAN_SPEC}` 取 `$WORKLIST_QUOTES` 所在的需求脈絡作為建模背景，並設 `$BATCH_NO` 為其需求描述段最新批次號。

3. Faithful REASONING 萃取 api-wise 業務 action

   3.1 針對 `$WORKLIST_QUOTES` 每句，嚴格遵照 `aibdd-flows-specify/02-activity-analyze/rules/apiwise-granularity.md` 的顆粒度定義萃取 RESTful-API-like 業務 action；請勿捕捉句子中不存在的元素，每個捕捉物都要明確指回其來源句與來源 impact id。

   3.2 將每個證據充足的 action 綁定至 `$PLAN_SCOPE` 中某個 `added` 或 `related` 的 package：既有待更新者沿用其來源 impact 既有 spec path 所屬 package，全新者依該 action 與各 package rationale 配對；derive 其 binds_feature path 為 `${FEATURE_SPECS_DIR}/<NN>-<action-slug>.feature`（`<NN>` 為 package 內兩位數序號，`<action-slug>` 依 slug 命名規則 PRINCIPLE 命名），本步只命名不建檔。

   3.3 紀錄所有證據充足的 action 作為 `$ACTIONS`，每個含 `{ action, package, binds_feature, impact_id }`，其 `{ binds_feature, impact_id }` 成對聯集為 `$ACTION_FEATURES`；下列疑點蒐集成 `$ACTION_GAPS`（落入者不作節點、不予 binds_feature、不納入 `$ACTION_FEATURES`）：
     - 針對某 action 不確定其顆粒度是否正確。
     - 某句需求暗示了業務動作，但證據不足以判定 actor、觸發點或可驗收結果。
     - 某 action 無法明確歸屬到任一 `$PLAN_SCOPE` 的 package。

   3.4 若 `$ACTION_GAPS` 非空 則對其每個 gap DELEGATE `/clarify-loop` 釐清、附其來源 quote 與候選 package 作 anchor，參考 `aibdd-core::references/ssot/spec.template.md` 的澄清紀錄填寫規則把結論 WRITE 進 `${PLAN_SPEC}` 批次 `$BATCH_NO`、owner `aibdd-flows-specify` 的澄清區塊，再依結論回到 3.2 重新 REASONING，重複至 `$ACTION_GAPS` 清空。

4. Faithful REASONING 萃取 Actors

   4.1 針對 `$ACTIONS` 之每個 action 自 `$WORKLIST_QUOTES`  REASONING 其觸發者作為 `$ACTORS`，嚴格遵照 `aibdd-flows-specify/02-activity-analyze/rules/activity-actor-granularity.md`；某 action 無法判定觸發 Actor 者蒐集成 `$ACTOR_GAPS`。

   4.2 若 `$ACTOR_GAPS` 非空 則對其每個 gap DELEGATE `/clarify-loop` 釐清、附其 action 與來源 quote 作 anchor，參考 `aibdd-core::references/ssot/spec.template.md` 的澄清紀錄填寫規則把拍板結論 WRITE 進 `${PLAN_SPEC}` 批次 `$BATCH_NO`、owner `aibdd-flows-specify` 的澄清區塊，再依結論回到 4.1 重新 REASONING，重複至 `$ACTOR_GAPS` 清空。

5. Faithful REASONING `$UAT_FLOWS` 清單（一條 flow = 一張 activity，從 actor 可理解的進場到可驗收完整旅程）

   5.1 READ `aibdd-flows-specify/02-activity-analyze/rules/activity-diagram-granularity.md`。

   5.2 從 `$WORKLIST_QUOTES` 與 `$ACTIONS` 提煉獨立的 flows 作為 `$UAT_FLOWS`，每筆必備：
     - uat_flow_id：本批次唯一
     - summary_one_line：一句話 journey
     - activity_relpath：相對其 package `${ACTIVITIES_DIR}` 之唯一相對路徑，須以 `.activity` 結尾、不得以 / 開頭，檔名依 slug 命名規則 PRINCIPLE 命名
     - member_actions：本 flow 涵蓋之 actions ⊆ `$ACTIONS`，每個帶其 binds_feature
     - variation_role：寬鬆度（happy_path／extreme_min／extreme_max／additional）選填，未知則 additional

   5.3 覆蓋約束確認：每個證據充足的 action 至少歸屬一條 flow（純查詢或唯讀且無業務狀態遷移者得依 `activity-diagram-granularity.md` 併入主流程之讀取段、不另立圖，但仍保留其 `$ACTIONS` 身分與 `$ACTION_FEATURES` 成員資格）。

6. Faithful REASONING 控制流建模

   6.1 READ `aibdd-flows-specify/02-activity-analyze/reasoning/activity-control-flow.md`。

   6.2 針對 `$UAT_FLOWS` 每一條 flow，依 `activity-control-flow.md` 建模成完整有向圖，含 name／id／initial／finals[]／actors[]／nodes[]（Action｜Decision｜Fork｜Merge｜Join，Action 節點帶 display_id、@actor、description、binds_feature）；建模未盡之處蒐集成 `$GRAPH_GAPS`。

   6.3 若 `$GRAPH_GAPS` 非空 則對其每個 gap DELEGATE `/clarify-loop` 釐清、附其所屬 flow 與節點作 anchor，參考 `aibdd-core::references/ssot/spec.template.md` 的澄清紀錄填寫規則把拍板結論 WRITE 進 `${PLAN_SPEC}` 批次 `$BATCH_NO`、owner `aibdd-flows-specify` 的澄清區塊，再依結論回到 6.2 重新 REASONING，重複至 `$GRAPH_GAPS` 清空。

   6.4 將每條 flow 之 name／id／initial／finals／actors／nodes 整體設為該 flow 之 `$ACTIVITY_ANALYSIS`。

7. 產出 .activity: 針對 `$UAT_FLOWS` 每條 flow DELEGATE `/aibdd-form-activity`，交付該 flow 之 `$ACTIVITY_ANALYSIS` 並落檔 target_path 定為其 package 的 `${ACTIVITIES_DIR}/<activity_relpath>`，既有檔需更新且建模有實質變更時帶 overwrite；所須輸入與 `.activity` 格式參照 `aibdd-form-activity/references/role-and-contract.md`；form activity 落檔不是停點，ok 為 false 則修正後重新建模。

8. 盤點並刪除孤兒 .activity: DELETE 本批次無任何 `$ACTIONS` 指向且需求明文淘汰的既有 `.activity` 檔案；實際刪除者記為 `$DELETED_ACTIVITIES`。

9. 回寫 .activity impact

   9.1 READ `aibdd-core::references/impact-matrix/cli-usage.md`，取得通用規則、資料模型、status 語意與各 verb 應用 command。

   9.2 對本批次新建或以 overwrite 改寫的每個 `.activity`，設其相對 `${TRUTH_BOUNDARY_ROOT}` 路徑為 spec_path、其所 formulate 的來源 impact 為 impact_id；若該 impact 尚無此 spec 則 EXECUTE command `add-spec --id <impact_id> --spec <spec_path> --status consistent`，否則 EXECUTE command `transit-status --id <impact_id> --spec <spec_path> --status consistent`；若 command 失敗則依其 violations 修正後重試直到成功。

   9.3 對 `$DELETED_ACTIVITIES` 每個 `.activity`，以 `read` 取回其所屬 impact id 與 spec_path 後 EXECUTE command `transit-status --id <impact_id> --spec <spec_path> --status consistent` 保留該 spec 並轉為 consistent；若 command 失敗則依其 violations 修正後重試直到成功。
