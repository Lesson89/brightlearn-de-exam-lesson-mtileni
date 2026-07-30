-- =====================================================
-- Script:      08_load_gold_procedure.sql
-- Layer:       Gold (orchestration)
-- Purpose:     Loads all dimensions and facts from Silver.
--              Safe to re-run: clears facts first (child),
--              then dimensions (parent), then reloads both
--              in dependency order.
-- Author:      Lesson Mtileni
-- Created:     2026-07-29
-- Notes:       DELETE is used (not TRUNCATE) for every dimension
--              table, because SQL Server blocks TRUNCATE on any
--              table with an active FK reference regardless of
--              whether the referencing rows currently exist.
-- =====================================================

USE BrightLearn_DWH;
GO

CREATE OR ALTER PROCEDURE gold.usp_load_gold
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear facts first - they hold the FKs pointing at dimensions
    TRUNCATE TABLE gold.fact_sales_line_item;
    TRUNCATE TABLE gold.fact_inventory_snapshot;

    -- Dimensions must use DELETE, not TRUNCATE - SQL Server blocks TRUNCATE
    -- based on the mere existence of an FK constraint, not row-level conflicts
    DELETE FROM gold.dim_customer;
    DELETE FROM gold.dim_store;
    DELETE FROM gold.dim_product;
    DELETE FROM gold.dim_cashier;
    -- dim_date is static/generated, never reloaded from Silver - left untouched

    -- ---- Reload dim_store ----
    INSERT INTO gold.dim_store (store_name, store_city, store_province, store_region, store_manager)
    SELECT DISTINCT store_name, store_city, store_province, store_region, store_manager
    FROM BrightLearn_STG.silver.sales_cleaned
    WHERE store_name IS NOT NULL;

    -- ---- Reload dim_product (category-conflict-resolved) ----
    ;WITH ranked_products AS (
        SELECT sku, product_name, category, sub_category, supplier, unit_price, cost_price,
            ROW_NUMBER() OVER (
                PARTITION BY sku
                ORDER BY CASE WHEN category = 'Unknown' THEN 1 ELSE 0 END, category
            ) AS rn
        FROM BrightLearn_STG.silver.sales_cleaned
        WHERE sku IS NOT NULL
    )
    INSERT INTO gold.dim_product (sku, product_name, category, sub_category, supplier, unit_price, cost_price)
    SELECT sku, product_name, category, sub_category, supplier, unit_price, cost_price
    FROM ranked_products WHERE rn = 1;

    -- ---- Reload dim_cashier ----
    INSERT INTO gold.dim_cashier (cashier_name)
    SELECT DISTINCT cashier_name
    FROM BrightLearn_STG.silver.sales_cleaned
    WHERE cashier_name IS NOT NULL;

    -- ---- Reload dim_customer: registered first, then guests ----
    INSERT INTO gold.dim_customer (customer_email, first_name, last_name, phone, city, province, loyalty_tier, customer_since, is_guest)
    SELECT customer_email, MAX(customer_first_name), MAX(customer_last_name), MAX(customer_phone),
           MAX(customer_city), MAX(customer_province), MAX(customer_loyalty_tier), MAX(customer_since), 0
    FROM BrightLearn_STG.silver.sales_cleaned
    WHERE is_guest = 0 AND customer_email IS NOT NULL
    GROUP BY customer_email;

    INSERT INTO gold.dim_customer (source_transaction_id, customer_email, first_name, last_name, is_guest)
    SELECT DISTINCT transaction_id, NULL, 'Guest', 'Customer', 1
    FROM BrightLearn_STG.silver.sales_cleaned
    WHERE is_guest = 1;

    -- ---- Reload fact_sales_line_item ----
    INSERT INTO gold.fact_sales_line_item (
        transaction_id, date_key, store_key, customer_key, product_key, cashier_key,
        payment_method, unit_price, cost_price, qty, line_amount,
        transaction_amount, transaction_discount, is_refund, is_guest
    )
    SELECT
        s.transaction_id, CONVERT(INT, FORMAT(s.transaction_date, 'yyyyMMdd')),
        st.store_key, c.customer_key, p.product_key, ca.cashier_key,
        s.payment_method, s.unit_price, s.cost_price, s.qty, s.line_amount,
        s.transaction_amount, s.transaction_discount, s.is_refund, s.is_guest
    FROM BrightLearn_STG.silver.sales_cleaned s
    JOIN gold.dim_store st ON st.store_name = s.store_name
    JOIN gold.dim_product p ON p.sku = s.sku
    JOIN gold.dim_cashier ca ON ca.cashier_name = s.cashier_name
    JOIN gold.dim_customer c
        ON (s.is_guest = 0 AND c.customer_email = s.customer_email)
        OR (s.is_guest = 1 AND c.source_transaction_id = s.transaction_id AND c.is_guest = 1);

    -- ---- Reload fact_inventory_snapshot ----
    INSERT INTO gold.fact_inventory_snapshot (snapshot_date, store_key, product_key, stock_on_hand, reorder_threshold)
    SELECT DISTINCT '2024-06-30', st.store_key, p.product_key, s.stock_on_hand, s.reorder_threshold
    FROM BrightLearn_STG.silver.sales_cleaned s
    JOIN gold.dim_store st ON st.store_name = s.store_name
    JOIN gold.dim_product p ON p.sku = s.sku
    WHERE s.stock_on_hand IS NOT NULL;

END;
GO