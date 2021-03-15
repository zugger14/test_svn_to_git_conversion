IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_message_board]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_message_board]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Procedure that is used for inserting/updating/deleting data and process those data related to message board and email.
	
	Parameters:
		@flag				:	Operation flag that decides the action to be performed.
		@user_login_id		:	Login Identifier of a User that is used for entering into application.
		@message_id			:	Numeric Identifier for a message of message board.
		@source				:	The source of the message, from where it is generated.
		@description		:	Description of message that describes the message text.
		@url_desc			:	Description of the URL.
		@url				:	URL that redirects the message board to its description.
		@type				:	Type of the message (Error/Warning/Success).
		@job_name			:	Name of the Job that is executed before throwing message.
		@as_of_date			:	Particular Date and Time.
		@process_id			:	Unique Identifier to create process table that is used to store data.
		@process_type		:	Type of process.
		@returnOutput		:	Specify whether to return output or not (y/n).
		@process_table_name		:	Name of the temporary table.
		@email_enable		:	Specify whether to enable email or not. If enabled, an email will be sent to receipents (y/n).
		@email_description	:	Description for email to be sent.
		@report_sp			:	Stored procedure of report that will show up when clicked on link of message board.
		@source_filter		:	Source of the message (BatchReport/DataImport).
		@message_filter		:	Part of message description that will help to filter messages from all available messages.
		@date_filter		:	Date that is used to filter the message with created date of message.
		@file_name			:	Name of File that is to be sent as link in message board/email. (CSV, XML, XLS)
		@email_subject		:	Subject of Email that is to be sent for specific user.
		@is_aggregate		:	To be discussed.
		@url_or_desc		:	Specify whether the message contains URL or Description (u/d).
		@batch_user_lists	:	List of the users who will get notified, that is included in the batch.
*/

CREATE PROCEDURE [dbo].[spa_message_board]	 
	@flag CHAR,
	@user_login_id VARCHAR(50) = 'NULL', 
	@message_id VARCHAR(MAX) = NULL, --to support multiple delete
	@source VARCHAR(MAX) = NULL,
	@description VARCHAR(MAX) = NULL,
	@url_desc VARCHAR(MAX) = NULL,
	@url VARCHAR(MAX) = NULL,
	@type CHAR(1) = NULL,
	@job_name VARCHAR(MAX) = NULL,
	@as_of_date DATETIME = NULL,
	@process_id VARCHAR(100) = NULL,
	@process_type CHAR(1) = NULL ,
	@returnOutput CHAR(1) = 'y',
	@process_table_name VARCHAR(500) = NULL,
	@email_enable CHAR(1) = 'n',
	@email_description VARCHAR(MAX) = NULL,
	@report_sp VARCHAR(MAX) = NULL,
	@source_filter VARCHAR(MAX) = NULL,
	@message_filter VARCHAR(MAX) = NULL,
	@date_filter DATETIME = NULL,
	@file_name VARCHAR(1500) = NULL,
	--@zip_filename VARCHAR(3000) = NULL,		--remove its logic and re-use parameter for another use
	--@xls_filename VARCHAR(3000) = NULL,		--remove its logic and re-use parameter for another use
	@email_subject VARCHAR(MAX) = NULL,
	@is_aggregate INT = 0,
	@url_or_desc CHAR(1) = NULL,
	@batch_user_lists VARCHAR(MAX) = NULL
        
AS
SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature

/** Debug Section **
DECLARE @flag CHAR
	, @user_login_id VARCHAR(50) = 'NULL'
	, @message_id VARCHAR(MAX) = NULL --to support multiple delete
	, @source VARCHAR(MAX) = NULL
	, @description VARCHAR(MAX) = NULL
	, @url_desc VARCHAR(MAX) = NULL
	, @url VARCHAR(MAX) = NULL
	, @type CHAR(1) = NULL
	, @job_name VARCHAR(MAX) = NULL
	, @as_of_date DATETIME = NULL
	, @process_id VARCHAR(100) = NULL
	, @process_type CHAR(1) = NULL
	, @returnOutput CHAR(1) = 'y'
	, @process_table_name VARCHAR(500) = NULL
	, @email_enable CHAR(1) = 'n'
	, @email_description VARCHAR(MAX) = NULL
	, @report_sp VARCHAR(MAX) = NULL
	, @source_filter VARCHAR(MAX) = NULL
	, @message_filter VARCHAR(MAX) = NULL
	, @date_filter DATETIME = NULL
	, @file_name VARCHAR(1500) = NULL	
	, @email_subject VARCHAR(MAX) = NULL
	, @is_aggregate INT = 0
	, @url_or_desc CHAR(1) = NULL
  
	, @batch_user_lists VARCHAR(MAX) = NULL

SELECT @flag = 's'
--*/
	
DECLARE @message_id_tmp         INT,
        @output_dir             VARCHAR(300),
        @output_full_file_path  VARCHAR(4000),
		@final_output_full_file_path  VARCHAR(4000),
        @trimmed_source         VARCHAR(100),
        @compress_file          CHAR(1),
        @delim                  VARCHAR(10),
        @is_header              VARCHAR(10),
		@xml_format				INT = -100000,
		@sql					VARCHAR(MAX),
		@output_extension		VARCHAR(10),
		@msg					NVARCHAR(100),
		@batch_notification_process_id VARCHAR(20)

DECLARE @db_user VARCHAR(50) = dbo.FNADBUser()


