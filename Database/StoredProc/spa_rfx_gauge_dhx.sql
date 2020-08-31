
IF OBJECT_ID(N'[dbo].[spa_rfx_gauge_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_gauge_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2013-04-08
-- Description: Read and save operations for gauges
 
-- Params:
-- @flag - Operation Flag                       
-- @process_id Operation Process ID
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_gauge_dhx]
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@page_id INT = NULL,
	@root_dataset_id INT = NULL,
	@gauge_name VARCHAR(100) = NULL,
	@gauge_type_id INT = NULL,
	@top VARCHAR(50) = NULL,
	@width VARCHAR(50) = NULL,
	@height VARCHAR(50) = NULL,
	@xml TEXT = NULL,
	@left VARCHAR(50) = NULL,
	@report_page_gauge_id INT = NULL,
	@gauge_label_column_id INT = NULL
AS

DECLARE @user_name                      VARCHAR(50)   
DECLARE @rfx_report_page_gauge          VARCHAR(200)
DECLARE @rfx_report_gauge_column        VARCHAR(200)
DECLARE @rfx_report_gauge_column_scale  VARCHAR(200)
DECLARE @sql                            VARCHAR(8000)

SET @xml = dbo.FNAURLDecode(@xml) --decode escaped characters		
SET @user_name = dbo.FNADBUser()
SET @rfx_report_page_gauge = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
SET @rfx_report_gauge_column = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
SET @rfx_report_gauge_column_scale = dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)

IF @report_page_gauge_id = ''
	SET @report_page_gauge_id = NULL
	
