IF OBJECT_ID(N'[dbo].[spa_alert_table_where_clause]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_table_where_clause]
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
CREATE PROCEDURE [dbo].[spa_alert_table_where_clause]
    @flag CHAR(1),
    @alert_id INT = NULL,
    @condition_id INT = NULL,
    @xml TEXT = NULL
AS
SET NOCOUNT ON 
DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
 
IF @flag = 's'
BEGIN
	SELECT atwc.alert_table_where_clause_id,
		   atwc.clause_type,
	       atwc.table_id,
		   --acd.column_name,
		   atwc.column_id,
	       atwc.column_function,
		   atwc.operator_id,
	       atwc.column_value,
	       atwc.second_value
	FROM   alert_table_where_clause atwc
	--INNER JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = atwc.column_id
	WHERE  atwc.alert_id = @alert_id AND atwc.condition_id = @condition_id
END

IF @flag = 'p' -- list all columns
BEGIN
	SELECT art.alert_rule_table_id [table_id],
		   acd.alert_columns_definition_id [column_id],
	       acd.column_name [column_name],
	       acd.static_data_type_id	       
	FROM alert_rule_table art
    INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
    INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id
	WHERE art.alert_id = @alert_id
END
IF @flag = 'q' -- list all tables
BEGIN
	SELECT art.alert_rule_table_id [table_id],
		   acd.alert_columns_definition_id [column_id],
	       art.table_alias + '.' + acd.column_name [column_name],
	       acd.static_data_type_id	       
	FROM alert_rule_table art
    INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
    INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id
	WHERE art.alert_id = @alert_id
END

IF @flag = 'i' -- insert into alert_table_where_clause
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#alert_table_where_clause') IS NOT NULL
			DROP TABLE #alert_table_where_clause
				
		SELECT clause_type [clause_type],
			   table_id [table_id],
			   column_id [column_id],
			   operator_id [operator_id],
			   column_value [column_value],
			   second_value [second_value],
			   column_function [column_function]
		INTO #alert_table_where_clause
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		   clause_type		VARCHAR(20),
		   table_id			VARCHAR(20),
		   column_id		VARCHAR(20),
		   operator_id		VARCHAR(500),
		   column_value		VARCHAR(1000),
		   second_value		VARCHAR(1000),
		   column_function	VARCHAR(1000)
		)
		
		If Exists (select table_id from #alert_table_where_clause where table_id = 0)
		Begin
			delete from #alert_table_where_clause where table_id  = 0
		END

		DELETE FROM alert_table_where_clause WHERE alert_id = @alert_id AND condition_id = @condition_id
	    
	    INSERT INTO alert_table_where_clause (alert_id, clause_type, column_id, operator_id, column_value, second_value, table_id, column_function, condition_id)
	    SELECT @alert_id, clause_type, column_id, NULLIF(operator_id,''), column_value, NULLIF(second_value, ''), table_id, column_function, @condition_id FROM #alert_table_where_clause atr 
		
		EXEC spa_ErrorHandler 0
			, 'alert_table_where_clause'
			, 'spa_alert_table_where_clause'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'alert_table_where_clause'
		   , 'spa_alert_table_where_clause'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END