IF OBJECT_ID(N'tempdb..#user_login_id') IS NOT NULL
DROP TABLE #user_login_id

CREATE TABLE #user_login_id(user_login_id  NVARCHAR(500) COLLATE DATABASE_DEFAULT)


IF SUBSTRING(LTRIM(@source), 1, 15) = 'Report Writer -'
	SET @trimmed_source = 'Report Writer'
ELSE
	SET @trimmed_source = @source

DECLARE @export_web_services_id	INT = NULL	

--grab output file details
SET @batch_notification_process_id = RIGHT(ISNULL(@job_name, @process_id), 13)
SELECT @output_dir = csv_file_path, @compress_file = compress_file,
       @delim = delimiter,
       @is_header = report_header,
	   @xml_format = ISNULL(xml_format, -100000),
       @export_web_services_id = export_web_services_id,
	   @output_extension = output_file_format
FROM   batch_process_notifications bpn
LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
WHERE  bpn.process_id = @batch_notification_process_id

IF @process_table_name IS NULL
	SELECT @process_table_name = dbo.FNAProcessTableName('batch_report', dbo.FNADBUser(), @process_id)

--generate unique file name if not provided

--IF @file_name IS NULL
--BEGIN
--	SET @output_full_file_path = @output_dir + @trimmed_source + '_' + REPLACE(dbo.FNADBUser(), '.', '_') + '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), ':', ''), ' ', '_'), '-', '_') + @output_extension
--END
--ELSE 

IF CHARINDEX(@output_dir, @file_name) <> 0
BEGIN
	--sometime full file path is available in @file_name
	SET @output_full_file_path = @file_name
END
ELSE
BEGIN
	SET @output_full_file_path = @output_dir + @file_name	
END
EXEC spa_print '@output_full_file_path=', @output_full_file_path

IF @compress_file = 'y'
BEGIN
	SELECT @description = REPLACE(@description, @output_extension, '.zip')
	, @email_description = REPLACE(@email_description, @output_extension, '.zip') 
	, @final_output_full_file_path = REPLACE(@output_full_file_path, @output_extension, '.zip')
END
ELSE
BEGIN
	SET @final_output_full_file_path = @output_full_file_path
END

DECLARE @out_msg VARCHAR(MAX)
IF @flag = 'i'
BEGIN
	--description sometimes become null due to bugs, which may prevent insertion in
	-- messageboard, which results in scheduler failed msg in job execution. So better to handle null
	IF EXISTS(
	       SELECT 1
	       FROM batch_process_notifications bpn
	       WHERE  bpn.process_id = @batch_notification_process_id
	)
	BEGIN
		
		INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type)
		OUTPUT INSERTED.user_login_id 
		INTO #user_login_id(user_login_id)
		SELECT DISTINCT ISNULL (bpn.user_login_id, aru.user_login_id), @trimmed_source, ISNULL(@description, 'Description is null'), @url_desc, @url, @type, @job_name, @as_of_date,@process_id,@process_type
		FROM batch_process_notifications bpn
		LEFT JOIN application_role_user aru ON bpn.role_id=aru.role_Id
		WHERE bpn.process_id = @batch_notification_process_id
			AND bpn.notification_type IN(751,752,755,756)
			AND (bpn.user_login_id IS NOT NULL OR aru.user_login_id IS NOT NULL)
	END
	ELSE IF ISNULL(@trimmed_source,'') <> 'Send Invoice' AND ISNULL(@trimmed_source,'') <> 'Send Confirmation' -- only use for invoice emailing purpose not to show msg in msg board 
	BEGIN
		INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id,  process_type)
		OUTPUT INSERTED.user_login_id 
		INTO #user_login_id(user_login_id)
		SELECT @user_login_id, @trimmed_source, ISNULL(@description, 'Description is null'), @url_desc, @url, @type, @job_name, @as_of_date,@process_id,@process_type
	END

	IF @export_web_services_id IS NOT NULL AND @report_sp IS NOT NULL
	BEGIN 
		EXEC spa_post_data_to_web_service @export_web_services_id, @report_sp, @output_full_file_path, @process_id, @out_msg OUTPUT
	END
		
	--select @msg
	RETURN
END

