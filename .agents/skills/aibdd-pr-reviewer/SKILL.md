---
name: aibdd-pr-reviewer
description: 依 `.agents/skills/aibdd-core/references/ssot/skill-writing-criteria/` 底下每一條規則審查 AIBDD skill PR 變更。當需要對 AIBDD skill-writing criteria 做 PR review、產出合併後的 `.reports/report.md`、收集使用者 feedback，並在使用者 confirm 後轉成 quote-and-comment comments plan 時使用。
---

# 目的

依 skill-writing criteria SSOT 審查 PR 或本地 change set 對 AIBDD skill artifact 的修改。
此 skill 不修正被審查檔案；它只產出給使用者看的 review report，依使用者 feedback 反覆收斂，並在使用者說 `confirm` 後，把 comments plan 寫入 `.reports/report.md`。

# 規則

## 輸入

1. Criteria root: `.agents/skills/aibdd-core/references/ssot/skill-writing-criteria/`。
2. Review target: 目前 PR diff、staged diff、unstaged diff，或使用者指定的 change set。
3. Report path: project root 底下的 `.reports/report.md`。
4. Ignore file path: `.reports/.gitignore`。

## Report 目錄

1. 確保 project root 底下存在 `.reports/`。
2. 確保 `.reports/.gitignore` 存在，且內容必須完全如下：

```gitignore
**
```

3. 不要提交 `.reports/` 內的任何內容。

## 規則分派審查

1. 讀取 criteria root 底下的 `README.md`，理解此目錄的用途。
2. 列舉 criteria root 底下每一個 rule file，但排除 `README.md`。
3. 針對每個 rule file，spawn 一個獨立 subagent。
4. 每個 subagent 只取得以下資訊：
 1. 它負責的 rule file。
 2. 要審查的 change set。
 3. 只回報自己負責規則之 findings 的指令。
5. 要求每個 subagent 回報：
 1. Rule file path。
 2. Rule identifier 或 rule number。
 3. Finding severity。
 4. Changed file path。
 5. Changed line 或 line range。
 6. 可取得時，引用 changed text。
 7. 說明此變更為什麼違反該 subagent 負責的規則。
 8. 建議的 PR review comment 文字。
6. 如果 subagent 沒有發現問題，要求它針對該規則回報 `NO_FINDINGS`。

## 合併報告

1. 將所有 subagent report 合併到 `.reports/report.md`。
2. Findings 先依 rule file 分組，再依 changed file path 分組。
3. 保留 `NO_FINDINGS` 規則的精簡摘要，讓使用者看得出哪些 criteria 通過。
4. 不要捏造 line number；如果無法取得 line number，寫 `line unavailable` 並說明原因。
5. Report 要以使用者可讀為主，並保持足夠精簡，方便 review discussion。

## Feedback 迴圈

1. 將合併後的 report 呈現給使用者。
2. 詢問 feedback 並等待使用者回覆。
3. 如果使用者要求調整，更新 `.reports/report.md`，讓報告反映雙方同意的解讀。
4. 重複此流程，直到使用者明確說 `confirm`。
5. 在使用者說 `confirm` 之前，不要建立 comments plan。

## 已確認的 Comments Plan

使用者說 `confirm` 後，在 `.reports/report.md` 內 append 或 rewrite `Comments Plan` section。
每一則 planned comment 必須使用「引用 + 評論」格式。

```markdown
## Comments Plan

1. 引用:
   > `path/to/file.md:12-16`
   > 被引用的 changed text。

   評論:
   這違反 `01-no-markdown-decoration-rule.md` rule 2.1：被修改的 SKILL.md 引入粗體 Markdown decoration。請移除 decoration，改用標題層級或更精準的文字表達強調語意。
```

每一則評論都必須符合以下條件：

1. 引用必須包含 file path 與 line number 或 line range。
2. 可取得時，引用必須包含相關 changed text。
3. 評論必須指名被違反的 criteria file。
4. 評論必須指出該 criteria file 內的具體 rule number 或 stable rule label。
5. 評論必須用具體語句說明違規原因。
6. 評論必須能直接作為 PR review comment 使用。