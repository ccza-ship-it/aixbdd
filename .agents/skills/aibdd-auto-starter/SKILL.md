---
name: aibdd-auto-starter
description: 從 arguments.yml 與 templates 產生 walking skeleton；以 STARTER_VARIANT 分流 frontend / backend。支援 python-e2e（FastAPI + Behave）、java-e2e（Spring Boot 4 + Cucumber）、nextjs-storybook-cucumber-e2e（Next.js 16 + Storybook 10 + playwright-bdd）。TRIGGER when 使用者說初始化前/後端、建前/後端骨架、frontend/backend starter、walking skeleton，或被 kickoff 後續流程委派。SKIP when 需求是 feature-specific 業務頁面/元件/API client/model/service/API/step definition 實作或既有專案重構。
metadata:
  user-invocable: true
  source: project-level dogfooding
  skill-type: utility
---

# aibdd-auto-starter

Generate a walking skeleton from kickoff arguments and starter templates. The variant set covers both backend (`python-e2e` / `java-e2e`) and frontend (`nextjs-storybook-cucumber-e2e`); dispatch is driven entirely by `STARTER_VARIANT` in `arguments.yml`.

## §1 REFERENCES

| ID | Path | Phase scope | Purpose |
|---|---|---|---|
| R1 | `references/variants/python-e2e.md` | global | 定義 Python E2E backend starter（FastAPI + Behave + Alembic + Testcontainers）的 stack、placeholder、驗證與安全邊界 |
| R2 | `references/variants/java-e2e.md` | global | 定義 Java E2E backend starter（Spring Boot 4 + Cucumber + Flyway + Testcontainers + JdbcClient）的 stack、placeholder、驗證與安全邊界 |
| R3 | `references/variants/nextjs-storybook-cucumber-e2e.md` | global | 定義 Next.js 16 + React 19 + TypeScript 5 + Tailwind 4 + Storybook 10 + Playwright + playwright-bdd + Vitest 4 frontend starter 的 stack、placeholder、驗證與安全邊界 |

## §2 SOP

依序執行 Phase 1–6，不在中途停下徵詢「要不要繼續」；唯一需要與使用者互動的地方是 Phase 3 詢問專案目錄／名稱（且僅在 caller 未提供時）。任一 Phase 標明「停止」即終止整個 skill、不再往下。

### Phase 1 — 取得 caller context 與 arguments.yml

1. 確認本 skill 目錄與當前工作目錄（cwd）。
2. 若 caller 傳入 payload 就讀取它。arguments.yml 的位置：payload 內帶 `arguments_path` → 用它（解析為絕對路徑）；否則預設 `${cwd}/.aibdd/arguments.yml`。
3. 確認 arguments.yml 是否存在。不存在 → 回報「`arguments.yml` 不存在；請先執行 /aibdd-kickoff 並選擇對應的 starter 變體」並停止。

### Phase 2 — 解析 starter 變體

1. 讀取並解析 arguments.yml（YAML）。
2. 取 `STARTER_VARIANT` 決定變體：
   - 為 `python-e2e` / `java-e2e` / `nextjs-storybook-cucumber-e2e` 之一 → 採用。
   - 缺少 `STARTER_VARIANT` → 嘗試由既有鍵推測（出現 `PY_` 前綴 → `python-e2e`；含 `BASE_PACKAGE` 或 `GROUP_ID` 鍵 → `java-e2e`）。仍無法判定 → 回報「`arguments.yml` 缺少 `STARTER_VARIANT`；請填 `STARTER_VARIANT: python-e2e` / `java-e2e` / `nextjs-storybook-cucumber-e2e`，或重新執行 /aibdd-kickoff」並停止。
   - 其他不支援的值 → 回報「目前 starter 支援 `python-e2e` / `java-e2e` / `nextjs-storybook-cucumber-e2e`；其他 variant 尚未實作。請改填其中之一，或重新執行 /aibdd-kickoff。」並停止。
3. 依變體決定 `variant_kind`：`python-e2e` / `java-e2e` → `backend`；`nextjs-storybook-cucumber-e2e` → `frontend`。
4. 讀取對應的 variant 契約 `references/variants/<variant>.md`。
5. 確認 starter templates 目錄 `templates/<variant>` 存在。不存在 → 回報「starter templates 不存在：`<templates 路徑>`」並停止。

### Phase 3 — 收集專案輸入

1. 決定專案目錄 `project_dir`：caller payload 有提供 → 用它（解析為絕對路徑）；否則詢問使用者「專案要建立在哪個目錄？預設為目前工作目錄。」
2. 決定專案名稱 `project_name`：caller payload 有提供 → 用它；否則詢問使用者「專案名稱？用於專案配置檔（pyproject.toml / pom.xml / package.json）與容器／scenario 命名。」
3. 驗證：`project_dir` 必須是絕對路徑、`project_name` 長度大於 0；任一不成立即停止。
4. 確認 arguments.yml 與專案同 repo：`arguments.yml` 路徑（正規化後）須等於 `${project_dir}/${AIBDD_ARGUMENTS_PATH}`。不一致 → 回報「starter 只讀同 repo 內既有 AIBDD project config；請在已 kickoff 的 `<backend|frontend>` root（依 variant_kind）執行，且 arguments.yml 必須位於 `${project_dir}/${AIBDD_ARGUMENTS_PATH}`。若 layout 不對，請重跑 /aibdd-kickoff 並選擇正確的根目錄。」並停止。

### Phase 4 — 產生 skeleton

1. 執行 `uv run ${skill_dir}/scripts/generate-skeleton.py --project-dir "${project_dir}" --project-name "${project_name}" --variant "${variant}" --arguments "${arguments_path}"`。
2. 退出碼非 0 → 回報 generator 失敗摘要並停止。
3. 從輸出解析本次寫入的檔案數。
4. 若輸出含 `SKIP (exists)` → 告知使用者「部分檔案已存在，generator 已依安全規則跳過覆蓋。」

### Phase 5 — 驗證 starter 健康

1. 依 variant 契約取得該 variant 的 dry-run 指令，在 `project_dir` 下執行。
2. 退出碼非 0 → 回報 dry-run 失敗摘要並停止。

### Phase 6 — 回報

1. 整理結果回報給 caller，含：`status: completed`、`variant`、`variant_kind`、`files_written`、`project_dir`、`specs_location`（= `${project_dir}/${SPECS_ROOT_DIR}`）、`dry_run_passed`。
2. 依 variant 契約的「完成後引導」section 取得 post-install／下一步指令提示。
3. 給使用者白話摘要，並提醒：下游 `/aibdd-flows-specify` 必須以 `project_dir` 為工作目錄（`cwd`），使 `AIBDD_ARGUMENTS_PATH` / `BDD_CONSTITUTION_PATH`（bdd-stack 目錄錨點）/ `DEV_CONSTITUTION_PATH` 相對路徑與 `.aibdd/arguments.yml` 同框解析；starter 不產生、不改寫 `specs/`。一併附上對應 variant 的 dependency install / dev-server 指令提示。

## §3 CROSS-REFERENCES

- `/aibdd-kickoff` — 上游產生 `arguments.yml` 與專案邊界設定（含 `STARTER_VARIANT`）
- `/aibdd-flows-specify` — walking skeleton 完成後的下一個規劃系統流程入口
- `/aibdd-auto-frontend-msw-api-layer` — frontend variant 後續以 OpenAPI 生成 MSW handlers + API client（Stage 1）
- `/aibdd-auto-frontend-nextjs-pages` — frontend variant 後續逐 frame 落 Next.js 動態頁面（Stage 2）
