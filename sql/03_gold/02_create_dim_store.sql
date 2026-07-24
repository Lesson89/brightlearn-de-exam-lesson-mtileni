-- =====================================================
-- Script:      02_create_dim_store.sql
-- Layer:       Gold (star schema)
-- Purpose:     Store dimension, sourced from distinct stores in Silver.
-- Author:      Lesson Mtileni
-- Created:     2026-07-24
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_DWH;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_store'
)
BEGIN
    CREATE TABLE gold.dim_store (
        store_key       INT IDENTITY(1,1) PRIMARY KEY,
        store_name      NVARCHAR(100) NOT NULL,
        store_city      NVARCHAR(100),
        store_province  NVARCHAR(100),
        store_region    NVARCHAR(50),
        store_manager   NVARCHAR(100),
        CONSTRAINT UQ_dim_store_name UNIQUE (store_name)
    );
END
GO