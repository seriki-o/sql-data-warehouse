

/*
============================================================
Script Purpose:
    Reset the DataWarehouse database by dropping it if it
    exists, recreating it, and creating the Bronze, Silver,
    and Gold schemas for the Medallion Architecture.

WARNING:
    Running this script permanently deletes the existing
    DataWarehouse database and all its data.
============================================================
*/

USE master;
GO

-- Drop the database if it already exists
IF DB_ID('DataWarehouse') IS NOT NULL
BEGIN
    ALTER DATABASE DataWarehouse
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;
GO

-- Create the database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create the Medallion Architecture schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
