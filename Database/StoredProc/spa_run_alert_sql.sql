IF OBJECT_ID(N'[dbo].[spa_run_alert_sql]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_alert_sql]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Executes the SQL logic defined in the Alert Rules

	Parameters :
	@alert_sql_id : Id of the Alert Rule (alert_sql_id FROM alert_sql)
	@process_id : Unique Identifier for Process
	@input_table_name : Process table that contains the data to be processed from workflow
	@source_column : Primary Column of the Workflow Module
	@source_id : Value of the primary column of the workflow module
	@event_trigger_id : Event Trigger Id (event_trigger_id FROM event_trigger)
	@msg_process_table : Process Table to save message instead of message_board
	@workflow_process_id : Unique Identifier for the current Process and other process triggered after current process
	@eod_message : Message passed from Eod steps
	@workflow_group_id : Workflow Group ID of the workflow
	@eod_as_of_date : As Of Date to execute the Eod Steps
	@control_status : Control Status (static_data_values - type_id = 725)
	@run_only_individual_step : 0 - Continue futher steps after completion of the current step
								1 - Stop and dont go further to next step after completioon of the current step
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
 */

CREATE PROCEDURE [dbo].[spa_run_alert_sql] (
    @alert_sql_id        INT,
    @process_id          NVARCHAR(100),
    @input_table_name    NVARCHAR(400) = NULL,
    @source_column		 NVARCHAR(300) = NULL,
    @source_id			 NVARCHAR(300) = NULL,
	@event_trigger_id	 INT = NULL,
	@msg_process_table	 NVARCHAR(400) = NULL,	
	@workflow_process_id NVARCHAR(100) = NULL,
	@eod_message		 NVARCHAR(500) = NULL,
	@workflow_group_id	 INT = NULL,
	@eod_as_of_date		 DATETIME = NULL,
	@control_status		 INT = NULL,
	@run_only_individual_step NCHAR(1) = NULL,
    @batch_process_id    NVARCHAR(50) = NULL,
    @batch_report_param  NVARCHAR(1000) = NULL
)
AS

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()
BEGIN
	
	--PRINT '@alert_sql_id --------------' + CAST(@alert_sql_id AS VARCHAR(10))
	--BEGIN -------EXECUTION OF SQL LOGIC
		--------------------------------------------IMPORTANT NOTE ------------------------------
		--------------------------------------------TEMPORARY LOGIC------------------------------
		/*	
		The following logic will reside within the SQL logic defined by @sql_id 
			The SQL logic might be saved in new report writer, old reprot writer or 
			somewhere else. For now this is a temporary logic for demonstration
			purpose only. 
		*/

		/*
			If @input_table_name is not null THEN GRAB all the inputs
			assume column name such as source_deal_heder_id etc... as an example
			select @source_deal_header_id = source_deal_header_id from @input_table_name
			Now going forward this variable can be used

			Also if notification is to be provided for trader and current user then 
			need to pass this in the spa_insert_alert_output_status
			
			format :
			select * into staging_table.table_prefix_process_id_table_postfix
				-- staging_table. should be replace by adiha_process.dbo.
				-- process_id should be replace by @process_id
		*/
		
		--DECLARE @alert_sql_id INT
		--DECLARE @process_id VARCHAR(500)
		--SET @process_id = 'asasdadasdjhsadhkdhajkhdkajhdjkashd'
		--SET @alert_sql_id = 6
		
	DECLARE @alert_type CHAR(1)
	DECLARE @new_process_id NVARCHAR(200)
	DECLARE @alert_tsql NVARCHAR(MAX)
	DECLARE @from_clause NVARCHAR(MAX)
	DECLARE @where_part  NVARCHAR(MAX)
	DECLARE @root_table NVARCHAR(200)
	DECLARE @primary_column NVARCHAR(200)
	DECLARE @process_table NVARCHAR(500)
	DECLARE @root_alias NVARCHAR(20)
	DECLARE @report_table NVARCHAR(500)
	DECLARE @new_process_table NVARCHAR(500) 	
	DECLARE @update_statement NVARCHAR(MAX)
	DECLARE @table_id INT
	DECLARE @table_alias NVARCHAR(50)
	DECLARE @sql_statement NVARCHAR(MAX)
	DECLARE @row_count INT
	DECLARE @table_name NVARCHAR(200)
	DECLARE @return_deal_ids NVARCHAR(MAX)
	DECLARE @sql_string NVARCHAR(MAX)
	DECLARE @param NVARCHAR(MAX)
	DECLARE @alert_name NVARCHAR(200)
	DECLARE @job_name NVARCHAR(300)
	DECLARE @user_login_id NVARCHAR(150)
	DECLARE @alert_actions_id INT
	DECLARE @triggered_flag INT = 0
	DECLARE @has_condition INT = 0
	DECLARE @is_eod_rule INT = 0
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @custom_eod_as_of_date DATE
	
	SELECT @alert_type = alert_type FROM alert_sql WHERE alert_sql_id = @alert_sql_id
	
	IF EXISTS(SELECT 1 FROM event_trigger et
					INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
					WHERE me.modules_id = 20619 AND et.event_trigger_id = @event_trigger_id AND me.event_id = 20561)
	BEGIN
		SET @is_eod_rule = 1
		SELECT @custom_eod_as_of_date = dbo.FNAResolveDynamicDate(NULLIF(me.eod_as_of_date,''))
		FROM event_trigger et
		INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
		WHERE me.modules_id = 20619 AND et.event_trigger_id = @event_trigger_id AND me.event_id = 20561
	END
			

		IF OBJECT_ID('tempdb..#alert_sql') IS NOT NULL
			DROP TABLE #alert_sql
		IF OBJECT_ID('tempdb..#alert_rule_table') IS NOT NULL
			DROP TABLE #alert_rule_table
		IF OBJECT_ID('tempdb..#alert_table_relation') IS NOT NULL
			DROP TABLE #alert_table_relation
		IF OBJECT_ID('tempdb..#alert_table_where_clause') IS NOT NULL
			DROP TABLE #alert_table_where_clause
		IF OBJECT_ID('tempdb..#alert_actions') IS NOT NULL
			DROP TABLE #alert_actions
		IF OBJECT_ID('tempdb..#alert_actions_events') IS NOT NULL
			DROP TABLE #alert_actions_events
		IF OBJECT_ID('tempdb..#alert_conditions') IS NOT NULL
			DROP TABLE #alert_conditions
			
		SELECT * INTO #alert_sql FROM alert_sql as1 WHERE as1.alert_sql_id = @alert_sql_id	
		SELECT * INTO #alert_rule_table FROM alert_rule_table WHERE alert_id = @alert_sql_id
		SELECT * INTO #alert_table_relation FROM alert_table_relation WHERE alert_id = @alert_sql_id
		SELECT * INTO #alert_table_where_clause FROM alert_table_where_clause WHERE alert_id = @alert_sql_id
		SELECT * INTO #alert_actions FROM alert_actions WHERE alert_id = @alert_sql_id
		SELECT * INTO #alert_actions_events FROM alert_actions_events WHERE alert_id = @alert_sql_id
		SELECT * INTO #alert_conditions FROM alert_conditions WHERE rules_id = @alert_sql_id
		
		SELECT @root_table = atd.physical_table_name,
			   @primary_column = ISNULL(atd.primary_column,acd.column_name),
			   @root_alias = art.table_alias
		FROM #alert_rule_table art
		INNER JOIN alert_table_definition atd ON  art.table_id = atd.alert_table_definition_id
		LEFT JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id AND acd.is_primary = 'y'
		WHERE  art.root_table_id IS NULL
		
		IF @root_table IS NULL AND @primary_column IS NULL
		BEGIN
			SELECT	@root_table = atd.physical_table_name,
					@primary_column = atd.primary_column,
					@root_alias = 'als' 
			FROM event_trigger et
			INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
			INNER JOIN workflow_module_rule_table_mapping wmr ON wmr.module_id = me.modules_id
			INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = wmr.rule_table_id
			WHERE et.event_trigger_id = @event_trigger_id AND atd.is_action_view = 'y' AND ISNULL(wmr.is_active,0) = 1
		END
		
		IF ISNULL(@root_alias,'') = ''
			SET @root_alias = 'als'
		
	DECLARE @is_disable CHAR(1)
	SELECT  @is_disable = is_disable FROM event_trigger WHERE event_trigger_id = @event_trigger_id

	IF ISNULL(@is_disable, 'n') = 'y'
	BEGIN
		DECLARE @dis_alert_id INT,
				@dis_trigger_id INT
		
		SELECT @alert_tsql = sql_statement
		FROM alert_sql asl
		INNER JOIN event_trigger et ON et.alert_id = asl.alert_sql_id
		WHERE et.event_trigger_id = @event_trigger_id

		
		SELECT @dis_alert_id = et1.alert_id, @dis_trigger_id = et1.event_trigger_id 
			FROM event_trigger et
		INNER JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
		INNER JOIN workflow_event_action wea ON wem.event_message_id = wea.event_message_id
		LEFT JOIN event_trigger et1 ON wea.alert_id = et1.event_trigger_id
		WHERE et.event_trigger_id = @event_trigger_id AND wea.status_id = CASE WHEN @is_eod_rule = 1 THEN 735 ELSE ISNULL(@control_status,729) END

		IF @is_eod_rule = 1 AND @dis_alert_id IS NULL
		BEGIN
			SELECT	@dis_alert_id = et.alert_id, 
					@dis_trigger_id = et.event_trigger_id  
			FROM workflow_schedule_task wst
			INNER JOIN workflow_schedule_task wst_n ON wst.parent = wst_n.parent AND wst.sort_order + 1 = wst_n.sort_order
			INNER JOIN event_trigger et ON wst_n.workflow_id = et.event_trigger_id
			WHERE wst.workflow_id = @event_trigger_id AND wst.workflow_id_type = 2
		END

		IF @dis_alert_id IS NOT NULL AND @dis_trigger_id IS NOT NULL
		BEGIN
			EXEC spa_run_alert_sql @dis_alert_id, NULL, @input_table_name, NULL, NULL, @dis_trigger_id, @msg_process_table, @workflow_process_id, NULL, @workflow_group_id, @control_status 
		END					
		RETURN
	END

	
	IF @alert_type = 's' OR @is_eod_rule = 1
	BEGIN
		SELECT @alert_tsql = as1.sql_statement
		FROM   alert_sql as1
		WHERE  as1.alert_sql_id = @alert_sql_id
		--WHILE CHARINDEX('  ', @alert_tsql) > 0 
		
		IF @is_eod_rule = 1 AND NULLIF(@alert_tsql,'') IS NULL
		BEGIN
			SET @alert_tsql = '@_CALCULATE_EOD_STATUS
								@_CALCULATE_EOD_STATUS_END'
		END

		SET @alert_tsql = REPLACE(@alert_tsql, '  ', ' ')

		--SET @alert_tsql = dbo. REPLACE(REPLACE(REPLACE(@alert_tsql, ' ', '<>'), '><', ''), '<>', ' ')
		SET @alert_tsql = REPLACE(@alert_tsql, 'staging_table.', 'adiha_process.dbo.')
		IF (CHARINDEX('new_process_id', @alert_tsql) <> 0)
		BEGIN
			SET @new_process_id = dbo.FNAGetNewID()
			SET @alert_tsql = REPLACE(@alert_tsql, 'new_process_id', @new_process_id)
		END

		IF @workflow_process_id IS NULL
			SET @workflow_process_id = dbo.FNAGetNewID()

		DECLARE @pre_eod_status NVARCHAR(MAX)  = '	
			IF OBJECT_ID(''tempdb..#tmp_spa_result'') IS NOT NULL DROP TABLE #tmp_spa_result
			CREATE TABLE #tmp_spa_result (
				ErrorCode NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
				Module NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
				Area NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
				Status NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
				Message NVARCHAR(1000) COLLATE DATABASE_DEFAULT ,
				Recommendation NVARCHAR(200) COLLATE DATABASE_DEFAULT 
			)
			INSERT INTO #tmp_spa_result (ErrorCode, Module, Area, Status, Message, Recommendation) '

			DECLARE @eod_parameters NVARCHAR(MAX) = '',
					@report_filters INT,
					@report_paramset_id INT,
					@component_id INT,
					@criteria NVARCHAR(MAX)

			SELECT	@report_filters = et.report_filters,
					@report_paramset_id = rp.report_paramset_id 
			FROM event_trigger AS et
			INNER JOIN report_paramset AS rp ON rp.paramset_hash = et.report_paramset_id 
			WHERE et.event_trigger_id = @event_trigger_id
				
			IF ISNULL(NULLIF(@report_paramset_id,0),'') <> ''
			BEGIN
				DECLARE @ed_process_id NVARCHAR(200) = dbo.FNAGetNewID()
				DECLARE @ed_process_table  NVARCHAR(500) = 'adiha_process.dbo.alert_eod_result' + @ed_process_id + '_app'
				
				DECLARE @report_name NVARCHAR(200)
				DECLARE @tech_error_msg NVARCHAR(500)

				SELECT @report_name = rp.name, 
					   @component_id = report_page_tablix_id 
				FROM report_page_tablix rpt
				INNER JOIN report_paramset rp ON rpt.page_id = rp.page_id
				WHERE rp.report_paramset_id = @report_paramset_id

				IF @eod_as_of_date IS NULL
				BEGIN
					SELECT @eod_as_of_date = coalesce(MIN(as_of_date), @custom_eod_as_of_date, GETDATE()) FROM eod_process_status 
					WHERE master_process_id = @workflow_process_id

					--IF ISNULL(@eod_as_of_date,'') IS NULL
					--	SET @eod_as_of_date = COALESCE(@custom_eod_as_of_date,GETDATE())
				END

				SELECT @criteria =
				STUFF((Select ',' + dsc.name + '=' + CASE WHEN dsc.name = 'as_of_date' THEN CONVERT(NVARCHAR(10),@eod_as_of_date,120)  WHEN dsc.name = 'process_id' THEN @process_id ELSE CAST(REPLACE(ISNULL(NULLIF(aufd.field_value,''),'NULL'),',','!') AS NVARCHAR(MAX)) END
				FROM application_ui_filter_details aufd
				LEFT JOIN data_source_column dsc ON aufd.report_column_id = data_source_column_id
				WHERE application_ui_filter_id = @report_filters AND report_column_id > 0
				FOR XML PATH('')),1,1,'') 
				
				SET @eod_parameters = 'EXEC spa_rfx_run_sql @paramset_id = ' + CAST(@report_paramset_id AS NVARCHAR) + ',@component_id = ' + CAST(@component_id AS NVARCHAR) + ', @criteria = ''' + @criteria + ''', @temp_table_name=NULL,@display_type=''t'',@runtime_user=''' + dbo.FNADBUser() + ''', @is_html = ''y'' , @is_refresh=0 , @batch_process_id=NULL, @eod_call_table=''' + @ed_process_table + ''''
				EXEC(@eod_parameters) 

				SET @tech_error_msg = 'EOD Process stopped for run date ' + CONVERT(NVARCHAR(10),@eod_as_of_date,120) + ' .Manually Start The Jobs at Error Step: ' + @report_name
				SET @eod_parameters = '
					IF OBJECT_ID(N''' + @ed_process_table + ''', N''U'') IS  NULL
					BEGIN
						INSERT INTO eod_process_status (master_process__id, process__id, source, status, message,as_of_date)
						SELECT ''@_workflow_process'', ''process_id'', ''EOD'', ''Technical Error'', ''' + @tech_error_msg + ''',''' + CONVERT(NVARCHAR(10),@eod_as_of_date,120) + '''

						CREATE TABLE ' + @ed_process_table + ' (
							ErrorCode NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
							Module NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
							Area NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
							Status NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
							Message NVARCHAR(1000) COLLATE DATABASE_DEFAULT ,
							Recommendation NVARCHAR(200) COLLATE DATABASE_DEFAULT 
						)
					END
					ELSE IF NOT EXISTS(SELECT 1 FROM ' + @ed_process_table + ')
					BEGIN
						INSERT INTO eod_process_status (master_process__id, process__id, source, status, message,as_of_date)
						SELECT ''@_workflow_process'', ''process_id'', ''EOD'', ''Technical Error'', ''' + @tech_error_msg + ''',''' + CONVERT(NVARCHAR(10),@eod_as_of_date,120) + ''' 
					END  

					'
				SET @alert_tsql = @eod_parameters + @alert_tsql
				--EXEC(@alert_tsql)
			END
		
			DECLARE @post_eod_status NVARCHAR(MAX) = ' SELECT * FROM ' + @ed_process_table + '	 
			IF EXISTS (SELECT 1 FROM #tmp_spa_result WHERE Status = ''Technical Error'')
			BEGIN
				INSERT INTO eod_process_status (master_process__id, process__id,status,message,as_of_date,source)
				SELECT TOP(1) ''@_workflow_process'',''process_id'', tmp.Status, tmp.Message,''' + CONVERT(NVARCHAR(10),@eod_as_of_date,120) + ''',''EOD''
				FROM #tmp_spa_result tmp WHERE status = ''Technical Error''
			END									
			ELSE 
			BEGIN
				INSERT INTO eod_process_status (master_process__id, process__id,status,message,as_of_date,source)
				SELECT TOP(1) ''@_workflow_process'',''process_id'', tmp.Status, tmp.Message,''' + CONVERT(NVARCHAR(10),@eod_as_of_date,120) + ''',''EOD''
				FROM #tmp_spa_result tmp WHERE status = ''Success''
			END '
		
		SET @alert_tsql = @alert_tsql + ' EXEC spa_insert_alert_output_status var_alert_sql_id, ''process_id'', NULL, NULL, NULL' 

		
		SET @alert_tsql = REPLACE(@alert_tsql,'@_CALCULATE_EOD_STATUS_END', ISNULL(@post_eod_status,''))
		SET @alert_tsql = REPLACE(@alert_tsql,'@_CALCULATE_EOD_STATUS', ISNULL(@pre_eod_status,''))
		SET @alert_tsql = REPLACE(@alert_tsql, 'batch_process_id', 'batch_process__id')
		SET @alert_tsql = REPLACE(@alert_tsql, 'process_id', @process_id)
		SET @alert_tsql = REPLACE(@alert_tsql, '@_workflow_process', @workflow_process_id)
		DECLARE @as_of_date DATE = GETDATE()
		
		IF @is_eod_rule = 1
		BEGIN
			SELECT @as_of_date = coalesce(MIN(as_of_date), @eod_as_of_date, GETDATE()) FROM eod_process_status 
			WHERE master_process_id = @workflow_process_id

			IF NULLIF(@as_of_date,'') IS NULL
				SET @as_of_date = ISNULL(@eod_as_of_date, GETDATE())
		END

		SET @alert_tsql = REPLACE(@alert_tsql, '@_as_of_date', @as_of_date)
		SET @alert_tsql = REPLACE(@alert_tsql, '@_user_login_id', dbo.FNADBUser())
		SET @alert_tsql = REPLACE(@alert_tsql, 'var_alert_sql_id', @alert_sql_id)
		SET @alert_tsql = REPLACE(@alert_tsql, 'process__id', 'process_id')
		SET @alert_tsql = REPLACE(@alert_tsql, '@_message_process_table', ISNULL(@msg_process_table,''))
		
		IF @input_table_name IS NOT NULL
		BEGIN
			SET @alert_tsql = REPLACE(@alert_tsql, '@_input_table', @input_table_name)
			EXEC('IF COL_LENGTH(''' + @input_table_name + ''',''primary_temp_id'') IS NULL BEGIN ALTER TABLE ' + @input_table_name + ' ADD primary_temp_id INT NOT NULL DEFAULT 1 END')
		END
		EXEC(@alert_tsql)
		--PRINT(@alert_tsql)
		
		IF @is_eod_rule = 1
		BEGIN
			DECLARE @message_board_msg NVARCHAR(500)
			SELECT DISTINCT TOP(1) @message_board_msg = description FROM message_board WHERE process_id = @process_id AND source <> 'Workflow Notification'

			IF @message_board_msg IS NOT NULL
			BEGIN
				UPDATE eod_process_status
				SET message = REPLACE(@message_board_msg,'''','''''')
				WHERE process_id = @process_id

				DELETE FROM message_board WHERE process_id = @process_id AND source <> 'Workflow Notification'
			END

			SET @new_process_id = ISNULL(@new_process_id, @process_id)  
			SET @sql = 'spa_process_outstanding_alerts'''+@new_process_id+''','+ CAST(@alert_sql_id AS NVARCHAR)+',NULL,NULL,NULL,NULL, '+CAST(@event_trigger_id AS NVARCHAR)+',NULL,'''+ ISNULL(@workflow_process_id,'')+''','''+ ISNULL(@eod_message,'')+''','''+ CAST(@workflow_group_id AS NVARCHAR)+''','''+ISNULL(@run_only_individual_step,'n')+''''
			
			SET @job_name = 'spa_process_outstanding_alerts_EOD_' + CAST(ISNULL(@event_trigger_id,'') AS NVARCHAR) + '_' + @workflow_process_id + '_' + CAST(CAST(RAND()*100 AS INT) AS NVARCHAR)

			EXEC spa_run_sp_as_job @job_name, @sql, 'spa_process_outstanding_alerts_EOD', @user_login_id

			IF EXISTS (SELECT 1 FROM eod_process_status WHERE process_id = @process_id AND [status] = 'Technical Error')
			BEGIN
				DECLARE @err_alert_process_table NVARCHAR(200)--,@err_process_id NVARCHAR(200)
				--SET @err_process_id = dbo.FNAGetNewID()
				SET @err_alert_process_table = 'adiha_process.dbo.alert_eod_error_' + @process_id +  '_aee'
				EXEC('CREATE TABLE ' + @err_alert_process_table + ' (primary_temp_id INT) INSERT INTO ' + @err_alert_process_table + '(primary_temp_id) SELECT 1')

				--INSERT INTO eod_process_status(master_process_id, process_id,status,message,as_of_date,source)
				--SELECT master_process_id, @err_process_id,status,message,as_of_date,source FROM eod_process_status WHERE process_id = @process_id 

				EXEC spa_register_event 20619, 20566, @err_alert_process_table, 1, @process_id
			END
		END
		ELSE 
		BEGIN
			SET @new_process_id = ISNULL(@new_process_id, @process_id)  
			EXEC spa_process_outstanding_alerts @new_process_id, @alert_sql_id, @input_table_name,  @root_table, @primary_column, NULL,@event_trigger_id, @msg_process_table, @workflow_process_id,NULL, @workflow_group_id, @run_only_individual_step
		END
	
	END
	ELSE IF @alert_type = 'r'
	BEGIN
			
		DECLARE @data_source_view_sql NVARCHAR(MAX)
		DECLARE @data_source_result_table NVARCHAR(MAX) = 'adiha_process.dbo.alert_data_source_' + dbo.FNAGetNewID() + '_result'

		SELECT	@data_source_view_sql = REPLACE(ds.tsql,'--[__batch_report__]', 'INTO ' + @data_source_result_table)
		FROM #alert_rule_table art
		INNER JOIN alert_table_definition atd ON art.table_id = atd.alert_table_definition_id
		LEFT JOIN data_source ds ON ds.data_source_id = atd.data_source_id
		WHERE art.root_table_id IS NULL

		SET @data_source_view_sql = REPLACE(@data_source_view_sql,'--[__alert_process_table__]', ' INNER JOIN ' + @input_table_name)

		IF @data_source_view_sql IS NOT NULL
			EXEC(@data_source_view_sql)

		;WITH cte_alert AS (
			SELECT art.alert_rule_table_id,
				   art.alert_id,
				   ISNULL(@data_source_result_table,atd.physical_table_name) [physical_table_name],
				   art.table_alias
			FROM #alert_rule_table art
			INNER JOIN alert_table_definition atd ON art.table_id = atd.alert_table_definition_id
			WHERE art.root_table_id IS NULL
		)
		,cte_relation (data_source, source_id, [alias], from_alias, from_column_id, to_alias, to_column_id, relationship_level) 
		AS 
		( 
		SELECT alert_rule_table_id, alert_rule_table_id source_id, table_alias [alias], table_alias [from_alias], CAST(NULL AS NVARCHAR(200)) from_column, CAST(NULL AS NVARCHAR(200)) to_alias, CAST(NULL AS NVARCHAR(200)) to_column, 0 relationship_level  FROM cte_alert
		UNION ALL
		--connected dataset
		SELECT 
		atr.from_table_id, art_main.alert_rule_table_id, art_main.table_alias, art_from.table_alias from_alias, CAST(atr.from_column_id AS NVARCHAR(200)) from_column_id, CAST(cdr.from_alias as NVARCHAR(200)) to_alias, CAST(atr.to_column_id AS NVARCHAR(200)) to_column_id, (cdr.relationship_level + 1) relationship_level
		FROM cte_relation cdr
		INNER JOIN #alert_table_relation atr ON atr.to_table_id = cdr.data_source
		INNER JOIN #alert_rule_table art_from ON atr.from_table_id = art_from.alert_rule_table_id
		INNER JOIN #alert_rule_table art_main ON atr.from_table_id = art_main.alert_rule_table_id
		)
	
		SELECT @from_clause =
		STUFF(
		(
			SELECT CHAR(10) + (CASE WHEN MAX(relationship_level) = 0 THEN ' FROM ' ELSE ' LEFT JOIN ' END) 
				+ ' ' + MAX(cte.[table_name]) + ' ' + QUOTENAME(MAX(cte.[alias]))			--datasource [alias]
				+ ISNULL(' ON ' + MAX(join_cols), '') 		--join keys
			FROM
			(
				SELECT data_source, source_id, ISNULL('(' + ds.tsql + ')',atd.physical_table_name) [table_name], cdr.[alias], from_alias, from_column_id, to_alias, to_column_id, MAX(relationship_level) relationship_level
				FROM cte_relation cdr
				INNER JOIN #alert_rule_table art ON cdr.data_source = art.alert_rule_table_id 
				INNER JOIN alert_table_definition atd ON art.table_id = atd.alert_table_definition_id
				LEFT JOIN data_source ds ON ds.data_source_id = atd.data_source_id
				GROUP BY data_source, source_id, ISNULL('(' + ds.tsql + ')',atd.physical_table_name), cdr.[alias], from_alias, from_column_id, to_alias, to_column_id
			) cte
			INNER JOIN #alert_rule_table art ON art.alert_rule_table_id = cte.source_id
			OUTER APPLY (
				 SELECT
				   STUFF(
					(  
					   SELECT DISTINCT ' AND ISNULL(CAST(' + CAST((from_alias + '.' + QUOTENAME(acd_from.column_name) + ' AS NVARCHAR(100)), '''') = ISNULL(CAST(' + to_alias +  '.' + QUOTENAME(acd_to.column_name)) AS NVARCHAR(MAX)) + ' AS NVARCHAR(100)), '''')'
					   FROM cte_relation cdr_inner
					   INNER JOIN alert_columns_definition acd_from ON cdr_inner.from_column_id = acd_from.alert_columns_definition_id
					   INNER JOIN alert_columns_definition acd_to ON cdr_inner.to_column_id = acd_to.alert_columns_definition_id					   
					   WHERE cdr_inner.data_source = cte.data_source
					   FOR XML PATH(''), TYPE
				   ).value('.[1]', 'NVARCHAR(MAX)'), 1, 5, '') join_cols
			) join_key_set
			GROUP BY data_source
			ORDER BY MAX(relationship_level)
			FOR XML PATH(''), TYPE
		).value('.[1]', 'NVARCHAR(MAX)'), 1, 1, '')	
		

		IF @input_table_name IS NOT NULL AND @primary_column IS NOT NULL
		BEGIN
			SET @process_table = @input_table_name
			SET @from_clause += ' INNER JOIN ' + @input_table_name + ' p ON p.' + @primary_column + ' = ' + @root_alias + '.' + @primary_column
		END
		
		DECLARE @condition_id INT
		--TODO: CURSOR for condition
		DECLARE condition_cursor CURSOR LOCAL FOR
		SELECT DISTINCT a.alert_conditions_id 
		FROM #alert_conditions a			
		
		OPEN condition_cursor
		FETCH NEXT FROM condition_cursor
		INTO @condition_id
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			SET @new_process_id = dbo.FNAGetNewID()	
			SELECT @new_process_table = CASE @root_table
											  WHEN 'contract_group' THEN 'adiha_process.dbo.alert_contract_' + @new_process_id + '_ac'
											  WHEN 'source_counterparty' THEN 'adiha_process.dbo.alert_counterparty_' + @new_process_id + '_ac'
											  WHEN 'vwSourceDealHeader' THEN 'adiha_process.dbo.alert_deal_' + @new_process_id + '_ad'
											  WHEN 'Calc_invoice_Volume_variance' THEN 'adiha_process.dbo.alert_invoice_' + @new_process_id + '_ai'
											  WHEN 'confirm_status' THEN 'adiha_process.dbo.alert_confirm_status_' + @new_process_id + '_ac'
											  ELSE 'adiha_process.dbo.alert_new_process_table_' + @new_process_id + '_ac'
			                            END
			                            	
			IF OBJECT_ID(@process_table) IS NOT NULL
			BEGIN
				SET @sql = 'SELECT * INTO ' + @new_process_table  + ' FROM ' + @process_table
				
				IF @source_column IS NOT NULL AND @source_id IS NOT NULL
				BEGIN
					SET @sql = @sql + ' WHERE ' + @source_column + ' = ' + CAST(@source_id AS NVARCHAR(20))
				END
				
				exec spa_print @sql	
				EXEC(@sql)
				SET @process_table = @new_process_table
			END
			
			SET @process_id = @new_process_id						
			
			/*
			SET @where_part = NULL
			SELECT @where_part = COALESCE(@where_part + ' ' , '') 
								+ CASE 
									WHEN atwc.clause_type = 1 THEN ' AND '
									ELSE ' OR '
								  END 
								  + ISNULL(NULLIF(atwc.column_function, ''), QUOTENAME(art.table_alias) + '.' + acd.column_name) + ' ' + rpo.sql_code + ' ' + CASE WHEN atwc.operator_id IN (6,7) THEN '' ELSE CASE WHEN ISNUMERIC(atwc.column_value) = 1 THEN atwc.column_value ELSE '''' + atwc.column_value + '''' END + ' ' + CASE WHEN atwc.operator_id = 8 THEN ' AND ' + CASE WHEN ISNUMERIC(atwc.column_value) = 1 THEN atwc.second_value ELSE '''' + atwc.second_value + '''' END ELSE '' END END
			FROM #alert_table_where_clause atwc
			INNER JOIN #alert_rule_table art ON art.alert_rule_table_id = atwc.table_id
			INNER JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = atwc.column_id
			INNER JOIN report_param_operator rpo ON rpo.report_param_operator_id = atwc.operator_id
			WHERE atwc.condition_id = @condition_id
			*/
			
			SET @where_part = ''
			DECLARE @total_count INT, @count INT = 1, @or_flag INT = 0
			SELECT @total_count = COUNT(1) FROM alert_table_where_clause WHERE condition_id = @condition_id

			IF @total_count > 0
				SET @where_part += ' AND (( '

			DECLARE @w_clause_type INT, @w_table_alias NVARCHAR(10), @w_column_name NVARCHAR(50), @w_sql_code NVARCHAR(20), @w_column_value NVARCHAR(100), @operator_id INT, @second_value NVARCHAR(100)
			DECLARE where_clause_cursor CURSOR FOR  
			SELECT	clause_type,
					art.table_alias,
					ISNULL(ds.[name],acd.column_name), 
					rpo.sql_code, 
					column_value,
					rpo.report_param_operator_id,
					second_value
			FROM #alert_table_where_clause atwc
			INNER JOIN #alert_rule_table art ON atwc.table_id = art.alert_rule_table_id
			LEFT JOIN report_param_operator rpo ON rpo.report_param_operator_id = atwc.operator_id
			LEFT JOIN data_source_column ds ON ds.data_source_column_id = atwc.data_source_column_id
			LEFT JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = atwc.column_id
			WHERE condition_id = @condition_id ORDER BY sequence_no

			OPEN where_clause_cursor   
			FETCH NEXT FROM where_clause_cursor INTO @w_clause_type,@w_table_alias,@w_column_name,@w_sql_code,@w_column_value,@operator_id,@second_value

			WHILE @@FETCH_STATUS = 0   
			BEGIN   
				IF @count <> 1 AND @or_flag = 0 AND @w_clause_type = 1
					SET @where_part += ' AND '

				IF @count <> 1 AND @or_flag = 0 AND @w_clause_type = 2
					SET @where_part += ' OR '
	
				IF @w_clause_type = 4 AND @count <> @total_count
				BEGIN
					SET @where_part += ' ) OR ( ' 
					SET @or_flag = 1
				END

				IF @w_clause_type = 3 AND @count <> @total_count
				BEGIN
					SET @where_part += ' ) AND ( ' 
					SET @or_flag = 1
				END

				--SELECT CASE WHEN @operator_id = 8 THEN ' AND ' + CASE WHEN ISNUMERIC(@second_value) = 1 THEN ISNULL(@second_value,'') ELSE '''' + ISNULL(@second_value,'') + ''''  END END

				IF @w_clause_type = 1 OR @w_clause_type = 2
				BEGIN
					SET @where_part += 
									CASE WHEN @operator_id IN (14,15,16,17,18,19) THEN CASE WHEN ISNULL(@second_value,1) = 1 THEN 'CAST(CONVERT(date,DATEADD(dd,CAST(' + @w_column_value + ' AS INT),''' + CAST(CONVERT(date, GETDATE()) AS NVARCHAR) + ''')) AS NVARCHAR) ' 
									ELSE '[dbo].[FNAGetBusinessDayN](''n'',''' + CAST(CONVERT(date, GETDATE()) AS NVARCHAR) + ''',null,CAST(''' + @w_column_value + ''' AS INT))' END
									ELSE QUOTENAME(@w_table_alias) + '.' + QUOTENAME(@w_column_name) END 
									+  ' ' + @w_sql_code + ' ' + 
									CASE 
										WHEN @operator_id IN (6,7) THEN '' 
										WHEN @operator_id IN (14,15,16,17,18,19) THEN QUOTENAME(@w_table_alias) + '.' + QUOTENAME(@w_column_name) 
										ELSE
											CASE WHEN ISNUMERIC(@w_column_value) = 1 THEN @w_column_value ELSE '''' + @w_column_value + ''''  END
									END 
									+
									CASE WHEN @operator_id = 8 THEN ' AND ' + CASE WHEN ISNUMERIC(@second_value) = 1 THEN ISNULL(@second_value,'') ELSE '''' + ISNULL(@second_value,'') + ''''  END ELSE '' END
					SET @or_flag = 0
				END
				 
				IF @count = @total_count
					SET @where_part = @where_part + ' )) '

				SET @has_condition = 1
				
				SET @count = @count + 1
				FETCH NEXT FROM where_clause_cursor INTO @w_clause_type,@w_table_alias,@w_column_name,@w_sql_code,@w_column_value,@operator_id,@second_value 
			END   
			CLOSE where_clause_cursor   
			DEALLOCATE where_clause_cursor
			
			
			DECLARE @output_table NVARCHAR(500),
				    @output_table_report NVARCHAR(500)				
			
			SET @output_table = 'adiha_process.dbo.nested_alert_' + @process_id + '_na'
			
			
			EXEC('IF OBJECT_ID(''adiha_process.dbo.workflow_table_' + @process_id + ''') IS NOT NULL
					DROP TABLE adiha_process.dbo.workflow_table_' + @process_id + '')
			EXEC('CREATE TABLE adiha_process.dbo.workflow_table_' + @process_id + ' (id INT, sql_id INT)')
			
			EXEC('IF OBJECT_ID(''adiha_process.dbo.nested_alert_' + @process_id + '_na'') IS NOT NULL
				DROP TABLE adiha_process.dbo.nested_alert_' + @process_id + '_na')
			
			SET @sql = 'SELECT DISTINCT ' + QUOTENAME(@root_alias) + '.*  INTO ' + @output_table + ' ' + @from_clause + ' WHERE 1 = 1 ' + @where_part
			
			IF @source_column IS NOT NULL AND @source_id IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND ' + QUOTENAME(@root_alias) + '.' + @source_column + ' = ' + CAST(@source_id AS NVARCHAR(20))
			END
			exec spa_print @sql	
			EXEC(@sql)
			
						
		
						
			IF EXISTS(SELECT 1 FROM #alert_actions WHERE condition_id = @condition_id)
			BEGIN
				SET @user_login_id = dbo.FNADBUser()
				SET @row_count = 0
								
				SELECT @sql_statement = sql_statement FROM #alert_actions WHERE condition_id = @condition_id
				
				--IF @sql_statement IS NULL
				--BEGIN
					DECLARE update_cursor CURSOR LOCAL FOR
					SELECT MIN(a.alert_actions_id), a.table_id, art.table_alias
					FROM #alert_actions a
					INNER JOIN alert_rule_table art ON art.alert_rule_table_id = a.table_id
					LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
					GROUP BY a.table_id, art.table_alias
					ORDER BY MIN(a.alert_actions_id)					
					
					OPEN update_cursor
					FETCH NEXT FROM update_cursor
					INTO @alert_actions_id, @table_id, @table_alias
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @update_statement = NULL
											
						SELECT @update_statement = COALESCE(@update_statement + ',', '') + ISNULL(ds.name,acd.column_name) + ' = ' + CASE WHEN ISNUMERIC(aa.column_value) = 1 THEN aa.column_value WHEN CHARINDEX('dbo.', aa.column_value) > 0 THEN aa.column_value ELSE '''' + REPLACE(aa.column_value, 'GETDATE()', GETDATE()) + '''' END
						FROM #alert_actions aa 
						LEFT JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = aa.column_id
						LEFT JOIN data_source_column ds ON ds.data_source_column_id = aa.data_source_column_id
						WHERE aa.table_id = @table_id AND aa.condition_id = @condition_id
						
						SET @sql_string = ' UPDATE ' + @table_alias + ' SET ' + @update_statement + @from_clause + ' WHERE 1 = 1 ' + @where_part
						EXEC sp_executesql @sql_string		
						SET @row_count = @@ROWCOUNT
						
						IF @row_count > 0
						BEGIN
							SET @sql_string = NULL
							SET @new_process_id = dbo.FNAGetNewID()
							SET @new_process_table = REPLACE(@process_table, @process_id, @new_process_id)
							
							EXEC('SELECT * INTO ' + @new_process_table  + ' FROM ' + @process_table)
							
							SELECT @sql_string = COALESCE(@sql_string + '  ', '') + 'EXEC spa_run_alert_sql ' + CAST(callback_alert_id AS NVARCHAR(10)) + ', ''' + @new_process_id + ''', ''' + @new_process_table + ''',NULL,NULL'
							FROM  alert_actions_events
							WHERE table_id = @table_id AND callback_alert_id IS NOT NULL 	
							
							EXEC sp_executesql @sql_string

							SELECT @table_name = atd.physical_table_name
							FROM alert_rule_table art
							INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
							WHERE art.alert_rule_table_id = @table_id

							IF @table_name IN ('source_deal_header', 'source_deal_detail', 'WF_deal')
							BEGIN
								SET @return_deal_ids = NULL
								SET @sql_string = 'SELECT @return_deal_ids =  COALESCE(@return_deal_ids + '','', '''') + CAST(source_deal_header_id AS NVARCHAR(20)) FROM ' + @process_table;  
								SET @param = '@return_deal_ids Nvarchar(MAX) OUTPUT';
								EXEC sp_executesql @sql_string, @param, @return_deal_ids = @return_deal_ids OUTPUT;
								
								IF @return_deal_ids IS NOT NULL
								BEGIN
									SELECT @alert_name = alert_sql_name FROM alert_sql WHERE alert_sql_id = @alert_sql_id
									SET @sql = 'spa_insert_update_audit ''u'',''' + CAST(@return_deal_ids AS NVARCHAR(MAX)) + '''' + ','' Updated by event rule: ' + ISNULL(@alert_name, '') + ''''
									SET @job_name = 'spa_insert_update_audit_' + @process_id
									EXEC spa_run_sp_as_job @job_name, @sql,'spa_insert_update_audit' ,@user_login_id
								END
							END
						END
						
						FETCH NEXT FROM update_cursor INTO @alert_actions_id, @table_id, @table_alias
					END
					CLOSE update_cursor
					DEALLOCATE update_cursor
				--END
				--ELSE
				IF @sql_statement IS NOT NULL
				BEGIN
					IF OBJECT_ID('tempdb..#alert_status') IS NOT NULL
						DROP TABLE #alert_status
					CREATE TABLE #alert_status (is_present INT)		
					
					IF OBJECT_ID(@output_table) IS NULL
						SET @output_table =  NULL

					SET @sql = 'INSERT INTO #alert_status (is_present)
								SELECT 1 ' + ISNULL(' FROM ' + @output_table, '')
					EXEC(@sql)
					IF EXISTS(SELECT 1 FROM #alert_status)
					BEGIN
						SET @sql_statement = REPLACE(@sql_statement, 'process_id', @process_id)
						SET @sql_statement = REPLACE(@sql_statement, '__input_table__', @input_table_name)
						SET @sql_statement = REPLACE(@sql_statement, '__primary_column', @primary_column)
						exec spa_print @sql_statement
						EXEC(@sql_statement)
					END
				END			
			END
			
			IF EXISTS (
				SELECT * FROM event_trigger et 
				INNER JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
				INNER JOIN alert_reports ar ON ar.event_message_id = wem.event_message_id AND ar.report_writer = 'a'
				WHERE et.event_trigger_id = @event_trigger_id
			)
			BEGIN
				/* For report*/
				SET @output_table_report = 'adiha_process.dbo.nested_alert_workflow_report_' + ISNULL(@new_process_id, @process_id) + '_na'
				SET @sql = 'SELECT DISTINCT ' + QUOTENAME(@root_alias) + '.*  INTO ' + @output_table_report + ' ' + @from_clause + ' WHERE 1 = 1 ' + @where_part
				IF @source_column IS NOT NULL AND @source_id IS NOT NULL
				BEGIN
					SET @sql = @sql + ' AND ' + QUOTENAME(@root_alias) + '.' + @source_column + ' = ' + CAST(@source_id AS NVARCHAR(20))
				END
			
				exec spa_print @sql	
				EXEC(@sql)
			END

			IF OBJECT_ID('tempdb..#alert_status2') IS NOT NULL
				DROP TABLE #alert_status2
			CREATE TABLE #alert_status2 (is_present INT)		
	
			IF OBJECT_ID(@output_table) IS NULL
				SET @output_table =  NULL

			SET @sql = 'INSERT INTO #alert_status2 (is_present)
						SELECT 1 ' + ISNULL(' FROM ' + @output_table, '')
			EXEC(@sql)
	
			IF EXISTS(SELECT 1 FROM #alert_status2)
			BEGIN
				SET @triggered_flag = 1
				SET @new_process_id = ISNULL(@new_process_id, @process_id)
				EXEC spa_insert_alert_output_status @alert_sql_id, @new_process_id, NULL, NULL, NULL
				
				EXEC spa_process_outstanding_alerts @new_process_id, @alert_sql_id, @process_table, @root_table, @primary_column, NULL, @event_trigger_id, @msg_process_table, @workflow_process_id, @eod_message, @workflow_group_id,@run_only_individual_step
			END	
			FETCH NEXT FROM condition_cursor INTO @condition_id
		END
		CLOSE condition_cursor
		DEALLOCATE condition_cursor		

		IF @triggered_flag = 0 AND @has_condition = 0
		BEGIN
			EXEC spa_insert_alert_output_status @alert_sql_id, @process_id, NULL, NULL, NULL
			SET @new_process_id = ISNULL(@new_process_id, @process_id)
				
			EXEC spa_process_outstanding_alerts @new_process_id, @alert_sql_id, @process_table, @root_table, @primary_column, NULL, @event_trigger_id, @msg_process_table, @workflow_process_id, @eod_message,@workflow_group_id,@run_only_individual_step
		END
	END	
END