IF @flag = 'u'
BEGIN
	--PRINT 'update'
	DECLARE @new_source VARCHAR(200)
	SELECT @new_source = mb.source FROM message_board mb WHERE  job_name=@job_name
	SET @trimmed_source = ISNULL(@trimmed_source, @new_source) -- if source is given null, don't update it.
	--PRINT  @trimmed_source
	--generate file		
	
		IF (OBJECT_ID(@process_table_name) IS NOT NULL OR @report_sp IS NOT NULL) --either process table or SP call returning data is available
		AND @output_full_file_path IS NOT NULL	--export location is provided
		AND @output_extension != '.xlsx'		--exclude Excel files as it is handled from SSRS (spa_export_RDL)
	BEGIN		
			EXEC spa_dump_csv @data_table_name=@process_table_name
		, @full_file_path = @output_full_file_path
			, @compress_file=@compress_file
			, @delim=@delim
			, @is_header=@is_header
			, @xml_format=@xml_format
		, @report_name=@trimmed_source
			, @data_sp=@report_sp
		, @process_id=@process_id
	END

			--post to FTP if configured
			IF EXISTS(SELECT 1 FROM batch_process_notifications bpn
					WHERE  bpn.process_id = @batch_notification_process_id
					AND bpn.file_transfer_endpoint_id IS NOT NULL)
			BEGIN
				DECLARE	
						@file_transfer_endpoint_id	INT,
						@ftp_folder_path			VARCHAR(1024) = NULL ,
						@ftp_result					VARCHAR(MAX),
						@ftp_info					NVARCHAR(MAX),
						@ftp_process_id				NVARCHAR(255)

				--load user defined FTP settings, otherwise load system defined settings	
				SELECT TOP 1
				 @file_transfer_endpoint_id = bpn.file_transfer_endpoint_id
				 , @ftp_folder_path = ISNULL(NULLIF(bpn.ftp_folder_path,''), '')
				 , @ftp_info = CASE WHEN bpn.file_transfer_endpoint_id IS NOT NULL 
					THEN CASE WHEN fte.file_protocol = 3 THEN 'sftp://' + REPLACE(fte.host_name_url, 'sftp://', '') ELSE 'ftp://' + REPLACE(fte.host_name_url, 'ftp://', '') END
				ELSE '' END
				FROM   batch_process_notifications bpn
				LEFT JOIN file_transfer_endpoint fte ON bpn.file_transfer_endpoint_id = fte.file_transfer_endpoint_id
				WHERE  bpn.process_id = @batch_notification_process_id

				SET @ftp_folder_path = REPLACE(@ftp_folder_path, '\', '/')
		
			IF dbo.FNAFileExists(@final_output_full_file_path) = 1
				BEGIN
					EXEC spa_upload_file_to_ftp @file_transfer_endpoint_id = @file_transfer_endpoint_id, @source_filename = @final_output_full_file_path, @remote_directory = @ftp_folder_path, @result = @ftp_result OUTPUT
					
					IF @ftp_result = 'Success'
						SET @ftp_result = 'FTP process completed for <b>' + @trimmed_source + '</b>. Report has been saved at <a href ="'+ @ftp_info + '/' +  ISNULL(@ftp_folder_path,'')  + '"><b>' + @ftp_info + '/' +  ISNULL(@ftp_folder_path,'') + '</b></a>.'
					ELSE
						SET @ftp_result = 'FTP process failed for <b>' + @trimmed_source + '</b>. Error: ' + @ftp_result
			 	
					SET @ftp_process_id = dbo.FNAGetNewID()
			
					INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id)
					SELECT DISTINCT ISNULL(aru.user_login_id, @user_login_id), @trimmed_source, ISNULL(@ftp_result, 'Description is null'), NULL, NULL, @type, NULL, NULL, @ftp_process_id
					FROM batch_process_notifications bpn
					LEFT JOIN application_role_user aru ON bpn.role_id=aru.role_id
					WHERE bpn.process_id = @batch_notification_process_id
						AND bpn.notification_type IN(751,752,755,756)
						AND (bpn.user_login_id IS NOT NULL OR aru.user_login_id IS NOT NULL)
				END
			END
	
	--post to web service if configured
	DECLARE @table_or_sp VARCHAR(MAX)
	--give priority to @report_sp
	SET @table_or_sp = ISNULL(@report_sp, @process_table_name)
    IF @export_web_services_id IS NOT NULL 
		AND (@table_or_sp IS NOT NULL OR @output_full_file_path IS NOT NULL)
	BEGIN 
		EXEC spa_post_data_to_web_service @export_web_services_id, @table_or_sp, @output_full_file_path, @process_id, @out_msg OUTPUT
	END
	
	IF EXISTS (SELECT 1 FROM message_board WHERE job_name = @job_name OR process_id = @process_id)
	BEGIN	
		UPDATE message_board
		SET    [description] = ISNULL(@description, 'Description is null'),
			   url_desc = @url_desc,
			   URL = @url,
			   [TYPE] = @type,
			   [Source] = @trimmed_source ,
			   is_read = 0,
			   update_ts = GETDATE()
		OUTPUT DELETED.user_login_id 
		INTO #user_login_id(user_login_id)
		WHERE  job_name = @job_name OR process_id = @process_id
	END
	ELSE --If message has been deleted from message board, it should be inserted.
	BEGIN
			EXEC spa_message_board 'i',
		     @user_login_id,
		     NULL,
		     @trimmed_source,
		     @description,
		     @url_desc,
		     @url,
		     @type,
		     @job_name,
		     @as_of_date,
		     @process_id,
		     @process_type,
		     @returnOutput,
		     @process_table_name,
		     @email_enable,
		     @email_description,
             @report_sp,
             @source_filter,
             @message_filter,
             @date_filter,
             @file_name
	END
END
IF @flag = 'd' 
BEGIN

	BEGIN TRY 
		BEGIN TRAN
		DECLARE @msg_count INT, @is_alert CHAR(1) = 'n'

		SELECT @is_alert = ISNULL(is_alert, 'n')
		FROM   message_board mb
		INNER JOIN dbo.FNASplit(@message_id, ',') m ON m.item = mb.message_id

		DELETE mb
		OUTPUT DELETED.user_login_id 
		INTO #user_login_id(user_login_id)
		--SELECT *  
		FROM   message_board mb
		INNER JOIN dbo.FNASplit(@message_id, ',') m ON m.item = mb.message_id
		WHERE 1 = 1 
			AND user_login_id = @user_login_id 
			AND ISNULL(mb.is_alert, 'n') = CASE WHEN @message_filter = '1' THEN 'y' ELSE 'n' END

		SELECT @msg_count = COUNT(1)  
		FROM   message_board
		WHERE 1 = 1 
			AND user_login_id = @user_login_id 
			AND ISNULL(is_alert, 'n') = @is_alert AND is_read = 0
			
		

		EXEC spa_ErrorHandler 0
			, 'message_board' -- Name the tables used in the query.
			, 'spa_message_board' -- Name the stored proc.
			, 'Success' -- Operations status.	
			, 'Changes have been saved successfully.' -- Success message.
			, @msg_count -- Remaning message which to display in counter.
		
		COMMIT TRAN	
	END TRY 
	BEGIN CATCH 
		ROLLBACK TRAN
		SET @description = 'Error while deleting data.'

		EXEC spa_ErrorHandler -1
			, 'message_board' -- Name the tables used in the query.
			, 'spa_message_board' -- Name the stored proc.
			, 'Error' -- Operations status.
			, @description -- Success message.
			, @message_id -- The reference of the data deleted.

	END CATCH

	RETURN
