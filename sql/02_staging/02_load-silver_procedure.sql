-- =====================================================
-- Script:      02_load_silver_procedure.sql
-- Layer:       Silver (cleansed)
-- Purpose:     Reads bronze.sales_raw, applies all data quality
--              fixes, and loads silver.sales_cleaned.
-- Author:      Lesson Mtilenis
-- Created:     2026-07-24
-- Notes:       Idempotent - safe to re-run (CREATE OR ALTER).
--              Truncates silver.sales_cleaned before reload -
--              this is safe because Silver is fully reproducible
--              from Bronze at any time (same principle as Bronze
--              reload, not a risk to trusted/final data).
-- =====================================================

USE BrightLearn_STG;
GO

CREATE OR ALTER PROCEDURE silver.usp_load_sales_cleaned  
AS  
BEGIN  
    SET NOCOUNT ON;  

    TRUNCATE TABLE silver.sales_cleaned;  

    ;WITH parsed AS (  
        SELECT  
            b.bronze_load_id,  

            COALESCE(  
                TRY_CONVERT(date, b.transaction_date, 23),
                TRY_CONVERT(date, b.transaction_date, 111),
                TRY_CONVERT(date, b.transaction_date, 103),
                TRY_CONVERT(date, b.transaction_date, 105),
                TRY_CONVERT(date, b.transaction_date, 106)
            ) AS transaction_date,  

            CASE UPPER(LTRIM(RTRIM(b.payment_method)))  
                WHEN 'CASH'         THEN 'Cash'  
                WHEN 'CREDIT CARD'  THEN 'Credit Card'  
                WHEN 'DEBIT CARD'   THEN 'Debit Card'  
                WHEN 'EFT'          THEN 'EFT'  
                WHEN 'STORE CREDIT' THEN 'Store Credit'  
                ELSE LTRIM(RTRIM(b.payment_method))  
            END AS payment_method,  

            b.cashier_name,  
            TRY_CAST(b.transaction_amount AS DECIMAL(12,2))   AS transaction_amount,  
            TRY_CAST(b.transaction_discount AS DECIMAL(12,2)) AS transaction_discount,  

            CASE WHEN TRY_CAST(b.transaction_amount AS DECIMAL(12,2)) < 0  
                 THEN 1 ELSE 0 END AS is_refund,  

            NULLIF(LTRIM(RTRIM(b.customer_first_name)), '') AS customer_first_name,  
            NULLIF(LTRIM(RTRIM(b.customer_last_name)), '')  AS customer_last_name,  
            NULLIF(LTRIM(RTRIM(b.customer_email)), '')      AS customer_email,  
            NULLIF(LTRIM(RTRIM(b.customer_phone)), '')      AS customer_phone,  
            b.customer_city,  
            b.customer_province,  
            b.customer_loyalty_tier,  
            TRY_CONVERT(date, b.customer_since, 23)          AS customer_since,  

            CASE WHEN NULLIF(LTRIM(RTRIM(b.customer_email)), '') IS NULL
                 THEN 1 ELSE 0 END AS is_guest,  

            b.store_name, b.store_city, b.store_province, b.store_region, b.store_manager,  

            b.product_name,  
            ISNULL(NULLIF(LTRIM(RTRIM(b.category)), ''), 'Unknown') AS category,  
            b.sub_category,  
            b.sku,  
            TRY_CAST(b.unit_price AS DECIMAL(10,2))   AS unit_price,  
            TRY_CAST(b.cost_price AS DECIMAL(10,2))   AS cost_price,  
            b.supplier,  
            TRY_CAST(b.qty AS INT)                     AS qty,  
            TRY_CAST(b.line_amount AS DECIMAL(12,2))   AS line_amount,  
            TRY_CAST(b.stock_on_hand AS INT)           AS stock_on_hand,  
            TRY_CAST(b.reorder_threshold AS INT)       AS reorder_threshold,  

            ROW_NUMBER() OVER (  
                PARTITION BY b.transaction_date, b.payment_method, b.cashier_name,  
                             b.transaction_amount, b.customer_email, b.product_name,  
                             b.qty, b.line_amount  
                ORDER BY b.bronze_load_id  
            ) AS dedup_rank  

        FROM bronze.sales_raw b  
    )  
    INSERT INTO silver.sales_cleaned (  
        bronze_load_id, transaction_id, transaction_date, payment_method, cashier_name,  
        transaction_amount, transaction_discount, is_refund,  
        customer_first_name, customer_last_name, customer_email, customer_phone,  
        customer_city, customer_province, customer_loyalty_tier, customer_since, is_guest,  
        store_name, store_city, store_province, store_region, store_manager,  
        product_name, category, sub_category, sku, unit_price, cost_price, supplier,  
        qty, line_amount, stock_on_hand, reorder_threshold  
    )  
    SELECT  
        p.bronze_load_id,  
        DENSE_RANK() OVER (  
            ORDER BY p.transaction_date, p.store_name, p.payment_method,  
                     ISNULL(p.customer_email, 'GUEST'), p.transaction_amount, p.transaction_discount  
        ) AS transaction_id,  
        p.transaction_date, p.payment_method, p.cashier_name,  
        p.transaction_amount, p.transaction_discount, p.is_refund,  
        p.customer_first_name, p.customer_last_name, p.customer_email, p.customer_phone,  
        p.customer_city, p.customer_province, p.customer_loyalty_tier, p.customer_since, p.is_guest,  
        p.store_name, p.store_city, p.store_province, p.store_region, p.store_manager,  
        p.product_name, p.category, p.sub_category, p.sku, p.unit_price, p.cost_price, p.supplier,  
        p.qty, p.line_amount, p.stock_on_hand, p.reorder_threshold  
    FROM parsed p  
    WHERE p.dedup_rank = 1;  

END;
GO