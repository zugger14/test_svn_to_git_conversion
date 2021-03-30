IF OBJECT_ID('spa_run_sp_as_job_schedule','p') IS NOT NULL
DROP PROC [dbo].[spa_run_sp_as_job_schedule] 
GO


/**
	Used to run stored procedure as job in the scheduled time.

	Parameters
	@run_job_name : Name of the Job.
	@spa : Name of stored procedure.
	@proc_desc : Description of stored procedure.
	@user_login_id : User login id of the account.
	@schedule_minute : Used in closing account period.
	@active_start_date : Date to start the job.
	@active_start_time : Time to start the job.
	@freq_type : '4' daily, '8' weekly, '16' monthly.
	@freq_interval : Interval in which the job is to run.
	@freq_subday_type : Frequency Subday Type.
	@freq_subday_interval : Frequency Subday Interval.
	@freq_relative_interval : Frequency Relative Interval.
	@freq_recurrence_factor : Frequency Recurrence Factor.
	@active_end_date : Date when the job ends.
	@active_end_time : Time when the job ends.
	@next_run : Next Run.
*/
CREATE PROCEDURE [dbo].[spa_run_sp_as_job_schedule] 
	@run_job_name VARCHAR(1000),
	@spa VARCHAR(MAX),
	@proc_desc VARCHAR(100),
	@user_login_id VARCHAR(50),
	@schedule_minute INT = NULL --it is used in  closing account period
	                            --	@schedule_date datetime=null,
	                            --	@schedule_TIME varchar(20),
	, @active_start_date INT = NULL
	, @active_start_time INT = NULL
	, @freq_type INT = NULL
	, @freq_interval INT = NULL
	, @freq_subday_type INT = NULL
	, @freq_subday_interval INT = NULL
	, @freq_relative_interval  INT = NULL
	, @freq_recurrence_factor INT = NULL
	, @active_end_date INT = NULL
	, @active_end_time INT = NULL
	, @next_run INT = NULL

AS

DECLARE @db_name varchar(50)
-- 1 means true 0 means false
DECLARE @error_found int
DECLARE @source varchar(20)
DECLARE @user_name varchar(50)
DECLARE @spa_failed VARCHAR(500)
DECLARE @desc varchar(500)
DECLARE @context_info NVARCHAR(MAX)

SET @user_name = isnull(@user_login_id,dbo.FNADBUser())
SET @error_found = 0
SET @db_name = db_name()
SET @run_job_name = @db_name + ' - ' + @run_job_name
SET @context_info ='DECLARE @contextinfo varbinary(128)
		SELECT @contextinfo = convert(varbinary(128),'''+@user_name+''')
		DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
		EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
		SET CONTEXT_INFO @contextinfo
		GO
		'

begin try
begin tran
	DECLARE @JobID BINARY(16) ,@job_delete_level INT
	DECLARE @job_description NVARCHAR(1000)
	SET @job_delete_level = IIF((@freq_type <> '' AND NULLIF(@freq_interval,0) IS NOT NULL ), 0, 1)
	SET @job_description = 'Created by: ' + @user_name + CHAR(13) + 'No description available.' --CHAR(13) used to seperate username and description

	-- Add the job
	EXECUTE msdb.dbo.sp_add_job @job_id = @JobID OUTPUT 
		, @job_name = @run_job_name--, @owner_login_name =@user_name
		, @description = @job_description, @category_name = N'[Uncategorized (Local)]'
		, @enabled = 1, @delete_level= @job_delete_level

	
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
		IF @next_run = 0 
		BEGIN
			SET @spa = 'EXEC ' + @db_name + '.dbo.' + @spa
		END

		SET @spa = @context_info + @spa

		SET @desc = 'Job ' + @run_job_name + ' failed.'
		SET @spa_failed = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' +
				 @desc + ''', '''', '''', ''e'', NULL'
	
		

		  -- Add the job steps
		EXEC msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
		   			@step_id = 1,
		   			@step_name = 'Step1',
		   			@subsystem = 'TSQL',
					@on_fail_action =3,
					@on_success_action =1, 
					@on_fail_step_id = 2,
		   			@command = @spa,
					@database_name = @db_name

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
	END

	if @schedule_minute is not null
	begin
			set @active_start_time=cast(replace(convert(varchar,dateadd(mi,@schedule_minute,getdate()),108),':','') as int)
			set @active_start_date=cast(convert(varchar,getdate(),112) as int)

	end	  
	EXECUTE  msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

	select @freq_type = isnull(@freq_type,1)
		, @freq_interval = isnull(@freq_interval,0) 
		, @freq_subday_type = isnull(@freq_subday_type,0)
		, @freq_subday_interval =isnull(@freq_subday_interval,0)
		, @freq_relative_interval =isnull(@freq_relative_interval,0)
		, @freq_recurrence_factor = isnull(@freq_recurrence_factor,0)
		, @active_start_date = isnull(@active_start_date,19900101)
		, @active_end_date = isnull(@active_end_date,000000)
		, @active_start_time = isnull(@active_start_time,99991231)
		, @active_end_time =isnull(@active_end_time,235959)

	declare @sch_name varchar(1000)

	SET @sch_name = 'schedule_'+@run_job_name
	-- Add the job schedules
	exec msdb.dbo.sp_add_schedule 
		@schedule_name = @sch_name
		, @enabled = 1
		, @freq_type = @freq_type
		, @freq_interval = @freq_interval
		, @freq_subday_type = @freq_subday_type
		, @freq_subday_interval =@freq_subday_interval
		, @freq_relative_interval =@freq_relative_interval
		, @freq_recurrence_factor = @freq_recurrence_factor
		, @active_start_date = @active_start_date
		, @active_end_date = @active_end_date
		, @active_start_time = @active_start_time
		, @active_end_time =@active_end_time
	 --   , @owner_login_name = @owner_login_name
	 --   , @schedule_uid = @schedule_uid
	 --   , @schedule_id = ] schedule_id OUTPUT ]
	 --   , @originating_server = ] server_name ] /* internal */

	EXEC msdb.dbo.sp_attach_schedule
		   @job_name = @run_job_name,
		   @schedule_name = @sch_name


	  -- Add the Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 

commit tran

---------------------End error Trapping--------------------------------------------------------------------------
end try

begin catch
	IF CURSOR_STATUS ('local', 'cur_job_sch') > 0 
    BEGIN 
            CLOSE cur_job_sch ; 
            DEALLOCATE cur_job_sch ; 
    END      
	--print 'Catch Error'
	if @@TRANCOUNT>0
		ROLLBACK
	if ERROR_message()='CatchError'
		set @desc='Unable to create job ' + @run_job_name + ' since there is already a multi-server job with this name.'
	else
		set @desc='Fail in creating Job :'+  @run_job_name + '(' +ERROR_MESSAGE()  + ').'

	--print @desc

	EXEC  spa_message_board 'i', @user_name, NULL, @proc_desc,
			 @desc, '', '', 'e', NULL

end catch
