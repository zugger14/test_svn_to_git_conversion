IF OBJECT_ID(N'spa_run_multi_step_job', N'P') IS NOT NULL
    DROP PROCEDURE spa_run_multi_step_job
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
 This proc will be used to create multi steps job. It supports upto 6 steps.
 Each steps which are to be executed should be kept in 6 different steps.
 Each steps should be given in sequential order, any step should not be skipped.
 Parameters
	@job_name : Name of the job.
	@job_description : Description of job.
	@step1 : First SQL Command to be executed.
	@step2 : Second SQL Command to be executed.
	@step3 : Third SQL Command to be executed.
	@step4 : Forth SQL Command to be executed.
	@step5 : Fifth SQL Command to be executed.
	@step6 : Sixth SQL Command to be executed.
	@process_id : Process ID
*/
CREATE PROCEDURE spa_run_multi_step_job
		@job_name VARCHAR(500),
		@job_description VARCHAR(500) = NULL,
		@step1 VARCHAR(MAX) = NULL,
		@step2 VARCHAR(MAX) = NULL,
		@step3 VARCHAR(MAX) = NULL,
		@step4 VARCHAR(MAX) = NULL,
		@step5 VARCHAR(MAX) = NULL,
		@step6 VARCHAR(MAX) = NULL,
		@process_id VARCHAR(50) = NULL
AS
/*------------------Debug Section-------------------
--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
--SET CONTEXT_INFO @contextinfo
DECLARE @job_name VARCHAR(500),
	    @job_category VARCHAR(500),
		@job_description VARCHAR(500),
		@step1 VARCHAR(MAX),
		@step2 VARCHAR(MAX),
		@step3 VARCHAR(MAX),
		@step4 VARCHAR(MAX),
		@step5 VARCHAR(MAX),
		@step6 VARCHAR(MAX),
		@process_id VARCHAR(500)

SELECT @job_name = 'Test Job',
	   @job_category = '',
	   @step1 = 'insert into job_session_test select 1,1',
	   @step2 = 'insert into job_session_test select ''as'',1',
	   @step3 = null,
	   @step4 = null,
	   @step5 = null,
	   @step6 = null,
	   @process_id = null
------------------------------------------------*/
DECLARE @db_name VARCHAR(100) = DB_NAME(),
		@user_name VARCHAR(100) = dbo.FNADBUser(),
		@error_validation_step VARCHAR(MAX),
		@error_description VARCHAR(1000),
		@on_success_action TINYINT,
		@step_id TINYINT = 1,
		@error_validation_step_id TINYINT,
		@job_id BINARY(16),
		@step_error_log_table VARCHAR(1000)

IF @process_id IS NULL
BEGIN
	SET @process_id = dbo.FNAGetNewID()
END

SET @job_name = @db_name + ' - ' + @job_name + '_' + @user_name + '_' + @process_id
SET @step_error_log_table = dbo.FNAProcessTableName('step_error_log', @user_name, @process_id)

SET @error_validation_step = '
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser(), @error_step VARCHAR(100), @err_message VARCHAR(1000)

	SELECT @error_step = s.step_name
	FROM ' + @step_error_log_table + ' a
	INNER JOIN msdb.dbo.sysjobsteps s ON s.job_id = a.job_id
		AND s.step_id = a.step_id

	SET @err_message =  ''Job <i>' + @job_name + '</i> failed to run. Error in <b>'' + @error_step + ''</b>.''

	EXEC ' + @db_name + '.dbo.spa_message_board ''i'', @user_name, NULL, ''Multi Step Job'', @err_message, '''', '''', ''e'', NULL

	IF OBJECT_ID(''' + @step_error_log_table + ''') IS NOT NULL
		DROP TABLE ' + @step_error_log_table + '
'

SET @step1 = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')	
	SET CONTEXT_INFO @contextinfo
	GO

	IF OBJECT_ID(''' + @step_error_log_table + ''') IS NOT NULL
		DROP TABLE ' + @step_error_log_table + '

	CREATE TABLE ' + @step_error_log_table + ' (
		error_log_id INT PRIMARY KEY IDENTITY(1, 1),
		job_id UNIQUEIDENTIFIER,
		step_id INT,
		step_name VARCHAR(100)
	)

	INSERT INTO ' + @step_error_log_table + '
	VALUES ($(ESCAPE_NONE(JOBID)), 1, ''Step 1'')
' + @step1

