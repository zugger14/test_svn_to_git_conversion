IF OBJECT_ID(N'[dbo].[spa_register_event_manual]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_register_event_manual]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[spa_register_event_manual]
	@flag				CHAR(1),
    @event_trigger_id	INT = NULL,
	@module_event_id	INT = NULL,
	@group_id			INT = NULL,
	@is_batch			BIT = 0,
    @process_table_xml	VARCHAR(200) = NULL,
	@source_id			INT = NULL,
	@source_column		VARCHAR(100) = NULL,
	@activity_id		INT = NULL,
	@xml				TEXT = NULL,
	@custom_activity_desc VARCHAR(5000) = NULL,
	@custom_activity_id INT = NULL,
	@custom_schedule_date	DATETIME = NULL,
	@group_process_id VARCHAR(500) = NULL,
	@run_only_individual_step CHAR(1) = NULL

AS

SET NOCOUNT ON; 

DECLARE @alert_sql_id INT
DECLARE @alert_process_table VARCHAR(500)
DECLARE @process_id VARCHAR(200) = dbo.FNAGETNewID()
DECLARE @sql VARCHAR(MAX)
DECLARE @job_name VARCHAR(100)
DECLARE @user_login_id VARCHAR(50) = dbo.FNADBUser()
DECLARE @idoc INT

SET @group_process_id = NULLIF(@group_process_id,'')
SET @process_table_xml = NULLIF(@process_table_xml,'')

IF @process_table_xml IS NOT NULL
BEGIN
	SET @alert_process_table = 'adiha_process.dbo.alert_manual_trigger_' + @process_id + '_amt'
END
ELSE
BEGIN
	SET @alert_process_table = NULL
END

DECLARE @process_xml_data VARCHAR(1000)
IF OBJECT_ID(@alert_process_table) IS NULL
BEGIN
	IF @process_table_xml IS NOT NULL
	BEGIN						
		SET @process_xml_data = '<PSRecordset>'+CAST(@process_table_xml AS NVARCHAR(MAX))+'</PSRecordset>'
		EXEC [spa_parse_xml_file] 'b',NULL,@process_xml_data,@alert_process_table

	END
END

IF @alert_process_table IS NOT NULL AND OBJECT_ID(@alert_process_table) IS NOT NULL
BEGIN
	SET @sql = 'IF COL_LENGTH(''' + @alert_process_table + ''',''primary_temp_id'') IS NULL 
				BEGIN 
					ALTER TABLE ' + @alert_process_table + ' ADD primary_temp_id INT NOT NULL DEFAULT 1 
				END
				IF COL_LENGTH(''' + @alert_process_table + ''', ''attachment_files'') IS NULL
				BEGIN
					ALTER TABLE ' + @alert_process_table + ' ADD attachment_files VARCHAR(300) NULL
				END'
	EXEC(@sql)
END

SELECT @alert_sql_id = et.alert_id FROM event_trigger et WHERE et.event_trigger_id = @event_trigger_id

IF @group_process_id IS NULL
BEGIN
SELECT TOP(1) @group_process_id = workflow_process_id FROM workflow_activities wa
INNER JOIN event_trigger et ON wa.workflow_trigger_id = et.event_trigger_id
INNER JOIN module_events me ON me.module_events_id = et.modules_event_id AND me.module_events_id = @module_event_id
INNER JOIN workflow_schedule_task wst ON wst.workflow_id = me.module_events_id AND wst.workflow_id_type = 1 AND wst.parent = @group_id 
WHERE wa.source_id = @source_id
ORDER BY wa.create_ts DESC
END

-- To Trigger the workflow step
IF @flag = 't'
BEGIN
	BEGIN TRY
		IF @is_batch = 0
		BEGIN
			EXEC spa_run_alert_sql @alert_sql_id,
				@process_id,
				@alert_process_table,
				NULL,
				NULL,
				@event_trigger_id,
				NULL,
				@group_process_id,
				NULL,
				@group_id,
				@custom_schedule_date,
				NULL,
				@run_only_individual_step

		END
		ELSE
		BEGIN
			DECLARE @sql_statement VARCHAR(MAX)

			SET @sql_statement = 'spa_run_alert_sql ' + CAST(@alert_sql_id AS VARCHAR) + ',' + '''' + @process_id + ''',' + ISNULL( + '''' + @alert_process_table + '''','NULL') + ',NULL,NULL,' + CAST(@event_trigger_id AS VARCHAR) + ',NULL,' + ISNULL( + '''' + @group_process_id + '''','NULL') + ',NULL,' + CAST(@group_id AS VARCHAR) + ',''' + ISNULL(CAST(@custom_schedule_date AS VARCHAR),'') + ''',NULL,''' + ISNULL(@run_only_individual_step,'n') + ''''
			
			SET @job_name = 'Alert_Job_' + CAST(@alert_sql_id AS VARCHAR) + '_' + CAST(@group_id AS VARCHAR) + '_' + @process_id
			EXEC spa_run_sp_as_job @job_name, @sql_statement, @job_name, @user_login_id ,NULL, NULL, NULL
		END		

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Workflow Step has been triggered manually.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- To keep workflow step in ignore list
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		INSERT INTO workflow_activities (workflow_trigger_id, as_of_date, event_message_id, control_status, [message], process_id, source_column, source_id, workflow_process_id, workflow_group_id)
		SELECT	wem.event_trigger_id, 
				GETDATE(),
				wem.event_message_id,
				737,
				wem.[message],
				@process_id,
				@source_column,
				@source_id,
				ISNULL(@group_process_id,dbo.FNAGETNewID()),
				@group_id
		FROM workflow_event_message wem
		WHERE wem.event_trigger_id = @event_trigger_id
	
		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Workflow Step has been ignored.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH

END

-- To remove workflow step from ignore list
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		DELETE FROM workflow_activities
		WHERE workflow_activity_id = @activity_id AND control_status = 737
	
		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Workflow Step has been removed from ignored list.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- To schedule the workflow step
ELSE IF @flag = 's'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
		IF OBJECT_ID('tempdb..#temp_calendar_detail') IS NOT NULL
			DROP TABLE #temp_calendar_detail

		SELECT
			name,
			[description],
			workflow_id,
			alert_id,
			reminder,
			rec_type,
			[start_date],
			end_date ,
			event_parent_id,
			event_length,
			workflow_group_id,
			automatic_trigger,
			run_only_this_step,
			workflow_process_id,
			scheduled_as_of_date
		INTO #temp_calendar_detail
		FROM OPENXML(@idoc, '/Root', 1)
		WITH (
			name VARCHAR(100),
			[description] VARCHAR(1000),
			workflow_id INT,
			alert_id INT,
			reminder INT,
			rec_type VARCHAR(1000),
			[start_date] DATETIME,
			end_date DATETIME,
			event_parent_id INT,
			event_length INT,
			workflow_group_id INT,
			automatic_trigger CHAR(1),
			run_only_this_step CHAR(1),
			workflow_process_id VARCHAR(300),
			scheduled_as_of_date DATETIME
		)

		INSERT INTO calendar_events (
			name,
			[description],
			workflow_id,
			alert_id,
			reminder,
			rec_type,
			[start_date],
			end_date,
			event_parent_id,
			event_length,
			workflow_group_id,
			process_table_xml,
			source_id,
			automatic_trigger,
			run_only_individual_step,
			workflow_process_id,
			scheduled_as_of_date
		)
		SELECT
			ISNULL(sdv.code, '') + ' - ' + tcd.name  + ' | ' + ISNULL(me.workflow_name, '') + ' - ' + ISNULL(wem.event_message_name,'') ,
			tcd.[description],
			tcd.workflow_id,
			tcd.alert_id,
			tcd.reminder,
			tcd.rec_type,
			dbo.FNAConvertTimezone(tcd.[start_date], 1),
			dbo.FNAConvertTimezone(tcd.end_date, 1),
			tcd.event_parent_id,
			tcd.event_length,
			tcd.workflow_group_id,
			@process_table_xml,
			@source_id,
			tcd.automatic_trigger,
			tcd.run_only_this_step,
			tcd.workflow_process_id,
			tcd.scheduled_as_of_date
		FROM #temp_calendar_detail tcd
		LEFT JOIN dbo.workflow_event_message wem ON tcd.alert_id = wem.event_trigger_id
		LEFT JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
		LEFT JOIN module_events me ON me.module_events_id = et.modules_event_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = me.modules_id

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Workflow Step has been scheduled.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- Cancel the scheduled workflow step
ELSE IF @flag = 'c'
BEGIN
	BEGIN TRY
		DELETE FROM calendar_events
		WHERE calendar_event_id = @activity_id
	
		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Scheduled workflow step has been canceled.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END


-- To keep workflow group in ignore list
ELSE IF @flag = 'g'
BEGIN
	BEGIN TRY
		DECLARE @igonore_group_process VARCHAR(100)

		SELECT TOP(1) @igonore_group_process = workflow_process_id
		FROM workflow_event_message wem
		INNER JOIN dbo.event_trigger et ON wem.event_trigger_id = et.event_trigger_id
		LEFT JOIN dbo.workflow_activities wa ON wa.workflow_trigger_id = et.event_trigger_id AND wa.event_message_id = wa.event_message_id AND wa.control_status = 737
				AND wa.source_column = @source_column AND wa.source_id = @source_id AND wa.workflow_group_id = @group_id
		WHERE et.modules_event_id = @module_event_id AND wa.workflow_activity_id IS NOT NULL

		IF @igonore_group_process IS NULL
			SET @igonore_group_process = dbo.FNAGETNewID()

		INSERT INTO workflow_activities (workflow_trigger_id, as_of_date, event_message_id, control_status, [message], process_id, source_column, source_id, workflow_process_id, workflow_group_id)

		SELECT	wem.event_trigger_id, 
				GETDATE(),
				wem.event_message_id,
				737,
				wem.[message],
				@process_id,
				@source_column,
				@source_id,
				@igonore_group_process,
				@group_id
		FROM workflow_event_message wem
		INNER JOIN dbo.event_trigger et ON wem.event_trigger_id = et.event_trigger_id
		LEFT JOIN dbo.workflow_activities wa ON wa.workflow_trigger_id = et.event_trigger_id AND wa.event_message_id = wa.event_message_id AND wa.control_status = 737
				AND wa.source_column = @source_column AND wa.source_id = @source_id AND wa.workflow_group_id = @group_id
		WHERE et.modules_event_id = @module_event_id AND wa.workflow_activity_id IS NULL
	
		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Workflow Step has been ignored.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH

END

-- Create custom activity
ELSE IF @flag = 'z'
BEGIN
	BEGIN TRY
		INSERT INTO workflow_custom_activities (
			workflow_custom_activity_desc,
			workflow_group_id,
			modules_event_id,
			status,
			source_column,
			source_id
		)
		SELECT	@custom_activity_desc,
				@group_id,
				@module_event_id,
				NULL,
				@source_column,
				@source_id

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Custom activity has been successfully created.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- Complete custom activity
ELSE IF @flag = 'x'
BEGIN
	BEGIN TRY
		UPDATE workflow_custom_activities
		SET [status] = 728
		WHERE workflow_custom_activity_id = @custom_activity_id

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Custom activity has been successfully completed.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- Remove custom activity
ELSE IF @flag = 'w'
BEGIN
	BEGIN TRY
		DELETE FROM workflow_custom_activities
		WHERE workflow_custom_activity_id = @custom_activity_id

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Custom activity has been successfully removed.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- Schedule the custom activity
ELSE IF @flag = 'p'
BEGIN
	BEGIN TRY
		
		INSERT INTO calendar_events (
			[name],
			description,
			workflow_id,
			alert_id,
			reminder,
			start_date,
			end_date,
			event_parent_id,
			event_length,
			source_id
		)
		SELECT	workflow_custom_activity_desc,
				'Custom Step',
				0,
				0,
				0,
				dbo.FNAConvertTimezone(@custom_schedule_date,1),
				dbo.FNAConvertTimezone(@custom_schedule_date,1),
				0,
				300,
				@custom_activity_id
		FROM workflow_custom_activities
		WHERE workflow_custom_activity_id = @custom_activity_id

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Custom activity has been successfully scheduled.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- Cancel the scheduled custom activity
ELSE IF @flag = 'f'
BEGIN
	BEGIN TRY
		
		DELETE ce FROM calendar_events ce
		WHERE ce.name = @custom_activity_desc AND ce.source_id = @custom_activity_id

		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Custom activity has been successfully canceled.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END

-- To remove workflow group in ignore list
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY

		DELETE wa
		FROM workflow_event_message wem
		INNER JOIN dbo.event_trigger et ON wem.event_trigger_id = et.event_trigger_id
		LEFT JOIN dbo.workflow_activities wa ON wa.workflow_trigger_id = et.event_trigger_id AND wa.event_message_id = wa.event_message_id AND wa.control_status = 737
				AND wa.source_column = @source_column AND wa.source_id = @source_id AND wa.workflow_group_id = @group_id
		WHERE et.modules_event_id = @module_event_id AND wa.workflow_activity_id IS NOT NULL
	
		EXEC spa_ErrorHandler 0,
             'Workflow Progress',
             'spa_workflow_progress',
             'Success',
             'Workflow Step has been removed from ignored list.',
             ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Workflow Progress',
             'spa_workflow_progress',
             'Error',
             'Fail',
             ''
	END CATCH
END