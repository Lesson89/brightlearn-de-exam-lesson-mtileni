-- =====================================================
-- Business Question: BQ-05
-- Which registered loyalty customers have not made a 
-- purchase since 28 April 2024? Flag for win-back campaign.
-- Raised by: Priya Govender, Loyalty Programme Manager
-- =====================================================

USE BrightLearn_DWH;
GO

SELECT
    c.first_name,
    c.last_name,
    c.customer_email,
    c.loyalty_tier,
    MAX(d.full_date) AS last_purchase_date,
    DATEDIFF(DAY, MAX(d.full_date), '2024-06-30') AS days_since_last_purchase
FROM gold.fact_sales_line_item f
JOIN gold.dim_customer c ON c.customer_key = f.customer_key
JOIN gold.dim_date d ON d.date_key = f.date_key
WHERE f.is_guest = 0
GROUP BY c.first_name, c.last_name, c.customer_email, c.loyalty_tier
HAVING MAX(d.full_date) < '2024-04-28'
ORDER BY last_purchase_date ASC;