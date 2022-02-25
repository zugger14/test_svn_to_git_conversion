DECLARE @job_db_name NVARCHAR(250) = DB_NAME()
DECLARE @job_owner NVARCHAR(100) = dbo.FNADBUser()
DECLARE @job_category NVARCHAR(150) = N'Import'
DECLARE @job_name NVARCHAR(500) = @job_db_name + N' - ' + @job_category + N' - Shaped Volume Power'

-- batch notification
DECLARE @role_id INT , @csv_file_path VARCHAR(5000), @role_id1 INT
IF NOT EXISTS(SELECT 1 FROM application_security_role WHERE role_name = 'Enercity Operations') 
BEGIN
	INSERT INTO application_security_role(role_name, role_description, role_type_value_id)
	SELECT 'Enercity Operations', 'Enercity Operations', 2
END

IF NOT EXISTS(SELECT 1 FROM application_security_role WHERE role_name = 'Enercity middle office') 
BEGIN
	INSERT INTO application_security_role(role_name, role_description, role_type_value_id)
	SELECT 'Enercity middle office', 'Enercity middle office', 2
END

SELECT @role_id = role_id FROM application_security_role WHERE ROLE_NAME = 'Enercity Operations'
SELECT @role_id1 = role_id FROM application_security_role WHERE ROLE_NAME = 'Enercity middle office'

SELECT @csv_file_path = document_path+'\temp_note' from connection_string

IF NOT EXISTS(SELECT 1 FROM batch_process_notifications WHERE process_id = 'zef42e2330j11' AND role_id = @role_id)
BEGIN
	INSERT INTO batch_process_notifications(role_id,process_id,notification_type,csv_file_path)
	SELECT @role_id,
		'zef42e2330j11',
		752,
		@csv_file_path	
END
ELSE
BEGIN
	UPDATE batch_process_notifications
	SET role_id = @role_id
		, notification_type = 752
	WHERE process_id = 'zef42e2330j11'
END

-- Removed 'Enercity Middle Office'
DELETE FROM batch_process_notifications WHERE process_id = 'zef42e2330j11' AND role_id = @role_id1

-- Added users list for notifications
IF OBJECT_ID('tempdb..#tmp_application_users') IS NOT NULL
	DROP TABLE #tmp_application_users

SELECT * INTO #tmp_application_users FROM (
SELECT 'Markus Richter' [user_name]
UNION ALL SELECT 'Oliver Studier'
UNION ALL SELECT 'Bernd Wallukat'
UNION ALL SELECT 'Fred Jansen'
UNION ALL SELECT 'Heike Reitz'
UNION ALL SELECT 'Maria Eggert'
) tau

INSERT INTO batch_process_notifications(user_login_id,process_id,notification_type,csv_file_path)
SELECT au.user_login_id
		,'zef42e2330j11'
		,752
		,@csv_file_path
		--select *
FROM #tmp_application_users tau
INNER JOIN application_users au ON tau.[user_name] = CONCAT (au.user_f_name,' ',au.user_l_name)
LEFT JOIN batch_process_notifications bpn ON bpn.user_login_id = au.user_login_id  AND bpn.process_id = 'zef42e2330j11' 
WHERE bpn.user_login_id IS NULL

DECLARE @command1 NVARCHAR(4000) = '
		DECLARE @file_transfer_endpoint_id INT
			, @target_remote_directory VARCHAR(500)
			, @rules_id INT
			, @result NVARCHAR(100)

		SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id
			, @target_remote_directory = imds.remote_directory
			, @rules_id = ir.ixp_rules_id
		FROM ixp_rules ir
		INNER JOIN ixp_import_data_source imds 
			ON ir.ixp_rules_id = imds.rules_id
		WHERE ir.ixp_rule_hash = ''A796978B_665C_46DA_9606_38FA73747158''
		
		IF OBJECT_ID(''tempdb..#ftp_dir_files'') IS NOT NULL 
			DROP TABLE tempdb..#ftp_dir_files
		CREATE TABLE #ftp_dir_files
		(
			ftp_url NVARCHAR(200), dir_file NVARCHAR(200)
		)

		INSERT INTO #ftp_dir_files
		EXEC spa_list_ftp_contents_using_clr @file_transfer_endpoint_id = @file_transfer_endpoint_id
			, @target_remote_directory = @target_remote_directory
			, @output_result = @result OUTPUT

		IF EXISTS( SELECT 1 FROM #ftp_dir_files fdf
				CROSS APPLY (
					VALUES 
					(''%.xlsx''),
					(''%.xls''),
					(''%.csv'')
				) AS ext (ext_type)
				WHERE dir_file like ext_type
			)
		BEGIN
			DECLARE @contextinfo varbinary(128)
			SELECT @contextinfo = convert(varbinary(128),''enercity_4442'')
			
			DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
			EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
			SET CONTEXT_INFO @contextinfo

			DECLARE @server_path VARCHAR(MAX)
			SELECT @server_path = document_path + ''\temp_Note'' FROM connection_string

			DECLARE @parameter NVARCHAR(MAX) = ''spa_ixp_rules @flag = ''''r'''',@ixp_rules_id = ''''''+CAST(@rules_id AS VARCHAR(50))+'''''',@server_path = ''''''+@server_path+'''''',@source = ''''21400'''',@enable_ftp = ''''1'''',@parameter_xml =		'''''''',@batch_process_id=''''PROCESS_ID:'''',@batch_report_param=''''spa_ixp_rules @flag = ''''''''r'''''''',@ixp_rules_id = ''''''''''+CAST(@rules_id AS VARCHAR(50))+'''''''''',@server_path =	''''''''''+@server_path+'''''''''',@source = ''''''''21400'''''''',@enable_ftp = ''''''''1'''''''',@parameter_xml =	 ''''''''''''''''''''''
			
		
			EXEC spa_run_sp_with_dynamic_params @parameter, ''zef42e2330j11'', NULL
		END
		'
	
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
--delete job if already exists
IF EXISTS(SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1

IF NOT EXISTS(SELECT [name] FROM msdb.dbo.syscategories WHERE [name] = @job_category AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@job_category
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
	@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
	@description=N'BatchReport', 
	@category_name=@job_category, 
	@owner_login_name=@job_owner, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=2, 
		@on_fail_action=2, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL',  
	    @command=@command1, 
	    @database_name=@job_db_name,
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'24X7', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200625, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235900
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
