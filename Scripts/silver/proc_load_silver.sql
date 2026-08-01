/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/



CREATE OR ALTER PROCEDURE silver.load_silver  AS
BEGIN
	-- select * from bronze.crm_cust_info;
	PRINT '>> Truncating Table: silver.crm_cust_info';

	TRUNCATE TABLE silver.crm_cust_info;

	PRINT '>> Inserting Data Into : silver.crm_cust_info';

	INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_martial_status,
		cst_gndr,
		cst_create_date
	)
	SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname, -- trimming the space of the columns
		trim(cst_lastname ) as cst_lastname,

		CASE 
			WHEN UPPER(TRIM(cst_martial_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_martial_status)) = 'M' then 'Married'
			-- capitalising and trimming the column then checking the condition and standardising (convert) according to our needs
		Else 'n/a'
		END as cst_martial_satus, -- Normaliza martial status value to readable format 

		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
		ELSE 'n/a' -- same as above
		END as cst_gndr, -- Normalise gender value to readable format

		cst_create_date

	FROM (
		SELECT 
			* ,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date desc) as flag_last
		FROM bronze.crm_cust_info -- used row number on cst_id and ordered the data based on create date to get most recent data
		where cst_id IS NOT NULL
	) t 
	where flag_last = 1;  -- filtered the to remove the duplicates 

	--select count(*) from silver.crm_cust_info;
	--select * from silver.crm_cust_info;

	PRINT '>> Truncating Table: silver.crm_prd_info';

	TRUNCATE Table silver.crm_prd_info;

	PRINT '>> Inserting Data Into: silver.crm_prd_info';

	INSERT INTO silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT
		prd_id,
		replace(substring(prd_key,1,5), '-','_') as cat_id, -- Extract category ID
		substring(prd_key , 7, len(prd_key)) as prd_key,  -- Extract product key

		prd_nm,
		isnull(prd_cost ,0 ) as prd_cost,

		CASE upper(trim (prd_line))
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'S' then 'other Sales'
			when 'T' then 'Touring'
			else 'n/a'

		end as prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt, -- also update ddl file columns data types as we change inthe proc load
		CAST(	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
					AS DATE
				) AS prd_end_dt -- Calculate end date as one day before the next start date			
	FROM bronze.crm_prd_info;


	--select * from silver.crm_prd_info;

	-- sp_help 'bronze.crm_sales_details';


	PRINT '>> Truncating Table: silver.crm_sales_details';

	TRUNCATE Table silver.crm_sales_details;

	PRINT '>> Inserting Data Into: silver.crm_sales_details';
	-- select * from bronze.crm_sales_details;

	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
	
		CASE 
			when sls_order_dt = 0 or len(sls_order_dt) != 8 then Null
			else CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		end as sls_order_dt,

		CASE 
			when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then Null
			else CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		end as sls_ship_dt,

		CASE 
			when sls_due_dt = 0 or len(sls_due_dt) != 8 then Null
			else CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		end as sls_due_dt,

		CASE 
			when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity *abs(sls_price)
				then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales, -- recalculate sales if original value is missing or incorrect 
		-- and replacing with correct value
		sls_quantity,

		CASE 
			when sls_price is null or sls_price <=0
				then sls_sales / nullif(sls_quantity,0)
			else sls_price
		end as sls_price

	from bronze.crm_sales_details;

	PRINT '>> Inserting Done  Into: silver.crm_sales_details';

	--select * from silver.crm_sales_details;


	--------------------------------------------------------------------------

	PRINT '------------------------------------------------';
	PRINT 'Loading ERP Tables';
	PRINT '------------------------------------------------';


	PRINT '>> Truncating Table: silver.erp_cust_az12';

	TRUNCATE Table silver.erp_cust_az12;

	PRINT '>> Inserting Data Into: silver.erp_cust_az12';

	INSERT INTO silver.erp_cust_az12(
		cid,
		bdate,
		gen
	)
	select 
		case 
			when cid like 'NAS%' then substring(cid,4 ,len(cid)) -- remove 'nas' prefix if present
			else cid
		end cid,

		case 
			when bdate > getdate() then null
			else bdate
		end bdate,

		case 
			when upper(trim(gen)) in ('F' , 'FEMALE') then 'Female'
			when upper(trim(gen)) in ('M' ,'MALE') then 'Male'
			else 'n/a'
		end as gen -- normalise gender values and handle unknown cases

	from bronze.erp_cust_az12;



	PRINT '>> Truncating Table: silver.erp_loc_a101';

	TRUNCATE Table silver.erp_loc_a101;

	PRINT '>> Inserting Data Into: silver.erp_loc_a101';

	INSERT INTO silver.erp_loc_a101 (
		cid,
		cntry
	)
	select 
		replace(cid,'-','')as cid,

		case
			when TRIM(cntry) = 'DE' then 'Germany'
			when trim(cntry) in ('US' ,'USA') then 'United States'
			when trim(cntry) = '' or cntry is null then 'n/a'
			else trim(cntry)
		end as cntry -- normalsie and hande missing or blank country codes

	from bronze.erp_loc_a101;


	PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
	INSERT INTO silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintenance
	)
	SELECT
		id,
		cat,
		subcat,
		maintenance
	FROM bronze.erp_px_cat_g1v2;

END
