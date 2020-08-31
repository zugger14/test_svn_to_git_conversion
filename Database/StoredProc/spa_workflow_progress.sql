IF OBJECT_ID(N'[dbo].[spa_workflow_progress]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_workflow_progress]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Operations for Workflow Status Report

	Parameters :
	@flag : Flag
			'p'-- Load the workflow
			's'-- Load the detail progress status of the workflow
			'w'-- Get the workflow name
			'z'-- Get the workflow group name
			'b'-- Get the parent
			'e'-- Get the EOD status report
	@filter_id : Value of the primary column of the workflow module
	@source_column : Primary Column of the Workflow Module
	@module_event_id : Module Event Id (module_events_id FROM module_events)
	@workflow_group_id : Workflow Group ID of the workflow
	@module_id : static_data_values - type_id = 20600
	@status : static_data_values - type_id = 725
	@date_from : Date From Filter
	@date_to : Date To Filter
	@user_login_id : User Login Id
	@workflow_process_id : Unique Identifier for the current Process and other process triggered after current process
	@show_all : Show all historic status of the workflow
 */

CREATE PROCEDURE [dbo].[spa_workflow_progress]
	@flag NCHAR(1),
	@filter_id	INT = NULL,
	@source_column NVARCHAR(100) = 'source_deal_header_id',
	@module_event_id NVARCHAR(100) = NULL,
	@workflow_group_id INT = NULL,
	@module_id INT = NULL,
	@status NVARCHAR(20) = NULL,
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@user_login_id NVARCHAR(500) = NULL,
	@workflow_process_id NVARCHAR(500) = NULL,
	@show_all NCHAR(1) = NULL
AS

/*
DECLARE @flag NCHAR(1) = 's',
	@filter_id	NVARCHAR(200) = '1',
	@source_column NVARCHAR(100) = 'primary_temp_id',
	@module_event_id NVARCHAR(300) = '30,31',
	@workflow_group_id NVARCHAR(300)='2350',
	@status NVARCHAR(300)='t,n,s',
	@module_id INT = NULL,
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@user_login_id NVARCHAR(500) = NULL,
	@show_all NCHAR(1) = NULL
--*/
SET NOCOUNT ON;

DECLARE @json_data NVARCHAR(MAX)
DECLARE @json_link NVARCHAR(MAX)
DECLARE @final_json NVARCHAR(MAX)

DECLARE @ud_text NVARCHAR(100)
DECLARE @total_tasks FLOAT
DECLARE @completed_task FLOAT
DECLARE @completed_percent FLOAT
DECLARE @latest_status NVARCHAR(300)

DECLARE @filter_id_new INT = @filter_id
IF @flag = 'p'
BEGIN
	SET @json_data = ''
	SET @json_link = ''

	DECLARE @d_id INT, @text NVARCHAR(500),@start_date DATETIME, @duration INT, @progress INT, @sort_order INT, @parent INT, @workflow_id_type INT, @workflow_id INT
	DECLARE @n_source_column NVARCHAR(100), @n_filter_id INT

	IF OBJECT_ID('tempdb..#temp_workflow_progress_data') IS NOT NULL
		DROP TABLE #temp_workflow_progress_data
	CREATE TABLE #temp_workflow_progress_data (id INT, [text] NVARCHAR(100) COLLATE DATABASE_DEFAULT, [start_date] DATETIME, duration INT, progress INT, sort_order INT, parent INT, workflow_id_type INT, workflow_id INT)

	INSERT INTO #temp_workflow_progress_data (id, [text], [start_date], duration, progress, sort_order, parent, workflow_id_type, workflow_id)
	SELECT DISTINCT wst.id, wst.[text], wst.[start_date], wst.duration, wst.progress, wst.sort_order, wst.parent, wst.workflow_id_type, wst.workflow_id
	FROM workflow_schedule_task wst
	LEFT JOIN module_events me ON wst.workflow_id = me.module_events_id AND wst.workflow_id_type = 1
	LEFT JOIN workflow_schedule_task par ON wst.parent = par.id
	INNER JOIN event_trigger et ON me.module_events_id = et.modules_event_id
	INNER JOIN alert_sql asl ON et.alert_id = asl.alert_sql_id
	INNER JOIN alert_rule_table art ON asl.alert_sql_id = art.alert_id
	INNER JOIN alert_columns_definition acd ON art.table_id = acd.alert_table_id AND acd.is_primary = 'y'
	WHERE par.system_defined < 2 AND (acd.column_name = @source_column OR acd.column_name = CASE WHEN @source_column = 'source_deal_header_id' THEN 'match_group_id' ELSE @source_column END)


	INSERT INTO #temp_workflow_progress_data (id, [text], [start_date], duration, progress, sort_order, parent, workflow_id_type, workflow_id)
	SELECT wst.id, wst.[text], wst.[start_date], wst.duration, wst.progress, wst.sort_order, wst.parent, wst.workflow_id_type, wst.workflow_id
	FROM workflow_schedule_task wst
	INNER JOIN #temp_workflow_progress_data twpa ON wst.id = twpa.parent
	WHERE wst.workflow_id_type = 0 AND wst.system_defined < 2
	
	IF OBJECT_ID('tempdb..#tmp_task_json') IS NOT NULL
		DROP TABLE #tmp_task_json
	
	CREATE TABLE #tmp_task_json (id INT, task_json NVARCHAR(2000) COLLATE DATABASE_DEFAULT, progress FLOAT, parent INT, sort INT)

	DECLARE data_cursor CURSOR FOR 
	SELECT id, [text], [start_date], duration, progress, sort_order, parent, workflow_id_type, workflow_id
	FROM #temp_workflow_progress_data
	WHERE workflow_id_type < 2
	ORDER BY workflow_id_type, sort_order
	
	OPEN data_cursor 
	FETCH NEXT FROM data_cursor 
	INTO @d_id, @text,@start_date,@duration,@progress,@sort_order,@parent,@workflow_id_type, @workflow_id

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ud_text = NULL
		SET @latest_status = ''
		
		
		IF @workflow_id_type = 0
		BEGIN
			SET @json_data = '{"id":' + CAST(@d_id AS NVARCHAR) + ', "duration":' + CAST(3 AS NVARCHAR) + ', "start_date":"' + CONVERT(NVARCHAR(12),CONVERT(DATETIME,@start_date,110),105) + '", "order":' + CAST(1 AS NVARCHAR)+ ', "ud_value1":"' + ISNULL(CAST(@filter_id AS NVARCHAR), '') + '","open":true, "color": "#b8b894", "text":"' + ISNULL(@text, 'Workflow Group') + '"}' 
			INSERT INTO #tmp_task_json (id, task_json, progress, parent, sort)
			SELECT @d_id, @json_data, 0, NULL, NULL
		END
		ELSE IF @workflow_id_type = 1
		BEGIN
			SET @n_source_column = @source_column
			SET @filter_id_new = @filter_id

			IF @n_source_column = 'source_deal_header_id'
			BEGIN
				IF EXISTS(SELECT 1 FROM module_events me 
				INNER JOIN alert_table_definition atd ON me.rule_table_id = atd.alert_table_definition_id
				WHERE me.module_events_id = @workflow_id AND logical_table_name = 'Scheduling')
				BEGIN
					SET @n_source_column = 'match_group_id'

					SET @filter_id_new = (SELECT DISTINCT TOP(1) mgh.match_group_id FROM match_group_header mgh
					INNER JOIN match_group_detail mgd ON mgh.match_group_header_id = mgd.match_group_header_id
					INNER JOIN source_deal_detail sdd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
					WHERE sdd.source_deal_header_id = @filter_id)
				END
			END

			SELECT @total_tasks = COUNT(event_trigger_id) FROM event_trigger et
			LEFT JOIN workflow_event_action wea ON et.event_trigger_id = wea.alert_id
			WHERE modules_event_id = @workflow_id AND (status_id <> 726 OR status_id IS NULL)

			SELECT TOP(1) @workflow_process_id = workflow_process_id FROM workflow_activities wa
			INNER JOIN event_trigger et ON wa.workflow_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @workflow_id AND wa.source_column = @n_source_column AND wa.source_id = @filter_id_new
			ORDER BY wa.create_ts DESC 

			--SELECT TOP(1) @workflow_process_id = workflow_process_id
			--FROM workflow_activities wa
			--INNER JOIN event_trigger et ON wa.workflow_trigger_id = event_trigger_id
			--INNER JOIN match_group_detail mgd ON mgd.match_group_id = wa.source_id
			--INNER JOIn source_deal_detail sdd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
			--WHERE wa.source_column = 'match_group_id' AND sdd.source_deal_header_id = @filter_id AND et.modules_event_id = @workflow_id
			--ORDER BY wa.create_ts desc

			SELECT @completed_task = COUNT(wa.workflow_activity_id)
			FROM workflow_activities wa
			INNER JOIN event_trigger et ON wa.workflow_trigger_id = et.event_trigger_id
			WHERE workflow_process_id = @workflow_process_id AND et.modules_event_id = @workflow_id


			SET @completed_percent = ROUND(@completed_task/ISNULL(@total_tasks,1),2)  
			
			SELECT	@ud_text = me.workflow_name 
			FROM workflow_schedule_task wst
			LEFT JOIN module_events me ON me.module_events_id = wst.workflow_id  AND wst.workflow_id_type = 1
			WHERE wst.id = @d_id

			SELECT TOP(1) @latest_status = wem.event_message_name + ' - ' + ISNULL(sdv.code, 'Approval Pending')
			FROM workflow_activities wa
			INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wa.workflow_trigger_id = et.event_trigger_id
			LEFT JOIN static_data_value sdv ON wa.control_status = sdv.value_id
			WHERE workflow_process_id = @workflow_process_id AND et.modules_event_id = @workflow_id
			ORDER BY workflow_activity_id DESC

			
			SET @json_data = '{"id":' + CAST(@d_id AS NVARCHAR) + ', "duration":' + CAST(3 AS NVARCHAR) + ', "start_date":"' + CONVERT(NVARCHAR(12),CONVERT(DATETIME,@start_date,110),105) + '", "order":' + CAST(1 AS NVARCHAR)+ ', "ud_value1":"' + ISNULL(CAST(@filter_id_new AS NVARCHAR), '') + '","ud_value2":' + CAST(@workflow_id AS NVARCHAR) + ', "ud_value3":"' + @latest_status + '","progressColor": "#669999","progress": ' + CAST(@completed_percent AS NVARCHAR) + ', "open":false, "text":"' + ISNULL(@ud_text, ISNULL(@text, 'Workflow')) + '", "parent":' + CAST(@parent AS NVARCHAR) + '}'

			INSERT INTO #tmp_task_json (id, task_json, progress, parent, sort)
			SELECT @d_id,@json_data, @completed_percent, @parent, @sort_order
			
		END
		
		FETCH NEXT FROM data_cursor 
		INTO @d_id, @text,@start_date,@duration,@progress,@sort_order,@parent,@workflow_id_type,@workflow_id
	END 
	CLOSE data_cursor;
	DEALLOCATE data_cursor;


	IF OBJECT_ID('tempdb..#tmp_task_parent') IS NOT NULL
		DROP TABLE #tmp_task_parent
	
	CREATE TABLE #tmp_task_parent (id INT)

	INSERT INTO #tmp_task_parent
	SELECT DISTINCT parent FROM #tmp_task_json WHERE progress > 0

	SELECT @final_json =
		STUFF((SELECT ',' + b.task_json
				FROM (SELECT DISTINCT ttj.task_json, ttj.id, ttj.parent, ttj.sort FROM #tmp_task_json ttj
						INNER JOIN #tmp_task_parent ttp ON ttj.id = ttp.id
						UNION ALL
						SELECT DISTINCT ttj.task_json, ttj.id, ttj.parent, ttj.sort FROM #tmp_task_json ttj
						INNER JOIN #tmp_task_parent ttp ON ttj.parent = ttp.id
					) b ORDER BY b.parent,b.sort
			FOR XML PATH('')), 1, 1, '')

	SET @final_json = '{"data":[' + ISNULL(@final_json,'') + ']}'
	SELECT @final_json
END

ELSE IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_workflow_process_id') IS NOT NULL
		DROP TABLE #temp_workflow_process_id
	CREATE TABLE #temp_workflow_process_id (workflow_process_id NVARCHAR(300) COLLATE DATABASE_DEFAULT)

	DECLARE @match_group_event INT
	DECLARE @match_group_id INT

	IF @source_column = 'source_deal_header_id'
	BEGIN
		IF EXISTS(SELECT 1 FROM module_events me 
		INNER JOIN alert_table_definition atd ON me.rule_table_id = atd.alert_table_definition_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@module_event_id) a ON a.item = me.module_events_id
		WHERE logical_table_name = 'Scheduling')
		BEGIN
			SELECT @match_group_event = a.item FROM module_events me 
			INNER JOIN alert_table_definition atd ON me.rule_table_id = atd.alert_table_definition_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@module_event_id) a ON a.item = me.module_events_id
			WHERE logical_table_name = 'Scheduling'

			SET @match_group_id = (SELECT DISTINCT TOP(1) mgh.match_group_id FROM match_group_header mgh
			INNER JOIN match_group_detail mgd ON mgh.match_group_header_id = mgd.match_group_header_id
			INNER JOIN source_deal_detail sdd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.source_deal_header_id = @filter_id)
		END	
	END

	IF @source_column = 'workflow_process_id'
	BEGIN
		INSERT INTO #temp_workflow_process_id (workflow_process_id)
		SELECT @workflow_process_id	
	END
	ELSE
	BEGIN
		INSERT INTO #temp_workflow_process_id (workflow_process_id)
		SELECT workflow_process_id FROM (
			SELECT workflow_process_id, et.modules_event_id, wa.workflow_trigger_id, wa.source_id, wa.create_ts, rank() over(partition by et.modules_event_id order by wa.create_ts desc) [rnk]
			FROM workflow_activities wa
			INNER JOIN event_trigger et ON wa.workflow_trigger_id = event_trigger_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@module_event_id) com ON com.item = et.modules_event_id
			WHERE wa.source_column = CASE 
										WHEN @match_group_event = et.modules_event_id THEN 'match_group_id' 
										WHEN wa.source_column = 'primary_temp_id' THEN wa.source_column 
										ELSE @source_column 
									 END 
				AND wa.source_id = CASE WHEN @match_group_event = et.modules_event_id THEN @match_group_id ELSE @filter_id END
		) a
		WHERE rnk = 1 
	END

	
	IF OBJECT_ID('tempdb..#temp_all_workflow_events') IS NOT NULL
		DROP TABLE #temp_all_workflow_events

	IF OBJECT_ID('tempdb..#temp_audit_workflow_events') IS NOT NULL
		DROP TABLE #temp_audit_workflow_events

	IF OBJECT_ID('tempdb..#temp_scheduled_workflow_events') IS NOT NULL
		DROP TABLE #temp_scheduled_workflow_events

	IF OBJECT_ID('tempdb..#temp_group_ignore_chk') IS NOT NULL
		DROP TABLE #temp_group_ignore_chk
	CREATE TABLE #temp_group_ignore_chk (workflow_id INT, [status] NCHAR(1))

	IF OBJECT_ID('tempdb..#temp_custom_activity') IS NOT NULL
		DROP TABLE #temp_custom_activity

	IF OBJECT_ID('tempdb..#temp_completed_scheduled_activity') IS NOT NULL
		DROP TABLE #temp_completed_scheduled_activity

	IF OBJECT_ID('tempdb..#temp_action_list') IS NOT NULL
		DROP TABLE #temp_action_list

	-- All the workflow events.
	SELECT DISTINCT	modules_event_id, 
				et.event_trigger_id,
				wem.event_message_id, 
				me.workflow_name, 
				wem.event_message_name,
				'Not Started' [status],
				ISNULL(wea.status_id,1) status_id,
				CASE WHEN CHARINDEX('20548',  me.event_id) > 0 THEN 'y' ELSE 'n' END [manual_step],
				et.manual_step [manual_checked],
				wst.parent [workflow_group_id],
				wst1.sort_order,
				me.event_id [event],
				'' c_ts,
				'' c_user,
				'' c_event
	INTO #temp_all_workflow_events
	FROM workflow_event_message wem
	INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
	INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@module_event_id) com ON com.item = et.modules_event_id
	LEFT JOIN workflow_event_action wea ON wea.alert_id = et.event_trigger_id
	LEFT JOIN workflow_schedule_task wst ON wst.workflow_id = me.module_events_id AND wst.workflow_id_type = 1
	LEFT JOIN dbo.workflow_schedule_task wst1 ON wst1.parent = wst.id AND wst1.workflow_id_type = 2 AND wst1.workflow_id = et.event_trigger_id
	WHERE ISNULL(@workflow_group_id,'') = CASE WHEN @workflow_group_id IS NULL THEN '' ELSE wst.parent END
	UNION ALL
	SELECT	wca.modules_event_id,
			wca.workflow_custom_activity_id [event_trigger_id],
			-1 [event_message_id],
			me.workflow_name,
			wca.workflow_custom_activity_desc,
			CASE 
				WHEN ce.calendar_event_id IS NULL OR wca.[status] IS NOT NULL THEN 'Custom Activity' + ISNULL(' - ' + sdv.code, '')
				ELSE 'Custom Activity -  Scheduled'
			END [status],
			1 [status_id],
			CASE 
				WHEN ce.calendar_event_id IS NOT NULL AND wca.status IS NOT NULL THEN 'n'
				WHEN ce.calendar_event_id IS NOT NULL THEN 'c'
				WHEN sdv.code IS NULL THEN 'a' 
				ELSE 'n' 
			END [manual_step],
			'y' [manual_checked],
			wca.workflow_group_id, 
			100 [sort_order],
			me.event_id [event],
			CASE 
				WHEN ce.calendar_event_id IS NOT NULL THEN ce.[start_date]
				ELSE wca.update_ts
			END [c_ts],
			CASE 
				WHEN ce.calendar_event_id IS NOT NULL THEN ' by ' + au_c.user_f_name + ' ' + au_c.user_l_name
				ELSE ' by ' + au.user_f_name + ' ' + au.user_l_name
			END [c_user],
			ce.calendar_event_id [c_event]
	FROM workflow_custom_activities wca
	INNER JOIN dbo.SplitCommaSeperatedValues(@module_event_id) com ON wca.modules_event_id = com.item
	INNER JOIN module_events me ON me.module_events_id = wca.modules_event_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = wca.status
	LEFT JOIN calendar_events ce ON ce.source_id = wca.workflow_custom_activity_id AND wca.workflow_custom_activity_desc = ce.name
	LEFT JOIN application_users au ON wca.update_user = au.user_login_id
	LEFT JOIN application_users au_c ON ce.create_user = au_c.user_login_id
	WHERE wca.workflow_group_id = @workflow_group_id AND wca.source_column = @source_column AND wca.source_id = @filter_id

	-- Events that are triggered.
	SELECT	et.modules_event_id, 
			et.event_trigger_id,
			wem.event_message_id, 
			me.workflow_name, 
			wem.event_message_name, 
			ISNULL(sdv.code, 'Approval Pending') [status], 
			' on ' + dbo.FNADateTimeFormat(ISNULL(wa.approved_date,wa.create_ts), 0) [approved_date], 
			ISNULL(' by ' + au.user_f_name,'') + ' ' + au.user_l_name [approved_by],
			an.attachment_file_name,
			an.attachment_folder, 
			wa.create_ts create_ts,
			CASE WHEN an.category_value_id = 42005 THEN 1 ELSE 0 END [is_manual_upload],
			cat.code [category],
			ISNULL(wau.control_new_status,wa.control_status) [status_id],
			wa.workflow_activity_id,
			wa.workflow_group_id,
			REPLACE(wa.[message],'href=".','href="../../../adiha.php.scripts')  + CASE WHEN wa.comments IS NOT NULL THEN '<br> [Comment: <i>' + wa.comments + '</i>]' ELSE '' END [message],
			wa.workflow_process_id,
			CASE WHEN tmp.workflow_process_id IS NOT NULL THEN 1 ELSE 0 END AS [is_latest],
			CASE WHEN tmp.workflow_process_id IS NOT NULL THEN '' ELSE ' - ' + dbo.FNADateTimeFormat(ftg.first_trigger,1) END first_trigger
	INTO #temp_audit_workflow_events
	FROM workflow_activities wa
	INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
	LEFT JOIN workflow_activities_audit wau ON wau.workflow_activity_id = wa. workflow_activity_id
	INNER JOIN event_trigger et ON wa.workflow_trigger_id = et.event_trigger_id
	INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
	LEFT JOIN #temp_workflow_process_id tmp ON wa.workflow_process_id = tmp.workflow_process_id
	LEFT JOIN static_data_value sdv ON ISNULL(wau.control_new_status,wa.control_status) = sdv.value_id
	LEFT JOIN application_users au ON wa.approved_by = au.user_login_id
	LEFT JOIN application_notes an ON an.workflow_process_id = tmp.workflow_process_id AND an.workflow_message_id = wem.event_message_id 
		AND ISNULL(an.parent_object_id, an.notes_object_id) = @filter_id
		AND wa.workflow_activity_id = (SELECT MAX(t_wa.workflow_activity_id) FROM dbo.workflow_activities t_wa WHERE t_wa.workflow_process_id = tmp.workflow_process_id AND t_wa.event_message_id = wem.event_message_id AND t_wa.source_id = @filter_id)
		AND an.create_ts = (SELECT MAX(t_an.create_ts) FROM dbo.application_notes t_an WHERE t_an.workflow_process_id = tmp.workflow_process_id AND t_an.workflow_message_id = wem.event_message_id AND ISNULL(t_an.parent_object_id,t_an.notes_object_id) = @filter_id)
	LEFT JOIN static_data_value cat ON cat.value_id = an.category_value_id
	OUTER APPLY (SELECT MIN(create_ts) first_trigger FROM workflow_activities tmp WHERE tmp.workflow_process_id = wa.workflow_process_id) ftg
	WHERE wa.source_id = @filter_id AND CASE WHEN ISNULL(@show_all, 'n') = 'n' THEN wa.workflow_process_id ELSE '1' END =  CASE WHEN ISNULL(@show_all, 'n') = 'n' THEN tmp.workflow_process_id ELSE '1' END

	-- Events that are scheduled
	SELECT	ce.calendar_event_id,
			ce.workflow_id,
			ce.alert_id,
			ce.workflow_group_id,
			ce.[start_date],
			ce.create_user
	INTO #temp_scheduled_workflow_events
	FROM calendar_events ce
	INNER JOIN dbo.SplitCommaSeperatedValues(@module_event_id) com ON ce.workflow_id = com.item
	LEFT JOIN workflow_activities wa ON ce.calendar_event_id = wa.source_id AND wa.source_column = 'calendar_event_id'
	WHERE ce.workflow_group_id = @workflow_group_id 
	AND CASE WHEN @source_column = 'workflow_process_id' THEN @filter_id ELSE ce.source_id END = @filter_id
	AND CASE WHEN @source_column = 'workflow_process_id' THEN ce.workflow_process_id ELSE @workflow_process_id END = @workflow_process_id
	AND wa.workflow_activity_id IS NULL
	
	INSERT INTO #temp_group_ignore_chk (workflow_id, [status])
	SELECT DISTINCT workflow_id, 'n' [status] 
	FROM #temp_scheduled_workflow_events
	UNION 
	SELECT DISTINCT modules_event_id, 'n' [status] FROM #temp_audit_workflow_events
	WHERE [status] <> 'Ignored'
	
	INSERT INTO #temp_group_ignore_chk (workflow_id, [status])
	SELECT DISTINCT  modules_event_id, 'r' [status] FROM #temp_audit_workflow_events tmp1
	LEFT JOIN #temp_group_ignore_chk tmp2 ON tmp1.modules_event_id = tmp2.workflow_id
	WHERE tmp1.[status] = 'Ignored' AND tmp2.workflow_id IS NULL

	SELECT  Results.event_message_id,
			STUFF((
			SELECT '   ' + 
				CASE WHEN wea.status_id = 729 AND wea.status_id <> 725 THEN '<a title="Approve" class="process_hyperlink approve_icon" onClick="hyperlink_workflow_approval_click(1,__workflow_activity_id__)"></a>'
						WHEN wea.status_id = 726 AND wea.status_id <> 725 THEN '<a title="Unapprove" class="process_hyperlink unapprove_icon" onClick="hyperlink_workflow_approval_click(0,__workflow_activity_id__)"></a>'
						WHEN wea.status_id = 728 AND wea.status_id <> 725 THEN '<a title="Complete" class="process_hyperlink complete_icon" onClick="hyperlink_workflow_approval_click(2,__workflow_activity_id__)"></a>'
				ELSE '' END
				FROM workflow_event_action wea
				WHERE (event_message_id = Results.event_message_id) 
				FOR XML PATH(''),TYPE 
			).value('.','NVARCHAR(MAX)') 
			,1,0,'') as actions,
			ISNULL(au.user_login_id,aru.user_login_id) [user_login_id]
	INTO #temp_action_list
	FROM workflow_event_action Results
	LEFT JOIN workflow_event_user_role weur ON weur.event_message_id = Results.event_message_id
	LEFT JOIN application_users au ON au.user_login_id = weur.user_login_id
	LEFT JOIN application_role_user aru ON aru.role_id = weur.role_id
	GROUP BY Results.event_message_id,au.user_login_id,aru.user_login_id

	SELECT DISTINCT c.calendar_event_id
	INTO #temp_completed_scheduled_activity
	FROM #temp_all_workflow_events a 
	LEFT JOIN #temp_scheduled_workflow_events c ON a.workflow_group_id = c.workflow_group_id AND a.modules_event_id = c.workflow_id AND a.event_trigger_id = c.alert_id
	LEFT JOIN #temp_audit_workflow_events b ON a.modules_event_id = b.modules_event_id AND b.event_message_id = a.event_message_id AND b.workflow_group_id = a.workflow_group_id
	WHERE b.modules_event_id IS NOT NULL AND c.calendar_event_id IS NOT NULL

	SELECT * FROM (
		SELECT  DISTINCT 
			a.modules_event_id, 
			a.event_trigger_id,
			a.event_message_id, 
			a.workflow_name + ISNULL(b.first_trigger,'') [workflow_name], 
			a.event_message_name,
			CASE 
				WHEN c.calendar_event_id IS NOT NULL AND b.modules_event_id IS NULL THEN ' - Scheduled'
				ELSE ' - ' + ISNULL(b.[status], a.[status]) 
			END [status],
			CASE 
				WHEN c.calendar_event_id IS NOT NULL AND b.modules_event_id IS NULL THEN ' for ' + dbo.FNADateTimeFormat(c.[start_date],0) 
				WHEN a.event_message_id = -1 AND a.manual_step = 'c' THEN ' for ' + dbo.FNADateTimeFormat(a.c_ts,0)
				WHEN a.event_message_id = -1 THEN ' on ' + dbo.FNADateTimeFormat(a.c_ts,0)
				ELSE b.approved_date
			END [approved_date],
			CASE WHEN b.[status] = 'Unapproved' THEN '' ELSE b.attachment_file_name END [attachment_file_name],
			CASE WHEN b.[status] = 'Unapproved' THEN '' ELSE b.attachment_folder END [attachment_folder],
			CASE 
				WHEN c.calendar_event_id IS NOT NULL THEN ' by ' + au1.user_f_name + ' ' + au1.user_l_name
				WHEN a.event_message_id = -1 THEN a.c_user
				ELSE b.approved_by
			END [approved_by],
			b.is_manual_upload,
			ISNULL(b.category, b.attachment_folder) [category],
			CASE WHEN a.event_message_id = -1 THEN a.c_ts ELSE b.create_ts END [create_ts],
			CASE 
				WHEN b.modules_event_id IS NULL AND c.workflow_id IS NOT NULL THEN 'c' 
				WHEN b.modules_event_id IS NULL THEN a.manual_step 
				WHEN b.modules_event_id IS NOT NULL AND b.status_id = '737' THEN 'i' 
				ELSE 'n' 
			END [manual_step],
			a.workflow_group_id,
			CASE WHEN ISNULL(b.is_latest,1) = 1 THEN
				CASE 
				WHEN b.modules_event_id IS NULL AND c.calendar_event_id IS NOT NULL THEN
					'<a class="process_hyperlink" onClick="hyperlink_calendar_complete_click(' + CAST(c.calendar_event_id AS NVARCHAR) + ')">Complete</a>
					 <a class="process_hyperlink" onClick="hyperlink_cancel_schedule_click(' + CAST(c.calendar_event_id AS NVARCHAR) + ')">Cancel</a>'
			
				WHEN a.manual_step = 'y' AND b.modules_event_id IS NULL THEN 
					'<div class="icon_right_align">
					<a title="Complete" class="process_hyperlink complete_icon" onClick="hyperlink_complete_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',' + CAST(a.modules_event_id AS NVARCHAR) + ',' + CAST(a.workflow_group_id AS NVARCHAR) + ')"></a>
					<a title="Schedule" class="process_hyperlink schedule_icon" onClick="hyperlink_schedule_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',' + CAST(a.modules_event_id AS NVARCHAR) + ',' + CAST(a.workflow_group_id AS NVARCHAR) + ','''')"></a>
					<a title="Ignore" class="process_hyperlink ignore_icon" onClick="hyperlink_ignore_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',' + CAST(a.modules_event_id AS NVARCHAR) + ',' + CAST(a.workflow_group_id AS NVARCHAR) + ')"></a>
					</div>'
				WHEN b.modules_event_id IS NOT NULL AND b.status_id = '737' THEN 
					'<a class="process_hyperlink" onClick="hyperlink_remove_igonore_click(' + CAST(b.workflow_activity_id AS NVARCHAR) + ')"></a>'
				WHEN a.manual_step = 'a' THEN
					'<div class="icon_right_align">
					<a title="Complete" class="process_hyperlink complete_icon" onClick="hyperlink_custom_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',''x'')"></a>
					<a title="Schedule" class="process_hyperlink schedule_icon" onClick="hyperlink_custom_schedule_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ')"></a>
					<a title="Remove" class="process_hyperlink remove_icon" onClick="hyperlink_custom_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',''w'')"></a>
					</div>'
				WHEN a.manual_step = 'c' AND a.event_message_id = -1 THEN 
					'<a class="process_hyperlink" onClick="hyperlink_calendar_complete_click(' + CAST(a.c_event AS NVARCHAR) + ')">Complete</a>
					 <a class="process_hyperlink" onClick="hyperlink_custom_cancel_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',''' + a.event_message_name + ''')">Cancel</a>'
				WHEN ((a.manual_checked <> 'n' AND a.manual_checked <> 'u') OR (a.manual_step = 'y' AND b.modules_event_id IS NOT NULL)) AND a.event_message_id > 0 THEN
					'<div class="icon_right_align">
					<a title="Complete" class="process_hyperlink complete_icon" onClick="hyperlink_complete_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',' + CAST(a.modules_event_id AS NVARCHAR) + ',' + CAST(a.workflow_group_id AS NVARCHAR) + ')"></a>
					<a title="Schedule" class="process_hyperlink schedule_icon" onClick="hyperlink_schedule_click(' + CAST(a.event_trigger_id AS NVARCHAR) + ',' + CAST(a.modules_event_id AS NVARCHAR) + ',' + CAST(a.workflow_group_id AS NVARCHAR) + ','''')"></a>' +
					CASE WHEN a.modules_event_id NOT IN (SELECT me.module_events_id FROM	module_events AS me WHERE me.modules_id=20619)
					THEN
						CASE WHEN b.workflow_activity_id IS NULL THEN '' ELSE '<a title="Document" class="process_hyperlink doc_icon" onClick="open_workflow_document(' + CAST(ISNULL(b.workflow_activity_id,'') AS NVARCHAR) + ')"></a>' END
					ELSE 
						''
					END +
					'</div>'				
				ELSE '' 
				END + 
				CASE 
					WHEN b.status = 'Approval Pending' AND ISNULL(NULLIF(wa.user_login_id,''), dbo.FNADBUser()) = dbo.FNADBUser() THEN ISNULL(REPLACE(tal.actions,'__workflow_activity_id__',b.workflow_activity_id),'')
					ELSE ''
				END
			ELSE '' END
			[hyperlink],
			CASE
				WHEN b.modules_event_id IS NULL AND c.workflow_id IS NOT NULL THEN 's'
				WHEN b.modules_event_id IS NOT NULL AND b.status_id = '737' THEN 'i' 
				WHEN b.modules_event_id IS NOT NULL THEN 't'
				ELSE 'n'
			END [status_id],
			a.sort_order,
			a.[event],
			CASE 
				WHEN gic.workflow_id IS NULL THEN 'y' 
				WHEN gic.workflow_id IS NOT NULL AND gic.[status] = 'n' THEN 'n'	
				ELSE 'r' 
			END [group_ignore],
			b.[message],
			wst.sort_order [workflow_sort],
			COALESCE(b.workflow_process_id, unt.workflow_process_id,a.workflow_name) [workflow_historic_id],
			ISNULL(b.[is_latest],1) [is_latest],
			ISNULL(@show_all,'n') [show_all]
		FROM #temp_all_workflow_events a 
		LEFT JOIN #temp_audit_workflow_events b ON a.modules_event_id = b.modules_event_id AND b.event_message_id = a.event_message_id AND b.workflow_group_id = a.workflow_group_id
		LEFT JOIN #temp_scheduled_workflow_events c ON a.workflow_group_id = c.workflow_group_id AND a.modules_event_id = c.workflow_id AND a.event_trigger_id = c.alert_id
		LEFT JOIN application_users au1 ON c.create_user = au1.user_login_id
		LEFT JOIN #temp_group_ignore_chk gic ON gic.workflow_id = a.modules_event_id
		LEFT JOIN workflow_activities wa ON wa.workflow_activity_id = b.workflow_activity_id
		LEFT JOIN #temp_action_list tal ON tal.event_message_id = a.event_message_id AND ISNULL(tal.user_login_id,wa.user_login_id)  = dbo.FNADBUser()
		LEFT JOIN workflow_schedule_task wst ON wst.workflow_id = a.modules_event_id AND wst.workflow_id_type = 1 AND wst.parent = a.workflow_group_id
		OUTER APPLY (SELECT TOP(1) workflow_process_id 
						FROM #temp_audit_workflow_events tmp
						WHERE tmp.is_latest = 1
						AND a.modules_event_id = tmp.modules_event_id AND tmp.workflow_group_id = a.workflow_group_id) unt
		WHERE (a.status_id <> 726 OR b.modules_event_id IS NOT NULL) 
		AND CASE WHEN (ISNULL(b.[status], a.[status]) = 'Approved' AND NULLIF(b.approved_by,'') IS NULL) THEN 0 ELSE 1 END = 1
	
		UNION ALL

		SELECT DISTINCT 
			a.modules_event_id, 
			a.event_trigger_id,
			a.event_message_id, 
			a.workflow_name + ISNULL(b.first_trigger,'') [workflow_name], 
			a.event_message_name,
			' - Scheduled'[status],
			' for ' + dbo.FNADateTimeFormat(c.[start_date],0) [approved_date],
			'' [attachment_file_name],
			'' [attachment_folder],
			' by ' + au1.user_f_name + ' ' + au1.user_l_name [approved_by],
			b.is_manual_upload,
			ISNULL(b.category, b.attachment_folder) [category],
			b.create_ts [create_ts],
			'c' [manual_step],
			a.workflow_group_id,
			'&nbsp;&nbsp; <a class="process_hyperlink" onClick="hyperlink_calendar_complete_click(' + CAST(c.calendar_event_id AS NVARCHAR) + ')">Complete</a>
			&nbsp;&nbsp; <a class="process_hyperlink" onClick="hyperlink_cancel_schedule_click(' + CAST(c.calendar_event_id AS NVARCHAR) + ')">Cancel</a>'
				[hyperlink],
			CASE
				WHEN b.modules_event_id IS NULL AND c.workflow_id IS NOT NULL THEN 's'
				WHEN b.modules_event_id IS NOT NULL AND b.status_id = '737' THEN 'i' 
				WHEN b.modules_event_id IS NOT NULL THEN 't'
				ELSE 'n'
			END [status_id],
			a.sort_order,
			a.[event],
			CASE 
				WHEN gic.workflow_id IS NULL THEN 'y' 
				WHEN gic.workflow_id IS NOT NULL AND gic.[status] = 'n' THEN 'n'	
				ELSE 'r' 
			END [group_ignore],
			'' [message],
			wst.sort_order [workflow_sort],
			COALESCE(b.workflow_process_id, unt.workflow_process_id,a.workflow_name) [workflow_historic_id],
			ISNULL(b.[is_latest],1) [is_latest],
			ISNULL(@show_all,'n') [show_all]
		FROM #temp_completed_scheduled_activity tcc
		INNER JOIN calendar_events c ON tcc.calendar_event_id = c.calendar_event_id
		INNER JOIN #temp_all_workflow_events a ON a.workflow_group_id = c.workflow_group_id AND a.modules_event_id = c.workflow_id AND a.event_trigger_id = c.alert_id
		OUTER APPLY ( SELECT MAX(workflow_activity_id) [workflow_activity_id] FROM #temp_audit_workflow_events tmp WHERE a.modules_event_id = tmp.modules_event_id
					 AND tmp.event_message_id = a.event_message_id AND tmp.workflow_group_id = a.workflow_group_id) tmp_b
		LEFT JOIN #temp_audit_workflow_events b ON b.workflow_activity_id = tmp_b.workflow_activity_id
		LEFT JOIN application_users au1 ON c.create_user = au1.user_login_id
		LEFT JOIN #temp_group_ignore_chk gic ON gic.workflow_id = a.modules_event_id
		LEFT JOIN workflow_schedule_task wst ON wst.workflow_id = a.modules_event_id AND wst.workflow_id_type = 1 AND wst.parent = a.workflow_group_id
		OUTER APPLY (SELECT TOP(1) workflow_process_id 
						FROM #temp_audit_workflow_events tmp
						WHERE tmp.is_latest = 1
						AND a.modules_event_id = tmp.modules_event_id AND tmp.workflow_group_id = a.workflow_group_id) unt
		WHERE b.modules_event_id IS NOT NULL AND c.calendar_event_id IS NOT NULL

		) a
	INNER JOIN dbo.SplitCommaSeperatedValues(@status) st ON st.item = a.status_id
	ORDER BY a.[workflow_sort], 
			CASE
				WHEN a.manual_step = 'i' THEN 99999 
				WHEN a.manual_step = 'c' THEN 88888
				WHEN a.create_ts IS NULL THEN ISNULL(a.sort_order,1)
				ELSE 0
			END,
			CASE 
				WHEN a.manual_step = 'i' THEN 99999 
				WHEN a.manual_step = 'c' THEN 88888
				WHEN a.manual_step = 'y' THEN 77777 
				WHEN a.manual_step = 'n' AND a.create_ts IS NULL THEN 66666 
				ELSE a.create_ts 
			END, 
			a.event_message_id
	
