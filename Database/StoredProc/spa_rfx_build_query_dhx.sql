

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].spa_rfx_build_query_dhx') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].spa_rfx_build_query_dhx
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Create date: 2012-09-06 14:46
-- Author : ssingh@pioneersolutionsglobal.com
-- Description: Builds a runnable SQL query from a Report Writer Report 
               
--Params:
--@paramset_id			INT			  : parameter set ID
--@root_dataset_id		INT			  : root_dataset ID
--@criteria				VARCHAR(5000) : parameter and their values 
--@temp_table_name		VARCHAR(100)  : temp table for batch processing 
--@batch_process_id		VARCHAR(50)   : process_id
--@batch_report_param	VARCHAR(1000) : Batch parameter
--@display_type			CHAR(1)		  : t = Tabular Display, c = Chart Display
--@final_sql			VARCHAR(MAX) OUTPUT : final runnable sql query returned 
-- ============================================================================================================================

CREATE PROCEDURE [dbo].spa_rfx_build_query_dhx
	@paramset_id			VARCHAR(10) = NULL
	, @component_id			VARCHAR(10) = NULL
	, @criteria				VARCHAR(MAX) = NULL
	, @temp_table_name		VARCHAR(100) = NULL
	, @display_type			CHAR(1) = 't'
	, @is_html				CHAR(1) = 'y'
	, @batch_process_id		VARCHAR(50) = NULL
	, @batch_report_param	VARCHAR(1000) = NULL
	, @final_sql			VARCHAR(MAX) OUTPUT
	, @process_id				VARCHAR(50)

AS
--/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
	@paramset_id			VARCHAR(10) = 1,
	@component_id			VARCHAR(10) = 1,
	@criteria				VARCHAR(5000) = 'sub_id=122,stra_id=123,book_id=124,sub_book_id=23',
	@temp_table_name		VARCHAR(100) = NULL,
	@batch_process_id		VARCHAR(50) = NULL,
	@batch_report_param 	VARCHAR(1000) = NULL,
	@display_type			CHAR(1) = 't',
	@is_html				CHAR(1) = 'y',
	@final_sql				VARCHAR(MAX), -- OUTPUT,
	@process_id				VARCHAR(50) = 'DD2CB3AB_75D4_40FC_8063_6066DEAD109F'
	
	
	                     
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/

