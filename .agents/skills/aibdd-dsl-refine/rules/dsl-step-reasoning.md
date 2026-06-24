# dsl step 推理分析（合理性優先，閘門式）

前提：`.feature`（SBE 產出）**不是 SSOT**，而是「待驗證的候選」。每個尚未定義的業務 step
都先驗證它本身的測試意圖與合理性，**確認正確後才推理 isa_step**。
【硬規則】絕不在不正確的 step 上推理 isa——前置閘門沒過就先變更 step，不得硬展開 isa。

順序固定：測試意圖 → 合理性判定 → 變更判定 →（閘門）→ isa 推理。

## 1. 測試意圖分析

對該 step 讀出：
- 角色與意圖：前置（Given 建立什麼狀態）／動作（When 觸發什麼操作）／斷言（Then 驗什麼結果）。
- 類型：happy / negative / idempotency。
- 與所屬 `Rule:` 的關係：這 step 是在實現該 atomic rule 的哪一面？預期結果與 negative 條件為何。

## 2. 合理性判定

逐條檢核這 step 作為測試規格是否正確、可推 isa；任一不過即「不合理」：

| 判準 | 不合理的徵兆 |
|------|-------------|
| 資料自足 | 空泛到無法判斷該帶什麼 payload（如「其餘欄位皆已填寫」） |
| 與 Rule 一致 | 跑題、超出或不足以驗證所屬 Rule 的條件 |
| 單一意圖 | 一句混多個無關意圖（該拆）；或一個意圖被拆成多句不自足（該併） |
| 斷言有意義 | Then 沒驗到真正結果（API 回應＋資料落地），只是空泛或重複 |
| 資料流可接 | 要引用的別名，前面沒有任何 step 負責建立 |
| 可對應 isa | 語意上對不到任何 isa 操作（內建或合理 custom） |

## 3. 變更判定

- 全部合理 → 通過閘門，進第 4 步。
- 任一不合理 → 此 step **需變更**，變更型態擇一或並用：
  - 重寫句子：讓意圖清楚、資料自足。
  - 重構結構：拆一句為多句、或併多句為一句（依 [feature-restructure.md](feature-restructure.md)）。
  - 修正與 Rule 的對齊。
- 變更一律先經 `/clarify-loop` 向使用者確認後才改 `.feature`；**發問時務必把該 example 的完整 GWT 全文帶進題目**，讓使用者在完整 context 下判斷。確認前不得逕改、更不得在未改的錯 step 上推 isa。

## 4. 閘門 → isa 推理

step 確認正確後，才依下列規則推出有序 isa_steps：
- 型別：[builtin-instruction-decision-tree.md](builtin-instruction-decision-tree.md)
- 符號：[symbol-system-usage.md](symbol-system-usage.md)
- 非內建：[custom-isa-placement.md](custom-isa-placement.md)

## Good

```text
step：Given "Alice" 準備一筆資料齊全的訂單   ← 空泛、不自足（判準 1 不過）
→ 不在此句硬塞 entity_setup；clarify-loop 帶整個 example 全文問使用者
→ 確認後併成自足句「When "Alice" 送出收件地址留空、其餘必填欄位皆已填的訂單」
→ step 正確 → 才推 isa（api_call body 缺收件地址 + response_validate 失敗）
```

## Bad

```text
- 不審查，直接把空泛句硬當 entity_setup 塞一筆假資料就往下推 isa。
- 在「跟所屬 Rule 對不上」的 step 上推一堆 isa_steps（建在錯的前提上）。
- 變更 .feature 時只在聊天問一句、沒帶完整 example，使用者缺 context 難判斷。
```
