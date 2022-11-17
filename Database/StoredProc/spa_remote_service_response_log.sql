SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	Purpose							: Logging details of remote services response.
	Created By						: ryadav@pioneersolutionsglobal.com
	Created Date					: 2020-07-31
	Modified By						: 
	Modified Date					:
	
	Parameters 							
	@flag							: Operation flag for various tasks and logic.
									  m => Insertion for Message board.
									  i => Insertion for Web serives.
									  s= > Drilldown responses message.
									  n= > Specific Messaging Logic for EznergyTDSExporter (Timeseries Decimal Segments)

	@remote_service_response_log_id : Remote service response log Id 
	@remote_service_type_id         : Remote service type Id
	@response_status				: Response Status
	@response_message				: Response Message
	@process_id						: Process Id
	@new_process_id					: New Process Id
	@request_identifier				: Request Identifier
	@response_file_name				: Response file name
	@response_msg_detail			: Response message Detail
	@request_msg_detail				: Request message Detail
	@export_web_service_id			: Export web service Id
	@generic_obj_id					: Generic object Id
	@type							: Type
	@source							: Source
	@job_name						: Job name

*/


CREATE OR ALTER PROCEDURE [dbo].[spa_remote_service_response_log]
      @flag								CHAR(50)        
	, @remote_service_response_log_id   INT 			= NULL
	, @remote_service_type_id           INT				= NULL
	, @response_status                  VARCHAR(200)	= NULL
	, @response_message					NVARCHAR(MAX)	= NULL
	, @process_id						VARCHAR(100)    = NULL
	, @new_process_id					VARCHAR(100)	= NULL
	, @request_identifier				VARCHAR(MAX)	= NULL
	, @response_file_name				VARCHAR(80)		= NULL
	, @response_msg_detail				NVARCHAR(MAX)	= NULL
	, @request_msg_detail				NVARCHAR(MAX)	= NULL
	, @export_web_service_id			INT				= NULL
	, @generic_obj_id					INT				= NULL
	, @type                             CHAR(1)			= NULL
	, @source                           NVARCHAR(100)	= NULL
  	, @job_name                         NVARCHAR(400)	= NULL
	
AS

SET NOCOUNT ON;

/*
--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

DECLARE
	 @flag								CHAR(50)        
	, @remote_service_response_log_id   INT 			= NULL
	, @remote_service_type_id           INT				= NULL
	, @response_status                  VARCHAR(200)	= NULL
	, @response_message					NVARCHAR(MAX)	= NULL
	, @process_id						VARCHAR(100)    = NULL
	, @new_process_id					VARCHAR(100)	= NULL
	, @request_identifier				VARCHAR(MAX)	= NULL
	, @response_file_name				VARCHAR(80)		= NULL
	, @response_msg_detail				NVARCHAR(MAX)	= NULL
	, @request_msg_detail				NVARCHAR(MAX)	= NULL
	, @export_web_service_id			INT				= NULL
	, @generic_obj_id					INT				= NULL
	, @type                             CHAR(1)			= NULL
	, @source                           NVARCHAR(100)	= NULL
  	, @job_name                         NVARCHAR(400)	= NULL

	
--Drops all temp tables created in this scope.
EXEC spa_drop_all_temp_table
--*/

DECLARE @SQL VARCHAR(MAX)
DECLARE @detail_url varchar(MAX) , @url varchar(MAX), @success_count NVARCHAR(20), @error_count  NVARCHAR(20)
DECLARE @detail_description varchar(MAX), @total_count NVARCHAR(20)
DECLARE @user_login_id NVARCHAR(250)
SET @user_login_id =  dbo.FNADBUSER()


