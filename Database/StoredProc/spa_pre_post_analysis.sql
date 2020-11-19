IF OBJECT_ID('[testing].[spa_pre_post_analysis]') IS NOT NULL
	DROP PROC [testing].[spa_pre_post_analysis]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/** 
	Procedure that is used to run pre post analysis of Regression Testing.

	Parameters:
		@regression_rule_id			:	Unique identifier for a regression rule.
		@output_process_id			:	Unique Identifier used to represent the stored data.
		@batch_process_id			:	Unique Identifier for Batch.
		@batch_report_param			:	Parameters sent for Batch.
		@drop_benchmark_table		:	Specify whether to drop benchmark table and recreate.
		@floating_tolerance_value	:	Tolerance value used to specify what differences can be ignored.
*/

CREATE PROC [testing].[spa_pre_post_analysis] @flag VARCHAR(1)
	,@regression_rule_id VARCHAR(500) = NULL
	,@output_process_id VARCHAR(50) = NULL --OUTPUT 
	,@batch_process_id VARCHAR(50) = NULL
	,@batch_report_param VARCHAR(1000) = NULL
	,@drop_benchmark_table BIT = 0
	,@floating_tolerance_value NUMERIC(30,20) = 0.00001
	--,@regression_group VARCHAR(100) = NULL
AS
SET NOCOUNT ON

/**** Debug Section ********
DECLARE @flag VARCHAR(1)
	,@regression_rule_id VARCHAR(500) = NULL
	,@output_process_id VARCHAR(50) = NULL --OUTPUT 
	,@batch_process_id VARCHAR(50) = NULL
	,@batch_report_param VARCHAR(1000) = NULL
	,@drop_benchmark_table BIT = 0
	,@floating_tolerance_value NUMERIC(30, 20) = 0.00001
	--,@regression_group VARCHAR(100) = NULL

	--select * from regression_rule

	--select @flag='p', @regression_rule_id=1004,@batch_process_id='FB02B1D7_9B3E_4791_A4D3_4DBA352B2FBB_5b3e7b70856e8',@batch_report_param='spa_pre_post_analysis @flag=''p'', @regression_rule_id=1004'
	--SELECT @flag='b', @regression_rule_id='5', @drop_benchmark_table=0
	--SELECT @flag='p',@floating_tolerance_value=0.0001 ,@regression_rule_id='31'

	--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON');
	--SET CONTEXT_INFO @contextinfo;
--*******************************************/

SET @regression_rule_id = NULLIF(@regression_rule_id, '')
--SET @regression_group = NULLIF(@regression_group, '')

DECLARE @filter_criteria VARCHAR(MAX)
	,@report_paramset_hash VARCHAR(50)
	,@report_page_id INT
	,@component_id INT
	,@paramset_id INT
	,@error_code CHAR(1) = 's'
	,@url VARCHAR(500)
	,@desc VARCHAR(8000)
	,@db_schema_name VARCHAR(50) = 'testing.'
	,@error_num INT
	,@unique_columns VARCHAR(MAX)
	,@compare_columns VARCHAR(MAX)
	,@sql_group_by_condition VARCHAR(MAX)
	,@sql VARCHAR(MAX)
	,@sql_join_condition VARCHAR(MAX)
	,@sql_where_conditions VARCHAR(MAX)
	,@data_missmatch BIT = 0
	,@tbl_name VARCHAR(200)
	,@process_table_name VARCHAR(200)
	,@tbl1 VARCHAR(500)
	--,@report_tbl1 VARCHAR(500)
	,@report_batch_table VARCHAR(500) = NULL
	,@select_unique_columns VARCHAR(MAX)
	,@select_compare_columns VARCHAR(MAX)
	,@having_columns VARCHAR(MAX)
	,@display_column_name VARCHAR(MAX)
	,@display_columns VARCHAR(MAX)
	,@sequence_order VARCHAR(MAX)
	,@current_date_time DATETIME = GETDATE()
	,@description VARCHAR(5000) = ''
	,@runtime_user VARCHAR(50) = NULL
	,@process_id VARCHAR(50) = NULL
	,@rule_name VARCHAR(100)
	,@grouped_rule_name VARCHAR(5000)
	,@error_description VARCHAR(100)
	,@module_id INT = NULL
	,@regression_module_header_id INT
	,@data_order VARCHAR(100)
	,@report_process_id VARCHAR(50)
	,@have_benchmarktable_for_postregg BIT = 1
	,@data_exists_for_postregg BIT = 1
	,@regression_group_id INT
	,@report_name VARCHAR(200)
	,@columns_names_withobj VARCHAR(MAX)
	,@column_names VARCHAR(MAX)
	,@sql1 VARCHAR(MAX)
	,@sql2 VARCHAR(MAX)
	,@sql3 VARCHAR(MAX)
	,@time_zone VARCHAR(10)
	,@rounding_value CHAR(1) = '5'
	,@floating_point_diff VARCHAR(MAX)
	,@regression_module_detail_id INT
	--,@tolerance_value NUMERIC(38, 20)

SET @process_id = ISNULL(@output_process_id, dbo.FNAGetNewID())

SELECT @time_zone = var_value --26
FROM dbo.adiha_default_codes_values (NOLOCK)
WHERE instance_no = 1
	AND default_code_id = 36
	AND seq_no = 1

IF NULLIF(@runtime_user, '') IS NULL
	SET @runtime_user = dbo.FNADBUser()

IF OBJECT_ID('tempdb..#unique_columns') IS NOT NULL
	DROP TABLE #unique_columns

IF OBJECT_ID('tempdb..#compare_columns') IS NOT NULL
	DROP TABLE #compare_columns

IF OBJECT_ID('tempdb..#pre_post_calc_status') IS NOT NULL
	DROP TABLE #pre_post_calc_status

IF OBJECT_ID('tempdb..#data_validation_error') IS NOT NULL
	DROP TABLE #data_validation_error

IF OBJECT_ID('tempdb..#temp_selected_rule_list') IS NOT NULL
	DROP TABLE #temp_selected_rule_list

