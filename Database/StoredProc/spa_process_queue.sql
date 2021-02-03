IF OBJECT_ID(N'dbo.spa_process_queue', N'P') IS NOT NULL
      DROP PROCEDURE dbo.spa_process_queue
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Operation for Process Queue functionality

	Parameters :
	@flag : Flag
			'create_process_queue' - Add the sql queries to the queue
			'execute_process_queue' - Executes the process queue sequentially
			'create_or_start_queue_job'
				o	If there is no job, it will create the job.
				o	If the job is not running , it will start the job.
	@process_queue_type : Process Queue Type (Static Data: Type ID - 112300)
	@source_id : Primary ID based on process_queue_type
	@queue_sql : SQL Query to be executed in the queue
	@process_id : Unique Identifier for process
	@description : Description
	@output_status : Return true/false
 */

CREATE PROCEDURE [dbo].[spa_process_queue]
	@flag				NVARCHAR(100),
	@process_queue_type	INT = NULL,
	@source_id			INT =  NULL,
	@queue_sql			NVARCHAR(MAX) = NULL,
	@process_id			NVARCHAR(100) = NULL,
	@description		NVARCHAR(MAX) = NULL,
	@output_status		NVARCHAR(100) OUTPUT

AS


SET @process_queue_type = ISNULL(@process_queue_type,112300)

IF @flag = 'create_process_queue'
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM process_queue WHERE process_id = @process_id)
		BEGIN
			UPDATE process_queue
			SET source_id = @source_id,
				is_processed = 'n',
				has_error = 'n',
				queue_sql = @queue_sql
			WHERE process_id = @process_id
		END
		ELSE
		BEGIN
			INSERT INTO process_queue (process_queue_type, source_id, queue_sql, process_id, is_processed, has_error, [description])
			SELECT @process_queue_type, @source_id, @queue_sql, @process_id, 'n', 'n', @description
		END
		SET @output_status = 'true'
	END TRY
	BEGIN CATCH
		SET @output_status = 'false'
	END CATCH
END

ELSE IF @flag = 'execute_process_queue'
BEGIN
	BEGIN TRY
		DECLARE @queue_log_retention_days INT = 0
		SELECT @queue_log_retention_days = ISNULL(var_value,0) FROM adiha_default_codes adc
		INNER JOIN adiha_default_codes_values adcv ON adc.default_code_id = adcv.default_code_id
		WHERE adc.default_code_id = 205

		DECLARE @process_user		NVARCHAR(100) = NULL,
				@process_queue_id	INT = NULL
		DECLARE @import_status_id INT, @ixp_notification_message_id INT
	
		SELECT @process_queue_id = MIN(process_queue_id) FROM process_queue 
		WHERE is_processed = 'n' AND create_ts >= DATEADD(dd,-2, GETDATE())
			AND process_queue_type = @process_queue_type

		WHILE(@process_queue_id IS NOT NULL)
		BEGIN
			BEGIN TRY
				UPDATE process_queue
				SET is_processed = 'p'
				WHERE process_queue_id = @process_queue_id 

				SET @queue_sql = NULL
				SET @process_user = NULL
				SET @process_id = NULL
				SET @process_queue_type = NULL
				SET @source_id = NULL

				SELECT	@queue_sql = queue_sql,
						@process_user = create_user,
						@process_id = process_id,
						@process_queue_type = process_queue_type,
						@source_id = source_id
				FROM process_queue
				WHERE process_queue_id = @process_queue_id

				UPDATE process_queue
				SET execution_start_ts = GETDATE()
				WHERE process_queue_id = @process_queue_id

				SET @queue_sql = ' DECLARE @contextinfo varbinary(128)
									SELECT @contextinfo = convert(varbinary(128),''' + @process_user + ''')
									SET CONTEXT_INFO @contextinfo
								 ' + @queue_sql
				EXEC(@queue_sql)

				UPDATE process_queue
				SET is_processed = 'y',
					has_error = 'n',
					execution_complete_ts = GETDATE()
				WHERE process_queue_id = @process_queue_id
			END TRY
			BEGIN CATCH
				UPDATE process_queue
				SET is_processed = 'y',
					has_error = 'y',
					error_description = ERROR_MESSAGE(),
					execution_complete_ts = GETDATE()
				WHERE process_queue_id = @process_queue_id

				IF @process_queue_type = 112300
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM source_system_data_import_status WHERE process_id = @process_id)
					BEGIN
						INSERT INTO source_system_data_import_status (
							Process_id,
							code,
							module,
							source,
							[type],
							[description],
							recommendation,
							rules_name
						)
						SELECT	@process_id,
								'Error' [code],
								'Import Data' [module],
								 ''	[source],
								 'Import Queue Error' [type],
								 'Technical Error - ' + ERROR_MESSAGE() [description],
								 'N/A' recommendation,
								 ixp_rules_name [rules_name]
						FROM ixp_rules
						WHERE ixp_rules_id = @source_id
					END
			
					SELECT @import_status_id = status_id FROM source_system_data_import_status WHERE process_id = @process_id
					SELECT @ixp_notification_message_id = error_message_id FROM ixp_import_data_source WHERE rules_id = @source_id

					IF @ixp_notification_message_id IS NOT NULL
					BEGIN
						EXEC spa_run_alert_message @module_id = 20634,
									@source_id = @import_status_id, 
									@event_message_id = @ixp_notification_message_id
					END
				END
			END CATCH

			SELECT @process_queue_id = MIN(process_queue_id) FROM process_queue 
			WHERE is_processed = 'n' AND process_queue_id > @process_queue_id
				AND process_queue_type = @process_queue_type
		END

		DELETE FROM process_queue
		WHERE is_processed = 'y' AND has_error = 'n'
		AND process_queue_type = @process_queue_type
		AND create_ts < DATEADD(d,@queue_log_retention_days * -1,GETDATE())
		
		DELETE FROM process_queue
		WHERE create_ts < DATEADD(dd,(@queue_log_retention_days * -1) - 1,GETDATE())
		AND process_queue_type = @process_queue_type

		SET @output_status = 'true'
	END TRY
	BEGIN CATCH
		SET @output_status = 'false'
	END CATCH