END
IF @flag = 'e' 
BEGIN

	BEGIN TRY 
		BEGIN TRAN
		
		DECLARE @delete_sql nvarchar(max)

		SET @delete_sql = 'DELETE mb
		--SELECT *  
		FROM   message_board mb
		WHERE message_id IN ( ' + @message_id + ')';

		EXEC(@delete_sql)

		EXEC spa_ErrorHandler 0
			, 'message_board' -- Name the tables used in the query.
			, 'spa_message_board' -- Name the stored proc.
			, 'Success' -- Operations status.
			, 'Data Deleted Successfully.' -- Success message.
			, '' -- The reference of the data deleted.
		
		COMMIT TRAN	
	END TRY 
	BEGIN CATCH 
		ROLLBACK TRAN
		SET @description = 'Error while deleting data.'

		EXEC spa_ErrorHandler -1
			, 'message_board' -- Name the tables used in the query.
			, 'spa_message_board' -- Name the stored proc.
			, 'Error' -- Operations status.
			, @description -- Success message.
			, '' -- The reference of the data deleted.

	END CATCH

	RETURN
END
IF @flag = 'f' 
BEGIN
	UPDATE mb
		SET mb.is_read = 1
	FROM   message_board mb
	INNER JOIN dbo.FNASplit(@message_id, ',') m ON m.item = mb.message_id
	WHERE 1 = 1 
		AND user_login_id = @user_login_id 
		AND ISNULL(mb.is_alert, 'n') = CASE WHEN @message_filter = '1' THEN 'y' ELSE 'n' END
	
	DECLARE @alert_count INT, @message_count INT

	SELECT @alert_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') = 'y' AND is_read = 0 AND type <> 'r'

	SELECT @message_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') <> 'y' AND is_read = 0 AND type <> 'r'

	
	SELECT 'Success' [ErrorCode]
		, 'message_board' [Module] -- Name the tables used in the query.
		, 'spa_message_board' [Area] -- Name the stored proc.
		, 'Success' [Status] -- Operations status.
		, 'Message marked as Read Successfully.' [Message] -- Success message.
		, @message_id [Recommendation] -- Processed messages id
		, @alert_count [alert_count] -- Remaning alert which to display in counter.
		, @message_count [message_count] -- Remaning message which to display in counter.
	RETURN
END
IF @flag = 'g'
BEGIN
	UPDATE mb
		SET mb.is_read = 0
	FROM   message_board mb
	INNER JOIN dbo.FNASplit(@message_id, ',') m ON m.item = mb.message_id
	WHERE 1 = 1 
		AND user_login_id = @user_login_id 
		AND ISNULL(mb.is_alert, 'n') = CASE WHEN @message_filter = '1' THEN 'y' ELSE 'n' END
	
	SELECT @alert_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') = 'y' AND is_read = 0 AND type <> 'r'

	SELECT @message_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') <> 'y' AND is_read = 0 AND type <> 'r'

	SELECT 'Success' [ErrorCode]
		, 'message_board' [Module] -- Name the tables used in the query.
		, 'spa_message_board' [Area] -- Name the stored proc.
		, 'Success' [Status] -- Operations status.
		, 'Message marked as Unread Successfully.' [Message] -- Success message.
		, @message_id [Recommendation] -- Processed messages id
		, @alert_count [alert_count] -- Remaning alert which to display in counter.
		, @message_count [message_count] -- Remaning message which to display in counter.
	
	RETURN
END
IF @flag = 'z'
BEGIN
	DELETE 
	FROM   message_board
	WHERE  message_id = ISNULL(@message_id, message_id)
	       AND user_login_id = @user_login_id
	       AND ISNULL(is_alert, 'n') = 'y' 
END
IF @flag = 'x'
BEGIN
	SELECT mb.message_id,
	       mb.[description],
	       CAST(mb.create_ts AS VARCHAR(100)) create_ts,
	       dbo.FNAFindDateDifference(mb.create_ts) [date_difference]
	FROM   message_board mb
	WHERE  mb.is_alert = 'y'
	       AND mb.is_alert_processed = 'n'
	       AND mb.user_login_id = @user_login_id
	ORDER BY mb.create_ts DESC
	RETURN