IF @flag = 'm' or @flag = 'e'
BEGIN
	SET @url  = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_remote_service_response_log @process_id =''' + @new_process_id + ''',@flag=''s'', @response_status=''Error'''

	IF @flag = 'e'
	BEGIN 
		SELECT  @detail_description = response_msg_detail, @response_message = ISNULL(response_message, 'Failed to post data')
		FROM remote_service_response_log rsrl	
		WHERE rsrl.process_id = @new_process_id AND response_status = 'Error'

		SET @type ='e'

		SET @detail_url =  '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;"> Post data Details (' + @source + ')
			 <font color="red">(Error(s) Found).</font> </br> ' + @response_message + '	</ul></a>' 
	END
	ELSE
	BEGIN		

		SELECT @error_count = COUNT(1)
		FROM remote_service_response_log rsrl	
		WHERE rsrl.process_id = @new_process_id AND response_status = 'Error'

		SELECT @success_count = COUNT(1)
		FROM remote_service_response_log rsrl	
		WHERE rsrl.process_id = @new_process_id AND response_status = 'Success'

		SELECT @total_count = COUNT(1)
		FROM remote_service_response_log rsrl	
		WHERE rsrl.process_id = @new_process_id 

		IF @error_count <> 0
		BEGIN
			SET @detail_url =  '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;"> Post data Details (' + @source + ')
			 <font color="red">(Error(s) Found).</font> </br> (Out of ' + @total_count + ' Timeseries Decimal Segments, ' + @success_count + ' successfully posted and ' + @error_count + ' Error(s) found.)	</ul></a>' 
		END
		ELSE
		BEGIN
			SET @detail_url = 'Post data Details (' + @source + ') </br> (' + @success_count + ' Timeseries Decimal Segment(s) successfully posted.)'
		END
	END

	INSERT INTO message_board (
		 user_login_id
		,source
		,[description]
		,url_desc
		,url
		,[type]
		,job_name
		,as_of_date
		,process_id
		)
	SELECT DISTINCT ISNULL(bpn.user_login_id, aru.user_login_id)
		,@source
		,ISNULL(@detail_url, 'Description is null')
		,NULL
		,NULL
		,@type
		,@job_name
		,NULL
		,@new_process_id
	FROM batch_process_notifications bpn
	LEFT JOIN application_role_user aru ON bpn.role_id = aru.role_Id
	WHERE bpn.process_id = RIGHT(@process_id, 13)
		AND bpn.notification_type IN (751,752,755,756)
		AND (bpn.user_login_id IS NOT NULL OR aru.user_login_id IS NOT NULL)

END
ELSE IF @flag = 'n'
BEGIN
	-- For Success case, send message to users in role 'Nomination Submission Notification-Success'
	INSERT INTO message_board (
		 user_login_id
		,source
		,[description]
		,url_desc
		,[url]
		,[type]
		,job_name
		,as_of_date
		,process_id
		)
	SELECT DISTINCT users.user_login_id
		,@source
		,ISNULL('<a target="_blank" href="./dev/spa_html.php?__user_name__=' + users.user_login_id + '&spa=exec spa_remote_service_response_log @process_id =''' + @new_process_id + ''',@flag=''s'', @response_status=''Success''"><ul style="padding:0px;margin:0px;list-style-type:none;"> Post data Details (' + @source + ')</ul></a>', 'Description is null')
		,NULL
		,NULL
		,'s'
		,@job_name
		,NULL
		,@new_process_id
	FROM remote_service_response_log rsrl
	CROSS APPLY (
		SELECT user_login_id FROM application_security_role asr 
		INNER JOIN application_role_user aru ON aru.role_id = asr.role_id
		WHERE role_name = 'Nomination Submission Notification-Success'
	) users
	WHERE rsrl.process_id = @new_process_id AND response_status = 'Success'
	
	-- For Error case, send message to users in role 'Nomination Submission Notification-Error'
	INSERT INTO message_board (
		 user_login_id
		,source
		,[description]
		,url_desc
		,[url]
		,[type]
		,job_name
		,as_of_date
		,process_id
		)
	SELECT DISTINCT users.user_login_id
		,@source
		,ISNULL('<a target="_blank" href="./dev/spa_html.php?__user_name__=' + users.user_login_id + '&spa=exec spa_remote_service_response_log @process_id =''' + @new_process_id + ''',@flag=''s'', @response_status=''Error''"><ul style="padding:0px;margin:0px;list-style-type:none;"> Post data Details (' + @source + ')</ul></a><font color=''red''>(Error(s) Found).</font>', 'Description is null')
		,NULL
		,NULL
		,'e'
		,@job_name
		,NULL
		,@new_process_id
	FROM remote_service_response_log rsrl
	CROSS APPLY (
		SELECT user_login_id FROM application_security_role asr 
		INNER JOIN application_role_user aru ON aru.role_id = asr.role_id
		WHERE role_name = 'Nomination Submission Notification-Error'
	) users
	WHERE rsrl.process_id = @new_process_id AND response_status = 'Error'
END

ELSE IF @flag = 'i'
BEGIN
	INSERT INTO remote_service_response_log (
	  remote_service_type_id
	, response_status
	, response_message
	, process_id
	, request_identifier
	, response_file_name
	, response_msg_detail
	, request_msg_detail
	, export_web_service_id
	, generic_obj_id
	) 
	VALUES (
		  @remote_service_type_id
		, @response_status
		, @response_message
		, @new_process_id
		, @request_identifier
		, @response_file_name
		, @response_msg_detail
		, @request_msg_detail
		, @export_web_service_id
		, @generic_obj_id
		)


	IF @new_process_id IS NOT NULL
	BEGIN
		UPDATE message_board
		SET [description] =   IIF(@type = 's', [description], ([description] + '<font color="red">(Error(s) Found).</font>'))
			, [source] = @source
			, job_name = @job_name
			, [type] = @type
		WHERE process_id = @new_process_id
	END

END

ELSE IF @flag = 's'
BEGIN
	 SELECT  
		  remote_service_response_log_id [System Source ID]
		, response_status [Response Status]
		, response_message [Response Message]
		, process_id [Process ID]
		, request_identifier [Request Identifier]
		, response_file_name [Response Filename]
		, response_msg_detail [Response Message Detail]
		, request_msg_detail [Request Message Detail]
		, create_user [Create User]
		, create_ts [Create TS]
	FROM remote_service_response_log WHERE process_id  =  @process_id 
	AND response_status = ISNULL(@response_status, response_status)  
END

GO	
