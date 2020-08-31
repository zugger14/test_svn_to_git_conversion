IF OBJECT_ID(N'[dbo].[spa_ixp_export_tables]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_export_tables]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2013-02-05
-- Description: CRUD operations for table ixp_export_tables
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @ixp_export_tables_id INT -- ixp_export_tables_id
-- @ipx_rules_id INT -- ipx_rules_id
-- @process_id  VARCHAR(300) -- process_id
-- @xml_tables
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_ixp_export_tables]
    @flag CHAR(1),
    @ixp_export_tables_id INT = NULL,
    @ipx_rules_id INT = NULL,
    @process_id VARCHAR(300) = NULL,
    @xml TEXT = NULL,
    @import_export_flag CHAR(1) = NULL
AS
SET NOCOUNT ON
DECLARE @sql				VARCHAR(MAX)
DECLARE @ixp_export_tables  VARCHAR(200)
DECLARE @user_name          VARCHAR(50) = dbo.FNADBUser()

SET @ixp_export_tables = dbo.FNAProcessTableName('ixp_export_tables', @user_name, @process_id) 
IF @flag = 'a' -- populates all tables present in rules
BEGIN
    SET @sql = 'SELECT DISTINCT it.ixp_tables_id [table_id],
					   it.ixp_tables_name [table_name],
					   MAX(it.ixp_tables_description) [table_desc],
					   ' + CASE WHEN @ipx_rules_id IS NULL THEN ' 0 ' ELSE ' MAX(ISNULL(iet.sequence_number, 999999)) ' END + ' [seq_no],
					   ' + CASE WHEN @ipx_rules_id IS NULL THEN ' -1 ' WHEN @ipx_rules_id IS NOT NULL THEN ' CASE WHEN ISNULL(iet.ixp_rules_id, -1) = ' +  CAST(@ipx_rules_id AS VARCHAR(10)) + ' THEN iet.ixp_rules_id ELSE -1 END ' END + ' rules_id,
					   MAX(it.import_export_flag) import_export_flag,
					   ' + CASE WHEN @ipx_rules_id IS NULL THEN ' 0 ' ELSE ' iet.repeat_number ' END + ' repeat_number					    
				INTO #temp_export_tables
                FROM ixp_tables it
				LEFT JOIN ixp_export_tables iet ON  iet.table_id = it.ixp_tables_id
				WHERE iet.dependent_table_id IS NULL AND it.ixp_tables_id IS NOT NULL
				GROUP BY it.ixp_tables_id, it.ixp_tables_name, iet.repeat_number, iet.ixp_rules_id 
				ORDER BY [seq_no]
				
				SELECT [table_id],
				       [table_name],
				       [table_desc],
				       [seq_no],
				       MAX(rules_id) rules_id,
				       import_export_flag,
				       repeat_number
				FROM #temp_export_tables
				GROUP BY
				       [table_id],
				       [table_name],
				       [table_desc],
				       [seq_no],
				       import_export_flag,
				       repeat_number'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'b' -- populates all dependent tables present in rules