SET @step2 = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')
	SET CONTEXT_INFO @contextinfo	
	GO

	DELETE FROM ' + @step_error_log_table + '
	INSERT INTO ' + @step_error_log_table + '
	VALUES ($(ESCAPE_NONE(JOBID)), 2, ''Step 2'')
' + @step2

SET @step3 = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')
	SET CONTEXT_INFO @contextinfo
	GO

	DELETE FROM ' + @step_error_log_table + '
	INSERT INTO ' + @step_error_log_table + '
	VALUES ($(ESCAPE_NONE(JOBID)), 3, ''Step 3'')
' + @step3

SET @step4 = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')
	SET CONTEXT_INFO @contextinfo
	GO

	DELETE FROM ' + @step_error_log_table + '
	INSERT INTO ' + @step_error_log_table + '
	VALUES ($(ESCAPE_NONE(JOBID)), 4, ''Step 4'')
' + @step4

SET @step5 = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')
	SET CONTEXT_INFO @contextinfo
	GO

	DELETE FROM ' + @step_error_log_table + '
	INSERT INTO ' + @step_error_log_table + '
	VALUES ($(ESCAPE_NONE(JOBID)), 5, ''Step 5'')
' + @step5

SET @step6 = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')
	SET CONTEXT_INFO @contextinfo
	GO

	DELETE FROM ' + @step_error_log_table + '
	INSERT INTO ' + @step_error_log_table + '
	VALUES ($(ESCAPE_NONE(JOBID)), 6, ''Step 6'')
' + @step6

SET @error_validation_step = '
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), ''' + @user_name + ''')
	SET CONTEXT_INFO @contextinfo
	GO	
' + @error_validation_step

