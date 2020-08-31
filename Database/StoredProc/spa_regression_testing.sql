IF OBJECT_ID(N'[testing].[spa_regression_testing]', N'P') IS NOT NULL
    DROP PROCEDURE [testing].[spa_regression_testing]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Procedure that is used for operations with Regression Testing menu.

	Parameters:
		@flag							:	Operation flag which decides the logic to be executed.
		@paramset_hash					:	Unique hash code for the report paramset.
		@regression_rule_id				:	Unique numeric identifier of regression rule.
		@col_names						:	Names of the columns used in Regression module.
		@table_name						:	Names of the table used in Regression module.
		@xml							:	Filter form XML.
		@load_default_filter			:	Specify whether to use default filter or not.
		@process_id						:	Unique Identifier used to create process table for storing benchmark data.
		@regression_module_header_id	:	Regression Module ID.
		@report_param_id				:	Numeric Identifier for Report paramset.
		@del_regression_rule_id			:	Multiple rule id separted with comma for multiple deletion.
		@is_combined_tab				:	Specify whether the json is to be generated for combined tab.
*/

CREATE PROCEDURE [testing].[spa_regression_testing]
	@flag CHAR(1) = NULL,
	@paramset_hash VARCHAR(50) = NULL,
	@regression_rule_id INT = NULL,
	@col_names VARCHAR(MAX) = NULL,
	@table_name VARCHAR(200) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@load_default_filter BIT = 1,
	@process_id VARCHAR(200) = NULL,
	@regression_module_header_id INT = NULL,
	@report_param_id VARCHAR(200) = NULL,
	@del_regression_rule_id VARCHAR(1000) = NULL,
	@is_combined_tab CHAR(1) = NULL
AS
SET NOCOUNT ON

/********** DEBUG SECTION **************
DECLARE @flag CHAR(1) = NULL,
	@paramset_hash VARCHAR(50) = NULL,
	@regression_rule_id INT = NULL,
	@col_names VARCHAR(MAX) = NULL,
	@table_name VARCHAR(200) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@load_default_filter BIT = 1,
	@process_id VARCHAR(200) = NULL,
	@regression_module_header_id INT = NULL,
	@report_param_id VARCHAR(200) = NULL,
	@del_regression_rule_id VARCHAR(1000) = NULL,
	@is_combined_tab CHAR(1) = NULL
	
	SELECT  @flag='h', 
            @regression_module_header_id=8,
            @report_param_id='30192,30334,30335,30425,30605,30619,30633',
            @load_default_filter=0,
			@is_combined_tab='y'
--*/
DECLARE @sql                  VARCHAR(MAX) = NULL,
	    @regression_group     INT = NULL,
	    @param_hash           VARCHAR(50),
	    @idoc                 INT,
		@physical_table_name VARCHAR(200), 
		@regg_table_name VARCHAR(200)
	
DECLARE @has_benchmark_table CHAR(1) = 'n'

IF @flag = 'g'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT,
	        @xml
	    
	SELECT @regression_group = regression_group,
	        @param_hash = paramset_hash
	FROM   OPENXML(@idoc, 'FormXML', 1)
	        WITH (regression_group INT, paramset_hash VARCHAR(50))
	    
	SET @sql = '
		SELECT rr.regression_rule_id,
			ISNULL(sdv.code, ''Uncategorized'') [regression_group],
			rr.rule_name,
			rr.[description],
			rr.[filter],
			CASE WHEN system_defined = ''y'' THEN 1 ELSE 0 END [system_defined],
			CASE WHEN system_defined = ''y'' THEN ''Yes'' ELSE ''No'' END [is_system_defined]
		FROM regression_rule rr
		LEFT JOIN static_data_value AS sdv ON rr.regression_group = sdv.value_id
		WHERE 1 = 1 
	'
	    
	IF @regression_group IS NOT NULL
	    SET @sql += ' AND rr.regression_group = ' + CAST(@regression_group AS VARCHAR) + ''
	    
	EXEC (@sql)
