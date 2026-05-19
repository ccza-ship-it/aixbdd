# Specs 根目錄佈局

邏輯 boundary（`boundary_id`）見 `${BOUNDARY_YML}` 與 `${TRUTH_BOUNDARY_ROOT}/boundary-map.yml`，為語意 tag，不對應 filesystem 子目錄。boundary truth 與 function package 同在 `${SPECS_ROOT_DIR}` 根下；plan package 集中在 `${PLAN_PACKAGES_DIR}`。

## 目錄樹（normative）

```text
${SPECS_ROOT_DIR}/
  architecture/
    boundary.yml
    component-diagram.class.mmd
  boundary-map.yml
  test-strategy.yml
  contracts/
  data/
  shared/
    dsl.yml
  packages/
    NN-<slug>/
      features/
  plans/
    NNN-<slug>/
      spec.md
      reports/
        discovery-sourcing.md
```

## arguments 綁定對照

| 鍵 | 應展開為 |
|---|---|
| `PLAN_PACKAGES_DIR` | `${SPECS_ROOT_DIR}/plans` |
| `CURRENT_PLAN_PACKAGE` | `${PLAN_PACKAGES_DIR}/NNN-<slug>` |
| `TRUTH_BOUNDARY_ROOT` | `${SPECS_ROOT_DIR}` |
| `TRUTH_BOUNDARY_PACKAGES_DIR` | `${SPECS_ROOT_DIR}/packages` |
| `CONTRACTS_DIR` | `${SPECS_ROOT_DIR}/contracts` |
| `DATA_DIR` | `${SPECS_ROOT_DIR}/data` |
| `TRUTH_BOUNDARY_SHARED_DIR` | `${SPECS_ROOT_DIR}/shared` |
| `BOUNDARY_SHARED_DSL` | `${TRUTH_BOUNDARY_SHARED_DIR}/dsl.yml` |
| `TEST_STRATEGY_FILE` | `${SPECS_ROOT_DIR}/test-strategy.yml` |
| boundary-map | `${TRUTH_BOUNDARY_ROOT}/boundary-map.yml` |

`Impact matrix` 第一欄路徑一律相對**展開後的** `${TRUTH_BOUNDARY_ROOT}`（即 `specs/` 根）。
