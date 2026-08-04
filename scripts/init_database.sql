/*
=========================================================
Create database and schemas
=========================================================
This script creates a new database 'Datawarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database
: 'bronze', 'silver' and 'gold'.

WARNING:
Running this script will drop entire database 'Datawarehouse' if it exists.
All data in the database will be permanently deleted. proceed with caution
and ensure you have proper backups before running this script.
*/


USE master;
GO


--Drop database if already exists.
IF EXISTS ( SELECT 1 FROM sys.databases WHERE name='Datawarehouse')
BEGIN
	ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Datawarehouse;
END;
GO


---create database
CREATE DATABASE Datawarehouse;

USE Datawarehouse;

--create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
