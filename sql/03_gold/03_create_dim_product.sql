-- =====================================================
-- Script:      03_create_dim_product.sql
-- Layer:       Gold (star schema)
-- Purpose:     Product dimension, sourced from distinct SKUs in Silver.
--              Verified: every SKU has exactly one consistent unit_price,
--              so no SCD/history logic needed.
-- Author:      Lesson Mtileni
-- Created:     2026-07-24
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_DWH;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_product'
)
BEGIN
    CREATE TABLE gold.dim_product (
        product_key     INT IDENTITY(1,1) PRIMARY KEY,
        sku             NVARCHAR(50) NOT NULL,
        product_name    NVARCHAR(150),
        category        NVARCHAR(100),
        sub_category    NVARCHAR(100),
        supplier        NVARCHAR(150),
        unit_price      DECIMAL(10,2),
        cost_price      DECIMAL(10,2),
        CONSTRAINT UQ_dim_product_sku UNIQUE (sku)
    );
END
GO