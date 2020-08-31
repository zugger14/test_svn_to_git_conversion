IF OBJECT_ID(N'[dbo].[spa_workflow_schedule]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_workflow_schedule]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Operation for Workflow Setup

	Parameters :
	@flag : Flag
			's'-- Build the JSON for workflow
			'i'-- Insert the workflow task
			'd'-- Delete the workflow task
			'u'-- Update the workflow task
			'l'-- Insert the workflow link
			'k'-- Delete the workflow link
			'w'-- Insert/Update the workflow
			'r'-- Insert/Update the rule
			'a'-- Insert/Update the action
			'c'-- To save approve/unapprove/completed from context menu
			'g'-- Insert/Update Workflow Group
			'h'-- Get Workflow Reports
			'e'-- Sort the sequence number
			'p'-- Dropdown for template workflow
			'q'-- Dropdown for workflow link
			't'-- Getting report paramset id from paramset hast
			'l'-- Get Column widgets
			 
	@task_id : task_id from workflow_schedule_task
	@task_date : start_date from workflow_schedule_task
	@task_duration : durationfrom workflow_schedule_task
	@task_parent : parent from workflow_schedule_task
	@task_level : workflow_id_type from workflow_schedule_task
	@link_id : id from workflow_schedule_link
	@link_source : source from workflow_schedule_link
	@link_target : target from workflow_schedule_link
	@link_type : type from workflow_schedule_link
	@xml : Xml Data
	@action_type : static_data_values - type_id = 725
	@alert_sql_id : Id of the Alert Rule (alert_sql_id FROM alert_sql)
	@module_id : static_data_values - type_id = 20600
	@event_id : static_data_values - type_id = 20500
	@trigger_id : Event Trigger Id (event_trigger_id FROM event_trigger)
	@paramset_hash : Report Paramset Hash filter to get report name
	@column_id : Data Source Column ID
 */

CREATE PROCEDURE [dbo].[spa_workflow_schedule]
	@flag NCHAR(1),
	@task_id INT = NULL,
	@task_date DATETIME = NULL,
	@task_duration INT = NULL,
	@task_parent INT = NULL,
	@task_level INT = NULL,
	@link_id INT = NULL,
	@link_source INT = NULL,
	@link_target INT = NULL,
	@link_type INT = NULL,
	@xml TEXT = NULL,
	@action_type INT = NULL,
	@alert_sql_id INT = NULL,
	@module_id INT = NULL,
	@event_id INT = NULL,
	@trigger_id INT = NULL,
	@paramset_hash NVARCHAR(MAX) = NULL,
	@column_id INT = NULl 

AS

SET NOCOUNT ON;

DECLARE @json_data NVARCHAR(MAX)
DECLARE @json_link NVARCHAR(MAX)
DECLARE @final_json NVARCHAR(MAX)

DECLARE @ud_text NVARCHAR(100)
DECLARE @ud_value1 NVARCHAR(100)
DECLARE @ud_value2 NVARCHAR(100)
DECLARE @ud_value3 NVARCHAR(100)
DECLARE @ud_value4 NVARCHAR(100)
DECLARE @ud_value5 NVARCHAR(100)
DECLARE @ud_value6 NVARCHAR(100)
DECLARE @ud_value7 NVARCHAR(100)

DECLARE @idoc INT
/*
Workflow_id_type
0 - Workflow Group
1 - Workflow
2 - Rule
3 - Message
4 - Action
*/

-- Build the JSON for workflow
IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#tmp_wg_task') IS NOT NULL
		DROP TABLE #tmp_wg_task
	CREATE TABLE #tmp_wg_task (task_id INT, parent_id INT)

	INSERT INTO #tmp_wg_task(task_id)
	SELECT w5.id FROM workflow_schedule_task w1
	INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
	INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
	INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
	INNER JOIN workflow_schedule_task w5 ON w4.id = w5.parent
	LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
	OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
	WHERE w1.id = CASE WHEN @task_id = '' THEN w1.id ELSE @task_id END 
	AND ISNULL(me.modules_id,'') = CASE WHEN @module_id = '' THEN ISNULL(me.modules_id,'') ELSE @module_id END 
	AND ISNULL(evt.event_id,'') = CASE WHEN @event_id = '' THEN ISNULL(evt.event_id,'') ELSE @event_id END 
	
	INSERT INTO #tmp_wg_task(task_id)
	SELECT w4.id FROM workflow_schedule_task w1
	INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
	INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
	INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
	LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
	OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
	WHERE w1.id = CASE WHEN @task_id = '' THEN w1.id ELSE @task_id END 
	AND ISNULL(me.modules_id,'') = CASE WHEN @module_id = '' THEN ISNULL(me.modules_id,'') ELSE @module_id END 
	AND ISNULL(evt.event_id,'') = CASE WHEN @event_id = '' THEN ISNULL(evt.event_id,'') ELSE @event_id END 

	INSERT INTO #tmp_wg_task(task_id)
	SELECT w3.id FROM workflow_schedule_task w1
	INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
	INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
	LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
	OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
	WHERE w1.id = CASE WHEN @task_id = '' THEN w1.id ELSE @task_id END 
	AND ISNULL(me.modules_id,'') = CASE WHEN @module_id = '' THEN ISNULL(me.modules_id,'') ELSE @module_id END 
	AND ISNULL(evt.event_id,'') = CASE WHEN @event_id = '' THEN ISNULL(evt.event_id,'') ELSE @event_id END 

	INSERT INTO #tmp_wg_task(task_id)
	SELECT w2.id FROM workflow_schedule_task w1
	INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
	LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
	OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
	WHERE w1.id = CASE WHEN @task_id = '' THEN w1.id ELSE @task_id END 
	AND ISNULL(me.modules_id,'') = CASE WHEN @module_id = '' THEN ISNULL(me.modules_id,'') ELSE @module_id END 
	AND ISNULL(evt.event_id,'') = CASE WHEN @event_id = '' THEN ISNULL(evt.event_id,'') ELSE @event_id END 
	
	IF @task_id = ''
	BEGIN
		INSERT INTO #tmp_wg_task(task_id)
		SELECT w2.parent FROM workflow_schedule_task w1
		INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
		LEFT JOIN module_events me ON w2.workflow_id = me.module_events_id AND w2.workflow_id_type = 1
		OUTER APPLY (SELECT item [event_id] FROM dbo.SplitCommaSeperatedValues(me.event_id)) evt
		WHERE w1.id = CASE WHEN @task_id = '' THEN w1.id ELSE @task_id END 
		AND w1.system_defined <> 1 -- To remove system defined workflow type.
		AND ISNULL(me.modules_id,'') = CASE WHEN @module_id = '' THEN ISNULL(me.modules_id,'') ELSE @module_id END 
		AND ISNULL(evt.event_id,'') = CASE WHEN @event_id = '' THEN ISNULL(evt.event_id,'') ELSE @event_id END 
	END
	ELSE
	BEGIN
		INSERT INTO #tmp_wg_task(task_id)
		SELECT @task_id
	END
	
	IF EXISTS(SELECT 1 FROM #tmp_wg_task tmp
	INNER JOIN workflow_schedule_task wst ON wst.id = tmp.task_id AND wst.workflow_id_type = 1 AND system_defined = 2)
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_mod_eve') IS NOT NULL
			DROP TABLE #tmp_mod_eve
		CREATE TABLE #tmp_mod_eve (workflow_id INT, task_id INT)

		INSERT INTO #tmp_mod_eve (workflow_id, task_id)	
		SELECT wst.workflow_id, wst.id FROM #tmp_wg_task tmp
		INNER JOIN workflow_schedule_task wst ON wst.id = tmp.task_id AND wst.workflow_id_type = 1 AND system_defined = 2

		INSERT INTO #tmp_wg_task(task_id, parent_id)
		SELECT wst_r.id,tmp.task_id FROM workflow_schedule_task wst
		INNER JOIN workflow_schedule_task wst1 ON wst.parent = wst1.id AND wst.workflow_id_type = 1
		INNER JOIN #tmp_mod_eve tmp ON tmp.workflow_id = wst.workflow_id AND ISNULL(wst1.system_defined,0) = 2
		INNER JOIN workflow_schedule_task wst_r ON wst_r.parent = wst.id

		INSERT INTO #tmp_wg_task(task_id)
		SELECT wst_m.id FROM workflow_schedule_task wst
		INNER JOIN workflow_schedule_task wst1 ON wst.parent = wst1.id AND wst.workflow_id_type = 1
		INNER JOIN #tmp_mod_eve tmp ON tmp.workflow_id = wst.workflow_id AND ISNULL(wst1.system_defined,0) = 2
		INNER JOIN workflow_schedule_task wst_r ON wst_r.parent = wst.id
		INNER JOIN workflow_schedule_task wst_m ON wst_m.parent = wst_r.id

		INSERT INTO #tmp_wg_task(task_id)
		SELECT wst_a.id FROM workflow_schedule_task wst
		INNER JOIN workflow_schedule_task wst1 ON wst.parent = wst1.id AND wst.workflow_id_type = 1
		INNER JOIN #tmp_mod_eve tmp ON tmp.workflow_id = wst.workflow_id AND ISNULL(wst1.system_defined,0) = 2
		INNER JOIN workflow_schedule_task wst_r ON wst_r.parent = wst.id
		INNER JOIN workflow_schedule_task wst_m ON wst_m.parent = wst_r.id
		INNER JOIN workflow_schedule_task wst_a ON wst_a.parent = wst_m.id
	END 

	SET @json_data = ''
	SET @json_link = ''

	DECLARE @d_id INT, @text NVARCHAR(500),@start_date DATETIME, @duration INT, @progress INT, @sort_order INT, @parent INT, @workflow_id_type INT

	DECLARE @total_count INT
	SELECT @total_count = COUNT(id) FROM workflow_schedule_task wst	INNER JOIN #tmp_wg_task tmp ON wst.id = tmp.task_id WHERE duration IS NOT NULL
	DECLARE @count INT = 1

	DECLARE data_cursor CURSOR FOR 
	SELECT id, [text], [start_date], duration, progress, sort_order, ISNULL(tmp.parent_id,parent), workflow_id_type
	FROM workflow_schedule_task wst
	INNER JOIN #tmp_wg_task tmp ON wst.id = tmp.task_id
	WHERE duration IS NOT NULL
	ORDER BY workflow_id_type, sort_order, create_ts

	
	OPEN data_cursor 
	FETCH NEXT FROM data_cursor 
	INTO @d_id, @text,@start_date,@duration,@progress,@sort_order,@parent,@workflow_id_type

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ud_text = NULL
		SET @ud_value1 = NULL
		SET	@ud_value2 = NULL
		SET	@ud_value3 = NULL
		SET @ud_value4 = NULL
		SET @ud_value5 = NULL
		SET @ud_value6 = NULL
		SET @ud_value7 = NULL

		SET @json_data = @json_data + '{"id":' + CAST(@d_id AS NVARCHAR) + ', "duration":' + CAST(@duration AS NVARCHAR) + ', "start_date":"' + CONVERT(NVARCHAR(12),CONVERT(DATETIME,@start_date,110),105) + '", "order":' + CAST(1 AS NVARCHAR)
		
		IF @workflow_id_type = 0
		BEGIN
			SELECT @ud_value1 = system_defined
			FROM workflow_schedule_task wst
			WHERE wst.id = @d_id

			SET @json_data = @json_data + ',"open":true, "color": "#b8b894", "text":"' + ISNULL(@text, 'Workflow Group') + '", "ud_value1":"' + ISNULL(@ud_value1,'0') + '"' 
		END
		ELSE IF @workflow_id_type = 1
		BEGIN
			SELECT	@ud_value1 = me.module_events_id,
					@ud_value2 = me.modules_id,
					@ud_value3 = me.event_id, 
					@ud_value4 = me.rule_table_id,
					@ud_text = me.workflow_name, 
					@ud_value5 = CASE WHEN wst.system_defined = 2 THEN 't' ELSE 'w' END,
					@ud_value6 = ISNULL(me.is_active, 'y'),
					@ud_value7 =  me.eod_as_of_date
			FROM workflow_schedule_task wst
			LEFT JOIN module_events me ON me.module_events_id = wst.workflow_id  AND wst.workflow_id_type = 1
			WHERE wst.id = @d_id

			SET @json_data = @json_data + ',"open":false,"color": "#65c16f", "text":"' + ISNULL(@ud_text, ISNULL(@text, 'Workflow')) + '", "parent":' + CAST(@parent AS NVARCHAR) + ', "ud_value1":"' + ISNULL(@ud_value1, '') + '", "ud_value2":"' + ISNULL(@ud_value2,'') + '", "ud_value3":"' + ISNULL(@ud_value3,'') + '", "ud_value4":"' + ISNULL(@ud_value4,'') + '", "ud_value5":"' + ISNULL(@ud_value5,'') + '", "ud_value6":"' + ISNULL(@ud_value6,'') + '", "ud_value7":"' + ISNULL(@ud_value7,'') + '"' 
		END
		ELSE IF @workflow_id_type = 2
		BEGIN
			SELECT	@ud_value1 = et.event_trigger_id,
					@ud_value2 = et.alert_id,
					@ud_text = asq.alert_sql_name,
					@ud_value3= ISNULL(et.initial_event, 'n'),
					@ud_value4= ISNULL(et.manual_step, 'n'),
					@ud_value5 = ISNULL(et.is_disable, 'n'),
					@ud_value6 = et.report_paramset_id,
					@ud_value7 = et.report_filters	
			FROM workflow_schedule_task wst
			LEFT JOIN event_trigger et ON et.event_trigger_id = wst.workflow_id AND wst.workflow_id_type = 2
			LEFT JOIN alert_sql asq ON et.alert_id = asq.alert_sql_id
			WHERE wst.id = @d_id
			
			SET @json_data = @json_data + ',"open":true, "text":"' + ISNULL(@ud_text, ISNULL(@text, 'Event')) + '", "ud_value1":"' + ISNULL(@ud_value1, '') + '", "ud_value2":"' + ISNULL(@ud_value2,'') + '", "ud_value3":"' + ISNULL(@ud_value3,'') + '", "ud_value4":"' + ISNULL(@ud_value4,'') + '", "ud_value5":"' + ISNULL(@ud_value5,'') + '", "ud_value6":"' + ISNULL(@ud_value6,'') + '", "ud_value7":"' + ISNULL(@ud_value7,'') + '", "parent":' + CAST(@parent AS NVARCHAR) + ''
		END
		ELSE IF @workflow_id_type = 3
		BEGIN
			SELECT	@ud_text = wem.event_message_name,
					@ud_value1 = wem.event_message_id,
					@ud_value2 = ISNULL(wem.automatic_proceed, 'n')	
			FROM workflow_schedule_task wst
			LEFT JOIN workflow_event_message wem ON wst.workflow_id = wem.event_message_id AND wst.workflow_id_type = 3
			WHERE wst.id = @d_id

			SET @json_data = @json_data + ',"open":true, "text":"' + ISNULL(@ud_text, ISNULL(@text, 'Message')) + '", "ud_value1":"' + ISNULL(@ud_value1, '') + '", "ud_value2":"' + ISNULL(@ud_value2, '') + '", "parent":' + CAST(@parent AS NVARCHAR) + ', "color":"#9999ff"'
		END
		ELSE IF @workflow_id_type = 4
		BEGIN
			SELECT @ud_value1 = wea.alert_id FROM workflow_schedule_task wst
			INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id AND wea.status_id = 729
			WHERE wst.id = @d_id
			SELECT @ud_value2 = wea.alert_id FROM workflow_schedule_task wst
			INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id AND wea.status_id = 726
			WHERE wst.id = @d_id
			SELECT @ud_value3 = wea.alert_id FROM workflow_schedule_task wst
			INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id AND wea.status_id = 728
			WHERE wst.id = @d_id
			SELECT @ud_value4 = wea.alert_id,
				   @ud_value5 = wea.threshold_days	
			 FROM workflow_schedule_task wst
			INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id AND wea.status_id = 733
			WHERE wst.id = @d_id
			SELECT @ud_value6 = wea.alert_id FROM workflow_schedule_task wst
			INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id AND wea.status_id = 735
			WHERE wst.id = @d_id
			SELECT @ud_value7 = wea.alert_id FROM workflow_schedule_task wst
			INNER JOIN workflow_event_action wea ON wst.workflow_id = wea.event_message_id AND wea.status_id = 736
			WHERE wst.id = @d_id

			SET @json_data = @json_data + ',"open":true, "text":"' + ISNULL(@ud_text, ISNULL(@text, 'Action')) + '", "parent":' + CAST(@parent AS NVARCHAR) + ', "ud_value1":"' + ISNULL(@ud_value1, '') + '", "ud_value2":"' + ISNULL(@ud_value2,'') + '", "ud_value3":"' + ISNULL(@ud_value3,'') + '", "ud_value4":"' + ISNULL(@ud_value4,'') + '", "ud_value5":"' + ISNULL(@ud_value5,'') + '", "ud_value6":"' + ISNULL(@ud_value6,'') + '", "ud_value7":"' + ISNULL(@ud_value7,'') + '"'
		END
		
		IF @count = @total_count
		BEGIN
			SET @json_data = @json_data + '}'
		END
		ELSE 
		BEGIn
			SET @json_data = @json_data + '},'
		END

		SET @count = @count + 1
		FETCH NEXT FROM data_cursor 
		INTO @d_id, @text,@start_date,@duration,@progress,@sort_order,@parent,@workflow_id_type
	END 
	CLOSE data_cursor;
	DEALLOCATE data_cursor;

	IF OBJECT_ID('tempdb..#tmp_link_json') IS NOT NULL
    DROP TABLE #tmp_link_json

	SELECT '{"id":' + CAST(id AS NVARCHAR) + 
			', "source":' + CAST(source AS NVARCHAR) + 
			', "color":"' + CASE WHEN action_type = 729 OR action_type = 735 THEN 'green' WHEN action_type = 726 OR action_type = 736 THEN 'red' WHEN action_type = 728 THEN 'blue' WHEN action_type = 733 THEN 'black' ELSE 'orange' END + '"' + 
			', "target":' + CAST([target] AS NVARCHAR) + 
			', "type":"' + CAST([type] AS NVARCHAR) + '"}' AS [link_json]
	INTO #tmp_link_json
	FROM workflow_schedule_link wsl 
	INNER JOIN #tmp_wg_task twt ON wsl.source = twt.task_id OR wsl.target = twt.task_id

	SELECT @json_link = STUFF((SELECT ',' + link_json
			  FROM #tmp_link_json
			  FOR XML PATH('')), 1, 1, '')
	
	SET @final_json = '{"data":[' + ISNULL(@json_data, '') + '],"links":[' + ISNULL(@json_link, '') + ']}'
	--SET @final_json = '{"data":[' + @json_data + ']}'
	SELECT @final_json
END

/*
-- Insert the workflow task
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		INSERT INTO workflow_schedule_task (text, start_date, duration, progress, sort_order, parent, workflow_id_type)
		SELECT 'New', @task_date, @task_duration, 1, 1, NULLIF(@task_parent, 0),@task_level
		
		DECLARE @new_task_id INT
		SET @new_task_id = SCOPE_IDENTITY()

		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Success',
             @new_task_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Fail',
             ''
	END CATCH
END
*/

-- Delete the workflow task
ELSE IF @flag = 'd'
BEGIN
	DECLARE @error_msg NVARCHAR(1000) = 'Fail'
	BEGIN TRY
	BEGIN TRAN
		DECLARE @task_workflow_id INT
		DECLARE @has_template INT
		SELECT	@task_workflow_id = workflow_id,
				@has_template = system_defined
		FROM workflow_schedule_task 
		WHERE id = @task_id

		IF OBJECT_ID('tempdb..#tmp_delete') IS NOT NULL
			DROP TABLE #tmp_delete
		CREATE TABLE #tmp_delete (task_id INT)

		IF OBJECT_ID('tempdb..#task_list') IS NOT NULL
			DROP TABLE #task_list
		CREATE TABLE #task_list (workflow_id INT)
		
		INSERT INTO #tmp_delete(task_id)
		SELECT @task_id

		IF @task_level = 4
		BEGIN
			DELETE FROM workflow_event_action
			WHERE event_message_id = @task_workflow_id
		END	
		ELSE IF @task_level = 3
		BEGIN
			INSERT INTO #tmp_delete(task_id)
			SELECT w2.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			WHERE w1.id = @task_id

			DELETE FROM workflow_event_action
			WHERE event_message_id = @task_workflow_id

			DELETE weme 
			FROM workflow_event_message_email weme
			INNER JOIN workflow_event_message_details wedd
				ON wedd.message_detail_id = weme.message_detail_id
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			WHERE wed.event_message_id = @task_workflow_id

			DELETE wedd FROM workflow_event_message_details wedd
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			WHERE wed.event_message_id = @task_workflow_id

			DELETE wed FROM workflow_event_message_documents wed
			WHERE wed.event_message_id = @task_workflow_id

			DELETE weur FROM workflow_event_user_role weur
			WHERE weur.event_message_id = @task_workflow_id

			DELETE wa FROM workflow_activities wa
			WHERE wa.event_message_id = @task_workflow_id

			IF EXISTS (SELECT 1 FROM workflow_event_message wem
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id AND et.alert_id = -2 AND wem.event_message_id = @task_workflow_id)
			BEGIN
				DECLARE @non_alert_message INT = NULL
				SELECT @non_alert_message = et.event_trigger_id FROM workflow_event_message wem
				INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id AND et.alert_id = -2 AND wem.event_message_id = @task_workflow_id

			END

			DELETE ar FROM alert_reports ar 
			WHERE ar.event_message_id = @task_workflow_id

			DELETE FROM workflow_event_message
			WHERE event_message_id = @task_workflow_id

			IF (@non_alert_message IS NOT NULL)
			BEGIN
				DELETE FROM workflow_event_action
				WHERE alert_id = @non_alert_message

				DELETE wea FROM workflow_event_action wea
				INNER JOIN workflow_event_message wem ON wea.event_message_id = wem.event_message_id
				WHERE wem.event_trigger_id = @non_alert_message

				DELETE weme 
				FROM workflow_event_message_email weme
				INNER JOIN workflow_event_message_details wedd
					ON wedd.message_detail_id = weme.message_detail_id
				INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
				INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
				WHERE wem.event_trigger_id = @non_alert_message

				DELETE wedd FROM workflow_event_message_details wedd
				INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
				INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
				WHERE wem.event_trigger_id = @non_alert_message
				
				DELETE wed FROM workflow_event_message_documents wed
				INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
				WHERE wem.event_trigger_id = @non_alert_message
				
				DELETE weur FROM workflow_event_user_role weur
				INNER JOIN workflow_event_message wem ON weur.event_message_id = wem.event_message_id
				WHERE wem.event_trigger_id = @non_alert_message

				DELETE waa FROM workflow_activities_audit waa
				WHERE waa.workflow_trigger_id = @non_alert_message

				DELETE wa FROM workflow_activities wa
				WHERE wa.workflow_trigger_id = @non_alert_message

				DELETE FROM workflow_event_message
				WHERE event_trigger_id = @non_alert_message
				
				DELETE FROM event_trigger WHERE event_trigger_id = @non_alert_message
			END
		END	
		ELSE IF @task_level = 2
		BEGIN
			INSERT INTO #tmp_delete(task_id)
			SELECT w3.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
			WHERE w1.id = @task_id

			INSERT INTO #tmp_delete(task_id)
			SELECT w2.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			WHERE w1.id = @task_id

			DELETE ar FROM alert_reports ar 
			INNER JOIN workflow_event_message wem ON wem.event_message_id = ar.event_message_id
			WHERE wem.event_trigger_id = @task_workflow_id

			DELETE weme 
			FROM workflow_event_message_email weme
			INNER JOIN workflow_event_message_details wedd
				ON wedd.message_detail_id = weme.message_detail_id
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			WHERE wem.event_trigger_id = @task_workflow_id

			DELETE wedd FROM workflow_event_message_details wedd
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			WHERE wem.event_trigger_id = @task_workflow_id

			DELETE wed FROM workflow_event_message_documents wed
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			WHERE wem.event_trigger_id = @task_workflow_id

			DELETE weur FROM workflow_event_user_role weur
			INNER JOIN workflow_event_message wem ON wem.event_message_id = weur.event_message_id
			WHERE wem.event_trigger_id = @task_workflow_id

			DELETE wea FROM workflow_event_action wea
			INNER JOIN workflow_event_message wem ON wea.event_message_id = wem.event_message_id
			WHERE wem.event_trigger_id = @task_workflow_id

			DELETE wa FROM workflow_activities wa
			INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
			WHERE event_trigger_id = @task_workflow_id

			DELETE FROM workflow_event_message 
			WHERE event_trigger_id = @task_workflow_id

			DELETE waa FROM workflow_activities_audit waa 
			WHERE waa.workflow_trigger_id = @task_workflow_id

			DELETE FROM event_trigger
			WHERE event_trigger_id = @task_workflow_id
		END	
		ELSE IF @task_level = 1
		BEGIN
			IF @has_template = 2
			BEGIN
				UPDATE workflow_schedule_task
				SET workflow_id = ''
				WHERE id = @task_id

				DELETE wlwc FROM workflow_link_where_clause wlwc
				INNER JOIN workflow_link wl ON wlwc.workflow_link_id = wl.workflow_link_id
				WHERE workflow_schedule_task_id = @task_id

				DELETE FROM workflow_link
				WHERE workflow_schedule_task_id = @task_id
			END
			ELSE
			BEGIN
			
			INSERT INTO #tmp_delete(task_id)
			SELECT w4.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
			INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
			WHERE w1.id = @task_id

			INSERT INTO #tmp_delete(task_id)
			SELECT w3.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
			WHERE w1.id = @task_id

			INSERT INTO #tmp_delete(task_id)
			SELECT w2.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			WHERE w1.id = @task_id

			DELETE ar FROM alert_reports ar 
			INNER JOIN workflow_event_message wem ON wem.event_message_id = ar.event_message_id
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE weme 
			FROM workflow_event_message_email weme
			INNER JOIN workflow_event_message_details wedd
				ON wedd.message_detail_id = weme.message_detail_id
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE wedd FROM workflow_event_message_details wedd
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE wed FROM workflow_event_message_documents wed
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE weur FROM workflow_event_user_role weur
			INNER JOIN workflow_event_message wem ON wem.event_message_id = weur.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE wea FROM workflow_event_action wea
			INNER JOIN workflow_event_message wem ON wea.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE wa FROM workflow_activities wa
			INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE wem FROM workflow_event_message wem 
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE waa FROM workflow_activities_audit waa 
			INNER JOIN event_trigger et ON waa.workflow_trigger_id = et.event_trigger_id
			WHERE et.modules_event_id = @task_workflow_id

			DELETE FROM event_trigger
			WHERE modules_event_id = @task_workflow_id

			DELETE FROM workflow_where_clause
			WHERE module_events_id = @task_workflow_id
	
			DELETE wlwc FROM workflow_link_where_clause wlwc
			INNER JOIN workflow_link wl ON wlwc.workflow_link_id = wl.workflow_link_id
			INNER JOIN workflow_schedule_task wst ON wl.workflow_schedule_task_id = wst.id AND wst.workflow_id_type = 1
			INNER JOIN #tmp_delete td ON wst.id = td.task_id

			DELETE wl FROM workflow_link wl
			INNER JOIN workflow_schedule_task wst ON wl.workflow_schedule_task_id = wst.id AND wst.workflow_id_type = 1
			INNER JOIN #tmp_delete td ON wst.id = td.task_id

			DELETE FROM module_events
			WHERE module_events_id = @task_workflow_id

			END
		END	
		ELSE IF @task_level = 0
		BEGIN
			INSERT INTO #tmp_delete(task_id)
			SELECT w5.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
			INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
			INNER JOIN workflow_schedule_task w5 ON w4.id = w5.parent
			WHERE w1.id = @task_id

			INSERT INTO #tmp_delete(task_id)
			SELECT w4.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
			INNER JOIN workflow_schedule_task w4 ON w3.id = w4.parent
			WHERE w1.id = @task_id

			INSERT INTO #tmp_delete(task_id)
			SELECT w3.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			INNER JOIN workflow_schedule_task w3 ON w2.id = w3.parent
			WHERE w1.id = @task_id

			INSERT INTO #tmp_delete(task_id)
			SELECT w2.id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			WHERE w1.id = @task_id	

			INSERT INTO #task_list(workflow_id)
			SELECT w2.workflow_id FROM workflow_schedule_task w1
			INNER JOIN workflow_schedule_task w2 On w1.id = w2.parent
			WHERE w1.id = @task_id	

			DELETE ar FROM alert_reports ar 
			INNER JOIN workflow_event_message wem ON wem.event_message_id = ar.event_message_id
			INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE weme 
			FROM workflow_event_message_email weme
			INNER JOIN workflow_event_message_details wedd
				ON wedd.message_detail_id = weme.message_detail_id
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE wedd FROM workflow_event_message_details wedd
			INNER JOIN workflow_event_message_documents wed ON wedd.event_message_document_id = wed.message_document_id
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id
			
			DELETE wed FROM workflow_event_message_documents wed
			INNER JOIN workflow_event_message wem ON wed.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE weur FROM workflow_event_user_role weur
			INNER JOIN workflow_event_message wem ON wem.event_message_id = weur.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE wea FROM workflow_event_action wea
			INNER JOIN workflow_event_message wem ON wea.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE wa FROM workflow_activities wa
			INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE wem FROM workflow_event_message wem 
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE waa FROM workflow_activities_audit waa 
			INNER JOIN event_trigger et ON waa.workflow_trigger_id = et.event_trigger_id
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE et FROM event_trigger et
			INNER JOIN #task_list tl ON tl.workflow_id = et.modules_event_id

			DELETE wwc FROM workflow_where_clause wwc
			INNER JOIN #task_list tl ON tl.workflow_id = wwc.module_events_id

			DELETE wlwc FROM workflow_link_where_clause wlwc
			INNER JOIN workflow_link wl ON wlwc.workflow_link_id = wl.workflow_link_id
			INNER JOIN workflow_schedule_task wst ON wl.workflow_schedule_task_id = wst.id AND wst.workflow_id_type = 1
			INNER JOIN #tmp_delete td ON wst.id = td.task_id

			DELETE wl FROM workflow_link wl
			INNER JOIN workflow_schedule_task wst ON wl.workflow_schedule_task_id = wst.id AND wst.workflow_id_type = 1
			INNER JOIN #tmp_delete td ON wst.id = td.task_id

			DELETE me FROM module_events me
			INNER JOIN #task_list tl ON tl.workflow_id = me.module_events_id
		END

		DELETE wwc FROM workflow_where_clause wwc
		INNER JOIN #tmp_delete td ON wwc.workflow_schedule_task_id = td.task_id

		IF EXISTS(SELECT 1 FROM workflow_schedule_task wst
		INNER JOIN #tmp_delete td ON wst.id = td.task_id
		INNER JOIN workflow_link wl ON wl.workflow_schedule_task_id = wst.id)
		BEGIN
			SET @error_msg = 'The workflow has been used as link. Please delete the link first.'
		END

		DELETE wsl FROM workflow_schedule_link wsl
		INNER JOIN #tmp_delete td ON wsl.source = td.task_id

		DELETE wsl FROM workflow_schedule_link wsl
		INNER JOIN #tmp_delete td ON wsl.[target] = td.task_id
		
		DELETE wst FROM workflow_schedule_task wst
		INNER JOIN #tmp_delete td ON wst.id = td.task_id

	COMMIT TRAN
		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Changes have been saved successfully.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Error',
             @error_msg,
             ''
	END CATCH
END

-- Update the workflow task
ELSE IF @flag = 'u'
BEGIN
	DECLARE @min_start_date DATETIME
	UPDATE workflow_schedule_task
	SET start_date = @task_date,
		duration = @task_duration
	WHERE id = @task_id

	SELECT @min_start_date = MIN(start_date) FROM workflow_schedule_task 
	WHERE parent = (SELECT parent FROM workflow_schedule_task WHERE id = @task_id) 
	AND workflow_id_type = 2

	UPDATE workflow_schedule_task
	SET start_date = @min_start_date
	WHERE id = (SELECT parent FROM workflow_schedule_task WHERE id = @task_id)
	AND workflow_id_type = 1 AND @min_start_date IS NOT NULL

END

-- Insert the workflow link
ELSE IF @flag = 'l'
BEGIN
	BEGIN TRY
		INSERT INTO workflow_schedule_link (source, target, type)
		SELECT @link_source, @link_target, @link_type
		
		DECLARE @new_link_id INT
		SET @new_link_id = SCOPE_IDENTITY()

		IF OBJECT_ID('tempdb..#tmp_ins_link') IS NOT NULL
			DROP TABLE #tmp_ins_link
		CREATE TABLE #tmp_ins_link
		(s_workflow_id INT, s_workflow_id_type INT, t_workflow_id INT, t_workflow_id_type INT)

		INSERT INTO #tmp_ins_link (s_workflow_id, s_workflow_id_type, t_workflow_id, t_workflow_id_type)
		SELECT s.workflow_id, s.workflow_id_type, t.workflow_id, t.workflow_id_type
		FROM workflow_schedule_link wst
		LEFT JOIN workflow_schedule_task s ON wst.source = s.id
		LEFT JOIN workflow_schedule_task t ON wst.[target] = t.id
		WHERE wst.id = @new_link_id

		UPDATE wem
		SET event_trigger_id = s_workflow_id
		FROM workflow_event_message wem
		INNER JOIN #tmp_ins_link tdl ON wem.event_message_id = tdl.t_workflow_id
		WHERE tdl.s_workflow_id_type = 2

		UPDATE wem
		SET next_module_events_id = me.module_events_id
		FROM workflow_event_message wem
		INNER JOIN #tmp_ins_link tdl ON wem.event_message_id = tdl.s_workflow_id
		INNER JOIN module_events me ON me.module_events_id = tdl.t_workflow_id
		WHERE tdl.s_workflow_id_type = 3

		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Success',
             @new_link_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Fail',
             ''
	END CATCH
END

-- Delete the workflow link
ELSE IF @flag = 'k'
BEGIN
	BEGIN TRY
		
		IF OBJECT_ID('tempdb..#tmp_del_link') IS NOT NULL
			DROP TABLE #tmp_del_link
		CREATE TABLE #tmp_del_link
		(s_workflow_id INT, s_workflow_id_type INT, t_workflow_id INT, t_workflow_id_type INT, action_type INT)

		INSERT INTO #tmp_del_link (s_workflow_id, s_workflow_id_type, t_workflow_id, t_workflow_id_type, action_type )
		SELECT s.workflow_id, s.workflow_id_type, t.workflow_id, t.workflow_id_type, wst.[action_type] 
		FROM workflow_schedule_link wst
		LEFT JOIN workflow_schedule_task s ON wst.source = s.id
		LEFT JOIN workflow_schedule_task t ON wst.[target] = t.id
		WHERE wst.id = @link_id

		UPDATE wem
		SET event_trigger_id = NULL
		FROM workflow_event_message wem
		INNER JOIN #tmp_del_link tdl ON wem.event_message_id = tdl.t_workflow_id
		WHERE tdl.s_workflow_id_type = 2
		
		UPDATE wem
		SET next_module_events_id = NULL
		FROM workflow_event_message wem
		INNER JOIN #tmp_del_link tdl ON wem.event_message_id = tdl.s_workflow_id
		WHERE tdl.s_workflow_id_type = 3

		/*
		UPDATE wea
		SET event_message_id = NULL
		FROM workflow_event_action wea
		INNER JOIN #tmp_del_link tdl ON wea.event_message_id = tdl.t_workflow_id
		WHERE tdl.s_workflow_id_type = 2
		*/

		DELETE wea FROM workflow_event_action wea
		INNER JOIN #tmp_del_link tdl ON wea.event_message_id = tdl.s_workflow_id AND wea.status_id = tdl.action_type
		WHERE tdl.s_workflow_id_type = 4
		
		DELETE FROM workflow_schedule_link
		WHERE id = @link_id

		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Success',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Fail',
             ''
	END CATCH
END

-- Insert/Update the workflow
ELSE IF @flag = 'w'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_workflow') IS NOT NULL
			DROP TABLE #tmp_workflow
		
		SELECT	modules_event_id[modules_event_id],
				workflow_name	[workflow_name],
				module_id		[module_id],
				event_id		[event_id],
				task_id			[task_id],
				rule_table_id	[rule_table_id],
				template_workflow [template_workflow],
				is_active		[is_active],
				eod_as_of_date [eod_as_of_date]
		INTO #tmp_workflow
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			modules_event_id	INT,
			workflow_name		NVARCHAR(100),
			module_id			INT,
			event_id			NVARCHAR(2000),
			task_id				INT,
			rule_table_id		INT,
			template_workflow	INT,
			is_active			NCHAR(1),
			eod_as_of_date		NVARCHAR(1000)
		)

		IF OBJECT_ID('tempdb..#tmp_task') IS NOT NULL
			DROP TABLE #tmp_task
		
		SELECT	[start_date]	[start_date],
				duration		[duration],
				workflow_id_type[workflow_id_type],
				parent_id		[parent_id],
				task_id			[task_id]
		INTO #tmp_task
		FROM OPENXML(@idoc, '/Root/TaskXML', 1)
		WITH (
			[start_date]		DATETIME,
			duration			INT,
			workflow_id_type	INT,
			parent_id			INT,
			task_id				INT
		)

		IF OBJECT_ID('tempdb..#where_clause') IS NOT NULL
			DROP TABLE #where_clause
		
		SELECT workflow_where_clause_id		[workflow_where_clause_id],
				table_id		[table_id],
				column_id		[column_id],
				operator_id		[operator_id],
				column_value	[column_value],
				column_value2	[column_value2],
				sequence_no		[sequence_no],
				clause_type		[clause_type],
				task_id			[task_id]
		INTO #where_clause
		FROM OPENXML(@idoc, '/Root/WhereClause', 1)
		WITH (
			workflow_where_clause_id		INT,
			table_id		INT,
			column_id		INT,
			operator_id		INT,
			column_value	NVARCHAR(100),
			column_value2	NVARCHAR(100),
			sequence_no		INT,
			clause_type		INT,
			task_id			INT
		)

		IF OBJECT_ID('tempdb..#workflow_link') IS NOT NULL
			DROP TABLE #workflow_link
		
		SELECT	workflow_link_id	[workflow_link_id],
				[description]		[description],
				task_id				[task_id],
				modules_event_id	[modules_event_id],
				link_tab_id			[link_tab_id]
		INTO #workflow_link
		FROM OPENXML(@idoc, '/Root/WorkflowLink', 1)
		WITH (
			workflow_link_id		INT,
			[description]			NVARCHAR(500),
			task_id					INT,
			modules_event_id		INT,
			link_tab_id				NVARCHAR(100)
		)

		IF OBJECT_ID('tempdb..#link_where_clause') IS NOT NULL
			DROP TABLE #link_where_clause
		
		SELECT workflow_Link_where_clause_id		[workflow_Link_where_clause_id],
				table_id		[table_id],
				column_id		[column_id],
				operator_id		[operator_id],
				column_value	[column_value],
				column_value2	[column_value2],
				sequence_no		[sequence_no],
				clause_type		[clause_type],
				workflow_link_id	[workflow_link_id],
				link_tab_id		[link_tab_id]
		INTO #link_where_clause
		FROM OPENXML(@idoc, '/Root/LinkWhereClause', 1)
		WITH (
			workflow_Link_where_clause_id		INT,
			table_id		INT,
			column_id		INT,
			operator_id		INT,
			column_value	NVARCHAR(100),
			column_value2	NVARCHAR(100),
			sequence_no		INT,
			clause_type		INT,
			workflow_link_id	INT,
			link_tab_id			NVARCHAR(100)
		)

		DECLARE @new_id INT = NULL
		DECLARE @template_used INT = NULL
		DECLARE @ids_string NVARCHAR(100) = NULL
		IF EXISTS (SELECT * FROM #tmp_workflow WHERE modules_event_id = 0)
		BEGIN
			INSERT INTO workflow_schedule_task ([start_date], duration, workflow_id_type, parent, sort_order)
			SELECT [start_date], duration, workflow_id_type, NULLIF(parent_id, '0'), s.[new_sort_order] FROM  #tmp_task tmp
			CROSS APPLY (
				SELECT ISNULL(MAX(sort_order) + 1,1) [new_sort_order] FROM workflow_schedule_task wst
				WHERE wst.parent = tmp.parent_id
			) s

			DECLARE @task_new_id INT = SCOPE_IDENTITY()

			IF EXISTS (SELECT 1 FROM #tmp_workflow WHERE template_workflow > 0)
			BEGIN
				SELECT @new_id = template_workflow FROM #tmp_workflow
				SET @template_used = 2
			END
			ELSE 
			BEGIN
				INSERT INTO module_events (workflow_name, modules_id, event_id, rule_table_id, is_active,eod_as_of_date)
				SELECT workflow_name, module_id, event_id, NULLIF(rule_table_id,0), ISNULL(is_active, 'n'),NULLIF(eod_as_of_date,'') FROM #tmp_workflow WHERE modules_event_id = 0

				SET @new_id = SCOPE_IDENTITY()
			END

			UPDATE wst
			SET wst.workflow_id = @new_id,
				wst.system_defined = @template_used
			FROM workflow_schedule_task wst
			WHERE id = @task_new_id

			INSERT INTO workflow_where_clause (workflow_schedule_task_id, clause_type, data_source_column_id, operator_id, column_value, table_id, sequence_no, second_value)
			SELECT @task_new_id, clause_type, column_id, operator_id, column_value, table_id, sequence_no, column_value2 FROM #where_clause
		END
		ELSE 
		BEGIN
			IF EXISTS (SELECT 1 FROM #tmp_workflow WHERE template_workflow > 0)
			BEGIN
				SELECT @new_id = template_workflow FROM #tmp_workflow
				SET @template_used = 2

				UPDATE wst
				SET workflow_id = @new_id,
					system_defined = @template_used
				FROM workflow_schedule_task wst
				INNER JOIN #tmp_task tmp ON wst.id = tmp.task_id
			END
			ELSE 
			BEGIN
				UPDATE me
				SET me.modules_id = tw.module_id,
					me.workflow_name = tw.workflow_name,
					me.event_id = tw.event_id,
					me.rule_table_id = NULLIF(tw.rule_table_id,0),
					me.is_active = ISNULL(tw.is_active, 'n'),
					me.eod_as_of_date = NULLIF(tw.eod_as_of_date,'')
				FROM module_events me
				INNER JOIN #tmp_workflow tw ON me.module_events_id = tw.modules_event_id
			END
			
			DELETE wwc FROM workflow_where_clause wwc
			INNER JOIN #tmp_workflow tmp ON tmp.modules_event_id = wwc.module_events_id

			DELETE wwc FROM workflow_where_clause wwc
			INNER JOIN #tmp_task wc ON wwc.workflow_schedule_task_id = wc.task_id

			INSERT INTO workflow_where_clause (workflow_schedule_task_id, clause_type, data_source_column_id, operator_id, column_value, table_id, sequence_no, second_value)
			SELECT task_id, clause_type, column_id, operator_id, column_value, table_id, sequence_no, column_value2 FROM #where_clause

			SELECT @task_new_id = wst.id 
			FROM workflow_schedule_task wst
			INNER JOIN #tmp_task tmp ON wst.id = tmp.task_id

			DELETE wlwc FROM workflow_link_where_clause wlwc
			INNER JOIN workflow_link wl ON wlwc.workflow_link_id = wl.workflow_link_id
			INNER JOIN #tmp_task wc ON wl.workflow_schedule_task_id = wc.task_id

			DELETE wl FROM workflow_link wl
			INNER JOIN #tmp_task wc ON wl.workflow_schedule_task_id = wc.task_id
					
		END
		
		DECLARE @link_tab_id NVARCHAR(100), @new_workflow_link_id INT
		DECLARE workflow_link_cursor CURSOR FOR 
		SELECT link_tab_id
		FROM #workflow_link wst

			OPEN workflow_link_cursor 
			FETCH NEXT FROM workflow_link_cursor 
			INTO @link_tab_id

			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO workflow_link (workflow_schedule_task_id, modules_event_id,[description])
				SELECT @task_new_id, modules_event_id, [description] FROM #workflow_link
				WHERE link_tab_id = @link_tab_id

				SET @new_workflow_link_id = SCOPE_IDENTITY()

				INSERT INTO workflow_link_where_clause (workflow_link_id, clause_type, data_source_column_id, operator_id, column_value, table_id, sequence_no, second_value)
				SELECT @new_workflow_link_id, clause_type, column_id, operator_id, column_value, table_id, sequence_no, column_value2 FROM #link_where_clause
				WHERE link_tab_id = @link_tab_id

			FETCH NEXT FROM workflow_link_cursor 
			INTO @link_tab_id
		END 
		CLOSE workflow_link_cursor;
		DEALLOCATE workflow_link_cursor;
		SELECT @ids_string = CAST(@new_id AS NVARCHAR(20)) + ',' + CAST(@task_new_id AS NVARCHAR(20)) 
		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Changes has been saved successfully.',
			 @ids_string
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to save workflow',
             ''
	END CATCH
END

-- Insert/Update the rule
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_event') IS NOT NULL
			DROP TABLE #tmp_event
		
		SELECT	modules_event_id	[modules_event_id],
				alert_id			[alert_id],
				event_trigger_id	[event_trigger_id],
				initial_event		[initial_event],
				manual_step			[manual_step],
				is_disable			[is_disable],
				report_paramset_id	[report_paramset_id],
				report_filters		[report_filters]
		INTO #tmp_event
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			modules_event_id	INT,
			alert_id			INT,
			event_trigger_id	INT,
			initial_event		NCHAR(1),
			manual_step			NCHAR(1),
			is_disable			NCHAR(1),
			report_paramset_id	NVARCHAR(MAX),
			report_filters		INT
		)

		IF OBJECT_ID('tempdb..#tmp_event_task') IS NOT NULL
			DROP TABLE #tmp_event_task
		
		SELECT	[start_date]	[start_date],
				duration		[duration],
				workflow_id_type[workflow_id_type],
				parent_id		[parent_id]
		INTO #tmp_event_task
		FROM OPENXML(@idoc, '/Root/TaskXML', 1)
		WITH (
			[start_date]		DATETIME,
			duration			INT,
			workflow_id_type	INT,
			parent_id			INT
		)

		IF EXISTS (SELECT * FROM #tmp_event WHERE event_trigger_id = 0)
		BEGIN
			INSERT INTO workflow_schedule_task ([start_date], duration, workflow_id_type, parent, sort_order)
			SELECT [start_date], duration, workflow_id_type, parent_id, s.new_sort_order FROM #tmp_event_task tmp
			CROSS APPLY (
				SELECT ISNULL(MAX(sort_order) + 1,1) [new_sort_order] FROM workflow_schedule_task wst
				WHERE wst.parent = tmp.parent_id
			) s

			DECLARE @event_task_new_id INT = SCOPE_IDENTITY()

			--INSERT INTO workflow_schedule_link (source, [target], [type])
			--SELECT parent, id, 1 FROM workflow_schedule_task WHERE id = @event_task_new_id

			INSERT INTO event_trigger (modules_event_id, alert_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters)
			SELECT modules_event_id, alert_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters FROM #tmp_event WHERE event_trigger_id = 0

			DECLARE @event_new_id INT = SCOPE_IDENTITY()

			UPDATE wst
			SET wst.workflow_id = @event_new_id
			FROM workflow_schedule_task wst
			WHERE id = @event_task_new_id
		END
		ELSE 
		BEGIN
			UPDATE et
			SET et.modules_event_id = tw.modules_event_id,
				et.alert_id = tw.alert_id,
				et.initial_event = tw.initial_event,
				et.manual_step = tw.manual_step,
				et.is_disable = tw.is_disable,
				et.report_paramset_id = tw.report_paramset_id,
				et.report_filters = tw.report_filters
			FROM event_trigger et
			INNER JOIN #tmp_event tw ON et.event_trigger_id = tw.event_trigger_id
		END
		
		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Workflow has been successfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to save workflow',
             ''
	END CATCH
END

-- Insert/Update the action
ELSE IF @flag = 'a'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_action') IS NOT NULL
			DROP TABLE #tmp_action
		
		SELECT	status_id			[status_id],
				alert_id			[alert_id],
				event_message_id	[event_message_id],
				threshold_days		[threshold_days]
		INTO #tmp_action
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			status_id			INT,
			alert_id			INT,
			event_message_id	INT,
			threshold_days		INT
		)

		IF OBJECT_ID('tempdb..#tmp_action_task') IS NOT NULL
			DROP TABLE #tmp_action_task
		
		SELECT	[start_date]	[start_date],
				duration		[duration],
				workflow_id_type[workflow_id_type],
				parent_id		[parent_id],
				message_id		[message_id]
		INTO #tmp_action_task
		FROM OPENXML(@idoc, '/Root/TaskXML', 1)
		WITH (
			[start_date]		DATETIME,
			duration			INT,
			workflow_id_type	INT,
			parent_id			INT,
			message_id			INT
		)
		DECLARE @event_link_new_id INT

		DELETE wea 
		FROM workflow_event_action wea 
		INNER JOIN #tmp_action_task ta ON wea.event_message_id = ta.message_id

		DELETE wsl 
		FROM workflow_schedule_link wsl 
		INNER JOIN workflow_schedule_task wst ON (wsl.source = wst.id OR wsl.[target] = wst.id) AND wst.workflow_id_type = 4
		INNER JOIN #tmp_action_task ta ON wst.workflow_id = ta.message_id
		
		DECLARE @action_task_date DATETIME = NULL
		SELECT TOP(1) @action_task_date = wst.[start_date] FROM workflow_schedule_task wst
		INNER JOIN #tmp_action_task ta ON wst.workflow_id = ta.message_id AND wst.workflow_id_type = 4

		DELETE wst 
		FROM workflow_schedule_task wst
		INNER JOIN #tmp_action_task ta ON wst.workflow_id = ta.message_id AND wst.workflow_id_type = 4

		DECLARE @new_message_id INT = NULL
		DECLARE @trigger_task_id INT = NULL
		DECLARE @msg_task_id INT = NULL
		
		IF @trigger_id IS NOT NULL AND @trigger_id <> 0
		BEGIN
			DELETE wa FROM workflow_activities wa INNER JOIN #tmp_action_task tmp ON wa.event_message_id = tmp.message_id
			DELETE wem FROM workflow_event_message wem INNER JOIN #tmp_action_task tmp ON wem.event_message_id = tmp.message_id
			DELETE wst FROM workflow_schedule_task wst INNER JOIN #tmp_action_task tmp ON wst.workflow_id = tmp.message_id AND wst.workflow_id_type = 3

			INSERT INTO workflow_event_message (event_trigger_id, event_message_name, message, mult_approval_required, comment_required,
						approval_action_required, self_notify, notify_trader, automatic_proceed)
			SELECT @trigger_id, 'Default Message', 'Default Message', 'n', 'n', 'n', 'y','n', 'h'
			
			SET @new_message_id =  SCOPE_IDENTITY()
			SELECT @trigger_task_id = id FROM workflow_schedule_task WHERE workflow_id = @trigger_id AND workflow_id_type = 2
			
			INSERT INTO workflow_schedule_task ([start_date], duration, workflow_id_type, parent, workflow_id)
			SELECT '2015-01-05 00:00:00.000', 1, 3, @trigger_task_id , @new_message_id 

			SET @msg_task_id = SCOPE_IDENTITY()

			--INSERT INTO workflow_schedule_link (source, [target], [type])
			--SELECT @trigger_task_id, @msg_task_id, 0

			UPDATE #tmp_action_task
			SET message_id = @new_message_id,
				parent_id = @msg_task_id

			UPDATE #tmp_action
			SET event_message_id = @new_message_id
		END

		IF NOT EXISTS (SELECT 1 FROM #tmp_action_task tct 
		INNER JOIN workflow_event_action wea ON tct.message_id = wea.event_message_id)
		BEGIN
			INSERT INTO workflow_schedule_task ([start_date], duration, workflow_id_type, parent, workflow_id)
			SELECT ISNULL(@action_task_date,[start_date]), duration, workflow_id_type, parent_id, message_id FROM  #tmp_action_task

			SET @event_link_new_id = SCOPE_IDENTITY()

			INSERT INTO workflow_schedule_link (source, [target], [type])
			SELECT ISNULL(@trigger_task_id,parent), id, 0 FROM workflow_schedule_task WHERE id = @event_link_new_id
		END
		
		INSERT INTO workflow_event_action(event_message_id, alert_id, status_id, threshold_days)
		SELECT ta.event_message_id, ta.alert_id, ta.status_id, NULLIF(ta.threshold_days,0) FROM #tmp_action ta
		
		INSERT INTO workflow_schedule_link (source, [target], [type], [action_type])
		SELECT @event_link_new_id, wst.id, 2, ta.status_id FROM #tmp_action ta
		INNER JOIN workflow_schedule_task wst ON ta.alert_id = wst.workflow_id AND wst.workflow_id_type = 2

		INSERT INTO workflow_schedule_link (source, [target], [type], [action_type])
		SELECT @event_link_new_id, wst.id, 2, ta.status_id FROM #tmp_action ta
		INNER JOIN event_trigger et ON ta.alert_id = et.event_trigger_id AND et.alert_id = -1
		INNER JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
		INNER JOIN workflow_schedule_task wst ON wem.event_message_id = wst.workflow_id AND wst.workflow_id_type = 3
		
		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Workflow has been successfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to save workflow',
             ''
	END CATCH
END

-- To save approve/unapprove/completed from context menu
ELSE IF @flag = 'c'
BEGIN
	BEGIN TRY
		DECLARE @source_id INT
		DECLARE @dest_id INT
		DECLARE @dest_id_level INT

		SELECT	@source_id = s.workflow_id,
				@dest_id = d.workflow_id,
				@dest_id_level = d.workflow_id_type 
		FROM workflow_schedule_link wsc
		INNER JOIN workflow_schedule_task s ON wsc.source = s.id
		INNER JOIN workflow_schedule_task d ON wsc.target = d.id
		WHERE wsc.id = @link_id
		
		IF (@dest_id_level =  3)
		BEGIN
			SELECT @dest_id = et.event_trigger_id FROM workflow_event_message wem
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			WHERE wem.event_message_id = @dest_id	
		END	

		IF EXISTS (SELECT 1 FROM workflow_event_action WHERE event_message_id = @source_id and status_id = @action_type)
		BEGIN
			EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Fail',
             'Action already mapped.',
             ''
			 Return
		END

		IF EXISTS (SELECT 1 FROM workflow_schedule_link WHERE action_type IS NULL AND id = @link_id)
		BEGIN
			INSERT INTO workflow_event_action (event_message_id, status_id, alert_id)
			SELECT @source_id, @action_type, @dest_id
		END
		ELSE 
		BEGIN
			UPDATE workflow_event_action
			SET status_id = @action_type
			WHERE event_message_id = @source_id AND alert_id = @dest_id
		END

		UPDATE workflow_schedule_link
		SET action_type = @action_type
		WHERE id = @link_id

		EXEC spa_ErrorHandler 0,
				 'Setup Workflow',
				 'spa_workflow_schedule',
				 'Success',
				 'Workflow has been successfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to save workflow',
             ''
	END CATCH
END

-- Workflow Group
ELSE IF @flag = 'g'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_workflow_group_task') IS NOT NULL
			DROP TABLE #tmp_workflow_group_task
		
		SELECT	[start_date]		[start_date],
				duration			[duration],
				workflow_id_type	[workflow_id_type],
				parent_id			[parent_id],
				workflow_group_id	[workflow_group_id],
				workflow_group_name	[workflow_group_name],
				system_defined		[system_defined]
		INTO #tmp_workflow_group_task
		FROM OPENXML(@idoc, '/Root/TaskXML', 1)
		WITH (
			[start_date]		DATETIME,
			duration			INT,
			workflow_id_type	INT,
			parent_id			INT,
			workflow_group_id	INT,
			workflow_group_name	NVARCHAR(100),
			system_defined		INT
		)

		DECLARE @wg_task_id INT
		IF EXISTS (SELECT 1 FROM workflow_schedule_task wst 
					INNER JOIN #tmp_workflow_group_task tmp ON wst.[text] = tmp.workflow_group_name AND wst.workflow_id_type = 0 
					WHERE wst.id <> tmp.workflow_group_id
					)
		BEGIN
			EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Workflow Group Name already exists.',
             ''
			 return
		END

		IF EXISTS (SELECT * FROM #tmp_workflow_group_task WHERE workflow_group_id = 0)
		BEGIN
			INSERT INTO workflow_schedule_task ([start_date], duration, workflow_id_type, parent, [text], system_defined)
			SELECT [start_date], duration, workflow_id_type, NULLIF(parent_id, '0'), workflow_group_name, system_defined FROM  #tmp_workflow_group_task
			
			SET @wg_task_id = SCOPE_IDENTITY()
		END
		ELSE 
		BEGIN
			UPDATE wst
			SET wst.text = tw.workflow_group_name,
				wst.system_defined = tw.system_defined
			FROM workflow_schedule_task wst
			INNER JOIN #tmp_workflow_group_task tw ON wst.id = tw.workflow_group_id

			SELECT @wg_task_id = workflow_group_id FROM #tmp_workflow_group_task
		END
		
		EXEC spa_ErrorHandler 0,
             'Setup Workflow',
             'spa_workflow_schedule',
             'Success',
             'Workflow has been successfully saved.',
             @wg_task_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Workflow',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to save workflow',
             ''
	END CATCH
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_rule') IS NOT NULL
				DROP TABLE #tmp_rule
		SELECT	alert_sql_id		[alert_sql_id],
				alert_sql_name		[alert_sql_name],
				notification_type	[notification_type],
				alert_type			[alert_type],
				is_active			[is_active],
				system_rule			[system_rule],
				rule_category		[rule_category],
				workflow_only		[workflow_only],
				alert_category		[alert_category]
		INTO #tmp_rule
		FROM OPENXML(@idoc, '/Root/Rule', 1)
		WITH (
			alert_sql_id		INT,
			alert_sql_name		NVARCHAR(100),
			notification_type	INT,
			alert_type			NCHAR(1),
			is_active			NCHAR(1),
			system_rule			NCHAR(1),
			rule_category		INT,
			workflow_only		NCHAR(1),
			alert_category		NCHAR(1)
		)

		
		IF OBJECT_ID('tempdb..#tmp_table') IS NOT NULL
				DROP TABLE #tmp_table
		SELECT	alert_rule_table_id	[alert_rule_table_id],
				table_id			[table_id],
				table_alias			[table_alias],
				alert_id			[alert_id]
		INTO #tmp_table
		FROM OPENXML(@idoc, '/Root/Table', 1)
		WITH (
			alert_rule_table_id	INT,
			table_id			INT,
			table_alias			NVARCHAR(20),
			alert_id			INT
		)

		IF OBJECT_ID('tempdb..#tmp_condition') IS NOT NULL
				DROP TABLE #tmp_condition
		SELECT	alert_condition_id		[alert_condition_id],
				rule_id					[rule_id],
				alert_condition_name	[alert_condition_name]
		INTO #tmp_condition
		FROM OPENXML(@idoc, '/Root/Condition', 1)
		WITH (
			alert_condition_id		INT,
			rule_id					INT,
			alert_condition_name	NVARCHAR(100)
		)

		IF OBJECT_ID('tempdb..#tmp_condition_detail') IS NOT NULL
				DROP TABLE #tmp_condition_detail
		SELECT	alert_table_where_clause_id	[alert_table_where_clause_id],
				table_id					[table_id],
				column_id					[column_id],
				operator_id					[operator_id],
				column_value				[column_value],
				column_value2				[column_value2],
				alert_id					[alert_id],
				condition_id				[condition_id],
				clause_type					[clause_type],
				sequence_no					[sequence_no]
		INTO #tmp_condition_detail
		FROM OPENXML(@idoc, '/Root/ConditionDetail', 1)
		WITH (
			alert_table_where_clause_id	INT,
			table_id					INT,
			column_id					INT,
			operator_id					INT,
			column_value				NVARCHAR(30),
			column_value2				NVARCHAR(30),
			alert_id					INT,
			condition_id				INT,
			clause_type					INT,
			sequence_no					INT
		)

		IF OBJECT_ID('tempdb..#tmp_rule_action') IS NOT NULL
				DROP TABLE #tmp_rule_action
		SELECT	alert_action_id	[alert_action_id],
				table_id		[table_id],
				column_id		[column_id],
				operator_id		[operator_id],
				column_value	[column_value],
				alert_id		[alert_id],
				condition_id	[condition_id]
		INTO #tmp_rule_action
		FROM OPENXML(@idoc, '/Root/Action', 1)
		WITH (
			alert_action_id	INT,
			table_id		INT,
			column_id		INT,
			operator_id		INT,
			column_value	NVARCHAR(30),
			alert_id		INT,
			condition_id	INT
		)

		IF OBJECT_ID('tempdb..#tmp_module_event') IS NOT NULL
				DROP TABLE #tmp_module_event
		SELECT	module_event_id	[module_event_id],
				modules_id		[modules_id],
				event_id		[event_id],
				workflow_name	[workflow_name],
				is_active		[is_active]
		INTO #tmp_module_event
		FROM OPENXML(@idoc, '/Root/ModuleEvent', 1)
		WITH (
			module_event_id	INT,
			modules_id		INT,
			event_id		INT,
			workflow_name	NVARCHAR(100),
			is_active		NCHAR(1)
		)

		IF OBJECT_ID('tempdb..#tmp_event_trigger') IS NOT NULL
				DROP TABLE #tmp_event_trigger
		SELECT	event_trigger_id	[event_trigger_id],
				module_event_id		[module_event_id],
				alert_id			[event_id]
		INTO #tmp_event_trigger
		FROM OPENXML(@idoc, '/Root/EventTrigger', 1)
		WITH (
			event_trigger_id	INT,
			module_event_id		INT,
			alert_id			INT
		)

		IF OBJECT_ID('tempdb..#tmp_workflow_message') IS NOT NULL
				DROP TABLE #tmp_workflow_message
		SELECT	event_message_id			[event_message_id],
				event_trigger_id			[event_trigger_id],
				message_template_id			[message_template_id],
				[message]					[message],
				self_notify					[self_notify],
				notification_type			[notification_type],
				mult_approval_required		[mult_approval_required],
				comment_required			[comment_required],
				approval_action_required	[approval_action_required],
				trader_notify				[trader_notify],
				event_message_name			[event_message_name]
		INTO #tmp_workflow_message
		FROM OPENXML(@idoc, '/Root/Message', 1)
		WITH (
			event_message_id			INT,
			event_trigger_id			INT,
			message_template_id			INT,
			[message]					NVARCHAR(300),
			self_notify					NCHAR(1),
			notification_type			NVARCHAR(100),
			mult_approval_required		NCHAR(1),
			comment_required			NCHAR(1),
			approval_action_required	NCHAR(1),
			trader_notify				NCHAR(1),
			event_message_name			NVARCHAR(300)
		)

		IF OBJECT_ID('tempdb..#tmp_user_role') IS NOT NULL
				DROP TABLE #tmp_user_role
		SELECT	event_message_id	[event_message_id],
				user_login_id		[user_login_id],
				role_id				[role_id]
		INTO #tmp_user_role
		FROM OPENXML(@idoc, '/Root/UserRole', 1)
		WITH (
			event_message_id	INT,
			user_login_id		NVARCHAR(50),
			role_id				INT
		)

		IF OBJECT_ID('tempdb..#tmp_message_document') IS NOT NULL
				DROP TABLE #tmp_message_document
		SELECT	event_message_id		[event_message_id],
				document_template_id	[document_template_id],
				document_category		[document_category]
		INTO #tmp_message_document
		FROM OPENXML(@idoc, '/Root/MessageDocument', 1)
		WITH (
			event_message_id		INT,
			document_template_id	INT,
			document_category		INT
		)

		IF OBJECT_ID('tempdb..#tmp_message_report') IS NOT NULL
				DROP TABLE #tmp_message_report
		SELECT	event_message_id	[event_message_id],
				report_description	[report_description],
				report_prefix		[report_prefix],
				report_sufix		[report_sufix],
				report_paramset		[report_paramset],
				report_writer		[report_writer],
				NULLIF(file_option_type,'')	[file_option_type]
		INTO #tmp_message_report
		FROM OPENXML(@idoc, '/Root/MessageReport', 1)
		WITH (
			event_message_id	INT,
			report_description	NVARCHAR(100),
			report_prefix		NVARCHAR(100),
			report_sufix		NVARCHAR(100),
			report_paramset		NVARCHAR(100),
			report_writer		NCHAR(1),
			file_option_type	NCHAR(1)
		)

		IF OBJECT_ID('tempdb..#tmp_alert_sql_statement') IS NOT NULL
				DROP TABLE #tmp_alert_sql_statement
		SELECT	alert_sql_id		[alert_sql_id],
				alert_sql_statement		[alert_sql_statement]
		INTO #tmp_alert_sql_statement
		FROM OPENXML(@idoc, '/Root/SqlStatement', 1)
		WITH (
			alert_sql_id		NVARCHAR(10),
			alert_sql_statement		NVARCHAR(MAX)
		)

		/*Validation Begin*/
		IF EXISTS(SELECT 1 FROM #tmp_rule tr
					INNER JOIN alert_sql as1
					ON as1.alert_sql_name = tr.alert_sql_name
					WHERE tr.alert_sql_id <> as1.alert_sql_id
			
		)
		BEGIN
			EXEC spa_ErrorHandler -1,
							  'spa_workflow_schedule',
							  'spa_workflow_schedule',
							  'DB Error',
							  'Rule name already exists.',
							  ''
		RETURN
		END
		/*Validation END*/
		BEGIN TRAN
		DECLARE @alert_id INT
		DECLARE @rule_table_id INT
		DECLARE @alert_condition_id INT
		DECLARE @module_event_id INT
		DECLARE @event_trigger_id INT
		DECLARE @event_message_id INT
		DECLARE @alert_sql_statement NVARCHAR(MAX)

		DECLARE @n_table_id INT
		SELECT @n_table_id = alert_table_definition_id FROM workflow_module_rule_table_mapping wm
		INNER JOIN alert_table_definition atd ON wm.rule_table_id = atd.alert_table_definition_id
		WHERE wm.module_id = @module_id AND wm.is_active = 1 AND atd.is_action_view = 'y'

		-- alert_sql Table / Rule
		IF EXISTS (SELECT 1 FROM #tmp_rule WHERE alert_sql_id = 0)
		BEGIN
			INSERT INTO alert_sql (alert_sql_name, notification_type, alert_type, is_active, system_rule, rule_category, workflow_only,alert_category)
			SELECT alert_sql_name, notification_type, alert_type, is_active, system_rule, rule_category, workflow_only,alert_category FROM #tmp_rule

			SET @alert_id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE als
			SET als.alert_sql_name = tr.alert_sql_name,
				als.notification_type = tr.notification_type,
				als.alert_category = tr.alert_category,
				als.rule_category = tr.rule_category
			FROM alert_sql als
			INNER JOIN #tmp_rule tr ON als.alert_sql_id = tr.alert_sql_id

			SELECT TOP(1) @alert_id = alert_sql_id FROM #tmp_rule 
		END

		-- alert_rule_table Table / Alert Table
		IF NOT EXISTS (SELECT 1 FROM #tmp_table) AND @n_table_id IS NOT NULL
		BEGIN
			IF EXISTS(SELECT 1 FROM alert_rule_table WHERE table_id = @n_table_id AND alert_id = @alert_id)
			BEGIN
				SELECT @rule_table_id = alert_rule_table_id FROM alert_rule_table WHERE table_id = @n_table_id AND alert_id = @alert_id
			END
			ELSE 
			BEGIN
				INSERT INTO alert_rule_table (table_id, table_alias, alert_id)
				SELECT @n_table_id, 'dt', @alert_id 

				SET @rule_table_id = SCOPE_IDENTITY()

				INSERT INTO alert_conditions (rules_id, alert_conditions_name)
				SELECT @alert_id, alert_sql_name FROM #tmp_rule

				SET @alert_condition_id = SCOPE_IDENTITY()
			END
		END
		ELSE IF EXISTS (SELECT 1 FROM #tmp_table WHERE alert_rule_table_id = 0 AND NULLIF(table_id,'') IS NOT NULL)
		BEGIN
			INSERT INTO alert_rule_table (table_id, table_alias, alert_id)
			SELECT table_id, ISNULL(NULLIF(table_alias,''),'dt'), @alert_id FROM #tmp_table

			SET @rule_table_id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE art
			SET art.table_id = tt.table_id,
				art.table_alias = tt.table_alias

			FROM alert_rule_table art
			INNER JOIN #tmp_table tt ON art.alert_rule_table_id = tt.alert_rule_table_id

			SELECT TOP(1) @rule_table_id = alert_rule_table_id FROM #tmp_table 
		END

		-- alert_conditions Table / Alert Condition
		IF EXISTS (SELECT 1 FROM #tmp_table WHERE alert_rule_table_id = 0)
		BEGIN
			INSERT INTO alert_conditions (rules_id, alert_conditions_name)
			SELECT @alert_id, alert_condition_name FROM #tmp_condition WHERE alert_condition_id = 0

			SET @alert_condition_id = SCOPE_IDENTITY()
		END
		ELSE 
		BEGIN
			UPDATE ac
			SET ac.alert_conditions_name = tc.alert_condition_name
			FROM alert_conditions ac
			INNER JOIN #tmp_condition tc ON ac.alert_conditions_id = tc.alert_condition_id

			SELECT TOP(1) @alert_condition_id = alert_conditions_id FROM alert_conditions WHERE rules_id = @alert_id
		END


		IF @rule_table_id IS NOT NULL
		BEGIN
			-- alert_table_where_clause Table / Alert Condition Where Clause
			DELETE atwc FROM alert_table_where_clause atwc
			LEFT JOIN #tmp_condition_detail tcd ON atwc.alert_table_where_clause_id = tcd.alert_table_where_clause_id
			WHERE atwc.alert_id = @alert_id AND tcd.alert_table_where_clause_id IS NULL
		
			INSERT INTO alert_table_where_clause (data_source_column_id, operator_id, column_value, alert_id, condition_id, clause_type, table_id, sequence_no, second_value)
			SELECT column_id, operator_id, column_value, @alert_id, @alert_condition_id, clause_type, @rule_table_id, sequence_no, column_value2 FROM #tmp_condition_detail WHERE alert_table_where_clause_id = 0
	
			UPDATE atwc
			SET atwc.data_source_column_id = tcd.column_id,
				atwc.operator_id = tcd.operator_id,
				atwc.column_value = tcd.column_value,
				atwc.table_id = @rule_table_id,
				atwc.sequence_no = tcd.sequence_no,
				atwc.clause_type = tcd.clause_type,
				atwc.second_value = tcd.column_value2
			FROM alert_table_where_clause atwc
			INNER JOIN #tmp_condition_detail tcd ON atwc.alert_table_where_clause_id = tcd.alert_table_where_clause_id
		

			-- alert_actions Table / Alert Actions
			DELETE aa FROM alert_actions aa
			LEFT JOIN #tmp_rule_action tra ON aa.alert_actions_id = tra.alert_action_id
			WHERE aa.alert_id = @alert_id AND tra.alert_action_id IS NULL
	
			INSERT INTO alert_actions (table_id, data_source_column_id, column_value, alert_id, condition_id)
			SELECT @rule_table_id, column_id, column_value, @alert_id, @alert_condition_id FROM #tmp_rule_action WHERE alert_action_id = 0
	
			UPDATE aa
			SET aa.table_id = @rule_table_id,
				aa.data_source_column_id = tra.column_id,
				aa.column_value = tra.column_value
			FROM alert_actions aa
			INNER JOIN #tmp_rule_action tra ON aa.alert_actions_id = tra.alert_action_id
		END

		-- module_events Table / Workflow
		IF EXISTS (SELECT 1 FROM #tmp_module_event WHERE module_event_id = 0)
		BEGIN
			INSERT INTO module_events(modules_id, event_id, workflow_name, is_active)
			SELECT modules_id, event_id, workflow_name, is_active FROM #tmp_module_event

			SET @module_event_id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE me
			SET me.modules_id = tme.modules_id,
				me.event_id = tme.event_id,
				me.workflow_name = tme.workflow_name,
				me.is_active = tme.is_active
			FROM module_events me
			INNER JOIN #tmp_module_event tme ON me.module_events_id = tme.module_event_id

			SELECT TOP(1) @module_event_id = module_event_id FROM #tmp_module_event 
		END

		-- event_trigger Table / Rule Mapping
		IF EXISTS (SELECT 1 FROM #tmp_event_trigger WHERE event_trigger_id = 0)
		BEGIN
			INSERT INTO event_trigger(modules_event_id, alert_id)
			SELECT @module_event_id, @alert_id FROM #tmp_event_trigger

			SET @event_trigger_id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE et
			SET et.modules_event_id = @module_event_id,
				et.alert_id = @alert_id
			FROM event_trigger et
			INNER JOIN #tmp_event_trigger tet ON et.event_trigger_id = tet.event_trigger_id

			SELECT TOP(1) @event_trigger_id = event_trigger_id FROM #tmp_event_trigger 
		END

		/* Update sql statement */
			SELECT @alert_sql_statement = alert_sql_statement
			FROM #tmp_alert_sql_statement
			
			IF EXISTS(SELECT 1 FROM alert_actions
					  WHERE alert_id = @alert_id 
					  AND condition_id = @alert_condition_id			
			) 
			BEGIN
				UPDATE alert_actions
				SET sql_statement = @alert_sql_statement
				WHERE alert_id = @alert_id 
				AND condition_id = @alert_condition_id	
			END
			ELSE IF NULLIF(@alert_sql_statement,'') IS NOT NULL
			BEGIN
				INSERT INTO alert_actions (alert_id, condition_id, sql_statement)
				SELECT @alert_id, @alert_condition_id, @alert_sql_statement
			END

		IF EXISTS(SELECT 1 FROM #tmp_rule WHERE alert_category = 'w')
		BEGIN
			DELETE wa FROM workflow_activities wa
			INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			LEFT JOIN #tmp_workflow_message twm ON wem.event_message_id = twm.event_message_id
			WHERE et.alert_id = @alert_id AND twm.event_message_id IS NULL

			DELETE weur FROM workflow_event_user_role weur
			INNER JOIN workflow_event_message wem ON weur.event_message_id = wem.event_message_id
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			LEFT JOIN #tmp_workflow_message twm ON wem.event_message_id = twm.event_message_id
			WHERE et.alert_id = @alert_id AND twm.event_message_id IS NULL

			DELETE wem FROM workflow_event_message wem
			INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
			LEFT JOIN #tmp_workflow_message twm ON wem.event_message_id = twm.event_message_id
			WHERE et.alert_id = @alert_id AND twm.event_message_id IS NULL

			-- workflow_event_message Table / Workflow Message
			IF EXISTS (SELECT 1 FROM #tmp_workflow_message WHERE event_message_id = 0)
			BEGIN
				INSERT INTO workflow_event_message(event_trigger_id, event_message_name, message_template_id, [message], self_notify, mult_approval_required, comment_required, approval_action_required, notify_trader, notification_type)
				SELECT @event_trigger_id, event_message_name, message_template_id, [message], self_notify, mult_approval_required, comment_required, approval_action_required, trader_notify, notification_type 
				FROM #tmp_workflow_message
				WHERE event_message_id = 0
		
				SET @event_message_id = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				UPDATE wem
				SET wem.event_trigger_id = @event_trigger_id,
					wem.[message] = twm.[message],
					wem.self_notify = twm.self_notify,
					wem.notification_type = twm.notification_type
				FROM workflow_event_message wem
				INNER JOIN #tmp_workflow_message twm ON wem.event_message_id = twm.event_message_id

				SELECT TOP(1) @event_message_id = event_message_id FROM #tmp_workflow_message 
			END		
			-- workflow_event_user_role Table / User Role for Message
			DELETE FROM workflow_event_user_role WHERE event_message_id = @event_message_id

			INSERT INTO workflow_event_user_role (event_message_id, user_login_id, role_id)
			SELECT @event_message_id, user_login_id, role_id FROM #tmp_user_role

			-- workflow_event_message_docuemnt Table 
			DELETE FROM workflow_event_message_documents WHERE event_message_id = @event_message_id
			
			INSERT INTO workflow_event_message_documents (event_message_id, document_template_id, document_category)
			SELECT @event_message_id, document_template_id, document_category   FROM #tmp_message_document

			-- alert_reports
			DELETE FROM alert_reports WHERE event_message_id = @event_message_id

			DECLARE @report_parameter NVARCHAR(MAX)
			DECLARE @alert_report_id INT
			SELECT @report_parameter = 
			STUFF((Select ','+ a.column_name + '=' + CASE WHEN a.initial_value = '' THEN 'NULL' ELSE a.initial_value END
				FROM (
					select dsc.name [column_name], REPLACE(rp.initial_value, ',','!') initial_value
					from report_param rp
					inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
					inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
					inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
					inner join report_param_operator rpo on rpo.report_param_operator_id = rp.operator
					inner join #tmp_message_report tmr ON rps.paramset_hash = tmr.report_paramset
					UNION ALL
					select '2_' + dsc.name [column_name], REPLACE(rp.initial_value2, ',','!') initial_value2
					from report_param rp
					inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
					inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
					inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
					inner join report_param_operator rpo on rpo.report_param_operator_id = rp.operator
					inner join #tmp_message_report tmr ON rps.paramset_hash = tmr.report_paramset
					where rpo.report_param_operator_id = 8
				) a
			FOR XML PATH('')),1,1,'')

			INSERT INTO alert_reports (event_message_id, report_writer, paramset_hash, report_param, report_desc, table_prefix, table_postfix, file_option_type)
			SELECT @event_message_id, 
					tmr.report_writer, 
					tmr.report_paramset, @report_parameter, 
					CASE WHEN tmr.report_description = '' THEN (SELECT name FROM report_paramset WHERE paramset_hash = tmr.report_paramset) ELSE tmr.report_description END,
					tmr.report_prefix, 
					tmr.report_sufix,
					tmr.file_option_type
			FROM #tmp_message_report tmr

			IF NOT EXISTS(SELECT 1 FROM workflow_schedule_task WHERE [text] ='Internal Workflow'+CAST(@module_event_id AS NVARCHAR))
			BEGIN
				INSERT INTO workflow_schedule_task(text,start_date,workflow_id_type,system_defined,parent,workflow_id)
				SELECT 'Internal Workflow'+CAST(@module_event_id AS NVARCHAR),getdate(),1,0,-999,@module_event_id
			END		END
	
	COMMIT TRAN

	EXEC spa_ErrorHandler 0,
             'spa_workflow_schedule',
             'spa_workflow_schedule',
             'Success',
             'Changes have been saved successfully.',
             @alert_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_workflow_schedule',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to save data.',
             ''
	END CATCH
END

ELSE IF @flag = 'h'
BEGIN
	DECLARE @user_login_ids NVARCHAR(300)
	DECLARE @role_ids NVARCHAR(300)

	SELECT @user_login_ids = STUFF((SELECT ','+ user_login_id
	FROM event_trigger et 
	INNER JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
	INNER JOIN workflow_event_user_role weur ON wem.event_message_id = weur.event_message_id
	WHERE et.alert_id = @alert_sql_id AND user_login_id <> '' AND user_login_id IS NOT NULL
	FOR XML PATH('')),1,1,'')

	SELECT @role_ids = STUFF((SELECT ','+ CAST(role_id AS NVARCHAR)
	FROM event_trigger et 
	INNER JOIN workflow_event_message wem ON et.event_trigger_id = wem.event_trigger_id
	INNER JOIN workflow_event_user_role weur ON wem.event_message_id = weur.event_message_id
	WHERE et.alert_id = @alert_sql_id AND role_id <> '' AND role_id IS NOT NULL
	FOR XML PATH('')),1,1,'')

	SELECT * FROM 
	(	
		SELECT	42101 [component_category],
				me.module_events_id [value_1],
				CAST(et.event_trigger_id AS NVARCHAR) [value_2],
				CAST(me.modules_id AS NVARCHAR) [value_3],
				CAST(me.event_id AS NVARCHAR) [value_4], 
				me.is_active [value_5],
				'' [value_6],
				'' [value_7],
				1 [sequence_no]
		FROM event_trigger et
		INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
		INNER JOIN alert_sql asl ON et.alert_id = asl.alert_sql_id
		WHERE et.alert_id = @alert_sql_id AND asl.alert_category = 'w'
		UNION ALL
		SELECT	42102 [component_category], 
				alert_sql_id [value_1], 
				alert_sql_name [value_2], 
				CAST(rule_category AS NVARCHAR) [value_3], 
				'' [value_4],
				'' [value_5],
				'' [value_6],
				'' [value_7],
				1 [sequence_no]
		FROM alert_sql
		WHERE alert_sql_id = @alert_sql_id
		UNION ALL
		SELECT	42103 [component_category], 
				art.alert_rule_table_id [value_1], 
				CAST(art.table_id AS NVARCHAR) [value_2], 
				CAST(art.table_alias AS NVARCHAR) [value_3], 
				CAST(ac.alert_conditions_id AS NVARCHAR) [value_4],
				'' [value_5],
				'' [value_6],
				'' [value_7],
				1 [sequence_no]
		FROM alert_rule_table art
		INNER JOIN alert_conditions ac ON art.alert_id = ac.rules_id
		LEFT JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id
		WHERE alert_id = @alert_sql_id AND atd.is_action_view = 'n'
		UNION ALL
		SELECT	CASE WHEN clause_type = 1 THEN 42104 WHEN clause_type = 2 THEN 42105 ELSE 42108 END [component_category],
				alert_table_where_clause_id [value_1],
				CASE WHEN clause_type = 1 OR clause_type = 2 THEN CAST(data_source_column_id AS NVARCHAR) ELSE CAST(clause_type AS NVARCHAR) END [value_2],
				CAST(operator_id AS NVARCHAR) [value_3],
				CAST(column_value AS NVARCHAR) [value_4],
				CAST(second_value AS NVARCHAR) [value_5],
				'' [value_6],
				'' [value_7],
				sequence_no [sequence_no]
		FROM alert_table_where_clause
		WHERE alert_id = @alert_sql_id
		UNION ALL
		SELECT	42106 [component_category], 
				alert_actions_id [value_1], 
				CAST(data_source_column_id AS NVARCHAR) [value_2], 
				CAST(column_value AS NVARCHAR) [value_3], 
				'' [value_4],
				'' [value_5],
				'' [value_6],
				'' [value_7],
				9996 [sequence_no]
		FROM alert_actions aa
		WHERE aa.alert_id = @alert_sql_id
		AND data_source_column_id IS NOT NULL
		AND column_value IS NOT NULL
		UNION ALL
		SELECT	42107 [component_category],
				wem.event_message_id [value_1],
				wem.[message] [value_2],
				wem.self_notify [value_3],
				@user_login_ids [value_4],
				@role_ids [value_5],
				wem.notification_type [value_6],
				'' [value_7],
				9998 [sequence_no]
		FROM workflow_event_message wem
		INNER JOIN event_trigger et on wem.event_trigger_id = et.event_trigger_id
		INNER JOIN alert_sql asl ON et.alert_id = asl.alert_sql_id
		WHERE et.alert_id = @alert_sql_id AND asl.alert_category = 'w'
		UNION ALL
		SELECT	42199 [component_category],
				ISNULL(wemd.document_template_id,'') [value_1],
				ISNULL(CAST(wemd.document_category AS NVARCHAR),'') [value_2],
				ISNULL(ar.paramset_hash,'') [value_3],
				ISNULL(ar.report_desc,'') [value_4],
				ISNULL(ar.table_prefix,'') + '||' + ISNULL(ar.table_postfix,'') [value_5],
				ar.report_writer [value_6],
				ar.file_option_type [value_7],
				9999 [sequence_no]
		FROM workflow_event_message wem
		INNER JOIN event_trigger et on wem.event_trigger_id = et.event_trigger_id
		INNER JOIN alert_sql asl ON et.alert_id = asl.alert_sql_id
		LEFT JOIN workflow_event_message_documents wemd ON wem.event_message_id = wemd.event_message_id
		LEfT JOIN alert_reports ar ON wem.event_message_id = ar.event_message_id
		WHERE et.alert_id = @alert_sql_id AND asl.alert_category = 'w'
		UNION ALL
		SELECT	42109 [component_category],
				alert_id [value_1],
				sql_statement [value_2],
				'' [value_3],
				'' [value_4],
				'' [value_5],
				'' [value_6],
				'' [value_7],
				9997 [sequence_no]
		FROM alert_actions  
		WHERE alert_id = @alert_sql_id AND NULLIF(sql_statement,'') IS NOT NULL
	) a
	ORDER BY a.sequence_no,CASE WHEN a.component_category = 42105 OR a.component_category = 42108 THEN 42104 ELSE a.component_category END
END

-- Sort the sequence number
ELSE IF @flag = 'e'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_sort_order') IS NOT NULL
				DROP TABLE #tmp_sort_order
		SELECT	task_id		[task_id],
				sort_order	[sort_order]
		INTO #tmp_sort_order
		FROM OPENXML(@idoc, '/Root/Task', 1)
		WITH (
			task_id		INT,
			sort_order	INT
		)

		UPDATE wst
		SET sort_order = tso.sort_order
		FROM workflow_schedule_task wst
		INNER JOIN #tmp_sort_order tso ON wst.id = tso.task_id

	EXEC spa_ErrorHandler 0,
             'spa_workflow_schedule',
             'spa_workflow_schedule',
             'Success',
             'Workflow has been successfully sorted.',
             @alert_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_workflow_schedule',
             'spa_workflow_schedule',
             'DB Error',
             'Failed to sort workflow',
             ''
	END CATCH

END

-- Dropdown for template workflow
ELSE IF @flag = 'p'
BEGIN
	SELECT me.module_events_id, me.workflow_name FROM workflow_schedule_task wst_g
	INNER JOIN workflow_schedule_task wst_w ON wst_g.id = wst_w.parent
	INNER JOIN module_events me ON me.module_events_id = wst_w.workflow_id
	WHERE wst_g.system_defined = 2
END

-- Dropdown for workflow link
ELSE IF @flag = 'q'
BEGIN
	SELECT DISTINCT me.module_events_id, me.workflow_name 
	FROM workflow_schedule_task wst
	INNER JOIN module_events me ON me.module_events_id = wst.workflow_id AND wst.workflow_id_type = 1
	WHERE wst.parent = @task_parent AND me.module_events_id <> @task_id
END

-- Getting report paramset id from paramset hast
ELSE IF @flag = 't'
BEGIN
	SELECT rp.report_paramset_id,rp.name  FROM report_paramset AS rp WHERE rp.paramset_hash  = @paramset_hash
END

ELSE IF @flag = '1'
BEGIN
	IF @column_id = -1
	BEGIN
		SELECT 'TEXTBOX' [column_widgets], '' [dropdown_options]
		RETURN
	END

	IF OBJECT_ID('tempdb..#temp_column_widgets') IS NOT NULL
		DROP TABLE #temp_column_widgets
	CREATE TABLE #temp_column_widgets ([column_widgets] NVARCHAR(20) COLLATE DATABASE_DEFAULT, [param_data_source] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, [dropdown_options] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)

	INSERT INTO #temp_column_widgets ([column_widgets], [param_data_source])
	SELECT rw.name [column_widgets], dsc.param_data_source
	FROM data_source_column dsc
	INNER JOIN report_widget rw ON dsc.widget_id = rw.report_widget_id
	WHERE dsc.data_source_column_id = @column_id
	--WHERE dsc.data_source_column_id = 26255
	--WHERE dsc.data_source_column_id = 26256

	IF EXISTS (SELECT 1 FROM #temp_column_widgets WHERE column_widgets = 'DROPDOWN')
	BEGIN
		DECLARE @data_source_query NVARCHAR(MAX)
		SELECT @data_source_query = MAX(param_data_source) FROM #temp_column_widgets

		IF OBJECT_ID('tempdb..#dropdown_values') IS NOT NULL
		DROP TABLE #dropdown_values
		CREATE TABLE #dropdown_values (value_id NVARCHAR(100) COLLATE DATABASE_DEFAULT, code NVARCHAR(2000) COLLATE DATABASE_DEFAULT)
		
		EXEC('INSERT INTO #dropdown_values ' + @data_source_query)

		UPDATE #temp_column_widgets
		SET [dropdown_options] =  STUFF((SELECT '<option value="' + value_id + '">' + code + '</option>' FROM #dropdown_values FOR XML PATH ('')), 1, 0, '') 
	END
	SELECT [column_widgets], [dropdown_options] FROM #temp_column_widgets
END
