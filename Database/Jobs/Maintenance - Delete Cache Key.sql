DECLARE @job_db_name NVARCHAR(250) = DB_NAME()
DECLARE @job_owner NVARCHAR(100) = SYSTEM_USER
DECLARE @job_category NVARCHAR(150) = N'Maintenance'
DECLARE @job_name NVARCHAR(500) = @job_db_name + N' - ' + @job_category + N' - Delete cache keys'

/****** Object:  Job [Delete cache keys]    Script Date: 6/21/2018 12:42:16 PM ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @job_name)
    EXEC msdb.dbo.SP_DELETE_JOB @job_name = @job_name, @delete_unused_schedule = 1

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

--Add if category not exists.
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@job_category AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.SP_ADD_CATEGORY @CLASS=N'JOB', @type=N'LOCAL', @name=@job_category
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Delete keys failed to remove from cache server due to connection issue.', 
		@category_name=@job_category, 
		@owner_login_name=@job_owner, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete Cache Key]    Script Date: 6/21/2018 12:42:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete Cache Key', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @url_address		NVARCHAR(500),
		@post_data				NVARCHAR(MAX),
		@user_login_id			NVARCHAR(100) = dbo.FNADBUser(), 
		@db						VARCHAR(100) = db_name(),
		@msg					NVARCHAR(MAX),
		@http_response			NVARCHAR(MAX),
		@dt datetime = getdate()
			
IF OBJECT_ID(''[dbo].[memcache_log]'') IS NOT NULL
BEGIN
	DELETE FROM [dbo].[memcache_log] WHERE DATEDIFF(day, create_ts, getdate()) > 1

	DECLARE @session_data			NVARCHAR(MAX)
		, @filtered_session_data	NVARCHAR(MAX)
		, @final_key_list			NVARCHAR(MAX)
	
	SELECT TOP 1 @session_data = session_data FROM trm_session where is_active = 1 AND session_data like ''%farrms_client_dir%'' ORDER BY create_ts DESC
	
	--DROP TABLE #cache_key
	SELECT DISTINCT REPLACE(SUBSTRING([cache_key_prefix] ,0,CHARINDEX(''&farrms_client_dir'',[cache_key_prefix] )),''prefix='','''') cache_key
	INTO  #cache_key
	FROM [dbo].[memcache_log]
	WHERE ''Keys Deleted.'' <>  REPLACE(REPLACE(status, CHAR(13), ''''), CHAR(10), '''')


	--declare @final_key_list	NVARCHAR(MAX)
	IF EXISTS(SELECT 1 FROM #cache_key)
	BEGIN
		SELECT @filtered_session_data = COALESCE(@filtered_session_data + ''&'','''')  + substring(item,0,charindex(''|'',item)) + ''='' + 
			REPLACE(REPLACE(RIGHT(item,  CHARINDEX('':'',REVERSE(item))-1),'';'',''''),''"'','''')
		FROM dbo.FNASplit(@session_data,'';'')
		WHERE item like ''%farrms_client_dir%'' --OR item LIKE ''%enable_data_caching%''

		SELECT @final_key_list = COALESCE(@final_key_list + '','','''') + ckp.item
		FROM #cache_key ml
		OUTER APPLY dbo.SplitCommaSeperatedValues(ml.[cache_key]) ckp
		GROUP BY ckp.item

		SELECT @url_address = SUBSTRING(file_attachment_path,0,CHARINDEX(''adiha.php.scripts'',file_attachment_path,0)+17)  
									+ ''/components/process_cached_data.php''
				 , @post_data = ''prefix='' + @final_key_list + ''&'' + @filtered_session_data 
		FROM connection_string
		--select @url_address,@post_data
		IF @post_data IS NOT NULL
		BEGIN
			EXEC spa_push_notification  @url_address,@post_data ,''n'',@msg output,@http_response output
				--select @url_address,@post_data,@http_response	
	
			UPDATE t
			SET [status] = @http_response
				, update_ts = getdate()
				, update_user = @user_login_id
			FROM [dbo].memcache_log t
			INNER JOIN #cache_key t1 ON  REPLACE(SUBSTRING([cache_key_prefix] ,0,CHARINDEX(''&farrms_client_dir'',[cache_key_prefix] )),''prefix='','''') = t1.cache_key
		END
	END
END', 
		@database_name=@job_db_name, 
		@flags=0

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule Delete Cache key', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180621, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


