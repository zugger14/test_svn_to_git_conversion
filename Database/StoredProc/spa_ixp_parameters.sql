IF OBJECT_ID(N'[dbo].[spa_ixp_parameters]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_parameters]
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

CREATE PROCEDURE [dbo].[spa_ixp_parameters]
    @flag CHAR(1),
    @rules_id INT = NULL,
    @process_id VARCHAR(200) = NULL,
    @xml XML = NULL,
	@data_source_type INT  = NULL
AS
SET NOCOUNT ON 

DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

DECLARE @user_name VARCHAR(100)
DECLARE @ixp_parameters VARCHAR(200)

IF NULLIF(@data_source_type, '') IS NULL 
BEGIN 
	SET @data_source_type = 21403
END
SET @user_name = dbo.FNADBUser() 
SET @ixp_parameters = dbo.FNAProcessTableName('ixp_parameters', @user_name, @process_id) 
 
IF @flag = 's'
BEGIN
	SET @sql = ' SELECT isp.ixp_parameters_id,
	                    isp.ixp_rules_id,
	                    isp.parameter_name,
	                    isp.parameter_label,
	                    isp.field_type,
	                    isp.operator_id,
	                    isp.default_value,
	                    isp.default_value2
	             FROM ' +  @ixp_parameters + ' isp
				 INNER JOIN ixp_import_data_source iids
						ON ISNULL(iids.ssis_package, -1) = ISNULL(isp.ssis_package, -1)
						AND ISNULL(iids.clr_function_id, -1) = ISNULL(isp.clr_function_id, -1)
	             WHERE iids.rules_id = ' + CAST(@rules_id AS VARCHAR(20))
	--print(@sql)	 
	EXEC(@sql)            
END

IF @flag = 'i' -- insert into ixp_parameters
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		--SET @xml = '
		--		<Root>
		--			<PSRecordset paramName="asas" paramLabel="ASAS'" fieldType="t" operatorId="1" paramValue="" secondValue=""></PSRecordset>
		--		</Root>'
				
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#ixp_parameters') IS NOT NULL
			DROP TABLE #ixp_parameters
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT paramName [param_name],
		       paramLabel [param_label],
		       fieldType [field_type],
		       operatorId [operator_id],
		       paramValue [param_value],
		       secondValue [second_value]
		INTO #ixp_parameters
		FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		   paramName     VARCHAR(100),
		   paramLabel	 VARCHAR(100),
		   fieldType	 VARCHAR(10),
		   operatorId	 VARCHAR(500),
		   paramValue	 VARCHAR(1000),
		   secondValue   VARCHAR(1000)
		)
		
		SET @sql = 'DELETE isp 
							FROM ' + @ixp_parameters + ' isp
							INNER JOIN ixp_import_data_source iids
								ON ISNULL(isp.ssis_package, -1) = ISNULL(iids.ssis_package, -1)
									AND ISNULL(isp.clr_function_id, -1) = ISNULL(iids.clr_function_id, -1)
							WHERE iids.rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '
					 INSERT INTO ' + @ixp_parameters + ' (parameter_name, parameter_label, operator_id, field_type, default_value, default_value2)
					 SELECT [param_name],
					        [param_label],
					        operator_id,
					        [field_type],
					        NULLIF([param_value], ''''),
					        NULLIF([second_value], '''')
					 FROM #ixp_parameters atr ' 
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_parameters'
			, 'spa_ixp_ssis_parameter'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_parameters'
		   , 'spa_ixp_ssis_parameter'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
ELSE IF @flag = 'p' -- finds out if rules have parameters or not
BEGIN
	IF @data_source_type = 21403
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM ixp_parameters isp
				INNER JOIN ixp_import_data_source iids
					ON isp.ssis_package = iids.ssis_package
				WHERE iids.rules_id = @rules_id
				)
		BEGIN
		SELECT 'Success' ErrorCode, 'ixp_parameters' Module, 'spa_ixp_parameters' Area, 'Success' Status, 'Parameters present for rule.' [Message], 'y' Recommendation, @data_source_type [data_source_type]
			
		END
		ELSE
			BEGIN
				SELECT 'Success' ErrorCode, 'ixp_parameters' Module, 'spa_ixp_parameters' Area, 'Success' Status, 'Parameters present for rule.' [Message], 'n' Recommendation, @data_source_type [data_source_type]
			END
	END
    IF @data_source_type = 21407
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM ixp_parameters isp
				INNER JOIN ixp_import_data_source iids
					ON isp.clr_function_id = iids.clr_function_id
				WHERE iids.rules_id = @rules_id
				)
		BEGIN
			SELECT 'Success' ErrorCode, 'ixp_parameters' Module, 'spa_ixp_parameters' Area, 'Success' Status, 'Parameters present for rule.' [Message], 'y' Recommendation, @data_source_type [data_source_type]
		END
		ELSE
			BEGIN
				SELECT 'Success' ErrorCode, 'ixp_parameters' Module, 'spa_ixp_parameters' Area, 'Success' Status, 'Parameters present for rule.' [Message], 'n' Recommendation, @data_source_type [data_source_type]
			END
	END
	IF @data_source_type IN (21405,21400,21401,21406,21404,21402,21409) 
	BEGIN
		SELECT 'Success' ErrorCode, 'ixp_parameters' Module, 'spa_ixp_parameters' Area, 'Success' Status, 'Parameters present for rule.' [Message], 'n' Recommendation, @data_source_type [data_source_type]
	END
END
ELSE IF @flag = 'a'
BEGIN
	SELECT isp.parameter_name,
	       isp.parameter_label,
	       isp.field_type,
	       isp.operator_id,
	       isp.default_value,
	       isp.default_value2
	FROM   ixp_parameters isp	
	INNER JOIN 	ixp_import_data_source iids
		ON ISNULL(isp.ssis_package, -1) = ISNULL(iids.ssis_package, -1)
		AND ISNULL(isp.clr_function_id, -1) = ISNULL(iids.clr_function_id, -1)
	WHERE iids.rules_id = @rules_id
END
GO