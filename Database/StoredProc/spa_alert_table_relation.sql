IF OBJECT_ID(N'[dbo].[spa_alert_table_relation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_table_relation]
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
CREATE PROCEDURE [dbo].[spa_alert_table_relation]
    @flag CHAR(1),
    @alert_id INT = NULL,
    @xml TEXT = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
 
IF @flag = 's'
BEGIN
	SELECT atr.alert_table_relation_id,
		   atr.from_table_id,
	       atr.from_column_id,
	       atr.to_table_id,
	       atr.to_column_id
	FROM   alert_table_relation atr
	WHERE atr.alert_id = @alert_id
END

IF @flag = 'p' -- list all alert tables (for to table)
BEGIN
	SELECT art.alert_rule_table_id [table_id],
		   art.table_alias + '.' + atd.logical_table_name [table_name]
	FROM alert_rule_table art
    INNER JOIN alert_table_definition atd ON  atd.alert_table_definition_id = art.table_id
	WHERE art.alert_id = @alert_id AND art.root_table_id IS NOT NULL
END

IF @flag = 'q' -- list all alert tables (for from table)
BEGIN
	SELECT art.alert_rule_table_id [table_id],
		   art.table_alias + '.' + atd.logical_table_name [table_name]
	FROM alert_rule_table art
    INNER JOIN alert_table_definition atd ON  atd.alert_table_definition_id = art.table_id
	WHERE art.alert_id = @alert_id
END

IF @flag = 'r' -- list all columns for all alert tables
BEGIN
	SELECT art.alert_rule_table_id [table_id],
	       acd.alert_columns_definition_id [column_id],
	       acd.column_name [column_name]
	FROM alert_rule_table art
    INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
    INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id
	WHERE art.alert_id = @alert_id
END

IF @flag = 'i' -- insert into alert_table_relation
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		--SET @xml = '
		--		<Root>
		--			<PSRecordset tableFrom="5" columnFrom="66" tableTo="7" columnTo="71"></PSRecordset>
		--			<PSRecordset tableFrom="5" columnFrom="64" tableTo="6" columnTo="58"></PSRecordset>
		--			<PSRecordset tableFrom="7" columnFrom="67" tableTo="6" columnTo="57"></PSRecordset>
		--			<PSRecordset tableFrom="7" columnFrom="67" tableTo="6" columnTo="57"></PSRecordset>
		--			<PSRecordset tableFrom="7" columnFrom="67" tableTo="6" columnTo="57"></PSRecordset>
		--		</Root>'
				
			--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#alert_table_relation') IS NOT NULL
			DROP TABLE #alert_table_relation
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT from_table [from_table_id],
			   to_table [to_table_id],
			   from_column [from_column_id],
			   to_column [to_column_id]
		INTO #alert_table_relation
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		   from_table		VARCHAR(20),
		   to_table			VARCHAR(20),
		   from_column		VARCHAR(500),
		   to_column		VARCHAR(500)
		)

	    DELETE FROM alert_table_relation WHERE alert_id = @alert_id
	    
	    INSERT INTO alert_table_relation (alert_id, from_table_id, from_column_id, to_table_id, to_column_id)
	    SELECT @alert_id, from_table_id, from_column_id, to_table_id, to_column_id FROM #alert_table_relation atr 
		
		EXEC spa_ErrorHandler 0
			, 'alert_table_relation'
			, 'spa_alert_table_relation'
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
		   , 'alert_table_relation'
		   , 'spa_alert_table_relation'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END

IF @flag = 't' -- list all columns for all alert tables
BEGIN
	SELECT acd.alert_columns_definition_id [column_id],
	       art.table_alias + '.' + acd.column_name [column_name]	       
	FROM alert_rule_table art
    INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
    INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id
	WHERE art.alert_id = @alert_id
END