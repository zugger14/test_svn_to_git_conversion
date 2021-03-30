
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_sp_as_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_sp_as_job]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Used to run stored procedure as job.

	Parameters
	@run_job_name : Name of the job.
	@spa : Name of stored procedure which is to be run as job.
	@proc_desc : Description of Stored procedure
	@user_login_id : User login id of the account.
	@job_subsystem : SSIS for creating job SSIS package.
	@system_id : ID of the system.
	@flag : To determine the request for IMPORT Source System.

*/
CREATE PROCEDURE [dbo].[spa_run_sp_as_job] 
		 @run_job_name varchar(1000)
		,@spa varchar(max)
		,@proc_desc varchar (100)
		,@user_login_id varchar(50)
		,@job_subsystem VARCHAR(100)='TSQL' -- SSIS for creating job SSIS package
		,@system_id varchar(10)=NULL
		,@flag char(1)=NULL -- To determine the request for IMPORT Source System
AS

SET NOCOUNT ON

		DECLARE @db_name varchar(50)
		-- 1 means true 0 means false
		DECLARE @error_found int
		DECLARE @source varchar(20), @source_system_name varchar(100)
		DECLARE @user_name varchar(25)
		DECLARE @spa_failed VARCHAR(500),@spa_queue VARCHAR(1000)
		DECLARE @desc varchar(500),@msg varchar(500)
		DECLARE @ssispath VARCHAR(1000),@root VARCHAR(1000),@configfile VARCHAR(1000)
		DECLARE @context_info NVARCHAR(MAX)
		DECLARE @job_description NVARCHAR(1000)

		if @system_id IS NOT NULL
			SELECT @source_system_name = source_system_name from source_system_description WHERE source_system_id=@system_id
		ELSE
			SET @source_system_name=NULL   

		SET @user_name =ISNULL( @user_login_id,dbo.FNADBUser())
		SET @error_found = 0
		SET @db_name = db_name()
		
		SET @context_info ='DECLARE @contextinfo varbinary(128)
							SELECT @contextinfo = convert(varbinary(128),'''+@user_name+''')
							DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
							EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
							SET CONTEXT_INFO @contextinfo
							GO
							'
		SET @job_subsystem = ISNULL(@job_subsystem,'TSQL')

		SET @desc = 'Job  ' + @run_job_name + ' failed.'
		SET @spa_failed = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' +
					 @desc + ''', '''', '''', ''e'', NULL'
		SET @run_job_name = @db_name + ' - ' + @run_job_name
		--DECLARE @db_name varchar(100), @flag varchar(100), @proc_desc varchar(200),@spa_queue VARCHAR(1000), @run_job_name varchar(100)
		--SET @db_name = db_name()
		--SET @proc_desc='y'
		--SET @flag='y'
		--SET @run_job_name='Test'

		SET @spa_queue = 'EXEC ' + @db_name + '.dbo.spa_job_queue ''' + @run_job_name + ''','''  + @source_system_name + ''','''  + @flag + ''''
		--PRINT @spa_queue
		DECLARE @proxy_name VARCHAR(100)

		IF @job_subsystem ='SSIS'
			SELECT @proxy_name= MAX(sql_proxy_account) FROM connection_string

		SET @job_description = 'Created by: ' + @user_name + CHAR(13) + 'No description available.' --CHAR(13) used to seperate username and description
		EXEC msdb.dbo.sp_add_job
					@job_name = @run_job_name,
					--@owner_login_name='sa',
					@delete_level = 1,
					@description = @job_description

		If @@ERROR = 0 
		BEGIN
			--From view schedule job menu original jobid is included in @spa 
			IF (CHARINDEX('JobID:', @spa) > 0)
			BEGIN
				DECLARE @command NVARCHAR(MAX)
					, @job_step_id INT
					, @job_step_name sysname
					, @success_action tinyint
					, @success_step INT
					, @fail_action tinyint
					, @fail_step INT

				DECLARE cur_job_sch CURSOR LOCAL FAST_FORWARD FOR 
				SELECT  REPLACE(REPLACE(RIGHT(command, LEN(command) - CHARINDEX('GO', command) - IIF(CHARINDEX('GO', command)>0,1,0)) ,CHAR(13),' '),CHAR(10),' ') command
					, step_id, step_name
					, on_success_action
					, on_success_step_id
					, on_fail_action
					, on_fail_step_id 
				FROM msdb.dbo.sysjobsteps
				WHERE job_id =  REPLACE(@spa,'JobID:','')
				ORDER BY step_id

				OPEN cur_job_sch ; 
				FETCH NEXT FROM cur_job_sch INTO @command, @job_step_id, @job_step_name, @success_action, @success_step, @fail_action,@fail_step
				WHILE @@FETCH_STATUS = 0 
				BEGIN 
					IF @job_step_id = 1
					  SET @command = @context_info + @command

						  -- Add the job steps
						EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
		   							@step_id = @job_step_id,
		   							@step_name = @job_step_name,
		   							@subsystem = 'TSQL',
									@on_success_action = @success_action, 							
									@on_success_step_id = @success_step,
									@on_fail_action = @fail_action,
									@on_fail_step_id = @fail_step,
		   							@command = @command,
									@database_name = @db_name
					
					  FETCH NEXT FROM cur_job_sch INTO @command, @job_step_id, @job_step_name, @success_action, @success_step, @fail_action,@fail_step 
				END 
				CLOSE cur_job_sch  
				DEALLOCATE cur_job_sch 
			END
			ELSE
			BEGIN
				IF @job_subsystem  ='TSQL'
					SET  @spa ='EXEC ' + @spa
			
			
				IF @job_subsystem = 'TSQL'
				BEGIN
					SET @spa = @context_info + @spa
				END
			

				IF @flag='y'
				BEGIN

						EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
	   							@step_id = 1,
	   							@step_name = 'Step1',
	   							@subsystem = @job_subsystem, --'TSQL',
								@on_fail_action =3,
								@on_success_action =4,
								@on_success_step_id = 3, 
								@on_fail_step_id = 2,
	   							@command = @spa,
								@database_name = @db_name,
								@proxy_name = @proxy_name
							
						EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
		   						@step_id = 2,
		   						@step_name = 'Step2',
		   						@subsystem = 'TSQL',
								@on_success_action =4,
								@on_success_step_id = 3,
								@on_fail_action=2, 
								@on_fail_step_id=0, 
								@command = @spa_failed,
								@database_name = @db_name
						
						EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
	   							@step_id = 3,
	   							@step_name = 'Step3',
	   							@subsystem = 'TSQL', --'TSQL',
								@on_success_action =1, 
								@command = @spa_queue,
								@database_name = @db_name

				END
				ELSE
				BEGIN
						EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
   								@step_id = 1,
   								@step_name = 'Step1',
   								@subsystem = @job_subsystem, --'TSQL',
								@on_fail_action =3,
								@on_success_action =1, 
								@on_fail_step_id = 2,
   								@command = @spa,
								@database_name = @db_name
						
						EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
	   							@step_id = 2,
	   							@step_name = 'Step2',
	   							@subsystem = 'TSQL',
								@on_success_action=2, 
								@on_success_step_id=0, 
								@on_fail_action=2, 
								@on_fail_step_id=0, 
	   							@command = @spa_failed,
								@database_name = @db_name

				END

			END

			If @@ERROR = 0
			BEGIN
				EXEC msdb.dbo.sp_add_jobserver @job_name = @run_job_name
				
				If @@ERROR = 0
				BEGIN
					if @flag='y' AND @source_system_name IS NOT NULL
					BEGIN

--						if NOT EXISTS(SELECT [name] FROM  msdb.dbo.sysjobs_view where [name]<> @run_job_name AND [name] LIKE 'importdata%')
						IF NOT EXISTS (	
							SELECT 1 FROM dbo.farrms_sysjobactivity a INNER JOIN msdb.dbo.sysjobs_view v ON a.job_id=v.job_id 
							WHERE v.[name]<> @run_job_name AND 
							v.[name]<> 'ImportData_'+dbo.FNAGetSplitPart(@run_job_name,'importdata_pipelinecut_',2) AND
							(v.[name] LIKE 'importdata%' OR v.[name] LIKE 'endur_import_data_%') AND a.stop_execution_date IS null
							AND a.schedule_id IS NULL
							)
							
						BEGIN
							EXEC msdb.dbo.sp_start_job @job_name = @run_job_name
							SET @msg='Your Ad-hoc import data process has been run and will complete shortly.'
							
						END
						ELSE
							SET @msg='Your Ad-hoc import data process is in queue and will start shortly.'
						--PRINT @msg
					END
					ELSE
						EXEC msdb.dbo.sp_start_job @job_name = @run_job_name,@output_flag=0

					If @@ERROR = 0
					BEGIN
						--SUCCESS
						SET @error_found = 0
					END
					ELSE	
					BEGIN
						--ERROR found
						SET @error_found = @@ERROR
						SET @source = 'start_job'
					END
				END
				ELSE
				BEGIN
					--ERROR found
					SET @error_found = @@ERROR
					SET @source = 'add_jobserver'
				END
			END
			ELSE
			BEGIN
				--ERROR found
				SET @error_found = @@ERROR
				SET @source = 'add_jobstep'	
			END
		END
		ELSE
		BEGIN
			--ERROR found
			SET @error_found = @@ERROR
			SET @source = 'add_job'
		END

		If @error_found > 0
		BEGIN
			SET @desc = 'Failed to run schedule process ' + @run_job_name
			EXEC  spa_message_board 'i', @user_name, NULL, @proc_desc,
					 @desc, '', '', 'e', NULL
		END
--		if (@error_found=0 AND @flag='y')
--			EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @msg,
--					'', '', 's', @run_job_name, NULL, NULL

		IF @flag = 'i' -- call from import
		BEGIN			
			EXEC spa_ErrorHandler 0,
				'Data Import',
				'spa_ixp_rules',
				'Import Success.',
				'Import process started successfully. Please check status in message board.',
				''
		END

