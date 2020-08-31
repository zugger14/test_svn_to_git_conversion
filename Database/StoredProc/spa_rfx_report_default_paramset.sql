
IF OBJECT_ID(N'[dbo].[spa_rfx_report_default_paramset]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_default_paramset]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-09-17
-- Description: CRUD operations for table report_page_tablix
 
-- Params:
-- @component_type CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_default_paramset]
@flag		VARCHAR(10) 
, @component_type VARCHAR(4)
, @user_name	VARCHAR(50)
, @process_id	VARCHAR(500) 
, @root_dataset_id INT = NULL

AS 
SET NOCOUNT ON
BEGIN
	DECLARE @sql    VARCHAR(MAX)
	DECLARE @rfx_report_page_tablix VARCHAR(200) = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
	DECLARE @rfx_report_page_chart  VARCHAR(200) = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
	DECLARE @rfx_report_page_gauge  VARCHAR(200) = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)



	DECLARE @rfx_report_dataset  VARCHAR(200) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
	DECLARE @rfx_report_paramset  VARCHAR(200) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)

	DECLARE @rfx_report_page  VARCHAR(200) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
	DECLARE @rfx_report_dataset_paramset  VARCHAR(200) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
	DECLARE @rfx_report_param  VARCHAR(200) = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
	
	DECLARE @rfx_component_page VARCHAR(200)
	DECLARE @rfx_component_page_alias VARCHAR(200)
	
	IF @component_type = 't'
	BEGIN 
		SET @rfx_component_page = @rfx_report_page_tablix
	END 
	ELSE IF @component_type = 'c'
	BEGIN 
		SET @rfx_component_page = @rfx_report_page_chart
	END 
	ELSE IF @component_type = 'g'
	BEGIN 
		SET @rfx_component_page = @rfx_report_page_gauge
	END 
	
	/*
	* This process is carried out to eliminate the compulsion of saving the default paramset only for the first time the report is created.
	* Further changes in the paramset caused due to changes in the related parent dataset has to handled seperately by saving the paramset page manaully.
	* Process tables of report_dataset_paramset and report_param are only repopulated if a new dataset is added.
	* Any changes made to the parent dataset of the component like (adding relationships or  adding/changing columns properties to required param)
	  after the dataset has already been populated for this instance will not be handled
	* */
	
	IF @flag = 'i'
	BEGIN
		SET @sql = '
			IF NOT EXISTS(
				SELECT 1 FROM ' +  @rfx_component_page + ' rcp
				INNER JOIN ' + @rfx_report_dataset + ' rd ON ISNULL(rd.root_dataset_id, rd.report_dataset_id) = rcp.root_dataset_id
				INNER JOIN ' + @rfx_report_paramset + ' rp ON rp.page_id = rcp.page_id 
				LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.root_dataset_id = rcp.root_dataset_id
					AND rdp.paramset_id = rp.report_paramset_id
					AND rdp.root_dataset_id = rcp.root_dataset_id
				where rdp.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(20)) + '
			)
				BEGIN
					INSERT INTO ' + @rfx_report_dataset_paramset + ' (paramset_id, root_dataset_id, where_part, advance_mode)
					SELECT 
						DISTINCT rp.report_paramset_id paramset_id
						, rcp.root_dataset_id root_dataset_id
						, NULL where_part
						, 0 advance_mode
					FROM ' + @rfx_component_page + ' rcp
					INNER JOIN ' + @rfx_report_dataset + ' rd ON ISNULL(rd.root_dataset_id, rd.report_dataset_id) = rcp.root_dataset_id
					INNER JOIN ' + @rfx_report_paramset + ' rp ON rp.page_id = rcp.page_id
					INNER JOIN data_source_column dsc ON dsc.source_id = rd.source_id AND dsc.reqd_param = 1 
						WHERE rcp.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(20)) + '
				END ' + '						
				IF  NOT EXISTS(
				SELECT 1 FROM ' + @rfx_component_page + ' rcp
				INNER JOIN ' + @rfx_report_dataset + ' rd ON ISNULL(rd.root_dataset_id, rd.report_dataset_id) = rcp.root_dataset_id
				INNER JOIN ' + @rfx_report_paramset + ' rp ON rp.page_id = rcp.page_id 
				INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.root_dataset_id = rcp.root_dataset_id
				AND rdp.paramset_id = rp.report_paramset_id
				INNER JOIN ' + @rfx_report_param + ' rparam ON rparam.dataset_paramset_id = rdp.report_dataset_paramset_id
				WHERE rdp.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(20)) + '
				)
				BEGIN 
				' + 
				CASE WHEN @component_type = 't' THEN
					'DECLARE @sql VARCHAR(MAX)
					IF OBJECT_ID(''tempdb..#dependent_report_parameters_returned'') IS NOT NULL
						DROP TABLE #dependent_report_parameters_returned		
						

					CREATE TABLE #dependent_report_parameters_returned
					( 
						dependent_report_paramset_id INT 
						,dependent_report_page_tablix_id INT 
						, dependent_component_type CHAR(2) COLLATE DATABASE_DEFAULT
						, dependent_export_table_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
						, dependent_is_global BIT 
						, dependent_column_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
						, dependent_column_id INT
						, dependent_operator VARCHAR(100) COLLATE DATABASE_DEFAULT
						, dependent_initial_value VARCHAR(4000) COLLATE DATABASE_DEFAULT
						, dependent_initial_value2 VARCHAR(4000) COLLATE DATABASE_DEFAULT
						, dependent_optional VARCHAR(100) COLLATE DATABASE_DEFAULT 
						, dependent_hidden VARCHAR(100) COLLATE DATABASE_DEFAULT
						, dependent_logical_operator VARCHAR(100) COLLATE DATABASE_DEFAULT
						, dependent_param_order VARCHAR(100) COLLATE DATABASE_DEFAULT
						, dependent_param_depth VARCHAR(100) COLLATE DATABASE_DEFAULT
						, dependent_label VARCHAR(255) COLLATE DATABASE_DEFAULT
					)

					EXEC spa_rfx_get_dependent_parameters ''1'' ,''p'', ''' + CAST(@process_id AS VARCHAR(200)) + ''', @sql OUTPUT
					INSERT INTO #dependent_report_parameters_returned
					EXEC(@sql)
					'
					ELSE '' END + '
					
					INSERT INTO ' + @rfx_report_param + ' (dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
					SELECT 
					DISTINCT rdp.report_dataset_paramset_id dataset_paramset_id
								, rd.report_dataset_id dataset_id
								, dsc.data_source_column_id column_id ' +
								CASE WHEN @component_type = 't' THEN
								', ISNULL(NULLIF(drpr.dependent_operator, ''''), CASE WHEN dsc.widget_id IN (1, 2, 6) THEN 1 ELSE 9 END) operator
								, ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULL) initial_value
								, ISNULL(NULLIF(drpr.dependent_initial_value2, ''''), NULL) initial_value2
								, ISNULL(NULLIF(drpr.dependent_optional, ''''), 0) optional
								, ISNULL(NULLIF(drpr.dependent_hidden, ''''), 0) hidden
								, ISNULL(NULLIF(drpr.dependent_logical_operator, ''''), 1)logical_operator
								, ISNULL(NULLIF(drpr.dependent_param_order, ''''), RANK( )OVER(ORDER BY data_source_column_id)-1) param_order
								, ISNULL(NULLIF(drpr.dependent_param_depth, ''''), 0) param_depth'
								ELSE
								',  CASE WHEN dsc.widget_id IN (1, 2, 6) THEN 1 ELSE 9 END  operator
								,  NULL initial_value
								,  NULL initial_value2
								,  0 optional
								,  0 hidden
								,  1 logical_operator
								,  RANK( )OVER(ORDER BY data_source_column_id)-1 param_order
								,  0 param_depth'
								END +
								', NULL as label
					FROM ' + @rfx_component_page + ' rcp
					INNER JOIN ' + @rfx_report_dataset + ' rd ON ISNULL(rd.root_dataset_id, rd.report_dataset_id) = rcp.root_dataset_id
					INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp on rdp.root_dataset_id = rcp.root_dataset_id
					INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
					INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id 
					LEFT JOIN report_widget rw on rw.report_widget_id = dsc.widget_id '+ 
					CASE WHEN @component_type = 't' THEN
					'/* join with parent paramset if present*/
					LEFT JOIN #dependent_report_parameters_returned drpr 
					 ON drpr.dependent_column_name = dsc.[name]' 
					 ELSE '' END  + 
					' WHERE  dsc.reqd_param = 1 
					and rdp.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(20)) + '
					END '
			
		
	--PRINT @sql	
--	RETURN
	EXEC (@sql)	

	/*
	* Generate and update the respective where_part
	* Cannot generate where part directly while inserting dataset into report_dataset_paramset since we need to intregate the 
	  the parameters of dependent export table source as well as operator values which reside in report_param table
	* where part is generated only the first time the component is saved i.e when where_part = NULL.
	  It doesnt handle any further addition of columns/dataset to the parent dataset which is made after
	  the component has been saved for the first time.
	* */

	SET @sql = 
	'DECLARE @initial_wherepart VARCHAR(8000) 
	
	SELECT @initial_wherepart = where_part FROM '+ @rfx_report_dataset_paramset + ' rdp where rdp.root_dataset_id
	= ' + CAST(@root_dataset_id AS VARCHAR(20)) + '
	 IF @initial_wherepart IS NULL 
		BEGIN
			IF OBJECT_ID(''tempdb..#where_part'') IS NOT NULL
			DROP TABLE #where_part	
							
			CREATE TABLE #where_part(
			dataset_paramset_id INT
			, root_dataset_id INT
			, ALIAS  VARCHAR(5000) COLLATE DATABASE_DEFAULT
			, name VARCHAR(5000) COLLATE DATABASE_DEFAULT
			, sql_code VARCHAR(500) COLLATE DATABASE_DEFAULT
			)
		 						
			INSERT INTO	#where_part			
			SELECT DISTINCT
			rparam.dataset_paramset_id 
			, rcp.root_dataset_id
			, rd.alias  
			, dsc.name 
			, rpo.sql_code
			FROM  ' +  @rfx_report_param + ' rparam
			INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rparam.dataset_id
			INNER JOIN ' + @rfx_component_page + ' rcp ON rcp.root_dataset_id = ISNULL(rd.root_dataset_id, rd.report_dataset_id)
			INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rparam.column_id
			INNER JOIN report_param_operator rpo ON  rpo.report_param_operator_id = rparam.operator
			WHERE dsc.append_filter = 1	
			and dsc.reqd_param = 1	
			and rcp.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(20)) + '
			
			UPDATE rdp
			SET rdp.where_part = final_where_part.where_part
			FROM 
			(SELECT 
				wp_grouped.dataset_paramset_id 
				, wp_grouped.root_dataset_id
				,''('' + STUFF(( 
					SELECT '' AND '' + wp.alias + ''.['' + wp.name+ ''] '' + wp.sql_code+ '' ('' + '' @'' + wp.name + '')''
					FROM #where_part wp
					WHERE wp.dataset_paramset_id = wp_grouped.dataset_paramset_id 
						AND wp.root_dataset_id = wp_grouped.root_dataset_id
				FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(5000)''), 1, 4, '''') + '')''  AS where_part
				FROM #where_part wp_grouped
				GROUP BY
				 wp_grouped.dataset_paramset_id 
				, wp_grouped.root_dataset_id
			) final_where_part
			INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.report_dataset_paramset_id = final_where_part.dataset_paramset_id 
				AND rdp.root_dataset_id = final_where_part.root_dataset_id 
		END'
	--	EXEC spa_print @sql	
		EXEC (@sql)	
	END
	ELSE IF @flag = 'd'
	BEGIN
		SET @sql = 'IF NOT EXISTS(
		SELECT 1 FROM(
		SELECT 1 comppnent_exist FROM  ' + @rfx_report_page_tablix + ' rpt WHERE rpt.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(MAX)) + '
		UNION
		SELECT 1 comppnent_exist FROM ' +  @rfx_report_page_chart + ' rpc WHERE rpc.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(MAX))+ '
		UNION
		SELECT 1 comppnent_exist FROM ' + @rfx_report_page_gauge + ' rpg WHERE rpg.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(MAX))+ ') dataset_exists )
		BEGIN
		DELETE rparam FROM ' + @rfx_report_param + ' rparam where rparam.dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(MAX)) 
		 + ' DELETE rdp FROM ' + @rfx_report_dataset_paramset + ' rdp where rdp.root_dataset_id = ' + CAST(@root_dataset_id AS VARCHAR(MAX))
		 +' END'

		--PRINT @sql	
		EXEC(@sql)
	END
END	
