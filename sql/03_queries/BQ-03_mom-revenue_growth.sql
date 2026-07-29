-- =====================================================
-- Business Question: BQ-03
-- What is the month-over-month revenue growth rate 
-- across all stores combined?
-- Raised by: Rofhiwa, CEO
-- =====================================================

USE BrightLearn_DWH;
GO

;WITH transaction_totals AS (
    SELECT DISTINCT
        f.transaction_id,
        d.year_num,
        d.month_num,
        d.month_name,
        f.transaction_amount
    FROM gold.fact_sales_line_item f
    JOIN gold.dim_date d ON d.date_key = f.date_key
    WHERE d.full_date BETWEEN '2024-01-01' AND '2024-06-30'
),
monthly_revenue AS (
    SELECT
        year_num, month_num, month_name,
        SUM(transaction_amount) AS total_revenue
    FROM transaction_totals
    GROUP BY year_num, month_num, month_name
)
SELECT
    year_num,
    month_num,
    month_name,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY year_num, month_num) AS prev_month_revenue,
    CAST(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year_num, month_num))
        * 100.0 / NULLIF(LAG(total_revenue) OVER (ORDER BY year_num, month_num), 0)
    AS DECIMAL(6,2)) AS mom_growth_pct
FROM monthly_revenue
ORDER BY year_num, month_num;