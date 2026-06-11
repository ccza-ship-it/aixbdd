# SOP — 需求變更（鎖定既有 plan package，套用本輪需求增量）

0. **RESOLVE arguments**——將本 SOP 引用的 `${VAR}` 透過 sibling resolver 綁定，並把 resolver stdout（每行一筆 `KEY=value`）原樣 EMIT 給用戶。Resolver 非 0 退出時，停止本 SOP 並把 stderr 透傳給用戶。Resolver 輸出的 plan-package 衍生鍵仍含 `<<NNN-plan-slug>>` 借位（`arguments.yml` 永遠如此）；該借位由 caller-context 已鎖定的 plan slug 解析為具體路徑。若 caller-context 沒有已鎖定的 slug，STOP 並回報「plan package 未鎖定，請回上下文解析」。

   ```bash
   python3 .claude/skills/aibdd-core/scripts/cli/resolve_args.py <<'EOF'
   CONTRACTS_DIR=${CONTRACTS_DIR}
   CURRENT_PLAN_PACKAGE=${CURRENT_PLAN_PACKAGE}
   DATA_DIR=${DATA_DIR}
   FEATURE_SPECS_DIR=${FEATURE_SPECS_DIR}
   IMPACT_MATRIX_YML=${IMPACT_MATRIX_YML}
   PLAN_PACKAGES_DIR=${PLAN_PACKAGES_DIR}
   PLAN_REPORTS_DIR=${PLAN_REPORTS_DIR}
   PLAN_SPEC=${PLAN_SPEC}
   PROJECT_SPEC_LANGUAGE=${PROJECT_SPEC_LANGUAGE}
   TRUTH_BOUNDARY_PACKAGES_DIR=${TRUTH_BOUNDARY_PACKAGES_DIR}
   TRUTH_BOUNDARY_ROOT=${TRUTH_BOUNDARY_ROOT}
   TRUTH_FUNCTION_PACKAGE=${TRUTH_FUNCTION_PACKAGE}
   EOF
   ```

0.1 READ [`aibdd-flows-specify/rules/specs-root-layout.md`](aibdd-flows-specify/rules/specs-root-layout.md) 作為本 sub-SOP 內所有 `${PLAN_PACKAGES_DIR}` / `${TRUTH_BOUNDARY_ROOT}` / `${TRUTH_BOUNDARY_PACKAGES_DIR}` / `${CONTRACTS_DIR}` / `${DATA_DIR}` 目錄結構路徑的 SSOT。

0.2 DERIVE `$package_naming_language`（**僅當本輪變更需新開 function package 時才執行**；plan package 已鎖定既有包，本路徑不產生新 plan slug，無 `$plan_package_slug` 命名需求）：

- SOURCE：`$package_naming_language` = ${PROJECT_SPEC_LANGUAGE}（zh-hant / zh-hans / en-us / ja-jp / ko-kr 等 BCP-47 值；同 `${FILENAME_AXES_TITLE_LANGUAGE_REF}` 所指 i18n reference）。
- 後續所有新開之 `$function_package_slug`（`NN-<slug>`）之 `<slug>` 主體**必須以該語系自然書寫**。
- 技術名詞（API field、DSL token、operationId、domain acronym 如 CRM／SOP／API／OAuth）**可保留英文原文**；其餘 slug body 不得整段翻成英文。
- **【嚴禁】以 romanization（漢語拼音／注音／粵拼）、kana、romaji 等 transliteration 充當「為避該語系字元」的 fallback**。落到 filesystem 的 slug 必須讀得懂、可直接還原為該語系文字。
- IF `$package_naming_language` == `zh-hant`：
  - ✅ Good：`packages/01-會員登入`
  - ❌ Bad（romanization）：`packages/01-hui-yuan-deng-ru`
  - ❌ Bad（整段英譯，無此需求）：`packages/01-member-login`
- IF `$package_naming_language` == `zh-hans`：規則同 zh-hant，但用簡體字形。
- IF `$package_naming_language` == `en-us`：slug 以英文撰寫，使用 kebab-case。
  - ✅ Good：`packages/01-member-login`
- IF `$package_naming_language` == `ja-jp`：以日文書寫，禁止以 romaji 取代漢字／假名。
- IF `$package_naming_language` == `ko-kr`：以韓文（Hangul）書寫，禁止以 romaja 取代。
- **禁止無理由中英檔名混拼**（半中半英的 slug，如 `01-會員-login`，除非含上述技術 token 例外）。
- 若 `${PROJECT_SPEC_LANGUAGE}` 缺失或無法判斷，**不得**自行 fallback 為英文或 romanization，須 DELEGATE `/clarify-loop` 詢問用戶。

