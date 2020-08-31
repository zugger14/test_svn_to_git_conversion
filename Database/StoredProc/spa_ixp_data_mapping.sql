
IF OBJECT_ID(N'[dbo].[spa_ixp_data_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_data_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 08-02-2013
-- Description: CRUD operations for table ixp_data_mapping
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @ixp_data_mapping_id INT - Identity column parameter for ixp_data_mapping table 
-- @ixp_rules_id INT - rules id
-- @xml TEXT - xml text variables, used for bulk insertion
-- USE - exec spa_ixp_data_mapping 'z', NULL, 1, 2, NULL, NULL, NULL, '53A1DF36_45A8_468B_B329_180A71DB25E5'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_ixp_data_mapping]
    @flag CHAR(1),
    @ixp_data_mapping_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @ixp_table_id INT = NULL,
    @insert_type CHAR(1) = NULL,
    @enable_identity_insert CHAR(1) = NULL,
    @create_dest_table CHAR(1) = NULL,
    @process_id VARCHAR(200) = NULL,
    @xml TEXT = NULL,
    @export_folder VARCHAR(5000) = NULL,
    @export_delim VARCHAR(20) = NULL,
    @generate_script CHAR(1) = NULL,
    @main_table INT = NULL
AS

DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_data_mapping   VARCHAR(200)
DECLARE @ixp_export_data_source VARCHAR(200)
DECLARE @user_name VARCHAR(100)
SET @user_name = dbo.fnadbuser()
SET @ixp_data_mapping = dbo.FNAProcessTableName('ixp_data_mapping', @user_name, @process_id)
SET @ixp_export_data_source = dbo.FNAProcessTableName('ixp_export_data_source', @user_name, @process_id)

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT DISTINCT ISNULL(ic.ixp_columns_name, idm.column_name) column_name,
					   ISNULL(idm.column_alias, ic.ixp_columns_name) column_alias,
					   idm.ixp_rules_id,
					   idm.table_id,
					   idm.column_function,
					   idm.column_aggregation,
					   idm.source_column	
				FROM ' + @ixp_data_mapping + ' idm
				LEFT JOIN ixp_columns ic ON idm.column_name = ic.ixp_columns_name
				LEFT JOIN ixp_tables it ON it.ixp_tables_id = ic.ixp_table_id
				WHERE idm.table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + ''
	
	exec spa_print @sql
	EXEC(@sql)
