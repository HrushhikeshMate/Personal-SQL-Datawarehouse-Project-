/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/


use DataWareHouse;

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

 /*
This above function checks the database system catalog for an object named silver.crm_cust_info.

The 'U' parameter specifies that it should look strictly for a User-defined table.

OBJECT_ID combined with IF acts like a guard at the door. It looks into the database first to see if the table is actually there.
If it isn't, it gently bypasses the DROP command so your script doesn't blow up.

*/
 
  
CREATE TABLE silver.crm_cust_info (
    cst_id          INT,
    cst_key         NVARCHAR(50),
    cst_firstname   NVARCHAR(50),
    cst_lastname    NVARCHAR(50),
    cst_martial_status NVARCHAR(50),
    cst_gndr    NVARCHAR(50),
    cst_create_date NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO


IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE ,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    CID    NVARCHAR(50),
    CNTRY  NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    ID           NVARCHAR(50),
    CAT          NVARCHAR(50),
    SUBCAT       NVARCHAR(50),
    MAINTENANCE  NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
