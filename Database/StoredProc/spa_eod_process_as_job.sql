IF OBJECT_ID(N'[dbo].[spa_eod_process_as_job]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eod_process_as_job]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Creates SQL job of EOD Log EOD Process

	Parameters 
	@run_job_name : EOD Job Name
	@spa : SQL String to be executed via job
	@proc_desc : Not in used
	@user_login_id : User Login Id of the user
	@job_subsystem : 'SSIS' for creating job SSIS package
	@run_type : ID of EOD task
	@master_process_id : Master Process Id
	@process_id : Process Id
	@as_of_date : As Of Date
	@exec_only_this_step : 1 for single execution, 0 from serial execution
*/


CREATE PROCEDURE [dbo].[spa_eod_process_as_job]
	@run_job_name VARCHAR(1000),
	@spa VARCHAR(5000),
	@proc_desc VARCHAR(100),
	@user_login_id VARCHAR(50),
	@job_subsystem VARCHAR(100) = 'SSIS', -- SSIS for creating job SSIS package
	@run_type INT = NULL,
	@master_process_id VARCHAR(120) = NULL,
	@process_id VARCHAR(120) = NULL,
	@as_of_date VARCHAR(10) = NULL,
	@exec_only_this_step INT = 0
	
AS
	DECLARE @db_name      VARCHAR(50),
	        @source       VARCHAR(20),
	        @user_name    VARCHAR(50),
	        @spa_failed   VARCHAR(500),
	        @spa_success  VARCHAR(500),
	        @desc         VARCHAR(500),
	        @msg          VARCHAR(500),
	        @proxy_name   VARCHAR(100),
	        @step_name_1  VARCHAR(1000),
	        @step_name_2  VARCHAR(1000),
	        @step_name_3  VARCHAR(1000)
	
	
	IF @as_of_date IS NULL
		SET @as_of_date = ''
	--SET @user_name = dbo.FNADBUser()
	
	SELECT @source = sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 19700 AND sdv.value_id=  @run_type
	
	SET @user_name = ISNULL(@user_login_id, dbo.FNADBUser())
	SET @db_name = DB_NAME()
	SET @desc = 'EOD process failed in ' + @source + ' process.'
	SET @run_job_name = @db_name + ' - ' + @run_job_name
	SET @spa_failed = 'EXEC ' + @db_name + '.dbo.spa_eod_process ' 
							+ cast(@run_type AS VARCHAR) 
							+ ', ''' + @master_process_id + '''' 
							+ ', ''' + @process_id + '''' 
							+ ', ''TechError'''  
							+ ', ''' + @as_of_date +''''				
							
	SET @spa_failed = ' DECLARE @contextinfo VARBINARY(128)
						SELECT @contextinfo = CONVERT(varbinary(128),''' + @user_name + ''')
						SET CONTEXT_INFO @contextinfo
						DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
						EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
						GO
						' + @spa_failed
						
	SET @desc = 'EOD process Completed for ' + @source + '.'
	SET @spa_success = 'EXEC ' + @db_name + '.[dbo].[spa_eod_process] ' 
							+ cast(@run_type AS VARCHAR) 
							+ ',  ''' + @master_process_id + '''' 
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
						
	BEGIN TRY	
	
		EXEC msdb.dbo.sp_add_job @job_name = @run_job_name, @delete_level = 1, @description = @user_name
	
		SET @job_subsystem = ISNULL(@job_subsystem, 'TSQL')
		
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
		
		EXEC spa_print 'step1'
		EXEC msdb.dbo.sp_add_jobstep 
		     @job_name = @run_job_name,
		     @step_id = 1,
		     @step_name = @step_name_1,
		     @subsystem = @job_subsystem,
		     @on_fail_action = 4,
		     @on_success_action = 4,
		     @on_success_step_id = 2,
		     @on_fail_step_id = 3,
		     @command = @spa,
		     @database_name = @db_name,
		     @proxy_name = @proxy_name
		
		IF @exec_only_this_step = 0
		BEGIN

			EXEC spa_print 'step2'
			EXEC msdb.dbo.sp_add_jobstep 
				 @job_name = @run_job_name,
				 @step_id = 2,
				 @step_name = @step_name_2,
				 @subsystem = 'TSQL',
				 @on_success_action = 1,
				 @command = @spa_success,
				 @database_name = @db_name
		
			EXEC spa_print 'step3'
			EXEC msdb.dbo.sp_add_jobstep 
				 @job_name = @run_job_name,
				 @step_id = 3,
				 @step_name = @step_name_3,
				 @subsystem = 'TSQL',
				 @on_success_action = 2, 
				 @on_success_step_id = 0, 
				 @on_fail_action = 2, 
				 @on_fail_step_id = 0,
				 @command = @spa_failed,
				 @database_name = @db_name
		     
		END

		EXEC msdb.dbo.sp_add_jobserver @job_name = @run_job_name

		EXEC msdb.dbo.sp_start_job @job_name = @run_job_name
					
	END TRY
	BEGIN CATCH
		SET @msg = ERROR_MESSAGE()
		EXEC spa_print @msg
		EXEC(@db_name + '.dbo.spa_eod_process ' 
							+ @run_type 
							+ ', ''' + @master_process_id + '''' 
							+ ', ''' + @process_id + ''''
							+ ', ''Error'''  
							+ ', ''Error while running job for ' + @source + ' ' + @msg + '''')
	END CATCH
/************************************* Object: 'spa_eod_process_as_job' END *************************************/
