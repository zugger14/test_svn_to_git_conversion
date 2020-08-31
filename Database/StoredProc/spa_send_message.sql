

/*
Author			: Tara Nath Subedi
Dated			: 02 March 2010
Desc			: Sends Message to specified roles or users.
Log Id			: 1760

Modified By		: Sudeep Lamsal
Date			: 17th Sept 2010
Desc			: Send message to users and roles via message board and email along with an attachment 

*/

IF OBJECT_ID('spa_send_message','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_send_message]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_send_message 'u','farrms_admin,akhadka','This is test message.'
--exec spa_send_message 'r','1,4','This is test message.'
CREATE PROCEDURE [dbo].[spa_send_message]
	@role_user_flag			CHAR(1)			= NULL, --not used
	@role_user_ids			VARCHAR(1000)	= NULL, -- This will have CSV depending on what user/role has been selected.
	@user_ids			    VARCHAR(1000)	= NULL, -- This will have CSV depending on what user/role has been selected.
	@message				VARCHAR(5000)	= NULL,
	@emailFrom				VARCHAR(100)	= NULL,
	@emailSubject			VARCHAR(100)	= NULL,
	@url					VARCHAR(1000)	= NULL,
	@file_name				VARCHAR(100)	= NULL,
	@file_path				VARCHAR(1000)	= NULL,
	@flag					CHAR(1)			= NULL, --'y' for sends email + stores for message board and 'n' only stores for message board (WITH/WITHOUT attachments) AND 'f' forward message
	@message_id				VARCHAR(50)		= NULL,
	@communication_type		VARCHAR(50)		= NULL,
	@job_name				VARCHAR(500)	= NULL,
	@additional_message		VARCHAR(5000)	= NULL,
	@application_functions INT = NULL
												   				
AS
SET NOCOUNT ON
BEGIN
	DECLARE @source VARCHAR(50)
	DECLARE @urlDesc VARCHAR(50)
	DECLARE @type CHAR(1)
	--SET @source=dbo.FNADBUser()  --sender
	SELECT @source= 'Message From:- ' + user_l_name + ', '+ user_f_name FROM application_users WHERE user_login_id=dbo.FNADBUser()

	CREATE TABLE #message_users_roles(
		[ID] [int] IDENTITY(1,1) NOT NULL,
		role_and_user_ids	VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
		flag			CHAR(1) COLLATE DATABASE_DEFAULT  NULL
	)
	IF @user_ids IS NOT NULL
		INSERT INTO #message_users_roles
		SELECT au.user_login_id,NULL FROM application_users au 
		WHERE au.user_login_id IN (SELECT DISTINCT item FROM dbo.SplitCommaSeperatedValues(@user_ids))
		
	IF @role_user_ids <> 'NULL'
		INSERT INTO #message_users_roles
		SELECT au.user_login_id,NULL FROM application_users au 
			LEFT JOIN application_role_user aru ON  au.user_login_id=aru.user_login_id 
		WHERE role_id IN (SELECT distinct item FROM dbo.SplitCommaSeperatedValues(@role_user_ids))

	
	--The script to delete the duplicate records in a table
	DELETE FROM #message_users_roles WHERE ID NOT IN
	(
		SELECT MAX(ID)FROM #message_users_roles GROUP BY role_and_user_ids
	)

	IF @flag='y'
	BEGIN
			DECLARE @send_from VARCHAR(100),@send_to VARCHAR(100),@send_bcc VARCHAR(100),@msgBoardAttachment VARCHAR(1000),@emailAttachment VARCHAR(1000)
			SELECT @send_from= user_emal_add FROM application_users WHERE user_login_id=@emailFrom
			IF (@message IS NOT NULL)
				SET @message = REPLACE(@message, '\', '')
				--PRINT @message 
			IF (@message_id IS NOT NULL) AND (@url IS NULL)
				SELECT @msgBoardAttachment = url from message_board WHERE message_id=CAST(@message_id as INT)
			ELSE
				SET @msgBoardAttachment=@url

			IF @communication_type='752' -- Email and Message Board
			BEGIN	
				SET @send_bcc='noreply@pioneersolutionsglobal.com'
				
				SET @type='E'  
				BEGIN TRY
					SELECT @send_to = user_emal_add FROM application_users WHERE user_login_id = @role_user_ids
					INSERT INTO email_notes
								([internal_type_value_id],[category_value_id],[notes_object_name],[notes_object_id],
								[notes_subject],[notes_text],
								[attachment_file_name],[notes_attachment],
								[send_from],[send_to],[send_cc],[send_bcc]
								,[send_status],[active_flag],
								[create_user],[create_ts],[update_user],[update_ts])
					SELECT 27,NULL,NULL,NULL
							,@emailSubject,@message + '<p>'+ @additional_message + '</p>'
							,@file_path,NULL
							,ISNULL(@send_from,'noreply@pioneersolutionsglobal.com'),au.user_emal_add,NULL,@send_bcc
							,'n','y'
							,NULL,NULL,NULL,NULL
						FROM application_users au 
							INNER JOIN #message_users_roles mur ON  au.user_login_id=mur.role_and_user_ids 
							AND au.user_emal_add IS NOT NULL AND au.user_active = 'y'
					
					SELECT @message = [description] 
					FROM message_board WHERE message_id = @message_id
					
					INSERT INTO message_board(user_login_id, source, [description], [type], [url_desc], [message_attachment],job_name, additional_message)
					SELECT DISTINCT role_and_user_ids,@source,@message,@type,@urlDesc,SUBSTRING(@msgBoardAttachment, 1, LEN(@msgBoardAttachment)), @job_name, @additional_message
					FROM #message_users_roles 	
				END TRY
				BEGIN CATCH 
						 IF @@ERROR <> 0
							EXEC spa_ErrorHandler -1, "message_board", 
									"spa_send_message", "DB Error", 
									"Message sending failed.", ''
						 RETURN
						 
				END CATCH
				EXEC spa_ErrorHandler 0, 'Send Message', 
					'spa_send_message', 'Success', 
					'Message successfully sent.', ''		
			END

			IF @communication_type='751' -- Message Board ONLY
			BEGIN
				SET @type='s'  
				BEGIN TRY
					SELECT @message = [description] 
					FROM message_board WHERE message_id = @message_id
					
					INSERT INTO message_board(user_login_id, source, [description], [type], [url_desc], [message_attachment],job_name, additional_message)
					SELECT DISTINCT role_and_user_ids,@source,@message,@type,@urlDesc,@msgBoardAttachment, @job_name, @additional_message
					FROM #message_users_roles 
				END TRY
				BEGIN CATCH 

					 IF @@ERROR <> 0
						EXEC spa_ErrorHandler -1, "message_board", 
								"spa_send_message", "DB Error", 
								"Message sending failed.", ''
					 RETURN
					 
				END CATCH

				EXEC spa_ErrorHandler 0, 'Send Message', 
				'spa_send_message', 'Success', 
				'Message successfully sent.', ''
			END
			
			IF @communication_type='750' -- Email ONLY
			BEGIN	
				SET @send_bcc='noreply@pioneersolutionsglobal.com'
				
				SET @type='E'  
				BEGIN TRY
					SELECT @send_to = user_emal_add FROM application_users WHERE user_login_id=@role_user_ids
					INSERT INTO email_notes
								([internal_type_value_id],[category_value_id],[notes_object_name],[notes_object_id],
								[notes_subject],[notes_text],
								[attachment_file_name],[notes_attachment],
								[send_from],[send_to],[send_cc],[send_bcc]
								,[send_status],[active_flag],
								[create_user],[create_ts],[update_user],[update_ts])
					SELECT 27,NULL,NULL,NULL
							,@emailSubject,@message + '<p>'+ @additional_message + '</p>'
							,@file_path,NULL
							,ISNULL(@send_from,'noreply@pioneersolutionsglobal.com'),au.user_emal_add,NULL,@send_bcc
							,'n','y'
							,NULL,NULL,NULL,NULL
						FROM application_users au 
							INNER JOIN #message_users_roles mur ON  au.user_login_id=mur.role_and_user_ids 
						AND au.user_emal_add IS NOT NULL AND au.user_active = 'y'
				END TRY
				BEGIN CATCH 
						 IF @@ERROR <> 0
							EXEC spa_ErrorHandler -1, "message_board", 
									"spa_send_message", "DB Error", 
									"Message sending failed.", ''
						 RETURN
						 
				END CATCH
				EXEC spa_ErrorHandler 0, 'Send Message', 
					'spa_send_message', 'Success', 
					'Message successfully sent.', ''		
			END
			ELSE
			BEGIN -- commucation type not handled
				IF @@ERROR <> 0
				EXEC spa_ErrorHandler -1, "message_board", 
						"spa_send_message", "DB Error", 
						"Message sending failed.", ''
				RETURN
			END

	END
	
	IF @flag='f'
	BEGIN
		DECLARE @doc_file_path VARCHAR(500)
		SET @doc_file_path = (SELECT  left(file_attachment_path, charindex('adiha.php.scripts', file_attachment_path) + LEN('adiha.php.scripts')) FROM connection_string AS cs) 
		SELECT message_id, user_login_id, source, REPLACE(DESCRIPTION,'../../adiha.php.scripts/',@doc_file_path) [description], url_desc, message_attachment, [type], job_name, dbo.FNAStripHTML(description) description_no_html
		FROM message_board WHERE message_id = @message_id
	END
	ELSE IF @flag = 'z'-- get file path and name
	BEGIN 
		SELECT  af.file_path
			, i.window_name function_call
			, af.function_desc
		FROM application_functions af
		LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = af.function_id	
		where af.function_id = @application_functions
	END 
END