1. ANCHOR + SEARCH（本步僅 READ／SEARCH／WRITE `${PLAN_SPEC}` 與補建缺漏骨架；`${TRUTH_BOUNDARY_ROOT}` 下 truth 不寫入；`arguments.yml` 不寫入）
   - 1.1 CHECK baseline 並補建缺漏（缺什麼補什麼，不回退、不 STOP）：
     - `${PLAN_SPEC}` 缺 → 依 `aibdd-flows-specify/assets/templates/spec.template.md` CREATE 空骨架（僅 `## 需求描述` 章節）；本輪變更敘事將於 1.2 寫成首個批次。
     - `${PLAN_REPORTS_DIR}/discovery-sourcing.md` 缺 → 依 `aibdd-flows-specify/assets/templates/discovery-sourcing.template.md` CREATE 章節骨架；內容由步驟 4／7 填入。
     - `${IMPACT_MATRIX_YML}` 缺 → 記 `$matrix_missing = true`，由步驟 3 補跑 `init`。
     - 既有產物一律 READ-ONLY 載入，不在本步改寫。
   - 1.2 AMEND `${PLAN_SPEC}`（批次遞增）：在 `## 需求描述` 下**追加**一個批次小節記錄本輪變更，格式依 `aibdd-flows-specify/assets/templates/spec.template.md`：
     - 批次標題：`### 批次 NNN（YYYY-MM-DD，需求變更）`，`NNN` = 既有最大批次 + 1（三位數零填充；`${PLAN_SPEC}` 為 1.1 新建的空骨架時自 `001` 起、註記改為「初始」）。
     - 既有全文尚未分批次（舊格式）者，先整體包進 `### 批次 001（日期不可考則留空，初始）`，**不改其內文**，再追加本輪批次。
     - 批次內文為使用者本輪變更敘事之**原文逐字收錄**；僅允許排版換行，**禁止**改寫、刪減、摘要或拆解成需求點清單（衍生的變更摘要屬步驟 4 報告，不入 spec.md）。**嚴禁**改寫或覆蓋既有批次內文。
   - 1.3 依 1.2 變更敘事，在 `${TRUTH_BOUNDARY_ROOT}` 下 READ／SEARCH 受本輪變更牽動的 boundary truth（含 `${CONTRACTS_DIR}`、`${DATA_DIR}`、`${TRUTH_BOUNDARY_PACKAGES_DIR}` 下既有 `.feature`／`.activity`），並 READ baseline 對照素材（既有批次、`${IMPACT_MATRIX_YML}` entries、discovery 報告之 charters）。本步**只做讀取與蒐集**，不做任何 entry 判斷分類——entry 推論一律在步驟 3。
   - 1.4 若掃描根下無可對照契約／資料：步驟 4 須明列「未找到」與補洞方式；不得以 repo 外私有路徑充當 truth，亦不得順手新建 contracts／data／shared／dsl／`.feature` 來補洞。

2. ASSERT DIR：`${PLAN_PACKAGES_DIR}/<NNN-plan-slug>/`（caller-context 已鎖定之包）於 filesystem 存在；本步**不**建新 plan package、**不**改寫 `arguments.yml`。本步亦不在 `${TRUTH_BOUNDARY_PACKAGES_DIR}` 下新建 functional module 目錄，除非本輪變更明確要新開 function package（那是步驟 6）。

3. EXECUTE `aibdd-flows-specify/01-amending-and-repackaging/steps/maintain-impact-matrix.md`：先 SNAPSHOT `$ENTRIES_BEFORE`（需求變更**前**的 matrix 全量 entries），再以宣告式維護策略收斂 `${IMPACT_MATRIX_YML}`——依 1.3 蒐集之素材、基於 `${PLAN_SPEC}` 所有批次合併後的淨需求重推本 plan 的完整 `$desired_entries`（每檔 path＋change_type，淘汰 plan 前既存檔者為 `change_type=remove`），`upsert` 全集、`delete` 不在集合內的現存 entry、`validate`——完成後 SNAPSHOT `$ENTRIES_AFTER`（需求變更**後**的 matrix 全量 entries）。兩者相同（本輪無實質增量）時，於步驟 4 明寫並照常收尾，不得硬造變更。`${IMPACT_MATRIX_YML}` 只經該 substep 內 wrapper 子步驟變更。

4. UPDATE `${PLAN_REPORTS_DIR}/discovery-sourcing.md`：在既有報告**追加**本輪變更章節（保留既有章節，不重寫整份；語感對照 `aibdd-flows-specify/assets/templates/discovery-sourcing.example.md`）——`## Change request <批次標識>`（本輪變更一句話，現在式）、變更摘要（本批次新增、修改、移除了哪些需求點）；UPDATE `${PLAN_SPEC}`（維持批次全文，追加指向該章節的 pointer 與可選執行摘要）。本步僅允許 UPDATE 上述兩檔。

5. THINK：在鎖定 `$package_naming_language` 下推導 charter 級影響——`affected_charters`（受本輪變更影響的 function package charters：新增職責或調整邊界）與是否需新開 function package（1..*）；bottom-up 規則見 `aibdd-flows-specify/rules/function-package-granularity.md`。每個受影響的 `$function_package_slug`（`NN-<slug>`）須在報告 `## Function package charters` 有對應小卡可更新或新增。本步只產出判斷，不寫檔。

6. CREATE DIRS ONLY：僅針對步驟 5 判定需**新開**的 function package，於 `${TRUTH_BOUNDARY_PACKAGES_DIR}` 建立其 `${TRUTH_FUNCTION_PACKAGE}`，僅建 `${FEATURE_SPECS_DIR}` 骨架；既有 function package 一律沿用，不重建。禁止建立 `dsl.yml`、`.feature`、`${CONTRACTS_DIR}`／`${DATA_DIR}` 內容或其它規格檔。本輪無新包時本步略過。

7. UPDATE `${PLAN_REPORTS_DIR}/discovery-sourcing.md` 與 `${PLAN_SPEC}`：把步驟 5 之 `affected_charters` 落進報告——更新或新增對應小卡（卡片欄位對齊 `aibdd-flows-specify/assets/templates/discovery-sourcing.template.md` 之 `### <packages/...>`，`本輪變更型態` 標 `impact-only`／`new-package`／`mixed`；句型對齊 `aibdd-flows-specify/assets/templates/discovery-sourcing.example.md` 之 charters 小卡），並維持批次全文與 pointer／摘要。本步僅允許 UPDATE 上述兩檔。

8. 本 sub-SOP 至此完成。**不停步**：立即回上層 `aibdd-flows-specify/SKILL.md` 之 `# SOP`，續跑步驟 3（`02-activity-analyze`）。