END

ELSE IF @flag = 'w'
BEGIN
	SELECT me.module_events_id, me.workflow_name FROM workflow_schedule_task wst
	INNER JOIN module_events me ON wst.workflow_id = me.module_events_id AND wst.workflow_id_type = 1
	
	WHERE wst.parent = @workflow_group_id AND me.modules_id = @module_id AND ISNULL(me.is_active, 'y') = 'y'
END

ELSE IF @flag = 'z'
BEGIN
	SELECT DISTINCT wst.id,wst.text FROM workflow_schedule_task wst
    INNER JOIN workflow_schedule_task wst1 ON wst.id = wst1.parent AND wst.workflow_id_type = 0
    INNER JOIN module_events me ON me.module_events_id = wst1.workflow_id AND wst1.workflow_id_type = 1
    WHERE me.modules_id = @module_id AND wst.system_defined IN (0,1) AND ISNULL(me.is_active, 'y') = 'y'
END

ELSE IF @flag = 'b'
BEGIN
	SELECT TOP(1) wst.parent FROM workflow_activities wa
	INNER JOIN event_trigger et On et.event_trigger_id = wa.workflow_trigger_id
	INNER JOIN module_events me ON me.module_events_id = et.modules_event_id AND ISNULL(me.is_active,'y') = 'y' AND me.modules_id = @module_id
	CROSS APPLY dbo.SplitCommaSeperatedValues(me.event_id) e
	INNER JOIN workflow_schedule_task wst ON me.module_events_id = wst.workflow_id AND wst.workflow_id_type = 1
	WHERE wa.source_id = @filter_id AND wa.source_column = @source_column AND e.item = 20548
	ORDER BY as_of_date DESC
END

ELSE IF @flag = 'e'
BEGIN
	SELECT  master_process_id [Master Process], 
		dbo.FNADateFormat(as_of_date) [As of Date], ISNULL(au.user_f_name + ' ' + au.user_l_name,eps.create_user) [Create User],
		MIN(dbo.fnadatetimeformat(eps.create_ts,0)) [Create TS]
	FROM eod_process_status eps
	LEFT JOIN application_users au ON eps.create_user = au.user_login_id
	LEFT JOIN dbo.SplitCommaSeperatedValues(@user_login_id) a ON a.item = au.application_users_id
	WHERE as_of_date >= ISNULL(@date_from,as_of_date) AND as_of_date <= ISNULL(@date_to,as_of_date)
	AND CASE WHEN NULLIF(@user_login_id,'') IS NULL THEN au.application_users_id ELSE a.item END IS NOT NULL
	GROUP BY master_process_id,dbo.FNADateFormat(as_of_date),ISNULL(au.user_f_name + ' ' + au.user_l_name,eps.create_user)
	ORDER BY dbo.FNADateFormat(as_of_date) DESC
END
