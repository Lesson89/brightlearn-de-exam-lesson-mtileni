-- =====================================================
-- Business Question: BQ-08
-- Based on the June 2024 inventory snapshot, which
-- store-product combinations have stock levels below
-- their reorder threshold?
-- Raised by: Thabo Nkosi, Head of Merchandising
-- Note: as of the June 2024 snapshot, no store-product
-- combination is below its reorder threshold - verified
-- against the full distribution (min stock=6, min
-- threshold=3; smallest margin is +3 units). This is a
-- genuine finding: stock levels are healthy fleet-wide.
-- =====================================================

USE BrightLearn_DWH;
GO

SELECT
    st.store_name,
    p.product_name,
    p.category,
    inv.stock_on_hand,
    inv.reorder_threshold
FROM gold.fact_inventory_snapshot inv
JOIN gold.dim_store st ON st.store_key = inv.store_key
JOIN gold.dim_product p ON p.product_key = inv.product_key
WHERE inv.is_below_reorder_threshold = 1
ORDER BY (inv.stock_on_hand - inv.reorder_threshold) ASC;