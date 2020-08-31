IF OBJECT_ID(N'[dbo].[spa_rfx_chart_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_chart_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-09-13
-- Description: Read and save operations for Charts
 
-- Params:
-- @flag - Operation Flag                       
-- @process_id Operation Process ID

--SAMPLE USE : EXEC [spa_rfx_chart_dhx] 'i', '06205D01_C778_4D98_96A0_AF2FB281DFA4', NULL, NULL, 55
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_chart_dhx]
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@page_id INT = NULL,
	@root_dataset_id INT = NULL,
	@chart_name VARCHAR(100) = NULL,
	@chart_type_id INT = NULL,
	@top VARCHAR(50) = NULL,
	@width VARCHAR(50) = NULL,
	@height VARCHAR(50) = NULL,
	@xml TEXT = NULL,
	@left VARCHAR(50) = NULL,
	@report_page_chart_id INT = NULL,
	@y_axis_caption VARCHAR(200) = NULL,
	@x_axis_caption VARCHAR(200) = NULL,	
	@page_break VARCHAR(4) = NULL,
	@chart_properties VARCHAR(8000) = NULL
	
AS
SET NOCOUNT ON
/*
declare 
@flag CHAR(1),
	@process_id VARCHAR(50),
	@page_id INT = NULL,
	@root_dataset_id INT = NULL,
	@chart_name VARCHAR(100) = NULL,
	@chart_type_id INT = NULL,
	@top VARCHAR(50) = NULL,
	@width VARCHAR(50) = NULL,
	@height VARCHAR(50) = NULL,
	@xml varchar(max) = NULL,
	@left VARCHAR(50) = NULL,
	@report_page_chart_id INT = NULL,
	@y_axis_caption VARCHAR(200) = NULL,
	@x_axis_caption VARCHAR(200) = NULL,	
	@page_break VARCHAR(4) = NULL,
	@chart_properties VARCHAR(8000) = NULL

select @flag='u',@process_id='2A845FE9_25CD_4C6A_AA76_E63AC417B3C5',@page_id='1',@root_dataset_id='1',@chart_name='cc_chart1',@chart_type_id='3',@top='0',@width='10',@height='10',@xml='<Root><PSRecordset 
DataSetID="1" ColumnID="711" ColumnAlias="sub" FunctionName="" Aggregation="" SortPriority="" SortTo="" CustomField="0" ColumnOrder="1" Placement="3" RenderAsLine="0"></PSRecordset><PSRecordset DataSetID="1" ColumnID="1285" ColumnAlias="buy_sell_flag" FunctionName="" Aggregation="" SortPriority="" SortTo="" CustomField="0" ColumnOrder="1" Placement="2" RenderAsLine="0"></PSRecordset><PSRecordset DataSetID="1" ColumnID="726" ColumnAlias="volume" FunctionName="" Aggregation="13" SortPriority="" SortTo="" CustomField="0" ColumnOrder="1" Placement="1" RenderAsLine="0"></PSRecordset></Root>',@left='0',@report_page_chart_id=NULL,@y_axis_caption='Caption X',@x_axis_caption='Caption Y',@page_break='0',@chart_properties='{"axes":{"x":{"render_as":"1","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"y":{"render_as":"1","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"z":{"render_as":"1","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"}},"axes_caption":{"x":{"font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"y":{"font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"z":{"font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"}}}'

--*/


DECLARE @user_name                VARCHAR(50)   
DECLARE @rfx_report_page_chart    VARCHAR(200)
DECLARE @rfx_report_chart_column  VARCHAR(200)
DECLARE @sql                      VARCHAR(8000)

SET @xml = dbo.FNAURLDecode(@xml) --decode escaped characters	
SET @user_name = dbo.FNADBUser()
SET @rfx_report_page_chart = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
DECLARE @rfx_report_dataset VARCHAR(200) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)


SET @rfx_report_chart_column = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
IF @report_page_chart_id = ''
	SET @report_page_chart_id = NULL
