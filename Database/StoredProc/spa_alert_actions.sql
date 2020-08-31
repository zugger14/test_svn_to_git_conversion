IF OBJECT_ID(N'[dbo].[spa_alert_actions]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_actions]
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

CREATE PROCEDURE [dbo].[spa_alert_actions]
    @flag CHAR(1),
    @alert_actions_id INT = NULL,
    @alert_id INT = NULL,
    @xml TEXT = NULL,
    @tsql VARCHAR(MAX) = NULL,
    @xml_events TEXT = NULL,
    @condition_id INT = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @return INT
 
IF @flag = 's'
BEGIN
	SELECT 
		   aa.table_id,
	       aa.column_id,
	       aa.column_value
	FROM alert_actions aa
	INNER JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = aa.column_id
	WHERE aa.alert_id = @alert_id AND aa.condition_id = @condition_id
END

IF @flag = 't' --- select all registered events for alert actions
BEGIN
	SELECT aare.table_id,
	       aare.callback_alert_id
	FROM   alert_actions_events aare
	WHERE  aare.alert_id = @alert_id
END

IF @flag = 'r'
BEGIN
	SELECT aa.sql_statement
	FROM alert_actions aa
	WHERE aa.alert_id = @alert_id
END

IF @flag = 'a'
BEGIN
	SELECT aa.sql_statement
	FROM alert_actions aa
	WHERE aa.alert_id = @alert_id AND aa.condition_id = @condition_id
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

IF @flag = 'i' -- insert into alert_actions
BEGIN
	BEGIN TRY
		BEGIN TRAN
		DECLARE @idoc_events  INT
		--DELETE FROM alert_actions WHERE alert_id = @alert_id
		DELETE FROM alert_actions WHERE condition_id = @condition_id
		
		IF @tsql IS NULL
		BEGIN
			DECLARE @idoc         INT
			--SET @xml = '
			--		<Root>
			--			<PSRecordset tableId="'+ table_id +'" columnId="' + column_id + '"  columnValue="' + column_value + '"></PSRecordset>
			--		</Root>'
					
				--Create an internal representation of the XML document.
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			-- Create temp table to store the report_name and report_hash
			IF OBJECT_ID('tempdb..#alert_actions') IS NOT NULL
				DROP TABLE #alert_actions
		
			-- Execute a SELECT statement that uses the OPENXML rowset provider.
			SELECT --condition_id [condition_id],
				   table_id [table_id],
				   column_id [column_id],
				   column_value [column_value]
			INTO #alert_actions
			FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
			WITH (
			   --condition_id	 VARCHAR(20),
			   table_id		 VARCHAR(20),
			   column_id		 VARCHAR(20),
			   column_value	 VARCHAR(1000)
			)
			
			INSERT INTO alert_actions (alert_id, column_id, column_value, table_id, condition_id)
			SELECT @alert_id, column_id, column_value, table_id, @condition_id FROM #alert_actions atr 		
		END
		ELSE
		BEGIN
			EXEC @return = spa_check_sql_syntax @tsql
			IF @return = 1
			BEGIN
				EXEC spa_ErrorHandler -1,
					 'alert_actions',
					 'spa_alert_actions',
					 'Error',
					 'SQL Statement is Invalid.',
					 ''
				RETURN
			END
			
			INSERT INTO alert_actions (alert_id, sql_statement, condition_id)
			SELECT @alert_id, @tsql, @condition_id	
		END
		
		DELETE FROM alert_actions_events WHERE alert_id = @alert_id
		EXEC sp_xml_preparedocument @idoc_events OUTPUT, @xml_events

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#alert_actions_events') IS NOT NULL
			DROP TABLE #alert_actions_events
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT table_id [table_id],
		       callback_alert_id [callback_alert_id]
		INTO #alert_actions_events
		FROM OPENXML(@idoc_events, '/Root/PSRecordset', 1)
        WITH (
           table_id VARCHAR(20),
           callback_alert_id VARCHAR(1000)
        )
		
		INSERT INTO alert_actions_events (alert_id, table_id, callback_alert_id)
		SELECT @alert_id, table_id, callback_alert_id FROM #alert_actions_events aare 
		
		COMMIT
		EXEC spa_ErrorHandler 0
			, 'alert_actions'
			, 'spa_alert_actions'
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
		   , 'alert_actions'
		   , 'spa_alert_actions'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
IF @flag = 'x' -- syntax checking
BEGIN
	EXEC @return = spa_check_sql_syntax @tsql
	
	IF @return = 0 
	BEGIN
		EXEC spa_ErrorHandler 0,
			 'alert_actions',
			 'alert_actions',
			 'Success',
			 'SQL Statement is Valid.',
			 ''
	END
	ELSE IF @return = 1
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'alert_sql_statement',
			 'alert_actions',
			 'Error',
			 'SQL Statement is Invalid.',
			 ''
	END 
END


