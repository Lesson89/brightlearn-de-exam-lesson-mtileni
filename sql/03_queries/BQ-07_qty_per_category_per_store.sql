-- =====================================================
-- Business Question: BQ-07
-- What is the total quantity sold per product category,
-- per store, for the reporting period?
-- Raised by: Thabo Nkosi, Head of Merchandising
-- =====================================================

USE BrightLearn_DWH;
GO

SELECT
    st.store_name,
    p.category,
    SUM(f.qty) AS total_qty_sold
FROM gold.fact_sales_line_item f
JOIN gold.dim_store st ON st.store_key = f.store_key
JOIN gold.dim_product p ON p.product_key = f.product_key
JOIN gold.dim_date d ON d.date_key = f.date_key
WHERE d.full_date BETWEEN '2024-01-01' AND '2024-06-30'
GROUP BY st.store_name, p.category
ORDER BY st.store_name, total_qty_sold DESC;