END
IF @flag = 'v'
BEGIN
	SELECT *,dbo.FNADateTimeFormat(ts, 0) create_ts FROM (
		SELECT TOP 10 mb.message_id,
			   mb.user_login_id,
			   mb.source,
			   CASE WHEN (CHARINDEX('<a target', mb.[description]) > 0 AND CHARINDEX('click here', mb.[description]) = 0) THEN REPLACE(REPLACE(description, '<a target="_blank" href', '<a target="_blank" alt' ), '<a target="_blank"', '<a href="javascript: message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ', ''desc''' + CASE WHEN is_alert = 'y' THEN ', ''y''' ELSE '' END + ')"') 
			   + CASE WHEN additional_message IS NOT NULL THEN  +'<p>' + additional_message + '<p>' ELSE '' END   ELSE mb.[description] + CASE WHEN additional_message IS NOT NULL THEN  +'<p>' + additional_message + '<p>' ELSE '' END 
			   END 
			   description,
			   ISNULL(mb.update_ts,mb.create_ts) ts, 
			   'Alert' [message_type],
			   dbo.FNAFindDateDifference(mb.create_ts) [created_on],
			   CASE WHEN (CHARINDEX('<a target', mb.url_desc) > 0 AND CHARINDEX('click here', mb.url_desc) = 0) 
					THEN REPLACE(REPLACE(mb.url_desc, 'href', 'alt' ), '<a target="_blank"', '<a href="javascript: message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ')"') 
					ELSE mb.url_desc 
			   END 
			   url_desc,
			   mb.url,
			   CASE WHEN is_read = 0 THEN 'msg_unread'
			   ELSE ''
			   END [is_read]	
		FROM   message_board mb
		WHERE mb.user_login_id = @user_login_id AND type <> 'r'
			AND is_alert = 'y'
		ORDER BY ISNULL(mb.update_ts,mb.create_ts) DESC
		UNION
		SELECT TOP 10 mb.message_id,
			   mb.user_login_id,
			   mb.source,
			   CASE WHEN (CHARINDEX('<a target', mb.[description]) > 0 AND CHARINDEX('click here', mb.[description]) = 0) THEN REPLACE(REPLACE(description, '<a target="_blank" href', '<a target="_blank" alt' ), '<a target="_blank"', '<a href="javascript: message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ', ''desc''' + CASE WHEN is_alert = 'y' THEN ', ''y''' ELSE '' END + ')"') 
			   + CASE WHEN additional_message IS NOT NULL THEN  +'<p>' + additional_message + '<p>' ELSE '' END   ELSE mb.[description] + CASE WHEN additional_message IS NOT NULL THEN  +'<p>' + additional_message + '<p>' ELSE '' END 
			   END 
			   description,
			   ISNULL(mb.update_ts,mb.create_ts) ts, 
			   'Message' [message_type],
			   dbo.FNAFindDateDifference(mb.create_ts) [created_on],
			   CASE WHEN (CHARINDEX('<a target', mb.url_desc) > 0 AND CHARINDEX('click here', mb.url_desc) = 0) 
					THEN REPLACE(REPLACE(mb.url_desc, 'href', 'alt' ), '<a target="_blank"', '<a href="javascript: message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ')"') 
					ELSE mb.url_desc 
			   END 
			   url_desc,
			   mb.url,
			   CASE WHEN is_read = 0 THEN 'msg_unread'
			   ELSE ''
			   END [is_read]
		FROM   message_board mb
		WHERE mb.user_login_id = @user_login_id AND type <> 'r'
			AND ISNULL(is_alert,'n') = 'n'
		ORDER BY ISNULL(mb.update_ts,mb.create_ts) DESC
	) rs
	ORDER BY message_type, ts DESC

	RETURN
