-- =====================================================
-- Script:      02_create_bronze_table.sql
-- Layer:       Bronze (raw landing)
-- Purpose:     Landing table for raw BrightLearn CSV export.
--              All columns NVARCHAR - no transformation applied yet.
-- Author:      Lesson Mtileni
-- Created:     2026-07-23
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_STG;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'bronze' AND t.name = 'sales_raw'
)
BEGIN
    CREATE TABLE bronze.sales_raw (
        bronze_load_id           INT IDENTITY(1,1) PRIMARY KEY,
        bronze_load_date         DATETIME2 DEFAULT SYSDATETIME(),
        source_file_name         NVARCHAR(255),

        transaction_date         NVARCHAR(50),
        payment_method           NVARCHAR(50),
        cashier_name              NVARCHAR(100),
        transaction_amount         NVARCHAR(50),
        transaction_discount        NVARCHAR(50),
        customer_first_name          NVARCHAR(100),
        customer_last_name            NVARCHAR(100),
        customer_email                  NVARCHAR(255),
        customer_phone                    NVARCHAR(50),
        customer_city                      NVARCHAR(100),
        customer_province                   NVARCHAR(100),
        customer_loyalty_tier                NVARCHAR(50),
        customer_since                        NVARCHAR(50),
        store_name                             NVARCHAR(100),
        store_city                              NVARCHAR(100),
        store_province                           NVARCHAR(100),
        store_region                              NVARCHAR(50),
        store_manager                              NVARCHAR(100),
        product_name                                NVARCHAR(150),
        category                                     NVARCHAR(100),
        sub_category                                  NVARCHAR(100),
        sku                                             NVARCHAR(50),
        unit_price                                       NVARCHAR(50),
        cost_price                                        NVARCHAR(50),
        supplier                                           NVARCHAR(150),
        qty                                                 NVARCHAR(50),
        line_amount                                          NVARCHAR(50),
        stock_on_hand                                         NVARCHAR(50),
        reorder_threshold                                      NVARCHAR(50)
    );
END
GO