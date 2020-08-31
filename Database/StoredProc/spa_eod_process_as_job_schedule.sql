IF OBJECT_ID('spa_eod_process_as_job_schedule','p') IS NOT NULL
	DROP PROC [dbo].[spa_eod_process_as_job_schedule] 
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Log EOD Process.
--              
-- Params:
-- @run_job_name VARCHAR(100) - Job Name
-- @spa VARCHAR(5000) - SQL
-- @proc_desc VARCHAR (100) - SQL Desc
-- @user_login_id VARCHAR(50) - farrms_admin
-- @job_subsystem VARCHAR(100) = 'SSIS'
-- @run_type INT = NULL - Steps
-- @master_process_id VARCHAR(120) = NULL
-- @process_id VARCHAR(120) = NULL
-- @as_of_date VARCHAR(10) = NULL - Date 
-- @active_start_date INT = NULL - Date
-- @active_start_time INT = NULL - Date
-- @freq_type INT = NULL 
-- @freq_interval INT = NULL
-- @freq_subday_type INT = NULL
-- @freq_subday_interval INT = NULL
-- @freq_relative_interval INT = NULL
-- @freq_recurrence_factor INT = NULL 
-- @active_end_date INT = NULL - Date
-- @active_end_time INT = NULL - Date	
-- @exec_only_this_step INT = 0 -- 1 for single step execution, default 0 for serial execution
-- ============================================================================================================================

/**
	Creates Scheduled SQL job of EOD Log EOD Process

	Parameters 
	@run_job_name : Job Name
	@spa : SQL String to be executed via job
	@proc_desc : Not in use
	@user_login_id : User Login Id of the user
	@job_subsystem : 'SSIS' for creating job SSIS package
	@run_type : ID of EOD task
	@master_process_id : Master Process Id
	@process_id : Process Id
	@as_of_date : As Of Date of EOD process
	@active_start_date : Job Schedule Start Date
	@active_start_time : Job Schedule Start Time
	@freq_type : Frequency of Job
	@freq_interval : Frequency Interval of Job 
	@freq_subday_type : Frequency Subday Type
	@freq_subday_interval : Frequency Subday Interval
	@freq_relative_interval : Frequency Relative Interval
	@freq_recurrence_factor : Frequency Recurrence Factor
	@active_end_date : Job Schedule End Date
	@active_end_time : Job Schedule Active End Time
	@exec_only_this_step : 1 for single execution, 0 from serial execution

*/

CREATE PROCEDURE [dbo].[spa_eod_process_as_job_schedule] 
	@run_job_name VARCHAR(1000), 
	@spa VARCHAR(5000), 
	@proc_desc VARCHAR (100), 
	@user_login_id VARCHAR(50), 
	@job_subsystem VARCHAR(100) = 'SSIS', 
	@run_type INT = NULL, 
	@master_process_id VARCHAR(120) = NULL, 
	@process_id VARCHAR(120) = NULL, 
	@as_of_date VARCHAR(10) = NULL, 
	@active_start_date INT = NULL, 
	@active_start_time INT = NULL, 
	@freq_type INT = NULL, 
	@freq_interval INT = NULL, 
	@freq_subday_type INT = NULL, 
	@freq_subday_interval INT = NULL, 
	@freq_relative_interval INT = NULL, 
	@freq_recurrence_factor INT = NULL, 
	@active_end_date INT = NULL, 
	@active_end_time INT = NULL,
	@exec_only_this_step INT = 0	
