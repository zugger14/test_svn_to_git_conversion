
IF OBJECT_ID(N'[dbo].[spa_rfx_report_page_tablix]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_page_tablix]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-09-17
-- Description: CRUD operations for table report_page_tablix
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_page_tablix]
    @flag						CHAR(1),
    @report_page_tablix_id		INT = NULL,
    @root_dataset_id			INT = NULL,
    @tablix_name				VARCHAR(100) = NULL,
    @process_id					VARCHAR(500) = NULL,
    @width						VARCHAR(50) = NULL,
    @height						VARCHAR(50) = NULL,
    @left						VARCHAR(50) = NULL,
    @page_id					INT = NULL,
    @top						VARCHAR(50) = NULL,
    @xml_column					VARCHAR(MAX) = NULL,
    @group_mode					INT = NULL,
    @border_style				INT = NULL,
    @xml_header					VARCHAR(MAX) = NULL,
    @page_break					INT = NULL,
    @type_id					INT = NULL,
    @cross_summary				INT = NULL,
    @no_header					INT = NULL,
    @export_table_name			VARCHAR(800)= NULL,
    @is_global					BIT = 1
AS
SET NOCOUNT ON
DECLARE @user_name                       VARCHAR(50),
        @rfx_report_page_tablix          VARCHAR(200),
        @rfx_report_tablix_column		 VARCHAR(200),
        @rfx_report_tablix_header		 VARCHAR(200),
        @sql                             VARCHAR(MAX),
        @rfx_data_source_column			 VARCHAR(200)

SET @xml_column = dbo.FNAURLDecode(@xml_column) --decode escaped characters

SET @user_name = dbo.FNADBUser()
SET @rfx_report_page_tablix = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
SET @rfx_report_tablix_column = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
SET @rfx_report_tablix_header = dbo.FNAProcessTableName('report_tablix_header', @user_name, @process_id)
DECLARE @rfx_report_dataset  VARCHAR(200) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)