END
ELSE 
IF @flag = 'k'
BEGIN
	SELECT stuff((
		SELECT DISTINCT ',' + ISNULL(NULLIF(CAST(rp.report_paramset_id AS VARCHAR), '-1'), '')
		FROM regression_module_header rmh
		INNER JOIN regression_module_detail rmd ON rmh.regression_module_header_id = rmd.regression_module_header_id
		INNER JOIN report_paramset rp ON rp.paramset_hash = rmd.regg_rpt_paramset_hash
		WHERE rmh.regression_module_header_id = @regression_module_header_id
		FOR XML PATH
			,type
		).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '') AS paramset_id
END
ELSE 
IF @flag = 'i'
BEGIN
	SELECT @flag flag,
	        @regression_rule_id regression_rule_id
END
	
IF @flag = 'x'
BEGIN
	SELECT DISTINCT rmd.table_name [table_name],
		rmd.unique_columns 
			+ IIF(NULLIF(rmd.compare_columns, '') IS NULL, '', ',' + rmd.compare_columns) 
			+ IIF(NULLIF(rmd.display_columns, '') IS NULL, '', ',' + rmd.display_columns) [columns],
	        REPLACE(REPLACE(rmd.unique_columns,'[',''),']','') 
			+ IIF(NULLIF(rmd.compare_columns, '') IS NULL, '', ',' + REPLACE(REPLACE(rmd.compare_columns,'[',''),']','')) 
			+ IIF(NULLIF(rmd.display_columns, '') IS NULL, '', ',' + REPLACE(REPLACE(rmd.display_columns,']',''),'[','')) [display_columns]
	FROM   regression_rule AS rr
	        INNER JOIN regression_module_header AS rmh
	            ON  rr.regression_module_header_id = rmh.regression_module_header_id
	        INNER JOIN regression_module_detail AS rmd
	            ON  rmd.regression_module_header_id = rmh.regression_module_header_id
	WHERE  rmd.table_name IS NOT NULL AND rr.regression_rule_id = @regression_rule_id
END
	
IF @flag = 'y'
BEGIN
	IF @process_id IS NULL 
		SET @process_id = dbo.FNAGetNewID()
		
	DECLARE @benchmark_process_table VARCHAR(500) = dbo.FNAProcessTableName('benchmark_data_', dbo.FNADBUser(), @process_id)
	 
	IF OBJECT_ID('testing.' + QUOTENAME('regg_' + CAST(@regression_rule_id AS VARCHAR) + '_' + @table_name)) IS NOT NULL
	BEGIN
		SET @has_benchmark_table = 'y'

		DECLARE @process_table_col_names NVARCHAR(MAX) = ''

		SELECT @process_table_col_names += CONCAT(item, ' AS ', REPLACE(item, ' ', '_')) + ', '
		FROM dbo.fnasplit(@col_names, ',')

		-- Remove Last comma
		SET @process_table_col_names = LEFT(RTRIM(@process_table_col_names), LEN(RTRIM(@process_table_col_names)) -1)

		SET @col_names = REPLACE(@col_names, ' ', '_')

		SET @sql = '
			SELECT ' + @process_table_col_names + '
			INTO ' + @benchmark_process_table + '
			FROM testing.' + QUOTENAME('regg_' + CAST(@regression_rule_id AS VARCHAR) + '_' + @table_name)

		EXEC(@sql)

	END
	SELECT @benchmark_process_table [process_table], @col_names [col_headers], @table_name [table_name], @has_benchmark_table [benchmark_table]
END

