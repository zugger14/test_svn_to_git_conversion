IF OBJECT_ID(N'[dbo].[spa_ixp_soap_functions]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_soap_functions]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-03-05
-- Description: Different operations using table ixp_soap_functions.
 
-- Params:
-- @flag CHAR(1)        - Operational flag 
--						- 's' - select, 
--						- 'r' - create a table using xml defined in ixp_soap_functions or sample xml
-- @soap_function_id INT - id from table ixp_soap_functions
-- @process_id VARCHAR(300) = process table 
-- Usage - EXEC spa_ixp_soap_functions 'r', 2, 'a'
-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[spa_ixp_soap_functions]
    @flag CHAR(1),
    @soap_function_id INT = NULL,
    @process_id VARCHAR(300) = NULL,
    @ws_function_name VARCHAR(200) = NULL
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @user_name VARCHAR(300)
SET @user_name = dbo.FNADBUser()
		
IF @flag = 's'
BEGIN
    SELECT isf.ixp_soap_functions_id,
           isf.ixp_soap_functions_name
    FROM   ixp_soap_functions isf
END
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		DECLARE @xml XML
		DECLARE @soap_process_table VARCHAR(600)
		DECLARE @function_name VARCHAR(300)
		
		--SELECT @xml = isf.ixp_soap_xml,
		--       @function_name = isf.ixp_soap_functions_name
		--FROM   ixp_soap_functions isf
		--WHERE  isf.ixp_soap_functions_id = @soap_function_id
		
		SELECT @xml = NULL,
		       @function_name = @ws_function_name 
		
		IF @xml IS NULL
		BEGIN
			SET @xml = '<Root><PSRecordset column1="1" column2="2"></PSRecordset></Root>'
		END
		
		SET @function_name = LOWER('soap_' + @function_name)
		SET @soap_process_table = dbo.FNAProcessTableName(@function_name, @user_name, @process_id)
	
		EXEC spa_parse_xml_file 'b', NULL, @xml, @soap_process_table
		
		IF OBJECT_ID(@soap_process_table) IS NOT NULL
		BEGIN
			-- delete all data from table so that data defined in sample XML is not inserted into database
			EXEC('DELETE FROM ' + @soap_process_table)
			
			EXEC spa_ErrorHandler 0
				, 'Run SOAP Service'
				, 'spa_ixp_soap_functions'
				, 'Success' 
				, 'Web Services initialize sucessfully.'
				, @soap_process_table
		END
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'Run SOAP Service'
				, 'spa_ixp_soap_functions'
				, 'Error' 
				, 'Web Services could not initialize sucessfully. Function is not defined properly. Please contact support.'
				, ''
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to initialize web service. ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
			, 'Run SOAP Service'
			, 'spa_ixp_soap_functions'
			, 'Error' 
			, @desc
			, ''
	END CATCH
END