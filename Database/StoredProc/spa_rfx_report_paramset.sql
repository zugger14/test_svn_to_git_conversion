

IF OBJECT_ID(N'[dbo].[spa_rfx_report_paramset]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_paramset]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-09-10
-- Description: Add/Update Operations for Report Paramsets
 
-- Params:
-- @process_id				: Process Id
-- @report_paramset_id		: Report Paramset Id
-- @page_id					: Page Id
-- @name					: Paramset Name
-- @xml						: Paramset column information in XML format
-- @report_id				: Report Id
-- @paramset_hash			: Paramset Hash
-- @column_id				: Column Id
-- @report_status			: Report Status
-- @report_privilege_type	: Report Privilege Type

-- Sample Use:
-- 1. EXEC [spa_rfx_report_paramset] 's'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_paramset]
	@flag CHAR(1),
	@process_id VARCHAR(50) = NULL,
	@report_paramset_id varchar(1000) = NULL,
	@page_id INT = NULL,
	@name VARCHAR(100) = NULL,
	@xml TEXT = NULL,
	@report_id INT = NULL,
	@paramset_hash VARCHAR(50) = NULL,
	@column_id VARCHAR(100) = NULL,
	@report_status INT = NULL,
	@report_privilege_type CHAR(1) = NULL
AS
SET NOCOUNT ON

DECLARE @user_name            VARCHAR(50) = dbo.FNADBUser() 
IF (@flag <> 'r' and @flag <> 'q')
BEGIN
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
   

	DECLARE @sql                  VARCHAR(MAX)  
	
	--Resolve Process Table Name
	DECLARE @rfx_report_dataset           VARCHAR(300) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
	DECLARE @rfx_report_paramset          VARCHAR(300) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id) 
	DECLARE @rfx_report_param             VARCHAR(300) = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
	DECLARE @rfx_report_dataset_paramset  VARCHAR(300) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
	DECLARE @rfx_report_chart_column      VARCHAR(300) = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
	DECLARE @rfx_report_tablix_column     VARCHAR(300) = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
	DECLARE @rfx_report_page_chart		  VARCHAR(300) = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
	DECLARE @rfx_report_page_tablix       VARCHAR(300) = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
	DECLARE @rfx_report_page			  VARCHAR(300) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
	DECLARE @rfx_report					  VARCHAR(300) = dbo.FNAProcessTableName('report', @user_name, @process_id)

	DECLARE @rfx_report_page_gauge            VARCHAR(200)
	DECLARE @rfx_report_gauge_column          VARCHAR(200)
	DECLARE @rfx_report_gauge_column_scale    VARCHAR(200)

	SET @rfx_report_page_gauge				= dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
	SET @rfx_report_gauge_column			= dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
	SET @rfx_report_gauge_column_scale		= dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)


	-- setting @is_admin
	DECLARE @is_admin INT, @report_owner VARCHAR(50), @is_owner INT 
	SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_name, 1)
END

IF (@flag <> 'y' AND @flag <> 'm' AND  @flag <> 'r' AND  @flag <> 'q')
BEGIN
	--setting @report_owner from process_table
	DECLARE @sql_specific NVARCHAR(512) = 'SELECT @report_owner = owner FROM ' + @rfx_report
	EXECUTE sp_executesql @sql_specific, N'@report_owner VARCHAR(50) OUTPUT', @report_owner = @report_owner OUTPUT

	IF @report_owner = @user_name OR @report_privilege_type = 'e'
	BEGIN
		SET @is_owner = 1
	END
	ELSE 
		SET @is_owner = 0	
END