IF @flag = 'h'
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	DECLARE @process_table_name VARCHAR(200) = dbo.FNAProcessTableName('form_data', dbo.FNADBUser(), @process_id)
		 
	IF OBJECT_ID(N'tempdb..#temp_ui_final_json') IS NOT NULL
		DROP TABLE #temp_ui_final_json
	IF OBJECT_ID('tempdb..#final_output') IS NOT NULL
		DROP TABLE #final_output

	CREATE TABLE #temp_ui_final_json(
		paramset_id VARCHAR(800) COLLATE DATABASE_DEFAULT,
		tab_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		tab_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		tab_json VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		form_json VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		process_id VARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	DECLARE @paramset_id VARCHAR(200), @tab_id VARCHAR(200), @tab_name VARCHAR(200)
	DECLARE @call_from VARCHAR(100)
	SET @call_from = 'regression_testing' + (CASE WHEN ISNULL(@load_default_filter, 0) = 1 THEN '_load_default_filter' ELSE '' END)

	--SELECT @report_param_id, 'combined_filter', 'Combined Filter'
	--UNION ALL
	--SELECT 
	--	CAST(rp.report_paramset_id AS VARCHAR(20)) AS paramset_id, 
	--	CAST(rp.report_paramset_id AS VARCHAR(20)) + '_' + LOWER(REPLACE(RTRIM(rp.name), ' ','_')) [tab_id], 
	--	rp.name [tab_name]
	--FROM dbo.SplitCommaSeperatedValues(@report_param_id) scsv
	--INNER JOIN report_paramset rp ON scsv.item = rp.report_paramset_id
	--RETURN
		
	--DECLARE paramset_cursor CURSOR FOR
	--SELECT @report_param_id, 'combined_filter', 'Combined Filter'
	--UNION ALL
	--SELECT 
	--	NULL AS paramset_id,  --CAST(rp.report_paramset_id AS VARCHAR(20)) AS paramset_id, 
	--	CAST(rp.report_paramset_id AS VARCHAR(20)) + '_' + LOWER(REPLACE(RTRIM(rp.name), ' ','_')) [tab_id], 
	--	rp.name [tab_name]
	--FROM dbo.SplitCommaSeperatedValues(@report_param_id) scsv
	--INNER JOIN report_paramset rp ON scsv.item = rp.report_paramset_id
		
	--OPEN paramset_cursor
	--FETCH NEXT FROM paramset_cursor INTO @paramset_id, @tab_id,	@tab_name
	--WHILE (@@FETCH_STATUS = 0)
	--BEGIN

	IF @is_combined_tab = 'y'
	BEGIN
		SELECT @paramset_id = @report_param_id, 
			@tab_id = 'combined_filter', 
			@tab_name = 'Combined Filter'
	END
	ELSE
	BEGIN
		SELECT @paramset_id = CAST(rp.report_paramset_id AS VARCHAR(20)),
			@tab_id = CAST(rp.report_paramset_id AS VARCHAR(20)) + '_' + LOWER(REPLACE(RTRIM(rp.name), ' ','_')),
			@tab_name = rp.[name]
		FROM dbo.SplitCommaSeperatedValues(@report_param_id) scsv
		INNER JOIN report_paramset rp ON scsv.item = rp.report_paramset_id
	END
	
	EXEC spa_view_report @flag='c', @report_param_id = @paramset_id, @batch_process_id = @process_id, @call_from = @call_from
	--EXEC spa_view_report @flag='c', @report_param_id = @paramset_id, @batch_process_id = @process_id, @call_from = @call_from

	SET @sql = '
		INSERT INTO #temp_ui_final_json (paramset_id, tab_id, tab_name, tab_json, form_json, process_id)
		SELECT  ''' + @paramset_id + ''',''' + @tab_id + ''',''' +  @tab_name + ''',''{"id": "' + @tab_id + '", "text": "' + @tab_name + '"' +
		CASE  
			WHEN @tab_id = 'combined_filter' 
			THEN     + ', "active": true' 
			ELSE   '' 
		END 
		+ '}'',
		form_json,
		layout_pattern FROM  ' + @process_table_name 

	EXEC(@sql)
			
	EXEC('DELETE FROM ' + @process_table_name)

	--	FETCH NEXT FROM paramset_cursor INTO @paramset_id, @tab_id, @tab_name
	--END
	--CLOSE paramset_cursor
	--DEALLOCATE paramset_cursor

	IF @is_combined_tab = 'y'
	BEGIN
		SELECT * 
		INTO #final_output
		FROM #temp_ui_final_json tj
		UNION ALL
		SELECT 
			CAST(rp.report_paramset_id AS VARCHAR(20)) AS paramset_id, 
			CAST(rp.report_paramset_id AS VARCHAR(20)) + '_' + LOWER(REPLACE(RTRIM(rp.[name]), ' ','_')) [tab_id], 
			rp.[name] [tab_name],
			'{"id": "' + CAST(rp.report_paramset_id AS VARCHAR(20)) + '_' + LOWER(REPLACE(RTRIM(rp.[name]), ' ','_')) + '", "text": "' + rp.[name] + '", "active": false}' [tab_json],
			'[{"type":"settings","position":"label-top"}]' [form_json],
			@process_id process_id
		FROM dbo.SplitCommaSeperatedValues(@report_param_id) scsv
		INNER JOIN report_paramset rp ON scsv.item = rp.report_paramset_id

		SELECT *
		FROM #final_output
		ORDER BY LEN(paramset_id) DESC --Added ORDER BY TO SET combined_tab always at first on UI
	END
	ELSE
		SELECT * FROM #temp_ui_final_json tj
	
	EXEC('DROP TABLE ' + @process_table_name)
END

IF @flag = 'd'
BEGIN
	IF OBJECT_ID(N'tempdb..#temp_ui_reggression_table_list') IS NOT NULL
		DROP TABLE #temp_ui_reggression_table_list


	CREATE TABLE #temp_ui_reggression_table_list (table_name VARCHAR(300) COLLATE DATABASE_DEFAULT, rule_id INT)

	INSERT INTO #temp_ui_reggression_table_list
	SELECT rmd.table_name, rr.regression_rule_id
	FROM regression_rule rr
	INNER JOIN regression_module_detail rmd ON rr.regression_module_header_id = rmd.regression_module_header_id
	INNER JOIN dbo.FNASplit(@del_regression_rule_id, ',') di ON di.item = rr.regression_rule_id
		
	BEGIN TRY
		BEGIN TRAN
		DECLARE @reg_rule_id INT

		DECLARE cursor_benchmark_table CURSOR
		FOR
		SELECT table_name, rule_id
		FROM #temp_ui_reggression_table_list

		OPEN cursor_benchmark_table

		FETCH NEXT
		FROM cursor_benchmark_table
		INTO @physical_table_name, @reg_rule_id

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @regg_table_name = 'testing.' + QUOTENAME('regg_' + CAST(@reg_rule_id AS VARCHAR(20)) + '_' + @physical_table_name)
			--select @regg_table_name
			IF OBJECT_ID(@regg_table_name) IS NOT NULL
				EXEC ('DROP TABLE ' + @regg_table_name)
				
			FETCH NEXT
			FROM cursor_benchmark_table INTO 
			@physical_table_name, @reg_rule_id
		END

		CLOSE cursor_benchmark_table

		DEALLOCATE cursor_benchmark_table

		DELETE rr
		FROM regression_rule rr
		INNER JOIN dbo.FNASplit(@del_regression_rule_id, ',') di ON di.item = rr.regression_rule_id

		EXEC spa_ErrorHandler 0
			,'Regression Testing'
			,'spa_regression_testing'
			,'Success'
			,'Change have been saved successfully.'
			,@del_regression_rule_id

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXEC spa_ErrorHandler - 1
			,'Regression Testing'
			,'spa_regression_module'
			,'Error'
			,'ERROR'
			,''
	END CATCH
END

-- Copy the Regression Rule.
IF @flag = 'c'
BEGIN
	INSERT INTO regression_rule (regression_group, rule_name, [description], [filter], regression_module_header_id, system_defined)
	SELECT regression_group, rule_name, [description], [filter], regression_module_header_id, system_defined
	FROM regression_rule
	WHERE regression_rule_id = @regression_rule_id

	DECLARE @new_id VARCHAR(100) = SCOPE_IDENTITY()

	UPDATE regression_rule
	SET rule_name = CONCAT('Copy of ', rule_name, ' ', @new_id),
		[description] = [description]
	WHERE regression_rule_id = @new_id

	EXEC spa_ErrorHandler 0
		,'Regression Testing'
		,'spa_regression_testing'
		,'Success'
		,'Change have been saved successfully.'
		,@regression_rule_id
END

GO