BEGIN	 
    SET @sql = 'SELECT [dependent_table_id], [table_id],[table_desc],[table_name], MAX([seq_no]) seq_no, MAX(rules_id) rules_id, import_export_flag,repeat_number
				INTO #ixp_export_dependent_table
                FROM (
				SELECT it2.ixp_tables_id [dependent_table_id],
					   it.ixp_tables_id [table_id],
					   MAX(it2.ixp_tables_description) [table_desc],
					   MAX(it2.ixp_tables_name) [table_name],
					   0 [seq_no],
					   -1 rules_id,
					   MAX(it.import_export_flag) import_export_flag,
					   0 repeat_number
				
                FROM ixp_dependent_table idt
				INNER JOIN ixp_table_meta_data itmd ON itmd.ixp_table_meta_data_table_id = idt.parent_table_id
				INNER JOIN ixp_table_meta_data itmd2 ON itmd2.ixp_table_meta_data_table_id = idt.table_id
				INNER JOIN ixp_tables it ON itmd.ixp_tables_id = it.ixp_tables_id
				INNER JOIN ixp_tables it2 ON itmd2.ixp_tables_id = it2.ixp_tables_id
				GROUP BY it.ixp_tables_id, it2.ixp_tables_id
				
				UNION ALL 
				
				SELECT it2.ixp_tables_id [dependent_table_id],
					   it.ixp_tables_id [table_id],
					   MAX(it2.ixp_tables_description) [table_desc],
					   MAX(it2.ixp_tables_name) [table_name],
					   ' + CASE WHEN @ipx_rules_id IS NULL THEN ' 0 ' ELSE ' MAX(ISNULL(iet.dependent_table_order, 0)) ' END + ' [seq_no],
					   ' + CASE WHEN @ipx_rules_id IS NULL THEN ' -1 ' WHEN @ipx_rules_id IS NOT NULL THEN ' CASE WHEN ISNULL(iet.ixp_rules_id, -1) = ' +  CAST(@ipx_rules_id AS VARCHAR(10)) + ' THEN iet.ixp_rules_id ELSE -1 END ' END + ' rules_id,
					   MAX(it.import_export_flag) import_export_flag,
					   ' + CASE WHEN @ipx_rules_id IS NULL THEN ' 0 ' ELSE ' iet.repeat_number ' END + ' repeat_number
                FROM ixp_dependent_table idt
				INNER JOIN ixp_table_meta_data itmd ON itmd.ixp_table_meta_data_table_id = idt.parent_table_id
				INNER JOIN ixp_table_meta_data itmd2 ON itmd2.ixp_table_meta_data_table_id = idt.table_id
				INNER JOIN ixp_tables it ON itmd.ixp_tables_id = it.ixp_tables_id
				INNER JOIN ixp_tables it2 ON itmd2.ixp_tables_id = it2.ixp_tables_id
				INNER JOIN ixp_export_tables iet ON  iet.dependent_table_id = it2.ixp_tables_id AND iet.table_id = it.ixp_tables_id
				WHERE iet.ixp_rules_id = ' + CAST(@ipx_rules_id AS VARCHAR(10)) + '
				GROUP BY it.ixp_tables_id, it2.ixp_tables_id,iet.ixp_rules_id, iet.ixp_export_tables_id, iet.repeat_number
				) a
				GROUP BY [dependent_table_id], [table_id],[table_desc],[table_name],import_export_flag,repeat_number
					
				SELECT [dependent_table_id],
					   [table_id],
				       [table_desc],
				       [table_name],
				       [seq_no],
				       MAX(rules_id) rules_id,
				       import_export_flag,
				       repeat_number
				FROM #ixp_export_dependent_table
				GROUP BY
					   [dependent_table_id],
				       [table_id],
				       [table_name],
				       [table_desc],
				       [seq_no],
				       import_export_flag,
				       repeat_number
				ORDER BY [table_id],[seq_no]'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'x' -- populates all tables present in process table
BEGIN
    SET @sql = 'SELECT iet.table_id [table_id],
				   it.ixp_tables_name [table_name],
				   it.ixp_tables_description [table_desc],
				   iet.sequence_number [seq_no]
				FROM ' + @ixp_export_tables + ' iet
				INNER JOIN ixp_tables it ON  iet.table_id = it.ixp_tables_id
				'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'y' -- populates all dependent tables present in in process table
BEGIN
    SET @sql = ' SELECT iet.dependent_table_id [dependent_table_id],
						iet.table_id [table_id],
						it.ixp_tables_description [table_desc],
						it.ixp_tables_name [table_name],
						iet.sequence_number [seq_no]
				FROM ' + @ixp_export_tables + ' iet
				INNER JOIN ixp_tables it ON  iet.dependent_table_id = it.ixp_tables_id
				'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		--SET @xml = '
		--		<Root>
		--			<PSRecordset RulesId="" TablesId="" TablesOrder="" DepTableId="" DepTableOrder=""></PSRecordset>
		--		</Root>'
				
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#ixp_export_tables') IS NOT NULL
			DROP TABLE #ixp_export_tables

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT [RulesId] [rules_id],
			   [TablesId] [table_id],
			   [TablesOrder] [table_order],
			   [DepTableId] [dependent_table_id],
			   [DepTableOrder] [dependent_table_order],
			   [RepeatNumber] [repeat_number]
			   INTO #ixp_export_tables
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
			[RulesId] VARCHAR(10),
			[TablesId] VARCHAR(20),
			[TablesOrder] VARCHAR(100),
			[DepTableId] VARCHAR(500),
			[DepTableOrder] VARCHAR(50),
			[RepeatNumber] VARCHAR(50)
		)
		
		UPDATE #ixp_export_tables SET [dependent_table_id] = NULL WHERE [dependent_table_id] = ''
		UPDATE #ixp_export_tables SET [dependent_table_order] = NULL WHERE [dependent_table_order] = ''
		
		SET @sql = 'DELETE iet 
					FROM ' + @ixp_export_tables + ' iet
					INNER JOIN #ixp_export_tables temp_iet ON temp_iet.rules_id = iet.ixp_rules_id
	    
					INSERT INTO ' + @ixp_export_tables + '(ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)
					SELECT [rules_id], [table_id], [dependent_table_id], [table_order], [dependent_table_order], [repeat_number] FROM #ixp_export_tables'
		--PRINT @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0,
             'Import Export FX',
             'spa_ixp_data_mapping',
             'Success',
             'Data successfully saved.',
             @process_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR,
             'Import Export FX',
             'spa_ixp_data_mapping',
             'DB Error',
             'Fail to save data.',
             ''
	END CATCH 
