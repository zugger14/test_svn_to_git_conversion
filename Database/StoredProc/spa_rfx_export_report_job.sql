IF OBJECT_ID(N'[dbo].[spa_rfx_export_report_job]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_rfx_export_report_job]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Report batch operations using SQL job (exporting report as excel,word,pdf; ftp file upload; invoice related operations)
	Parameters
	@report_param				: Export Command
	@proc_desc					: Process Desccription
	@user_login_id				: User Login Id
	@report_RDL_name			: Report Name
	@report_file_name			: Report File name
	@report_file_full_path			: Report File Path
	@process_id					: Process Id
	@report_export_custom_dir   : User provided custom directory for report export 
	@schedule_minute			: Schedule Minute
	@active_start_date			: Active Start Date
	@active_start_time			: Active Start Time
	@freq_type					: Frequency Type
	@freq_interval				: Frequency Interval
	@freq_subday_type			: Frequency Subday Type
	@freq_subday_interval		: Frequency Subday Interval
	@freq_relative_interval		: Frequency Relative Interval
	@freq_recurrence_factor		: Frequency Recurrence Factor
	@active_end_date			: Active End Date
	@active_end_time			: Active End Time
	@email_description			: Email Description
	@email_subject				: Email Subject
	@is_aggregate				: Is Aggregate flag (to be used only for email aggregation from invoices)
	@call_from_invoice			: Flag to identify a call from Invoice
	@save_invoice				: Save Invoice flag
	@output_file_format			: Output File Format
	@export_report_name			: Export Report Name as to be exported
	@jobname					: Job Name
	@paramset_hash				: Unique report identifier to resolve report paramset at run time.
	@job_name					: Job name
*/

CREATE PROCEDURE [dbo].[spa_rfx_export_report_job] 
	  @report_param				VARCHAR(8000)		
	, @proc_desc				VARCHAR (100)		
	, @user_login_id			VARCHAR(50)			
	, @report_RDL_name			VARCHAR(5000)		
	, @report_file_name			VARCHAR(5000)
	, @report_file_full_path	VARCHAR(5000)
	, @process_id				VARCHAR(75) = NULL	 
	, @report_export_custom_dir	VARCHAR(8000) = NULL 
	, @schedule_minute			INT = NULL
	, @active_start_date		INT = NULL
	, @active_start_time		VARCHAR(20) = NULL
	, @freq_type				INT = NULL
	, @freq_interval			INT = NULL
	, @freq_subday_type			INT = NULL
	, @freq_subday_interval		INT = NULL
	, @freq_relative_interval	INT = NULL
	, @freq_recurrence_factor	INT = NULL
	, @active_end_date			INT = NULL
	, @active_end_time			VARCHAR(20) = NULL
	, @email_description		VARCHAR(MAX) = NULL
	, @email_subject 			VARCHAR(MAX) = NULL
	, @is_aggregate				INT = 0  --1 to be used only for email aggregation from invoices
	, @call_from_invoice VARCHAR(20) = NULL --'call_from_invoice' to be used only for email aggregation from invoices
	, @save_invoice				CHAR(1) = 'n' -- 'y' Not to show message when invoice is saved in folder
	, @output_file_format VARCHAR(25) = 'EXCELOPENXML'
	
	--TODO revise below parameters. Can we use holiday_calendar_id in batch table? can we take right 13 chars as batch unique identifier.
	, @export_report_name VARCHAR(5000) = NULL
	--, @batch_unique_id			VARCHAR(100)	= NULL
	--, @holiday_calendar_id		INT = NULL
	, @job_name					VARCHAR(5000) = NULL
	, @paramset_hash			VARCHAR(50) = NULL
AS
SET NOCOUNT ON

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

/*
declare 
@report_param				VARCHAR(8000)		
	, @proc_desc				VARCHAR (100)		
	, @user_login_id			VARCHAR(50)			
	, @report_RDL_name			VARCHAR(5000)		
	, @report_file_name			VARCHAR(5000)
	, @report_file_full_path	VARCHAR(5000)
	, @process_id				VARCHAR(75) = NULL	 
	, @report_export_custom_dir	VARCHAR(8000) = NULL 
	, @schedule_minute			INT = NULL
	, @active_start_date		INT = NULL
	, @active_start_time		VARCHAR(20) = NULL
	, @freq_type				INT = NULL
	, @freq_interval			INT = NULL
	, @freq_subday_type			INT = NULL
	, @freq_subday_interval		INT = NULL
	, @freq_relative_interval	INT = NULL
	, @freq_recurrence_factor	INT = NULL
	, @active_end_date			INT = NULL
	, @active_end_time			VARCHAR(20) = NULL
	, @email_description		VARCHAR(MAX) = NULL
	, @email_subject 			VARCHAR(MAX) = NULL
	, @is_aggregate				INT = 0  --1 to be used only for email aggregation from invoices
	, @call_from_invoice VARCHAR(20) = NULL --'call_from_invoice' to be used only for email aggregation from invoices
	, @save_invoice				CHAR(1) = 'n' -- 'y' Not to show message when invoice is saved in folder
	, @output_file_format VARCHAR(25) = 'EXCELOPENXML'
	
	, @export_report_name VARCHAR(5000) = NULL
	--, @batch_unique_id			VARCHAR(100)	= NULL
	--, @holiday_calendar_id		INT = NULL
	, @job_name					VARCHAR(5000) = NULL
	, @paramset_hash			VARCHAR(50) = NULL

--*/

DECLARE @report_RDL_name_original VARCHAR(5000) = @report_RDL_name

IF NULLIF(@export_report_name, '') IS NOT NULL
SET @report_RDL_name = @export_report_name + '_' + @export_report_name;	--TODO revise this logic. why same variable is concatenated

SET NOCOUNT ON
DECLARE 
	@is_aggregate_var CHAR(2) = CAST(@is_aggregate AS CHAR(2))
	, @export_extension VARCHAR(10)
	, @zip_ext VARCHAR(5) = 'zip'
	, @report_executable_sp VARCHAR(MAX) = NULL
	, @export_web_services_id	INT = NULL	
	, @file_creation_datatime VARCHAR(200)
	, @report_final_file_name VARCHAR(2000)
	, @user_name VARCHAR(50)
	, @batch_unique_id			VARCHAR(100)	= NULL
	, @holiday_calendar_id		INT = NULL


SET @batch_unique_id = RIGHT(@process_id, 13)

SET @user_name = ISNULL(@user_login_id, dbo.FNADBUser())

IF @email_subject IS NULL 
	--TODO: Make default email subject configurable, may be with F10 Config (which is enhanced in Trunk)
	SET @email_subject = 'TRMTracker Notification'

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

SET @report_export_custom_dir = NULLIF(@report_export_custom_dir, '')
SET @report_param = dbo.FNAURLDecode(@report_param)
SET @export_extension = CASE WHEN CHARINDEX('.', REVERSE(@report_file_name)) > 1 THEN RIGHT(@report_file_name, CHARINDEX('.', REVERSE(@report_file_name)) -1) ELSE '' END 

SET @report_final_file_name = @proc_desc + ' - '		--append @proc_desc value (normally "BatchReport - ") in report file name	
	+ REPLACE(@report_file_name, '.' + @export_extension, '')	--remove extension, which will be added later
	+ '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), ':', ''), ' ', '_'), '-', '_') --add timestamp
	+ '.' + @export_extension									--add extension
	
IF ISNULL(@call_from_invoice, '') <> 'call_from_invoice' AND @save_invoice <> 'y'
BEGIN
	--replace supplied @report_file_name with generated @report_final_file_name
	SET @report_param = REPLACE(@report_param, @report_file_name, @report_final_file_name)
	SET @report_file_full_path	= REPLACE(@report_file_full_path, @report_file_name, @report_final_file_name)
END

DECLARE @db_name                 	VARCHAR(50) 
DECLARE @error_found             	INT -- 1 means true 0 means false
DECLARE @source                  	VARCHAR(20),
        @source_system_name      	VARCHAR(100)
DECLARE @report_param_success       	VARCHAR(8000) = '',
        @report_param_failed        	VARCHAR(8000),        
        @ftp_export_cmd_success   	VARCHAR(8000),
        @ftp_export_cmd_failed    	VARCHAR(8000),
        @ftp_desc_success         	VARCHAR(5000),
        @ftp_desc_failed          	VARCHAR(5000),        
        @copy_export_cmd          	VARCHAR(8000),
        @copy_export_cmd_success  	VARCHAR(8000),
        @copy_export_cmd_failed   	VARCHAR(8000),        
        @export_job_name          	VARCHAR(8000),
        @desc_success             	VARCHAR(5000),
        @desc_failed              	VARCHAR(5000),        
        @msg                      	VARCHAR(500),
        @process_table_name       	VARCHAR(5000),
        @new_process_id			  	VARCHAR(500),
        @compress_file              CHAR(1),
        @output_file_full_path		VARCHAR(8000),	--report file full path without zip
		@final_output_full_file_path		VARCHAR(8000),	--report file full path with zip
		@elapsed_time_msg			VARCHAR(1000),
        @xml_format 				INT = NULL

--store destination path to create final report file 

SELECT @output_file_full_path = CASE WHEN @report_export_custom_dir IS NULL THEN @report_file_full_path 
	ELSE @report_export_custom_dir +  '\' + @report_final_file_name END
SET @output_file_full_path = REPLACE(@output_file_full_path, '/', '\')

SET @final_output_full_file_path = CASE WHEN @compress_file = 'y' THEN 
	REPLACE(@output_file_full_path, '.' + @export_extension, '.' + @zip_ext)
	ELSE @output_file_full_path
	END

DECLARE @invoice_id VARCHAR(500)
DECLARE @doc_path VARCHAR(100)
DECLARE @is_finalized CHAR(1) = 'n'
DECLARE @invoice_file_name VARCHAR(1000)
DECLARE @url VARCHAR(250)
DECLARE @report_item_ids VARCHAR(MAX)

SELECT @doc_path = document_path FROM connection_string
IF @report_param IS NOT NULL 
	AND ISNULL(@call_from_invoice, '') = 'call_from_invoice' --set invoice ids when only called from invoice
	SET @invoice_id = REPLACE(@report_param, 'invoice_ids:', '');
	
SELECT	@invoice_file_name = @doc_path + '\invoice_docs\' + ISNULL(CASE WHEN a.item < 0 THEN civv.netting_file_name ELSE civv.invoice_file_name END,''),
		@is_finalized = 'y'
FROM Calc_invoice_Volume_variance civv
INNER JOIN dbo.SplitCommaSeperatedValues(@invoice_id) a ON civv.calc_id = ABS(a.item)
WHERE civv.finalized = 'y'

IF @is_finalized = 'n'
	SET @invoice_file_name = ISNULL(@report_file_full_path,'')

SET @new_process_id = dbo.FNAGetNewID()

SET @process_table_name = dbo.FNAProcessTableName('report_batch', @user_name, @process_id)
SET @source_system_name = NULL   
SET @error_found = 0
SET @db_name = DB_NAME()
SET @export_job_name = @db_name + ' - ' + ISNULL(@job_name,'report_batch_' + @process_id)

IF @schedule_minute IS NOT NULL
BEGIN
    SET @active_start_time = CAST(REPLACE(CONVERT(VARCHAR(10), DATEADD(mi, @schedule_minute, GETDATE()), 108), ':', '') AS INT)							
    SET @active_start_date = CAST(CONVERT(VARCHAR, GETDATE(), 112) AS INT)
END	

DECLARE @trimmed_report_name VARCHAR(100)
SET @trimmed_report_name = REPLACE(
								REPLACE(@report_file_name, '_' + @user_name, '')
								, '.' + @export_extension, '')
SET @trimmed_report_name = ISNULL(@trimmed_report_name, @proc_desc)

SELECT TOP 1 @compress_file = bpn.compress_file
	, @xml_format = bpn.xml_format
	, @export_web_services_id = export_web_services_id
	, @holiday_calendar_id = holiday_calendar_id
FROM   batch_process_notifications bpn
	LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
WHERE  bpn.process_id = RIGHT(@process_id, 13)

DECLARE @ext VARCHAR(5)

DECLARE @custom_xml_format BIT
IF ISNULL(@xml_format,-100000) NOT IN (-100000, -100001) 
	SET @custom_xml_format = 1


SELECT @report_item_ids = 'paramset_id:' + CAST(rp.report_paramset_id AS VARCHAR(20)) + ',' + [dbo].[FNARFXGenerateReportItemsCombined](rp.page_id) + ','
FROM report_paramset rp
WHERE rp.paramset_hash = @paramset_hash

IF @export_web_services_id IS NOT NULL
BEGIN
    SELECT @report_executable_sp = [dbo].[FNABuildRfxQueryFromReportParameter]((ISNULL(@report_item_ids, '') + @report_param), @process_id, 'y')
END
ELSE
BEGIN
    SELECT @report_executable_sp = [dbo].[FNABuildRfxQueryFromReportParameter]((ISNULL(@report_item_ids, '') + @report_param), @process_id, 'n')
END

-- compress file code starts here
IF @compress_file = 'y' -- set file extension to zip 
BEGIN
	SET @ext = 'zip'
END
-- compress file code starts ends	

SET @url = '../../adiha.php.scripts/force_download.php?path='
			
IF @email_description IS NULL
	--TODO: Make default email description configurable, may be with F10 Config (which is enhanced in Trunk)
	SET @email_description = 'Batch process completed for <b>' + @report_RDL_name + '</b>.'	


SET @desc_success = 'Batch process completed for <b>' + @trimmed_report_name + '</b>. Report has been saved. Please
					<a target="_blank" href="'+  @url + @final_output_full_file_path + '">
					<b> Click Here</b></a> to download.'

--(File generation including compression for csv, xml and txt is handled by spa_dump_csv in spa_message_board)
IF @export_extension = 'xlsx'
BEGIN
	IF @report_export_custom_dir IS NOT NULL
	BEGIN
		SET @desc_success = 'Batch process completed for <b>' + @trimmed_report_name + '</b>. Report has been saved at <b>' + @final_output_full_file_path + '</b>.'
	END
	-- Added logic to delete source file after compression
	IF @compress_file = 'y'
	BEGIN
		SET @export_extension = @zip_ext

		SET @report_param_success = '			
		EXEC spa_compress_file  ''' + @final_output_full_file_path  + ''',  ''' + @output_file_full_path  + '''
		GO
		Declare @output_msg nvarchar(1024)
		EXEC spa_delete_file ''' + @output_file_full_path + ''', @output_msg OUTPUT 
		GO 
		'
	END

	SET @report_param_success += 'EXEC ' + @db_name + '.dbo.spa_message_board @flag = ''u'', @user_login_id = ''' + @user_name + ''', @source= ''' + @trimmed_report_name  + ''', @description =''' + @desc_success + ''', @url_desc='''', @url ='''', @type = ''s'', @job_name='''+@export_job_name+''', @process_id= ''' + @process_id + ''', @email_enable =''y'', @email_description=''' + @email_description + ''', @email_subject=''' + @email_subject + ''',@file_name =''' + @final_output_full_file_path  + ''''
END
ELSE
BEGIN
	IF @save_invoice <> 'y' 
		SET @report_param_success = 'EXEC ' + @db_name + '.dbo.spa_message_board @flag = ''u'', @user_login_id = ''' + @user_name + ''', @source= ''' + @trimmed_report_name  + ''', @description = ''' + @desc_success + ''', @url_desc='''', @url ='''', @type = ''s'', @job_name= '''+@export_job_name+''', @process_id= ''' + @process_id + ''', @email_enable =''y'', @email_description=''' + @email_description + ''',@report_sp =' + CASE WHEN @report_executable_sp IS NOT NULL THEN '''' + REPLACE(@report_executable_sp, '''','''''') + '''' ELSE 'NULL' END + ',@file_name =''' + @output_file_full_path  + ''', @email_subject=''' + @email_subject + ''', @is_aggregate = '+@is_aggregate_var+''
END

SET @elapsed_time_msg = '
	--mark completion just for record	
	DECLARE @desc_success_with_time varchar(8000) = ''' + @desc_success +  '<i> Elapsed time: </i>'';

	SELECT TOP 1 @desc_success_with_time = @desc_success_with_time + [dbo].[FNAFindDateDifference](time_start)
	FROM process_log_tracker
	WHERE process_id = ''' + @process_id + '''
	'

SET @desc_failed = 'Job ' + @export_job_name + ' failed.'
SET @report_param_failed = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' + @desc_failed + ''', '''', '''', ''e'', NULL'

SET @ftp_desc_failed = 'FTP process ' + @export_job_name + ' failed<#custom_error_message#>.'
SET @ftp_export_cmd_failed = 'EXEC ' + @db_name + '.dbo.spa_message_board ''i'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' + @ftp_desc_failed + ''', '''', '''', ''e'', NULL'

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @export_job_name)
	SET @export_job_name = 'report_batch_' + @new_process_id 

DECLARE @job_delete_level INT
SET @job_delete_level = 1
--if job is scheduled, set @delete_level = 0 to prevent auto deletion after first run
SET @job_delete_level = IIF((@freq_type <> '' AND @freq_interval <> 0), 0, 1)

EXEC msdb.dbo.sp_add_job @job_name = @export_job_name, @delete_level = @job_delete_level, @description = @user_name

IF @@ERROR = 0 
BEGIN
	DECLARE @proxy_name VARCHAR(100)
	SET @proxy_name = NULL
	
	DECLARE @export_sql_cmd VARCHAR(MAX)
	SET @export_sql_cmd =  'EXEC spa_export_RDL @report_RDL_name =''' +  @report_RDL_name + ''', @parameters =''' +  @report_param + ''', @OutputFileFormat = ''' + @output_file_format + ''', @output_filename = ''' +@output_file_full_path+ ''', @process_id ='''+ @process_id + ''', @paramset_hash=''' + ISNULL(@paramset_hash, '') + ''''
	
	IF @custom_xml_format = 1 
	BEGIN
		SET @export_sql_cmd =  'EXEC ' + @db_name + '.dbo.spa_message_board ''u'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' + @desc_success + ''', '''', '''', ''s'', '''+ @export_job_name+''',NULL, ''' + @process_id + ''',NULL,NULL,NULL,''y'',''' + @email_description + ''',' + CASE WHEN @report_executable_sp IS NOT NULL THEN '''' + REPLACE(@report_executable_sp, '''','''''') + '''' ELSE 'NULL' END + ',NULL,NULL,NULL,NULL,NULL,NULL,''' + @email_subject + ''', '+@is_aggregate_var+',NULL,' + CASE WHEN @invoice_file_name IS NOT NULL THEN '''' + @invoice_file_name + '''' ELSE 'NULL' END 	 		
	END
	
	IF (@call_from_invoice = 'call_from_invoice')
	BEGIN
		SET @export_sql_cmd = 'EXEC spa_generate_document_view @flag = ''g'', @object_id =' + CAST(@invoice_id AS VARCHAR) + ', @document_category = 38, @document_sub_category = 42031, @document_filename = ''' + @report_file_name + ''''
	END

	IF (@call_from_invoice = 'call_from_stmt_invoice')
	BEGIN
		SET @export_sql_cmd = 'EXEC spa_generate_document @filter_object_id = ' + CAST(@invoice_id AS VARCHAR) + ', @document_category = ''10000283'', @document_sub_category = '''', @temp_generate = ''1'', @get_generated = ''1'', @show_output = ''1'''
	END
	
	SET @export_sql_cmd = ' 
		DECLARE @job_name NVARCHAR(1000) = ''$(ESCAPE_NONE(JOBNAME))''
		EXEC sys.sp_set_session_context @key = N''JOB_NAME'', @value = @job_name;
		GO
		spa_run_sp_with_dynamic_params @spa = ''' + REPLACE(@export_sql_cmd, '''', '''''') + ''',@batch_unique_id = ''' + ISNULL(@batch_unique_id,'') + ''',@holiday_calendar_id = ' + ISNULL('''' + CAST(@holiday_calendar_id AS VARCHAR(10)) + '''', 'NULL')
	
	--Notifying
	IF @custom_xml_format = 0
	BEGIN
		BEGIN
			IF @save_invoice <> 'y'	
			SET @report_param_success += @elapsed_time_msg + '
			EXEC ' + @db_name + '.dbo.spa_message_board ''u'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', @desc_success_with_time, '''', '''', ''s'', '''+ @export_job_name+''',NULL, ''' + @process_id + ''',NULL,NULL,NULL,''y'',''' + @email_description + ''',' + CASE WHEN @report_executable_sp IS NOT NULL THEN '''' + REPLACE(@report_executable_sp, '''','''''') + '''' ELSE 'NULL' END + ',NULL,NULL,NULL,NULL,NULL,' + CASE WHEN @invoice_file_name IS NOT NULL THEN '''' + @invoice_file_name + '''' ELSE 'NULL' END + ',''' + @email_subject + ''', '+@is_aggregate_var+''	 		

		END
	END
	/*
	Step1:- Process and generates custom xml file or generates invoice document or generate excel file from report server. 
			CSV, TXT and XML file generation is handled in Step 2.
	Step2:- Excel: Compress xlsx file generated in Step1 and delete xlsx file. 
					Notify to users.
			Non Excel: Generate file, compress, and notify user.
			FTP file upload
	Step3:- Error notification
	*/
	BEGIN
		EXEC msdb.dbo.sp_add_jobstep @job_name = @export_job_name,
				@step_id = 1,
				@step_name = 'Generate report.',
				@subsystem = 'TSQL',
				@on_fail_action = 4,
				@on_success_action = 4,
				@on_success_step_id = 2,
				@on_fail_step_id = 3,
				@command = @export_sql_cmd,
				@database_name = @db_name
			
		EXEC msdb.dbo.sp_add_jobstep @job_name = @export_job_name,
				@step_id = 2,
				@step_name = 'Notify success.',
				@subsystem = 'TSQL',
				@command = @report_param_success,
				@database_name = @db_name
				
		EXEC msdb.dbo.sp_add_jobstep @job_name = @export_job_name,
				@step_id = 3,
				@step_name = 'Notify failure',
				@subsystem = 'TSQL',
				@on_success_action = 2, 
				@on_success_step_id = 0, 
				@on_fail_action = 2, 
				@on_fail_step_id = 0,
				@command = @report_param_failed,
				@database_name = @db_name	
	END

	IF @@ERROR = 0
	BEGIN
		EXEC msdb.dbo.sp_add_jobserver @job_name = @export_job_name
		IF @@ERROR <> 0
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
	
	IF @freq_type <> '' --AND @freq_interval IS NOT NULL
	BEGIN		 			
		SELECT @freq_type = ISNULL(@freq_type, 1),
			   @freq_interval = ISNULL(@freq_interval, 0),
			   @freq_subday_type = ISNULL(@freq_subday_type, 0),
			   @freq_subday_interval = ISNULL(@freq_subday_interval, 0),
			   @freq_relative_interval = ISNULL(@freq_relative_interval, 0),
			   @freq_recurrence_factor = ISNULL(@freq_recurrence_factor, 0),
			   @active_start_date = ISNULL(@active_start_date, 19900101),
			   @active_end_date = ISNULL(@active_end_date, 000000),
			   @active_start_time = ISNULL(@active_start_time, 99991231),
			   @active_end_time = ISNULL(@active_end_time, 235959)
		
		DECLARE @sch_name VARCHAR(1000)
		
		SET @sch_name = 'schedule_' + @export_job_name
		-- Add the job schedules
		EXEC msdb.dbo.sp_add_schedule 
			 @schedule_name = @sch_name,
			 @enabled = 1,
			 @freq_type = @freq_type,
			 @freq_interval = @freq_interval,
			 @freq_subday_type = @freq_subday_type,
			 @freq_subday_interval = @freq_subday_interval,
			 @freq_relative_interval = @freq_relative_interval,
			 @freq_recurrence_factor = @freq_recurrence_factor,
			 @active_start_date = @active_start_date,
			 @active_end_date = @active_end_date,
			 @active_start_time = @active_start_time,
			 @active_end_time = @active_end_time
		
		EXEC msdb.dbo.sp_attach_schedule @job_name = @export_job_name, @schedule_name = @sch_name
	 END
	 ELSE
	 BEGIN
		--start the job immediately if not scheduled
		EXEC msdb.dbo.sp_start_job @job_name = @export_job_name

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
END
ELSE
BEGIN
	--ERROR found
	SET @error_found = @@ERROR
	SET @source = 'add_job'
END

IF @error_found > 0
BEGIN
	SET @desc_failed = 'Failed to run schedule process ' + @export_job_name
	EXEC spa_message_board 'i', @user_name, NULL, @proc_desc, @desc_failed, '', '', 'e', NULL		
END
ELSE
BEGIN
	IF @save_invoice <> 'y'
	EXEC spa_ErrorHandler 0, @export_job_name, 'batch_report_process', 'Success', 'Job has been started successfully.', '' 
END	

-- Clean up Process Tables Used after the scope is completed when Debug Mode is Off.
DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
BEGIN
	EXEC spa_clear_all_temp_table NULL, @process_id
END

GO

