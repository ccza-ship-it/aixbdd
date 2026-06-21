# SOP

1. 解析 arguments: EXECUTE command 以 resolver 綁定本 SOP 引用的變數並對使用者輸出 resolver stdout（每行一筆 `KEY=value`），resolver 非 0 退出時 STOP 並對使用者輸出其 stderr；resolver 輸出含 `<<NNN-plan-slug>>` 者由 `$PLAN_PACKAGE_SLUG` 解析，`${TRUTH_FUNCTION_PACKAGE}` 與 `${FEATURE_SPECS_DIR}` 另含 `<<NN-functional-module>>` 由各 `.feature` 所屬 package 的 `NN-<slug>` 解析。

   ```bash
   python3 .claude/skills/aibdd-core/scripts/cli/resolve_args.py <<'EOF'
   FEATURE_SPECS_DIR=${FEATURE_SPECS_DIR}
   IMPACT_MATRIX_YML=${IMPACT_MATRIX_YML}
   PLAN_SPEC=${PLAN_SPEC}
   PROJECT_SPEC_LANGUAGE=${PROJECT_SPEC_LANGUAGE}
   TRUTH_BOUNDARY_ROOT=${TRUTH_BOUNDARY_ROOT}
   TRUTH_FUNCTION_PACKAGE=${TRUTH_FUNCTION_PACKAGE}
   EOF
   ```

2. 確認待落檔 feature: ASSERT `$ACTION_FEATURES` 非空，為空則 STOP 並對使用者輸出尚未偵測到任何 action 與其 binds_feature，請先完成 activity 建模再建構 feature 骨架。

3. WRITE feature-file 骨架（rule-less）

   3.1 對 `$ACTION_FEATURES` 每個 `{ binds_feature, impact_id }` 的 binds_feature path，在該 path CREATE `.feature`，維持 `.activity` action 節點與 `.feature` 一一對應；該 `.feature` 已存在時不覆寫、不重建，僅在缺檔時新建。

   3.2 `.feature` 內容只寫檔頭骨架，逐行如下，不得寫入任何 Rule:、Background、Scenario、Examples、Step：

     ```gherkin
     # @ignore - 等執行 /aibdd-red-execute 時，會只將 target Feature file 標注的 @ignore 拿掉，透過此手段來控制範疇。
     @ignore
     Feature: <表該 action 業務意圖的標題>
     ```

   3.3 Feature: 標題填該 binds_feature 對應 action 之業務意圖，不得等同實作細節或內部技術步驟名稱。

   3.4 一致性確認：每個 `.activity` action 節點之 binds_feature 都須對應到本步建立或既存之 `.feature`；某 binds_feature path 非法或無法建立者蒐集成 `$FEATURE_GAPS`。

   3.5 若 `$FEATURE_GAPS` 非空 則對其每個 gap DELEGATE `/clarify-loop` 釐清、附其對應 action 與預期 feature 路徑作 anchor，參考 `aibdd-core::references/ssot/spec.template.md` 的澄清紀錄填寫規則把拍板結論 WRITE 進 `${PLAN_SPEC}` 批次 `$BATCH_NO`、owner `aibdd-flows-specify` 的澄清區塊，再依結論修正 binds_feature 並重寫對應 `.feature`，若結論改動了某既有 `.activity` action 節點之 binds_feature 則連動更新該 `.activity`，重複至 `$FEATURE_GAPS` 清空。

4. 盤點並刪除孤兒 .feature

   4.1 設 `$OBSOLETE_FEATURES` 為本批次已無任何 `.activity` action 節點 binds_feature 指向且需求明文淘汰的既有 `.feature`。

   4.2 對 `$OBSOLETE_FEATURES` 每個先 ASSERT 已無任何 `.activity` action 節點 binds_feature 指向，仍被綁定者不刪、蒐集成 `$ORPHAN_GAPS`，確認無指向後 DELETE，實際刪除者記為 `$DELETED_FEATURES`。

   4.3 若 `$ORPHAN_GAPS` 非空 則對其每個 gap DELEGATE `/clarify-loop` 釐清、附其 `.feature` 與既有綁定作 anchor，參考 `aibdd-core::references/ssot/spec.template.md` 的澄清紀錄填寫規則把拍板結論 WRITE 進 `${PLAN_SPEC}` 批次 `$BATCH_NO`、owner `aibdd-flows-specify` 的澄清區塊，再依結論重新判定各目標刪除與否、補刪確認淘汰者，重複至 `$ORPHAN_GAPS` 清空。

5. 回寫 .feature impact

   5.1 READ `aibdd-core::references/impact-matrix/cli-usage.md`，取得通用規則、資料模型、status 語意與各 verb 應用 command。

   5.2 對本批次新建的每個 `.feature`，設其相對 `${TRUTH_BOUNDARY_ROOT}` 路徑為 spec_path、其 binds_feature 在 `$ACTION_FEATURES` 對應的來源 impact 為 impact_id；若該 impact 尚無此 spec 則 EXECUTE command `add-spec --id <impact_id> --spec <spec_path> --status consistent`，否則 EXECUTE command `transit-status --id <impact_id> --spec <spec_path> --status consistent`；若 command 失敗則依其 violations 修正後重試直到成功。

   5.3 對 `$DELETED_FEATURES` 每個 `.feature`，以 `read` 取回其所屬 impact id 與 spec_path 後 EXECUTE command `transit-status --id <impact_id> --spec <spec_path> --status consistent` 保留該 spec 並轉為 consistent；若 command 失敗則依其 violations 修正後重試直到成功。

6. 結案完成的 impact: EXECUTE command 以 `read --owner aibdd-flows-specify --impact-status pending` 取回本 owner 仍 pending 的 impact，對其中 specs 非空且全部 spec 皆為 consistent 的每個 impact EXECUTE command `transit-status --id <impact_id> --status resolved`；若 command 失敗則依其 violations 修正後重試直到成功。
