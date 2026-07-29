-- =====================================================
-- Business Question: BQ-04
-- Who are the top 10 loyalty customers ranked by total 
-- spend over the reporting period?
-- Raised by: Priya Govender, Loyalty Programme Manager
-- Note: Guests are excluded - they are not enrolled in
-- the loyalty programme by definition.
-- =====================================================

USE BrightLearn_DWH;
GO

;WITH transaction_totals AS (
    SELECT DISTINCT
        f.transaction_id,
        f.customer_key,
        f.transaction_amount
    FROM gold.fact_sales_line_item f
    WHERE f.is_guest = 0
)
SELECT TOP 10
    c.first_name,
    c.last_name,
    c.customer_email,
    c.loyalty_tier,
    SUM(t.transaction_amount) AS total_spend,
    COUNT(DISTINCT t.transaction_id) AS num_transactions
FROM transaction_totals t
JOIN gold.dim_customer c ON c.customer_key = t.customer_key
GROUP BY c.first_name, c.last_name, c.customer_email, c.loyalty_tier
ORDER BY total_spend DESC;