BEGIN
	SET NOCOUNT ON; -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	
	DECLARE @root_dataset_id				VARCHAR(10)
	DECLARE @from_index						INT
	DECLARE @batch_identifier				VARCHAR(100)
	DECLARE @view_identifier				VARCHAR(100)
	DECLARE @data_source_process_id			VARCHAR(50)
	DECLARE	@data_source_tsql				VARCHAR(MAX)
	DECLARE @data_source_alias				VARCHAR(50)
	DECLARE @hidden_criteria_not_appended	VARCHAR(5000)	
	DECLARE @user_name                      VARCHAR(50) = dbo.FNADBUser()
	DECLARE @sqln		                    NVARCHAR(MAX)
	DECLARE @sql		                    VARCHAR(MAX)

	
	--defining process tables
	DECLARE @rfx_report_page_tablix				VARCHAR(200) = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
	DECLARE @rfx_report_page_chart				VARCHAR(200) = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
	DECLARE @rfx_report_page_gauge				VARCHAR(200) = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
	DECLARE @rfx_report_tablix_column			VARCHAR(200) = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
	DECLARE @rfx_report_chart_column			VARCHAR(200) = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
	DECLARE @rfx_report_gauge_column			VARCHAR(200) = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
	DECLARE @rfx_report_param					VARCHAR(200) = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
	DECLARE @rfx_report_dataset_paramset		VARCHAR(200) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
	DECLARE @rfx_report_paramset				VARCHAR(200) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
	DECLARE @rfx_report_page					VARCHAR(200) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
	DECLARE @rfx_report_dataset					VARCHAR(200) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
	DECLARE @rfx_report_dataset_relationship	VARCHAR(200) = dbo.FNAProcessTableName('report_dataset_relationship', @user_name, @process_id)
	
	DECLARE @view_result_identifier varchar(100) = '<#PROCESS_TABLE#>'
		
	SET @is_html = 'y' --forcing for a while to make sure that data is not lost otherwise done by dbo.FNAStripHTML()
	SET @view_identifier = '{'
	SET @batch_identifier = '--[__batch_report__]'	
	SET @final_sql = ''
	IF @display_type IS NULL
		SET @display_type = 't'
		
	SELECT @data_source_process_id = CASE WHEN @batch_process_id IS NOT NULL THEN @batch_process_id ELSE dbo.FNAGetNewID() END
	
	--NOTE: if this same code is required to use in other places, consider exporting it to an UDF rather than repeating it.
	IF @display_type = 't'
	BEGIN
		SET @sqln = '
		SELECT @root_dataset_id = root_dataset_id  
		FROM ' + @rfx_report_page_tablix + '  rpt WHERE rpt.report_page_tablix_id = ' + @component_id + '
		'
		EXEC sp_executesql @sqln, N'@root_dataset_id INT OUTPUT', @root_dataset_id OUT
	END
	ELSE IF @display_type = 'c'
	BEGIN
		SET @sqln = '
		SELECT @root_dataset_id = root_dataset_id  
		FROM ' + @rfx_report_page_chart + '  rpt WHERE rpt.report_page_chart_id = ' + @component_id + '
		'
		EXEC sp_executesql @sqln, N'@root_dataset_id INT OUTPUT', @root_dataset_id OUT
	END
	ELSE IF @display_type = 'g'
	BEGIN
		SET @sqln = '
		SELECT @root_dataset_id = root_dataset_id  
		FROM ' + @rfx_report_page_gauge + '  rpt WHERE rpt.report_page_gauge_id = ' + @component_id + '
		'
		EXEC sp_executesql @sqln, N'@root_dataset_id INT OUTPUT', @root_dataset_id OUT
	END
	--select @root_dataset_id
	/******************************Hidden not appending criteria generation START*********************************/
	--generate criteria for hidden params, whose append filter is false, means it is used in View and won't participate in where clause.
	--Value for such parameter should be supplied in Criteria
	SET @sqln = '
	SELECT @hidden_criteria_not_appended =	STUFF((
		--treat blank value as NULL for initial value. Otherwise it gives problem in book structure filter query generation
		-- [AND ('''' = ''NULL'' OR sub.entity_id IN ()) AND (''312'' = ''NULL'' OR stra.entity_id IN (312)) AND ('''' = ''NULL'' OR book.entity_id IN ())]
		--comma has to be replaced by !(exclamation) sign to parse correctly in spa_html_header 
		SELECT '','' + dsc.[name] + ''='' + ISNULL(NULLIF(REPLACE(rp.initial_value, '','', ''!''), ''''), ''NULL'') 
			+ (CASE WHEN rp.operator = 8 THEN '',2_'' + dsc.[name] + ''='' + ISNULL(REPLACE(rp.initial_value2, '','', ''!''), ''NULL'') ELSE '''' END)
		FROM ' + @rfx_report_param + ' rp
		INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id
		WHERE rdp.paramset_id = ' + @paramset_id + '
			AND rdp.root_dataset_id = ' + @root_dataset_id + '
			AND ISNULL(rp.hidden, 0) = 1
			--TODO: figure out why append_filter is required. It caused problem in case of hidden appending params. So it is removed now.
			--AND ISNULL(dsc.append_filter, 1) = 0
		FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(5000)''), 1, 1, '''')
	'
	EXEC sp_executesql @sqln, N'@hidden_criteria_not_appended VARCHAR(5000) OUTPUT', @hidden_criteria_not_appended OUT
	--select @hidden_criteria_not_appended
	--return

	IF @hidden_criteria_not_appended IS NOT NULL	
		SET @criteria = ISNULL(NULLIF(@criteria, '') + ',', '') + @hidden_criteria_not_appended
	
	EXEC spa_print '****************************************SELECT Hidden non appending criteria START****************************************:' 
				,@hidden_criteria_not_appended,'****************************************SELECT Hidden non appending criteria END******************************************:'
	/******************************Hidden not appending criteria generation END*********************************/				
		
	BEGIN TRY	
	
		/******************************Datasource TSQL processing (if multiline) START*********************************/
		IF OBJECT_ID('tempdb..#tmp_cur_select') IS NOT NULL
			DROP TABLE #tmp_cur_select
		CREATE TABLE #tmp_cur_select (
			[tsql] VARCHAR(MAX) COLLATE DATABASE_DEFAULT , [alias] VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
		)
		SET @sql = '
		INSERT INTO #tmp_cur_select([tsql], [alias])
		SELECT DISTINCT ds.[tsql], ds.[alias] 
		FROM ' + @rfx_report_paramset + ' rp
		INNER JOIN ' + @rfx_report_page + ' rpage ON rpage.report_page_id = rp.page_id
		CROSS APPLY (
			SELECT report_dataset_id, rd_inner.source_id, rd_inner.[alias] 
			FROM ' + @rfx_report_dataset + ' rd_inner
			WHERE rd_inner.report_id = rpage.report_id
				AND ISNULL(rd_inner.root_dataset_id, rd_inner.report_dataset_id) = ' + @root_dataset_id + '
		) rd
		INNER JOIN data_source ds ON rd.source_id = ds.data_source_id 
		WHERE rp.report_paramset_id = ' + @paramset_id + '
		'
		EXEC(@sql)
		--select * from #tmp_cur_select
		--return

		DECLARE cur_data_source CURSOR LOCAL FOR
		
		SELECT ds.[tsql], ds.[alias] 
		FROM #tmp_cur_select ds
			 
		OPEN cur_data_source   
		FETCH NEXT FROM cur_data_source INTO @data_source_tsql, @data_source_alias
		
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			EXEC spa_rfx_handle_data_source_dhx
				@data_source_tsql			
				, @data_source_alias		
				, @criteria					
				, @data_source_process_id	
				, 0	--@validate				
				, 0	--@handle_single_line_sql
				, @paramset_id
			--	, 'v'
				, 'y'
				, @process_id
			FETCH NEXT FROM cur_data_source INTO @data_source_tsql, @data_source_alias
		END	
		
		CLOSE cur_data_source   
		DEALLOCATE cur_data_source
		
		/******************************Datasource TSQL processing (if multiline) END*********************************/


		
		
		/*****************************************Generate SELECT clause START**************************************/	
		DECLARE @cols VARCHAR(MAX)
		
		/*
		* placement:
		* 1. Detail Columns
		* 2: Group Columns (SSRS Grouping)
		* 
		* [type_id]:
		* 1: Default Tab
		* 2: Cross Tab
		* 
		* Query level group by is required only if 
		* 	a) aggregation used in any detail columns i.e (AND rtc.sql_aggregation IS NOT NULL AND rtc.placement = 1)
		* Query Level Group by is not implemented in these cases 
		* 	a)Doesnt contain any aggregate function in the detail column
		* set @query_level_grouping_reqd = 1 : SSRS grouping logic may exists and is Default tab i.e SQL GROUP BY is required or is Cross Tab.
		* set @query_level_grouping_reqd = NULL : It has no aggregation logic in any columns involved.
		*/
		
		DECLARE @query_level_grouping_reqd VARCHAR(5)
		--DECLARE @sql VARCHAR(MAX)
		DECLARE @report_page_component_join	   VARCHAR(500)
		DECLARE @report_page_component_column_join	   VARCHAR(500)
		DECLARE @report_component_alias  VARCHAR(5)
		
		IF OBJECT_ID('tempdb..#query_level_grouping_reqd') IS NOT NULL
				DROP TABLE #query_level_grouping_reqd
		CREATE TABLE #query_level_grouping_reqd (is_grouping INT )

		IF @display_type = 't'
		BEGIN
			SET  @report_page_component_join = 'INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON  rpt.report_page_tablix_id'
			SET @report_page_component_column_join = 'INNER JOIN ' + @rfx_report_tablix_column + ' rtc ON rtc.tablix_id = rpt.report_page_tablix_id'
			set @report_component_alias = 'rtc'
		END 
		ELSE IF @display_type = 'c'
		BEGIN
			SET  @report_page_component_join = 'INNER JOIN ' + @rfx_report_page_chart + ' rpc ON  rpc.report_page_chart_id'
			SET @report_page_component_column_join = 'INNER JOIN ' + @rfx_report_chart_column + ' rcc ON rcc.chart_id = rpc.report_page_chart_id'
			set @report_component_alias = 'rcc'
		END
		ELSE IF @display_type = 'g'
		BEGIN
			SET  @report_page_component_join = 'INNER JOIN ' + @rfx_report_page_gauge + ' rpg ON  rpg.report_page_gauge_id'
			SET @report_page_component_column_join = 'INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON rgc.gauge_id = rpg.report_page_gauge_id'
			set @report_component_alias = 'rgc'
		END
		
		SELECT @sql =
		'
		INSERT INTO  #query_level_grouping_reqd
		SELECT 1 FROM   ' + @rfx_report_paramset + ' rp ' 
				+ @report_page_component_join 
				+' = ' + cast(@component_id AS VARCHAR(10))
				+ ' ' + @report_page_component_column_join 
				+ ' WHERE  rp.report_paramset_id = ' + cast(@paramset_id AS VARCHAR(10))
				+	' AND ('
				+	CASE WHEN 	@display_type <> 'g' THEN  @report_component_alias + '.placement = 1
		                      AND '
		            ELSE '' 
		            END
		                      + @report_component_alias + CASE WHEN @display_type = 't' THEN '.sql_aggregation' ELSE '.aggregation' END  + 
		                      ' IS NOT NULL
						  )'
		EXEC spa_print  @sql
		EXEC(@sql)
	
		
SELECT  @query_level_grouping_reqd = is_grouping FROM #query_level_grouping_reqd

		--Group by logic is only implemented in tablix only.
		
		--IF EXISTS (
		--       SELECT 1
		--		FROM   report_paramset rp
		--		INNER JOIN report_page_tablix rpt
  --                 ON  rpt.report_page_tablix_id = @component_id
		--		--CROSS APPLY(
		--		--   SELECT COUNT(report_tablix_column_id) cnt
		--		--   FROM   report_tablix_column rtc
		--		--   WHERE  placement = 2
		--		--  AND tablix_id = rpt.report_page_tablix_id
		--		--) tablix_with_grouping_cols
		--       INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rpt.report_page_tablix_id
		--       WHERE  rp.report_paramset_id = @paramset_id
		--			--AND tablix_with_grouping_cols.cnt = 0	--make sure no grouping colums exist						
		--			AND (
		--					  rtc.placement = 1
		--                      AND rtc.sql_aggregation IS NOT NULL
		--                  )
		--)
		--BEGIN
		--	SET @query_level_grouping_reqd = 1 
		--END
			
			IF OBJECT_ID('tempdb..#column_aggregation_option') IS NOT NULL
				DROP TABLE #column_aggregation_option

			SELECT agg.* INTO #column_aggregation_option 
			FROM ( 
				SELECT 1 [id], 'Avg' [function_name],'Average (non-null values)' [label],'1' [only_for_number],'1' [for_group],'1' [for_non_group] UNION
				SELECT 2, 'Count','Count','0','1','1' UNION
				SELECT 8, 'Max','Max (non-null values)','0','1','1' UNION 
				SELECT 9, 'Min','Min (non-null values)','0','1','1' UNION
				SELECT 11, 'StDev','Standard Deviation (non-null values)','1','1','1' UNION
				SELECT 12, 'StDevP','Population Standard Deviation (non-null values)','1','1','1' UNION
				SELECT 13, 'Sum','Sum','1','1','1' UNION
				SELECT 14, 'Var','Variance (non-null values)','1','1','1' UNION
				SELECT 15, 'VarP','Population Variance (non-null values)','1','1','1' UNION
				SELECT 16, 'COUNT_BIG','Count Big','0','0','1' UNION
				SELECT 17, 'GROUPING','Grouping','0','0','1' UNION
				SELECT 18, '','Derive Aggregate','0','0','1'
			) agg
		--Retrieving columns to be displayed in tabular form
		IF @display_type = 't'
		BEGIN
			--IF OBJECT_ID('tempdb..#column_aggregation_option') IS NOT NULL
			--	DROP TABLE #column_aggregation_option

			/* Report manager support both style of aggregation.
			*  a. SSRS Level
			*  b. SQL Level (same as old report writer).
			*  
			*  For b., query is prepared in such a way that it contains the user configured aggregation functions. 
			*  Applying aggregation function in any columns will push the remaining columns in group by clause.
			*/
			
			--SELECT agg.* INTO #column_aggregation_option 
			--FROM ( 
			--	SELECT 1 [id], 'Avg' [function_name],'Average (non-null values)' [label],'1' [only_for_number],'1' [for_group],'1' [for_non_group] UNION
			--	SELECT 2, 'Count','Count','0','1','1' UNION
			--	SELECT 8, 'Max','Max (non-null values)','0','1','1' UNION 
			--	SELECT 9, 'Min','Min (non-null values)','0','1','1' UNION
			--	SELECT 11, 'StDev','Standard Deviation (non-null values)','1','1','1' UNION
			--	SELECT 12, 'StDevP','Population Standard Deviation (non-null values)','1','1','1' UNION
			--	SELECT 13, 'Sum','Sum','1','1','1' UNION
			--	SELECT 14, 'Var','Variance (non-null values)','1','1','1' UNION
			--	SELECT 15, 'VarP','Population Variance (non-null values)','1','1','1' UNION
			--	SELECT 16, 'COUNT_BIG','Count Big','0','0','1' UNION
			--	SELECT 17, 'GROUPING','Grouping','0','0','1' UNION
			--	SELECT 18, '','Derive Aggregate','0','0','1'
			--) agg
			SET @sqln = '	 
			SELECT @cols = STUFF(( 
				SELECT '', '' + ' + 
				CASE WHEN @query_level_grouping_reqd IS NULL THEN + '
						ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])) + '' AS '' + QUOTENAME(rtc.[alias]) ' 
					 WHEN @query_level_grouping_reqd = 1 THEN + '
						CASE 
							WHEN rtc.sql_aggregation IS NOT NULL AND rtc.functions IS NOT NULL THEN
								--insert aggregation function
								--STUFF(rtc.functions 
								--	, CHARINDEX(''('', rtc.functions) + 1	--start
								--	, 0 --do not delete any chars
								--	, cao.function_name + ''(''	--add aggregation function name
								--	) + '')'' 
								--	+  '' AS '' + QUOTENAME(rtc.[alias])
								
					--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
								cao.function_name + ''('' + rtc.functions + '')''
								+  '' AS '' + QUOTENAME(rtc.[alias])
							WHEN rtc.sql_aggregation IS NOT NULL AND rtc.placement <> 2 THEN cao.function_name + ''('' + ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])) + '')'' + '' AS '' + QUOTENAME(rtc.[alias])
							ELSE ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])) + '' AS '' + QUOTENAME(rtc.[alias])
						END '
				END + '
				FROM ' + @rfx_report_paramset + ' rp
					INNER JOIN ' + @rfx_report_page_tablix + ' rt ON rt.report_page_tablix_id = ' + @component_id + '
						AND rt.root_dataset_id = ' + @root_dataset_id + '
				    INNER JOIN ' + @rfx_report_tablix_column + ' rtc ON rtc.tablix_id = rt.report_page_tablix_id
				    LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rtc.dataset_id
					LEFT JOIN #column_aggregation_option cao ON cao.id  = rtc.sql_aggregation
					--use LEFT JOIN as custom fields will not have column_id value
					LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
				WHERE rp.report_paramset_id = ' + @paramset_id + '
				ORDER BY rtc.column_order
				FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''')	
			'
			EXEC sp_executesql @sqln, N'@cols VARCHAR(MAX) OUTPUT', @cols OUT
			

			IF @is_html = 'n'
			BEGIN
				SET @cols = REPLACE(@cols, ' AS', ') AS ')
				SET @cols = 'dbo.FNAStripHTML(' + REPLACE(@cols, ',', ', dbo.FNAStripHTML(')
			END

		
		EXEC spa_print '****************************************SELECT Tablix Columns START****************************************:' 
			,@cols,'****************************************SELECT Tablix Columns END******************************************:'
		END 
		--Retrieving columns to be displayed in Chart form
		ELSE IF @display_type = 'c'
		BEGIN 
			SET @sqln = '
			 SELECT @cols = STUFF((
				--SELECT '', '' + 
					
				--	CASE WHEN dsc.widget_id = 6 THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
				--		ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) END 
				
				--+  '' AS '' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias])) --Chart allows NULLABLE [alias] as it is not set in frontend 
					SELECT '', '' + ' + 
					CASE WHEN @query_level_grouping_reqd IS NULL 
						THEN ' ISNULL(rcc.functions,
								--CASE WHEN dsc.widget_id = 6 
								--	THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
								--	ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
								--END 
								--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
								QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) 
						  )+ '' AS '' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))	'
						WHEN @query_level_grouping_reqd = 1 THEN '
							CASE 
								WHEN rcc.aggregation IS NOT NULL AND rcc.functions IS NOT NULL THEN		
								--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
									cao.function_name + ''('' + rcc.functions + '')'' +  '' AS '' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))
								WHEN rcc.aggregation IS NOT NULL  
									THEN cao.function_name + ''('' +ISNULL(rcc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
											--	ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) 
									  ) + '')'' + '' AS '' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))
									ELSE ISNULL(rcc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
											--	ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
									  )+ '' AS '' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))
							END '
					END  + '
				FROM ' + @rfx_report_paramset + ' rp
				INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rpc.report_page_chart_id = ' + @component_id + '
				INNER JOIN ' + @rfx_report_chart_column + ' rcc ON rcc.chart_id = rpc.report_page_chart_id 
				INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rcc.dataset_id
				LEFT JOIN #column_aggregation_option cao ON cao.id  = rcc.aggregation
				--use LEFT JOIN as custom fields won''t have column_id value
				LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rcc.column_id 
				WHERE rp.report_paramset_id = ' + @paramset_id + '
			FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(MAX)''), 1, 1, '''')
			'
			EXEC sp_executesql @sqln, N'@cols VARCHAR(MAX) OUTPUT', @cols OUT

			IF @is_html = 'n'
			BEGIN
				SET @cols = REPLACE(@cols, ' AS', ') AS ')
				SET @cols = 'dbo.FNAStripHTML(' + REPLACE(@cols, ',', ', dbo.FNAStripHTML(')
			END


			EXEC spa_print  '****************************************SELECT Chart Columns START****************************************:' 
				,@cols,'****************************************SELECT Chart Columns END******************************************:'
		END 
		--Retrieving columns to be displayed in gauge form
		ELSE IF @display_type = 'g'
		BEGIN 
			-- SELECT @cols = STUFF((
			--	SELECT ', ' + 
					
			--		CASE WHEN dsc.widget_id = 6 THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
			--			ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) END 
				
			--	+  ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias])) --gauge allows NULLALE [alias] as it is not set in frontend  
			--	FROM report_paramset rp
			--	INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = @component_id
			--	INNER JOIN report_gauge_column rgc ON rgc.gauge_id = rpg.report_page_gauge_id
			--	INNER JOIN report_dataset rd ON rd.report_dataset_id = rgc.dataset_id
			--	INNER JOIN data_source_column dsc ON rgc.column_id = dsc.data_source_column_id 
			--	WHERE rp.report_paramset_id = @paramset_id
			--FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')
						
			DECLARE @data_cols VARCHAR(5000)
			DECLARE @label_cols VARCHAR(5000)

			SET @sqln = '
			SELECT @data_cols = STUFF((
				--SELECT '', '' + 		
				--	CASE WHEN dsc.widget_id = 6 THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
				--		ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) END 	
				--+  '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias])) --gauge allows NULLALE [alias] as it is not set in frontend 
				SELECT '', '' + ' + 	
					CASE WHEN @query_level_grouping_reqd IS NULL 
						THEN ' ISNULL(rgc.functions,
								--CASE WHEN dsc.widget_id = 6 
								--	THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
								--	ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
								--END 
								--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
								QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
						  )+ '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))	'
						WHEN @query_level_grouping_reqd = 1 THEN '
							CASE 
								WHEN rgc.aggregation IS NOT NULL AND rgc.functions IS NOT NULL THEN		
								--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
									cao.function_name + ''('' + rgc.functions + '')'' +  '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
								WHEN rgc.aggregation IS NOT NULL  
									THEN cao.function_name + ''('' +ISNULL(rgc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
											--	ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
									  ) + '')'' + '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
									ELSE ISNULL(rgc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
											--	ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) 
									  )+ '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
							END '
					END + '
				FROM ' + @rfx_report_paramset + ' rp
				INNER JOIN ' + @rfx_report_page_gauge + ' rpg ON rpg.report_page_gauge_id = ' + @component_id + '
				INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON rgc.gauge_id = rpg.report_page_gauge_id
				INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rgc.dataset_id
				LEFT JOIN #column_aggregation_option cao ON cao.id  = rgc.aggregation
				--use LEFT JOIN as custom fields won''t have column_id value
				LEFT JOIN data_source_column dsc ON rgc.column_id = dsc.data_source_column_id 
				WHERE rp.report_paramset_id = ' + @paramset_id + '
			FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(MAX)''), 1, 1, '''')
			'
			EXEC sp_executesql @sqln, N'@data_cols VARCHAR(5000) OUTPUT', @data_cols OUT

			SET @sqln = '
			SELECT @label_cols = STUFF((
				SELECT DISTINCT '', '' + 		
					CASE WHEN dsc.widget_id = 6 THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
						ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) END 	
				+  '' AS '' + QUOTENAME(ISNULL(dsc.[alias], rgc.[alias])) --gauge allows NULLALE [alias] as it is not set in frontend 
				--SELECT '', '' + 		
				--	CASE WHEN @query_level_grouping_reqd IS NULL 
				--		THEN ISNULL(rgc.functions,
				--				CASE WHEN dsc.widget_id = 6 
				--					THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
				--					ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
				--				END 
				--		  )+ '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))	
				--		WHEN @query_level_grouping_reqd = 1 THEN
				--			CASE 
				--				WHEN rgc.aggregation IS NOT NULL AND rgc.functions IS NOT NULL THEN		
				--				--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
				--					cao.function_name + ''('' + rgc.functions + '')'' +  '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
				--				WHEN rgc.aggregation IS NOT NULL  
				--					THEN cao.function_name + ''('' +ISNULL(rgc.functions,
				--							CASE WHEN dsc.widget_id = 6 
				--								THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
				--								ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
				--							 END 
				--					  ) + '')'' + '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
				--					ELSE ISNULL(rgc.functions,
				--							CASE WHEN dsc.widget_id = 6 
				--								THEN ''dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
				--								ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name])
				--							 END 
				--					  )+ '' AS '' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
				--			END 
				--	END  
				FROM ' + @rfx_report_paramset + ' rp
				INNER JOIN ' + @rfx_report_page_gauge + ' rpg ON rpg.report_page_gauge_id = ' + @component_id + '
				INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON rgc.gauge_id = rpg.report_page_gauge_id
				INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rgc.dataset_id
				LEFT JOIN #column_aggregation_option cao ON cao.id  = rgc.aggregation
				--use LEFT JOIN as custom fields won''t have column_id value
				LEFT JOIN data_source_column dsc ON rpg.gauge_label_column_id = dsc.data_source_column_id 
				WHERE rp.report_paramset_id = ' + @paramset_id + '
			FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(MAX)''), 1, 1, '''')
			'
			EXEC sp_executesql @sqln, N'@label_cols VARCHAR(5000) OUTPUT', @label_cols OUT

			SET @cols = @data_cols + ', ' +@label_cols

			
			IF @is_html = 'n'
			BEGIN
				SET @cols = REPLACE(@cols, ' AS', ') AS ')
				SET @cols = 'dbo.FNAStripHTML(' + REPLACE(@cols, ',', ', dbo.FNAStripHTML(')
			END


			EXEC spa_print '****************************************SELECT gauge Columns START****************************************:' 
				, @cols,'****************************************SELECT gauge Columns END******************************************:'
		END
		
		/*****************************************Generate SELECT clause END****************************************/
		
			
		
		
		
		
		
		/*****************************************Generate FROM clause START**************************************/		
		/*
		* All datasets are defined in report_dataset which can easily be retrieved using simple query. 
		* But relationship level needs to be identified so that first order dataset 
		* (those which are directly connected to main dataset) are picked first, instead of second order dataset 
		* (those which are connected to first order dataset). So CTE is used to resolve relationship level 
		*/
		DECLARE @from_clause VARCHAR(MAX)
		DECLARE @is_free_from BIT = 0 -- 0: free form is not used, 1: free from is used  
		DECLARE @relational_sql VARCHAR(MAX)
		DECLARE @view_index INT
			
		--SET @view_index = CHARINDEX(@view_identifier, @data_source_tsql)
		--PRINT 'View Index: ' + ISNULL(CAST(@view_index AS VARCHAR), '@view_index IS NULL')	
		
		SET @sqln = '
		IF EXISTS (
			SELECT 1
			FROM ' + @rfx_report_paramset + ' rp
			INNER JOIN ' + @rfx_report_page + ' rpage ON rpage.report_page_id = rp.page_id
			INNER JOIN ' + @rfx_report_dataset + ' rd ON rpage.report_id =rd.report_id
				AND rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = ' + @root_dataset_id + '
			WHERE rp.report_paramset_id = ' + @paramset_id	 + '
			AND rd.is_free_from = 1 
		)
		BEGIN 
			SET @is_free_from = 1
		END
		'
		EXEC sp_executesql @sqln, N'@is_free_from BIT OUTPUT', @is_free_from OUT
		--SELECT @is_free_from RETURN

		IF @is_free_from = 1 
		BEGIN 
			SET @sqln = '
			SELECT @relational_sql = ''FROM [''+ rd.alias + ''] '' + rd.relationship_sql
			FROM ' + @rfx_report_paramset + ' rp
			INNER JOIN ' + @rfx_report_page + ' rpage ON rpage.report_page_id = rp.page_id
			INNER JOIN ' + @rfx_report_dataset + ' rd ON rpage.report_id =rd.report_id
				AND rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = ' + @root_dataset_id + '
			WHERE rp.report_paramset_id = ' + @paramset_id + '
			'
			EXEC sp_executesql @sqln, N'@relational_sql VARCHAR(MAX) OUTPUT', @relational_sql OUT
			
			--DECLARE @temp_map TABLE 
			--(
			--	start_index				INT	
			--	,report_dataset_id		VARCHAR(100)
			--	,root_dataset_id		VARCHAR(100)
			--	,source_id				INT
			--	, alias					VARCHAR(100)
			--)
			IF OBJECT_ID('tempdb..#temp_map') IS NOT NULL
				DROP TABLE #temp_map
			CREATE TABLE #temp_map 
			(
				start_index				INT	
				,report_dataset_id		VARCHAR(100) COLLATE DATABASE_DEFAULT 
				,root_dataset_id		VARCHAR(100) COLLATE DATABASE_DEFAULT 
				,source_id				INT
				, alias					VARCHAR(100) COLLATE DATABASE_DEFAULT 
			)			
			
			SET @sql = '
			;WITH cte_dataset_hierarchy (report_dataset_id,  root_dataset_id, ALIAS, source_id, is_free_from, relationship_sql) 
					AS 
			( 
				SELECT  rd.report_dataset_id, rd.root_dataset_id, rd.alias, rd.source_id, rd.is_free_from, rd.relationship_sql
						FROM ' + @rfx_report_paramset + ' rp
						INNER JOIN ' + @rfx_report_page + ' rpage ON rpage.report_page_id = rp.page_id
						INNER JOIN ' + @rfx_report_dataset + ' rd ON rpage.report_id =rd.report_id
							AND rd.root_dataset_id IS NULL
							AND rd.report_dataset_id = ' + @root_dataset_id + '
						WHERE rp.report_paramset_id = ' + @paramset_id + '
				
				UNION ALL
				
				SELECT rd_child.report_dataset_id, rd_child.root_dataset_id, rd_child.alias, rd_child.source_id, rd_child.is_free_from, rd_child.relationship_sql
						FROM cte_dataset_hierarchy cdr
						INNER JOIN ' + @rfx_report_dataset + ' rd_child ON rd_child.root_dataset_id = cdr.report_dataset_id
			)
	
			INSERT INTO #temp_map(
				start_index,
				report_dataset_id,
				root_dataset_id,
				source_id,
				alias
			)
			SELECT  n, cdh.report_dataset_id, cdh.root_dataset_id, cdh.source_id, cdh.alias
			FROM cte_dataset_hierarchy cdh
			INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = cdh.report_dataset_id
			LEFT JOIN dbo.seq pos_alias_name ON pos_alias_name.n <= LEN(''' + @relational_sql + ''')
				AND SUBSTRING(''' + @relational_sql + ''', pos_alias_name.n, LEN(''['' + cdh.alias + '']''))  = ''['' + rd.alias + '']''
			'
			EXEC(@sql)
			
			SELECT @relational_sql =  
				CASE WHEN CHARINDEX(@batch_identifier, MAX(ds.[tsql])) > 0 OR CHARINDEX(@view_result_identifier, MAX(ds.[tsql])) > 0 THEN
					STUFF(@relational_sql, MAX(tm.start_index), 0, dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id))
				ELSE
					STUFF(@relational_sql, MAX(tm.start_index), 0, '('+ MAX(ds.[tsql]) + ')')
				END 
			FROM #temp_map tm
			INNER JOIN data_source ds ON ds.data_source_id = tm.source_id
			GROUP BY start_index
			ORDER BY start_index DESC --start replacing the source from the end such that the position of the alias doesnt change.

			SELECT	@from_clause = @relational_sql
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#dataset_join_option') IS NOT NULL
			DROP TABLE #dataset_join_option
			
			SELECT dataset_join.* INTO #dataset_join_option 
			FROM ( 
				SELECT 1 [id], 'INNER JOIN ' [Description] UNION
				SELECT 2 [id], 'LEFT JOIN '  [Description] UNION
				SELECT 3 [id], 'FULL JOIN ' [Description] 
			) dataset_join	

			IF OBJECT_ID('tempdb..#tmp_cte_dataset_rel') IS NOT NULL
				DROP TABLE #tmp_cte_dataset_rel
			CREATE TABLE #tmp_cte_dataset_rel 
			(
				dataset_id				INT	
				, source_id		INT
				, [alias]		VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, from_alias				VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, from_column_id INT
				, to_alias VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, to_column_id INT
				, relationship_level INT
				, join_type INT
			)

			SET @sql = '
			;WITH cte_dataset_rel (dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, relationship_level, join_type) 
			AS 
			( 
				--main dataset
					SELECT rd.report_dataset_id, rd.source_id, rd.[alias], rd.[alias] from_alias, NULL from_column_id, CAST(NULL AS VARCHAR(100)) to_alias, NULL to_column_id, 0 relationship_level , NULL join_type
				FROM ' + @rfx_report_paramset + ' rp
				INNER JOIN ' + @rfx_report_page + ' rpage ON rpage.report_page_id = rp.page_id
				INNER JOIN ' + @rfx_report_dataset + ' rd ON rpage.report_id =rd.report_id
					AND rd.root_dataset_id IS NULL
					AND rd.report_dataset_id = ' + @root_dataset_id + '
				WHERE rp.report_paramset_id = ' + @paramset_id + '
			
				UNION ALL
			
				--connected dataset
					SELECT rdr.from_dataset_id, rd_main.source_id, rd_main.[alias], rd_from.[alias] from_alias, rdr.from_column_id, cdr.from_alias to_alias, rdr.to_column_id, (cdr.relationship_level + 1) relationship_level ,rdr.join_type join_type
				FROM cte_dataset_rel cdr
				INNER JOIN ' + @rfx_report_dataset_relationship + ' rdr ON rdr.to_dataset_id = cdr.dataset_id
				INNER JOIN ' + @rfx_report_dataset + ' rd_from ON rdr.from_dataset_id = rd_from.report_dataset_id
				INNER JOIN ' + @rfx_report_dataset + ' rd_main ON rdr.from_dataset_id = rd_main.report_dataset_id
				WHERE rd_from.root_dataset_id = ' + @root_dataset_id + '
		
			)
			INSERT INTO #tmp_cte_dataset_rel
			SELECT * FROM cte_dataset_rel
			'
			EXEC(@sql)
			
		
		/*---------------------------------------------------------DEBUG START---------------------------------------------*/
		----raw tabular output of cte
		--SELECT dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, MAX(relationship_level) relationship_level
		--FROM cte_dataset_rel
		--GROUP BY dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id
		--ORDER BY relationship_level
		--return
		----join key combined
		--SELECT
		--STUFF((SELECT CHAR(10) + ' AND ' + (from_alias + '.' + QUOTENAME(CAST(from_column_id AS VARCHAR(30))) + ' = ' + to_alias + QUOTENAME(CAST(to_column_id AS VARCHAR(30))) ) 
		--FROM cte_dataset_rel
		----WHERE dataset_id = cte.dataset_id
		--FOR XML PATH('')
		--), 1, 5, '') join_cols
		--return
		/*---------------------------------------------------------DEBUG END---------------------------------------------*/
		
		SELECT @from_clause = 
			STUFF(
			(
					SELECT CHAR(10) + (CASE WHEN MAX(relationship_level) = 0 THEN ' FROM ' ELSE 
						MAX(djo.[description]) 
																												 END) 
					+  CASE WHEN CHARINDEX(@batch_identifier, MAX(ds.[tsql])) > 0 OR CHARINDEX(@view_result_identifier, MAX(ds.[tsql])) > 0
						THEN dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id)
								--WHEN CHARINDEX(@view_identifier, MAX(ds.[tsql])) > 0  AND CHARINDEX(@batch_identifier, dbo.FNAGetViewTsql(MAX(ds.[tsql]))) > 0 
								--	THEN  dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id)--'('+ dbo.FNAGetViewTsql(MAX(ds.[tsql])) + ')'	
								WHEN CHARINDEX(@view_identifier, MAX(ds.[tsql])) > 0 
									THEN dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id)
						ELSE '(' + MAX(ds.[tsql]) + ')'
						END										--datasource
					+ ' ' + QUOTENAME(MAX(cte.[alias]))			--datasource [alias]
					+ ISNULL(' ON ' + MAX(join_cols), '') 		--join keys
				FROM
				(
						SELECT dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, MAX(relationship_level) relationship_level, join_type
					FROM #tmp_cte_dataset_rel
						GROUP BY dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, join_type
					--ORDER BY relationship_level
				) cte
				INNER JOIN data_source ds ON ds.data_source_id = cte.source_id
				OUTER APPLY (
					 SELECT
					   STUFF(
				   		(
				   		   SELECT DISTINCT ' AND ' + CAST((from_alias + '.' + QUOTENAME(dsc_from.name) + ' = ' + to_alias +  '.' + QUOTENAME(dsc_to.name)) AS VARCHAR(MAX)) 
						   FROM #tmp_cte_dataset_rel cdr_inner
						   INNER JOIN data_source_column dsc_from ON cdr_inner.from_column_id = dsc_from.data_source_column_id
						   INNER JOIN data_source_column dsc_to ON cdr_inner.to_column_id = dsc_to.data_source_column_id
						   WHERE cdr_inner.dataset_id = cte.dataset_id
						   FOR XML PATH(''), TYPE
					   ).value('.[1]', 'VARCHAR(MAX)'), 1, 5, '') join_cols
				) join_key_set
					LEFT  JOIN  #dataset_join_option djo ON djo.id = cte.join_type
					GROUP BY dataset_id, cte.join_type
					ORDER BY MAX(relationship_level), cte.join_type 
				FOR XML PATH(''), TYPE
			).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '') 
		END
			
		EXEC spa_print '****************************************FROM clause START****************************************:' 
			,@from_clause,'****************************************FROM clause END******************************************:'
	
	
		--RETURN
		/*****************************************Generate FROM clause END**************************************/	
			
		
	
	
	
		/*****************************************Generate WHERE clause START**************************************/	
		DECLARE @params_final	VARCHAR(MAX)
		DECLARE @where_part		VARCHAR(MAX)
		/*
		* Removed the logic to generate the hidden parameter and required parameter 
		* as it will be generated in the where_part of the of report_dataset_paramset table
		* from the front end.
		
		DECLARE @params_hidden	VARCHAR(MAX)
		
		SET @params_hidden = (
								SELECT
									 STUFF(
											(
												SELECT ' AND ' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.name)
												+ ' ' +  rpo.sql_code + ' '
												+ CASE WHEN --rpo.sql_code = 'BETWEEN' THEN 
													rpo.report_param_operator_id = 8 THEN	--BETWEEN
													CASE WHEN  rdt.report_datatype_id IN(1, 2, 5) THEN QUOTENAME(ISNULL(rp.initial_value, '') ,'''') + ' AND  ' +  QUOTENAME(ISNULL(rp.initial_value2, ''),'''')
														ELSE +  ISNULL(rp.initial_value,'')  + ' AND  ' + ISNULL(rp.initial_value2, '')  
													END
												WHEN rpo.report_param_operator_id IN (6, 7) THEN ''
												WHEN rpo.report_param_operator_id IN (9, 10) THEN
													 '(' +
													  CASE WHEN  rdt.report_datatype_id IN(1, 2, 5) THEN  QUOTENAME(ISNULL(rp.initial_value, ''),'''')
															ELSE + ISNULL(rp.initial_value,'') 
													  END 
													 + ')' 
												ELSE 
													CASE WHEN  rdt.report_datatype_id IN(1, 2, 5) THEN QUOTENAME(ISNULL(rp.initial_value,''),'''')
														ELSE  + ISNULL(rp.initial_value,'')
													 END 
												END 	
												FROM report_param rp 
												INNER JOIN report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
												INNER JOIN report_dataset rd ON rd.report_dataset_id = rp.dataset_id
												INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id 
												INNER JOIN report_param_operator rpo ON rpo.report_param_operator_id = rp.operator 
												INNER JOIN report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
												WHERE rdp.root_dataset_id = @root_dataset_id
													AND  rdp.paramset_id = @paramset_id 
													AND dsc.append_filter = 1
													AND (rp.hidden = 1 OR dsc.reqd_param = 1)											
												 FOR XML PATH(''), TYPE
												).value('.[1]', 'VARCHAR(MAX)'), 1, 5, ''
											 )	
										)							 
		
		*/
		DECLARE @has_opt_param INT, @advance_mode int
		SET @sqln = '
		SELECT @has_opt_param = 1 FROM ' + @rfx_report_param + ' rp 
		INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp
			ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
		WHERE rdp.root_dataset_id = ' + @root_dataset_id + '
			AND rdp.paramset_id = ' + @paramset_id + '
			AND rp.optional = 1

		SELECT @advance_mode = 1 FROM ' + @rfx_report_dataset_paramset + ' rdp
		WHERE rdp.root_dataset_id = ' + @root_dataset_id + '
			AND rdp.paramset_id = ' + @paramset_id + '
			AND rdp.advance_mode = 1
		'
		EXEC sp_executesql @sqln, N'@has_opt_param INT OUTPUT,@advance_mode INT OUTPUT', @has_opt_param OUT, @advance_mode OUT
		
		IF @has_opt_param = 1 and isnull(@advance_mode, 0) = 0
		BEGIN 
			--SET  @where_part =  dbo.FNARFXReplaceOptionalParam(@paramset_id, @root_dataset_id)
			--where part calculation
			IF OBJECT_ID('tempdb..#temp_map_tbl') IS NOT NULL
				DROP TABLE #temp_map_tbl
			CREATE TABLE #temp_map_tbl 
			(
				alias				VARCHAR(100) COLLATE DATABASE_DEFAULT 	--dataset alias
				, name				VARCHAR(500) COLLATE DATABASE_DEFAULT 	--column name                                                                                     
				, combined_name		VARCHAR(1000) COLLATE DATABASE_DEFAULT 	--name with alias (e.g. sdp.term_start)
				, start_index		INT				--start index of optional parameter clause (for debuggin purpose)
				, param_index		INT				--start index of parameter value in optional parameter clause (for debuggin purpose)
				, end_index			INT				--end index of optional parameter clause
			)
	
			DECLARE @new_where_part VARCHAR(5000)
			
			SET @sqln = '
			SELECT @new_where_part =(SELECT where_part FROM ' + @rfx_report_dataset_paramset + ' WHERE root_dataset_id = ' + @root_dataset_id + ' AND  paramset_id = ' + @paramset_id + ')
			'
			EXEC sp_executesql @sqln, N'@new_where_part VARCHAR(5000) OUTPUT', @new_where_part OUT
			
			--can we use group by to avoid possible duplication?
			SET @sql = '
			INSERT INTO #temp_map_tbl(alias, name, combined_name, start_index, param_index, end_index)
			SELECT 
			rd.alias, dsc.name, (rd.alias + ''.'' + QUOTENAME(dsc.name)) combined_name, pos_param_name.n AS start_index, pos_param_value_start.n param_index, ISNULL(pos_param_value_end.n, LEN(rdp.where_part) + 1) end_index 
			FROM ' + @rfx_report_dataset_paramset + ' rdp 
			INNER JOIN ' + @rfx_report_param + ' rp  ON rp.dataset_paramset_id = rdp.report_dataset_paramset_id
			--INNER JOIN ' + @rfx_report_paramset + ' rps ON rps.report_paramset_id = rp.dataset_paramset_id
			--INNER JOIN ' + @rfx_report_page + ' rpage ON rps.page_id = rpage.report_page_id
			INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rp.dataset_id
			INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id 
			INNER JOIN report_param_operator rpo ON rpo.report_param_operator_id = rp.operator
			--find the first occurence of param_name
			INNER JOIN dbo.seq pos_param_name ON pos_param_name.n <= LEN(rdp.where_part)
				AND SUBSTRING(rdp.where_part, pos_param_name.n, LEN(rd.alias + ''.'' + QUOTENAME(dsc.name))) = rd.alias + ''.'' + QUOTENAME(dsc.name)
			--find the first occurence of param_value after param_name
			OUTER APPLY (
				SELECT TOP 1 n
				FROM dbo.seq
				WHERE n <= LEN(rdp.where_part)
					-- if operator is BETWEEN, pick up second param_value, which starts with 2_ (two characters)
					--1 is added in every case to compensate for @ in the start of the parameter name
					AND SUBSTRING(rdp.where_part, n, LEN(dsc.name) + (CASE WHEN rpo.report_param_operator_id = 8 THEN 3 ELSE 1 END)) 
						 = ''@'' + (CASE WHEN rpo.report_param_operator_id = 8 THEN (''2_'' + dsc.name ) ELSE dsc.name  END) 
					AND n > pos_param_name.n	--index must be greater than start_index
				ORDER BY n
			) pos_param_value_start
			--find the first occurence of space or newline after param_value
			OUTER APPLY (
				SELECT TOP 1 n
				FROM dbo.seq 
				WHERE n <= LEN(rdp.where_part)
					AND SUBSTRING(rdp.where_part, n, 1) IN ('' '', CHAR(9), CHAR(10), CHAR(13))
					AND n > pos_param_value_start.n	--index must be greater than param_index
				ORDER BY n 
			) pos_param_value_end	
			WHERE  rdp.root_dataset_id = ' + @root_dataset_id + '
				AND rdp.paramset_id = ' + @paramset_id + '
				AND rp.optional = 1
				AND rpo.report_param_operator_id NOT IN (6, 7)
			'
			EXEC(@sql)
		
			--SELECT * FROM @temp_map

			--Append ending parenthesis [)] of parameter nullifying clause
			--ORDER BY clause is very important here as appending ) from right preserves index of previous matches from left
			SELECT @new_where_part = STUFF(@new_where_part + ' ', map.end_index, 0, ')')--, map.*
			FROM #temp_map_tbl map
			ORDER BY map.end_index DESC

			--Replace param_name to append paramter nullifying start section [('@term_start' = 'NULL' OR sdp.term_start...]
			SELECT @new_where_part = REPLACE(@new_where_part, map.combined_name, '(' + QUOTENAME('@' + map.name, '''') + ' = ''NULL'' OR ' + map.combined_name)
			FROM #temp_map_tbl map

			SET @where_part = @new_where_part
			
			--where part calculation
		END 
		ELSE 
		BEGIN
			SET @sqln = '
			SELECT @where_part = (SELECT where_part FROM ' + @rfx_report_dataset_paramset + '  WHERE root_dataset_id = ' + @root_dataset_id + ' AND paramset_id = ' + @paramset_id + ' )
			'
			EXEC sp_executesql @sqln, N'@where_part VARCHAR(5000) OUTPUT', @where_part OUT
		END 
		
		--SET @params_final = ISNULL(@params_hidden, ' 1 = 1 ')  + ISNULL(' AND ' + NULLIF(@where_part, ''), '')
		SET @params_final = ISNULL(NULLIF(@where_part,''), '1 = 1')
	
		EXEC spa_print '****************************************WHERE clause START****************************************:' 
			,@params_final,'****************************************WHERE clause END******************************************:'
		/*****************************************Generate WHERE clause END **************************************/
		
		
		
		
		/*****************************************Generate GROUP BY clause START**************************************/
		DECLARE @group_by VARCHAR(8000) = NULL
		/*
		* Build GROUP BY clause only if 
		*  a)aggregation used in any detail columns i.e (AND rtc.sql_aggregation IS NOT NULL AND rtc.placement = 1)
		* 	 i.e @query_level_grouping_reqd = 1.
		* All the columns besides columns that have aggregate function are listed in the GROUP BY clause
		* i.e columns of both placement (1 and 2)
		*/
		--IF @display_type = 't'
		--BEGIN
		--	IF @query_level_grouping_reqd = 1 
		--	BEGIN 	
		--		 SELECT @group_by = STUFF(
 	--										(
		--									SELECT ', ' + ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]))
		--									FROM report_paramset rp
		--									INNER JOIN report_page_tablix rt ON rt.report_page_tablix_id = @component_id 
		--									INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rt.report_page_tablix_id
		--									LEFT JOIN report_dataset rd ON rd.report_dataset_id = rtc.dataset_id
		--									--use LEFT JOIN as custom fields won't have column_id value
		--									LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
		--										WHERE rp.report_paramset_id = @paramset_id
		--									--	AND rtc.placement <> 2 
		--										AND rtc.sql_aggregation IS NULL 
		--										--AND rt.[type_id] = 1
		--									FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	

		--	END 
		--END
		IF @display_type = 't' AND @query_level_grouping_reqd = 1
			BEGIN 	
				SET @sqln = '
				SELECT @group_by = STUFF(
 											(
											SELECT '', '' + ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]))
											FROM ' + @rfx_report_paramset + ' rp
											INNER JOIN ' + @rfx_report_page_tablix + ' rt ON rt.report_page_tablix_id = ' + @component_id + '
											INNER JOIN ' + @rfx_report_tablix_column + ' rtc ON rtc.tablix_id = rt.report_page_tablix_id
											LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rtc.dataset_id
											--use LEFT JOIN as custom fields will not have column_id value
											LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
											WHERE rp.report_paramset_id = ' + @paramset_id + '
											--	AND rtc.placement <> 2 
												AND rtc.sql_aggregation IS NULL 
												--AND rt.[type_id] = 1
											FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''')	
				'
				EXEC sp_executesql @sqln, N'@group_by VARCHAR(8000) OUTPUT', @group_by OUT
				
			END 
		
		IF @display_type = 'c' AND @query_level_grouping_reqd = 1
		BEGIN
			SET @sqln = '
			SELECT @group_by = STUFF(
									(
									SELECT '', '' + ISNULL(rcc.functions, QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]))
									FROM ' + @rfx_report_paramset + ' rp
									INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rpc.report_page_chart_id = ' + @component_id + ' 
									INNER JOIN ' + @rfx_report_chart_column + ' rcc ON rcc.chart_id = rpc.report_page_chart_id
									LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rcc.dataset_id
									--use LEFT JOIN as custom fields will not have column_id value
									LEFT JOIN data_source_column dsc ON rcc.column_id = dsc.data_source_column_id 
										WHERE rp.report_paramset_id = ' + @paramset_id + '
									--	AND rtc.placement <> 2 
										AND rcc.aggregation IS NULL 
										--AND rt.[type_id] = 1
									FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''')	
			'
			EXEC sp_executesql @sqln, N'@group_by VARCHAR(8000) OUTPUT', @group_by OUT
		END
		
		IF @display_type = 'g' AND @query_level_grouping_reqd = 1
		BEGIN
			DECLARE @label_cols_group VARCHAR(MAX)
			
			/*Group by gauge columns that donot have aggregate logic*/
			SET @sqln = '
			SELECT @group_by = STUFF((
									SELECT '', '' + ISNULL(rgc.functions, QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]))
									FROM ' + @rfx_report_paramset + ' rp
									INNER JOIN ' + @rfx_report_page_gauge + ' rpg ON rpg.report_page_gauge_id = ' + @component_id + ' 
									INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON rgc.gauge_id = rpg.report_page_gauge_id
									LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rgc.dataset_id
									--use LEFT JOIN as custom fields won''t have column_id value
									LEFT JOIN data_source_column dsc ON rgc.column_id = dsc.data_source_column_id 
										WHERE rp.report_paramset_id = ' + @paramset_id + '
									--	AND rtc.placement <> 2 
										AND rgc.aggregation IS NULL 
										--AND rt.[type_id] = 1
									FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''')
			'
			EXEC sp_executesql @sqln, N'@group_by VARCHAR(8000) OUTPUT', @group_by OUT
			
			/*Group by Label columns*/
			SET @sqln = '
			SELECT @label_cols_group = STUFF((
											SELECT DISTINCT '', '' + 		
												CASE WHEN dsc.widget_id = 6 
													THEN '' dbo.FNADateFormat('' + QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) + '') '' 
													ELSE QUOTENAME(rd.[alias]) + ''.'' + QUOTENAME(dsc.[name]) 
												END 
											FROM ' + @rfx_report_paramset + ' rp
											INNER JOIN ' + @rfx_report_page_gauge + ' rpg ON rpg.report_page_gauge_id = ' + @component_id + '
											INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON rgc.gauge_id = rpg.report_page_gauge_id
											INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rgc.dataset_id
											LEFT JOIN #column_aggregation_option cao ON cao.id  = rgc.aggregation
											INNER JOIN data_source_column dsc ON rpg.gauge_label_column_id = dsc.data_source_column_id 
											WHERE rp.report_paramset_id = ' + @paramset_id + '
											FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(MAX)''), 1, 1, '''')
			'
			EXEC sp_executesql @sqln, N'@label_cols_group VARCHAR(MAX) OUTPUT', @label_cols_group OUT
			
			SELECT  @group_by = ISNULL(NULLIF(@group_by, '') + ',', '') + @label_cols_group
		END	
				
				
		EXEC spa_print  '****************************************GROUP BY clause START****************************************:' 
			,@group_by, '****************************************GROUP BY clause END******************************************:'							
								
		/*****************************************Generate GROUP BY clause END**************************************/	
		
		
		/*****************************************Generate ORDER BY clause START**************************************/
		DECLARE @order_by VARCHAR(8000)
		
		IF @display_type = 't'
		BEGIN 
			SET @sqln = '
			SELECT @order_by = STUFF(
	 								(
										SELECT '', '' + QUOTENAME(rtc.[alias])
										+ CASE WHEN rtc.default_sort_direction = 2 THEN '' DESC''
												ELSE '''' 
										  END
										FROM ' + @rfx_report_paramset + ' rp
										INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON rpt.report_page_tablix_id = ' + @component_id + '
										INNER JOIN ' + @rfx_report_tablix_column + ' rtc ON rtc.tablix_id = rpt.report_page_tablix_id
										LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rtc.dataset_id 
										--use LEFT JOIN as custom fields will not have column_id value
										LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
										WHERE rp.report_paramset_id = ' + @paramset_id + '
											AND rtc.default_sort_order <> 0
										ORDER BY rtc.default_sort_order ASC 
									FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''')	
			'
			EXEC sp_executesql @sqln, N'@order_by VARCHAR(8000) OUTPUT', @order_by OUT
		 END 
		 ELSE IF @display_type = 'c'
		 BEGIN
			SET @sqln = '
		 	SELECT @order_by = STUFF(
		 							(
									SELECT '', '' + QUOTENAME(rcc.[alias])
									+ CASE WHEN rcc.default_sort_direction = 2 THEN '' DESC''
										ELSE '''' 
										END
									FROM ' + @rfx_report_paramset + ' rp
									INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rpc.report_page_chart_id = ' + @component_id + '
									INNER JOIN ' + @rfx_report_chart_column + ' rcc ON rcc.chart_id = rpc.report_page_chart_id
									LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rcc.dataset_id
									--use LEFT JOIN as custom fields woill not have column_id value
									LEFT JOIN data_source_column dsc ON rcc.column_id = dsc.data_source_column_id 
									WHERE rp.report_paramset_id = ' + @paramset_id + '
										AND rcc.placement = 3 --(category field X axis)
									ORDER BY rcc.default_sort_order ASC --(maintain the order of columns to order by)
								FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''')	
			'
			EXEC sp_executesql @sqln, N'@order_by VARCHAR(8000) OUTPUT', @order_by OUT	
		 	
		 END
			
		
		EXEC spa_print  '****************************************ORDER BY clause START****************************************:' 
			,@order_by,'****************************************ORDER BY clause END******************************************:'									
								
		/*****************************************Generate ORDER BY clause END**************************************/		
	
	
		
	
	
		/*****************************************Generate Master Query START**************************************/
		DECLARE @parameterized_stmnt  VARCHAR(MAX)
		
		SET @parameterized_stmnt = 'SELECT ' + ISNULL(@cols, '*') + @from_clause + ISNULL(' WHERE ' + @params_final, '') + ISNULL(' GROUP BY ' + @group_by, '') + ISNULL(' ORDER BY ' + @order_by, '')

		
		EXEC spa_print '****************************************Master Query START****************************************:' 
			,@parameterized_stmnt, '****************************************Master Query START******************************************:'
		/*****************************************Generate Master Query START**************************************/
		
	
		
		
	
		/*****************************************Replacing Parameters START**************************************/
		DECLARE @final_query  VARCHAR(MAX)
		SET @final_query = dbo.FNARFXReplaceReportParams(@parameterized_stmnt, @criteria, @paramset_id)
		
		EXEC spa_print '****************************************FINAL SQL START****************************************:' 
			,@final_query,'****************************************FINAL SQL END******************************************:'
		/*****************************************Replacing Parameters END **************************************/
		
	

		
		
		/*****************************************Generate Final Batch START**************************************/
		DECLARE @str_batch_table VARCHAR(MAX)
		SET @str_batch_table = ''
		SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @final_query, 0)
		
		IF @batch_process_id IS NULL 
		BEGIN
			IF @temp_table_name IS NOT NULL 
				--add an auto-number column while inserting in process table. Altering process table to add sno later distorts the data order
				SET @str_batch_table = ' INTO ' + @temp_table_name 
		END
		ELSE
		BEGIN
			--add an auto-number column while inserting in process table. Altering process table to add sno later distorts the data order
			SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)
		END
		
		EXEC spa_print 'Batch table name:' , @str_batch_table
		IF ISNULL(@str_batch_table, '') <> ''
			SET @final_query = SUBSTRING(@final_query, 0, @from_index) + @str_batch_table + ' ' +  SUBSTRING(@final_query, @from_index, LEN(@final_query))
		
		SET @final_sql = @final_query
				
		EXEC spa_print  '****************************************Final Batch SQL Started****************************************:' 
			,@final_sql,'****************************************Final Batch SQL Ended******************************************:'
		/*****************************************Generate Final Batch END **************************************/	


	END TRY
	BEGIN CATCH
		--EXEC spa_print 'ERROR: ' + ERROR_MESSAGE()
		DECLARE @error_msg	VARCHAR(1000)
		SET @error_msg = 'Error building Report SQL.' + ERROR_MESSAGE()
		
		IF CURSOR_STATUS('local', 'cur_data_source') >= 0 
		BEGIN
			CLOSE cur_data_source
			DEALLOCATE cur_data_source;
		END
		
		--Raise error to let the SQL Agent job that this job failed. The failed job triggers another job which updates the 
		--message board error message.
		RAISERROR (@error_msg, -- Message text.
				   16, -- Severity.
				   1 -- State.
               );
		
	END CATCH

END
GO
