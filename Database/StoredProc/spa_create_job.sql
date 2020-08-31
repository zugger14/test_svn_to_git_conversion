IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_create_job]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_job]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_create_job] 
		 @run_job_name VARCHAR(1000)
		,@spa VARCHAR(MAX)
		,@spa_success VARCHAR(MAX) = NULL
		,@spa_failed VARCHAR(MAX) = NULL
		,@proc_desc VARCHAR (100)
		,@user_login_id VARCHAR(50)
		,@job_subsystem VARCHAR(100)='TSQL' -- TSQL or SSIS
AS

		DECLARE @db_name VARCHAR(50) = DB_NAME(),
				@error_found INT = 0,
				@source VARCHAR(20), 
				@user_name VARCHAR(25) = ISNULL( @user_login_id,dbo.FNADBUser()),
				@desc VARCHAR(500)
		
		SET @run_job_name = @db_name + ' - ' + @run_job_name
		EXEC msdb.dbo.sp_add_job 
					@job_name = @run_job_name,
					--@owner_login_name='sa',
					@delete_level = 1,
					@description = @user_name

		IF @@ERROR = 0 
		BEGIN
			SET @desc = 'Process ' + @run_job_name + ' completed successfully.'
	 		IF @spa_success IS NULL
	 			SET @spa_success = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' +
					 @desc + ''', '''', '''', ''s'', NULL'
					 			
			SET @desc = 'Job ' + @run_job_name + ' failed.'
	 		IF @spa_failed IS NULL
	 			SET @spa_failed = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' +
					 @desc + ''', '''', '''', ''e'', NULL'


			IF ISNULL(@job_subsystem,'TSQL')  ='TSQL'
				SET  @spa='EXEC ' + @spa
			SET @job_subsystem=ISNULL(@job_subsystem,'TSQL')
			
			IF @job_subsystem = 'TSQL'
			BEGIN
				SET @spa='DECLARE @contextinfo varbinary(128)
				SELECT @contextinfo = convert(varbinary(128),'''+@user_name+''')
				SET CONTEXT_INFO @contextinfo
				DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
				EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
				GO
				'+@spa
			END
			
			DECLARE @proxy_name VARCHAR(100)
			IF @job_subsystem='SSIS'
				SELECT @proxy_name= MAX(sql_proxy_account) FROM connection_string

			-- main step
			EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
					@step_id = 1,
					@step_name = 'Step1',
					@subsystem = @job_subsystem, --'TSQL',
					@on_fail_action =4,
					@on_fail_step_id = 2, -- on fail goto step 2
					@on_success_action =4,
					@on_success_step_id = 3, -- on success goto step 3 
					@command = @spa,
					@database_name = @db_name,
					@proxy_name = @proxy_name
			
			-- fail step		
			EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
   					@step_id = 2,
   					@step_name = 'Step2',
   					@subsystem = 'TSQL',
					@on_success_action = 2, 
					@on_success_step_id = 0, 
					@on_fail_action = 2, 
					@on_fail_step_id = 0, 
					@command = @spa_failed,
					@database_name = @db_name
			
			-- success step	
			EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
					@step_id = 3,
					@step_name = 'Step3',
					@subsystem = 'TSQL',
					@on_success_action =1, 
					@command = @spa_success,
					@database_name = @db_name

			IF @@ERROR = 0
			BEGIN
				EXEC msdb.dbo.sp_add_jobserver @job_name = @run_job_name
				IF @@ERROR = 0
				BEGIN
					EXEC msdb.dbo.sp_start_job @job_name = @run_job_name
					
					EXEC spa_print 'Your Ad-hoc import data process has been run and will complete shortly.'

					IF @@ERROR = 0
					BEGIN
						--SUCCESS
						SET @error_found = 0
					END
					ELSE	
					BEGIN
						SET @error_found = @@ERROR -- error found in start_job
						SET @source = 'start_job'
					END
				END
				ELSE
				BEGIN
					SET @error_found = @@ERROR -- error found in add_jobserver
					SET @source = 'add_jobserver'
				END
			END
			ELSE
			BEGIN
				SET @error_found = @@ERROR -- error found in add_jobstep
				SET @source = 'add_jobstep'	
			END
		END
		ELSE
		BEGIN
			SET @error_found = @@ERROR -- error found in add_job
			SET @source = 'add_job'
		END

		IF @error_found > 0
		BEGIN
			SET @desc = 'Failed to run schedule process ' + @run_job_name + '. Error Code: ' + CAST(@error_found AS VARCHAR(10)) + 
			'. Error in ' + @source + '. Please contact technical support.'

			EXEC  spa_message_board 'i', @user_name, NULL, @proc_desc, @desc, '', '', 'e', NULL
			EXEC spa_print @desc
		END