END

ELSE IF @flag = 'create_or_start_queue_job'
BEGIN
	BEGIN TRY
		DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
		DECLARE @queue_job_type NVARCHAR(100) 
		SELECT @queue_job_type = code 
			FROM static_data_value
			WHERE value_id =  @process_queue_type
		 
		DECLARE @queue_job_name NVARCHAR(100) = DB_NAME() + ' - Process Queue ' + @queue_job_type
		DECLARE @queue_job_query NVARCHAR(1000) = ' spa_process_queue @flag = ''execute_process_queue'', @process_queue_type = ' + CAST(@process_queue_type AS NVARCHAR) + ', @output_status = NULL '
		
		-- Sometime dupliate jobs are created with no steps. Added this code to delete those jobs with no steps.
		IF EXISTS(SELECT 1 FROM msdb.dbo.sysjobs_view sj
		LEFT JOIN msdb.dbo.sysjobsteps sjs ON sj.job_id = sjs.job_id
		WHERE sjs.job_id IS NULL AND sj.name = @queue_job_name)
		BEGIN
			IF OBJECT_ID('tempdb..#temp_job_list') IS NOT NULL
				DROP TABLE #temp_job_list

			SELECT sj.job_id
				INTO #temp_job_list
			FROM msdb.dbo.sysjobs_view sj
			LEFT JOIN msdb.dbo.sysjobsteps sjs ON sj.job_id = sjs.job_id
			WHERE sjs.job_id IS NULL AND sj.name = @queue_job_name

			DECLARE @del_job_id VARCHAR(200)
			WHILE EXISTS (SELECT 1 FROM #temp_job_list)
			BEGIN
				SELECT TOP(1) @del_job_id = job_id FROM #temp_job_list

				EXEC msdb.dbo.sp_delete_job  @job_id = @del_job_id;  

				DELETE FROM #temp_job_list WHERE job_id = @del_job_id
			END
		END

		DECLARE @queue_job_name_temp VARCHAR(1000) = 'Process Queue Import'
		--	While checking job existence include db name with job Eg. TRMTracker_Enercity_UAT - Process Queue Import 
		--	but this same name cannot be passed for spa_run_sp_as_job since it will add db name again error will be thrown same job existence
		IF NOT EXISTS(SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @queue_job_name)
		BEGIN
			EXEC spa_run_sp_as_job @queue_job_name_temp, @queue_job_query, 'ProcessQueue', @user_name
		END
		ELSE IF NOT EXISTS (
			SELECT 1
			FROM msdb.dbo.sysjobs_view job  
			INNER JOIN msdb.dbo.sysjobactivity activity ON job.job_id = activity.job_id 
			WHERE	activity.start_execution_date  IS NOT NULL
					AND activity.stop_execution_date IS NULL  
					AND job.name = @queue_job_name 
					AND NOT EXISTS(
						SELECT 1 FROM msdb..sysjobactivity new
						WHERE new.job_id = activity.job_id AND new.start_execution_date > activity.start_execution_date 
					)
		)
		BEGIN
			EXEC msdb.dbo.sp_start_job @queue_job_name
		END
		SET @output_status = 'true'
	END TRY
	BEGIN CATCH
		SET @output_status = 'false'
	END CATCH
END