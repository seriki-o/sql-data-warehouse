/*
============================================================
Script: Gold Layer Data Quality Checks

Script Purpose:
    Validates the quality and integrity of Gold Layer data
    by checking for duplicate records, standardized values,
    and foreign key integrity.

Checks Performed:
    1. Customer duplication caused by joins.
    2. Customer gender standardization.
    3. Product duplication caused by joins.
    4. Foreign key integrity between the sales fact and
       customer and product dimensions.

Usage:
    Run after creating or updating the Gold Layer views.
    Review each result set and investigate unexpected rows.

Expectations:
    - Duplicate checks should return no rows.
    - Gender values should follow the expected standard.
    - Foreign key checks should return no unmatched records.

============================================================
*/

USE DataWarehouse;
GO


-- ==========================================================
-- 1. Customer Dimension: Check for Duplicates from Joins
-- ==========================================================

-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM (
    SELECT
        ci.cst_id
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS la
        ON ci.cst_key = la.cid
) AS t
GROUP BY cst_id
HAVING COUNT(*) > 1;
GO


-- ==========================================================
-- 2. Customer Dimension: Check Gender Standardization
-- ==========================================================

SELECT DISTINCT
    gender
FROM gold.dim_customers
ORDER BY gender;
GO


-- ==========================================================
-- 3. Product Dimension: Check for Duplicate Product Keys
-- ==========================================================

-- Expectation: No Results
SELECT
    prd_key,
    COUNT(*) AS record_count
FROM (
    SELECT
        cp.prd_key
    FROM silver.crm_prd_info AS cp
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
        ON cp.cat_id = pc.id
    WHERE cp.prd_end_dt IS NULL
) AS t
GROUP BY prd_key
HAVING COUNT(*) > 1;
GO


-- ==========================================================
-- 4. Sales Fact: Check Foreign Key Integrity
-- ==========================================================

-- Expectation: No Results for unmatched customer or product keys
SELECT
    f.order_number,
    f.customer_key,
    f.product_key,
    c.customer_key AS matched_customer_key,
    p.product_key AS matched_product_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;
GO
