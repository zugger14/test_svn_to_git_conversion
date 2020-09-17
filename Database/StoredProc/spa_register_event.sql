

IF OBJECT_ID(N'[dbo].[spa_register_event]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_register_event]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Triggers the Alerts and Workflow

	Parameters :
	@module_id : static_data_values - type_id = 20600
	@event_id : static_data_values - type_id = 20500
	@process_table : Process table that contains the data to be processed from workflow
	@is_batch : 0 - Dont execute in batch job, 1 - execute in batch job
	@process_id : Unique Identifier for Process
	@nxt_module_events_id : module_events_id Filter (module_events_id FROM module_events)
	@workflow_g_id : Workflow Group ID of the workflow
	@p_id : ID of the primary column, to create the process table if there isn't a process table.
	@execute_in_queue : NULL -> Execute as per from adiha_configuration
						1 -> Execute in Queue
						2 -> Execute in parallel
 */
 
CREATE PROCEDURE [dbo].[spa_register_event]
    @module_id INT,
    @event_id INT,
    @process_table NVARCHAR(200),
    @is_batch BIT = 0,
    @process_id NVARCHAR(200),
	@nxt_module_events_id INT = NULL,
	@workflow_g_id INT = NULL,
	@p_id INT = NULL,
	@execute_in_queue INT = NULL
AS
/*
declare @module_id INT = 20608,
    @event_id INT = 20523,
    @process_table NVARCHAR(200) = 'adiha_process.dbo.alert_nomination_9D0F66D0_A57E_4CF1_8A00_C5BBBEDCF914_an',
    @is_batch BIT = 0,
    @process_id NVARCHAR(200) = '9D0F66D0_A57E_4CF1_8A00_C5BBBEDCF914',
	@nxt_module_events_id INT = NULL,
	@workflow_g_id INT = NULL



--*/ 

IF @execute_in_queue IS NULL
BEGIN
	SET @execute_in_queue = 1
	SELECT @execute_in_queue = ISNULL(var_value,1) FROM adiha_default_codes adc
	INNER JOIN adiha_default_codes_values adcv ON adc.default_code_id = adcv.default_code_id
	WHERE adc.default_code_id = 204
END

-------------------------- Create Process table if ID only supplied.
IF @p_id IS NOT NULL 
BEGIN
	DECLARE @sql_stmt NVARCHAR(MAX)
	SET @process_id = dbo.FNAGetNewID()  
	SET @process_table = 'adiha_process.dbo.counterparty_credit_info_' + @process_id + '_ac'

		SET @sql_stmt = 'CREATE TABLE ' + @process_table + '
						 (
	                 		counterparty_credit_enhancement_id    INT
						 )
						INSERT INTO ' + @process_table + '(
							counterparty_credit_enhancement_id
						  )
						SELECT ' +  CAST(@p_id AS NVARCHAR(30))
 --print(@sql_stmt)
	EXEC(@sql_stmt)
END
--------------------------------------------------------------------------
DECLARE @user_login_id NVARCHAR(50)
DECLARE @sql NVARCHAR(MAX),
		@new_process_id NVARCHAR(200)

IF OBJECT_ID('tempdb..#tmp_condition_chk') IS NOT NULL
	DROP TABLE #tmp_condition_chk
CREATE TABLE #tmp_condition_chk (flag INT)

IF OBJECT_ID('tempdb..#module_event_where_clause') IS NOT NULL
	DROP TABLE #module_event_where_clause
CREATE TABLE #module_event_where_clause (module_events_id INT, condition_clause NVARCHAR(2000) COLLATE DATABASE_DEFAULT , condition_match INT, workflow_group_id INT, new_process_table NVARCHAR(4000) COLLATE DATABASE_DEFAULT)

DECLARE @table_name NVARCHAR(MAX)
DECLARE @primary_column NVARCHAR(100)
DECLARE @split_process_table NVARCHAR(500)
DECLARE @report_process_table NVARCHAR(500)

DECLARE @data_source_view_sql NVARCHAR(MAX)
DECLARE @data_source_result_table NVARCHAR(MAX) = 'adiha_process.dbo.alert_data_source_' + dbo.FNAGetNewID() + '_result'

SELECT	@data_source_view_sql = REPLACE(ds.tsql,'--[__batch_report__]', 'INTO ' + @data_source_result_table)
FROM module_events me
LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = me.rule_table_id
OUTER APPLY (
	SELECT MAX(atd.data_source_id) [data_source_id] 
	FROM alert_table_definition atd
	INNER JOIN workflow_module_rule_table_mapping wmr ON atd.alert_table_definition_id = wmr.rule_table_id
	WHERE module_id = @module_id AND atd.is_action_view = 'y' AND ISNULL(wmr.is_active,0) = 1
) atd_d
LEFT JOIN data_source ds ON ds.data_source_id = ISNULL(atd.data_source_id,atd_d.data_source_id)
WHERE me.modules_id = @module_id

IF @data_source_view_sql IS NOT NULL
BEGIN
	SET @data_source_view_sql = REPLACE(@data_source_view_sql,'--[__alert_process_table__]', ' INNER JOIN ' + @process_table)
	EXEC(@data_source_view_sql)
END
ELSE 
	SET @data_source_result_table = NULL

SELECT	@table_name = ISNULL(@data_source_result_table,atd.physical_table_name),
		@primary_column = COALESCE(atd_dd.primary_column,atd.primary_column,  clm.[primary_column])
FROM module_events me
LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = me.rule_table_id
OUTER APPLY (
	SELECT MAX(atd.alert_table_definition_id) [alert_table_definition_id] 
	FROM alert_table_definition atd
	INNER JOIN workflow_module_rule_table_mapping wmr ON atd.alert_table_definition_id = wmr.rule_table_id
	WHERE module_id = @module_id AND atd.is_action_view = 'y'  AND ISNULL(wmr.is_active,0) = 1
) atd_d
LEFT JOIN alert_table_definition atd_dd ON atd_dd.alert_table_definition_id = atd_d.alert_table_definition_id
OUTER APPLY (SELECT acd.column_name [primary_column] FROM alert_columns_definition acd WHERE acd.alert_table_id = atd.alert_table_definition_id AND is_primary = 'y') clm
WHERE me.modules_id = @module_id

DECLARE @select_part NVARCHAR(1000) = 'SELECT 1  FROM ' + @table_name + ' a '
IF @process_table IS NOT NULL
BEGIN
	SET @select_part += ' INNER JOIN ' + @process_table + ' p ON a.' + @primary_column + ' = p.' + @primary_column + ' WHERE 1=1 '  
END

DECLARE @where_part NVARCHAR(1000) = ''
DECLARE @w_clause_type INT, @w_table_alias NVARCHAR(10), @w_column_name NVARCHAR(50), @w_sql_code NVARCHAR(20), @w_column_value NVARCHAR(100), @operator_id INT, @second_value NVARCHAR(200), @module_events_id INT, @workflow_task_id INT, @workflow_group_id INT


DECLARE module_events_cursor CURSOR FOR
SELECT me.module_events_id, wst.id, par.id FROM module_events me
INNER JOIN workflow_schedule_task wst ON me.module_events_id = wst.workflow_id AND wst.workflow_id_type = 1
LEFT JOIN workflow_schedule_task par ON par.id = wst.parent
OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
WHERE me.modules_id = @module_id AND evt.event_id = @event_id AND ISNULL(par.system_defined,0) <> 2 AND ISNULL(me.is_active, 'y') = 'y'

OPEN module_events_cursor   
FETCH NEXT FROM module_events_cursor INTO @module_events_id, @workflow_task_id, @workflow_group_id

WHILE @@FETCH_STATUS = 0   
BEGIN  
	DECLARE @total_count INT, @count INT = 1, @or_flag INT = 0
	SELECT @total_count = COUNT(1) FROM module_events me
	INNER JOIN workflow_schedule_task wst ON me.module_events_id = wst.workflow_id AND wst.workflow_id_type = 1
	INNER JOIN workflow_where_clause wwc ON wwc.workflow_schedule_task_id = wst.id
	WHERE wst.id = @workflow_task_id

	SELECT @total_count +=  COUNT(1) FROM workflow_where_clause wwc
	INNER JOIN module_events me ON wwc.module_events_id = me.module_events_id
	WHERE me.module_events_id = @module_events_id

	IF @total_count > 0
		SET @where_part = ' AND (( '
	ELSE
		SET @where_part = ''

	DECLARE where_clause_cursor CURSOR FOR  
	SELECT  a.clause_type,
			a.alias,
			a.column_name, 
			a.sql_code, 
			a.column_value,
			a.report_param_operator_id,
			a.second_value 
	FROM (
		SELECT	clause_type,
				'a' [alias],
				ISNULL(dsc.name,acd.column_name) [column_name], 
				rpo.sql_code, 
				column_value,
				rpo.report_param_operator_id,
				second_value,
				sequence_no
		FROM module_events me
		LEFT JOIN workflow_schedule_task wst ON me.module_events_id = wst.workflow_id AND wst.workflow_id_type = 1
		LEFT JOIN workflow_where_clause wwc ON wwc.workflow_schedule_task_id = wst.id
		LEFT JOIN report_param_operator rpo ON rpo.report_param_operator_id = wwc.operator_id
		LEFT JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = wwc.column_id
		LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = wwc.data_source_column_id
		WHERE wst.id = @workflow_task_id
		UNION ALL
		SELECT	clause_type,
				'a' [alias],
				ISNULL(dsc.name,acd.column_name) [column_name],
				rpo.sql_code, 
				column_value,
				rpo.report_param_operator_id,
				second_value,
				sequence_no
		FROM workflow_where_clause wwc
		INNER JOIN module_events me ON wwc.module_events_id = me.module_events_id
		LEFT JOIN report_param_operator rpo ON rpo.report_param_operator_id = wwc.operator_id
		LEFT JOIN alert_columns_definition acd ON acd.alert_columns_definition_id = wwc.column_id
		LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = wwc.data_source_column_id
		WHERE me.module_events_id = @module_events_id
	) a
	WHERE a.clause_type IS NOT NULL
	ORDER BY a.sequence_no


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

		IF @w_clause_type = 1 OR @w_clause_type = 2
		BEGIN
			SET @where_part += 
							CASE WHEN @operator_id IN (14,15,16,17,18,19) THEN 'CAST(CONVERT(date,DATEADD(dd,CAST(' + @w_column_value + ' AS INT),' + @w_table_alias + '.' + @w_column_name + ')) AS NVARCHAR) ' 
							ELSE @w_table_alias + '.' + @w_column_name END 
							+  ' ' + @w_sql_code + ' ' + 
							CASE 
								WHEN @operator_id IN (6,7) THEN '' 
								WHEN @operator_id IN (14,15,16,17,18,19) THEN '''' + CAST(CONVERT(date, GETDATE()) AS NVARCHAR) + ''''
								ELSE
									CASE WHEN ISNUMERIC(@w_column_value) = 1 THEN @w_column_value ELSE '''' + @w_column_value + ''''  END
							END 
							+
							CASE WHEN @operator_id = 8 THEN ' AND ' + CASE WHEN ISNUMERIC(@second_value) = 1 THEN ISNULL(@second_value,'') ELSE '''' + ISNULL(@second_value,'') + ''''  END ELSE '' END
			SET @or_flag = 0
		END
		IF @count = @total_count
			SET @where_part += ' )) '

		SET @count = @count + 1
		FETCH NEXT FROM where_clause_cursor INTO @w_clause_type,@w_table_alias,@w_column_name,@w_sql_code,@w_column_value,@operator_id,@second_value 
	END   
	CLOSE where_clause_cursor   
	DEALLOCATE where_clause_cursor
	
	DELETE FROM #tmp_condition_chk
	IF (@select_part IS NOT NULL AND @select_part <> '')
	BEGIN
		INSERT INTO #tmp_condition_chk(flag)
		EXEC(@select_part + @where_part)

		IF((SELECT COUNT(1) FROM #tmp_condition_chk) = 0)
		BEGIN
			INSERT INTO #module_event_where_clause
			SELECT @module_events_id, @select_part + @where_part, 0, @workflow_group_id, ''
		END
		ELSE
		BEGIN

			SET @new_process_id = dbo.FNAGetNewID()

			SET @split_process_table = 'adiha_process.dbo.alert_re_' + @new_process_id + '_app'
			
			SET @sql = REPLACE(@select_part,'SELECT 1', 'SELECT DISTINCT p.* INTO ' + @split_process_table) + @where_part
			EXEC(@sql)
			
			IF @split_process_table IS NOT NULL
			BEGIN
				SET @sql = 'IF COL_LENGTH(''' + @split_process_table + ''',''primary_temp_id'') IS NULL 
							BEGIN 
								ALTER TABLE ' + @split_process_table + ' ADD primary_temp_id INT NOT NULL DEFAULT 1 
							END
							IF COL_LENGTH(''' + @split_process_table + ''', ''attachment_files'') IS NULL
							BEGIN
								ALTER TABLE ' + @split_process_table + ' ADD attachment_files NVARCHAR(300) NULL
							END'
				EXEC(@sql)
			END

			INSERT INTO #module_event_where_clause
			SELECT @module_events_id, @select_part + @where_part, 1, @workflow_group_id, @split_process_table
		END
	END
	
FETCH NEXT FROM module_events_cursor INTO @module_events_id, @workflow_task_id, @workflow_group_id
END   

CLOSE module_events_cursor   
DEALLOCATE module_events_cursor

IF OBJECT_ID('tempdb..#alerts') IS NOT NULL
	DROP TABLE #alerts

CREATE TABLE #alerts (alert_id INT, event_trigger_id INT, module_events_id INT, workflow_group_id INT, new_process_table NVARCHAR(2000) COLLATE DATABASE_DEFAULT)


SET @user_login_id = dbo.FNADBUser()

SET @sql = 'INSERT INTO #alerts (alert_id, event_trigger_id, module_events_id, workflow_group_id, new_process_table)
			SELECT DISTINCT ett.alert_id, ett.event_trigger_id, mee.module_events_id, par.id, mewc.new_process_table
			FROM module_events mee
			LEFT JOIN event_trigger ett ON mee.module_events_id = ett.modules_event_id
			LEFT JOIN (	
				SELECT DISTINCT wea.alert_id,me.is_active
				FROM module_events me
				INNER JOIN event_trigger et ON  me.module_events_id = et.modules_event_id
				INNER JOIN workflow_event_message wem ON wem.event_trigger_id = et.event_trigger_id
				LEFT JOIN workflow_event_action wea ON wea.event_message_id = wem.event_message_id
				INNER JOIN alert_sql as1 ON as1.alert_sql_id = et.alert_id
				WHERE as1.is_active = ''y'' AND wea.event_action_id IS NOT NULL AND wea.alert_id IS NOT NULL
			) a ON a.alert_id = ett.event_trigger_id
			LEFT JOIN alert_sql as2 ON ett.alert_id = as2.alert_sql_id
			LEFT JOIN workflow_schedule_task wst ON wst.workflow_id = mee.module_events_id AND wst.workflow_id_type = 1
			LEFT JOIN workflow_schedule_task par ON wst.parent = par.id
			OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(mee.event_id)) evt
			LEFT JOIN #module_event_where_clause mewc ON mewc.module_events_id = mee.module_events_id AND mewc.workflow_group_id = par.id
			WHERE a.alert_id IS NULL and as2.is_active = ''y'' AND ISNULL(mewc.condition_match, 1) > 0 AND ISNULL(par.system_defined,0) <> 2 AND ISNULL(a.is_active,''y'') = ''y''
			AND ISNULL(mee.is_active,''y'') = ''y''
			'
IF @nxt_module_events_id IS NULL
	SET @sql = @sql + ' AND mee.modules_id = ' + CAST(@module_id AS NVARCHAR) + ' AND evt.event_id = ' + CAST(@event_id AS NVARCHAR)
ELSE 
	SET @sql = @sql + ' AND mee.module_events_id = ' + CAST(@nxt_module_events_id AS NVARCHAR) + ' AND par.id = ' + CAST(@workflow_g_id AS NVARCHAR)

SET @sql = @sql + ' UNION 
			SELECT DISTINCT ett.alert_id, ett.event_trigger_id, mee.module_events_id,par.id, mewc.new_process_table
			FROM module_events mee
			LEFT JOIN event_trigger ett ON mee.module_events_id = ett.modules_event_id
			LEFT JOIN workflow_schedule_task wst ON wst.workflow_id = mee.module_events_id AND wst.workflow_id_type = 1
			LEFT JOIN workflow_schedule_task par ON wst.parent = par.id
			LEFT JOIN alert_sql as2 ON ett.alert_id = as2.alert_sql_id
			LEFT JOIN workflow_schedule_task wst_e ON wst_e.workflow_id = ett.event_trigger_id AND wst_e.workflow_id_type = 2
			LEFT JOIN #module_event_where_clause mewc ON mewc.module_events_id = mee.module_events_id AND mewc.workflow_group_id = par.id
			OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(mee.event_id)) evt
			WHERE as2.is_active = ''y'' AND ISNULL(mewc.condition_match, 1) > 0 AND wst_e.sort_order = 1  AND ISNULL(par.system_defined,0) <> 2 AND ISNULL(mee.is_active,''y'') = ''y'''
IF @nxt_module_events_id IS NULL
	SET @sql = @sql + ' AND mee.modules_id = ' + CAST(@module_id AS NVARCHAR) + ' AND evt.event_id = ' + CAST(@event_id AS NVARCHAR)
ELSE 
	SET @sql = @sql + ' AND mee.module_events_id = ' + CAST(@nxt_module_events_id AS NVARCHAR) + ' AND par.id = ' + CAST(@workflow_g_id AS NVARCHAR)

EXEC (@sql)


DECLARE @cursor_name NVARCHAR(500)
SET @cursor_name = 'register_event_cursor' + dbo.FNAGetNewID()

SET @sql = '
DECLARE @alert_id INT 
DECLARE @event_trigger_id INT
DECLARE @workflow_group_id INT
DECLARE @job_name NVARCHAR(100)
DECLARE @new_process_table NVARCHAR(500)
DECLARE @process_queue_status NVARCHAR(100)
DECLARE ' + @cursor_name + ' CURSOR FOR
SELECT alert_id, event_trigger_id, workflow_group_id, new_process_table FROM #alerts ORDER BY alert_id

OPEN ' + @cursor_name + '
FETCH NEXT FROM ' + @cursor_name + ' 
INTO @alert_id, @event_trigger_id, @workflow_group_id, @new_process_table
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @new_process_table = ISNULL(@new_process_table,''' + @process_table + ''')
	IF ' + CAST(@is_batch AS NVARCHAR)+ ' = 0 AND ' + CAST(@execute_in_queue AS NVARCHAR)+ ' = 0
	BEGIN
		EXEC spa_run_alert_sql @alert_id,
         ''' + @process_id + ''',
         @new_process_table,
         NULL,
         NULL,
		 @event_trigger_id,
		 NULL,
		 NULL,
		 NULL,
		 @workflow_group_id
	END
	ELSE
	BEGIN
		DECLARE @sql_statement NVARCHAR(MAX)
		SET @sql_statement = ''spa_run_alert_sql '' + CAST(@alert_id AS NVARCHAR) + '','' + ''''''' + @process_id + ''''''' + '','''''' + @new_process_table + '''''',NULL,NULL,'' + CAST(@event_trigger_id AS NVARCHAR) + '',NULL,NULL,NULL,'' + CAST(@workflow_group_id AS NVARCHAR) + ''''
		EXEC spa_print @sql_statement
		IF ' + CAST(@execute_in_queue AS NVARCHAR)+ ' = 1
		BEGIN
			SET @sql_statement = ''EXEC '' + @sql_statement

			EXEC spa_process_queue	@flag = ''create_process_queue'',
									@source_id = @event_trigger_id,
									@process_queue_type = 112301,
									@queue_sql = @sql_statement,
									@process_id = ''' + @process_id + ''',
									@output_status = @process_queue_status
											
			EXEC spa_process_queue @flag = ''create_or_start_queue_job'', @process_queue_type = 112301, @output_status = @process_queue_status
		END
		ELSE
		BEGIN
			SET @job_name = ''Alert_Job_'' + CAST(@alert_id AS NVARCHAR) + ''_'' + CAST(CAST(RAND()*100 AS INT) AS NVARCHAR)+ ''_'' + CAST(@workflow_group_id AS NVARCHAR) + ''_'' + ''' + @process_id + '''' + '
			EXEC spa_run_sp_as_job @job_name, @sql_statement, @job_name, ''' + @user_login_id + ''',' + 'NULL, NULL, NULL
		END
	END		
		
    FETCH NEXT FROM ' + @cursor_name + ' 
    INTO @alert_id, @event_trigger_id, @workflow_group_id, @new_process_table
END
CLOSE ' + @cursor_name + '
DEALLOCATE ' + @cursor_name + ' '

--PRINT(ISNULL(@sql, 'is null')) 
EXEC(@sql)