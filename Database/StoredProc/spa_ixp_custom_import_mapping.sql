IF OBJECT_ID(N'[dbo].[spa_ixp_custom_import_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_custom_import_mapping]
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
CREATE PROCEDURE [dbo].[spa_ixp_custom_import_mapping]
    @flag CHAR(1),
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(500) = NULL,
    @destination_table_id INT = NULL,
    @filter VARCHAR(8000) = NULL,
    @xml TEXT = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_custom_import_mapping VARCHAR(600) 
DECLARE @user_name VARCHAR(200)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @ixp_import_query_builder_import_tables VARCHAR(600)

SET @user_name = dbo.FNADBUser() 
SET @ixp_custom_import_mapping = dbo.FNAProcessTableName('ixp_custom_import_mapping', @user_name, @process_id) 
SET @ixp_import_query_builder_import_tables = dbo.FNAProcessTableName('ixp_import_query_builder_import_tables', @user_name, @process_id)

IF @flag = 'a' -- list all columns of import tables
BEGIN
	SET @sql = 'SELECT c.name [column_name],
	                   icim.source_table_id [table_id],
	                   icim.source_column [source_column],
	                   icim.filter [filter],
	                   REPLACE(icim.default_value, '''''''', '''''''''''') default_value
	            FROM ixp_exportable_table iet
	            INNER JOIN ' + @ixp_import_query_builder_import_tables + ' iiqbit ON iiqbit.table_id = iet.ixp_exportable_table_id
	            LEFT JOIN sys.columns c ON c.object_id = OBJECT_ID(iet.ixp_exportable_table_name)
                LEFT JOIN ' + @ixp_custom_import_mapping + ' icim
					ON  iiqbit.ixp_import_query_builder_import_tables_id= icim.dest_table_id
					AND c.name = icim.destination_column
					AND icim.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '                    
	            WHERE iiqbit.ixp_import_query_builder_import_tables_id = ' + CAST(@destination_table_id AS VARCHAR(20))				
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
		IF OBJECT_ID('tempdb..#ixp_custom_import_mapping') IS NOT NULL
			DROP TABLE #ixp_custom_import_mapping
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT DestColumn [dest_column],
			   SourceTable [source_table_id],
			   SourceColumn [source_column],
			   DefaultValue [default_value]
		INTO #ixp_custom_import_mapping
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		   DestColumn	VARCHAR(500),
		   SourceTable  VARCHAR(500),
		   SourceColumn	VARCHAR(500),
		   DefaultValue VARCHAR(500)
		)

	    SET @sql = '
					DELETE 
	                FROM   ' + @ixp_custom_import_mapping + '
	                WHERE  ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
	                AND dest_table_id = ' + CAST(@destination_table_id AS VARCHAR(20)) + '	                
	                 
					INSERT INTO ' + @ixp_custom_import_mapping + ' ([ixp_rules_id], [dest_table_id],[destination_column], [source_table_id], [source_column], [filter], [default_value])
					SELECT ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ',
					       ' + CAST(@destination_table_id AS VARCHAR(20)) + ', 
					       [dest_column],
					       [source_table_id],
					       [source_column],
					       ' + ISNULL('''' + @filter + '''', 'NULL') + ',
					       [default_value]
					FROM   #ixp_custom_import_mapping'
	    EXEC spa_print @sql
	    EXEC (@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_custom_import_mapping'
			, 'spa_ixp_custom_import_mapping'
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
		   , 'ixp_custom_import_mapping'
		   , 'spa_ixp_custom_import_mapping'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END