IF @flag = 'i' OR @flag = 'u'
BEGIN
	IF @xml IS NOT NULL
	BEGIN
		DECLARE @idoc		INT
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#rfx_gauge') IS NOT NULL
			DROP TABLE #rfx_gauge
		
		IF OBJECT_ID('tempdb..#rfx_gauge_column') IS NOT NULL
			DROP TABLE #rfx_gauge_column
		
		IF OBJECT_ID('tempdb..#rfx_gauge_column_scale') IS NOT NULL
			DROP TABLE #rfx_gauge_column
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT  DataSetID [dataset_id],
				ColumnID [column_id],
				ColumnAlias [column_alias],
				FunctionName [function_name],
				Aggregation [aggregation],
				Currency [currency],
				Rounding [rounding],
				ThousandSeperator [thousand_seperation],
				Font [font],
				FontSize [font_size],
				TextColor [text_color],
				FontStyle [font_style],
				CustomField [custom_field],
				ColumnOrder [column_order],
				RenderAs [render_as],
				ColumnTemplate [column_template],
				ScaleMin [scale_minimum],
				ScaleMax [scale_maximum],
				ScaleInt [scale_interval],
				SubScaleStart [scale_start],
				SubScaleEnd [scale_end],
				SubScaleOrder [scale_order],
				RangeColor [color]
		INTO #rfx_gauge
		FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
				DataSetID VARCHAR(10),
				ColumnID VARCHAR(10),
				ColumnAlias VARCHAR(200),
				FunctionName VARCHAR(8000),
				Aggregation VARCHAR(10),
				Currency VARCHAR(10),
				Rounding VARCHAR(10),
				ThousandSeperator VARCHAR(10),
				Font VARCHAR(50),
				FontSize VARCHAR(10),
				TextColor VARCHAR(20),
				FontStyle VARCHAR(10),
				CustomField VARCHAR(10),
				ColumnOrder VARCHAR(10),
				RenderAs VARCHAR(10),
				ColumnTemplate VARCHAR(10),
				ScaleMin VARCHAR(10),
				ScaleMax VARCHAR(10),
				ScaleInt VARCHAR(10),
				SubScaleStart VARCHAR(10),
				SubScaleEnd VARCHAR(10),
				SubScaleOrder VARCHAR(10),
				RangeColor VARCHAR(10)
   
		)
		
		IF EXISTS(
		          SELECT 1
		          FROM   (
		                     SELECT COUNT([column_alias]) AS [count_same_name],
		                            [column_alias]
		                     FROM   #rfx_gauge 
		                     WHERE [scale_order] = 1
		                     GROUP BY
		                            [column_alias]
		                 )db
		          WHERE  [count_same_name] > 1
		          
		)
	   BEGIN
		   EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Same display name used in multiple fields.', ''
			RETURN
	   END
	   
	  
	END

	/*
	* To Track the old root dataset_id when dataset source is changed
	* */
	IF OBJECT_ID('tempdb..#rootdataset_before_update') IS NOT NULL
	DROP TABLE #rootdataset_before_update	
			
	CREATE TABLE #rootdataset_before_update(
		root_dataset_id INT
	)
	
	--## USED GLOBAL TEMPORARY TABLE DUE TO NESTED INSERT EXEC ERROR ON PARENT PROC
	IF OBJECT_ID(N'tempdb..##rootdataset_before_update') IS NOT NULL
		DROP TABLE ##rootdataset_before_update

	SET @sql = 'SELECT DISTINCT root_dataset_id into ##rootdataset_before_update FROM ' + @rfx_report_page_gauge + ' rpc WHERE rpc.root_dataset_id <> ' + CAST(@root_dataset_id AS VARCHAR(10))

	EXEC (@sql)

	INSERT INTO #rootdataset_before_update
	SELECT root_dataset_id FROM ##rootdataset_before_update

	IF OBJECT_ID(N'tempdb..##rootdataset_before_update') IS NOT NULL
		DROP TABLE ##rootdataset_before_update
		
	IF @report_page_gauge_id IS NOT NULL
	BEGIN
		CREATE TABLE #rfx_gauge_name_u (name_exists TINYINT)
		SET @sql = 'INSERT INTO #rfx_gauge_name_u ([name_exists]) 
					SELECT TOP(1) 1 FROM ' + @rfx_report_page_gauge + ' 
					WHERE report_page_gauge_id <> ' + CAST(@report_page_gauge_id AS VARCHAR(10)) + ' 
						AND page_id = ' + CAST(@page_id AS VARCHAR(10)) + ' 
						AND name = ''' + @gauge_name + ''''
		EXEC spa_print @sql
		EXEC (@sql)
		IF EXISTS(SELECT 1 FROM #rfx_gauge_name_u) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'gauge name already used.', ''
			 RETURN
		END	
		SET @sql = 'UPDATE ' + @rfx_report_page_gauge + '
					SET  page_id = ' + CAST(@page_id AS VARCHAR(10)) + ',
						 root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(10)) + ',
						 [name] = ''' + @gauge_name + ''',
						 [type_id] = ' + CAST(@gauge_type_id AS VARCHAR(10)) + ',
						 [top] = ' + @top + ',
						 width = ' + @width + ',
						 height = ' + @height + ',
						 [left] = ' + @left + ',
						 gauge_label_column_id = ' + CAST(@gauge_label_column_id AS VARCHAR) + '
					WHERE report_page_gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR)
		IF @xml IS NOT NULL
		BEGIN			
			SET @sql +=	'		CREATE TABLE #rfx_rgc_old
					(
						gauge_id                INT,
						dataset_id              INT,
						column_id               INT,
						report_gauge_column_id  INT
					)
					
					CREATE TABLE #rfx_rgc_new
					(
						gauge_id                INT,
						dataset_id              INT,
						column_id               INT,
						report_gauge_column_id  INT,
						alias					VARCHAR(500) COLLATE DATABASE_DEFAULT
					)
					
					DELETE FROM ' + @rfx_report_gauge_column + '
					OUTPUT deleted.gauge_id, deleted.dataset_id, deleted.column_id, deleted.report_gauge_column_id 
					INTO #rfx_rgc_old(gauge_id, dataset_id, column_id, report_gauge_column_id) 
					WHERE gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR) + '
					
					INSERT INTO ' + @rfx_report_gauge_column + ' (
						gauge_id,
						column_id,
						column_order,
						dataset_id, 
						scale_minimum,
						scale_maximum, 
						scale_interval, 
						alias,
						functions,
						aggregation,
						font,
						font_size,
						font_style,
						text_color,
						custom_field,
						render_as,
						column_template,
						currency,
						rounding,
						thousand_seperation
					)	                
					OUTPUT 
						INSERTED.gauge_id, 
						INSERTED.dataset_id, 
						INSERTED.column_id, 
						INSERTED.report_gauge_column_id,
						INSERTED.alias  
					INTO #rfx_rgc_new(
						gauge_id, 
						dataset_id, 
						column_id, 
						report_gauge_column_id,
						alias
					) 
					SELECT DISTINCT ' + CAST(@report_page_gauge_id AS VARCHAR) + ',												
					    rc.column_id,																				
					    rc.column_order,
					    rc.dataset_id,
					    rc.scale_minimum,
					    rc.scale_maximum,
					    rc.scale_interval,
					    rc.column_alias,  
					    CASE WHEN (rc.function_name = '''') 
							THEN NULL ELSE rc.function_name 
					    END
					    ,
					    CASE WHEN (rc.aggregation = '''') 
							THEN NULL ELSE rc.aggregation
						END,
					    CASE WHEN (rc.font = '''')
							THEN NULL ELSE rc.font
					    END,
						CASE WHEN (rc.font_size = '''')
							THEN NULL ELSE rc.font_size
					    END,
						rc.font_style,
						CASE WHEN (rc.text_color = '''')
							THEN NULL ELSE rc.text_color
					    END,
						rc.custom_field,
						rc.render_as,
						rc.column_template,
						rc.currency,
						rc.rounding,
						rc.thousand_seperation
					FROM   #rfx_gauge rc					
					
					SELECT o.report_gauge_column_id [report_gauge_column_id_old],
						   n.report_gauge_column_id [report_gauge_column_id_new]
					INTO #rfx_rgcs
					FROM #rfx_rgc_old o
					INNER JOIN #rfx_rgc_new n ON  o.gauge_id = n.gauge_id
						AND o.dataset_id = n.dataset_id
						AND o.column_id = n.column_id 
					
					DELETE rgcs
					FROM ' + @rfx_report_gauge_column_scale + ' rgcs
					INNER JOIN #rfx_rgcs rgc ON rgc.report_gauge_column_id_old = rgcs.report_gauge_column_id
					
					INSERT INTO ' + @rfx_report_gauge_column_scale + '(
						report_gauge_column_id, 
						placement, 
						scale_start, 
						scale_end, 
						column_id, 
						scale_range_color
						)
					SELECT rrn.report_gauge_column_id
						   ,rc.scale_order
						   ,rc.scale_start
						   ,rc.scale_end
						   ,rc.column_id
						   ,rc.color							   						   
					FROM #rfx_gauge rc
					INNER JOIN #rfx_rgc_new rrn ON rrn.alias = rc.column_alias 					
					WHERE rc.scale_start <> ''''
					ORDER BY rc.scale_start, rc.scale_end					
					'	
		END
	END
	ELSE
	BEGIN
		CREATE TABLE #rfx_gauge_name (name_exists TINYINT)
		SET @sql = 'INSERT INTO #rfx_gauge_name ([name_exists]) 
					SELECT TOP(1) 1 FROM ' + @rfx_report_page_gauge + ' 
					WHERE page_id = ' + CAST(@page_id AS VARCHAR(10)) + ' 
						AND name = ''' + @gauge_name + ''''
		EXEC spa_print @sql
		EXEC (@sql)
		
		IF EXISTS(SELECT 1 FROM #rfx_gauge_name) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'gauge name already used.', ''
			RETURN
		END	
		SET @sql = 'DECLARE @gauge_id INT
					INSERT INTO ' + @rfx_report_page_gauge + '(page_id,root_dataset_id,[name],[type_id],[top],width,height,[left], gauge_label_column_id )
					VALUES(
						' + CAST(@page_id AS VARCHAR(10)) + ',
						' + CAST(@root_dataset_id AS VARCHAR(10)) + ',
						''' + @gauge_name + ''',
						' + CAST(@gauge_type_id AS VARCHAR(10)) + ',
						' + @top + ',
						' + @width + ',
						' + @height + ',
						' + @left + ',
						' + CAST(@gauge_label_column_id AS VARCHAR(10)) + '
					)'	
		IF @xml IS NOT NULL
		BEGIN				
			SET @sql +=' SET @gauge_id = IDENT_CURRENT(''' + @rfx_report_page_gauge + ''')
					
					CREATE TABLE #rfx_rgc_scale_new
					(
						report_gauge_column_id  INT,
						alias					VARCHAR(500) COLLATE DATABASE_DEFAULT
					)
		
					INSERT INTO ' + @rfx_report_gauge_column + ' (
						gauge_id,
						column_id,
						column_order,
						dataset_id, 
						scale_minimum,
						scale_maximum, 
						scale_interval, 
						alias,
						functions,
						aggregation,
						font,
						font_size,
						font_style,
						text_color,
						custom_field,
						render_as,
						column_template,
						currency,
						rounding,
						thousand_seperation
					)				                
					OUTPUT 
						INSERTED.report_gauge_column_id,
						INSERTED.alias 
					INTO #rfx_rgc_scale_new(
						report_gauge_column_id,
						alias
					) 
					SELECT DISTINCT @gauge_id,
						rc.column_id,																				
					    rc.column_order,
					    rc.dataset_id,
					    rc.scale_minimum,
					    rc.scale_maximum,
					    rc.scale_interval,
					    rc.column_alias,
					    rc.function_name,
					    rc.aggregation,
					    rc.font,
						rc.font_size,
						rc.font_style,
						rc.text_color,
						rc.custom_field,
						rc.render_as,
						rc.column_template,
						rc.currency,
						rc.rounding,
						rc.thousand_seperation						   
					FROM   #rfx_gauge rc
					
					DECLARE @gauge_column_id INT
					SET @gauge_column_id = IDENT_CURRENT(''' + @rfx_report_gauge_column + ''')
					
					INSERT INTO ' + @rfx_report_gauge_column_scale + '(report_gauge_column_id, placement, scale_start, scale_end, scale_range_color, column_id)
					SELECT rrsn.report_gauge_column_id
						   ,rg.scale_order
						   ,rg.scale_start
						   ,rg.scale_end
						   ,rg.color
						   ,rg.column_id							   
					FROM #rfx_gauge rg	
					INNER JOIN #rfx_rgc_scale_new rrsn ON rrsn.alias = rg.column_alias 					
					WHERE rg.scale_start <> ''''
					ORDER BY rg.scale_start, rg.scale_end	
					'
					
					
			END		
	END
	 
	EXEC spa_print @sql 	
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
		EXEC spa_rfx_report_default_paramset 'd', 'g', @user_name, @process_id, @old_root_dataset_id
		FETCH NEXT FROM cur_get_rootdataset_before_update INTO @old_root_dataset_id
	END
	CLOSE cur_get_rootdataset_before_update   
	DEALLOCATE cur_get_rootdataset_before_update	

	/*
	* Insert default parameters for the dataset chosen in the component while saving the component
	* */ 
	EXEC spa_rfx_report_default_paramset 'i', 'g', @user_name, @process_id, @root_dataset_id
	
	DECLARE @report_page_gauge  VARCHAR(MAX)
	DECLARE @sql_exec   NVARCHAR(MAX) 
	
	SET @sql_exec = N'SELECT @report_page_gauge = report_page_gauge_id from ' + @rfx_report_page_gauge
	EXEC sp_executesql @sql_exec, N'@report_page_gauge varchar(max) output', @report_page_gauge = @report_page_gauge OUTPUT
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_gauge_dhx', 'DB Error', 'Failed to save data.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_gauge_dhx', 'Success', 'Data successfully saved.', @report_page_gauge


END
IF @flag = 's'
BEGIN
	SET @sql = 'SELECT main.report_page_gauge_id,
							main.root_dataset_id,
							main.[name],
							main.[type_id],
							main.width,
							main.height,
							main.gauge_label_column_id
					 FROM ' + @rfx_report_page_gauge + ' main
					 WHERE report_page_gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR)
	exec spa_print @sql
	EXEC(@sql)
END
IF @flag = 'a'
BEGIN
	DECLARE @sql_stmt VARCHAR(MAX)
	SET @sql_stmt = 'SELECT main.report_page_gauge_id,
							main.root_dataset_id,
							main.[name],
							main.[type_id],
							main.width,
							main.height,
							main.gauge_label_column_id,
							col.report_gauge_column_id,
							col.gauge_id,
							col.column_id,
							col.column_order,
							col.dataset_id,
							col.scale_minimum,
							col.scale_maximum,
							col.scale_interval,
							col.alias,
							col.functions,
							col.aggregation,
							col.font,
							col.font_size,
							col.font_style,
							col.text_color,
							col.custom_field,
							col.render_as,
							col.column_template,
							col.currency,
							col.rounding,
							col.thousand_seperation
					 FROM ' + @rfx_report_page_gauge + ' main
					 INNER JOIN ' + @rfx_report_gauge_column + ' col ON main.report_page_gauge_id = col.gauge_id 
					 WHERE report_page_gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR) + ' 
					 ORDER BY col.column_order' 
					                 
	EXEC(@sql_stmt)
	exec spa_print @sql_stmt
END


IF @flag = 'g'
BEGIN
	SET @sql = 'SELECT s.report_gauge_column_id,
					   s.placement,
					   s.scale_start,
					   s.scale_end,
					   s.scale_range_color
				FROM ' + @rfx_report_gauge_column_scale + ' s 
				INNER JOIN ' + @rfx_report_gauge_column + ' c ON  c.report_gauge_column_id = s.report_gauge_column_id
				WHERE c.gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR) + ' 
				ORDER BY s.placement'
	exec spa_print @sql
	EXEC(@sql)	
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
						SELECT root_dataset_id  FROM ' + @rfx_report_page_gauge + ' WHERE report_page_gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR)
			EXEC spa_print @sql
			EXEC (@sql)
			
			SET @sql = 'DELETE rgcs
			            FROM   ' + @rfx_report_gauge_column_scale + ' rgcs
	                    INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON  rgc.report_gauge_column_id = rgcs.report_gauge_column_id
 	                    INNER JOIN ' + @rfx_report_page_gauge + ' rpg ON  rpg.report_page_gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR) 						
			EXEC(@sql)


			SET @sql = 'DELETE FROM ' + @rfx_report_gauge_column + ' WHERE gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR)
			EXEC(@sql)
			
			SET @sql = 'DELETE FROM ' + @rfx_report_page_gauge + ' WHERE report_page_gauge_id = ' + CAST(@report_page_gauge_id AS VARCHAR)
			EXEC(@sql)
			
				
			DECLARE @used_root_dataset_id INT 
			SELECT @used_root_dataset_id = used_root_dataset_id FROM #used_root_dataset_id
			/*
			* Delete default parameters for the dataset chosen if no component uses it 
			* */ 
			EXEC spa_rfx_report_default_paramset 'd', 'g', @user_name, @process_id, @used_root_dataset_id
	 
		COMMIT
	 
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_gauge_dhx', 'Success', 'gauge successfully deleted.', @process_id
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	  
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_gauge_dhx', 'Failed', 'Fail to delete data.', @process_id
	END CATCH	
END
	
	
