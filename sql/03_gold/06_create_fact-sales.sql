-- =====================================================
-- Script:      06_create_fact_sales.sql
-- Layer:       Gold (star schema)
-- Purpose:     Fact table. Grain: one row per sales line item.
--              Foreign keys to all 5 dimensions, plus measures.
-- Author:      Lesson Mtileni
-- Created:     2026-07-28
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_DWH;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'fact_sales_line_item'
)
BEGIN
    CREATE TABLE gold.fact_sales_line_item (
        line_item_key          INT IDENTITY(1,1) PRIMARY KEY,
        transaction_id         INT NOT NULL,

        date_key               INT NOT NULL REFERENCES gold.dim_date(date_key),
        store_key              INT NOT NULL REFERENCES gold.dim_store(store_key),
        customer_key           INT NOT NULL REFERENCES gold.dim_customer(customer_key),
        product_key            INT NOT NULL REFERENCES gold.dim_product(product_key),
        cashier_key            INT NOT NULL REFERENCES gold.dim_cashier(cashier_key),

        payment_method         NVARCHAR(50),

        unit_price             DECIMAL(10,2),
        cost_price             DECIMAL(10,2),
        qty                    INT,
        line_amount            DECIMAL(12,2),
        transaction_amount     DECIMAL(12,2),
        transaction_discount   DECIMAL(12,2),
        is_refund              BIT,
        is_guest               BIT
    );
END
GO