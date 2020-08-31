
DECLARE @db_name VARCHAR(200), @library_path VARCHAR(2000)
SET @db_name = DB_NAME()

--TODO: Change the path to dll files according to the deployment environment
-- This path must exists in server
SET @library_path = 'D:\FARRMS_SPTFiles\CLRLibrary\FARRMSGenericCLR.dll'

EXEC('ALTER DATABASE ' + @db_name + ' SET TRUSTWORTHY ON')

/*WHEN SID of the database is not matched with what is stored in master db, creating assembly fails.
* The SID mismatch can occur due to restoration of db from a backup taken from other server, where database owner is different.
* To fix that, change ownership of the db to sa.
* Following queries can be used to check the SID
* --To get owner SID recorded in the master database for the current database
SELECT owner_sid FROM sys.databases WHERE database_id = DB_ID()

--To get the owner SID recorded for the current database owner
SELECT sid FROM sys.database_principals WHERE name=N'dbo'
*/
--TODO : ALways provide system user which has sysadmin privileges .
EXEC('ALTER AUTHORIZATION ON Database::' + @db_name + ' TO [sa]')

IF OBJECT_ID('spa_calculate_eigen_values') IS NOT NULL
	DROP PROCEDURE spa_calculate_eigen_values
	
DROP ASSEMBLY FARRMSGenericCLR

CREATE ASSEMBLY FARRMSGenericCLR
FROM @library_path
WITH PERMISSION_SET = UNSAFE
GO

CREATE PROCEDURE spa_calculate_eigen_values
	@as_of_date NVARCHAR(10),
	@term_start NVARCHAR(10),
	@term_end NVARCHAR(10),
	@purge NVARCHAR(1),
	@dvalue_end_range FLOAT = -2, -- Default end range for dvalue
	@user_name NVARCHAR(100),
	@process_id NVARCHAR(100)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CalculateEigenValues
GO


EXEC sp_configure 'clr enabled', 1
GO
RECONFIGURE WITH OVERRIDE
GO


/*
*--	Example 
EXEC spa_calculate_eigen_values @as_of_date = '2014-07-31'
,    @term_start = '2014-08-01'
,    @term_end = '2014-12-01'
,    @purge = 'y'
,    @dvalue_end_range = -2
,    @user_name = 'farrms_admin'
,    @process_id = '09CCCFB8_11C6_4EEA_A0A9_9F76D2AB554A_54edafc19b3dd'

--	Eigen values output table 
SELECT * FROM eigen_value_decomposition
*/