/*
==============================================================================================
DDL script for gold layer : Create Gold views
==============================================================================================
Script purpose:
  This script creates views for gold layer in the data warehouse.
  The gold layer represents the final dimension and fact tables ( Star Schema)

  Each view performs transformation and combines data from the silver layer to produce 
  a clean , enriched and business - ready dataset.

Usage:   
  - These views can be queried directly for analytics and reporting.
===============================================================================================
*/

--==========================================
-- create dimension : gold.dim_customers
--===========================================

IF OBJECT_ID ('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT  
	ROW_NUMBER() OVER( ORDER BY cc.cst_id) AS customer_key,
	cc.cst_id AS customer_id,
	cc.cst_key AS customer_number,
	cc.cst_firstname AS first_name,
	cc.cst_lastname AS last_name,
	ecl.cntry AS country,
	cc.cst_marital_status AS marital_status,
	CASE WHEN cc.cst_gndr != 'n/a' THEN cc.cst_gndr -- CRM is the master for gender info
		 ELSE COALESCE(ec.gen,'n/a')
	END gender,
	ec.bdate AS birhdate,
	cc.cst_create_date AS create_date
FROM silver.crm_cust_info cc
LEFT JOIN silver.erp_cust_az12 ec
ON  cc.cst_key = ec.cid
LEFT JOIN silver.erp_loc_a101 ecl
ON cc.cst_key = ecl.cid;

GO

--==========================================
-- create dimension : gold.dim_products
--===========================================
  
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products;

GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cp.prd_start_dt,cp.prd_key) AS product_key,
	cp.prd_id AS product_id,
	cp.prd_key AS product_number,
	cp.prd_nm AS product_name,
	cp.cat_id AS category_id,
	ep.cat AS category,
	ep.subcat AS subcategory,
	ep.maintenance,
	cp.prd_cost AS cost,
	cp.prd_line AS product_line,
	cp.prd_start_dt AS start_date
FROM silver.crm_prd_info cp
LEFT JOIN silver.erp_px_cat_g1v2 ep
ON cp.cat_id = ep.id
WHERE cp.prd_end_dt IS NULL; -- Filter out all historical data.

GO

--==========================================
-- create fact table : gold.fact_sales
--===========================================

IF OBJECT_ID('gold.facts_sales','V') IS NOT NULL
	DROP VIEW gold.facts_sales;
GO


CREATE VIEW gold.facts_sales AS
SELECT 
    sls_ord_num AS order_number,
    p.product_key,
    c.customer_key,
    sls_order_dt As order_date,
    sls_ship_dt AS shipping_date,
    sls_due_dt AS due_date,
    sls_sales AS sales,
    sls_quantity As quantity,
    sls_price AS price
  FROM silver.crm_sales_details s
  LEFT JOIN gold.dim_customers c
  ON s.sls_cust_id = c.customer_id
  LEFT JOIN gold.dim_products p
  ON s.sls_prd_key = p.product_number;

  GO
