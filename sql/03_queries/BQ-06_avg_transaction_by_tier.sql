-- =====================================================
-- Business Question: BQ-06
-- What is the average transaction value broken down by
-- customer loyalty tier (Bronze, Silver, Gold)?
-- Raised by: Priya Govender, Loyalty Programme Manager
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
SELECT
    c.loyalty_tier,
    COUNT(DISTINCT t.transaction_id) AS num_transactions,
    AVG(t.transaction_amount) AS avg_transaction_value
FROM transaction_totals t
JOIN gold.dim_customer c ON c.customer_key = t.customer_key
WHERE c.loyalty_tier IS NOT NULL
GROUP BY c.loyalty_tier
ORDER BY avg_transaction_value DESC;