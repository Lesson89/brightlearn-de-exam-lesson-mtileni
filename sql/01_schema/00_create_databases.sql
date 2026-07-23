-- =====================================================
-- Script:      00_create_databases.sql
-- Purpose:     Creates the STG and DWH databases
-- Author:      Lesson Mtileni
-- Created:     2026-07-23
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BrightLearn_STG')
BEGIN
    CREATE DATABASE BrightLearn_STG;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BrightLearn_DWH')
BEGIN
    CREATE DATABASE BrightLearn_DWH;
END
GO