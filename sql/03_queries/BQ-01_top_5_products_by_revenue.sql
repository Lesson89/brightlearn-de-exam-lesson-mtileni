-- =====================================================
-- Business Question: BQ-01
-- What were the top 5 best-selling products by total 
-- revenue between January and June 2024?
-- Raised by: Thabo Nkosi, Head of Merchandising
-- =====================================================

USE BrightLearn_DWH;
GO

SELECT TOP 5
    p.product_name,
    p.category,
    SUM(f.line_amount) AS total_revenue,
    SUM(f.qty) AS total_units_sold
FROM gold.fact_sales_line_item f
JOIN gold.dim_product p ON p.product_key = f.product_key
JOIN gold.dim_date d ON d.date_key = f.date_key
WHERE d.full_date BETWEEN '2024-01-01' AND '2024-06-30'
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;