END
-- List of Alert for grid
IF @flag = 'l'
BEGIN

	IF OBJECT_ID('tempdb..#temp_msg_board') IS NOT NULL
		DROP TABLE #temp_msg_board
	SELECT row_number() OVER(ORDER BY ISNULL(mb.update_ts,mb.create_ts) DESC) row_num,
	mb.message_id message_id,
	       --mb.user_login_id,
	       0 [value],
		   mb.source,
	       --mb.[description],
		   --CASE WHEN CHARINDEX('<a target', description) > 0 THEN  REPLACE(REPLACE(description, 'href', 'alt' ), '<a target="_blank"', '<a target="_blank"  href="javascript: message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ')"') ELSE mb.[description] END description,
		   CASE WHEN (CHARINDEX('<a target', mb.[description]) > 0 AND CHARINDEX('click here', mb.[description]) = 0) THEN REPLACE(REPLACE(description, 'href', 'alt' ), '<a target="_blank"', '<a href="javascript: parent.message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ','''',''y'')"') 
		   + CASE WHEN additional_message IS NOT NULL THEN  +'<p>' + additional_message + '<p>' ELSE '' END   ELSE mb.[description] + CASE WHEN additional_message IS NOT NULL THEN  +'<p>' + additional_message + '<p>' ELSE '' END END description,
		   CAST(dbo.FNADateTimeFormat(ISNULL(mb.update_ts,mb.create_ts), 0) AS VARCHAR(100)) create_ts
	       --CASE WHEN is_alert = 'y' THEN 'Alert' ELSE 'Message' END [message_type],
	       --dbo.FNAFindDateDifference(mb.create_ts) [created_on],
		   --mb.url_desc,
		   --mb.url
		   , mb.is_read
	INTO #temp_msg_board
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
	AND is_alert = 'y' AND type <> 'r'
	
	SELECT 
	message_id, [value],source,
	CASE WHEN CHARINDEX('Report Attached File', [description]) > 0
	THEN
	SUBSTRING([description], 0, CHARINDEX('Report Attached File', [description])) + 
	REPLACE(SUBSTRING([description], CHARINDEX('Report Attached File', [description]), LEN([description]) - CHARINDEX('Report Attached File', [description])+ 1), 'alt', 'href') 
	ELSE 
	[description]
	END
	[description]
	,create_ts,is_read
	FROM #temp_msg_board
	ORDER BY row_num 
	RETURN
END
-- List of message for grid
IF @flag = 'o'
BEGIN	
	IF OBJECT_ID('tembdb..#temp_msg_main') IS NOT NULL
		DROP TABLE #temp_msg_main

	SELECT row_number() OVER(ORDER BY ISNULL(mb.update_ts,mb.create_ts) DESC) row_num, mb.message_id,
	       --mb.user_login_id,
	       0 [value],
		   mb.source,
	       --mb.[description],
		   --CASE WHEN CHARINDEX('<a target', description) > 0 THEN  REPLACE(REPLACE(description, 'href', 'alt' ), '<a target="_blank"', '<a target="_blank"  href="javascript: message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ')"') ELSE mb.[description] END description,
		   
		   CASE WHEN (CHARINDEX('<a target', mb.[description]) > 0 AND CHARINDEX('click here', mb.[description]) = 0) THEN REPLACE(REPLACE(description, 'href', 'alt' ), '<a target="_blank"', '<a href="javascript: parent.message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ', ''d'')"') 
				ELSE  mb.[description] END						
			+ CASE WHEN additional_message IS NOT NULL THEN  + '<p>' + additional_message + '<p>' ELSE '' END 
		    
			+ CASE WHEN (CHARINDEX('<a target', mb.url_desc) > 0 AND CHARINDEX('click here', mb.url_desc) = 0) 
				THEN '<span style="float: right; margin-right:10px;">[' + REPLACE(REPLACE(mb.url_desc, 'href', 'alt' ), '<a target="_blank"', '<a href="javascript: parent.message_pop_up_drill(' + CAST(mb.message_id AS VARCHAR(100)) + ', ''u'')"') + ']</span>'
				ELSE ISNULL(mb.url_desc, '') 
		   END 
		   description,
		   CAST(dbo.FNADateTimeFormat(ISNULL(mb.update_ts,mb.create_ts), 0) AS VARCHAR(100)) create_ts
	       --CASE WHEN is_alert = 'y' THEN 'Alert' ELSE 'Message' END [message_type],
	       --dbo.FNAFindDateDifference(mb.create_ts) [created_on],
		   --mb.url_desc,
		   --mb.url
		   , mb.is_read
	INTO #temp_msg_main
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') <> 'y'

	SELECT message_id,[value], source,CASE WHEN CHARINDEX('Report Attached File', [description]) > 0
	THEN
	SUBSTRING([description], 0, CHARINDEX('Report Attached File', [description])) + 
	REPLACE(SUBSTRING([description], CHARINDEX('Report Attached File', [description]), LEN([description]) - CHARINDEX('Report Attached File', [description])+ 1), 'alt', 'href') 
	ELSE 
	[description]
	END
	[description], create_ts, is_read FROM #temp_msg_main ORDER BY row_num 
	RETURN
END
IF @flag = 'm' --selection of distinct source for message board log report
BEGIN
	SELECT DISTINCT REPLACE(REPLACE(mba.source, 'Import Data', 'ImportData'), 'Email Invoices', 'Send Invoices'),
	       REPLACE(REPLACE(mba.source, 'Import Data', 'ImportData'), 'Email Invoices', 'Send Invoices')
	FROM   message_board mba
	WHERE  mba.source NOT LIKE('Message From%')
	GROUP BY mba.source
	
	RETURN
END
IF @flag = 'n' --selection of distinct source for message board log report
BEGIN
	SELECT * FROM message_board WHERE source = 'Workflow Notification' ORDER BY ISNULL(update_ts,create_ts) DESC
	RETURN
END
IF @flag = 'q' --selection of distinct source for message board log report
BEGIN
	SELECT DISTINCT REPLACE(REPLACE(mba.source, 'Import Data', 'ImportData'), 'Email Invoices', 'Send Invoices'),
	       REPLACE(REPLACE(mba.source, 'Import Data', 'ImportData'), 'Email Invoices', 'Send Invoices')
	FROM   message_board mba
	WHERE  mba.source IN ('Deal Settlement', 'ImportData', 'Settlement Reconciliation', 'Email Invoices', 'Import Data', 'Send Invoices')
	
	RETURN
END
IF @flag = 'r' --selection of distinct source while selecting the alert message type
BEGIN
	SELECT DISTINCT mba.source,
	       mba.source
	FROM   message_board mba
	WHERE  mba.is_alert = 'y'
	
	RETURN
END
IF @flag = 'w'
BEGIN
	SELECT au.user_f_name + ' ' + ISNULL(au.user_m_name + ' ', '') + au.user_l_name [USER_NAME], 
		  CONVERT(VARCHAR(200), au.create_ts, 107) [MEMBERSHIP_DATE], 
		  au.user_f_name + ISNULL(' '  + au.user_m_name, '') + ISNULL(' '  + au.user_l_name, '') [full_name], 
		  au.menu_type_role_id [menu_role]
		  , ISNULL(avi.version_label,'Version Label') version_label
		  , avi.version_color
		  , dbo.FNAAppAdminRoleCheck(@db_user) AS [is_admin]
		  , ISNULL(avi.version_label_font_size,'14px') version_label_font_size
	FROM application_users au
		LEFT JOIN application_version_info avi ON 1 = 1
	WHERE au.user_login_id = @db_user
	RETURN
END
IF @flag = 'c'
BEGIN 
	DECLARE @reminder_count INT

	SELECT @alert_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') = 'y' AND is_read = 0 AND type <> 'r'

	SELECT @message_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') <> 'y' AND is_read = 0 AND type <> 'r'
	
	SELECT @reminder_count = COUNT(message_id) 
	FROM   message_board mb
	WHERE mb.user_login_id = @user_login_id
		AND ISNULL(is_alert, 'n') = 'y' AND type = 'r' --AND ISNULL(is_alert_processed, 'n') = 'n'
		AND CONVERT(VARCHAR(16),dbo.FNADateTimeFormat(ISNULL(reminderDate, create_ts),2), 120) = CONVERT(VARCHAR(16),dbo.FNADateTimeFormat(GETDATE(), 2), 120)
	
	--UPDATE message_board
	--SET reminderDate = NULL,
	--	is_alert_processed = 'n'
	--WHERE user_login_id = @user_login_id
	--AND ISNULL(is_alert, 'n') = 'y' AND type = 'r' --AND ISNULL(is_alert_processed, 'n') = 'n'
	--AND reminderDate <= CONVERT(VARCHAR(16),GETDATE(), 120)

	SELECT @alert_count alert_count, @message_count message_count, @reminder_count reminder_count

	RETURN
END

IF @flag = 'j' --updates recommendation to null 
BEGIN
	BEGIN TRY
		BEGIN TRAN

			UPDATE source_system_data_import_status
			SET recommendation = NULL
			WHERE process_id = @process_id

			SET @returnOutput = 'n'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
	ROLLBACK TRAN
		EXEC spa_ErrorHandler -1
			, 'source_system_data_import_status' 
			, 'spa_message_board' 
			, 'Error' 
			, 'Error updating message'
			, @process_id 
	END CATCH

END

IF @returnOutput = 'y'
BEGIN
	--PRINT 'select'
	SET @sql = 'SELECT message_id,
					   user_login_id,
					   source,
					   [description],
					   url_desc,
					   URL,
					   [type],
					   --dbo.FNADateTimeFormat(create_ts, 1) AS create_ts,
					   CONVERT(VARCHAR(24),create_ts,113)
					   refresh_speed,
					   php_path,
					   sort_order,
					   message_attachment,
					   is_alert,
					   is_alert_processed,
					   spa
				FROM (
					SELECT  0 AS message_id, 
							au.user_login_id AS user_login_id, 
							'''' AS source, 
							(au.user_f_name + '' '' + ISNULL(au.user_m_name, '''') + '' '' + au.user_l_name) AS [description], 
							'''' url_desc, 
							'''' AS url, 
							'''' AS [type],
							GETDATE() AS create_ts, 
							CAST(ISNULL(au.message_refresh_time, -1) AS VARCHAR) AS refresh_speed, 
							cs.php_path, 
							1 AS sort_order, 
							'''' AS message_attachment,
							'''' AS is_alert,
							'''' AS is_alert_processed,
							'''' spa
					FROM application_users au 
					CROSS JOIN connection_string cs
					WHERE user_login_id = ''' + @user_login_id + '''

					UNION
					SELECT mb.message_id,
						   mb.user_login_id,
						   mb.source,
						   mb.description,
						   mb.url_desc,
						   mb.url,
						   mb.type,
						   mb.create_ts AS create_ts,
						   '''' AS refresh_speed,
						   '''' AS php_path,
						   2 AS sort_order,
						   mb.message_attachment,
						   ISNULL(mb.is_alert, ''n''),
						   ISNULL(mb.is_alert_processed, ''n''),
						   dbo.[FNAGetSplitPart](dbo.[FNAGetSplitPart](' + CASE WHEN @url_or_desc = 'u' THEN 'url_desc' ELSE 'description' END + ', ''spa='', 2), ''">'', 1) spa
					--coalesce(substring(mb.reminderDate,1,10), mb.as_of_date, mb.create_ts) as create_ts
					--, '''' as refresh_speed, '''' as php_path, 2 as sort_order
					FROM message_board mb
					WHERE user_login_id = ''' + @user_login_id + ''' AND delActive <> ''n''
					' +  CASE WHEN nullif(@source_filter, '') IS NOT NULL THEN 'AND source LIKE ''%' + @source_filter + '%'' ' ELSE '' END 
					+ CASE WHEN nullif(@date_filter, '') IS NOT NULL THEN 'AND  dbo.FNAGetSQLStandardDate(create_ts) =''' + cast( dbo.FNAGetSQLStandardDate(@date_filter) AS VARCHAR(50)) + '''' ELSE '' END
					+ CASE WHEN nullif(@message_filter, '') IS NOT NULL THEN 'AND [description] LIKE ''%' + @message_filter + '%'' ' ELSE '' END
					+ '
			 
				) return_rows
	            where source not like ''%Dynamic Limit%''
				and return_rows.message_id = ' + CASE WHEN @message_id <> '' THEN @message_id ELSE 'return_rows.message_id' END + ' 
				ORDER BY sort_order,CAST(create_ts AS DATETIME) DESC'
			
	--PRINT @sql
	EXEC (@sql)	
END
	
IF @email_enable='y'
BEGIN
	--Send Email with attachments
	DECLARE @subject VARCHAR(200)
	IF CHARINDEX('Invoice statement', @email_description) <> 0
		SET @subject = 'Invoice to Counterparty'
	ELSE IF CHARINDEX('Remittance statement', @email_description) <> 0
		SET @subject = 'Remittance to Counterparty'
	ELSE 
		SET @subject = ISNULL(@email_subject, 'TRM Tracker Notifications')

	DECLARE @php_path VARCHAR(500), @shared_document_path varchar(1000)
	SELECT @php_path = cs.php_path, @shared_document_path = cs.document_path  FROM connection_string cs
	
	BEGIN
		DECLARE @new_report_url VARCHAR(MAX)
		DECLARE @FindSubString VARCHAR(MAX), 
                @occurance INT	
		SET @description = ISNULL(@email_description, dbo.FNAStripAnchor(@description))
				
		IF @report_sp IS NOT NULL
		BEGIN
			
			SELECT @new_report_url = @description --removed the hyperlink for now--+ '<br /><p><a target="_blank" href="' + @php_path + 'spa_report_executor.php?viewer_id=' + bpn.process_id + '">Click here</a> to view report.</p>' 
				FROM batch_process_notifications bpn
				LEFT JOIN application_role_user aru ON bpn.role_id=aru.role_Id
				LEFT JOIN application_users au ON au.user_login_id=ISNULL(bpn.user_login_id,aru.user_login_id)
				WHERE bpn.process_id=RIGHT(ISNULL(@job_name,@process_id),13) 
					AND bpn.notification_type IN(750,752,754,756)
					AND user_emal_add IS NOT NULL 
			IF @email_description IS NOT NULL
				SET @report_sp = @php_path + 'dev/spa_html.php?spa=exec ' + @report_sp + '&rnd=4'
			ELSE 
				SET @report_sp = @php_path + REPLACE(@report_sp, './dev', 'dev')
		END
		
		IF @is_aggregate = 0 OR @is_aggregate = 2
		BEGIN
		INSERT INTO email_notes
		  (
			[internal_type_value_id],
			[category_value_id],
			[notes_object_id],
			[notes_object_name],
			[send_status],
			[active_flag],
			[notes_subject],
			[notes_text],
			[send_from],
			[send_to],
			[attachment_file_name],
			[process_id],
			[notes_description]
		  )
		SELECT DISTINCT
			   NULL [internal_type_value_id],
				NULL [category_value_id],
				NULL [notes_object_id],
				NULL [notes_object_name],
				'n' [send_status],
				'y' [active_flag],
				@subject [notes_subject],
			   ISNULL(@new_report_url , @description),
			   'noreply@pioneersolutionsglobal.com',
			   user_emal_add,
			   --CASE WHEN bpn.attach_file = 'y' AND @process_table_name IS NOT NULL THEN @process_table_name ELSE NULL END,
			   CASE 
				WHEN bpn.attach_file = 'y' AND @final_output_full_file_path IS NOT NULL THEN @final_output_full_file_path
				WHEN bpn.attach_file = 'y' AND @process_table_name IS NOT NULL THEN @process_table_name
				ELSE NULL
				END [attachment_file_name],
			   bpn.process_id,
			   @report_sp
		FROM batch_process_notifications bpn
		LEFT JOIN application_role_user aru ON bpn.role_id=aru.role_Id
		LEFT JOIN application_users au ON au.user_login_id=ISNULL(bpn.user_login_id,aru.user_login_id)
		WHERE  bpn.process_id = @batch_notification_process_id
			AND bpn.notification_type IN(750,752,754,756)
			AND user_emal_add IS NOT NULL	
	END	
	END	
	--for non-system users
	BEGIN
		DECLARE @email_desc VARCHAR(5000)
		DECLARE @proc_table_name VARCHAR(100)
			
		SET @email_desc = 'Batch process completed for <b>' + @job_name + '</b>.'
		
		SELECT @proc_table_name = dbo.FNAProcessTableName('batch_report', dbo.FNADBUser(), @process_id)
		IF @is_aggregate = 0 OR @is_aggregate = 2
		BEGIN	
		INSERT INTO email_notes
		  (
			[internal_type_value_id],
			[category_value_id],
			[notes_object_id],
			[notes_object_name],
			[send_status],
			[active_flag],
			[notes_subject],
			[notes_text],
			[send_from],
			[send_to],
			[attachment_file_name],
			[process_id],
			[notes_description],
			[send_cc],
			[send_bcc]
		  )
		SELECT DISTINCT
			   NULL [internal_type_value_id],
				NULL [category_value_id],
				NULL [notes_object_id],
				NULL [notes_object_name],
				'n' [send_status],
				'y' [active_flag],
				@subject [notes_subject],
			   ISNULL(@email_description, @email_desc),
			   'noreply@pioneersolutionsglobal.com',
			   bpn.non_sys_user_email,
			   --CASE WHEN bpn.attach_file = 'y' AND @process_table_name IS NOT NULL THEN @process_table_name ELSE NULL END,
			   CASE 
				WHEN bpn.attach_file = 'y' AND @output_full_file_path IS NOT NULL THEN @output_full_file_path
				WHEN bpn.attach_file = 'y' AND @process_table_name IS NOT NULL THEN @process_table_name
				ELSE NULL
				END [attachment_file_name],
				bpn.process_id [process_id],
				@report_sp [notes_description],
				bpn.cc_email [send_cc],
				bpn.bcc_email [send_bcc]
		FROM batch_process_notifications bpn
		WHERE bpn.process_id = @batch_notification_process_id
                AND bpn.notification_type IN(750,752,754,756) AND non_sys_user_email IS NOT NULL
	END
	END
END

