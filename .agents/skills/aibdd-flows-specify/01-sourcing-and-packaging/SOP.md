# SOP

0. **RESOLVE arguments**——將本 SOP 引用的 `${VAR}` 透過 sibling resolver 綁定，並把 resolver stdout（每行一筆 `KEY=value`）原樣 EMIT 給用戶。Resolver 非 0 退出時，停止本 SOP 並把 stderr 透傳給用戶。

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

0.2 DERIVE `$package_naming_language`：

- SOURCE：`$package_naming_language` = ${PROJECT_SPEC_LANGUAGE}（zh-hant / zh-hans / en-us / ja-jp / ko-kr 等 BCP-47 值；同 `${FILENAME_AXES_TITLE_LANGUAGE_REF}` 所指 i18n reference）。
- 後續所有 `$plan_package_slug`（`NNN-<slug>`）與 `$function_package_slug`（`NN-<slug>`）之 `<slug>` 主體**必須以該語系自然書寫**。
- 技術名詞（API field、DSL token、operationId、domain acronym 如 CRM／SOP／API／OAuth）**可保留英文原文**；其餘 slug body 不得整段翻成英文。
- **【嚴禁】以 romanization（漢語拼音／注音／粵拼）、kana、romaji 等 transliteration 充當「為避該語系字元」的 fallback**。落到 filesystem 的 slug 必須讀得懂、可直接還原為該語系文字。
- IF `$package_naming_language` == `zh-hant`：
  - ✅ Good：`001-會員登入記錄登入時間`、`001-CRM學員旅程階段SOP`、`packages/01-會員登入`
  - ❌ Bad（romanization）：`001-yi-a2b-mo-wang-fang`、`001-hui-yuan-deng-ru`
  - ❌ Bad（整段英譯，無此需求）：`001-member-login-last-login-at`
- IF `$package_naming_language` == `zh-hans`：規則同 zh-hant，但用簡體字形。
- IF `$package_naming_language` == `en-us`：slug 以英文撰寫，使用 kebab-case。
  - ✅ Good：`001-member-login-last-login-at`、`packages/01-member-login`
- IF `$package_naming_language` == `ja-jp`：以日文書寫，禁止以 romaji 取代漢字／假名。
- IF `$package_naming_language` == `ko-kr`：以韓文（Hangul）書寫，禁止以 romaja 取代。
- **禁止無理由中英檔名混拼**（半中半英的 slug，如 `001-會員-login`，除非含上述技術 token 例外）。
- 若 `${PROJECT_SPEC_LANGUAGE}` 缺失或無法判斷，**不得**自行 fallback 為英文或 romanization，須 DELEGATE `/clarify-loop` 詢問用戶。

1. ANCHOR + SEARCH（本步僅 READ／SEARCH／WRITE `${PLAN_SPEC}`；`${TRUTH_BOUNDARY_ROOT}` 下 truth 不寫入；`arguments.yml` 不寫入）
   - 1.1 若當前 plan slug 尚未由 caller-context 提供：DERIVE `$plan_package_slug`（`NNN-<slug>`）→ CREATE `${PLAN_PACKAGES_DIR}/$plan_package_slug/` 於 filesystem → 將 `$plan_package_slug` 作為 return value 回傳上層 orchestrator，後續解析 `${CURRENT_PLAN_PACKAGE}` 借位時以此 slug override → 回到 1.2。`arguments.yml` 中 `CURRENT_PLAN_PACKAGE` 永遠保持 `<<NNN-plan-slug>>` 借位形態，本步**不**改寫 yaml。
   - 1.2 將使用者本輪需求敘事**原文逐字**寫入 `${PLAN_SPEC}`，格式依 `aibdd-flows-specify/assets/templates/spec.template.md`（`## 需求描述` 下以 `### 批次 001（YYYY-MM-DD，初始）` 起始）；僅允許排版換行，**禁止**改寫、刪減、摘要或重組措辭——此原文是下游 atomic rule 與 Action 萃取「指回需求原文」的溯源錨點。
   - 1.3 依 1.2 敘事在 `${TRUTH_BOUNDARY_ROOT}` 下 READ／SEARCH boundary truth（含 `${CONTRACTS_DIR}`、`${DATA_DIR}`、`${TRUTH_BOUNDARY_PACKAGES_DIR}` 等）。本步**只做讀取與蒐集**，不做任何 entry 判斷分類——含「本輪需求是否明文淘汰既存規格檔」在內的分類與 entry 推論一律在步驟 3；淘汰事實由步驟 4 記入報告。
   - 1.4 若掃描根下無可對照契約／資料：步驟 4 須明列「未找到」與補洞方式；不得以 repo 外私有路徑充當 truth，亦不得順手新建 contracts／data／shared／dsl／`.feature` 來補洞。

2. CREATE DIR：若 1.1 已建立則 ASSERT `${PLAN_PACKAGES_DIR}/$plan_package_slug/` 存在並略過；否則在鎖定 `$package_naming_language` 後 DERIVE `$plan_package_slug`、CREATE `${PLAN_PACKAGES_DIR}/$plan_package_slug/` 於 filesystem，並將 `$plan_package_slug` 作為 return value 回傳上層 orchestrator。**不**改寫 `arguments.yml`（`CURRENT_PLAN_PACKAGE` 保持借位形態）。本步不在 `${TRUTH_BOUNDARY_PACKAGES_DIR}` 下新建 functional module 目錄，除非本輪明確要新開 function package。

3. EXECUTE `aibdd-flows-specify/01-sourcing-and-packaging/steps/maintain-impact-matrix.md`，收斂本輪 impact scope 至 `${IMPACT_MATRIX_YML}`。`${IMPACT_MATRIX_YML}` 只經該 substep 內 wrapper 子步驟變更。

4. WRITE `${PLAN_REPORTS_DIR}/discovery-sourcing.md`（章節以 `aibdd-flows-specify/assets/templates/discovery-sourcing.template.md` 為準；語感對照 `aibdd-flows-specify/assets/templates/discovery-sourcing.example.md`）；UPDATE `${PLAN_SPEC}`（保留 1.2 需求全文，追加指向該報告的 pointer 與可選執行摘要）。本步僅允許 WRITE `${PLAN_REPORTS_DIR}/discovery-sourcing.md` 與 UPDATE `${PLAN_SPEC}`。

5. THINK：在鎖定 `$package_naming_language` 下拆解 function package 數量（1..*）；bottom-up 規則見 `aibdd-flows-specify/rules/function-package-granularity.md`。每個 `$function_package_slug`（`NN-<slug>`）須在報告 `## Function package charters` 有職責一句、納入、排除、本 plan 變更型態。本步只產出判斷，不寫檔。

6. CREATE DIRS ONLY：於 `${TRUTH_BOUNDARY_PACKAGES_DIR}` 建立或沿用各 `${TRUTH_FUNCTION_PACKAGE}`，僅建 `${FEATURE_SPECS_DIR}` 骨架。禁止建立 `dsl.yml`、`.feature`、`${CONTRACTS_DIR}`／`${DATA_DIR}` 內容或其它規格檔。目錄示意見 example 內 Spec structure。

7. UPDATE `${PLAN_REPORTS_DIR}/discovery-sourcing.md` 與 `${PLAN_SPEC}`（維持 1.2 需求全文與 pointer／摘要；句型對齊 example）。本步僅允許 UPDATE 上述兩檔。

8. 本 sub-SOP 至此完成。**不停步**：立即回上層 `aibdd-flows-specify/SKILL.md` 之 `# SOP`，續跑步驟 3（`02-activity-analyze`）。
