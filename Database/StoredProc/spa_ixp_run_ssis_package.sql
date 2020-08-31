IF OBJECT_ID(N'[dbo].[spa_ixp_run_ssis_package]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_run_ssis_package]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================


CREATE PROCEDURE [dbo].[spa_ixp_run_ssis_package]
    @flag CHAR(1),
    @package_id INT = NULL,
    @use_parameter CHAR(1) = NULL,
    @process_id VARCHAR(400) = NULL,
    @rules_id INT = NULL,
    @param_xml TEXT = NULL
AS
 
DECLARE @sql VARCHAR(8000)
DECLARE @ssis_path VARCHAR(5000)
DECLARE @package_desc VARCHAR(200)
DECLARE @job_name VARCHAR(5000)
DECLARE @user_login_id VARCHAR(100)
DECLARE @package_name VARCHAR(100)
DECLARE @config_filter_value VARCHAR(100)
DECLARE @import_table_name VARCHAR(400)
DECLARE @params VARCHAR(8000)
DECLARE @user_defined_params VARCHAR(8000)

SET @user_login_id = dbo.FNADBUser()

IF @flag = 'r'
BEGIN
	SELECT @config_filter_value = config_filter_value,
	       @package_name = package_name,
	       @package_desc = package_description
	FROM ixp_ssis_configurations
	WHERE ixp_ssis_configurations_id = @package_id	
	
	SET @import_table_name = 'adiha_process.dbo.' + @package_name + '_' + @process_id
	
	DECLARE @ssis_system_variable VARCHAR(1024) = ' /SET \Package.Connections[OLE_CONN_MainDB].Properties[UserName];' + @user_login_id
	SET @params = 'PS_ProcessID=' + @process_id + ', PS_StagingTable=' + @import_table_name + ', PS_UserLoginID=' + @user_login_id 
	
	IF @use_parameter = 'y'
	BEGIN
		IF @param_xml IS NOT NULL
		BEGIN
			DECLARE @idoc  INT
			--SET @xml = '
			--		<Root>
			--			<PSRecordset paramName="asas" paramValue="ASAS'"></PSRecordset>
			--		</Root>'
					
			--Create an internal representation of the XML document.
			EXEC sp_xml_preparedocument @idoc OUTPUT, @param_xml

			IF OBJECT_ID('tempdb..#ixp_ssis_parameters') IS NOT NULL
				DROP TABLE #ixp_ssis_parameters
		
			-- Execute a SELECT statement that uses the OPENXML rowset provider.
			SELECT paramName [parameter_name],
				   paramValue [param_value]
			INTO #ixp_ssis_parameters
			FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
			WITH (
			   paramName     VARCHAR(100),
			   paramValue	 VARCHAR(100)
			)
			
			SET @user_defined_params = NULL
			SELECT @user_defined_params = COALESCE(@user_defined_params + ' ', '') + ',' + isp.parameter_name + '=' + isp.param_value FROM #ixp_ssis_parameters isp
						
			SET @params = ISNULL(@params, '') + ' ' + ISNULL(@user_defined_params, '')
		END
		ELSE IF EXISTS(
				SELECT 1 
				FROM ixp_import_data_source iids 
				INNER JOIN ixp_parameters isp				
				ON ISNULL(isp.ssis_package, -1) = ISNULL(iids.ssis_package, -1)
				AND ISNULL(isp.clr_function_id, -1) = ISNULL(iids.clr_function_id, -1)
				WHERE iids.rules_id = @rules_id)
		BEGIN
			SET @user_defined_params = NULL
			SELECT @user_defined_params = COALESCE(@user_defined_params + ' ', '') + ',' + isp.parameter_name + '=' + isp.default_value
			FROM ixp_import_data_source iids 
				INNER JOIN ixp_parameters isp				
				ON ISNULL(isp.ssis_package, -1) = ISNULL(iids.ssis_package, -1)
				AND ISNULL(isp.clr_function_id, -1) = ISNULL(iids.clr_function_id, -1)
			WHERE iids.rules_id = @rules_id
			
			SET @params = ISNULL(@params, '') + ' ' + ISNULL(@user_defined_params, '')
		END
	END

	SET @sql = ISNULL(@sql, '') + ISNULL(@params,'')	
	----now execute dynamic SQL by using CLR. 
	DECLARE @returncode NVARCHAR(MAX)
	EXEC spa_execute_ssis_package_using_clr @config_filter_value, @package_name, @sql, @ssis_system_variable, 'n', 'n', @returncode output
    
	IF @returncode = 'Success'	
		EXEC spa_ErrorHandler 0
			, 'Run SSIS Package'
			, 'spa_ixp_run_ssis_package'
			, 'Success' 
			, 'The package execution succeeded.'
			, @import_table_name
	ELSE	
		EXEC spa_ErrorHandler -1
		   , 'Run SSIS Package'
		   , 'spa_ixp_run_ssis_package'
		   , 'Error'
		   , 'Package failed to execute.'
		   , ''
END