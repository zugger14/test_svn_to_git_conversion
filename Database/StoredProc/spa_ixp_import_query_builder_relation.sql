IF OBJECT_ID(N'[dbo].[spa_ixp_import_query_builder_relation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_query_builder_relation]
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
CREATE PROCEDURE [dbo].[spa_ixp_import_query_builder_relation]
    @flag CHAR(1),
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(300) = NULL,
    @xml TEXT = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_import_query_builder_relation VARCHAR(600) 
DECLARE @ixp_import_query_builder_tables VARCHAR(600)
DECLARE @user_name VARCHAR(200)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

SET @user_name = dbo.FNADBUser() 
SET @ixp_import_query_builder_relation = dbo.FNAProcessTableName('ixp_import_query_builder_relation', @user_name, @process_id) 
SET @ixp_import_query_builder_tables = dbo.FNAProcessTableName('ixp_import_query_builder_tables', @user_name, @process_id) 
 
IF @flag = 's'
BEGIN
    SET @sql = 'SELECT from_iiqbt.ixp_import_query_builder_tables_id [from_table],
					   to_iiqbt.ixp_import_query_builder_tables_id [to_table],
					   iiqbr.from_column [from_column],
					   iiqbr.to_column [to_column]
				FROM ' + @ixp_import_query_builder_relation + ' iiqbr 
				INNER JOIN ' + @ixp_import_query_builder_tables + ' from_iiqbt ON  from_iiqbt.ixp_import_query_builder_tables_id = iiqbr.from_table_id
				INNER JOIN ' + @ixp_import_query_builder_tables + ' to_iiqbt ON  to_iiqbt.ixp_import_query_builder_tables_id = iiqbr.to_table_id
				WHERE  iiqbr.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
	exec spa_print @sql
	EXEC(@sql)
END

IF @flag = 'p' -- list all query builder tables (for to table)
BEGIN
	SET @sql = 'SELECT iiqbt.ixp_import_query_builder_tables_id [table_id],
					   iiqbt.table_alias + ''.'' + iiqbt.tables_name [table_name]
				FROM ' + @ixp_import_query_builder_tables + ' iiqbt
				WHERE  iiqbt.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
	EXEC(@sql)	
END

IF @flag = 'q' -- list all query builder tables (for from table)
BEGIN
	SET @sql = 'SELECT iiqbt.ixp_import_query_builder_tables_id [table_id],
					   iiqbt.table_alias + ''.'' + iiqbt.tables_name [table_name]
				FROM ' + @ixp_import_query_builder_tables + ' iiqbt
				WHERE  iiqbt.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' AND root_table_id IS NOT NULL '
	EXEC(@sql)	
END

IF @flag = 'r' -- list all columns for all query builder tables
BEGIN
	SET @sql = 'SELECT a.[table_id], a.[column_name]
	            FROM (
	
					SELECT iiqbt.ixp_import_query_builder_tables_id [table_id],
						   ic.ixp_columns_name  [column_name]
					FROM   ' + @ixp_import_query_builder_tables + ' iiqbt
					INNER JOIN ixp_tables it ON iiqbt.tables_name = it.ixp_tables_description
					INNER JOIN ixp_columns ic ON it.ixp_tables_id = ic.ixp_table_id
					WHERE  iiqbt.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' AND iiqbt.root_table_id IS NULL
							            
					UNION ALL
		
					SELECT iiqbt.ixp_import_query_builder_tables_id [table_id],
						   c.name  [column_name]
					FROM   ' + @ixp_import_query_builder_tables + ' iiqbt
					INNER JOIN ixp_exportable_table iet ON iiqbt.tables_name = iet.ixp_exportable_table_description
					INNER JOIN sys.objects o ON o.object_id = OBJECT_ID(iet.ixp_exportable_table_name) AND o.name = iet.ixp_exportable_table_name
					INNER JOIN sys.columns c ON c.object_id = o.object_id
					WHERE  iiqbt.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' AND iiqbt.root_table_id IS NOT NULL
	            ) a ORDER BY a.[table_id], a.[column_name]		            
	            '
	exec spa_print @sql
	EXEC(@sql)	
END

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
		IF OBJECT_ID('tempdb..#ixp_import_query_builder_relation') IS NOT NULL
			DROP TABLE #ixp_import_query_builder_relation
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT tableFrom [from_table_id],
			   tableTo [to_table_id],
			   columnFrom [from_column_id],
			   columnTo [to_column_id]
		INTO #ixp_import_query_builder_relation
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		   tableFrom	VARCHAR(20),
		   tableTo		VARCHAR(20),
		   columnFrom	VARCHAR(500),
		   columnTo		VARCHAR(500)
		)

	    SET @sql = 'DELETE FROM ' + @ixp_import_query_builder_relation + ' WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + 
					' INSERT INTO ' + @ixp_import_query_builder_relation + '([ixp_rules_id], [from_table_id], [to_table_id], [from_column], [to_column])
	                SELECT ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ', [from_table_id], [to_table_id], [from_column_id], [to_column_id] FROM #ixp_import_query_builder_relation'
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