END
IF @flag = 'p' -- populates all import tables
BEGIN
    SET @sql = 'SELECT it.ixp_tables_id [table_id],
					   it.ixp_tables_name [Name],
					   MAX(it.ixp_tables_description) [Tables]
				FROM   ixp_tables it
				LEFT JOIN  ixp_export_tables  iet ON  iet.table_id = it.ixp_tables_id
				GROUP BY it.ixp_tables_id, it.ixp_tables_name'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'q' -- populates all dependent tables present for a given import table
BEGIN
	SET @sql = 'SELECT it2.ixp_tables_id [Dependent Table Id],
					   MAX(it2.ixp_tables_name) [Name],
					   MAX(it2.ixp_tables_description) [Dependent Tables]					   
				FROM   ixp_dependent_table  idt
				INNER JOIN ixp_table_meta_data itmd ON itmd.ixp_table_meta_data_table_id = idt.parent_table_id
				INNER JOIN ixp_table_meta_data itmd2 ON itmd2.ixp_table_meta_data_table_id = idt.table_id
				INNER JOIN ixp_tables it ON itmd.ixp_tables_id = it.ixp_tables_id
				INNER JOIN ixp_tables it2 ON itmd2.ixp_tables_id = it2.ixp_tables_id
				WHERE it.ixp_tables_id = ' + CAST(ISNULL(@ixp_export_tables_id, 0) AS VARCHAR(20)) + '
				GROUP BY it2.ixp_tables_id, idt.parent_table_id'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 's'
BEGIN
	SELECT it.ixp_tables_id,
	       it.ixp_tables_description
	FROM   ixp_tables it
END
ELSE IF @flag = 'z' -- select main table for mapping for Export
BEGIN
	DECLARE @export_table INT		
	
	DECLARE @mapping_table TABLE (exportable_table_name VARCHAR(400), table_name VARCHAR(400))
	
	INSERT INTO @mapping_table (exportable_table_name, table_name)
	SELECT 'source_traders', 'ixp_source_trader_template' UNION ALL
	SELECT 'contract_group', 'ixp_contract_template' UNION ALL
	SELECT 'source_minor_location', 'ixp_location_template' UNION ALL
	SELECT 'meter_id', 'ixp_hourly_allocation_data_template' UNION ALL
	SELECT 'contract_group_detail', 'ixp_contract_template' UNION ALL
	SELECT 'source_deal_header', 'ixp_source_deal_template' UNION ALL
	SELECT 'source_deal_detail', 'ixp_source_deal_template' 		
			
	SELECT @export_table = MAX(it.ixp_tables_id)
	FROM ixp_tables  AS it 
	INNER JOIN @mapping_table mt ON mt.table_name = it.ixp_tables_name
	INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = mt.exportable_table_name		
	WHERE iet.ixp_exportable_table_id = @ixp_export_tables_id
	
	IF @export_table IS NULL
	BEGIN
		SELECT @export_table = MAX(it.ixp_tables_id)
		FROM ixp_exportable_table   AS iet
		INNER JOIN ixp_tables  AS it 
		ON  iet.ixp_exportable_table_name = LEFT(REPLACE(it.ixp_tables_name, 'ixp_', ''), LEN(REPLACE(it.ixp_tables_name, 'ixp_', '')) - LEN('_template'))
		AND iet.ixp_exportable_table_id = @ixp_export_tables_id
	END

	EXEC spa_ErrorHandler 0,
             'Import Export FX',
             'spa_ixp_data_mapping',
             'Success',
             'Table selected.',
             @export_table
END
ELSE IF @flag = 'm' -- populates all tables present in process table for new UI
BEGIN
    SET @sql = 'SELECT MAX(iet.table_id) [table_id],
				   MAX(it.ixp_tables_name) [table_name],
				   MAX(it.ixp_tables_description) [table_desc],
				   MAX(iet.sequence_number) [seq_no]
				FROM ' + @ixp_export_tables + ' iet
				INNER JOIN ixp_tables it ON  iet.table_id = it.ixp_tables_id
				GROUP BY iet.sequence_number,iet.table_id 
				'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'n' -- populates all dependent tables present in in process table for new UI
BEGIN
    SET @sql = ' SELECT iet.dependent_table_id [dependent_table_id],
						iet.table_id [table_id],
						it.ixp_tables_description [table_desc],
						it.ixp_tables_name [table_name],
						iet.sequence_number [seq_no]
				FROM ' + @ixp_export_tables + ' iet
				INNER JOIN ixp_tables it ON  iet.dependent_table_id = it.ixp_tables_id
				'
	--PRINT(@sql)
	EXEC(@sql)
END