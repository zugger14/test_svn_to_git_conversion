IF OBJECT_ID(N'[dbo].[spa_adiha_grid]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_adiha_grid]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	A Generic procedure for all operations related to Adiha Grid.

	Parameters:
		@flag			:	Operation flag that decides the action to be performed.
		@grid_name		:	Name of the grid that uniquely identifies the grid itself.
		@grid_id		:	Numeric identifier of the grid, used for filtering the grid data.
		@column_name	:	Name of the column that exists in the Adiha Grid.
		@audit_id		:	Numeric identifier of Audit of grid or its columns.
		@lang_translate:	Translate grid column label - Default translate
*/

CREATE PROCEDURE [dbo].[spa_adiha_grid]
    @flag CHAR(1),
    @grid_name VARCHAR(500) = NULL,
    @grid_id INT = NULL,
    @column_name VARCHAR(200) = NULL,
	@audit_id INT = NULL,
	@lang_translate BIT = 1
AS
 
SET NOCOUNT ON

DECLARE @sql NVARCHAR(4000)
DECLARE @sql_stmt NVARCHAR(MAX)

IF @grid_id IS NULL
BEGIN
	SELECT @grid_id = agd.grid_id FROM adiha_grid_definition agd WHERE agd.grid_name = @grid_name
END		

IF @flag = 's'
BEGIN
	DECLARE @column_name_list       VARCHAR(2000),
	        @column_label_list      NVARCHAR(2000),
	        @column_type_list       VARCHAR(2000),
	        @dropdown_columns       VARCHAR(2000),
	        @select_statement       VARCHAR(5000),
	        @grouping_column        VARCHAR(5000),
	        @grid_type              VARCHAR(5000),
	        @is_hidden              VARCHAR(5000),
	        @column_width           VARCHAR(5000),
	        @sorting_preference     VARCHAR(5000),
	        @edit_permission        CHAR(1) = 'n',
	        @delete_permission      CHAR(1) = 'n',
	        @edit_function_id       VARCHAR(100),
	        @delete_function_id     VARCHAR(100),
			@validation_rule		VARCHAR(2000),
			@column_alignment		VARCHAR(2000),
			@split_at				INT,
			@numeric_columns		VARCHAR(5000),
			@date_columns		VARCHAR(5000),
			@enable_server_side_paging INT,
			@order_seq_direction VARCHAR(500),
			@id_field VARCHAR(50),
			@dependent_field VARCHAR(200),
			@browser_columns		VARCHAR(4000),
			@rounding_values		VARCHAR(4000)

	IF OBJECT_ID('tempdb..#adiha_grid_definition') IS NOT NULL
		DROP TABLE #adiha_grid_definition
	IF OBJECT_ID('tempdb..#adiha_grid_columns_definition') IS NOT NULL
		DROP TABLE #adiha_grid_columns_definition

	CREATE TABLE #adiha_grid_definition(grid_id INT, load_sql VARCHAR(5000) COLLATE DATABASE_DEFAULT, grid_type CHAR(1) COLLATE DATABASE_DEFAULT, grouping_column VARCHAR(500) COLLATE DATABASE_DEFAULT, edit_permission VARCHAR(100) COLLATE DATABASE_DEFAULT, delete_permission VARCHAR(100) COLLATE DATABASE_DEFAULT, split_at INT, enable_server_side_paging INT, dependent_field VARCHAR(200) COLLATE DATABASE_DEFAULT, dependent_query VARCHAR(1000) COLLATE DATABASE_DEFAULT)

	CREATE TABLE #adiha_grid_columns_definition(grid_id INT, column_name VARCHAR(100) COLLATE DATABASE_DEFAULT, column_label VARCHAR(500) COLLATE DATABASE_DEFAULT, field_type VARCHAR(500) COLLATE DATABASE_DEFAULT, sql_string VARCHAR(5000) COLLATE DATABASE_DEFAULT, is_editable CHAR(1) COLLATE DATABASE_DEFAULT, is_required CHAR(1) COLLATE DATABASE_DEFAULT, column_order INT, is_hidden CHAR(1) COLLATE DATABASE_DEFAULT, column_width INT, sorting_preference VARCHAR(20) COLLATE DATABASE_DEFAULT, validation_rule VARCHAR(50) COLLATE DATABASE_DEFAULT, column_alignment VARCHAR(20) COLLATE DATABASE_DEFAULT, rounding VARCHAR(10) COLLATE DATABASE_DEFAULT, order_seq_direction INT)

	DECLARE @grid_def_table VARCHAR(100) = 'adiha_grid_definition', @grid_col_def_table VARCHAR(100) = 'adiha_grid_columns_definition'
	IF @audit_id IS NOT NULL
	BEGIN
		SET @grid_def_table = 'adiha_grid_definition_audit'
		SET @grid_col_def_table = 'adiha_grid_columns_definition_audit'
	END

	SET @sql = '
				INSERT INTO #adiha_grid_definition(grid_id, load_sql, grid_type, grouping_column, edit_permission, delete_permission, split_at, enable_server_side_paging, dependent_field, dependent_query)
				SELECT grid_id, load_sql, grid_type, grouping_column, edit_permission, delete_permission, split_at, enable_server_side_paging, dependent_field, dependent_query
				FROM ' + @grid_def_table + ' WHERE grid_id = ' + CAST(@grid_id AS VARCHAR(100))
	IF @audit_id IS NOT NULL
		SET @sql += ' AND application_ui_template_audit_id = ' + CAST(@audit_id AS VARCHAR(100))
	SET @sql += ' INSERT INTO #adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, column_width, sorting_preference, validation_rule, column_alignment, rounding, order_seq_direction)
				SELECT grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, column_width, sorting_preference, validation_rule, column_alignment, rounding, order_seq_direction
				FROM ' + @grid_col_def_table + ' WHERE grid_id = ' + CAST(@grid_id AS VARCHAR(100))
	IF @audit_id IS NOT NULL
		SET @sql += ' AND application_ui_template_audit_id = ' + CAST(@audit_id AS VARCHAR(100))
	EXEC(@sql)

	SELECT @grouping_column = CASE WHEN ISNULL(agd.grid_type, 'g') = 't' OR ISNULL(agd.grid_type, 'g') = 'a' THEN ISNULL(grouping_column, 'General') ELSE NULL END,
			@sql_stmt = ISNULL(agd.load_sql, agd.dependent_query),
			@grid_type = ISNULL(agd.grid_type, 'g'),
			@edit_function_id = agd.edit_permission,
			@delete_function_id = agd.delete_permission,
			@split_at = agd.split_at,
			@enable_server_side_paging = ISNULL(NULLIF(enable_server_side_paging, ''), 0),
			@dependent_field = NULLIF(agd.dependent_field, '')
	FROM #adiha_grid_definition agd
	WHERE agd.grid_id = @grid_id

	IF @edit_function_id IS NOT NULL
		SET @edit_permission = dbo.FNACheckPermission(@edit_function_id)
	IF @delete_function_id IS NOT NULL
		SET @delete_permission = dbo.FNACheckPermission(@delete_function_id)

	DECLARE @max_seq_no INT
	SELECT @max_seq_no = MAX(agcd.column_order)
	FROM #adiha_grid_columns_definition agcd WHERE agcd.grid_id = @grid_id

	SELECT  @column_name_list = COALESCE(@column_name_list + ',', '') + agcd.column_name,
			@column_label_list = COALESCE(@column_label_list + ',', '') + IIF(@lang_translate = 1, dbo.FNAGetLocaleValue(agcd.column_label), agcd.column_label),
			@column_type_list = COALESCE(@column_type_list + ',', '') + agcd.field_type,
			@select_statement = COALESCE(@select_statement + ',', '') + agcd.column_name + '[' + agcd.column_label + ']',
			@is_hidden	= COALESCE(@is_hidden + ',', '') + CASE WHEN ISNULL(agcd.is_hidden,'n')='n' THEN 'false' ELSE 'true' END,
			@column_width	= COALESCE(@column_width + ',', '') + CAST(agcd.column_width AS VARCHAR(20)),
			@sorting_preference = COALESCE(@sorting_preference + ',', '') + ISNULL(NULLIF(agcd.sorting_preference,''),'str'),
			@validation_rule = 	COALESCE(@validation_rule + ',', '') + ISNULL(agcd.validation_rule,''),
			@column_alignment = COALESCE(@column_alignment + ',', '') + agcd.column_alignment,
			@numeric_columns = CASE
			                        WHEN agcd.field_type IN ('ron', 'ro_no', 'ro_p', 'edn', 'ed_no', 'ed_p') OR agcd.sorting_preference = 'int'
										THEN COALESCE(@numeric_columns + ',', '') + agcd.column_name
			                        ELSE @numeric_columns
			                   END,
			@date_columns = CASE
			                        WHEN agcd.field_type IN ('dhxCalendarA', 'dhxCalendar', 'dhxCalendarDT') OR agcd.sorting_preference = 'date'
										THEN COALESCE(@date_columns + ',', '') + agcd.column_name
			                        ELSE @date_columns
			                   END,
			@rounding_values = CASE
			                        WHEN agcd.field_type IN ('ron', 'ro_no', 'ro_p', 'edn', 'ed_no', 'ed_p')
										THEN COALESCE(@rounding_values + ',', '') + ISNULL(agcd.rounding,'')
			                        ELSE COALESCE(@rounding_values + ',', '')
						 END
	FROM #adiha_grid_columns_definition agcd WHERE agcd.grid_id = @grid_id
	ORDER BY agcd.column_order
	
	SELECT @id_field = column_name
	FROM #adiha_grid_columns_definition agcd WHERE agcd.grid_id = @grid_id AND column_order = 1
	-- Use positive sign for ASC negative sign for DESC for @order_seq_direction
	SELECT @order_seq_direction = COALESCE(@order_seq_direction + ',', '') + column_name + CASE WHEN order_seq_direction < 1 THEN '::DESC' ELSE '::ASC' END 
	FROM #adiha_grid_columns_definition WHERE grid_id = @grid_id 
	AND order_seq_direction IS NOT NULL ORDER BY ABS(order_seq_direction)

	/*Temporary fix to show Date and Time in grid */
	DECLARE @timepart VARCHAR(10) = ''
	IF CHARINDEX('dhxCalendarDT', @column_type_list) <> 0
	BEGIN
		SET @timepart = ' %H:%i'
		SET @column_type_list = REPLACE(@column_type_list,'dhxCalendarDT','dhxCalendarA')
	END
	/*End of Temporary fix to show Date and Time in grid */


	SELECT @dropdown_columns = COALESCE(@dropdown_columns + ',', '') + agcd.column_name
	FROM #adiha_grid_columns_definition agcd WHERE agcd.grid_id = @grid_id AND (agcd.field_type = 'combo' OR agcd.field_type = 'ro_combo')

	SELECT @browser_columns = COALESCE(@browser_columns + ',', '') + agcd.column_name + '->' + agd.grid_name + '->' + CAST(IIF(ISNULL(agcd.allow_multi_select, 'n') = 'y', 1, 0) AS VARCHAR(10))
	FROM adiha_grid_columns_definition agcd
	/*	Changed logic from agd.grid_id to agd.grid_name because, grid_id might be different on another versions
		but grid_name remains the same
	*/
	INNER JOIN adiha_grid_definition agd ON agd.grid_name = agcd.browser_grid_id
	WHERE agcd.grid_id = @grid_id AND agcd.field_type = 'browser'

	IF @sql_stmt IS NULL
	BEGIN
		SET @sql_stmt = 'EXEC(''SELECT ' + @select_statement + ' FROM ' + @grid_name + ''')'
	END

	SELECT @grid_id [grid_id],
	       @grid_name [grid_name],
	       @column_name_list [column_name_list],
	       @column_label_list [column_label_list],
	       @column_type_list [column_type_list],
	       @dropdown_columns [dropdown_columns],
	       @sql_stmt [sql_stmt],
	       @grid_type [grid_type],
	       @grouping_column [grouping_column],
		   @is_hidden [set_visibility],
		   @column_width [column_width],
		   @sorting_preference [sorting_preference],
		   @edit_permission [edit_permission],
		   @delete_permission [delete_permission],
		   @validation_rule [validation_rule],
		   COALESCE(dbo.FNAChangeDateFormat() + @timepart, '%Y-%m-%d') [user_date_format],
		   '%Y-%m-%d' + @timepart [server_date_format],
		   @column_alignment [column_alignment],
		   @split_at [split_at],
		   @numeric_columns [numeric_fields],
		   @date_columns [date_fields],
		   @enable_server_side_paging [enable_server_side_paging],
		   @id_field id_field,
		   @order_seq_direction order_seq_direction,
		   @dependent_field dependent_field,
		   @browser_columns [browser_columns],
		   @rounding_values [rounding_values]
END

IF @flag = 't'
BEGIN
	--DECLARE @column_name VARCHAR(200)
	--DECLARE @grid_id INT
	
	--SET @column_name = 'type_id'
	
	DECLARE @is_required CHAR(1)
	
	SELECT @sql_stmt = agcd.sql_string,
		   @is_required = ISNULL(agcd.is_required, 'n')
	FROM adiha_grid_columns_definition agcd 
	WHERE agcd.column_name = @column_name
	AND agcd.grid_id = @grid_id
	
	IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
		DROP TABLE #temp_combo
	
	CREATE TABLE #temp_combo (
		[value]	VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[text]	NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[state]	VARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable'
	)

	IF @is_required = 'n'
	BEGIN
		INSERT INTO #temp_combo
		SELECT '', '', ''
	END
	
	BEGIN TRY
		INSERT INTO #temp_combo([value],[text],[state])
		EXEC(@sql_stmt)
	END TRY
	BEGIN CATCH
		INSERT INTO #temp_combo([value],[text])
		EXEC (@sql_stmt)
	END CATCH

	DECLARE @xml XML
	DECLARE @param NVARCHAR(100)
	SET @param = N'@xml XML OUTPUT';

	SET @sql = ' SET @xml = (SELECT [value], [text], [state]
				 FROM #temp_combo 
				 FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
	EXECUTE sp_executesql @sql, @param,  @xml = @xml OUTPUT;
	SET @xml = REPLACE(CAST(@xml AS NVARCHAR(MAX)), '"', '\"')
	DECLARE @dropdown_json NVARCHAR(MAX) 
	SET @dropdown_json = dbo.FNAFlattenedJSON(@xml)
	
	IF CHARINDEX('[', @dropdown_json, 0) <= 0
		SET @dropdown_json = '[' + @dropdown_json + ']'
	
	SELECT '{"options":' + @dropdown_json + '}' json_string 
END

IF @flag = 'd'
BEGIN TRY
	BEGIN TRAN
		--DELETE FROM application_ui_template_group WHERE application_ui_template_id=@application_ui_template_id 
		DELETE agcd FROM adiha_grid_columns_definition AS agcd
		INNER JOIN adiha_grid_definition AS agd ON agd.grid_id = agcd.grid_id
		WHERE agd.grid_id = @grid_id
			
		DELETE FROM adiha_grid_definition
		WHERE grid_id = @grid_id
			
		COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN
		IF @@TRANCOUNT > 0 ROLLBACK
		--PRINT 'Delete Failed'
END CATCH