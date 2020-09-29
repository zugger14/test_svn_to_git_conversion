IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].spa_rfx_build_query') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].spa_rfx_build_query
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Builds a runnable SQL query from a Report Builder

	Parameters
	@paramset_id			: Parameter set ID
	@component_id			: Component ID
	@criteria				: Parameter and their values 
	@temp_table_name		: Temp table for batch processing 
	@display_type			: t = Tabular Display, c = Chart Display
	@is_html				: HTML Rendering or Not
	@batch_process_id		: Batch Process ID
	@batch_report_param		: Batch parameter
	@call_from				: Call From
	@final_sql				: Final runnable sql query returned , OUTPUT variable
*/

CREATE PROCEDURE [dbo].spa_rfx_build_query
	@paramset_id			INT = NULL
	, @component_id			INT = NULL
	, @criteria				VARCHAR(MAX) = NULL
	, @temp_table_name		VARCHAR(100) = NULL
	, @display_type			CHAR(1) = 't'
	, @is_html				CHAR(1) = 'y'
	, @batch_process_id		VARCHAR(50) = NULL
	, @batch_report_param	VARCHAR(1000) = NULL
	, @call_from			VARCHAR(20) = NULL
	, @final_sql			VARCHAR(MAX) OUTPUT

AS
--/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
	@paramset_id			INT = NULL
	, @component_id			INT = NULL
	, @criteria				VARCHAR(5000) = NULL
	, @temp_table_name		VARCHAR(100) = NULL
	, @display_type			CHAR(1) = 't'
	, @is_html				CHAR(1) = 'y'
	, @batch_process_id		VARCHAR(50) = NULL
	, @batch_report_param	VARCHAR(1000) = NULL
	, @call_from			VARCHAR(20) = NULL
	, @final_sql			VARCHAR(MAX) 
	
	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON'); SET CONTEXT_INFO @contextinfo
	
	set @paramset_id	= 38476
	set @component_id = 37833		
	--set @paramset_id	= NULL	
	--set @criteria	= 'source_deal_header_id = 3212,term_start= NULL,source_system_id = 2'
	set @criteria	= 'sub_id=1376,stra_id=1377,book_id=1378,sub_book_id=3348,source_deal_header_id=NULL,deal_id=NULL,as_of_date=NULL,deal_date_from=0|0|106400|n,deal_date_to=NULL,term_start=2019-05-03,term_end=2019-05-01,counterparty_id=NULL,contract_id=NULL,trader_id=NULL,location_id=NULL,buy_sell_flag=NULL,detail_phy_fin_flag=NULL,commodity_id=NULL,source_deal_type_id=NULL,curve_id=NULL,pricing_index=NULL,pricing_type=NULL,pricing_period=NULL'
	set @display_type = 't'
	--set @criteria = 'source_counterparty_id = 1'
	--SET @temp_table_name = '#temp_table'
	--set @batch_process_id	= '1111'
	--set @batch_report_param = 'a'
	--SET @sql_source_tsql = '--[__batch_report__]   
	--                        SELECT  template_id,template_name FROM  source_deal_header_template  '
	--SET @sql_source_alias = 'test'
	--SET @validate = 1
	                     
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/

