-- =====================================================
-- Script:      01_create_dim_date.sql
-- Layer:       Gold (star schema)
-- Purpose:     Date dimension. Generated, not sourced from data.
-- Author:      lesson Mtileni
-- Created:     2026-07-24
-- Notes:       Idempotent - safe to re-run. Uses IF NOT EXISTS, never DROP.
-- =====================================================

USE BrightLearn_DWH;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_date'
)
BEGIN
    CREATE TABLE gold.dim_date (
        date_key      INT PRIMARY KEY,      -- yyyymmdd
        full_date     DATE NOT NULL,
        day_num       TINYINT,
        month_num     TINYINT,
        month_name    NVARCHAR(20),
        quarter_num   TINYINT,
        year_num      SMALLINT
    );
END
GO

-- Populate: only insert dates not already present (idempotent)
;WITH date_range AS (
    SELECT CAST('2024-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM date_range WHERE d < '2024-12-31'
)
INSERT INTO gold.dim_date (date_key, full_date, day_num, month_num, month_name, quarter_num, year_num)
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd')),
    d,
    DAY(d),
    MONTH(d),
    DATENAME(MONTH, d),
    DATEPART(QUARTER, d),
    YEAR(d)
FROM date_range dr
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_date WHERE full_date = dr.d)
OPTION (MAXRECURSION 400);
GO