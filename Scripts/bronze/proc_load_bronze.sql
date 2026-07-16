/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/



/*

BEGIN and END (Grouping Code)
What it does: It acts like parentheses or a wrapper for your SQL code.

Why use it: It tells SQL Server to treat a group of multiple sentences as one single package.

When to use it: You use it most often with IF conditions. Without BEGIN and END, an IF statement will 
only run the very next single line of code; with them, it will run the entire wrapped block.
======================================================================================================================
BEGIN TRY and BEGIN CATCH (Error Handling)
What it does: It is a safety net that prevents your database from crashing when an error happens.

Why use it: If something goes wrong (like trying to divide a number by zero or inserting duplicate data), 
SQL Server stops running the TRY block immediately and safely jumps down to the CATCH block.

When to use it: You use this when you want to run risky code, log errors, or undo changes safely if something fails midway.

*/


CREATE OR ALTER PROCEDURE bronze.loadbronze AS

BEGIN
	DECLARE @start_time  DATETIME , @end_time DATETIME ,@batch_start_time DATETIME , @batch_end_time DATETIME;
	BEGIN TRY
	
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> truncating table : bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data into : bronze.crm_cust_info  '

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\HRUSHI\Desktop\PROJECTS\sql Datawarehouse git\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW =2 ,
			FIELDTERMINATOR = ',' ,
			TABLOCK 
			);
		

		SET @start_time = GETDATE();
		PRINT '>> truncating table : bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting Data into : bronze.crm_prd_info  '

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\HRUSHI\Desktop\PROJECTS\sql Datawarehouse git\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW =2 ,
			FIELDTERMINATOR = ',' ,
			TABLOCK 
			);
		
		SET @start_time = GETDATE();
		PRINT '>> truncating table : bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data into : bronze.crm_sales_details  '

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\HRUSHI\Desktop\PROJECTS\sql Datawarehouse git\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW =2 ,
			FIELDTERMINATOR = ',' ,
			TABLOCK 
			);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
		


		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\HRUSHI\Desktop\PROJECTS\sql Datawarehouse git\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\HRUSHI\Desktop\PROJECTS\sql Datawarehouse git\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\HRUSHI\Desktop\PROJECTS\sql Datawarehouse git\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END