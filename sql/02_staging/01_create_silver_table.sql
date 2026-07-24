-- =====================================================
-- Script:      01_create_silver_table.sql
-- Layer:       Silver (cleansed)
-- Purpose:     Cleansed, typed version of bronze.sales_raw.
--              Grain: one row per sales line item (same as Bronze).
-- Author:      Lesson Mtileni
-- Created:     2026-07-24
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_STG;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'silver' AND t.name = 'sales_cleaned'
)
BEGIN
    CREATE TABLE silver.sales_cleaned (
        silver_load_id          INT IDENTITY(1,1) PRIMARY KEY,
        silver_load_date        DATETIME2 DEFAULT SYSDATETIME(),
        bronze_load_id           INT,                       -- traceability back to raw row
        transaction_id            INT,                       -- reconstructed transaction grouping

        transaction_date            DATE,
        payment_method                NVARCHAR(50),
        cashier_name                   NVARCHAR(100),
        transaction_amount               DECIMAL(12,2),
        transaction_discount               DECIMAL(12,2),
        is_refund                            BIT,

        customer_first_name                   NVARCHAR(100),
        customer_last_name                      NVARCHAR(100),
        customer_email                            NVARCHAR(255),
        customer_phone                              NVARCHAR(50),
        customer_city                                 NVARCHAR(100),
        customer_province                               NVARCHAR(100),
        customer_loyalty_tier                             NVARCHAR(50),
        customer_since                                       DATE,
        is_guest                                               BIT,

        store_name                                              NVARCHAR(100),
        store_city                                                NVARCHAR(100),
        store_province                                              NVARCHAR(100),
        store_region                                                  NVARCHAR(50),
        store_manager                                                   NVARCHAR(100),

        product_name                                                      NVARCHAR(150),
        category                                                            NVARCHAR(100),
        sub_category                                                          NVARCHAR(100),
        sku                                                                     NVARCHAR(50),
        unit_price                                                                DECIMAL(10,2),
        cost_price                                                                  DECIMAL(10,2),
        supplier                                                                      NVARCHAR(150),
        qty                                                                             INT,
        line_amount                                                                       DECIMAL(12,2),

        stock_on_hand                                                                       INT,
        reorder_threshold                                                                     INT
    );
END
GO