BEGIN
	SET NOCOUNT ON; -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	
	DECLARE @root_dataset_id				INT
	DECLARE @from_index						INT
	DECLARE @batch_identifier				VARCHAR(100)
	DECLARE @view_identifier				VARCHAR(100)
	DECLARE @data_source_process_id			VARCHAR(50)
	DECLARE	@data_source_tsql				VARCHAR(MAX)
	DECLARE @data_source_alias				VARCHAR(50)
	DECLARE @hidden_criteria_not_appended	VARCHAR(5000)	
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
		SELECT @root_dataset_id = root_dataset_id  
		FROM report_page_tablix rpt WHERE rpt.report_page_tablix_id = @component_id
	ELSE IF @display_type = 'c'
		SELECT @root_dataset_id = root_dataset_id  
		FROM report_page_chart rpc WHERE rpc.report_page_chart_id = @component_id
	ELSE IF @display_type = 'g'
		SELECT @root_dataset_id = root_dataset_id  
		FROM report_page_gauge rpg WHERE rpg.report_page_gauge_id = @component_id
	
	/******************************Hidden not appending criteria generation START*********************************/
	--generate criteria for hidden params, whose append filter is false, means it is used in View and won't participate in where clause.
	--Value for such parameter should be supplied in Criteria
	SELECT @hidden_criteria_not_appended =	STUFF((
		--treat blank value as NULL for initial value. Otherwise it gives problem in book structure filter query generation
		-- [AND ('' = 'NULL' OR sub.entity_id IN ()) AND ('312' = 'NULL' OR stra.entity_id IN (312)) AND ('' = 'NULL' OR book.entity_id IN ())]
		--comma has to be replaced by !(exclamation) sign to parse correctly in spa_html_header 
		SELECT ',' + dsc.[name] + '=' + ISNULL(NULLIF(REPLACE(rp.initial_value, ',', '!'), ''), 'NULL') 
			+ (CASE WHEN rp.operator = 8 THEN ',2_' + dsc.[name] + '=' + ISNULL(REPLACE(rp.initial_value2, ',', '!'), 'NULL') ELSE '' END)
		FROM report_param rp
		INNER JOIN report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id
		WHERE rdp.paramset_id = @paramset_id
			AND rdp.root_dataset_id = @root_dataset_id
			AND ISNULL(rp.hidden, 0) = 1
			--TODO: figure out why append_filter is required. It caused problem in case of hidden appending params. So it is removed now.
			--AND ISNULL(dsc.append_filter, 1) = 0
		FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(5000)'), 1, 1, '')
	
	IF @hidden_criteria_not_appended IS NOT NULL	
		SET @criteria = ISNULL(NULLIF(@criteria, '') + ',', '') + @hidden_criteria_not_appended
	
	EXEC spa_print  '****************************************SELECT Hidden non appending criteria START****************************************:' 
				,@hidden_criteria_not_appended,
				 '****************************************SELECT Hidden non appending criteria END******************************************:'
	/******************************Hidden not appending criteria generation END*********************************/				
		
	BEGIN TRY	
	
		DECLARE @process_table_name VARCHAR(500)

		IF OBJECT_ID('tempdb..#error_msg') IS NOT NULL
			DROP TABLE #error_msg

		CREATE TABLE #error_msg (error_msg VARCHAR(MAX) COLLATE DATABASE_DEFAULT)

		/******************************Datasource TSQL processing (if multiline) START*********************************/
		DECLARE cur_data_source CURSOR LOCAL FOR
		
		SELECT DISTINCT ds.[tsql], ds.[alias] 
		FROM report_paramset rp
		INNER JOIN report_page rpage ON rpage.report_page_id = rp.page_id
		CROSS APPLY (
			SELECT report_dataset_id, rd_inner.source_id, rd_inner.[alias] 
			FROM report_dataset rd_inner
			WHERE rd_inner.report_id = rpage.report_id
				AND ISNULL(rd_inner.root_dataset_id, rd_inner.report_dataset_id) = @root_dataset_id
		) rd
		INNER JOIN data_source ds ON rd.source_id = ds.data_source_id 
		WHERE rp.report_paramset_id = @paramset_id
			 
		OPEN cur_data_source   
		FETCH NEXT FROM cur_data_source INTO @data_source_tsql, @data_source_alias
		
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			EXEC spa_rfx_handle_data_source
				@data_source_tsql			
				, @data_source_alias		
				, @criteria					
				, @data_source_process_id	
				, 0	--@validate				
				, 0	--@handle_single_line_sql
				, @paramset_id
			--	, 'v'
				, 'y'


				SET @process_table_name = dbo.FNAProcessTableName('report_dataset_' + @data_source_alias, dbo.FNADBUser(), @data_source_process_id)
				
				IF COL_LENGTH(@process_table_name, 'Error_status') IS NOT NULL
				BEGIN
				
					DECLARE @error_msg1	VARCHAR(MAX)
					EXEC ('INSERT INTO #error_msg SELECT error_msg FROM ' + @process_table_name)
					
					SELECT @error_msg1 = '![( Error building Report SQL. ' + error_msg  + ' )]!'
					FROM #error_msg
					
					RAISERROR (@error_msg1, -- Message text.
						   16, -- Severity.
						   1 -- State.
					   );
				END

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
		DECLARE @sql VARCHAR(MAX)
		DECLARE @report_page_component_join	   VARCHAR(500)
		DECLARE @report_page_component_column_join	   VARCHAR(500)
		DECLARE @report_component_alias  VARCHAR(5)
		
		IF OBJECT_ID('tempdb..#query_level_grouping_reqd') IS NOT NULL
				DROP TABLE #query_level_grouping_reqd
		CREATE TABLE #query_level_grouping_reqd (is_grouping INT )

		IF @display_type = 't'
		BEGIN
			SET  @report_page_component_join = 'INNER JOIN report_page_tablix rpt ON  rpt.report_page_tablix_id'
			SET @report_page_component_column_join = 'INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rpt.report_page_tablix_id'
			set @report_component_alias = 'rtc'
		END 
		ELSE IF @display_type = 'c'
		BEGIN
			SET  @report_page_component_join = 'INNER JOIN report_page_chart rpc ON  rpc.report_page_chart_id'
			SET @report_page_component_column_join = 'INNER JOIN report_chart_column rcc ON rcc.chart_id = rpc.report_page_chart_id'
			set @report_component_alias = 'rcc'
		END
		ELSE IF @display_type = 'g'
		BEGIN
			SET  @report_page_component_join = 'INNER JOIN report_page_gauge rpg ON  rpg.report_page_gauge_id'
			SET @report_page_component_column_join = 'INNER JOIN report_gauge_column rgc ON rgc.gauge_id = rpg.report_page_gauge_id'
			set @report_component_alias = 'rgc'
		END
		
		SELECT @sql =
		'
		INSERT INTO  #query_level_grouping_reqd
		SELECT 1 FROM   report_paramset rp ' 
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

			IF OBJECT_ID('tempdb..#tmp_select_tablix_cols') IS NOT NULL
				DROP TABLE #tmp_select_tablix_cols

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
				 
			SELECT 
				CASE WHEN @query_level_grouping_reqd IS NULL THEN 
						ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])) + ' AS ' + QUOTENAME(rtc.[alias])
					 WHEN @query_level_grouping_reqd = 1 THEN
						CASE 
							WHEN rtc.sql_aggregation IS NOT NULL AND rtc.functions IS NOT NULL THEN
								--insert aggregation function
								--STUFF(rtc.functions 
								--	, CHARINDEX('(', rtc.functions) + 1	--start
								--	, 0 --do not delete any chars
								--	, cao.function_name + '('	--add aggregation function name
								--	) + ')' 
								--	+  ' AS ' + QUOTENAME(rtc.[alias])
								
					--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
								cao.function_name + '(' + rtc.functions + ')'
								+  ' AS ' + QUOTENAME(rtc.[alias])
							WHEN rtc.sql_aggregation IS NOT NULL AND rtc.placement <> 2 THEN cao.function_name + '(' + ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])) + ')' + ' AS ' + QUOTENAME(rtc.[alias])
							ELSE ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])) + ' AS ' + QUOTENAME(rtc.[alias])
						END 
				END  AS [cols_name], rtc.column_id, CAST(rtc.sorting_column AS INT) AS sorting_column, rd.[alias] AS rd_alias, rtc.[alias] AS rtc_alias, rtc.column_order,rtc.sql_aggregation		
				into #tmp_select_tablix_cols		
				FROM report_paramset rp
					INNER JOIN report_page_tablix rt ON rt.report_page_tablix_id = @component_id 
						AND rt.root_dataset_id = @root_dataset_id
				    INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rt.report_page_tablix_id
				    LEFT JOIN report_dataset rd ON rd.report_dataset_id = rtc.dataset_id
					LEFT JOIN #column_aggregation_option cao ON cao.id  = rtc.sql_aggregation
					--use LEFT JOIN as custom fields won't have column_id value
					LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
				WHERE rp.report_paramset_id = @paramset_id
				
				IF OBJECT_ID('tempdb..#tmp_select_tablix_cols2') IS NOT NULL
					DROP TABLE #tmp_select_tablix_cols2

				select 
				[cols_name], column_order
				into #tmp_select_tablix_cols2
				from #tmp_select_tablix_cols 
				
				-- Included sorting columns which are not included in select columns and if aggregation exists in tablix then function MAX is used in sorting column
				insert into #tmp_select_tablix_cols2(cols_name, column_order)
				SELECT 
				CASE WHEN sql_agg.agg_req = 1 THEN 'MAX(' ELSE '' END + QUOTENAME(t1.[rd_alias]) + '.' + QUOTENAME(dsc2.[name]) + CASE WHEN sql_agg.agg_req = 1 THEN ')' ELSE '' END + ' AS ' + QUOTENAME(ISNULL(dsc2.[alias],dsc2.[name])) AS [cols_name], 9999999
				FROM #tmp_select_tablix_cols t1 
				inner join data_source_column dsc2 on dsc2.data_source_column_id = t1.sorting_column
				left join #tmp_select_tablix_cols t2 on t2.column_id = t1.sorting_column AND t2.rtc_alias = ISNULL(dsc2.[alias],dsc2.[name])
				OUTER APPLY (SELECT TOP 1 1 agg_req FROM #tmp_select_tablix_cols WHERE sql_aggregation IS NOT NULL) sql_agg
				WHERE t2.column_id IS NULL

				--Debug code
				--select * into adiha_process.dbo.tmp_navaraj1 from #tmp_select_tablix_cols2

				SELECT @cols = STUFF(( 
					SELECT ', ' + [cols_name]
					from #tmp_select_tablix_cols2
					ORDER BY column_order
				FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	
			
			IF @is_html = 'n'
			BEGIN
				SET @cols = REPLACE(@cols, ' AS', ') AS ')
				SET @cols = 'dbo.FNAStripHTML(' + REPLACE(@cols, ',', ', dbo.FNAStripHTML(')
			END

		
		EXEC spa_print  '****************************************SELECT Tablix Columns START****************************************:' 
			,@cols, '****************************************SELECT Tablix Columns END******************************************:'
		END 
		--Retrieving columns to be displayed in Chart form
		ELSE IF @display_type = 'c'
		BEGIN 
			 SELECT @cols = STUFF((
				--SELECT ', ' + 
					
				--	CASE WHEN dsc.widget_id = 6 THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
				--		ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) END 
				
				--+  ' AS ' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias])) --Chart allows NULLABLE [alias] as it is not set in frontend 
					SELECT ', ' + 
					CASE WHEN @query_level_grouping_reqd IS NULL 
						THEN ISNULL(rcc.functions,
								--CASE WHEN dsc.widget_id = 6 
								--	THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
								--	ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
								--END 
								--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
								QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) 
						  )+ ' AS ' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))	
						WHEN @query_level_grouping_reqd = 1 THEN
							CASE 
								WHEN rcc.aggregation IS NOT NULL AND rcc.functions IS NOT NULL THEN		
								--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
									cao.function_name + '(' + rcc.functions + ')' +  ' AS ' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))
								WHEN rcc.aggregation IS NOT NULL  
									THEN cao.function_name + '(' +ISNULL(rcc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
											--	ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) 
									  ) + ')' + ' AS ' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))
									ELSE ISNULL(rcc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
											--	ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
									  )+ ' AS ' + QUOTENAME(ISNULL(rcc.[alias], dsc.[alias]))
							END 
					END  
				FROM report_paramset rp
				INNER JOIN report_page_chart rpc ON rpc.report_page_chart_id = @component_id				
				INNER JOIN report_chart_column rcc ON rcc.chart_id = rpc.report_page_chart_id 
				INNER JOIN report_dataset rd ON rd.report_dataset_id = rcc.dataset_id
				LEFT JOIN #column_aggregation_option cao ON cao.id  = rcc.aggregation
				--use LEFT JOIN as custom fields won't have column_id value
				LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rcc.column_id 
				WHERE rp.report_paramset_id = @paramset_id
			FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

			IF @is_html = 'n'
			BEGIN
				SET @cols = REPLACE(@cols, ' AS', ') AS ')
				SET @cols = 'dbo.FNAStripHTML(' + REPLACE(@cols, ',', ', dbo.FNAStripHTML(')
			END


			EXEC spa_print  '****************************************SELECT Chart Columns START****************************************:' 
				,@cols, '****************************************SELECT Chart Columns END******************************************:'
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

			SELECT @data_cols = STUFF((
				--SELECT ', ' + 		
				--	CASE WHEN dsc.widget_id = 6 THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
				--		ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) END 	
				--+  ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias])) --gauge allows NULLALE [alias] as it is not set in frontend 
				SELECT ', ' + 		
					CASE WHEN @query_level_grouping_reqd IS NULL 
						THEN ISNULL(rgc.functions,
								--CASE WHEN dsc.widget_id = 6 
								--	THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
								--	ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
								--END 
								--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
								QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
						  )+ ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))	
						WHEN @query_level_grouping_reqd = 1 THEN
							CASE 
								WHEN rgc.aggregation IS NOT NULL AND rgc.functions IS NOT NULL THEN		
								--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
									cao.function_name + '(' + rgc.functions + ')' +  ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
								WHEN rgc.aggregation IS NOT NULL  
									THEN cao.function_name + '(' +ISNULL(rgc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
											--	ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
									  ) + ')' + ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
									ELSE ISNULL(rgc.functions,
											--CASE WHEN dsc.widget_id = 6 
											--	THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
											--	ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
											--END 
											--## COMMENTED BEACASUE THIS FUNCTION OUTPUTS DATE ON TEXT FORMAT AND THE DATE FORMAT OPTION ON REPORT LEVEL CANNOT RENDER AS PROVIDED OPTION.
											QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) 
									  )+ ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
							END 
					END  
				FROM report_paramset rp
				INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = @component_id
				INNER JOIN report_gauge_column rgc ON rgc.gauge_id = rpg.report_page_gauge_id
				INNER JOIN report_dataset rd ON rd.report_dataset_id = rgc.dataset_id
				LEFT JOIN #column_aggregation_option cao ON cao.id  = rgc.aggregation
				--use LEFT JOIN as custom fields won't have column_id value
				LEFT JOIN data_source_column dsc ON rgc.column_id = dsc.data_source_column_id 
				WHERE rp.report_paramset_id = @paramset_id
			FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

			SELECT @label_cols = STUFF((
				SELECT DISTINCT ', ' + 		
					CASE WHEN dsc.widget_id = 6 THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
						ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) END 	
				+  ' AS ' + QUOTENAME(ISNULL(dsc.[alias], rgc.[alias])) --gauge allows NULLALE [alias] as it is not set in frontend 
				--SELECT ', ' + 		
				--	CASE WHEN @query_level_grouping_reqd IS NULL 
				--		THEN ISNULL(rgc.functions,
				--				CASE WHEN dsc.widget_id = 6 
				--					THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
				--					ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
				--				END 
				--		  )+ ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))	
				--		WHEN @query_level_grouping_reqd = 1 THEN
				--			CASE 
				--				WHEN rgc.aggregation IS NOT NULL AND rgc.functions IS NOT NULL THEN		
				--				--place aggregation function in the outermost scope such that it supports Custom functions having multiple parameters applied in same column.
				--					cao.function_name + '(' + rgc.functions + ')' +  ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
				--				WHEN rgc.aggregation IS NOT NULL  
				--					THEN cao.function_name + '(' +ISNULL(rgc.functions,
				--							CASE WHEN dsc.widget_id = 6 
				--								THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
				--								ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
				--							 END 
				--					  ) + ')' + ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
				--					ELSE ISNULL(rgc.functions,
				--							CASE WHEN dsc.widget_id = 6 
				--								THEN 'dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
				--								ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name])
				--							 END 
				--					  )+ ' AS ' + QUOTENAME(ISNULL(rgc.[alias], dsc.[alias]))
				--			END 
				--	END  
				FROM report_paramset rp
				INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = @component_id
				INNER JOIN report_gauge_column rgc ON rgc.gauge_id = rpg.report_page_gauge_id
				INNER JOIN report_dataset rd ON rd.report_dataset_id = rgc.dataset_id
				LEFT JOIN #column_aggregation_option cao ON cao.id  = rgc.aggregation
				--use LEFT JOIN as custom fields won't have column_id value
				LEFT JOIN data_source_column dsc ON rpg.gauge_label_column_id = dsc.data_source_column_id 
				WHERE rp.report_paramset_id = @paramset_id
			FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

			SET @cols = @data_cols + ', ' +@label_cols

			
			IF @is_html = 'n'
			BEGIN
				SET @cols = REPLACE(@cols, ' AS', ') AS ')
				SET @cols = 'dbo.FNAStripHTML(' + REPLACE(@cols, ',', ', dbo.FNAStripHTML(')
			END


			EXEC spa_print  '****************************************SELECT gauge Columns START****************************************:' 
				,@cols, '****************************************SELECT gauge Columns END******************************************:'
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
		
		IF EXISTS (
			SELECT 1
			FROM report_paramset rp
			INNER JOIN report_page rpage ON rpage.report_page_id = rp.page_id
			INNER JOIN report_dataset rd ON rpage.report_id =rd.report_id
				AND rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = @root_dataset_id
			WHERE rp.report_paramset_id = @paramset_id	
			AND rd.is_free_from = 1 
		)
		BEGIN 
			SET @is_free_from = 1
		END

		IF @is_free_from = 1 
		BEGIN 
			SELECT @relational_sql = 'FROM ['+ rd.alias + '] ' + rd.relationship_sql
			FROM report_paramset rp
			INNER JOIN report_page rpage ON rpage.report_page_id = rp.page_id
			INNER JOIN report_dataset rd ON rpage.report_id =rd.report_id
				AND rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = @root_dataset_id
			WHERE rp.report_paramset_id = @paramset_id
			
			DECLARE @temp_map TABLE 
			(
				start_index				INT	
				,report_dataset_id		VARCHAR(100)
				,root_dataset_id		VARCHAR(100)
				,source_id				INT
				, alias					VARCHAR(100)
			)			
			
			
			;WITH cte_dataset_hierarchy (report_dataset_id,  root_dataset_id, ALIAS, source_id, is_free_from, relationship_sql) 
					AS 
			( 
				SELECT  rd.report_dataset_id, rd.root_dataset_id, rd.alias, rd.source_id, rd.is_free_from, rd.relationship_sql
						FROM report_paramset rp
						INNER JOIN report_page rpage ON rpage.report_page_id = rp.page_id
						INNER JOIN report_dataset rd ON rpage.report_id =rd.report_id
							AND rd.root_dataset_id IS NULL
							AND rd.report_dataset_id = @root_dataset_id
						WHERE rp.report_paramset_id = @paramset_id
				
				UNION ALL
				
				SELECT rd_child.report_dataset_id, rd_child.root_dataset_id, rd_child.alias, rd_child.source_id, rd_child.is_free_from, rd_child.relationship_sql
						FROM cte_dataset_hierarchy cdr
						INNER JOIN report_dataset rd_child ON rd_child.root_dataset_id = cdr.report_dataset_id
			)
	
			INSERT INTO @temp_map(
				start_index,
				report_dataset_id,
				root_dataset_id,
				source_id,
				alias
			)
			SELECT  n, cdh.report_dataset_id, cdh.root_dataset_id, cdh.source_id, cdh.alias
			FROM cte_dataset_hierarchy cdh
			INNER JOIN report_dataset rd ON rd.report_dataset_id = cdh.report_dataset_id
			LEFT JOIN dbo.seq pos_alias_name ON pos_alias_name.n <= LEN(@relational_sql)
				AND SUBSTRING(@relational_sql, pos_alias_name.n, LEN('[' + cdh.alias + ']'))  = '[' + rd.alias + ']'

			SELECT @relational_sql =  
				CASE WHEN  IIF(CHARINDEX(@batch_identifier, MAX(ds.[tsql])) = 0,1, CHARINDEX(@batch_identifier, MAX(ds.[tsql]))) > 0 OR CHARINDEX(@view_result_identifier, MAX(ds.[tsql])) > 0 THEN
					STUFF(@relational_sql, MAX(tm.start_index), 0, dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id))
				ELSE
					STUFF(@relational_sql, MAX(tm.start_index), 0, '('+ MAX(ds.[tsql]) + ')')
				END 
			FROM @temp_map tm
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


			;WITH cte_dataset_rel (dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, relationship_level, join_type) 
		AS 
		( 
			--main dataset
				SELECT rd.report_dataset_id, rd.source_id, rd.[alias], rd.[alias] from_alias, NULL from_column_id, CAST(NULL AS VARCHAR(100)) to_alias, NULL to_column_id, 0 relationship_level , NULL join_type
			FROM report_paramset rp
			INNER JOIN report_page rpage ON rpage.report_page_id = rp.page_id
			INNER JOIN report_dataset rd ON rpage.report_id =rd.report_id
				AND rd.root_dataset_id IS NULL
				AND rd.report_dataset_id = @root_dataset_id
			WHERE rp.report_paramset_id = @paramset_id
			
			UNION ALL
			
			--connected dataset
				SELECT rdr.from_dataset_id, rd_main.source_id, rd_main.[alias], rd_from.[alias] from_alias, rdr.from_column_id, cdr.from_alias to_alias, rdr.to_column_id, (cdr.relationship_level + 1) relationship_level ,rdr.join_type join_type
			FROM cte_dataset_rel cdr
			INNER JOIN report_dataset_relationship rdr ON rdr.to_dataset_id = cdr.dataset_id
			INNER JOIN report_dataset rd_from ON rdr.from_dataset_id = rd_from.report_dataset_id
			INNER JOIN report_dataset rd_main ON rdr.from_dataset_id = rd_main.report_dataset_id
			WHERE rd_from.root_dataset_id = @root_dataset_id
		
		)
		
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
					+  CASE WHEN IIF(CHARINDEX(@batch_identifier, MAX(ds.[tsql])) = 0 , 1,  CHARINDEX(@batch_identifier, MAX(ds.[tsql]))) > 0 OR CHARINDEX(@view_result_identifier, MAX(ds.[tsql])) > 0
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
					FROM cte_dataset_rel
						GROUP BY dataset_id, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, join_type
					--ORDER BY relationship_level
				) cte
				INNER JOIN data_source ds ON ds.data_source_id = cte.source_id
				OUTER APPLY (
					 SELECT
					   STUFF(
				   		(
				   		   SELECT DISTINCT ' AND ' + CAST((from_alias + '.' + QUOTENAME(dsc_from.name) + ' = ' + to_alias +  '.' + QUOTENAME(dsc_to.name)) AS VARCHAR(MAX)) 
						   FROM cte_dataset_rel cdr_inner
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
			
		EXEC spa_print  '****************************************FROM clause START****************************************:' 
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
		IF EXISTS (SELECT 1 FROM report_param rp 
					INNER JOIN report_dataset_paramset rdp
						ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
					WHERE rdp.root_dataset_id = @root_dataset_id
						AND rdp.paramset_id = @paramset_id 
						AND rp.optional = 1  
						AND rdp.advance_mode = 0)
		BEGIN 
			SET  @where_part =  dbo.FNARFXReplaceOptionalParam(@paramset_id, @root_dataset_id)
		END 
		ELSE 
		BEGIN
			SET @where_part = (SELECT where_part FROM report_dataset_paramset  WHERE root_dataset_id = @root_dataset_id AND paramset_id = @paramset_id )
		END 
		
		--SET @params_final = ISNULL(@params_hidden, ' 1 = 1 ')  + ISNULL(' AND ' + NULLIF(@where_part, ''), '')
		SET @params_final = ISNULL(NULLIF(nullif(@where_part,'(  )'),''), '1 = 1')
	
		EXEC spa_print '****************************************WHERE clause START****************************************:' 
			, @params_final, '****************************************WHERE clause END******************************************:'
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
				 SELECT @group_by = STUFF(
 											(
											SELECT ', ' + ISNULL(rtc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]))
											FROM report_paramset rp
											INNER JOIN report_page_tablix rt ON rt.report_page_tablix_id = @component_id 
											INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rt.report_page_tablix_id
											LEFT JOIN report_dataset rd ON rd.report_dataset_id = rtc.dataset_id
											--use LEFT JOIN as custom fields won't have column_id value
											LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
											WHERE rp.report_paramset_id = @paramset_id
											--	AND rtc.placement <> 2 
												AND rtc.sql_aggregation IS NULL 
												--AND rt.[type_id] = 1
											FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	
			END 
		
		IF @display_type = 'c' AND @query_level_grouping_reqd = 1
		BEGIN
			SELECT @group_by = STUFF(
									(
									SELECT ', ' + ISNULL(rcc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]))
									FROM report_paramset rp
									INNER JOIN report_page_chart rpc ON rpc.report_page_chart_id = @component_id 
									INNER JOIN report_chart_column rcc ON rcc.chart_id = rpc.report_page_chart_id
									LEFT JOIN report_dataset rd ON rd.report_dataset_id = rcc.dataset_id
									--use LEFT JOIN as custom fields won't have column_id value
									LEFT JOIN data_source_column dsc ON rcc.column_id = dsc.data_source_column_id 
										WHERE rp.report_paramset_id = @paramset_id
									--	AND rtc.placement <> 2 
										AND rcc.aggregation IS NULL 
										--AND rt.[type_id] = 1
									FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	
		END
		
		IF @display_type = 'g' AND @query_level_grouping_reqd = 1
		BEGIN
			DECLARE @label_cols_group VARCHAR(MAX)
			
			/*Group by gauge columns that donot have aggregate logic*/
			SELECT @group_by = STUFF((
									SELECT ', ' + ISNULL(rgc.functions, QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]))
									FROM report_paramset rp
									INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = @component_id 
									INNER JOIN report_gauge_column rgc ON rgc.gauge_id = rpg.report_page_gauge_id
									LEFT JOIN report_dataset rd ON rd.report_dataset_id = rgc.dataset_id
									--use LEFT JOIN as custom fields won't have column_id value
									LEFT JOIN data_source_column dsc ON rgc.column_id = dsc.data_source_column_id 
										WHERE rp.report_paramset_id = @paramset_id
									--	AND rtc.placement <> 2 
										AND rgc.aggregation IS NULL 
										--AND rt.[type_id] = 1
									FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	
			
			/*Group by Label columns*/
			SELECT @label_cols_group = STUFF((
											SELECT DISTINCT ', ' + 		
												CASE WHEN dsc.widget_id = 6 
													THEN ' dbo.FNADateFormat(' + QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) + ') ' 
													ELSE QUOTENAME(rd.[alias]) + '.' + QUOTENAME(dsc.[name]) 
												END 
											FROM report_paramset rp
											INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = @component_id
											INNER JOIN report_gauge_column rgc ON rgc.gauge_id = rpg.report_page_gauge_id
											INNER JOIN report_dataset rd ON rd.report_dataset_id = rgc.dataset_id
											LEFT JOIN #column_aggregation_option cao ON cao.id  = rgc.aggregation
											INNER JOIN data_source_column dsc ON rpg.gauge_label_column_id = dsc.data_source_column_id 
											WHERE rp.report_paramset_id = @paramset_id
											FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')
			
			SELECT  @group_by = ISNULL(NULLIF(@group_by, '') + ',', '') + @label_cols_group
		END	
				
				
		EXEC spa_print '****************************************GROUP BY clause START****************************************:' 
			,@group_by, '****************************************GROUP BY clause END******************************************:'							
								
		/*****************************************Generate GROUP BY clause END**************************************/	
		
		
		/*****************************************Generate ORDER BY clause START**************************************/
		DECLARE @order_by VARCHAR(8000)
		
		IF @display_type = 't'
		BEGIN 
			SELECT @order_by = STUFF(
	 								(
										SELECT ', ' + QUOTENAME(rtc.[alias])
										+ CASE WHEN rtc.default_sort_direction = 2 THEN ' DESC'
												ELSE '' 
										  END
										FROM report_paramset rp
										INNER JOIN report_page_tablix rpt ON rpt.report_page_tablix_id = @component_id
										INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rpt.report_page_tablix_id
										LEFT JOIN report_dataset rd ON rd.report_dataset_id = rtc.dataset_id 
										--use LEFT JOIN as custom fields won't have column_id value
										LEFT JOIN data_source_column dsc ON rtc.column_id = dsc.data_source_column_id 
										WHERE rp.report_paramset_id = @paramset_id
											AND rtc.default_sort_order <> 0
										ORDER BY rtc.default_sort_order ASC 
									FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	
		 END 
		 ELSE IF @display_type = 'c'
		 BEGIN
		 	SELECT @order_by = STUFF(
		 							(
									SELECT ', ' + QUOTENAME(rcc.[alias])
									+ CASE WHEN rcc.default_sort_direction = 2 THEN ' DESC'
										ELSE '' 
										END
									FROM report_paramset rp
									INNER JOIN report_page_chart rpc ON rpc.report_page_chart_id = @component_id
									INNER JOIN report_chart_column rcc ON rcc.chart_id = rpc.report_page_chart_id
									LEFT JOIN report_dataset rd ON rd.report_dataset_id = rcc.dataset_id
									--use LEFT JOIN as custom fields won't have column_id value
									LEFT JOIN data_source_column dsc ON rcc.column_id = dsc.data_source_column_id 
									WHERE rp.report_paramset_id = @paramset_id
										AND rcc.placement = 3 --(category field X axis)
									ORDER BY rcc.default_sort_order ASC --(maintain the order of columns to order by)
								FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')		
		 	
		 END
			
		
		EXEC spa_print '****************************************ORDER BY clause START****************************************:' 
			,@order_by,'****************************************ORDER BY clause END******************************************:'									
								
		/*****************************************Generate ORDER BY clause END**************************************/		
	
	
		
	
	
		/*****************************************Generate Master Query START**************************************/
		DECLARE @parameterized_stmnt  VARCHAR(MAX)
		
		SET @parameterized_stmnt = 'SELECT ' + ISNULL(@cols, '*') + @from_clause + ISNULL(' WHERE ' + @params_final, '') + ISNULL(' GROUP BY ' + @group_by, '') + ISNULL(' ORDER BY ' + @order_by, '')
		
		EXEC spa_print '****************************************Master Query START****************************************:' 
			,@parameterized_stmnt,'****************************************Master Query START******************************************:'
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
		
		--EXEC spa_print 'Batch table name:' , ISNULL(@str_batch_table, 'NULL')
		IF ISNULL(@str_batch_table, '') <> ''
		BEGIN	
			IF @call_from = 'powerbi' AND CHARINDEX('batch_report_',@str_batch_table) > -1
			BEGIN
				DECLARE @str_batch_table_temp VARCHAR(MAX) = ' into #temp_powerbi_table '
				DECLARE @powerbi_user VARCHAR(50) = dbo.FNADBUser()
				SET @str_batch_table = REPLACE(@str_batch_table,@powerbi_user,'power_bi')
				SET @final_query = SUBSTRING(@final_query, 0, @from_index) + ' , ''' + @powerbi_user + ''' [power_bi_run_user] ' + @str_batch_table_temp + ' ' +  SUBSTRING(@final_query, @from_index, LEN(@final_query))
				SET @final_query = @final_query + '
								IF OBJECT_ID (N''' + REPLACE(REPLACE(@str_batch_table,'into',''),' ','') + ''', N''U'') IS NOT NULL
								begin
									DELETE FROM ' + REPLACE(@str_batch_table,'into','') +' WHERE power_bi_run_user = ''' + @powerbi_user + ''' 

									insert ' + @str_batch_table + ' 
									select * from #temp_powerbi_table
								end
								else
								begin									
									select * ' + @str_batch_table + ' from  #temp_powerbi_table
									
									USE adiha_process;
									DECLARE @sql_stmt VARCHAR(MAX) = ''DECLARE @query nvarchar(max);''

									SELECT @sql_stmt = @sql_stmt
										+ ''SET @query =''''ALTER TABLE ''
										+ TABLE_NAME
										+ '' ALTER COLUMN [''
										+ COLUMN_NAME
										+ ''] ''
										+ DATA_TYPE
										+ ''(MAX) ''''
										exec(@query);''
									FROM INFORMATION_SCHEMA.COLUMNS
									WHERE DATA_TYPE in (''varchar'',''nvarchar'') and TABLE_NAME = ''batch_report_power_bi_' + @batch_process_id +'''

									EXEC(@sql_stmt)
								end
								 
								'
			END
			ELSE
			BEGIN
			SET @final_query = SUBSTRING(@final_query, 0, @from_index) + @str_batch_table + ' ' +  SUBSTRING(@final_query, @from_index, LEN(@final_query))
			END
		END

		SET @final_sql = @final_query
				
		EXEC spa_print '****************************************Final Batch SQL Started****************************************:' 
			, @final_sql, '****************************************Final Batch SQL Ended******************************************:'
		/*****************************************Generate Final Batch END **************************************/	


	END TRY
	BEGIN CATCH
		--EXEC spa_print 'ERROR: ' + ERROR_MESSAGE()
		DECLARE @error_msg	VARCHAR(1000)
		SET @error_msg = IIF(CHARINDEX('Error building Report SQL. ', ERROR_MESSAGE()) = 0 , 'Error building Report SQL. ', '')  + ERROR_MESSAGE()
		
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
