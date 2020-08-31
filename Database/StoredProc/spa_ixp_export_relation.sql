IF OBJECT_ID(N'[dbo].[spa_ixp_export_relation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_export_relation]
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
CREATE PROCEDURE [dbo].[spa_ixp_export_relation]
    @flag CHAR(1) = NULL,
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(300) = NULL,
    @xml TEXT = NULL
    
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_export_relation VARCHAR(600) 
DECLARE @ixp_export_data_source VARCHAR(600)
DECLARE @user_name VARCHAR(200)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

SET @user_name = dbo.FNADBUser() 
SET @ixp_export_relation = dbo.FNAProcessTableName('ixp_export_relation', @user_name, @process_id) 
SET @ixp_export_data_source = dbo.FNAProcessTableName('ixp_export_data_source', @user_name, @process_id) 

IF @flag = 'i' -- insert into ixp_export_relation
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
		IF OBJECT_ID('tempdb..#ixp_export_tables') IS NOT NULL
			DROP TABLE #ixp_export_tables
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT tableFrom [from_table_id],
			   tableTo [to_table_id],
			   columnFrom [from_column_id],
			   columnTo [to_column_id]
		INTO #ixp_export_tables
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		   tableFrom	VARCHAR(20),
		   tableTo		VARCHAR(20),
		   columnFrom	VARCHAR(500),
		   columnTo		VARCHAR(500)
		)

	    SET @sql = 'DELETE FROM ' + @ixp_export_relation + ' WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + 
					' INSERT INTO ' + @ixp_export_relation + '([ixp_rules_id], [from_data_source], [to_data_source], [from_column], [to_column])
	                SELECT ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ', [from_table_id], [to_table_id], [from_column_id], [to_column_id] FROM #ixp_export_tables'
	    EXEC spa_print @sql
	    EXEC (@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_export_relation'
			, 'spa_ixp_export_relation'
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
		   , 'ixp_export_relation'
		   , 'spa_ixp_export_relation'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
ELSE IF @flag = 's'
BEGIN
	SET @sql = 'SELECT from_ieds.ixp_export_data_source_id [from_table],
					   to_ieds.ixp_export_data_source_id [to_table],
					   ier.from_column [from_column],
					   ier.to_column [to_column]
				FROM ' + @ixp_export_relation + ' ier 
				INNER JOIN ' + @ixp_export_data_source + ' from_ieds ON  from_ieds.ixp_export_data_source_id = ier.from_data_source
				INNER JOIN ' + @ixp_export_data_source + ' to_ieds ON  to_ieds.ixp_export_data_source_id = ier.to_data_source
				INNER JOIN ixp_exportable_table from_iet ON  from_iet.ixp_exportable_table_id = from_ieds.export_table
				INNER JOIN ixp_exportable_table to_iet ON  to_iet.ixp_exportable_table_id = to_ieds.export_table
				WHERE  ier.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
	exec spa_print @sql
	EXEC(@sql)
END



