-- =====================================================
-- Business Question: BQ-02
-- What was the total revenue per store, broken down by 
-- month, for the January-June 2024 period?
-- Raised by: Johan van der Merwe, Regional Manager
-- =====================================================

USE BrightLearn_DWH;
GO

;WITH transaction_totals AS (
    -- Collapse to one row per transaction (not per line item) to avoid
    -- double-counting transaction_amount across multiple products in a basket
    SELECT DISTINCT
        f.transaction_id,
        f.store_key,
        d.year_num,
        d.month_num,
        d.month_name,
        f.transaction_amount
    FROM gold.fact_sales_line_item f
    JOIN gold.dim_date d ON d.date_key = f.date_key
    WHERE d.full_date BETWEEN '2024-01-01' AND '2024-06-30'
)
SELECT
    st.store_name,
    t.year_num,
    t.month_num,
    t.month_name,
    SUM(t.transaction_amount) AS total_revenue
FROM transaction_totals t
JOIN gold.dim_store st ON st.store_key = t.store_key
GROUP BY st.store_name, t.year_num, t.month_num, t.month_name
ORDER BY st.store_name, t.year_num, t.month_num;