IF @flag = 'c'-- retrive column names and id for tablix detail page
BEGIN
	 SET @sql = 'SELECT col.column_id,
						rd.[alias] + ''.'' + data_col.alias as column_name,
						rd.[alias] + ''.'' + data_col.name as column_real_name,
						col.report_tablix_column_id,
						CASE WHEN col.alias IS NULL THEN data_col.alias ELSE col.alias END as alias,
						col.functions,
						col.aggregation,
						col.sortable,
						col.rounding,
						col.thousand_seperation,
						col.default_sort_order,
						col.default_sort_direction,
						col.font,
						col.font_size,
						col.font_style,
						col.text_align,
						col.text_color,
						col.background,
						col.placement,
						data_col.datatype_id,
						col.column_order,
						rd.report_dataset_id group_entity,
						data_col.data_source_column_id,
						col.render_as,
						data_col.tooltip,
						header.report_tablix_header_id,
						header.report_tablix_column_id [h_column_id],
						header.font [h_font],
						header.font_size [h_font_size],
						header.font_style [h_font_style],
						header.text_align [h_text_align],
						header.text_color [h_text_color],
						header.background [h_background],
						col.column_template,
						col.negative_mark,
						col.currency,
						col.date_format,
						col.cross_summary_aggregation,
						data_col.column_template [master_column_template],
						col.mark_for_total,
						col.sql_aggregation,
						col.subtotal   
				 FROM ' + @rfx_report_tablix_column + ' col
				 LEFT JOIN data_source_column data_col ON  col.column_id = data_col.data_source_column_id
				 LEFT JOIN data_source ds ON  data_col.source_id = ds.data_source_id
				 LEFT JOIN ' + @rfx_report_dataset + ' rd ON col.dataset_id = rd.report_dataset_id
				 --LEFT JOIN ' + @rfx_report_tablix_header + ' header ON  header.tablix_id = col.tablix_id
					--AND header.report_tablix_column_id = col.report_tablix_column_id
				OUTER APPLY(
					SELECT TOP 1 * FROM ' + @rfx_report_tablix_header + ' header 
					WHERE header.tablix_id = col.tablix_id
				--	AND header.report_tablix_column_id = col.report_tablix_column_id
					ORDER BY col.report_tablix_column_id DESC	
				) AS [header]
					
				 WHERE  col.tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) + '
				 ORDER BY col.placement, col.column_order ASC'             
	 --PRINT(@sql)
	 EXEC(@sql)         
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
	--Process XML if both header and column data is given
	IF @xml_column IS NOT NULL AND @xml_header IS NOT NULL
	BEGIN
		IF COL_LENGTH(@rfx_report_tablix_column, 'MarkIndex') IS NULL
		BEGIN
			SET @sql = 'ALTER TABLE ' + @rfx_report_tablix_column + ' ADD MarkIndex INT NULL' 
			EXEC (@sql)
		END			

		IF COL_LENGTH(@rfx_report_tablix_header, 'MarkIndex') IS NULL
		BEGIN
			SET @sql = 'ALTER TABLE ' + @rfx_report_tablix_header + ' ADD MarkIndex INT NULL' 
			EXEC (@sql)
		END	
		
			
			DECLARE @idoc_column       INT,
					@idoc_header       INT,
					@tablix_id_return  INT
			
			EXEC sp_xml_preparedocument @idoc_column OUTPUT,@xml_column		
			EXEC sp_xml_preparedocument @idoc_header OUTPUT,@xml_header
		
			IF OBJECT_ID('tempdb..#rfx_tablix_column') IS NOT NULL
				DROP TABLE #rfx_tablix_column
				
			IF OBJECT_ID('tempdb..#rfx_tablix_header') IS NOT NULL
				DROP TABLE #rfx_tablix_header	
		
			SELECT TabColID [TabColID],
				   DataSetID [DataSetID],
				   TabLixID [TabLixID],
				   ColumnID [ColumnID],
				   ColumnAlias [ColumnAlias],
				   FunctionName [FunctionName],
				   Aggregation [Aggregation],
				   SQLAggregation [SQLAggregation],
				   Subtotal [Subtotal],
				   SortLinkHeader [SortLinkHeader],
				   Rounding [Rounding],
				   ThousandSeperator [ThousandSeperator],
				   SortPriority [SortPriority],
				   SortTo [SortTo],
				   Font [Font],
				   FontSize [FontSize],
				   TextAlign [TextAlign],
				   TextColor [TextColor],
				   Background [Background],
				   FontStyle [FontStyle],
				   CustomField [CustomField],
				   ColumnOrder [ColumnOrder],
				   RenderAs [RenderAs],
				   Placement [Placement],
				   ColumnTemplate [ColumnTemplate],
				   NegativeMark [NegativeMark],
				   Currency [Currency],
				   FormatDate [FormatDate],
				   CrossSummaryAggregation [CrossSummaryAggregation],
				   MarkForTotal [MarkForTotal],
				   MarkIndex [MarkIndex]
			INTO #rfx_tablix_column
			FROM OPENXML(@idoc_column, '/Root/PSRecordset', 1)
			WITH (
				   TabColID VARCHAR(10),
				   DataSetID VARCHAR(10),
				   TabLixID VARCHAR(10),
				   ColumnID VARCHAR(10),
				   ColumnAlias VARCHAR(200),
				   FunctionName VARCHAR(8000),
				   Aggregation VARCHAR(10),
				   SQLAggregation VARCHAR(10),
				   Subtotal VARCHAR(10),
				   SortLinkHeader VARCHAR(10),
				   Rounding VARCHAR(10),
				   ThousandSeperator VARCHAR(10),
				   SortPriority VARCHAR(10),
				   SortTo VARCHAR(10),
				   Font VARCHAR(50),
				   FontSize VARCHAR(10),
				   TextAlign VARCHAR(20),
				   TextColor VARCHAR(20),
				   Background VARCHAR(20),
				   FontStyle VARCHAR(10),
				   CustomField VARCHAR(10),
				   ColumnOrder VARCHAR(10),
				   RenderAs VARCHAR(10),
				   Placement VARCHAR(10),
				   ColumnTemplate VARCHAR(10),
				   NegativeMark VARCHAR(10),
				   Currency VARCHAR(10),
				   FormatDate VARCHAR(10),
				   CrossSummaryAggregation VARCHAR(10),
				   MarkForTotal VARCHAR(10),
				   MarkIndex VARCHAR(100)
			)
		    
			   IF EXISTS(
					  SELECT 1
					  FROM   (
								 SELECT COUNT([ColumnAlias]) AS [count_same_name],
										[ColumnAlias]
								 FROM   #rfx_tablix_column
								 GROUP BY
										[ColumnAlias]
							 )db
					  WHERE  [count_same_name] > 1
				  )
			   BEGIN
					EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Same display name used in multiple fields.', ''
					RETURN
			   END
			   
			IF @export_table_name IS NOT NULL 
			BEGIN
				DECLARE @data_source_id INT 

				SELECT @data_source_id =data_source_id FROM data_source WHERE [name]= '[adiha_process].[dbo].[report_export_' + @export_table_name + ']'

				IF OBJECT_ID('tempdb..#dependent_report_datasets') IS NOT NULL
				DROP TABLE #dependent_report_datasets		

				CREATE TABLE #dependent_report_datasets
				(
				report_dataset_id	INT
				,source_id			INT
				,report_id			INT
				,ALIAS				VARCHAR(300) COLLATE DATABASE_DEFAULT
				,root_dataset_id   INT 
				)
				INSERT INTO #dependent_report_datasets
				SELECT 
				report_dataset_id	
				,source_id			
				,report_id			
				,ALIAS	
				,root_dataset_id			
				FROM report_dataset WHERE source_id = @data_source_id

				IF OBJECT_ID('tempdb..#dependent_used_column') IS NOT NULL
				DROP TABLE #dependent_used_column		

				CREATE TABLE #dependent_used_column
				(
				component_id INT 
				, column_id INT
				, alias VARCHAR(3000) COLLATE DATABASE_DEFAULT
				)

				INSERT INTO #dependent_used_column
				SELECT  tablix_id, column_id,rtc.alias
				FROM #dependent_report_datasets drd
				INNER JOIN report_tablix_column rtc ON rtc.dataset_id = ISNULL(drd.root_dataset_id, drd.report_dataset_id)
				UNION 
				SELECT  chart_id, column_id, rcc.alias
				FROM #dependent_report_datasets drd
				INNER JOIN report_chart_column rcc ON rcc.dataset_id = ISNULL(drd.root_dataset_id, drd.report_dataset_id)
				UNION
				SELECT  gauge_id, column_id,rgc.alias
				FROM #dependent_report_datasets drd
				INNER JOIN report_gauge_column rgc ON rgc.dataset_id = ISNULL(drd.root_dataset_id, drd.report_dataset_id)
				UNION 
				SELECT rp.report_param_id,column_id,dsc.alias
				FROM #dependent_report_datasets drd
				INNER JOIN report_param rp ON rp.dataset_id = ISNULL(drd.root_dataset_id, drd.report_dataset_id)
				INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id
				
			   IF EXISTS(
				 SELECT  1 FROM #dependent_used_column duc
				LEFT JOIN #rfx_tablix_column rftc ON rftc.ColumnAlias = duc.alias
				where rftc.ColumnAlias IS NULL 
			   )
				BEGIN
					EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Cannot remove column, It is used by Dependent exported Reports', ''
					RETURN
				END
			END
				   
			UPDATE #rfx_tablix_column SET ColumnAlias = NULL WHERE  ColumnAlias = ''		
			UPDATE #rfx_tablix_column SET TabColID = NULL WHERE  TabColID = ''		
			UPDATE #rfx_tablix_column SET FunctionName = NULL WHERE  FunctionName = ''		
			UPDATE #rfx_tablix_column SET Aggregation = NULL WHERE  Aggregation = ''
			UPDATE #rfx_tablix_column SET SQLAggregation = NULL WHERE  SQLAggregation = ''	
			UPDATE #rfx_tablix_column SET Subtotal = NULL WHERE  Subtotal = ''		
			UPDATE #rfx_tablix_column SET CrossSummaryAggregation = NULL WHERE  CrossSummaryAggregation = ''		
			UPDATE #rfx_tablix_column SET Rounding = NULL WHERE  Rounding = ''
			UPDATE #rfx_tablix_column SET ThousandSeperator = NULL WHERE  ThousandSeperator = ''
			UPDATE #rfx_tablix_column SET NegativeMark = NULL WHERE  NegativeMark = ''
			UPDATE #rfx_tablix_column SET Currency = NULL WHERE  Currency = ''
			UPDATE #rfx_tablix_column SET FormatDate = NULL WHERE  FormatDate = ''				
			UPDATE #rfx_tablix_column SET SortPriority = NULL WHERE  SortPriority = ''		
			UPDATE #rfx_tablix_column SET SortTo = NULL WHERE  SortTo = ''		
			UPDATE #rfx_tablix_column SET Font = NULL WHERE  Font = ''		
			UPDATE #rfx_tablix_column SET FontSize = NULL WHERE  FontSize = ''
			UPDATE #rfx_tablix_column SET TextAlign = NULL WHERE  TextAlign = ''		
			UPDATE #rfx_tablix_column SET TextColor = NULL WHERE  TextColor = ''		
			UPDATE #rfx_tablix_column SET Background = NULL WHERE  Background = ''
			UPDATE #rfx_tablix_column SET ColumnOrder = NULL WHERE  ColumnOrder = ''
			UPDATE #rfx_tablix_column SET RenderAs = NULL WHERE  RenderAs = ''
			UPDATE #rfx_tablix_column SET Placement = NULL WHERE  Placement = ''
			UPDATE #rfx_tablix_column SET TabLixID = NULL WHERE  TabLixID = 'NULL'
			UPDATE #rfx_tablix_column SET ColumnID = NULL WHERE  ColumnID = ''
			UPDATE #rfx_tablix_column SET TabLixID = @tablix_id_return WHERE  TabLixID = ''		
			UPDATE #rfx_tablix_column SET MarkForTotal = NULL WHERE  MarkForTotal = ''

			SELECT TabColID [TabColID],
				   TabLixID [TabLixID],
				   ColumnID [ColumnID],
				   Font [Font],
				   FontSize [FontSize],
				   TextAlign [TextAlign],
				   TextColor [TextColor],
				   Background [Background],
				   FontStyle [FontStyle],
				   MarkIndex [MarkIndex]
			INTO #rfx_tablix_header
			FROM OPENXML(@idoc_header, '/Root/PSRecordset', 1)
			WITH (
				   TabColID VARCHAR(10),
				   TabLixID VARCHAR(10),
				   ColumnID VARCHAR(10),
				   Font VARCHAR(50),
				   FontSize VARCHAR(10),
				   TextAlign VARCHAR(20),
				   TextColor VARCHAR(20),
				   Background VARCHAR(20),
				   FontStyle VARCHAR(10),
				   MarkIndex VARCHAR(100)			   				   
			)   
			
		
		    
			UPDATE #rfx_tablix_header SET TabColID = NULL WHERE  TabColID = ''		
			UPDATE #rfx_tablix_header SET Font = NULL WHERE  Font = ''		
			UPDATE #rfx_tablix_header SET FontSize = NULL WHERE  FontSize = ''
			UPDATE #rfx_tablix_header SET TextAlign = NULL WHERE  TextAlign = ''		
			UPDATE #rfx_tablix_header SET TextColor = NULL WHERE  TextColor = ''		
			UPDATE #rfx_tablix_header SET Background = NULL WHERE  Background = ''
			UPDATE #rfx_tablix_header SET TabLixID = NULL WHERE  TabLixID = 'NULL'
			UPDATE #rfx_tablix_header SET ColumnID = NULL WHERE  ColumnID = ''
			UPDATE #rfx_tablix_header SET TabLixID = @tablix_id_return WHERE  TabLixID = ''	
			
			/*
			* To Track the old root dataset_id when dataset source is changed
			* */
			IF OBJECT_ID('tempdb..#rootdataset_before_update') IS NOT NULL
			DROP TABLE #rootdataset_before_update	
				
			CREATE TABLE #rootdataset_before_update(
				root_dataset_id INT
			)
					
			INSERT INTO	#rootdataset_before_update	
			EXEC ('SELECT DISTINCT root_dataset_id FROM ' + @rfx_report_page_tablix + ' rpt WHERE rpt.root_dataset_id <> ' + @root_dataset_id)
	END
	
		
		IF @report_page_tablix_id IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..#rfx_tablix_name_i') IS NOT NULL
				DROP TABLE #rfx_tablix_name_i	
				
			CREATE TABLE #rfx_tablix_name_i (name_exists TINYINT)
			
			SET @sql = 'INSERT INTO #rfx_tablix_name_i ([name_exists]) 
						SELECT TOP(1) 1 FROM ' + @rfx_report_page_tablix + ' 
						WHERE report_page_tablix_id <> ' + CAST(@report_page_tablix_id AS VARCHAR(10)) + ' 
							AND page_id = ' + CAST(@page_id AS VARCHAR(10)) + ' 
							AND name = ''' + @tablix_name + ''''
			--PRINT @sql
			EXEC (@sql)
			
			IF EXISTS(SELECT 1 FROM #rfx_tablix_name_i) 
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Tablix name already used.', ''
				RETURN
			END	
			
			SET @sql = 'UPDATE ' + @rfx_report_page_tablix + '
						SET  page_id = ' + CAST(@page_id AS VARCHAR(10)) + ',
							 root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(10)) + ',
							 [name] = ''' + @tablix_name + ''',
							 [top] = ' + @top + ',
							 width = ' + @width + ',
							 height = ' + @height + ',
							 [left] = ' + @left + ',
							 [group_mode] = ' + CAST(@group_mode AS VARCHAR(10)) + ',
							 [border_style] = ' + CAST(@border_style AS VARCHAR(10)) + ',
							 [page_break] = ' + CAST(@page_break AS VARCHAR(10)) + ',
							 [type_id] = ' + CAST(@type_id AS VARCHAR(10)) + ',
							 [cross_summary] = ' + CAST(@cross_summary AS VARCHAR(10)) + ',
							 [no_header] = ' + CAST(@no_header AS VARCHAR(10)) + ',
							 [export_table_name]= ' + CAST(ISNULL(''''+ @export_table_name + '''', 'NULL') AS VARCHAR(800)) + ',
							 [is_global]= '+ CAST(ISNULL(@is_global, '1') AS VARCHAR(10)) + '
						WHERE report_page_tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) 
			
			IF @xml_column IS NOT NULL AND @xml_header IS NOT NULL
			BEGIN			
				SET @sql +=		'	--DELETE FROM ' + @rfx_report_tablix_column + ' WHERE tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) + '
						
						MERGE ' + @rfx_report_tablix_column + ' AS rtc
						USING #rfx_tablix_column AS tmp_tablix_col ON rtc.tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) + ' AND tmp_tablix_col.ColumnID = rtc.column_id AND tmp_tablix_col.DataSetID = rtc.dataset_id 
						WHEN MATCHED THEN	
							UPDATE SET rtc.tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) + ',
									   rtc.column_id = tmp_tablix_col.ColumnID,
									   rtc.alias = tmp_tablix_col.ColumnAlias,
									   rtc.functions = tmp_tablix_col.FunctionName,
									   rtc.aggregation = tmp_tablix_col.Aggregation,
									   rtc.sql_aggregation = tmp_tablix_col.SQLAggregation,
									   rtc.subtotal = tmp_tablix_col.Subtotal,
									   rtc.sortable = tmp_tablix_col.SortLinkHeader,
									   rtc.rounding = tmp_tablix_col.Rounding,
									   rtc.thousand_seperation = tmp_tablix_col.ThousandSeperator,
									   rtc.default_sort_order = tmp_tablix_col.SortPriority,
									   rtc.default_sort_direction = tmp_tablix_col.SortTo,
									   rtc.font = tmp_tablix_col.Font,
									   rtc.font_size = tmp_tablix_col.FontSize,
									   rtc.font_style = tmp_tablix_col.FontStyle,
									   rtc.text_align = tmp_tablix_col.TextAlign,
									   rtc.text_color = tmp_tablix_col.TextColor,
									   rtc.background = tmp_tablix_col.Background,
									   rtc.custom_field = tmp_tablix_col.CustomField,
									   rtc.column_order = tmp_tablix_col.ColumnOrder,
									   rtc.render_as = tmp_tablix_col.RenderAs,
									   rtc.placement = tmp_tablix_col.Placement,
									   rtc.dataset_id = tmp_tablix_col.DataSetID,
									   rtc.column_template = tmp_tablix_col.ColumnTemplate,
									   rtc.negative_mark = tmp_tablix_col.NegativeMark,
									   rtc.currency = tmp_tablix_col.Currency,
									   rtc.date_format = tmp_tablix_col.FormatDate,
									   rtc.cross_summary_aggregation = tmp_tablix_col.CrossSummaryAggregation,
									   rtc.mark_for_total = tmp_tablix_col.MarkForTotal,
									   rtc.MarkIndex = tmp_tablix_col.MarkIndex
						WHEN NOT MATCHED THEN
							INSERT (tablix_id, 
									placement,
									aggregation,
									sql_aggregation,
									subtotal,
									functions,
									alias,
									sortable,
									rounding,
									thousand_seperation,
									font,
									font_size,
									font_style,
									text_align,
									text_color,
									default_sort_order,
									default_sort_direction,
									background,
									dataset_id,
									custom_field,
									column_order,
									render_as,
									column_id,
									column_template,
									negative_mark,
									currency,
									date_format,
									cross_summary_aggregation,
									mark_for_total,
									MarkIndex 
								)
								VALUES(
									' + CAST(@report_page_tablix_id AS VARCHAR) + ',
									tmp_tablix_col.Placement,
									tmp_tablix_col.Aggregation,
									tmp_tablix_col.SQLAggregation,
									tmp_tablix_col.Subtotal,
									tmp_tablix_col.FunctionName,
									tmp_tablix_col.ColumnAlias,
									tmp_tablix_col.SortLinkHeader,
									tmp_tablix_col.Rounding,
									tmp_tablix_col.ThousandSeperator,
									tmp_tablix_col.Font,
									tmp_tablix_col.FontSize,
									tmp_tablix_col.FontStyle,
									tmp_tablix_col.TextAlign,
									tmp_tablix_col.TextColor,
									tmp_tablix_col.SortPriority,
									tmp_tablix_col.SortTo,
									tmp_tablix_col.Background,
									tmp_tablix_col.DataSetID,
									tmp_tablix_col.CustomField,
									tmp_tablix_col.ColumnOrder,
									tmp_tablix_col.RenderAs,
									tmp_tablix_col.ColumnID,
									tmp_tablix_col.ColumnTemplate,
									tmp_tablix_col.NegativeMark,
									tmp_tablix_col.Currency,
									tmp_tablix_col.FormatDate,
									tmp_tablix_col.CrossSummaryAggregation,
									tmp_tablix_col.MarkForTotal,
									tmp_tablix_col.MarkIndex
								)							
						WHEN NOT MATCHED BY SOURCE AND rtc.tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) + ' THEN 
						DELETE
						;'			
			END	
	
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#rfx_tablix_name_u') IS NOT NULL
				DROP TABLE #rfx_tablix_name_u	
				
			CREATE TABLE #rfx_tablix_name_u (name_exists TINYINT)
			
			SET @sql = 'INSERT INTO #rfx_tablix_name_u ([name_exists]) 
						SELECT TOP(1) 1 FROM ' + @rfx_report_page_tablix + ' 
						WHERE page_id = ' + CAST(@page_id AS VARCHAR(10)) + ' 
							AND name = ''' + @tablix_name + ''''
		--	EXEC spa_print @sql
			EXEC (@sql)
			
			IF EXISTS(SELECT 1 FROM #rfx_tablix_name_u) 
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Tablix name already used.', ''
				RETURN
			END	
			SET @sql = 'DECLARE @tablix_id  INT
						INSERT INTO ' + @rfx_report_page_tablix + ' (page_id, root_dataset_id, [top], [name], width, height, [left], group_mode, border_style, page_break, type_id, cross_summary,no_header,export_table_name,is_global)
						VALUES(
							' + CAST(@page_id AS VARCHAR(10)) + ',
							' + CAST(@root_dataset_id AS VARCHAR(10)) + ',
							' + @top + ',
							''' + @tablix_name + ''',
							' + @width + ',
							' + @height + ',
							' + @left + ',
							' + CAST(@group_mode AS VARCHAR(10)) + ',
							' + CAST(@border_style AS VARCHAR(10)) + ',
							' + CAST(@page_break AS VARCHAR(10)) + ',
							' + CAST(@type_id AS VARCHAR(10)) + ',
							' + CAST(ISNULL(@cross_summary, '') AS VARCHAR(10)) + ',
							' + CAST(ISNULL(@no_header, '') AS VARCHAR(10))+',
							''' + CAST(ISNULL(@export_table_name, '') AS VARCHAR(800)) + ''',
							' + CAST(ISNULL(@is_global,'1') AS VARCHAR(10)) + '
						)' 
			IF @xml_column IS NOT NULL AND @xml_header IS NOT NULL
			BEGIN			
				SET @sql += '			SET @tablix_id = IDENT_CURRENT(''' + @rfx_report_page_tablix + ''')
						
						INSERT INTO ' + @rfx_report_tablix_column + ' (
							tablix_id, column_id, placement, aggregation,sql_aggregation, subtotal, functions, alias, sortable, rounding, thousand_seperation,
							font, font_size, font_style, text_align, text_color, default_sort_order, default_sort_direction,
							background, dataset_id, custom_field, column_order, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, MarkIndex
						  )
						SELECT @tablix_id, ColumnID, Placement, Aggregation,SQLAggregation, Subtotal, FunctionName, ColumnAlias, SortLinkHeader, Rounding, ThousandSeperator,
							   Font, FontSize, FontStyle, TextAlign, TextColor, SortPriority, SortTo,
							   Background, DataSetID, CustomField, ColumnOrder, RenderAs, ColumnTemplate, NegativeMark, Currency, FormatDate, CrossSummaryAggregation, MarkForTotal, MarkIndex
						FROM   #rfx_tablix_column	
						'	
			END				
		END
		
		--PRINT(@sql)
		EXEC(@sql)
		
		IF @xml_column IS NOT NULL AND @xml_header IS NOT NULL
		BEGIN
			DECLARE @sql_header VARCHAR(8000)
			SET @sql_header = '	DECLARE @tablix_id_h  INT
								SET @tablix_id_h = IDENT_CURRENT(''' + @rfx_report_page_tablix + ''')
								DELETE rth 
								FROM ' + @rfx_report_tablix_header + ' rth
								INNER JOIN #rfx_tablix_header rh ON rh.TabLixID = rth.tablix_id
			
								INSERT INTO ' + @rfx_report_tablix_header + '(
									tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id, MarkIndex
								)
								SELECT ISNULL(rth.TabLixID,@tablix_id_h), rth.ColumnID, rth.Font, rth.FontSize, rth.FontStyle, 
										rth.TextAlign, rth.TextColor, rth.Background, rrtc.report_tablix_column_id, rth.MarkIndex
								FROM #rfx_tablix_header rth
								LEFT JOIN ' + @rfx_report_tablix_column + ' rrtc ON rrtc.tablix_id = rth.TabLixID
									AND rrtc.column_id = rth.ColumnID
									AND rrtc.MarkIndex = rth.MarkIndex

								UPDATE h 
									SET h.report_tablix_column_id = c.report_tablix_column_id
								FROM ' + @rfx_report_tablix_header + ' h
								INNER JOIN ' + @rfx_report_tablix_column + ' c ON c.MarkIndex = h.MarkIndex
								
														
								--UPDATE h 
								--	SET h.report_tablix_column_id = c.report_tablix_column_id
								--FROM ' + @rfx_report_tablix_header + ' h
								--INNER JOIN ' + @rfx_report_tablix_column + ' c ON c.tablix_id = h.tablix_id
								--	AND c.column_id = h.column_id
								
								--UPDATE h
								--	SET h.report_tablix_column_id = c.report_tablix_column_id
								--FROM ' + @rfx_report_tablix_header + ' h
								--INNER JOIN ' + @rfx_report_tablix_column + ' c ON  c.tablix_id = h.tablix_id
								--WHERE h.report_tablix_column_id IS NULL AND c.column_id IS NULL							
								'
								
			--	exec spa_print @sql_header
				EXEC(@sql_header)
		
				SET @sql = 'ALTER TABLE ' + @rfx_report_tablix_column + ' DROP COLUMN MarkIndex ' 
				EXEC (@sql)
				
				SET @sql = 'ALTER TABLE ' + @rfx_report_tablix_header + ' DROP COLUMN MarkIndex ' 
				EXEC (@sql)
				
			/*
			* Delete the data from processing tables of report_param and report_dataset_paramset, if no component uses the dataset anymore
			* when dataset id is changed in a component
			* */
			DECLARE @old_root_dataset_id INT 
			DECLARE cur_get_rootdataset_before_update CURSOR LOCAL FOR 
			SELECT  root_dataset_id  FROM #rootdataset_before_update	
			
			OPEN cur_get_rootdataset_before_update   
			FETCH NEXT FROM cur_get_rootdataset_before_update INTO @old_root_dataset_id

			WHILE @@FETCH_STATUS = 0   
			BEGIN
				EXEC spa_rfx_report_default_paramset 'd', 't', @user_name, @process_id, @old_root_dataset_id
				FETCH NEXT FROM cur_get_rootdataset_before_update INTO @old_root_dataset_id
			END
			CLOSE cur_get_rootdataset_before_update   
			DEALLOCATE cur_get_rootdataset_before_update	
								

			/*
			* Insert default parameters for the dataset chosen in the component while saving the component
			* */ 
			EXEC spa_rfx_report_default_paramset 'i', 't', @user_name, @process_id, @root_dataset_id
		END
		
		SET @tablix_id_return = IDENT_CURRENT(@rfx_report_page_tablix)
			
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_page_tablix', 'Success', 'Data succesfully updated.', @tablix_id_return
	END TRY
	BEGIN CATCH
		DECLARE @DESC1 VARCHAR(500)
		DECLARE @err_no1 INT
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC1 = 'Fail to update data ( Errr Description:' + @DESC1 + ').'
		ELSE
		   SET @DESC1 = 'Fail to update data  ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no1 = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no1, 'Reporting FX', 'spa_rfx_report_page_tablix', 'Error', @DESC1, ''
	END CATCH
END

IF @flag = 'x'
BEGIN
	SET @sql = 'SELECT col.column_id,
	                   col.alias,
	                   col.tablix_id
	            FROM   ' + @rfx_report_tablix_column + ' col
	            INNER JOIN ' + @rfx_report_page_tablix + ' tab_table ON  tab_table.report_page_tablix_id = col.tablix_id
	            WHERE  col.tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR) + '
					AND col.custom_field = 1  ORDER BY col.placement DESC'
	--PRINT(@sql)
	EXEC(@sql)
END

IF @flag = 'a'
BEGIN
	DECLARE @sql_stmt VARCHAR(MAX)
	SET @sql_stmt = 'SELECT main.report_page_tablix_id,
	                        main.root_dataset_id,
	                        main.[name],
	                        main.width,
	                        main.height,
	                       -- col.column_id,
	                       -- col.placement,
	                       -- col.column_order,
	                      --  col.alias,
	                      --  col.dataset_id,
	                        main.group_mode,
                            main.border_style,
                            main.page_break,
                            main.type_id,
                            main.cross_summary,
                            main.no_header,
                            main.export_table_name,
                            main.is_global
	                 FROM ' + @rfx_report_page_tablix + ' main
	                 --INNER JOIN ' + @rfx_report_tablix_column + ' col ON main.report_page_tablix_id = col.tablix_id 
	                 WHERE report_page_tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR)                 
	EXEC(@sql_stmt)
	--PRINT(@sql_stmt)
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		/*
		* to find the used root_dataset_id by the tablix such as to delete the data populated for the dataset in
			report_dataset_paramset and report_param
		* */
			CREATE TABLE #used_root_dataset_id (used_root_dataset_id INT )
	
			SET @sql = 'INSERT INTO #used_root_dataset_id
						SELECT root_dataset_id  FROM ' + @rfx_report_page_tablix + ' WHERE report_page_tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR)
			EXEC spa_print @sql
			EXEC (@sql)

			SET @sql = 'DELETE FROM ' + @rfx_report_tablix_column + ' WHERE tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR)
			EXEC(@sql)
			
			SET @sql = 'DELETE FROM ' + @rfx_report_page_tablix + ' WHERE report_page_tablix_id = ' + CAST(@report_page_tablix_id AS VARCHAR)
			EXEC(@sql)
			
			DECLARE @used_root_dataset_id INT 
			SELECT @used_root_dataset_id = used_root_dataset_id FROM #used_root_dataset_id
			/*
			* Delete default parameters for the dataset chosen if no component uses it 
			* */ 
			EXEC spa_rfx_report_default_paramset 'd', 't', @user_name, @process_id, @used_root_dataset_id
	 
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_page_tablix', 'Success', 'Data successfully deleted.', @process_id
			COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @DESC2 VARCHAR(500)
		DECLARE @err_no2 INT
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC2 = 'Fail to insert Data ( Errr Description:' + @DESC2 + ').'
		ELSE
		   SET @DESC2 = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no2 = ERROR_NUMBER()	 
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_page_tablix', 'Failed', 'Fail to delete data.', @process_id
	END CATCH	
END
