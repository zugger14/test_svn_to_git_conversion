IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_deploy_rdl_as_job_dhx]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_rfx_deploy_rdl_as_job_dhx]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Deploy RDL file using SQL Job which uses CLR functionality for RDL deployment for Preview mode on 'Preview' SSRS folder.
	Parameters
	@proc_desc		:	Process description
	@user_login_id	:	User login ID
	@job_subsystem	:	Job sub system used while adding a SQL job
	@report_page_id	:	Report Page ID
	@rdl_type		:	RDL Type introduced on Preview mode development (rdl_final,rdl_preview)
	@report_name	:	Report Name
*/

CREATE PROCEDURE [dbo].[spa_rfx_deploy_rdl_as_job_dhx] 
	 @proc_desc VARCHAR (1000)
	,@user_login_id VARCHAR(50)
	,@job_subsystem VARCHAR(100)='CmdExec' -- SSIS for creating job SSIS package
	,@report_page_id INT
	,@rdl_type varchar(12) = 'rdl_final'
	,@report_name VARCHAR(1024)
AS

SET NOCOUNT ON
	IF @rdl_type = 'rdl_preview'
	BEGIN
		--EXEC master..xp_cmdshell @rdl_cmd
		declare @report_desc varchar(500) = 'Generated ' + @report_name + ' via CLR'
		EXEC [spa_deploy_rdl_using_clr] @report_name, @report_desc ,'/Preview'
		RETURN
	END

	DECLARE @db_name             VARCHAR(50) 
	DECLARE @error_found         INT -- 1 means true 0 means false
	DECLARE @source              VARCHAR(20),
	        @source_system_name  VARCHAR(100)
	
	DECLARE @user_name           VARCHAR(50)
	DECLARE @rdl_cmd_failed      VARCHAR(500),
	        @rdl_cmd_queue       VARCHAR(1000),
	        @rdl_job_name		 VARCHAR(8000),
			@rdl_cmd_success	 VARCHAR(500)
	
	DECLARE @desc                VARCHAR(500),
	        @msg                 VARCHAR(500)
	  
	SET @source_system_name = NULL   

	SET @user_name = ISNULL(@user_login_id, dbo.FNADBUser())
	SET @error_found = 0
	SET @db_name = DB_NAME()
	SET @rdl_job_name	= @db_name + ' - RDL_Deployer_Job_' + dbo.FNAGetNewID()
	--SET @desc = 'Scheduler failed to run for process ' + @rdl_job_name + '. Please contact technical support.'
	SET @desc = 'Error while deploying ' + @report_name + '.'
	
	SET @rdl_cmd_failed = 'EXEC ' + @db_name + '.dbo.spa_rfx_report_page_dhx ''p'', NULL, ' + CAST(@report_page_id as varchar(100)) 
						+ ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,''' + @user_name + ''',''' + @proc_desc  + ''',''' + @desc + ''''

	SET @rdl_cmd_success = 'EXEC ' + @db_name + '.dbo.spa_rfx_report_page_dhx ''q'', NULL, ' + CAST(@report_page_id as varchar(100)) 
						
	/* SET @rdl_cmd_failed = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' +
				 @desc + ''', '''', '''', ''e'', NULL'
				 */
	-- Release key with prefix report hash
	DECLARE @report_hash NVARCHAR(200),
		@memcache_key			VARCHAR(500) 

	SELECT @report_hash = rps.paramset_hash 
	FROM report_page rp 
	INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	WHERE 1 =1 

	SELECT @memcache_key = db_name() + '_RptRM_' +  @report_hash 
						+ ',' + db_name() +'_RptList'
	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [dbo].[spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @source_object = 'spa_rfx_deploy_rdl_as_job_dhx'
	END	
	

	DECLARE @flag CHAR(1)
	SET @flag = 'y'
		
	SET @rdl_cmd_queue = 'EXEC ' + @db_name + '.dbo.spa_job_queue ''' + @rdl_job_name + ''','''  + @source_system_name + ''','''  + @flag + ''''
	--PRINT @rdl_cmd_queue

	EXEC msdb.dbo.sp_add_job @job_name = @rdl_job_name, @delete_level = 1, @description = @user_name

	IF @@ERROR = 0 
	BEGIN
		
		SET @job_subsystem = ISNULL(@job_subsystem, 'CmdExec')
		
		
		DECLARE @proxy_name VARCHAR(100)
		SET @proxy_name = NULL
		IF @job_subsystem='CmdExec'
			--SET @proxy_name = 'SSRS_Proxy'
			SELECT @proxy_name = cs.sql_proxy_account FROM connection_string cs

		DECLARE @deploy_cmd VARCHAR(1024) = 'EXEC [spa_deploy_rdl_using_clr] ''' + @report_name + ''',''Generated ' + @report_name + ' via SQL Job'' ,''''' 
			
		EXEC msdb.dbo.sp_add_jobstep @job_name = @rdl_job_name,
				@step_id = 1,
				@step_name = 'Step1 : Deploy RDL to ReportServer',
				@subsystem = 'TSQL',				
				@on_success_action =4, 
				@on_success_step_id = 3,
				@on_fail_action =3,
				@on_fail_step_id = 2,
				@command = @deploy_cmd,
				@database_name = @db_name,
				@proxy_name = @proxy_name
			
		EXEC msdb.dbo.sp_add_jobstep @job_name = @rdl_job_name,
				@step_id = 2,
				@step_name = 'Step2 : Deploy RDL to ReportServer Failed Message',
				@subsystem = 'TSQL',
				@on_success_action = 2, 
				@on_success_step_id = 0, 
				@on_fail_action = 2, 
				@on_fail_step_id = 0, 
				@command = @rdl_cmd_failed,
				@database_name = @db_name

		
		EXEC msdb.dbo.sp_add_jobstep @job_name = @rdl_job_name,
				@step_id = 3,
				@step_name = 'Step3 : Update is_deployed to 1 in report_page',
				@subsystem = 'TSQL',
				@command = @rdl_cmd_success,
				@database_name = @db_name
				


		IF @@ERROR = 0
		BEGIN
			EXEC msdb.dbo.sp_add_jobserver @job_name = @rdl_job_name
			IF @@ERROR = 0
			BEGIN

				EXEC msdb.dbo.sp_start_job @job_name = @rdl_job_name

				IF @@ERROR = 0
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

	IF @error_found > 0
	BEGIN
		SET @desc = 'Failed to run schedule process ' + @rdl_job_name
		EXEC spa_message_board 'i', @user_name, NULL, @proc_desc, @desc, '', '', 'e', NULL		
	END