CREATE TABLE #pre_post_calc_status (
	process_id VARCHAR(100) COLLATE DATABASE_DEFAULT
	,error_code VARCHAR(50) COLLATE DATABASE_DEFAULT
	,module VARCHAR(100) COLLATE DATABASE_DEFAULT
	,[source] VARCHAR(100) COLLATE DATABASE_DEFAULT
	,[type] VARCHAR(100) COLLATE DATABASE_DEFAULT
	,[description] VARCHAR(1000) COLLATE DATABASE_DEFAULT
	,[benchmark_date] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[rules_name] VARCHAR(100) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #data_validation_error (
	regg_type VARCHAR(100) COLLATE DATABASE_DEFAULT
	,table_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	--,column_name VARCHAR(50) COLLATE DATABASE_DEFAULT
	,validation_message VARCHAR(8000) COLLATE DATABASE_DEFAULT
	,recommendation VARCHAR(8000) COLLATE DATABASE_DEFAULT
)

IF @flag IN ('b' ,'p', 'v')
BEGIN
	IF @flag IN('p', 'b')
	BEGIN
		SELECT @description = COALESCE(NULLIF(@description, '') + ',', '') + module_name,
			@grouped_rule_name = COALESCE(NULLIF(@grouped_rule_name, '') + ',', '') + rule_name
		FROM regression_module_header rmh
		INNER JOIN regression_rule rr ON rr.regression_module_header_id = rmh.regression_module_header_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@regression_rule_id) csrrid ON rr.regression_rule_id = csrrid.item
	END
	
	DECLARE @regg_type INT
	DECLARE @rmd_paramset_hash VARCHAR(200), @rule_id INT

	SELECT ROW_NUMBER() OVER (ORDER BY rmd.regg_type DESC) AS r_id
		, rmd.regg_type [regg_type]
		, rr.[filter] [filter]
		, rp.page_id [page_id]
		, rp.report_paramset_id [report_paramset_id]
		, rmd.regression_module_header_id [regression_module_header_id]
		, rmd.regg_rpt_paramset_hash [regg_rpt_paramset_hash]
		, rr.regression_rule_id [regression_rule_id]
		, rr.rule_name [rule_name]
		, ISNULL(rp.[name]
		, MAX(rmd.table_name)) [report_name]
		, rmh.process_exec_order [process_exec_order]
		, MAX(rmd.regression_module_detail_id) [regression_module_detail_id]
	INTO #temp_selected_rule_list
	FROM regression_module_header rmh
	INNER JOIN regression_module_detail rmd ON rmh.regression_module_header_id = rmd.regression_module_header_id
	INNER JOIN regression_rule rr ON rr.regression_module_header_id = rmd.regression_module_header_id
	LEFT JOIN report_paramset rp ON rp.paramset_hash = rmd.regg_rpt_paramset_hash
	INNER JOIN dbo.SplitCommaSeperatedValues(@regression_rule_id) csrrid ON rr.regression_rule_id = csrrid.item
	GROUP BY rmd.regg_type
		,rr.[filter]
		,rp.page_id
		,rp.report_paramset_id
		,rmd.regression_module_header_id
		,rmd.regg_rpt_paramset_hash
		,rr.regression_group
		,rr.regression_rule_id
		,rr.rule_name
		,rmh.process_exec_order
		,rp.[name]

	--Validation for missing report mapped on regression module detail table
	IF @flag IN('p', 'b')
	BEGIN
		INSERT INTO source_system_data_import_status (process_id, code, module, [source], [type], [description], recommendation, rules_name)
		SELECT @process_id
			,'<b><font color="red">Setup Error</font></b>'
			,'Pre/Post Test'
			,[report_name]
			,'<b><font color="red">Data Error</font></b>'
			,'Report not found.'
			,'Please verify if report exists or not.'
			,rule_name
		FROM #temp_selected_rule_list
		WHERE report_paramset_id IS NULL
	END

	IF CURSOR_STATUS('global','paramset_hash') >= -1
	BEGIN
		IF CURSOR_STATUS('global','paramset_hash') > -1
		BEGIN
			CLOSE paramset_hash
		END
		DEALLOCATE paramset_hash
	END
	
	DECLARE paramset_hash CURSOR
	FOR
	SELECT regg_type
		, [filter]
		, page_id
		, report_paramset_id
		, regression_module_header_id
		, regg_rpt_paramset_hash
		, regression_rule_id
		, rule_name
		, [regression_module_detail_id]
		--, process_exec_order
	FROM #temp_selected_rule_list
	WHERE report_paramset_id IS NOT NULL
	ORDER BY process_exec_order, r_id -- to run calculation first

	OPEN paramset_hash

	FETCH NEXT FROM paramset_hash
	INTO @regg_type
		,@filter_criteria
		,@report_page_id
		,@paramset_id
		,@regression_module_header_id
		,@rmd_paramset_hash
		,@rule_id
		,@rule_name
		,@regression_module_detail_id

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF @regg_type = 109701 -- Report manage report 
			SET @report_process_id = dbo.FNAGetNewID()

		SET @report_batch_table = NULL

		IF @flag IN('b', 'p') 
		BEGIN
			/**
				109702 --type calculation of report
				109701 --type Report manager report
			**/
			IF @regg_type IN (109702, 109701) --AND @rmd_paramset_hash IS NOT NULL-- type calculation or report
			BEGIN
				--	SET @filter_criteria = @filter_criteria + ',batch_process_id=' + @process_id
				SELECT @component_id = COALESCE(rpt.report_page_tablix_id, rpc.report_page_chart_id, rpg.report_page_gauge_id)
				FROM (
					VALUES (1)
				) dummy_tbl(dummy_col) --generate a row to ensure data is returned if matched in any component (tablix, chart, gauge)
				LEFT JOIN report_page_tablix rpt ON rpt.page_id = @report_page_id
				LEFT JOIN report_page_chart rpc ON rpc.page_id = @report_page_id
				LEFT JOIN report_page_gauge rpg ON rpg.page_id = @report_page_id
			
				SET @sql = 'EXEC spa_rfx_run_sql @paramset_id = ' + CAST(@paramset_id AS VARCHAR(20)) + '
					, @component_id = ' + CAST(@component_id AS VARCHAR(20)) + '
					, @criteria = ''' + @filter_criteria + '''
					, @display_type = ''t''
					, @runtime_user = ''' + @runtime_user + '''
					, @is_refresh = ''0'''

				IF @regg_type = 109701 -- Report manage report 
					SET @sql += ', @batch_process_id = ''' + @report_process_id + ''''
				
				-- Note the time before running the report.
				DECLARE @reg_track_start_time DATETIME = GETDATE()
				-- PRINT @sql
				EXEC (@sql)
				-- Note the time after successfully running the report.
				DECLARE @reg_track_end_time DATETIME = GETDATE()

				-- Logic that sets old benchmark as NULL, so that currently running benchmark will set as latest benchmark.
				IF @flag = 'b'
				BEGIN
					DELETE rtt
					-- SELECT *
					FROM regression_time_tracker rtt
					WHERE is_benchmark = 1
						AND module_detail_id = @regression_module_detail_id
						AND process_id <> @process_id
				END

				INSERT INTO regression_time_tracker (rule_id, module_detail_id, start_time, end_time, process_id, is_benchmark)
				SELECT @rule_id,
					@regression_module_detail_id,
					@reg_track_start_time,
					@reg_track_end_time,
					@process_id,
					CASE WHEN @flag = 'b' THEN 1 ELSE 0 END

				IF @regg_type = 109701 -- Report manage report 
				BEGIN
					SET @report_batch_table = dbo.FNAProcessTableName('batch_report', @runtime_user, @report_process_id)
					IF COL_LENGTH(@report_batch_table, 'row_id') IS NOT NULL
						EXEC ('ALTER TABLE ' + @report_batch_table + ' DROP COLUMN row_id')
				END
			END
		END
		
		IF CURSOR_STATUS('global','table_names_cursor') >= -1
		BEGIN
			IF CURSOR_STATUS('global','table_names_cursor') > -1
			BEGIN
				CLOSE table_names_cursor
			END
			DEALLOCATE table_names_cursor
		END

		-- SELECT @rmd_paramset_hash
		DECLARE table_names_cursor CURSOR
		FOR
		SELECT rmd.unique_columns
			,rmd.compare_columns
			,rmd.table_name
			,rmd.display_columns
			,rmd.data_order
			,rmd.regg_rpt_paramset_hash
			,rpms.[name]
		FROM [dbo].[regression_module_detail] rmd
		LEFT JOIN report_paramset rpms ON rpms.paramset_hash = rmd.regg_rpt_paramset_hash
		LEFT JOIN report_page rpg ON rpg.report_page_id = rpms.page_id
		--LEFT JOIN report r ON r.report_id = rpg.report_id
		WHERE rmd.regression_module_header_id = @regression_module_header_id
			AND rmd.regg_type = @regg_type
			AND rmd.regg_rpt_paramset_hash = @rmd_paramset_hash
		ORDER BY process_exec_order

		OPEN table_names_cursor

		FETCH NEXT
		FROM table_names_cursor
		INTO @unique_columns
			,@compare_columns
			,@tbl_name
			,@display_columns
			,@data_order
			,@report_paramset_hash
			,@report_name
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			TRUNCATE TABLE #pre_post_calc_status
			TRUNCATE TABLE #data_validation_error

			SET @sql_join_condition = NULL
			SET @sql_where_conditions = NULL
			SET @sql_group_by_condition = NULL
			SET @select_unique_columns = NULL
			SET @select_compare_columns = NULL
			SET @display_column_name = NULL
			SET @having_columns = NULL
			SET @floating_point_diff = NULL

			-- Table for regression are stored in 'testing' schema. Eg: testing.regg_<rule_id>_<table_name>
			SET @process_table_name = @db_schema_name + QUOTENAME('regg_' + CAST(@rule_id AS VARCHAR(20)) + '_' + @tbl_name)
			SET @tbl1 = dbo.FNAProcessTableName(@tbl_name, @runtime_user, @process_id)
			SET @tbl1 = 'adiha_process.dbo.' + QUOTENAME(REPLACE(@rule_name + '->' + @tbl1, 'adiha_process.dbo.', ''))
			
			--PRINT @tbl1
			--SET @report_tbl1 = dbo.FNAProcessTableName(REPLACE(LTRIM(RTRIM(@report_name)), ' ', '_'), @runtime_user, @process_id)
			--PRINT @report_name

			IF @flag IN('b', 'p')
			BEGIN
				IF OBJECT_ID(@process_table_name) IS NOT NULL AND @drop_benchmark_table = 1 AND @flag = 'b'
				BEGIN
					EXEC('DROP TABLE ' + @process_table_name)
				END

				SET @column_names = IIF(ISNULL(@unique_columns, '') = '', '', @unique_columns) +
						IIF(ISNULL(@compare_columns, '') = '', '', IIF(ISNULL(@unique_columns, '') = '', '', ',') + @compare_columns) +
						IIF(ISNULL(@display_columns, '') = '', '', IIF(ISNULL(@compare_columns, '') = '', '', ',') + @display_columns)

				DECLARE @col_nm VARCHAR(MAX) = ''

				SELECT @col_nm = @col_nm + a.item + ', '
				FROM (
					SELECT DISTINCT item
					FROM dbo.FNASplit(@column_names, ',')
				) a

				SET @col_nm = LEFT(RTRIM(@col_nm), LEN(@col_nm) - 1)

				SET @column_names = @col_nm

				--SELECT '' [OBJECT_ID(@report_batch_table)], OBJECT_ID(@report_batch_table), @regg_type

				-- Validation For Error While Running Report
				IF OBJECT_ID(@report_batch_table) IS NULL AND  @regg_type = 109701 --type Report manager report  OBJECT_ID(@report_batch_table) IS NULL always
				BEGIN
					SET @sql = '
						INSERT INTO #data_validation_error
						SELECT ' + 
						CASE 
							WHEN @regg_type = 109701
								THEN '''Report''' + ',' + ''''+ @report_name + ''''
							 ELSE '''Table''' + ',' + '''' + @tbl_name + ''''
						END
						+ ',''Error while running the report.'',''Verify report configuration.''
					'
					--PRINT @sql
					EXEC(@sql)
				END

				--validation for column mission on physical table and benchmark table
				SET @sql = '
					IF NOT EXISTS(
						SELECT 1
						FROM #data_validation_error
						WHERE table_name = ''' + CASE WHEN  @regg_type = 109701 THEN @report_name ELSE @tbl_name END + '''
					)
					BEGIN
						INSERT INTO #data_validation_error
						SELECT ' +
							CASE
								WHEN  @regg_type = 109701 THEN '''Report''' + ',' + '''' + @report_name + ''''
								ELSE '''Table''' + ',' + '''' + @tbl_name + ''''
							END + ',
							''Column <b><font color="red">'' + config_columns.item + ''</font></b> is missing in the main table.'',
							''Verify regression configuration.''
						FROM dbo.SplitCommaSeperatedValues(''' + @column_names + ''') config_columns
						LEFT JOIN (
							SELECT c.name
							FROM ' + 
								CASE WHEN  @regg_type = 109701 THEN 'adiha_process.sys.tables  t WITH(NOLOCK)'
									ELSE 'sys.tables t'
								END + ' 
							INNER JOIN ' +
								CASE WHEN @regg_type = 109701 THEN ' adiha_process.sys.columns  c WITH(NOLOCK)'
									ELSE ' sys.columns c'
								END  + '  ON t.object_id = c.object_id
							WHERE t.name = REPLACE('''
							+ ISNULL(
								CASE
									WHEN @regg_type = 109701 THEN @report_batch_table
									ELSE @tbl_name
								END , '') +
							''',''adiha_process.dbo.'', '''')
						) a ON QUOTENAME(a.name) = config_columns.item
						WHERE a.name IS NULL
				'

				-- Validation for column missing on physical table
				IF OBJECT_ID(@process_table_name) IS NOT NULL
				BEGIN
					SET @sql = @sql +  ' 
					UNION ALL 
					SELECT ' + 
						CASE 
							WHEN  @regg_type = 109701
								THEN '''Report''' + ',' + '''' + @report_name + ''''
							 ELSE '''Table''' + ',' + '''' + @tbl_name + ''''
						END
						+ ', ''Column'' + config_columns.item + '' is missing in the benchmark table.'',''Verify Regression Configuration.''
						FROM dbo.SplitCommaSeperatedValues(''' + @column_names + ''') config_columns
				LEFT JOIN 
				(SELECT QUOTENAME(COLUMN_NAME) COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = PARSENAME(REPLACE( ''' + @process_table_name + ''',''' + @db_schema_name + ''',''''), 1) AND TABLE_SCHEMA = ''testing'') physical_cols
				ON config_columns.item  = physical_cols.COLUMN_NAME
				WHERE physical_cols.COLUMN_NAME IS NULL
				' 
				END

				SET @sql = @sql + ' END'
				-- validation for report aborated while running report manager report(if report is not runned correctly )
				--IF OBJECT_ID(@report_batch_table) IS NULL AND  @regg_type = 109701 --type Report manager report  OBJECT_ID(@report_batch_table) IS NULL always
				--BEGIN
				--	SET @sql = @sql + ' UNION ALL
				--		SELECT ' + 
				--		CASE 
				--			WHEN  OBJECT_ID(@report_batch_table) IS NOT NULL
				--				THEN '''Report''' + ',' + '''' + @report_name + ''''
				--			 ELSE '''Table''' + ',' + '''' + @tbl_name + ''''
				--		END
				--		+ ',''Error while running the report.'',''Verify report configuration.''
				--	'
				--END
				--print @sql
				--print 2
				EXEC(@sql)
			END

			IF @flag = 'b'  AND NOT EXISTS(SELECT 1 FROM #data_validation_error)
			BEGIN
			--print '' + @column_names + ''
				SET @columns_names_withobj = STUFF((
					SELECT ',' + 'data_table.' + s.item
					FROM (
						SELECT *
						FROM dbo.SplitCommaSeperatedValues('' + @column_names + '')
					) s
					FOR XML PATH
						,TYPE
					).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

				IF OBJECT_ID(@process_table_name) IS NULL 
				BEGIN
					SET @sql = 'SELECT ' + @columns_names_withobj + ', CHECKSUM(''' + @filter_criteria + ''') as filter_hash,CAST(''' + @filter_criteria + ''' AS VARCHAR(MAX)) as filter_criteria, ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''' as benchmark_date INTO  ' + @process_table_name + ' FROM  ' + CASE 
							WHEN OBJECT_ID(@report_batch_table) IS NULL
								THEN @tbl_name + ' data_table' + CASE 
										WHEN @report_paramset_hash IS NULL
											THEN + ' WHERE 1=1'
										ELSE + ' WHERE  create_user = ''' + @runtime_user + ''' AND create_ts >= ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''''
										END
							ELSE @report_batch_table + ' data_table '
							END
					--print 3
					EXEC (@sql)
				END
				ELSE
				BEGIN
				--print ('DELETE FROM ' + @process_table_name + ' WHERE CHECKSUM(filter_criteria) = CHECKSUM( ''' + @filter_criteria + ''')')
					--EXEC ('DELETE FROM ' + @process_table_name + ' WHERE CHECKSUM(filter_criteria) = CHECKSUM( ''' + @filter_criteria + ''')')
					EXEC ('DELETE FROM ' + @process_table_name)
					SET @sql = ' INSERT INTO ' + @process_table_name + '(' +  @column_names + ', filter_hash, filter_criteria, benchmark_date)
					SELECT ' + @columns_names_withobj + ',CHECKSUM( ''' + @filter_criteria + ''') as filter_hash, ''' + @filter_criteria + ''' as filter_criteria, ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''' as benchmark_date
					FROM  ' + CASE 
							WHEN OBJECT_ID(@report_batch_table) IS NULL
								THEN @tbl_name + ' data_table ' + CASE 
										WHEN @report_paramset_hash IS NULL
											THEN + ' WHERE 1=1'
										ELSE + ' WHERE  create_user = ''' + @runtime_user + ''' AND create_ts >= ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''''
										END
							ELSE @report_batch_table + ' data_table '
							END
							--print @columns_names_withobj
							--print 4
					EXEC(@sql)
				END
				--select @tbl_name, @@ROWCOUNT
				IF @@ROWCOUNT > 0
				BEGIN
					SET @sql = '
						INSERT INTO #pre_post_calc_status
						(
							process_id ,error_code,module,[source],[type],[description],[benchmark_date], rules_name
						)
						SELECT ''' + @process_id + ''' process_id,
							''Success'' error_code,
							''Pre/Post Test'' module,''' + 
							CASE 
								WHEN OBJECT_ID(@report_batch_table) IS NULL
									THEN @tbl_name
								ELSE @report_name
							END + ''' [source],
							''Success'' [type],
							CAST(COUNT(1) AS VARCHAR)+'' record'' + CASE WHEN COUNT(1)>1 THEN ''s'' ELSE '''' END + '' imported into benchmark.'' [description],
							CASE
								WHEN MAX(et.regg_type) = 109702 THEN
									''<i>Combined Elapsed Time: ''
								ELSE ''<i>Elapsed Time: ''
							END + MAX(et.elapsed_time) + ''</i>, Benchmark Date: '' + ''' + dbo.FNADateTimeFormat(CAST(@current_date_time AS VARCHAR(50)), 121) + ''' 
							, ''' + ISNULL(@rule_name, '') + '''
						FROM ' +  
						CASE
							WHEN OBJECT_ID(@report_batch_table) IS NULL
								THEN @tbl_name + ' mt
									OUTER APPLY (
										SELECT dbo.FNAGetTimeInterval(start_time, end_time, 2) elapsed_time, regg_type
										FROM regression_time_tracker rtt
										INNER JOIN regression_module_detail rmd ON rmd.regression_module_detail_id = rtt.module_detail_id
										WHERE process_id = ''' + @process_id + '''
											AND module_detail_id = ' + CAST(@regression_module_detail_id AS VARCHAR) + '
									) et
									WHERE 1=1 ' + CASE 
									WHEN @report_paramset_hash IS NULL THEN + ' '
									ELSE + '  AND create_user = ''' + @runtime_user + ''' AND create_ts >= ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''''
								END
							ELSE @report_batch_table + ' mt
								OUTER APPLY (
									SELECT dbo.FNAGetTimeInterval(start_time, end_time, 2) elapsed_time, regg_type
									FROM regression_time_tracker rtt
									INNER JOIN regression_module_detail rmd ON rmd.regression_module_detail_id = rtt.module_detail_id
									WHERE process_id = ''' + @process_id + '''
										AND module_detail_id = ' + CAST(@regression_module_detail_id AS VARCHAR) + '
								) et '
						END

					--PRINT(@sql) RETURN
					EXEC(@sql)
				END
				ELSE
				BEGIN
					SET @sql = '
							INSERT INTO #pre_post_calc_status
							(
								process_id, error_code, module, [source], [type], [description], [benchmark_date], rules_name
							)
							SELECT ''' + @process_id + ''' process_id,''Setup Error'' error_code,''Pre/Post Test'' module,''' + CASE 
							WHEN OBJECT_ID(@report_batch_table) IS NULL
								THEN @tbl_name
							ELSE @report_name
							END + ''' [source],''<b><font color="red">Data Error</font></b>'' [type]
							,''No data available to benchmark.'' [description]
							,'''' [benchmark_date]
							, ''' + ISNULL(@rule_name, '') +  '''
							'

					--EXEC spa_print @sql
					--print 6
					EXEC(@sql)
				END
			END
			ELSE IF @flag = 'p' AND NOT EXISTS(SELECT 1 FROM #data_validation_error)
			BEGIN

				SELECT @sql_join_condition = ISNULL(@sql_join_condition + ' and ', '') + 'ISNULL(CAST(benchmark_table.' + isnull(item, '') + ' AS VARCHAR(200)),''0'')=ISNULL(CAST(physical_table.' + isnull(item, '') + ' AS VARCHAR(200)), ''0'')'
				FROM dbo.SplitCommaSeperatedValues(@unique_columns)

				--SELECT @sql_where_conditions = ISNULL(@sql_where_conditions + ' and ', '') + 'benchmark_table.' + isnull(item, '') + '=isnull(physical_table.' + isnull(item, '') + ',benchmark_table.' + isnull(item, '') + ')'
				--FROM dbo.SplitCommaSeperatedValues(@compare_columns)

				SELECT @sql_group_by_condition = ISNULL(@sql_group_by_condition + ',', '') + 'ISNULL(benchmark_table.' + ISNULL(item, '') + ', physical_table.' + isnull(item, '') + ')'
				FROM dbo.SplitCommaSeperatedValues(@unique_columns)

			
				SELECT @sql_where_conditions = ISNULL(@sql_where_conditions + ' or ', '') + 'isnull(benchmark_table.' + ISNULL(item, '') + ',0)<>isnull(physical_table.' + ISNULL(item, '') + ',0)'
				FROM dbo.SplitCommaSeperatedValues(@compare_columns)

				IF @regg_type = 109701
				BEGIN

					SELECT @floating_point_diff = ISNULL(@floating_point_diff + ' OR ', '') + ' ABS(ISNULL(ROUND(benchmark_table.' + ISNULL(item, '') + ', 5), 0.0) - ISNULL(ROUND(physical_table.' + ISNULL(item, '') + ', 5), 0.0)) > ' + CONVERT(VARCHAR, ISNULL(dbo.FNARemoveTrailingZero(@floating_tolerance_value), '0.0'))
					FROM dbo.SplitCommaSeperatedValues(@compare_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c  WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND (c.DATA_TYPE = 'float' OR c.DATA_TYPE = 'numeric')

					SELECT @select_unique_columns = ISNULL(@select_unique_columns, '') + ',ISNULL(dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + '), dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ')) ' + ISNULL(item, '')
					FROM dbo.SplitCommaSeperatedValues(@unique_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE = 'numeric'	

					SELECT @select_unique_columns = ISNULL(@select_unique_columns, '') + ',ISNULL(benchmark_table.' + ISNULL(item, '') + ',physical_table.' + ISNULL(item, '') + ') ' + ISNULL(item, '')
					FROM dbo.SplitCommaSeperatedValues(@unique_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE  <> 'numeric'			

					SELECT @select_compare_columns = ISNULL(@select_compare_columns, '') + ', dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + ') ' + ISNULL(item, '') + ' , dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ') [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@compare_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE = 'numeric'	

					SELECT @select_compare_columns = ISNULL(@select_compare_columns, '') + ',benchmark_table.' + ISNULL(item, '') + ' ' + ISNULL(item, '') + ' ,physical_table.' + ISNULL(item, '') + ' [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@compare_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE  <> 'numeric'	
						
					
					SELECT @display_column_name = ISNULL(@display_column_name, '') + ', dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + ') ' + ISNULL(item, '') + ' , dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ') [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@display_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE = 'numeric'	
						
					
					SELECT @display_column_name = ISNULL(@display_column_name, '') + ', benchmark_table.' + ISNULL(item, '') + ' ' + ISNULL(item, '') + ' ,physical_table.' + ISNULL(item, '') + ' [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@display_columns) scsv
					INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON 'adiha_process.dbo.' + c.TABLE_NAME = @report_batch_table
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE <> 'numeric'
				END
				ELSE
				BEGIN
			
					SELECT @floating_point_diff = ISNULL(@floating_point_diff + ' OR ', '') + 'ABS(ISNULL(ROUND(benchmark_table.' + ISNULL(item, '') + ', 5), 0.0) - ISNULL(ROUND(physical_table.' + ISNULL(item, '') + ', 5), 0.0)) > ' + CONVERT(VARCHAR, ISNULL(dbo.FNARemoveTrailingZero(@floating_tolerance_value), '0.0')) + ''
					FROM dbo.SplitCommaSeperatedValues(@compare_columns) scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND (c.DATA_TYPE = 'float' OR c.DATA_TYPE = 'numeric')


					SELECT @select_unique_columns = ISNULL(@select_unique_columns, '') + ',ISNULL(dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + '), dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ')) ' + ISNULL(item, '')
					FROM dbo.SplitCommaSeperatedValues(@unique_columns)scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE = 'numeric'	

					SELECT @select_unique_columns = ISNULL(@select_unique_columns, '') + ',ISNULL(benchmark_table.' + ISNULL(item, '') + ',physical_table.' + ISNULL(item, '') + ') ' + ISNULL(item, '')
					FROM dbo.SplitCommaSeperatedValues(@unique_columns) scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE  <> 'numeric'


					SELECT @select_compare_columns = ISNULL(@select_compare_columns, '') + ',
						CASE
							WHEN ABS(benchmark_table.' + ISNULL(item, '') + ' - physical_table.' + ISNULL(item, '') + ') > ' + CAST(@floating_tolerance_value AS VARCHAR(100)) + ' THEN
								CONCAT(''<span class="mismatch_data_regression">'',
									CAST(dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + ') AS VARCHAR(100)),
									''</span>''
								)
							ELSE
								CAST(dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + ') AS VARCHAR(100))
							END ' + ISNULL(item, '') + ',
						CASE
							WHEN ABS(benchmark_table.' + ISNULL(item, '') + ' - physical_table.' + ISNULL(item, '') + ') > ' + CAST(@floating_tolerance_value AS VARCHAR(100)) + ' THEN
								CONCAT(''<span class="mismatch_data_regression">'',
									CAST(dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ') AS VARCHAR(100)),
									''</span>''
								)
						ELSE
							CAST(dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ') AS VARCHAR(100))
						END [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@compare_columns) scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE = 'numeric'	

					SELECT @select_compare_columns = ISNULL(@select_compare_columns, '') + ',
						CASE
							WHEN benchmark_table.' + ISNULL(item, '') + ' = physical_table.' + ISNULL(item, '') + ' THEN
								benchmark_table.' + ISNULL(item, '') + '
							ELSE
								CONCAT(''<span class="mismatch_data_regression">'',
									benchmark_table.' + ISNULL(item, '') + ',
									''</span>'')
						END ' + ISNULL(item, '') + ',
						CASE
							WHEN benchmark_table.' + ISNULL(item, '') + ' = physical_table.' + ISNULL(item, '') + ' THEN
								physical_table.' + ISNULL(item, '') + '
							ELSE
								CONCAT(''<span class="mismatch_data_regression">'',
									physical_table.' + ISNULL(item, '') + ',
									''</span>'')
						END [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@compare_columns) scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE  <> 'numeric'
			

					SELECT @display_column_name = ISNULL(@display_column_name, '') + ', benchmark_table.' + ISNULL(item, '') + ' ' + ISNULL(item, '') + ' ,physical_table.' + ISNULL(item, '') + ' [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@display_columns) scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE  <> 'numeric'			
					
					SELECT @display_column_name = ISNULL(@display_column_name, '') + ', dbo.FNARemoveTrailingZero(benchmark_table.' + ISNULL(item, '') + ') ' + ISNULL(item, '') + ' , dbo.FNARemoveTrailingZero(physical_table.' + ISNULL(item, '') + ') [' + ISNULL(REPLACE(REPLACE(item, '[', ''), ']', ''), '') + '_new]'
					FROM dbo.SplitCommaSeperatedValues(@display_columns) scsv
					INNER JOIN INFORMATION_SCHEMA.COLUMNS c WITH(NOLOCK) ON c.TABLE_NAME = @tbl_name
						AND scsv.item = QUOTENAME(c.COLUMN_NAME)	--TODO: Better handling of quotenames
						AND c.DATA_TYPE = 'numeric'	
				END

				--select @report_batch_table,@regg_type,@batch_process_id
				--IF  OBJECT_ID(@report_batch_table) IS NOT NULL
				--	SET  @tbl1 = @report_tbl1

				SET @sql = '
				IF OBJECT_ID(''' + @process_table_name + ''') IS NOT NULL' + 
				CASE 
					WHEN OBJECT_ID(@process_table_name) IS NOT NULL THEN 
						+ ' AND EXISTS( SELECT TOP 1 1 FROM ' + @process_table_name + ')'
					ELSE ''  
				END + 	
				'--AND (OBJECT_ID(@report_batch_table) IS NOT NULL OR  OBJECT_ID(@tbl_name) IS NOT NULL)

				AND EXISTS(SELECT TOP 1 1 FROM ' + 
				CASE 
						WHEN @regg_type <> 109701 --WHEN OBJECT_ID('' + @report_batch_table + '') IS  NULL
							THEN '' +  @tbl_name + '' + ' WHERE create_ts >= ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''' AND create_user=''' + @runtime_user + ''''
						ELSE '' + @report_batch_table + ''
					END + ')
				BEGIN
						
				SELECT ''' + @process_table_name + ''' table_name' + ISNULL(@select_unique_columns, '') + '' + ISNULL(@select_compare_columns, '') + '' + ISNULL(@display_column_name, '') + '
					INTO ' + @tbl1
				SET @sql1 =' 
				FROM ' + @process_table_name + ' benchmark_table
					FULL JOIN
				' + CASE 
						WHEN OBJECT_ID(@report_batch_table) IS  NULL
							THEN @tbl_name
						ELSE @report_batch_table
					END + ' physical_table ON ' + ISNULL(@sql_join_condition, '') + ' WHERE CHECKSUM(benchmark_table.filter_criteria) = CHECKSUM(''' + @filter_criteria + ''')
					AND ( ' + @sql_where_conditions + ' )'
				SET @sql2 =
				CASE 
					WHEN @floating_point_diff IS NOT NULL
						THEN 'AND ( '+  @floating_point_diff  + ')'  
					ELSE 
					''
				END
				+ ' ORDER BY ' + ISNULL(NULLIF(@data_order, ''), '1') + '
				END'
				SET @sql3 = '
				ELSE 
				BEGIN
					INSERT INTO #pre_post_calc_status(process_id ,error_code,module,[source],[type],[description],[benchmark_date], rules_name)
					SELECT ''' + @process_id + ''', ''<b><font color="red">Data Error</font></b>'', ''Pre/Post Test'',''' + CASE 
					WHEN OBJECT_ID(@report_batch_table) IS NULL
						THEN @tbl_name
					ELSE @report_name END + ''', ''<b><font color="red">Data Error</font></b>'', 
						CASE 
						WHEN OBJECT_ID(''' + @process_table_name + ''') IS NULL THEN ''Benchmark table is missing.''
						WHEN NOT EXISTS( SELECT TOP 1 1 FROM '+ 
						CASE 
								WHEN @regg_type <> 109701 --WHEN OBJECT_ID('' + @report_batch_table + '') IS  NULL
									THEN '' +  @tbl_name + ' WHERE create_ts >= ''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''' AND create_user=''' + @runtime_user + ''''
								ELSE '' + @report_batch_table + ''
							END + ') THEN ''Post regression data not refreshed.''
						ELSE ''Benchmark Data Not Found.'' END
						, NULL,''' + ISNULL(@rule_name, '') + '''
				END'
				--print @sql
				--print @sql1
				--print @sql2
				--print @sql3
				--PRINT(@sql + @sql1 + @sql2 + @sql3)
				--RETURN
				EXEC(@sql + @sql1 + @sql2 + @sql3)

				EXEC spa_print  @sql

				IF OBJECT_ID(@tbl1) IS NOT NULL
				BEGIN
					SET @sql = '
						INSERT INTO #pre_post_calc_status
						(
							process_id ,error_code,module,[source],[type],[description],[benchmark_date], rules_name
						)
						SELECT ''' + @process_id + ''' process_id,
							''Error'' error_code,
							''Pre/Post Test'' module,
							''' + 
								CASE 
									WHEN OBJECT_ID(@report_batch_table) IS NULL
										THEN @tbl_name
									ELSE @report_name
								END +
							''' [source],
							''Mismatch'' [type],
							CAST(COUNT(1) AS VARCHAR) +'' record''+ CASE WHEN COUNT(1)>1 THEN ''s'' ELSE '''' END+'' found mismatch.'' [description],
							CASE WHEN MAX(et.regg_type) = 109702 THEN
								''<i>Combined Elapsed Time ''
							ELSE ''<i>Elapsed Time '' 
							END + ''(Benchmark: '' + ISNULL(MAX(et.elapsed_time_bnch), ''N/A'') + '', Post: '' + ISNULL(MAX(et.elapsed_time), ''N/A'') + '')</i>
								; Date (Benchmark: '' + dbo.FNADateTimeFormat(CAST(MAX(benchmark_date) AS VARCHAR(50)), 121) +'', Post: '' + dbo.FNADateTimeFormat(''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''', 121) + ''); Fault Tolerance: ' + CAST(dbo.FNARemoveTrailingZero(@floating_tolerance_value) AS VARCHAR) + ''' AS benchmark_date,
							''' + ISNULL(@rule_name, '') + '''
						FROM ' + @tbl1 + ' 
						OUTER APPLY(SELECT MAX(benchmark_date) AS benchmark_date 
							FROM ' + @process_table_name + ' 
								WHERE CHECKSUM(filter_criteria) = CHECKSUM(''' + @filter_criteria + ''')
						) btd
						OUTER APPLY (
							SELECT dbo.FNAGetTimeInterval(start_time, end_time, 2) elapsed_time, eti.elapsed_time_bnch, regg_type
							FROM regression_time_tracker rtt
							INNER JOIN regression_module_detail rmd ON rmd.regression_module_detail_id = rtt.module_detail_id
							OUTER APPLY (
								SELECT dbo.FNAGetTimeInterval(start_time, end_time, 2) elapsed_time_bnch
								FROM regression_time_tracker rtt
								WHERE module_detail_id = ' + CAST(@regression_module_detail_id AS VARCHAR) + '
									AND is_benchmark = 1
							) eti
							WHERE process_id = ''' + @process_id + '''
								AND module_detail_id = ' + CAST(@regression_module_detail_id AS VARCHAR) + '
						) et
						GROUP BY table_name HAVING COUNT(1)>0 '

					--EXEC spa_print @sql
					EXEC(@sql)

					IF @@ROWCOUNT < 1
					BEGIN
						IF OBJECT_ID(@process_table_name) IS NOT NULL
						BEGIN
							SET @sql = '
								INSERT INTO #pre_post_calc_status
								(
									process_id ,error_code,module,[source],[type],[description],[benchmark_date],rules_name
								)
								SELECT ''' + @process_id + ''' process_id,''Success'' error_code,''Pre/Post Test'' module,''' + 
								CASE 
									WHEN OBJECT_ID(@report_batch_table) IS NULL
										THEN @tbl_name
									ELSE @report_name
								END + ''' [source],''Success'' [type]
								,CAST(COUNT(1) AS VARCHAR)+'' record'' + CASE WHEN COUNT(1)>1 THEN ''s'' ELSE '''' END+'' found match.'' [description]
								,CASE WHEN MAX(et.regg_type) = 109702 THEN 
									''<i>Combined Elapsed Time ''
									ELSE ''<i>Elapsed Time ''
								END + ''(Benchmark: '' + ISNULL(MAX(et.elapsed_time_bnch), ''N/A'') + '', Post: '' + ISNULL(MAX(et.elapsed_time), ''N/A'') + '')</i>
									; Date (Benchmark: ''+ dbo.FNADateTimeFormat(CAST(MAX(btd.benchmark_date) AS VARCHAR(50)), 121) +'', Post: ''+ dbo.FNADateTimeFormat(''' + CONVERT(VARCHAR(25), @current_date_time, 121) + ''', 121) + ''); Fault Tolerance: ' + CAST(dbo.FNARemoveTrailingZero(@floating_tolerance_value) AS VARCHAR) + '''  AS benchmark_date
								, ''' + ISNULL(@rule_name, '') + ''' 
								FROM ' + @process_table_name + ' s 
								OUTER APPLY(SELECT MAX(benchmark_date) AS benchmark_date FROM ' + @process_table_name + ' 
									WHERE CHECKSUM(filter_criteria) = CHECKSUM(''' + @filter_criteria + ''')
								) btd
								OUTER APPLY (
									SELECT dbo.FNAGetTimeInterval(start_time, end_time, 2) elapsed_time, eti.elapsed_time_bnch, regg_type
									FROM regression_time_tracker rtt
									INNER JOIN regression_module_detail rmd ON rmd.regression_module_detail_id = rtt.module_detail_id
									OUTER APPLY (
										SELECT dbo.FNAGetTimeInterval(start_time, end_time, 2) elapsed_time_bnch
										FROM regression_time_tracker
										WHERE module_detail_id = ' + CAST(@regression_module_detail_id AS VARCHAR) + '
											AND is_benchmark = 1
									) eti
									WHERE process_id = ''' + @process_id + '''
										AND module_detail_id = ' + CAST(@regression_module_detail_id AS VARCHAR) + '
								) et
							'
							--print 8
							EXEC(@sql)
						END
					END
				END
			END

			IF @flag IN ('b', 'p')
			BEGIN
				INSERT INTO source_system_data_import_status (
					process_id
					,code
					,module
					,[source]
					,[type]
					,[description]
					,recommendation
					,rules_name
					)
				SELECT process_id
					,error_code
					,module
					,[source]
					,[type]
					,[description]
					,benchmark_date
					,rules_name
				FROM #pre_post_calc_status
				UNION
				SELECT @process_id, '<b><font color="red">Setup Error</font></b>','Pre/Post Test',table_name,'<b><font color="red">Data Error</font></b>', validation_message, recommendation, @rule_name FROM #data_validation_error
				--drop table #data_validation_error
			END

			IF @flag = 'v' AND @have_benchmarktable_for_postregg = 1-- for validation
			BEGIN
				IF OBJECT_ID(@process_table_name) IS NULL
				BEGIN
					SET @have_benchmarktable_for_postregg = 0
				END
				ELSE
				BEGIN
				
					IF OBJECT_ID('tempdb..#benchmark_status') IS NOT NULL
						DROP TABLE #benchmark_status

					CREATE TABLE #benchmark_status (is_valid BIT)

					SET @sql = ' 
						IF NOT EXISTS(
							SELECT 1 FROM ' + @process_table_name + ' 
							WHERE CHECKSUM(filter_criteria) = CHECKSUM(''' + @filter_criteria + ''')
						) 
							INSERT INTO #benchmark_status(is_valid) VALUES(0)
					'

					EXEC (@sql)

					IF EXISTS (
							SELECT 1
							FROM #benchmark_status
							)
					BEGIN
						SET @have_benchmarktable_for_postregg = 0
						SET @data_exists_for_postregg = 0
					END
				END
			END

			FETCH NEXT FROM table_names_cursor
			INTO @unique_columns
				,@compare_columns
				,@tbl_name
				,@display_columns
				,@data_order
				,@report_paramset_hash
				,@report_name
		END

		CLOSE table_names_cursor

		DEALLOCATE table_names_cursor

		FETCH NEXT
		FROM paramset_hash
		INTO @regg_type
			,@filter_criteria
			,@report_page_id
			,@paramset_id
			,@regression_module_header_id
			,@rmd_paramset_hash
			,@rule_id
			,@rule_name
			,@regression_module_detail_id
	END

	CLOSE paramset_hash

	DEALLOCATE paramset_hash

	IF @flag = 'v'
	BEGIN
		IF @have_benchmarktable_for_postregg = 0
		BEGIN
			SET @error_description = 'No benchmark found for ' + @grouped_rule_name + '.'

			EXEC spa_ErrorHandler - 1
				,'Regression Testing'
				,'spa_pre_post_analysis'
				,'Error'
				,@error_description
				,''
		END
		ELSE IF @data_exists_for_postregg = 0
		BEGIN
			EXEC spa_ErrorHandler - 1
					,'Regression Testing'
					,'spa_pre_post_analysis'
					,'Error'
					,'Benchmark not found for applied filter.'
					,'1'
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0
				,'Regression Testing'
				,'spa_pre_post_analysis'
				,'Success'
				,''
				,''
		END
		RETURN
	END

	IF @flag IN ('b', 'p')
	BEGIN
		SET @url = './dev/spa_html.php?__user_name__=' + @runtime_user + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @runtime_user + ''',null,''Regression Testing'''
		--DECLARE @e_time_s INT = DATEDIFF(ss, @current_date_time, GETDATE())
		DECLARE @e_time_text_s VARCHAR(100)
		SET @e_time_text_s = dbo.FNAGetElapsedTime(@current_date_time, 2) --CAST(CAST(@e_time_s/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@e_time_s - CAST(@e_time_s/60 AS INT) * 60 AS VARCHAR) + ' Secs'

		IF EXISTS (
			SELECT 1
			FROM source_system_data_import_status
			WHERE process_id = @process_id AND code = 'Error'
		)
		BEGIN
			SET @desc = '<a target="_blank" href="' + @url + '">' +
				CASE WHEN @flag = 'b'
					THEN 'Benchmark process completed for regression rule ''' + @description + '''<span style="color:red"> (Data not found)</span>'
					ELSE 'Post Regression process completed for regression rule '''+ @description +''' <span style="color:red"> (Mismatch Found)</span>'
				END + '[Elapse time:' + @e_time_text_s + '].</a>'

			SET @error_code = 'e'
		END
		ELSE
			SET @desc = '<a target="_blank" href="' + @url + '">' +
				CASE WHEN @flag = 'b'
					THEN ' Benchmark process completed for regression rule'
					ELSE 'Post Regression process completed for regression rule'
				END + '''' + @description + '''[Elapse time:' + @e_time_text_s + '].</a>'

		--EXEC spa_print @desc

		EXEC spa_message_board @flag = 'u'
			,@user_login_id = @runtime_user
			,@source = @description
			,@description = @desc
			,@url_desc = ''
			,@url = ''
			,@type = @error_code
			,@returnOutput = 'n'
			,@email_enable = 'y'

		INSERT import_data_files_audit (
			dir_path
			,imp_file_name
			,as_of_date
			,[status]
			,elapsed_time
			,process_id
			,create_user
			,source_system_id
			)
		VALUES (
			'Regression Testing'
			,'Regression Testing run for applied filter'
			,CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
			,@error_code
			,DATEDIFF(ss, @current_date_time, GETDATE())
			,@process_id
			,@runtime_user
			,2
		)

		--IF @flag = 'p'
		--BEGIN
		--	SET @output_process_id = @process_id
		--END
	END
END

GO