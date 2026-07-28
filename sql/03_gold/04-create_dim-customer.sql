-- =====================================================
-- Script:      04_create_dim_customer.sql
-- Layer:       Gold (star schema)
-- Purpose:     Customer dimension. Registered customers deduped by
--              email (one row per person). Guest customers (no email)
--              get one row PER TRANSACTION - they are never merged,
--              since we cannot confirm two guest transactions belong
--              to the same person.
-- Author:      Lesson Mtileni
-- Created:     2026-07-24
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_DWH;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_customer'
)
BEGIN
    CREATE TABLE gold.dim_customer (
        customer_key        INT IDENTITY(1,1) PRIMARY KEY,
        source_transaction_id INT NULL,          -- only populated for guests; ties row to one specific transaction
        customer_email       NVARCHAR(255) NULL,  -- NULL for guests
        first_name             NVARCHAR(100),
        last_name                NVARCHAR(100),
        phone                      NVARCHAR(50),
        city                        NVARCHAR(100),
        province                     NVARCHAR(100),
        loyalty_tier                   NVARCHAR(50),
        customer_since                   DATE,
        is_guest                           BIT NOT NULL
    );
END
GO