-- =====================================================
-- Script:      05_create_dim_cashier.sql
-- Layer:       Gold (star schema)
-- Purpose:     Cashier dimension, sourced from distinct cashier
--              names in Silver. Not required by BQ-01 to BQ-08,
--              but included for a more complete, realistic model.
-- Author:      Lesson Mtileni
-- Created:     2026-07-28
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_DWH;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_cashier'
)
BEGIN
    CREATE TABLE gold.dim_cashier (
        cashier_key     INT IDENTITY(1,1) PRIMARY KEY,
        cashier_name    NVARCHAR(100) NOT NULL,
        CONSTRAINT UQ_dim_cashier_name UNIQUE (cashier_name)
    );
END
GO