IF @flag = 's'
BEGIN
	--SELECT @report_owner
	
    SET @sql = 'SELECT rp.report_paramset_id [Paramset ID],
                       rp.[name] [Name],
                       rp.create_user [Create User],
                       ''' + @user_name + ''' [Application User],
                       ''' + @report_owner + ''' [Report Owner]                       
                FROM ' + @rfx_report_paramset + ' rp
                LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rp.paramset_hash
                WHERE rp.page_id = ' + CAST( ISNULL(@page_id, '') AS VARCHAR(50)) + '
                AND 1 = 1
                '    
                +
                CASE WHEN @is_admin = 1 OR @is_owner = 1 THEN ''
					 ELSE 
					 ' --AND rpp.user_id = ''' + @user_name + '''
					   --AND rpp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(''' + @user_name + '''))
					   AND rp.create_user IS NULL OR rp.create_user = ''' + @user_name + '''
					 '
				END                
   -- EXEC spa_print @sql
    EXEC (@sql)
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF @xml IS NOT NULL
			BEGIN
				SET @paramset_hash = dbo.FNAGetNewID()
				DECLARE @idoc  INT
						
				--Create an internal representation of the XML document.
				EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

				-- Create temp table to store the report_name and report_hash
				IF OBJECT_ID('tempdb..#rfx_param') IS NOT NULL
					DROP TABLE #rfx_param
			
				-- Execute a SELECT statement that uses the OPENXML rowset provider.
				SELECT Paramset [paramset_id],
					   RootDataset [root_dataset_id],
					   Dataset [dataset_id],
					   [Column] [column_id],
					   Operator [operator],
					   InitialValue [initial_value],
					   InitialValue2 [initial_value2],
					   Optional [optional],
					   Hidden [hidden],
					   dbo.FNADecodeXML(WherePart) [where_part],
					   LogicalOperator [logical_operator],
					   ParamOrder [param_order],
					   ParamDepth [param_depth],
					   Label [label],
					   AdvanceMode [advance_mode]
				INTO #rfx_param
				FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
				WITH (
				   Paramset VARCHAR(10),
				   RootDataset VARCHAR(10),
				   Dataset VARCHAR(10),
				   [Column] VARCHAR(10),
				   Operator VARCHAR(10),
				   InitialValue VARCHAR(200),
				   InitialValue2 VARCHAR(200),
				   Optional VARCHAR(10),
				   Hidden VARCHAR(10),
				   WherePart VARCHAR(8000),
				   LogicalOperator VARCHAR(10),
				   ParamOrder VARCHAR(10),
				   ParamDepth VARCHAR(10),
				   Label VARCHAR(255),
				   AdvanceMode VARCHAR(10)
				)
				
				UPDATE #rfx_param SET [where_part] = NULL WHERE [where_part] = ''	
				UPDATE #rfx_param SET [label] = NULL WHERE [label] = ''			
				
				CREATE TABLE #temp_exist ([name] TINYINT)
				SET @sql =  'INSERT INTO #temp_exist ([name]) SELECT TOP(1) 1 FROM ' + @rfx_report_paramset + ' WHERE page_id = ' + CAST(@page_id AS VARCHAR(100)) + ' AND  name = ''' + @name + ''''
			--	exec spa_print @sql
				EXEC(@sql)
				IF EXISTS (SELECT 1 FROM #temp_exist)
				BEGIN
					EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset', 'DB Error', 'Parameset name already exists.', ''
					RETURN
				END
				
				SET @sql = 'DECLARE @paramset_id INT
							DECLARE @dataset_paramset_id INT
							
							INSERT INTO ' + @rfx_report_paramset + '(page_id, [name],paramset_hash, report_status_id)
							VALUES(
								' + CAST(@page_id AS VARCHAR(10)) + ',
								''' + CAST(@name AS VARCHAR(100)) + ''',
								''' + dbo.FNAGetNewID() + ''',
								' + CAST(@report_status AS VARCHAR(10)) + '
							  )
				
							SET @paramset_id  = IDENT_CURRENT(''' + @rfx_report_paramset + ''')
							
							INSERT INTO ' + @rfx_report_dataset_paramset + ' (paramset_id, root_dataset_id, where_part,advance_mode)
							SELECT MAX(@paramset_id),
								   root_dataset_id,
								   where_part,
								   advance_mode
							FROM   #rfx_param GROUP BY root_dataset_id, where_part, advance_mode
							
							--SET @dataset_paramset_id  = IDENT_CURRENT(''' + @rfx_report_dataset_paramset + ''')
							
							INSERT INTO ' + @rfx_report_param + '(dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
							SELECT rrdp.report_dataset_paramset_id,
								   dataset_id,
								   column_id,
								   MAX(operator),
								   MAX(initial_value),
								   MAX(initial_value2),
								   MAX(optional),
								   MAX(hidden),
								   MAX(logical_operator),
								   MAX(param_order),
								   MAX(param_depth),
								   MAX(label)
							FROM  #rfx_param rp_temp 
							INNER JOIN ' + @rfx_report_dataset + ' rd ON rp_temp.dataset_id = rd.report_dataset_id
							INNER JOIN ' + @rfx_report_dataset_paramset + ' rrdp ON rrdp.paramset_id = @paramset_id AND rrdp.root_dataset_id = rp_temp.root_dataset_id
							GROUP BY rrdp.report_dataset_paramset_id, dataset_id, column_id, operator' 
			--	exec spa_print @sql
				EXEC(@sql)
			END
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_paramset', 'Success', 'Data successfully inserted .', @process_id
		COMMIT	
	END TRY
	BEGIN CATCH
		DECLARE @error_desc VARCHAR(1000)
		DECLARE @error_no INT
		SET @error_no = ERROR_NUMBER()		
		SET @error_desc = ERROR_MESSAGE()
		
		EXEC spa_print 'Error:', @error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_report_paramset', @error_desc, 'Failed to insert data.', ''
	END	CATCH
END
IF @flag = 'a'
BEGIN
	SET @sql = CAST('' AS VARCHAR(MAX)) + '
			/*----------Populate report_param properties Parent paramset if present START---------*/
			DECLARE @sql VARCHAR(MAX)
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
			
			EXEC spa_rfx_get_dependent_parameters ' + cast(@report_paramset_id AS VARCHAR(50)) + ' ,''p'', ''' + cast(@process_id AS VARCHAR(200)) + ''', @sql OUTPUT
			INSERT INTO #dependent_report_parameters_returned
			EXEC(@sql)
			
			/*----------Populate report_param properties Parent paramset END ---------*/
	
			SELECT report_paramset_id,
	                   MAX(page_id) page_id,
	                   MAX([name]) [name],
	                   MAX(report_param_id) report_param_id,
	                   MAX(dataset_paramset_id) dataset_paramset_id,
	                   dataset_id,
	                   column_id,
	                   operator,
	                   MAX(initial_value) initial_value,
	                   MAX(initial_value2) initial_value2,
	                   MAX(optional + 0) optional,
	                   MAX(hidden + 0) hidden,
	                   MAX(logical_operator) logical_operator,
	                   MAX(param_order) param_order,
	                   MAX(param_depth) param_depth,
	                   MAX(where_part) where_part,
	                   root_dataset_id,
	                   MAX(REQUIRED) REQUIRED,
	                   MAX(widget_type) widget_type,
	                   append_filter,
	                   MAX(label) label,
					   MAX(report_status) [report_status],
					   MAX(advance_mode) [advance_mode],
					   MAX(unsaved_param)[unsaved_param]	
	            FROM   
				(SELECT rps.report_paramset_id,
				        rps.page_id,
				        rps.[name],
				        rp.report_param_id,
				        rp.dataset_paramset_id,
				        rp.dataset_id,
				        rp.column_id,
				    --    rp.operator,
				    --    CASE WHEN rp.initial_value = '''' OR rp.initial_value IS NULL THEN dsc.param_default_value
							 --ELSE rp.initial_value END initial_value,
				    --    rp.initial_value2,
				    --    rp.optional,
				    --    rp.hidden,
				    --    rp.logical_operator,
				    --    rp.param_order,
				    --    rp.param_depth,
				        ISNULL(NULLIF(drpr.dependent_operator, ''''), rp.operator ) operator,
				        CASE WHEN ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULLIF(rp.initial_value,'''')) IS null THEN dsc.param_default_value
							 ELSE ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULLIF(rp.initial_value,'''')) END initial_value,
				        ISNULL(NULLIF(drpr.dependent_initial_value2, ''''), rp.initial_value2) initial_value2,
				        ISNULL(NULLIF(drpr.dependent_optional, ''''), rp.optional) optional,
				        ISNULL(NULLIF(drpr.dependent_hidden, ''''), rp.hidden) hidden,
				        ISNULL(NULLIF(drpr.dependent_logical_operator, ''''), rp.logical_operator)logical_operator,
				        ISNULL(NULLIF(drpr.dependent_param_order, ''''), rp.param_order) param_order,
				        ISNULL(NULLIF(drpr.dependent_param_depth, ''''), rp.param_depth) param_depth,
				        rdp.where_part,
				        rdp.root_dataset_id root_dataset_id,
				        CASE WHEN dsc.reqd_param = 1 THEN 1 ELSE 0 END required,
				        rw.name [widget_type],
				        dsc.append_filter,
				        rp.label,
						rps.report_status_id [report_status],
						rdp.advance_mode [advance_mode]		
						, 0 [unsaved_param]	
				 FROM   ' + @rfx_report_paramset + ' rps
				 LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.paramset_id = rps.report_paramset_id
				 LEFT JOIN ' + @rfx_report_param + ' rp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				 LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id
				 LEFT JOIN report_widget rw ON  rw.report_widget_id = dsc.widget_id
				 --LEFT JOIN report_status rs ON rs.report_status_id = rps.report_status_id
				 LEFT JOIN #dependent_report_parameters_returned drpr 
				 	 ON drpr.dependent_column_name = dsc.[name]
				 WHERE rps.report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + ' 
				 
				 UNION  

				--grab required columns to be shown by default for Default Paramset (one that is automatically added when adding page)
				 SELECT rps.report_paramset_id,
				        rps.page_id,
				        rps.[name],
				        NULL report_param_id,
				        NULL dataset_paramset_id,
				        rd.report_dataset_id dataset_id,
				        dsc.data_source_column_id column_id
						, ISNULL(NULLIF(drpr.dependent_operator, ''''),  CASE WHEN dsc.widget_id IN (1, 2, 6) THEN 1 ELSE 9 END) operator
						, ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULL) initial_value
						, ISNULL(NULLIF(drpr.dependent_initial_value2, ''''), NULL) initial_value2
						, ISNULL(NULLIF(drpr.dependent_optional, ''''), 0) optional
						, ISNULL(NULLIF(drpr.dependent_hidden, ''''), 0) hidden
						, ISNULL(NULLIF(drpr.dependent_logical_operator, ''''), 1)logical_operator
						, ISNULL(NULLIF(drpr.dependent_param_order, ''''), RANK( )OVER(ORDER BY data_source_column_id)-1) param_order
						, ISNULL(NULLIF(drpr.dependent_param_depth, ''''), 0) param_depth,
				        rd.[alias] + ''.['' + dsc.[name] + '']=''''@'' + dsc.[name] + '''''''' where_part,
				        ISNULL(rd.root_dataset_id, rd.report_dataset_id) root_dataset_id,
				        CASE WHEN dsc.reqd_param = 1 THEN 1 ELSE 0 END required,
				        rw.name [widget_type],
				        dsc.append_filter,
				        NULL as label,
						rps.report_status_id [report_status],
						0 [advance_mode]	
						, 1 [unsaved_param]	
				 FROM   ' + @rfx_report_paramset + ' rps
				 INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rps.page_id
				 INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_id = rp.report_id
				 INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
				 INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id
				 LEFT JOIN report_widget rw on rw.report_widget_id = dsc.widget_id
				 LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.paramset_id = rps.report_paramset_id
					AND rdp.root_dataset_id  = ISNULL(rd.root_dataset_id, rd.report_dataset_id)
				 LEFT JOIN ' + @rfx_report_param + ' rparam ON rparam.column_id = dsc.data_source_column_id
					AND rparam.dataset_paramset_id = rdp.report_dataset_paramset_id
				 LEFT JOIN #dependent_report_parameters_returned drpr 
			 	 ON drpr.dependent_column_name = dsc.[name]	
				 WHERE rps.report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + '
					AND dsc.reqd_param = 1 
					AND rparam.report_param_id IS NULL
				) params
			GROUP BY report_paramset_id, root_dataset_id, dataset_id, column_id, operator, append_filter
			ORDER BY required DESC'
				
	--PRINT(@sql)
	EXEC (@sql)
END

IF @flag = 'u'
BEGIN
	SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRAN
		CREATE TABLE #temp_exist_u ([name] TINYINT)
		SET @sql =  'INSERT INTO #temp_exist_u ([name]) SELECT TOP(1) 1 FROM ' + @rfx_report_paramset + ' WHERE report_paramset_id <> ' + CAST(@report_paramset_id AS VARCHAR(50)) + ' AND page_id = ' + CAST(@page_id AS VARCHAR(50)) + ' AND name = ''' + @name + ''''
	--	exec spa_print @sql
		EXEC(@sql)
		IF EXISTS (SELECT 1 FROM #temp_exist_u)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset', 'DB Error', 'Parameset name already exists.', ''
			RETURN
		END
		SET @sql = 'UPDATE ' + @rfx_report_paramset + '
						SET [name] = ''' + @name + ''',
							[report_status_id] = ' + CAST(@report_status AS VARCHAR(10)) + '
					WHERE report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
		--PRINT @sql
		EXEC (@sql)
		
		SET @sql ='DELETE 
		           FROM   ' + @rfx_report_param + '
		           WHERE  dataset_paramset_id IN (SELECT report_dataset_paramset_id FROM ' + @rfx_report_dataset_paramset + ' WHERE paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + ')'
		--PRINT @sql
		EXEC (@sql)
		
		SET @sql ='DELETE FROM ' + @rfx_report_dataset_paramset + '
					WHERE paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
		--PRINT @sql
		EXEC (@sql)
		
		IF @xml IS NOT NULL
		BEGIN
			DECLARE @idoc1  INT
					
			--Create an internal representation of the XML document.
			EXEC sp_xml_preparedocument @idoc1 OUTPUT,@xml

			-- Create temp table to store the report_name and report_hash
			IF OBJECT_ID('tempdb..#rfx_param1') IS NOT NULL
				DROP TABLE #rfx_param1
								
			-- Execute a SELECT statement that uses the OPENXML rowset provider.
			SELECT Paramset [paramset_id],
				   RootDataset [root_dataset_id],
				   Dataset [dataset_id],
				   [Column] [column_id],
				   Operator [operator],
				   InitialValue [initial_value],
				   InitialValue2 [initial_value2],
				   Optional [optional],
				   Hidden [hidden],
				   WherePart [where_part],
				   LogicalOperator [logical_operator],
				   ParamOrder [param_order],
				   ParamDepth [param_depth],
				   Label [label],
				   AdvanceMode [advance_mode]				   
			INTO #rfx_param1
			FROM OPENXML(@idoc1, '/Root/PSRecordset', 1)
			WITH (
			   Paramset VARCHAR(10),
			   RootDataset VARCHAR(10),
			   Dataset VARCHAR(10),
			   [Column] VARCHAR(10),
			   Operator VARCHAR(10),
			   InitialValue VARCHAR(200),
			   InitialValue2 VARCHAR(200),
			   Optional VARCHAR(10),
			   Hidden VARCHAR(10),
			   WherePart VARCHAR(8000),
			   LogicalOperator VARCHAR(10),
			   ParamOrder VARCHAR(10),
			   ParamDepth VARCHAR(10),
			   Label VARCHAR(255),
			   AdvanceMode VARCHAR(10)
			)	
			
			UPDATE #rfx_param1 SET [where_part] = NULL WHERE [where_part] = ''
			UPDATE #rfx_param1 SET [label] = NULL WHERE [label] = ''
							
			SET @sql = 'INSERT INTO ' + @rfx_report_dataset_paramset + ' (paramset_id, root_dataset_id, where_part,advance_mode)
						SELECT ' + MAX(CAST(@report_paramset_id AS VARCHAR(50))) + ',
							   root_dataset_id,
							   where_part,
							   advance_mode
						FROM   #rfx_param1 GROUP BY root_dataset_id, where_part, advance_mode' 
		--	EXEC spa_print @sql 
			EXEC (@sql)
			SET @sql = 'INSERT INTO ' + @rfx_report_param + '(dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
						SELECT rrdp.report_dataset_paramset_id,
							   dataset_id,
							   column_id,
							   operator,
							   MAX(initial_value),
							   MAX(initial_value2),
							   MAX(optional),
							   MAX(hidden),
							   MAX(logical_operator),
							   MAX(param_order),
							   MAX(param_depth),
							   MAX(label)
						FROM  #rfx_param1 rp_temp 
						INNER JOIN ' + @rfx_report_dataset + ' rd ON rp_temp.dataset_id = rd.report_dataset_id
						INNER JOIN ' + @rfx_report_dataset_paramset + ' rrdp ON rrdp.paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + ' AND rrdp.root_dataset_id = rp_temp.root_dataset_id
						GROUP BY rrdp.report_dataset_paramset_id, dataset_id, column_id, operator' 
		--	EXEC spa_print @sql
			EXEC (@sql)
		END					
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_paramset', 'Success', 'Data successfully updated .', @process_id
		
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @edit_error_desc VARCHAR(1000)
		DECLARE @edit_error_no INT
		SET @edit_error_no = ERROR_NUMBER()		
		SET @edit_error_desc = ERROR_MESSAGE()
		
		EXEC spa_print 'Error:', @edit_error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no, 'Reporting FX', 'spa_rfx_report_paramset', @edit_error_desc, 'Failed to update data.', ''
	END CATCH
END
IF @flag = 'd'
BEGIN
	BEGIN TRY
		CREATE TABLE #temp_paramset (last_paramset TINYINT)
		SET @sql = 'DECLARE @report_page_id INT
					SELECT @report_page_id = rp.page_id FROM ' + @rfx_report_paramset + ' rp WHERE report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + 
					' INSERT INTO #temp_paramset ([last_paramset])
					  SELECT 1
					  FROM   ' + @rfx_report_paramset + '
					  WHERE  page_id = @report_page_id
					  HAVING COUNT(*) = 1
					 ' 
	--	EXEC spa_print @sql
		EXEC (@sql)
		
		IF EXISTS(SELECT 1 FROM #temp_paramset) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'report_paramset', 'spa_rfx_report_paramset', 'DB Error', 'Cannot delete Paramset. Atleast one paramset should be present.', ''
			DROP TABLE #temp_paramset
			RETURN
		END
		ELSE
		BEGIN
			BEGIN TRAN
			SET @sql = 'DECLARE @dataset_paramset_id VARCHAR(500)
						SELECT @dataset_paramset_id = COALESCE(@dataset_paramset_id + '','' ,'''') + CAST(report_dataset_paramset_id AS VARCHAR)
						FROM   ' + @rfx_report_dataset_paramset + '
						WHERE  paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + '
						
						DELETE FROM ' + @rfx_report_dataset_paramset + '
						WHERE paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + '
						
						DELETE FROM ' + @rfx_report_param + '
						WHERE dataset_paramset_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@dataset_paramset_id))'
		--	EXEC spa_print @sql
			EXEC (@sql)
			
			SET @sql = 'DELETE FROM ' + @rfx_report_paramset + '
						WHERE report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
		--	EXEC spa_print @sql
			EXEC (@sql) 
			
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_paramset', 'Success', 'Data succesfully deleted.', @process_id			
			COMMIT
		END
	END TRY
	BEGIN CATCH
		DECLARE @edit_error_desc1 VARCHAR(1000)
		DECLARE @edit_error_no1 INT
		SET @edit_error_no1 = ERROR_NUMBER()		
		SET @edit_error_desc1 = ERROR_MESSAGE()
		
		EXEC spa_print 'Error:', @edit_error_desc1
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no1, 'Reporting FX', 'spa_rfx_report_paramset', @edit_error_desc1, 'Failed to delete data.', ''		
	END CATCH
END
IF @flag = 'h'
BEGIN
	--one used report dataset per tab
	SET @sql = 'SELECT DISTINCT rd.report_dataset_id [Report Datasets ID],
					CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[batch_export_'') 
						WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
						ELSE ds.[name]
					END 
                    + '' ('' + rd.[alias] + '')'' [name],
                   rd.source_id
                FROM   ' + @rfx_report_dataset + ' rd
                INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
                INNER JOIN (
                	SELECT rpc.root_dataset_id 
					FROM ' + @rfx_report_page_chart + ' rpc
                	WHERE rpc.page_id = ' + CAST(@page_id AS VARCHAR(10))+ '
					
					UNION ALL				
					
					SELECT rpt.root_dataset_id 
					FROM ' + @rfx_report_page_tablix + ' rpt
                	WHERE rpt.page_id = ' + CAST(@page_id AS VARCHAR(10))+ '
                	
                	union all
                	
                	SELECT rpc.root_dataset_id 
					FROM ' + @rfx_report_page_gauge + ' rpc
                	WHERE rpc.page_id = ' + CAST(@page_id AS VARCHAR(10))+ '
                	
                	
                ) rd_used ON rd_used.root_dataset_id = rd.report_dataset_id
	            WHERE rd.root_dataset_id IS NULL
                '
   -- EXEC spa_print @sql 
    EXEC (@sql)
END
IF @flag = 'c'
BEGIN
    /*
    * Example dataset 
    * sdh
    *	sdd (child of sdh)
    *	sdp (child of sdh)
    *	
    * If only sdp.* columns are used in Tablix/Chart, we need to show columns of all connected dataset (sdh, sdd, sdp).
    * First set in CROSS Apply gives self, i.e. sdp
    * Second set gives parent set, i.e. sdh
    * Third set gives silblings (means child of sdh), means sdd and sdp
    * 
    * Unioning all gives the required result (sdh, sdd, sdp)
    *
    */
    SET @sql =
			'SELECT DISTINCT 
				rd.root_dataset_id,
				dsc.[data_source_column_id],
				rd.[alias] + ''.'' + dsc.[alias] AS [name],
				rd.dataset_id dataset_id,
				dsc.[name] column_name
				,rw.name [widget_type],
				dsc.append_filter,
				dsc.param_data_source,
				dsc.param_default_value	
			FROM 
			(
				SELECT rcc.dataset_id, rpc.root_dataset_id  
				FROM ' + @rfx_report_chart_column + ' rcc 
				INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rcc.chart_id = rpc.report_page_chart_id 
					AND rpc.page_id = ' + CAST(@page_id AS VARCHAR)+ '
				
				UNION 				
				
				SELECT rtc.dataset_id, rpt.root_dataset_id 
				FROM  ' + @rfx_report_tablix_column + ' rtc
				INNER JOIN '  + @rfx_report_page_tablix + ' rpt ON rtc.tablix_id = rpt.report_page_tablix_id 
					AND rpt.page_id = ' + CAST(@page_id AS VARCHAR) + '
				
				UNION 				
				
				SELECT rtc.dataset_id, rpt.root_dataset_id 
				FROM  ' + @rfx_report_gauge_column + ' rtc
				INNER JOIN '  + @rfx_report_page_gauge + ' rpt ON rtc.gauge_id = rpt.report_page_gauge_id 
					AND rpt.page_id = ' + CAST(@page_id AS VARCHAR) + '
				
			) used_ds
			CROSS APPLY (
				--used dataset i.e. self (sdp)
				SELECT ISNULL(rd_used.root_dataset_id, report_dataset_id) root_dataset_id, report_dataset_id dataset_id, source_id, alias 
				FROM ' + @rfx_report_dataset + ' rd_used
				WHERE rd_used.report_dataset_id = used_ds.dataset_id
				
				UNION
				
				--root dataset (sdh)
				SELECT report_dataset_id, report_dataset_id dataset_id, source_id, alias 
				FROM  ' + @rfx_report_dataset + ' rd_root
				WHERE rd_root.report_dataset_id = used_ds.root_dataset_id
						
				UNION
				
				--child of parent of used dataset if it is a leaf dataset (i.e. sibling, which is sdd, sdp)
				--child of used dataset if it is a root dataset
				SELECT rd_child.root_dataset_id root_dataset_id, rd_child.report_dataset_id dataset_id, rd_child.source_id, rd_child.alias 
				FROM  ' + @rfx_report_dataset + ' rd_used
				LEFT JOIN ' + @rfx_report_dataset + ' rd_parent ON rd_parent.report_dataset_id = rd_used.root_dataset_id
				INNER JOIN ' + @rfx_report_dataset + ' rd_child ON rd_child.root_dataset_id = ISNULL(rd_parent.report_dataset_id, rd_used.report_dataset_id)
				WHERE rd_used.report_dataset_id = used_ds.dataset_id
			) rd
			INNER JOIN data_source ds ON  rd.source_id = ds.data_source_id
			INNER JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
			INNER JOIN report_widget rw on rw.report_widget_id = dsc.widget_id '
			
			IF @column_id IS NOT NULL
				SET @sql = @sql + ' where dsc.[data_source_column_id]=' + @column_id 
			 
			SET @sql = @sql + ' ORDER BY [name]'
	
   -- EXEC spa_print @sql 
    EXEC (@sql)
END
IF @flag = 'x' -- populate the required parameter list
BEGIN
    SET @sql = 'SELECT NULL report_paramset_id, NULL, NULL, NULL, NULL, rd.report_dataset_id dataset_id ,
                       dsc.[data_source_column_id] column_id,
                       NULL, NULL, NULL, NULL, NULL, rd.[alias] + ''.['' + dsc.[name] + '']=''''@'' + dsc.[name] + '''''''' where_part, 
                       CASE 
                            WHEN rd.root_dataset_id IS NULL THEN rd.[report_dataset_id]
                            ELSE rd.root_dataset_id
                       END root_dataset_id, 1 required
                       ,rw.name [widget_type],
                       dsc.append_filter,
                       NULL as label
                FROM   ' + @rfx_report_dataset + ' rd
                INNER JOIN data_source ds ON  rd.source_id = ds.data_source_id
                INNER JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
                INNER JOIN report_widget rw on rw.report_widget_id = dsc.widget_id				
                WHERE  rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + '
                AND dsc.reqd_param = 1 ORDER BY rd.root_dataset_id ASC'
   -- EXEC spa_print @sql 
    EXEC (@sql)
END

IF @flag = 'y'
BEGIN
	declare @sec_filter_info varchar(max) = cast(@xml as varchar(max))

	--declare @sec_filter_info varchar(max) = 'as_of_date=NULL,block_define_id=NULL,block_type=NULL,commodity_id=NULL,counterparty_id=NULL,create_ts_from=NULL,create_ts_to=NULL,deal_id=NULL,deal_lock=NULL,detail_phy_fin_flag=NULL,formula_curve_id=NULL,legal_entity=NULL,source_deal_header_id=NULL,source_deal_type_id=NULL,template_id=NULL,term_end=NULL,term_start=NULL,update_ts_from=NULL,update_ts_to=NULL,counterparty_type=NULL,buy_sell_flag=NULL,confirm_status_id=NULL,contract_id=NULL,deal_date_from=NULL,deal_date_to=NULL,deal_status_id=NULL,deal_sub_type_type_id=NULL,index_id=NULL,location_id=NULL,period_from=NULL,period_to=NULL,physical_financial_flag=NULL,pnl_source_value_id=NULL,source_counterparty_id=NULL,sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,to_as_of_date=NULL,trader_id=NULL_-_88B0C7FB_CEE5_4431_81FF_F5A5100C72C4'
	
	declare @sec_filter_info2 varchar(max) = SUBSTRING(@sec_filter_info, CHARINDEX('_-_', @sec_filter_info, 0)+3, len(@sec_filter_info))
	declare @sec_filter_info1 varchar(max) = replace(@sec_filter_info, '_-_' + @sec_filter_info2, '')

	--select @sec_filter_info1, @sec_filter_info2

	
	DECLARE @rfx_report_filter_string VARCHAR(500) = dbo.FNAProcessTableName('rfx_report_filter_string', @user_name, @sec_filter_info2)

	--select '@flag'='q', '@xml'=@sec_filter_info1, '@process_id'=@sec_filter_info2

	EXEC spa_rfx_report_paramset_dhx @flag='q', @xml=@sec_filter_info1, @process_id=@sec_filter_info2, @result_to_table=@rfx_report_filter_string

	declare @sqln nvarchar(max)
	declare @report_filter_final varchar(max) = @sec_filter_info1
	SET @sqln = '
	SELECT @report_filter_final = rfs.report_filter  
	FROM ' + @rfx_report_filter_string + '  rfs
	'
	EXEC sp_executesql @sqln, N'@report_filter_final VARCHAR(max) OUTPUT', @report_filter_final OUT
	
    SELECT rp.[name], @user_name [user_name], dbo.FNAGetMSSQLVersion() [major_version_no], @report_filter_final [report_filter_final]
    FROM   report_paramset rp
	inner join dbo.SplitCommaSeperatedValues(@report_paramset_id)  scsv on scsv.item = rp.report_paramset_id
    --WHERE  rp.report_paramset_id = @report_paramset_id

	-- Clean up Process Tables Used after the scope is completed when Debug Mode is Off.
	DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')
	SET @rfx_report_filter_string = REPLACE(@rfx_report_filter_string, 'adiha_process.dbo.', '')

	IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
	BEGIN
		EXEC dbo.spa_clear_all_temp_table NULL, @rfx_report_filter_string
	END
END

IF @flag = 'm'
BEGIN
    SELECT dbo.FNAGetMSSQLVersion() [major_version_no]
END
IF @flag = 'r'
BEGIN

    SELECT REPLACE(name,' ', '_') name, item_id FROM (
		SELECT rpt.name AS name,rpt.report_page_tablix_id AS item_id FROM report_paramset rp 
		Left JOIN report_page_tablix rpt ON rp.page_id =rpt.page_id
		WHERE rp.report_paramset_id = @report_paramset_id
		UNION ALL 
		SELECT rpc.name AS name, rpc.report_page_chart_id AS item_id FROM report_paramset rp 
		Left JOIN report_page_chart rpc ON rp.page_id =rpc.page_id
		WHERE rp.report_paramset_id = @report_paramset_id
		UNION  ALL
		SELECT rpg.name AS name, rpg.report_page_gauge_id AS item_id FROM report_paramset rp 
		Left JOIN report_page_gauge rpg ON rp.page_id =rpg.page_id
		WHERE rp.report_paramset_id = @report_paramset_id
	) x WHERE item_id IS NOT null
END