IF @flag = 'i' OR @flag = 'u'
BEGIN
	IF @xml IS NOT NULL
	BEGIN
		DECLARE @idoc		INT
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#rfx_chart') IS NOT NULL
			DROP TABLE #rfx_chart
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT  DataSetID [DataSetID],
				ColumnID [ColumnID],
				ColumnAlias [ColumnAlias],
				FunctionName [FunctionName],
				Aggregation [Aggregation],
				SortPriority [SortPriority],
				nullif(SortingColumn,'') [SortingColumn],
				SortTo [SortTo],
				CustomField [CustomField],
				ColumnOrder [ColumnOrder],
				Placement [Placement],
				RenderAsLine [RenderAsLine]
		INTO #rfx_chart
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
		    DataSetID VARCHAR(10),
			ColumnID VARCHAR(10),
			ColumnAlias VARCHAR(200),
			FunctionName VARCHAR(8000),
			Aggregation VARCHAR(10),
			SortPriority VARCHAR(10),
			SortingColumn VARCHAR(10),
			SortTo VARCHAR(10),
			CustomField VARCHAR(10),
			ColumnOrder VARCHAR(10),
			Placement VARCHAR(10),
			RenderAsLine VARCHAR(10)
		)
		
		IF EXISTS(
		          SELECT 1
		          FROM   (
		                     SELECT COUNT([ColumnAlias]) AS [count_same_name],
		                            [ColumnAlias]
		                     FROM   #rfx_chart
		                     GROUP BY
		                            [ColumnAlias]
		                 )db
		          WHERE  [count_same_name] > 1
		      )
		   BEGIN
		       EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Same display name used in multiple fields.', ''
				RETURN
		   END
		
		UPDATE #rfx_chart SET ColumnID = NULL WHERE  ColumnID = ''
		UPDATE #rfx_chart SET ColumnAlias = NULL WHERE  ColumnAlias = ''		
		UPDATE #rfx_chart SET FunctionName = NULL WHERE  FunctionName = ''		
		UPDATE #rfx_chart SET Aggregation = NULL WHERE  Aggregation = ''		
		UPDATE #rfx_chart SET SortPriority = NULL WHERE  SortPriority = ''		
		UPDATE #rfx_chart SET SortTo = NULL WHERE  SortTo = ''		
		UPDATE #rfx_chart SET ColumnOrder = NULL WHERE  ColumnOrder = ''
		UPDATE #rfx_chart SET Placement = NULL WHERE  Placement = ''
		UPDATE #rfx_chart SET RenderAsLine = NULL WHERE  RenderAsLine = ''
		
		
	END

	/*
	* To Track the old root dataset_id when dataset source is changed
	* */
	--begin try
	IF OBJECT_ID('tempdb..#rootdataset_before_update') IS NOT NULL
	DROP TABLE #rootdataset_before_update	
		
	CREATE TABLE #rootdataset_before_update(
		root_dataset_id INT
	)
	
	--## USED GLOBAL TEMPORARY TABLE DUE TO NESTED INSERT EXEC ERROR ON PARENT PROC
	IF OBJECT_ID(N'tempdb..##rootdataset_before_update') IS NOT NULL
		DROP TABLE ##rootdataset_before_update

	SET @sql = 'SELECT DISTINCT root_dataset_id into ##rootdataset_before_update FROM ' + @rfx_report_page_chart + ' rpc WHERE rpc.root_dataset_id <> ' + CAST(@root_dataset_id AS VARCHAR(10))

	EXEC (@sql)

	INSERT INTO #rootdataset_before_update
	SELECT root_dataset_id FROM ##rootdataset_before_update

	IF OBJECT_ID(N'tempdb..##rootdataset_before_update') IS NOT NULL
		DROP TABLE ##rootdataset_before_update
				
	--end try
	--begin catch
	--	select ERROR_MESSAGE()
	--end catch
	
	
	IF @report_page_chart_id IS NOT NULL
	BEGIN
		CREATE TABLE #rfx_chart_name_u (name_exists TINYINT)
		SET @sql = 'INSERT INTO #rfx_chart_name_u ([name_exists]) SELECT TOP(1) 1 FROM ' + @rfx_report_page_chart + ' WHERE report_page_chart_id <> ' + CAST(@report_page_chart_id AS VARCHAR(10)) + ' AND page_id = ' + CAST(@page_id AS VARCHAR(10)) + ' AND name = ''' + @chart_name + ''''
		--PRINT @sql
		EXEC (@sql)
		IF EXISTS(SELECT 1 FROM #rfx_chart_name_u) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Chart name already used.', ''
			RETURN
		END	
		SET @sql = 'UPDATE ' + @rfx_report_page_chart + '
					SET  page_id = ' + CAST(@page_id AS VARCHAR(10)) + ',
						 root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(10)) + ',
						 [name] = ''' + @chart_name + ''',
						 [TYPE_ID] = ' + CAST(@chart_type_id AS VARCHAR(10)) + ',
						 [top] = ' + @top + ',
						 width = ' + @width + ',
						 height = ' + @height + ',
						 [left] = ' + @left + ',
						 [y_axis_caption] = ''' + @y_axis_caption + ''',
						 [x_axis_caption] = ''' + @x_axis_caption + ''',
						 [page_break] = ''' + @page_break + ''',
						 [chart_properties] = ''' + @chart_properties + '''
					WHERE report_page_chart_id = ' + CAST(@report_page_chart_id AS VARCHAR)
		IF @xml IS NOT NULL
		BEGIN			
			SET @sql += '
					DELETE FROM ' + @rfx_report_chart_column + ' WHERE chart_id = ' + CAST(@report_page_chart_id AS VARCHAR) + '
					
					INSERT INTO ' + @rfx_report_chart_column + ' (
							chart_id,
							dataset_id,
							column_id,
							alias,
							functions,
							aggregation,
							custom_field,
                            column_order,
                            placement,
                            default_sort_order,
							sorting_column,
                            default_sort_direction,
                            render_as_line
							)	                
					SELECT ' + CAST(@report_page_chart_id AS VARCHAR) + ',
						    rc.DataSetID,
							rc.ColumnID,
							rc.ColumnAlias,
							rc.FunctionName,
							rc.Aggregation,
							rc.CustomField,
							rc.ColumnOrder,
							rc.Placement,
							rc.SortPriority,
							rc.SortingColumn,
							rc.SortTo,
							rc.RenderAsLine
					FROM   #rfx_chart rc '	
			
		END
	END
	ELSE
	BEGIN
	
		CREATE TABLE #rfx_chart_name (name_exists TINYINT)
		SET @sql = 'INSERT INTO #rfx_chart_name ([name_exists]) SELECT TOP(1) 1 FROM ' + @rfx_report_page_chart + ' WHERE page_id = ' + CAST(@page_id AS VARCHAR(10)) + ' AND name = ''' + @chart_name + ''''
		--PRINT @sql
		EXEC (@sql)
		IF EXISTS(SELECT 1 FROM #rfx_chart_name) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Chart name already used.', ''
			RETURN
		END	
		
		SET @sql = 'DECLARE @chart_id INT
					INSERT INTO ' + @rfx_report_page_chart + '(page_id,root_dataset_id,[name],[TYPE_ID],[top],width,height,[left], [y_axis_caption], [x_axis_caption], [page_break], [chart_properties] )
					VALUES(
						' + CAST(@page_id AS VARCHAR(10)) + ',
						' + CAST(@root_dataset_id AS VARCHAR(10)) + ',
						''' + @chart_name + ''',
						' + CAST(@chart_type_id AS VARCHAR(10)) + ',
						' + @top + ',
						' + @width + ',
						' + @height + ',
						' + @left + ',
						''' + @y_axis_caption + ''',
						''' + @x_axis_caption + ''',
						''' + @page_break + ''',
						''' + @chart_properties + '''
					)'	
		IF @xml IS NOT NULL
		BEGIN			
			SET @sql += '
					SET @chart_id = IDENT_CURRENT(''' + @rfx_report_page_chart + ''')
		
					INSERT INTO ' + @rfx_report_chart_column + ' (
						chart_id,
						dataset_id,
						column_id,
						alias,
						functions,
						aggregation,
						default_sort_order,
						sorting_column,
						default_sort_direction,
						custom_field,
						column_order,
						placement,
						render_as_line
					)	                
					SELECT @chart_id,
					    rc.DataSetID,
						rc.ColumnID,
						rc.ColumnAlias,
						rc.FunctionName,
						rc.Aggregation,
						rc.SortPriority,
						rc.SortingColumn,
						rc.SortTo,
						rc.CustomField,
						rc.ColumnOrder,
						rc.Placement,
						rc.RenderAsLine
					FROM   #rfx_chart rc
					'
		END
	END
	--PRINT '###'
	--PRINT @sql
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
		EXEC spa_rfx_report_default_paramset_dhx 'd', 'c', @user_name, @process_id, @old_root_dataset_id
		FETCH NEXT FROM cur_get_rootdataset_before_update INTO @old_root_dataset_id
	END
	CLOSE cur_get_rootdataset_before_update   
	DEALLOCATE cur_get_rootdataset_before_update	
		
	/*
	* Insert default parameters for the dataset chosen in the component while saving the component
	* */ 
	
	EXEC spa_rfx_report_default_paramset_dhx 'i', 'c', @user_name, @process_id, @root_dataset_id
	
	Declare @report_page_chart varchar(max), @report_page_chart_name varchar(max)
	Declare @sql_exec nvarchar(max) 

	SET @sql_exec = N'SELECT @report_page_chart = report_page_chart_id, @report_page_chart_name = name from ' + @rfx_report_page_chart
	EXEC sp_executesql @sql_exec, N'@report_page_chart varchar(max) output,@report_page_chart_name varchar(max) output', @report_page_chart=@report_page_chart output, @report_page_chart_name=@report_page_chart_name output
	
	DECLARE @recommendation VARCHAR(2000) = @report_page_chart + ',' + @report_page_chart_name
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_chart_dhx', 'DB Error', 'Failed to save data.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_chart_dhx', 'Success', 'Data successfully saved.', @report_page_chart
	
	--ELSE
	--BEGIN
		--EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_chart_dhx', 'Error', 'XML not supplied.', ''
        --RETURN
	--END
END
IF @flag = 's'
BEGIN
	SET @sql = 'SELECT main.report_page_chart_id,
	                        main.root_dataset_id,
	                        main.[name],
	                        main.[type_id],
	                        main.width,
	                        main.height,
	                        main.y_axis_caption,
	                        main.x_axis_caption,
	                        main.page_break,
	                        main.chart_properties,
							rd.source_id [data_source_id],
							rd.alias [dataset_alias]
	                 FROM ' + @rfx_report_page_chart + ' main
					 LEFT JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = main.root_dataset_id
	                 WHERE report_page_chart_id = ' + CAST(@report_page_chart_id AS VARCHAR)                 
	--PRINT(@sql)
	EXEC(@sql)
END
IF @flag = 'a'
BEGIN
	DECLARE @sql_stmt VARCHAR(MAX)
	SET @sql_stmt = 'SELECT main.report_page_chart_id,
	                        main.root_dataset_id,
	                        main.[name],
	                        main.[type_id],
	                        main.width,
	                        main.height,
	                        main.y_axis_caption,
	                        main.x_axis_caption,
	                        main.page_break,
	                        main.chart_properties,
	                        col.dataset_id,
							col.column_id,
							col.alias,
							col.functions,
							col.aggregation,
							col.default_sort_order,
							col.sorting_column,
							col.default_sort_direction,
							col.custom_field,
							col.column_order,
							col.placement,
							col.render_as_line,
							rd.[alias] + ''.'' + data_col.name [column_name_real],
							case when rd.root_dataset_id is null then ds.alias else rd.[alias] end + ''.'' + data_col.name as column_name_real_pivot,
							data_col.data_source_column_id
	                 FROM ' + @rfx_report_page_chart + ' main
	                 INNER JOIN ' + @rfx_report_chart_column + ' col ON main.report_page_chart_id = col.chart_id 
					 inner join ' + @rfx_report_dataset + ' rd on rd.report_dataset_id = col.dataset_id
					 inner join data_source ds on ds.data_source_id = rd.source_id
					 INNER JOIN data_source_column data_col ON data_col.data_source_column_id = col.column_id
	                 WHERE report_page_chart_id = ' + CAST(@report_page_chart_id AS VARCHAR)                 
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
						SELECT root_dataset_id  FROM ' + @rfx_report_page_chart + ' WHERE report_page_chart_id = ' + CAST(@report_page_chart_id AS VARCHAR)
			--PRINT @sql
			EXEC (@sql)
			
			SET @sql = 'DELETE FROM ' + @rfx_report_chart_column + ' WHERE chart_id = ' + CAST(@report_page_chart_id AS VARCHAR)
			EXEC(@sql)
			
			SET @sql = 'DELETE FROM ' + @rfx_report_page_chart + ' WHERE report_page_chart_id = ' + CAST(@report_page_chart_id AS VARCHAR)
			EXEC(@sql)
			
			DECLARE @used_root_dataset_id INT 
			SELECT @used_root_dataset_id = used_root_dataset_id FROM #used_root_dataset_id
			
			/*
			* Delete default parameters for the dataset chosen if no component uses it 
			* */ 
			EXEC spa_rfx_report_default_paramset_dhx 'd', 'c', @user_name, @process_id, @used_root_dataset_id
	 
		COMMIT
	 
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_chart_dhx', 'Success', 'Chart successfully deleted.', @process_id
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
	 
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_chart_dhx', 'Failed', 'Fail to delete data.', @process_id
	END CATCH	
END
	
	