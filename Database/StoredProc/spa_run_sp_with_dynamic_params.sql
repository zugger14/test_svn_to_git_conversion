IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_run_sp_with_dynamic_params]') AND [type] IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_run_sp_with_dynamic_params]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Wrapper sp for generating runtime value for dynamic params for the main job sp. Replaces dynamic params in the main job sql and executes it.
 
	Parameters:
			@spa					:	Main sp sql to run in job. Supported dynamic params:
										1. DATE.F - First Day of the month
										2. DATE.L - Last Day of the month
										3. DATE.X - (Today - X) where X is an integer
		@batch_unique_id			:	Dynamic param PROCESS_ID, will be replaced by newly generated process_id. This will help not to repeat the same process_id for recurring job.
		@holiday_calendar_id		:	Holiday group value id to exclude holidays from schedule.
		@export_process_id			:	Process ID that is used for export.
		@export_table_name_suffix 	:	Suffix of the table that is to be exported.
		@job_name					:	Name of the job.
*/
	
CREATE PROCEDURE dbo.spa_run_sp_with_dynamic_params 
	@spa VARCHAR(MAX),
	@batch_unique_id VARCHAR(20) = NULL,
	@holiday_calendar_id INT = NULL,
	@export_process_id VARCHAR(100) = NULL,
	@export_table_name_suffix VARCHAR(200) = NULL,
	@job_name NVARCHAR(500) = NULL,
	--Dummy Variables not in use inside this SP but it is expected to have while runnaing the job via batch_repo_process as these are concatenated in the sql string.
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL 
AS
/*-------------------------------Debug Section-------------------------------
DECLARE @spa VARCHAR(MAX),
		@batch_unique_id VARCHAR(20) = NULL,
		@holiday_calendar_id INT = NULL,
		@export_process_id VARCHAR(100) = NULL,
		@export_table_name_suffix VARCHAR(200) = NULL
---------------------------------------------------------------------------*/
SET NOCOUNT ON
BEGIN
	DECLARE @param_name VARCHAR(200),
			@param_value VARCHAR(200),
			@start_index INT,
			@end_index INT,
			@comma_end_index INT,
			@user_today DATETIME,
			@curent_date VARCHAR(10),
			@process_id VARCHAR(800),
			@user_login_id VARCHAR(200),
			@export_table_name	VARCHAR(250),
			@sql VARCHAR(MAX),
			@create_table_option VARCHAR(10) = 'c' 
	
	SET @curent_date = CONVERT(VARCHAR(10), GETDATE(), 120)
	
	IF EXISTS (SELECT 1 FROM holiday_group hg WHERE hg.hol_group_value_id = @holiday_calendar_id AND hg.hol_date = @curent_date)
	BEGIN
		SET @job_name = CONVERT(VARCHAR(1000), SESSION_CONTEXT(N'JOB_NAME'))
		
		EXEC spa_print 'Job will not executed in holidays.'
		-- Stop the job
		IF @job_name IS NOT NULL	
			EXEC msdb.dbo.sp_stop_job @job_name = @job_name

	    RETURN
	END
	ELSE
	BEGIN
		--Update process log time.		
		UPDATE process_log_tracker SET time_start = GETDATE() WHERE process_id like '%' + @batch_unique_id
		
		--Replace [Timestamp] with underscore separator timestamp as filename suffix.
		IF CHARINDEX('[TIMESTAMP]', @spa) > 0
		BEGIN
			
			SELECT @spa = REPLACE(@spa, '[TIMESTAMP]', REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), time_start, 120), ':', ''), ' ', '_'), '-', '_'))
			FROM process_log_tracker WHERE process_id like '%' + @batch_unique_id
		END
	END
	
	--Resolve dynamic date if spa contains dynamic date	
	SET @spa = [dbo].FNAReplaceDYNDateParam(@spa)
	
	--If export table is called @export_process_id will be passed from sp batch_report_process
	--For such case the dynamic PROCESS_ID: must be replaced by the @export_process_id such that the batch data can be retrieved
	
	IF @export_process_id IS NOT NULL
	BEGIN 
		IF CHARINDEX('PROCESS_ID:', @spa) > 0
		BEGIN
			SET @process_id = @export_process_id
			SET @spa = REPLACE(@spa, 'PROCESS_ID:', @process_id)
		END
	END 
	ELSE 
	BEGIN 
		IF CHARINDEX('PROCESS_ID:', @spa) > 0
		BEGIN
			SET @process_id = dbo.FNAGetNewID() + ISNULL('_' + @batch_unique_id, '')
			SET @spa = REPLACE(@spa, 'PROCESS_ID:', @process_id)
		END
	END
	 
	--DATE.F: First Day of the month
	SET @spa = REPLACE(@spa , 'DATE.F', [dbo].[FNAResolveCustomAsOfDate]('DATE.F', DEFAULT))
	
	--DATE.L: Last Day of the month
	SET @spa = REPLACE(@spa, 'DATE.L', [dbo].[FNAResolveCustomAsOfDate]('DATE.L', DEFAULT))
	
	--DATE.X where X is an integer: (Today - X)
	SET @start_index = PATINDEX('%DATE.%' ,@spa)
	
	IF @start_index > 0
	BEGIN
	    --eg: Normal Report: 'spa_Create_Position_Report ''DATE.1'', ''7'', NULL....'
	    --search for both ('') & (,) and use whichever found first.		
	    SET @end_index = CHARINDEX('''', @spa, @start_index + 1)
	    SET @comma_end_index = CHARINDEX(',', @spa, @start_index + 1)
	    
		IF @comma_end_index < @end_index
	        SET @end_index = @comma_end_index
	    
	    SET @param_name = SUBSTRING(@spa, @start_index + LEN('DATE.') ,@end_index - @start_index - LEN('DATE.'))
	    SET @param_value = [dbo].[FNAResolveCustomAsOfDate]('DATE.' + @param_name, DEFAULT)
	    SET @spa = REPLACE(@spa ,'DATE.' + @param_name ,@param_value)
	END
	
	EXEC (@spa)
	
	SELECT @export_table_name = export_table_name FROM batch_process_notifications WHERE [process_id] = @batch_unique_id
	
	IF @export_table_name IS NOT NULL 
		AND @export_process_id IS NOT NULL	--if export option is enabled 
		AND @create_table_option = 'c'	--for now, other options are not supported.	
	BEGIN
		EXEC spa_rfx_export_report_data @batch_unique_id, @export_process_id, @export_table_name_suffix
	END
END
GO