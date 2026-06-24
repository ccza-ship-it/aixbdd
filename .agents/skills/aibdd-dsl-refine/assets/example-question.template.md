# 提問模版：dsl step refine（逐 example）

每次就「單一個 example」向使用者提問時，用本模版組裝 `/clarify-loop` payload。
鐵則：**Context 區一定帶該 example 的完整 GWT 全文（一行不漏）**，讓使用者在完整脈絡下思考再回答。
一次只問這一個 example，不混入其他 example。

---

## Context — 完整 Example（必帶）

```gherkin
Feature: {{FEATURE_NAME}}
  {{RULE_LINE}}
    Example: {{EXAMPLE_TITLE}}
{{EXAMPLE_GWT_FULLTEXT}}
```

## 本輪分析（精簡）

- 正在處理的 step：`{{CURRENT_STEP}}`
- 測試意圖：{{INTENT}}
- 合理性：{{VERDICT}}    <!-- 合理 ｜ 不合理：指出未過的判準（見 rules/dsl-step-reasoning.md） -->

## 問題（依情境擇一）

### 情境 A — step 需變更（合理性未過，改 `.feature` 前確認）
- 建議變更（{{CHANGE_KIND}}：重寫句子 / 重構結構 / 對齊 Rule）：
  ```gherkin
  {{PROPOSED_STEP}}
  ```
- 問：是否同意此變更？（只動步驟結構/句子，不改驗收意圖）
- reply token：`A: 同意 | 不同意：<說明>`

### 情境 B — step 正確、已產出 dsl_step（7.5 收尾確認）
- 已寫入的 dsl_step（精簡片段，不貼整段 .isa.feature）：
  ```yaml
  {{DSL_SNIPPET}}
  ```
- 問：確認無誤？要調整？還是繼續下一個 example？
- reply token：`B: 確認 | 調整：<說明> | 下一個`

### 情境 C — 卡住澄清（DISCUSS）
- 卡點：{{BLOCKER}}
- 問：{{CLARIFY_QUESTION}}
- reply token：`C: <回答>`
