IF OBJECT_ID('spa_execute_ssis_package_using_clr') IS NOT NULL
    DROP PROC spa_execute_ssis_package_using_clr
GO
/*
* Example :
declare @result_output nvarchar(max)
EXEC spa_execute_ssis_package_using_clr 
	 'PRJ_Simplex_Solver',
     'Simplex_Solver',
     'PS_ProcessID=FACBAADE_551D_495A_8308_DC017FE2E31D,PS_user_name=farrms_admin',
     '',
     'y',
     'y',
     @result_output output
     select @result_output
*/
CREATE PROCEDURE dbo.[spa_execute_ssis_package_using_clr]
	@configuration_filter NVARCHAR(255),
	@package_name NVARCHAR(255),
	@ssis_variables_values NVARCHAR(MAX),
	@ssis_system_variables NVARCHAR(MAX)= NULL,
	@use_32_bit_dtexec CHAR(1) = 'n',
	@debug_mode NCHAR(1) = 'n',
	@result_output NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @sql_version_info NVARCHAR(1024) = @@VERSION
	
	DECLARE @ssis_filename NVARCHAR(2048)
	SELECT @ssis_filename = dbo.FNAGetSSISPkgFullPath(@configuration_filter, 'User::PS_PackageSubDir') + @package_name + '.dtsx'
	
	DECLARE @bit_version INT, @sql_version NVARCHAR(25)
	SELECT @bit_version = CASE WHEN CHARINDEX('x64', @sql_version_info) <> 0 THEN 64 ELSE 32 END 
	
	DECLARE @current_version INT 
	SELECT @current_version = dbo.FNAGetMSSQLVersion() 
	SELECT @sql_version = CASE WHEN @current_version = 10 THEN '2008R2' WHEN @current_version = 11 THEN '2012' WHEN @current_version = 12 THEN '2014' WHEN @current_version = 13 THEN '2016' ELSE '2008R2' END 
	
	SELECT @bit_version = CASE WHEN @use_32_bit_dtexec = 'y' THEN 32 ELSE @bit_version END 
	EXEC spa_execute_ssis_package @ssis_filename, @ssis_variables_values, @ssis_system_variables, @sql_version, @bit_version, @debug_mode, @result_output OUTPUT
END

	