END
ELSE IF @flag = 'z' -- for insert mode, maps all columns by default.
BEGIN
	SET @sql = 'DECLARE @mapping_table TABLE (exportable_table_name VARCHAR(400), table_name VARCHAR(400))
	
				INSERT INTO @mapping_table (exportable_table_name, table_name)
				SELECT ''source_traders'', ''ixp_source_trader_template'' UNION ALL
				SELECT ''contract_group'', ''ixp_contract_template'' UNION ALL
				SELECT ''source_minor_location'', ''ixp_location_template'' UNION ALL
				SELECT ''meter_id'', ''ixp_hourly_allocation_data_template'' UNION ALL
				SELECT ''contract_group_detail'', ''ixp_contract_template'' UNION ALL
				SELECT ''source_deal_header'', ''ixp_source_deal_template'' UNION ALL
				SELECT ''source_deal_detail'', ''ixp_source_deal_template''
								
				SELECT DISTINCT 
					   ic.ixp_columns_name column_name,
					   ic.ixp_columns_name column_alias,
					   NULL ixp_rules_id,
					   NULL table_id,
					   NULL column_function,
					   NULL column_aggregation,
					   (MAX(export_table_alias) + ''.['' + MAX(c.name) + '']'') source_column
				FROM ixp_columns ic
				INNER JOIN ixp_tables it ON it.ixp_tables_id = ic.ixp_table_id
				LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = LEFT(REPLACE(it.ixp_tables_name, ''ixp_'', ''''), LEN(REPLACE(it.ixp_tables_name, ''ixp_'', '''')) - LEN(''_template''))
				LEFT JOIN @mapping_table mt ON mt.table_name = it.ixp_tables_name
				LEFT JOIN ixp_exportable_table iet2 ON iet2.ixp_exportable_table_name = mt.exportable_table_name	
				LEFT JOIN ' + @ixp_export_data_source + ' ieds ON ieds.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(10)) + ' AND ieds.export_table = ISNULL(iet.ixp_exportable_table_id, iet2.ixp_exportable_table_id)
				LEFT JOIN sys.columns c ON c.object_id = OBJECT_ID(ISNULL(iet.ixp_exportable_table_name, iet2.ixp_exportable_table_name)) AND c.name = ic.ixp_columns_name
				WHERE it.ixp_tables_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + '
				GROUP BY ic.ixp_columns_name, ic.ixp_columns_name				
				'
	exec spa_print @sql
	EXEC(@sql)
END

IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT MAX(idm.column_filter) column_filter,
					   MAX(idm.insert_type) insert_type ,
					   MAX(idm.enable_identity_insert) enable_identity_insert,
					   MAX(idm.create_destination_table) create_destination_table,
					   REPLACE(MAX(idm.export_folder), ''\'', ''\\'') export_folder,
					   MAX(idm.export_delim) export_delim,
					   MAX(idm.generate_script) generate_script,
					   MAX(idm.main_table) main_table 	
				FROM ' + @ixp_data_mapping + ' idm
				WHERE idm.table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + ' AND idm.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(10))
	
	exec spa_print @sql
	EXEC(@sql)
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		--SET @xml = '
		--		<Root>
		--			<PSRecordset Rules="1" Table="1" Column="counterparty_id" SourceColumn="count.[counterparty_id]" Function="" Aggregation="" Filter=""></PSRecordset>
		--			<PSRecordset Rules="1" Table="1" Column="counterparty_name" SourceColumn="count.[counterparty_name]" Function="" Aggregation="" Filter=""></PSRecordset>
		--			<PSRecordset Rules="1" Table="1" Column="counterparty_desc" SourceColumn="count.[counterparty_desc]" Function="" Aggregation="" Filter=""></PSRecordset>
		--			<PSRecordset Rules="1" Table="1" Column="int_ext_flag" SourceColumn="count.[int_ext_flag]" Function="" Aggregation="" Filter=""></PSRecordset>
		--		</Root>'
				
			--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#ixp_data_mapping') IS NOT NULL
			DROP TABLE #ixp_data_mapping

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT Rules [rules_id],
			   [Table] [table_id],
			   [Column] [column_name],
			   [Alias] [column_alias],
			   [SourceColumn] [source_column],
			   [Function] [column_function],
			   [Aggregation] [column_aggregation],
			   [Filter] [column_filter]
		INTO #ixp_data_mapping
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
			Rules VARCHAR(10),
			[Table] VARCHAR(20),
			[Column] VARCHAR(500),
			[Alias] VARCHAR(500),
			[SourceColumn] VARCHAR(500),
			[Function] VARCHAR(MAX),
			[Aggregation] VARCHAR(50),
			[Filter] VARCHAR(MAX)
		)
		
		IF OBJECT_ID('tempdb..#ixp_check_sql_syntax') IS NOT NULL
			DROP TABLE #ixp_check_sql_syntax
		CREATE TABLE #ixp_check_sql_syntax (column_function VARCHAR(5000) COLLATE DATABASE_DEFAULT, is_error INT, column_name VARCHAR(300) COLLATE DATABASE_DEFAULT)
		
		INSERT INTO #ixp_check_sql_syntax (column_function, column_name)
		SELECT ixm.[column_function], ixm.column_name
		FROM #ixp_data_mapping  ixm
		WHERE ixm.[column_function] <> ''
		
		DECLARE @return_value INT
		DECLARE @column_function VARCHAR(1000)
		DECLARE @sql_syntax VARCHAR(MAX)
		DECLARE @invalid_column_functions VARCHAR(MAX)
		DECLARE @desc VARCHAR(MAX)		
		
		DECLARE sql_syntax_cursor CURSOR LOCAL FOR
		SELECT DISTINCT column_function FROM #ixp_check_sql_syntax
		
		OPEN sql_syntax_cursor
		FETCH NEXT FROM sql_syntax_cursor
		INTO @column_function
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql_syntax = NULL
			
			SET @sql_syntax = 'SELECT ' + @column_function + ' FROM tq'
			
			EXEC @return_value =  spa_check_sql_syntax @sql_syntax
			
			UPDATE #ixp_check_sql_syntax
			SET is_error = @return_value
			WHERE [column_function] = @column_function
			
			FETCH NEXT FROM sql_syntax_cursor
			INTO @column_function
		END		
		CLOSE sql_syntax_cursor
		DEALLOCATE sql_syntax_cursor
		
		IF EXISTS(SELECT 1 FROM #ixp_check_sql_syntax WHERE is_error = 1)
		BEGIN
			SELECT @invalid_column_functions = COALESCE(@invalid_column_functions + ',', '') + column_name
			FROM #ixp_check_sql_syntax 
			WHERE is_error = 1
			
			SET @desc = 'Error in column function for columns :- ' + @invalid_column_functions + ' .' 
			
			EXEC spa_ErrorHandler -1,
				 'Import Export FX',
				 'spa_ixp_data_mapping',
				 'DB Error',
				 @desc,
				 ''
			RETURN
		END
						
		UPDATE #ixp_data_mapping SET [column_function] = NULL WHERE [column_function] = ''
		UPDATE #ixp_data_mapping SET [column_aggregation] = NULL WHERE [column_aggregation] = ''
		UPDATE #ixp_data_mapping SET [column_filter] = NULL WHERE [column_filter] = ''
		
		SET @sql = 'DELETE idm 
					FROM ' + @ixp_data_mapping + ' idm
					INNER JOIN #ixp_data_mapping temp_idm ON temp_idm.rules_id = idm.ixp_rules_id AND temp_idm.table_id = idm.table_id
	    
					INSERT INTO ' + @ixp_data_mapping + '(ixp_rules_id, table_id, column_name, column_alias, source_column, column_function, column_aggregation, column_filter, export_folder, export_delim, generate_script, main_table)
					SELECT [rules_id], [table_id], [column_name], [column_alias], [source_column], [column_function], [column_aggregation], [column_filter] , ''' + @export_folder + ''', ' + ISNULL('''' + @export_delim + '''', 'NULL') + ', ''' + @generate_script + ''', ' + ISNULL(CAST(@main_table  AS VARCHAR(10)), 'NULL') + ' FROM #ixp_data_mapping'
					
		exec spa_print @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0,
             'Import Export FX',
             'spa_ixp_data_mapping',
             'Success',
             'Data successfully saved.',
             @process_id
	END TRY
	BEGIN CATCH
		IF CURSOR_STATUS('local','sql_syntax_cursor') > = -1
		BEGIN
			DEALLOCATE sql_syntax_cursor
		END
		
		EXEC spa_ErrorHandler @@ERROR,
             'Import Export FX',
             'spa_ixp_data_mapping',
             'DB Error',
             'Fail to save data.',
             ''
	END CATCH      
END