AS

	DECLARE @db_name      VARCHAR(50),
	        @user_name    VARCHAR(50),
	        @spa_failed   VARCHAR(500),
	        @spa_success  VARCHAR(500),
	        @desc         VARCHAR(500),
	        @msg          VARCHAR(500),
	        @job_ID       BINARY(16),
	        @sch_name     VARCHAR(1000),
	        @proxy_name   VARCHAR(100),
	        @source       VARCHAR(1000),
	        @step_name_1  VARCHAR(1000),
	        @step_name_2  VARCHAR(1000),
	        @step_name_3  VARCHAR(1000)
			
	--SET @user_name = dbo.FNADBUser()
	              
	SET @user_name = ISNULL(@user_login_id, dbo.FNADBUser())
	SET @db_name = DB_NAME()
	SET @as_of_date = ISNULL(@as_of_date, '')
	SET @run_job_name = @db_name + ' - ' + @run_job_name

	BEGIN TRY
		BEGIN TRAN	

			SELECT @source = sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 19700 AND sdv.value_id=  @run_type
			
			SET @desc = 'EOD process failed in ' + @source + ' process.'
			SET @spa_failed = 'EXEC ' + @db_name + '.dbo.spa_eod_process ' 
								+ cast(@run_type AS VARCHAR) 
								+ ', ''' + @master_process_id + '''' 
								+ ', ''' + @process_id + '''' 
								+ ', ''TechError'''  
								+ ', ''' + @as_of_date +''''
								
			SET @spa_failed = 'DECLARE @contextinfo VARBINARY(128)
								SELECT @contextinfo = CONVERT(varbinary(128),''' + @user_name + ''')
								SET CONTEXT_INFO @contextinfo
								DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
								EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
								GO
								' + @spa_failed
								
			SET @desc = 'EOD process Completed for ' + @source + '.'
			SET @spa_success = 'EXEC ' + @db_name + '.[dbo].[spa_eod_process] ' 
									+ cast(@run_type AS VARCHAR)
									+ ', ''' + @master_process_id + '''' 
									+ ', ''' + @process_id + ''''  
									+ ', ''Success'''
									+ ', ''' + @as_of_date +''''
									
			SET @spa_success = 'DECLARE @contextinfo VARBINARY(128)
								SELECT @contextinfo = CONVERT(varbinary(128),''' + @user_name + ''')
								SET CONTEXT_INFO @contextinfo
								DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
								EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
								GO
								' + @spa_success
			EXEC spa_print 'here'
			-- Add the job
			EXECUTE msdb.dbo.sp_add_job @job_id = @job_ID OUTPUT 
					, @job_name = @run_job_name
					--, @owner_login_name = @user_name
					, @description = @user_name
					, @category_name = N'[Uncategorized (Local)]'
					, @enabled = 1
					, @delete_level= 0
			
			IF @job_subsystem = 'TSQL'
			BEGIN
				SET @spa = 'DECLARE @contextinfo VARBINARY(128)
							SELECT @contextinfo = CONVERT(varbinary(128),''' + @user_name + ''')
							SET CONTEXT_INFO @contextinfo
							GO
							' + @spa
			END
			
			
			IF @job_subsystem = 'SSIS'
				SELECT @proxy_name = MAX(sql_proxy_account) FROM connection_string
			
			-- assign step name
			SET @step_name_1 = '1 - ' + @source + ' start'
			SET @step_name_2 = '2 - ' + @source + ' success' 
			SET @step_name_3 = '3 - ' + @source + ' failure'
			
			-- Add the job steps
			EXEC spa_print 'step1'
			EXEC msdb.dbo.sp_add_jobstep 
				@job_name = @run_job_name
				, @step_id = 1
				, @step_name = @step_name_1
				, @subsystem = @job_subsystem
				, @on_fail_action = 4
				, @on_success_action = 4
				, @on_success_step_id = 2
				, @on_fail_step_id = 3
				, @command = @spa
				, @database_name = @db_name
				, @proxy_name = @proxy_name
			
			
			IF @exec_only_this_step = 0
			BEGIN			
				
				EXEC spa_print 'step2'
				EXEC msdb.dbo.sp_add_jobstep 
					@job_name = @run_job_name
					, @step_id = 2
					, @step_name = @step_name_2
					, @subsystem = 'TSQL'
					, @on_success_action = 1
					, @command = @spa_success
					, @database_name = @db_name
			
				EXEC spa_print 'step3'
				EXEC msdb.dbo.sp_add_jobstep 
					@job_name = @run_job_name
					, @step_id = 3
					, @step_name = @step_name_3
					, @subsystem = 'TSQL'
					, @on_success_action = 2 
					, @on_success_step_id = 0
					, @on_fail_action = 2
					, @on_fail_step_id = 0
					, @command = @spa_failed
					, @database_name = @db_name
				
			END
				  
			EXEC spa_print 'update job'
			EXECUTE msdb.dbo.sp_update_job @job_id = @job_ID, @start_step_id = 1 

			SET @sch_name = 'schedule_' + @run_job_name
			
			SELECT @freq_type = ISNULL(@freq_type, 1)
					, @freq_interval = ISNULL(@freq_interval, 0) 
					, @freq_subday_type = ISNULL(@freq_subday_type, 0)
					, @freq_subday_interval =ISNULL(@freq_subday_interval, 0)
					, @freq_relative_interval =ISNULL(@freq_relative_interval, 0)
					, @freq_recurrence_factor = ISNULL(@freq_recurrence_factor, 0)
					, @active_start_date = ISNULL(@active_start_date, 19900101)
					, @active_end_date = ISNULL(@active_end_date, 99991231)
					, @active_start_time = ISNULL(@active_start_time, 000000)
					, @active_end_time =ISNULL(@active_end_time, 235959)
			
			-- Add the job schedules
			EXEC spa_print 'add schedule'
			EXEC msdb.dbo.sp_add_schedule 
				@schedule_name = @sch_name
				, @enabled = 1 
				, @freq_type = @freq_type
				, @freq_interval = @freq_interval
				, @freq_subday_type = @freq_subday_type
				, @freq_subday_interval = @freq_subday_interval
				, @freq_relative_interval = @freq_relative_interval
				, @freq_recurrence_factor = @freq_recurrence_factor
				, @active_start_date = @active_start_date
				, @active_end_date = @active_end_date
				, @active_start_time = @active_start_time
				, @active_end_time = @active_end_time
			
			EXEC spa_print 'attach schedule'
			EXEC msdb.dbo.sp_attach_schedule @job_name = @run_job_name, @schedule_name = @sch_name

			-- Add the Target Servers
			EXEC spa_print 'add jobserver'
			EXECUTE msdb.dbo.sp_add_jobserver @job_id = @job_ID, @server_name = N'(local)' 
			
			EXEC spa_print 'end'
		COMMIT TRAN

	---------------------End error Trapping--------------------------------------------------------------------------
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		SET @msg = ERROR_MESSAGE()
		EXEC(@db_name + '.dbo.spa_eod_process ' 
						+ '-1' 
						+ ', NULL' 
						+ ', ''' + @process_id + '''' 
						+ ', 0'  
						+ ', ''Error while starting EOD Process' + @msg + '''')
	END CATCH
/************************************* Object: 'spa_eod_process_as_job_schedule' END *************************************/
