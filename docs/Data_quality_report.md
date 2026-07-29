# BrightLearn Data Quality Findings Report
**Project:** BL-DE-EXAM-2026-07  
**Author:** Lesson Mtileni  
**Date:** July 2026  

## Purpose
This report documents every data quality issue identified in `BrightLearn_Raw_Data.csv` during the Bronze → Silver → Gold ETL pipeline build, the number of records affected, and the decision made to resolve each issue.

---

## 1. Inconsistent Date Formats
* **Issue:** `transaction_date` contained at least 5 different formats mixed throughout the file (e.g., `2024-06-12`, `17/05/2024`, `13-04-2024`, `02 Feb 2024`).
* **Affected:** Spread across all 5,000 rows (exact format varied per row).
* **Decision:** In the Silver layer, applied `TRY_CONVERT` against each known format in sequence (`COALESCE`), converting all values to a single standardized `DATE` type.

---

## 2. No Transaction Identifier (Grain Reconstruction)
* **Issue:** The source has no natural transaction ID. Multiple product line items belonging to the same basket share the same `transaction_amount`, discount, customer, date, and store — discovered by verifying `transaction_amount = SUM(line_amount) - discount` for grouped rows.
* **Affected:** All 5,000 rows (structural, not a count of bad records).
* **Decision:** Reconstructed a surrogate `transaction_id` in Silver using `DENSE_RANK()` over the composite business key (date, store, payment method, customer, amount, discount).

---

## 3. Exact Duplicate Rows
* **Issue:** 44 fully duplicated rows (identical across all columns).
* **Affected:** 44 of 5,000 rows.
* **Decision:** Deduplicated in Silver using `ROW_NUMBER()` partitioned on the full business key, keeping the first-loaded occurrence (`ORDER BY bronze_load_id`) and discarding the rest.

---

## 4. Inconsistent Payment Method Casing
* **Issue:** `payment_method` values appeared in mixed casing (e.g., `Cash` vs `CASH`, `Credit Card` vs `CREDIT CARD`).
* **Affected:** 66 non-standard rows.
* **Decision:** Normalized to a fixed set of 5 values (Cash, Credit Card, Debit Card, EFT, Store Credit) via a `CASE` expression on the uppercased, trimmed value.

---

## 5. Missing Customer Identity (Guest Transactions)
* **Issue:** Some rows have no customer email at all — meaning the customer cannot be reliably identified or deduplicated (a name alone is not a safe unique key: two different customers can share a name, and misspellings can split one real customer into two records).
* **Affected:** 811 rows missing `customer_email` (of which 253 were missing all customer fields entirely).
* **Decision:** Any row with no email is flagged `is_guest = 1` in Silver. Guest customers are modeled in `dim_customer` as one row per transaction (never merged across transactions), since identity cannot be confirmed without an email.

---

## 6. Negative Transaction Amounts (Refunds)
* **Issue:** 435 rows have a negative `transaction_amount`, consistent with refunds.
* **Affected:** 435 of 5,000 rows.
* **Decision:** Kept as-is (not converted to positive) and flagged with `is_refund = 1`, to preserve accurate net revenue totals for reporting (BQ-02, BQ-03).

---

## 7. Missing Product Category
* **Issue:** 132 rows had a blank `category` value.
* **Affected:** 132 of 5,000 rows.
* **Decision:** Initially filled with `'Unknown'` at the row level in Silver. This surfaced a second issue (#8 below) which was resolved at the Gold layer.

---

## 8. Category Inconsistency at the Product Level
* **Issue:** Because issue #7 was resolved per-row rather than per-product, 24 of 44 products ended up with two different category values (`'Unknown'` on some rows, the true category on others) — even though category is really a product-level attribute, not a per-transaction one.
* **Affected:** 24 of 44 products in `dim_product`.
* **Decision:** In Gold, `dim_product` population uses `ROW_NUMBER()` to prioritize any non-`'Unknown'` category per SKU, falling back to `'Unknown'` only if truly absent everywhere.

---

## 9. Non-Numeric / Blank Values in Numeric Fields
* **Issue:** Bronze lands all columns as text by design; numeric fields (`unit_price`, `qty`, `transaction_amount`, etc.) required safe casting.
* **Affected:** All numeric columns, all rows (structural handling, not a defect count).
* **Decision:** Used `TRY_CAST`/`TRY_CONVERT` throughout Silver rather than `CAST`, so any unexpected value converts to `NULL` instead of failing the entire load.

---

## 10. Ambiguous Inventory Snapshot
* **Issue:** `stock_on_hand` and `reorder_threshold` are repeated identically on every transaction row for a given store+product, rather than appearing once — confirmed via `COUNT(DISTINCT ...)` per store+SKU returning 1 for all combinations.
* **Affected:** All 5,000 rows (structural).
* **Decision:** Deduplicated to one row per store+product in a dedicated `fact_inventory_snapshot` table, separate from the transactional sales fact.