BEGIN TRY
	BEGIN TRANSACTION
	IF NOT EXISTS(SELECT 1 FROM msdb.dbo.sysjobs where name = @job_name)
	BEGIN
	--Add the job.
	EXEC msdb.dbo.sp_add_job @job_name = @job_name, 
							 @enabled = 1,
							 @description = @job_description,
							 --@owner_login_name  = @user_name,
							 @delete_level = 1,
							 @job_id = @job_id OUTPUT
	
	--Determining the error validation step id on the basis of number of job steps presence
	SET @error_validation_step_id = CASE 
										 WHEN @step1 IS NOT NULL AND @step2 IS NULL AND @step3 IS NULL AND @step4 IS NULL AND @step5 IS NULL AND @step6 IS NULL THEN 2 
										 WHEN @step1 IS NOT NULL AND @step2 IS NOT NULL AND @step3 IS NULL AND @step4 IS NULL AND @step5 IS NULL AND @step6 IS NULL THEN 3 
										 WHEN @step1 IS NOT NULL AND @step2 IS NOT NULL AND @step3 IS NOT NULL AND @step4 IS NULL AND @step5 IS NULL AND @step6 IS NULL THEN 4 
										 WHEN @step1 IS NOT NULL AND @step2 IS NOT NULL AND @step3 IS NOT NULL AND @step4 IS NOT NULL AND @step5 IS NULL AND @step6 IS NULL THEN 5 
										 WHEN @step1 IS NOT NULL AND @step2 IS NOT NULL AND @step3 IS NOT NULL AND @step4 IS NOT NULL AND @step5 IS NOT NULL AND @step6 IS NULL THEN 6
										 WHEN @step1 IS NOT NULL AND @step2 IS NOT NULL AND @step3 IS NOT NULL AND @step4 IS NOT NULL AND @step5 IS NOT NULL AND @step6 IS NOT NULL THEN 7 
									END

	-- Add the first job step, it is mandatory to have at least a single step as an input
	SET @on_success_action = IIF(@step2 IS NULL, 1, 3) --this is the action done after successful execution of step 1. if step 2 is present then the value is 3 that means go to next step if not 1 which is exit with success.

	EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id,
								 @step_name = N'Step1',
								 @step_id = @step_id,
								 @on_success_action = @on_success_action,
								 @on_fail_action = 4,
								 @on_fail_step_id = @error_validation_step_id,
								 @subsystem = N'TSQL',
								 @command = @step1,
								 @database_name = @db_name
	--Job description update logic is implemented to track the step where the error is occurred, which is used in error step for messaging.
	EXEC msdb.dbo.sp_update_job @job_name = @job_name, @description = 'Step 1';

	--Add step 2 if it is present, it is not mandatory.
	IF @step2 IS NOT NULL
	BEGIN
		SET @on_success_action = IIF(@step3 IS NULL, 1, 3) 
		SET @step_id = @step_id + 1 -- incremented the the job step id in sequential order

		EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id,
									 @step_name = N'Step2',
									 @step_id = @step_id,
									 @on_success_action = @on_success_action,
									 @on_fail_action = 4,
									 @on_fail_step_id = @error_validation_step_id,
									 @subsystem = N'TSQL',
									 @command = @step2,
									 @database_name = @db_name

		--Job description update logic is implemented to track the step where the error is occurred, which is used in error step for messaging.
		EXEC msdb.dbo.sp_update_job @job_name = @job_name, @description = 'Step 2';
	END

	--Add step 3 if it is present, it is not mandatory.
	IF @step3 IS NOT NULL
	BEGIN
		SET @step_id = @step_id + 1
		SET @on_success_action = IIF(@step4 IS NULL, 1, 3)
		
		EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id,
									 @step_name = N'Step3',
									 @step_id = @step_id,
									 @on_success_action = @on_success_action,
									 @on_fail_action = 4,
									 @on_fail_step_id = @error_validation_step_id,
									 @subsystem = N'TSQL',
									 @command = @step3,
									 @database_name = @db_name

		--Job description update logic is implemented to track the step where the error is occurred, which is used in error step for messaging.
		EXEC msdb.dbo.sp_update_job @job_name = @job_name, @description = 'Step 3';
	END

	--Add step 4 if it is present, it is not mandatory.
	IF @step4 IS NOT NULL
	BEGIN
		SET @on_success_action = IIF(@step5 IS NULL, 1, 3)
		SET @step_id = @step_id + 1

		EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id,
									 @step_name = N'Step4',
									 @step_id = @step_id,
									 @on_success_action = @on_success_action,
									 @on_fail_action = 4,
									 @on_fail_step_id = @error_validation_step_id,
									 @subsystem = N'TSQL',
									 @command = @step4,
									 @database_name = @db_name
	
		--Job description update logic is implemented to track the step where the error is occurred, which is used in error step for messaging.
		EXEC msdb.dbo.sp_update_job @job_name = @job_name, @description = 'Step 4';
	END

	--Add step 5 if it is present, it is not mandatory.
	IF @step5 IS NOT NULL
	BEGIN
		SET @on_success_action = IIF(@step6 IS NULL, 1, 3)
		SET @step_id = @step_id + 1
		EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id,
									 @step_name = N'Step5',
									 @step_id = @step_id,
									 @on_success_action = @on_success_action,
									 @on_fail_action = 4,
									 @on_fail_step_id = @error_validation_step_id,
									 @subsystem = N'TSQL',
									 @command = @step5,
									 @database_name = @db_name

		--Job description update logic is implemented to track the step where the error is occurred, which is used in error step for messaging.
		EXEC msdb.dbo.sp_update_job @job_name = @job_name, @description = 'Step 5';
	END

	--Add step 6 if it is present, it is not mandatory.
	IF @step6 IS NOT NULL
	BEGIN
		SET @step_id = @step_id + 1
		EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id,
									 @step_name = N'Step6',
									 @step_id = @step_id,
									 @on_success_action = 1,
									 @on_fail_action = 4,
									 @on_fail_step_id = @error_validation_step_id,
									 @subsystem = N'TSQL',
									 @command = @step6,
									 @database_name = @db_name

		--Job description update logic is implemented to track the step where the error is occurred, which is used in error step for messaging.
		EXEC msdb.dbo.sp_update_job @job_name = @job_name, @description = 'Step 6';
	END

	--Added the job step in case of step execution order
	EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id, @step_name = N'ErrorStep', @step_id = @error_validation_step_id, @on_success_action = 1, @on_fail_action = 2, @subsystem = N'TSQL', @command = @error_validation_step, @database_name = @db_name
	EXEC msdb.dbo.sp_update_job @job_id = @job_id, @start_step_id = 1
	EXEC msdb.dbo.sp_add_jobserver @job_id = @job_id, @server_name = N'(local)'
	
	--Run the job.
	EXEC msdb.dbo.sp_start_job @job_name = @job_name, @output_flag = 0
	END
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SET @error_description = 'Error while creating Multi Step Job: ' + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC spa_print @error_description
	
	SET @error_description = 'Failed to create the job: ' + @job_name
	EXEC spa_message_board 'i', @user_name, NULL, @job_name, @error_description, '', '', 'e', NULL	
END CATCH
GO