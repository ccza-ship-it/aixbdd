# 依賴盤點範圍判別式與 kind 判定

盤點（SOP step 6）時逐條適用的無序規定。上游依據：dsl-refine-q1-h2 模式軸研究與
dependency-taxonomy（研究 repo），此處為其可執行投影。

## 範圍判別式

1. 範圍內：step 測「業務行為經過依賴」，且依賴可判定為下方 kind 值域之一。
2. 範圍外，一律不入盤點清單（明列於盤點附註即可）：
   - 依賴自身協定語意：訊息順序、exactly-once、重投遞、連線重試、心跳
   - 併發競態、分散式鎖爭用、非功能（延遲、吞吐）
   - SSO redirect 流程面（E2E 層）
   - 第一方純 REST endpoint（歸 aibdd-api-plan）、persistent state（歸 aibdd-data-plan）
   - 快取命中這類白箱觀測（斷言「DB 未被查」）
3. 與 RDB 同構的 NoSQL（有固定 schema、可對映表）不入盤點——走 builtin
   entity_setup／entity_validate 的 source 擴充，歸 data-plan 範疇。

## kind 判定（v1 值域：api／store／channel）

1. api：SUT 以 HTTP 對外呼叫第三方服務（金流、簡訊商、徵信⋯）。
   其 webhook 回打屬同一依賴的 facet，不獨立成依賴；callback endpoint
   本身歸 api-plan。
2. store：SUT 讀寫的 schema-free 外部儲存——Redis、S3／MinIO、Elasticsearch、
   NoSQL document store。判準：測試要對它做資料預存（前置）或資料驗證（斷言）。
3. channel：SUT 消費或發布訊息的 MQ topic／queue——Kafka、RabbitMQ。
   判準：測試要發訊驅動 SUT（inbound）或驗證 SUT 有發送事件（outbound）。
4. 落點速查（承 taxonomy 壓力測試）：SFTP／檔案交換→store；Elasticsearch→store；
   feature flag 遠端服務型→api、本地檔案型→store；HTTP 履約的 Email／SMS 商→api；
   對外 webhook（SUT 打別人）→api 的驗證面。
5. v1 值域外但已知歸屬：websocket、grpc、identity（SSO／IdP）——判定到即收進
   `$ASK_BATCH` 問使用者本輪緩做或升級值域，不得硬塞進 v1 kind。
6. 同一外部服務同時有多個 kind 面向（例：又有 HTTP API 又推 websocket）時，
   每個 kind 面向各立一個 registry entry，name 加 facet 後綴區辨（如 foo-api、foo-feed）。

## 盤點品質規定

1. name 全域唯一、kebab-case、用服務的業務名不用產品名（session-cache 而非 redis）。
2. 每筆盤點必須指得回來源：quotes（需求句）與 feature truth 的具體 step。
3. 既有 entry（`${DEPENDENCIES_DIR}/dependencies.yml` 已登記者）不重建；本批次真相牽動其
   surface／truth 才列為待更新，並沿用原 name。
