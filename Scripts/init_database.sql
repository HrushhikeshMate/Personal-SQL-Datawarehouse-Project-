/*
=====================================================================
CREATE Database 'DataWarehouse' and Schemas
=====================================================================
Script purpose :
	This script creates a new database named 'DataWarehouse' database after 
	checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
	
*/

USE master;
GO

-- Drop and recrete the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse ;
END;
GO

/*
Database Existence Check: The above snippet queries SQL Server's system catalog 
(sys.databases) to see if a database named 'DataWarehouse' already exists. 
If it finds a match, SELECT 1 returns a lightweight true response, triggering
the BEGIN...END block to safely execute the inner code without throwing an error 
if the database is missing.

*/


-- Create the 'DataWarehouse' database
create database DataWareHouse;
GO

USE DataWareHouse;
GO

-- Create Schemas 
CREATE SCHEMA bronze;
Go

CREATE SCHEMA silver;
Go

CREATE SCHEMA gold;
Go
