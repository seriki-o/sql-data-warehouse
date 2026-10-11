
/*
============================================================
Script: Silver Layer Data Quality Checks

Script Purpose:
    Runs data quality checks on Silver layer tables to
    identify duplicates, missing values, unwanted spaces,
    inconsistent values, invalid dates, and data integrity
    issues.

Usage:
    Run after executing silver.load_silver.
    Review the results of each query to identify anomalies.

Expectation:
    Queries marked "No Results Expected" should return
    zero rows when the data passes the check.
============================================================
*/

USE DataWarehouse;
GO

-- ==========================================================
-- CRM: Customer Information
-- ==========================================================

-- Check for NULLs or duplicate customer IDs
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;
GO

-- Check for unwanted spaces in customer names
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);
GO

-- Check gender standardization
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Check marital status standardization
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;
GO

-- Review customer records
SELECT *
FROM silver.crm_cust_info;
GO


-- ==========================================================
-- CRM: Product Information
-- ==========================================================

-- Check for NULLs or duplicate product IDs
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;
GO

-- Check for unwanted spaces in product names
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);
GO

-- Check for NULL or negative product costs
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0
    OR prd_cost IS NULL;
GO

-- Check product line standardization
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;
GO

-- Check for invalid product date ranges
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
GO


-- ==========================================================
-- CRM: Sales Details
-- ==========================================================

-- Check for unwanted spaces in order numbers
-- Expectation: No Results
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num);
GO

-- Check for product keys without matching products
-- Expectation: No Results
SELECT s.*
FROM silver.crm_sales_details AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.crm_prd_info AS p
    WHERE p.prd_key = s.sls_prd_key
);
GO

-- Check for customer IDs without matching customers
-- Expectation: No Results
SELECT s.*
FROM silver.crm_sales_details AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.crm_cust_info AS c
    WHERE c.cst_id = s.sls_cust_id
);
GO

-- Check for NULL or invalid sales order dates
-- Expectation: No Results
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
    OR sls_order_dt < '1900-01-01'
    OR sls_order_dt > '2050-01-01';
GO

-- Check for invalid date sequences
-- Order date should not be later than ship or due date
-- Expectation: No Results
SELECT *
FROM silver.crm_sales_details
WHERE (sls_ship_dt IS NOT NULL
       AND sls_order_dt > sls_ship_dt)
    OR (sls_due_dt IS NOT NULL
        AND sls_order_dt > sls_due_dt);
GO

-- Check consistency between sales, quantity, and price
-- Sales should equal quantity multiplied by price
-- Expectation: No Results
SELECT
    sls_ord_num,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
    OR sls_sales <> sls_quantity * sls_price;
GO


-- ==========================================================
-- ERP: Customer Information
-- ==========================================================

-- Check for birth dates outside the accepted range
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
    OR bdate > CAST(GETDATE() AS DATE);
GO

-- Check gender standardization
SELECT DISTINCT gen
FROM silver.erp_cust_az12;
GO


-- ==========================================================
-- ERP: Location Information
-- ==========================================================

-- Check country standardization
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;
GO

-- Review location records
SELECT *
FROM silver.erp_loc_a101;
GO


-- ==========================================================
-- ERP: Product Category Information
-- ==========================================================

-- Check for unwanted spaces
-- Expectation: No Results
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
    OR subcat <> TRIM(subcat)
    OR maintenance <> TRIM(maintenance);
GO

-- Check maintenance value standardization
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
GO

