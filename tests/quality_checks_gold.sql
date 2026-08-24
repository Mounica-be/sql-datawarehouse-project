/*
======================================================================================
Quality checks
======================================================================================
Script purpose:
  This script performs quality checks to validate the integrity , consistency,
  and accuracy of the gold layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    -Referential integrity between fact and dimension tables.
    -Validation of relationships in the data model for analytical purposes.

Usage Notes:
   - Run these scripts after loading gold layer.
   - Investigate and resolve any discrepancies found during the checks.
======================================================================================
*/

--=================================
-- Checking 'gold.dim_customers'
--=================================

-- checking for uniqueness of product key in gold.dim_customers
-- Expectation : No results

SELECT
	customer_key,
	COUNT(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) >1

--=================================
-- Checking 'gold.dim_products'
--=================================

-- checking for uniqueness of product key in gold.dim_products
-- Expectation : No results

SELECT
	product_key,
	COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) >1

-- Foreign key integrity ( dimensions)
SELECT * 
FROM gold.facts_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


SELECT *
FROM gold.facts_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

--================================================
-- Checking 'gold.fact_sales'
--================================================
-- Check the datamodel connectivity between fact and dimensions.
SELECT * 
FROM gold.facts_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
