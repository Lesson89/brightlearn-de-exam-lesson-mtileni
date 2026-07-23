-- =====================================================
-- Script:      01_create_schemas.sql
-- Purpose:     Creates medallion schemas (bronze/silver in STG, gold in DWH)
-- Author:      Lesson Mtileni
-- Created:     2026-07-23
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

-- Run against BrightLearn_STG
USE BrightLearn_STG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO

-- Run against BrightLearn_DWH
USE BrightLearn_DWH;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO