
IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_sendemail]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_sendemail]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_sendemail] 
	@mail_profile VARCHAR(100) = 'TRMTracker Mail'
AS
/*
declare @mail_profile VARCHAR(100) = 'TRMTracker Mail'
--*/
DECLARE @count VARCHAR(10),
		@notes_id INT,
		@send_from VARCHAR(100),
		@send_to VARCHAR(5000),
		@send_cc VARCHAR(5000),
		@send_bcc VARCHAR(5000),
		@subject VARCHAR(250),
		@notes_text VARCHAR(MAX),
		@notes_attachment_filename VARCHAR(5000),
		@iMsg INT, --Object reference
		@message VARCHAR(MAX),
		@resultcode INT,
		@the_mailitem_id int --used to store in email_notes to fetch failed items

BEGIN
	IF OBJECT_ID('tempdb..#tmp_email_notes') IS NOT NULL
		DROP TABLE #tmp_email_notes

	CREATE TABLE #tmp_email_notes (
		temp_id INT IDENTITY(1, 1),
		notes_id INT,
		send_from VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		send_to VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
		send_cc VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
		send_bcc VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
		[subject] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
		notes_text VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		notes_attachment_filename VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
	)

	DECLARE @shared_document_path VARCHAR(1000) = NULL

	SELECT @shared_document_path = cs.document_path
	FROM connection_string cs

	INSERT INTO #tmp_email_notes
	SELECT notes_id,
		   send_from,
		   send_to,
		   send_cc,
		   send_bcc,
		   notes_subject,
		   notes_text,
		   LTRIM(RTRIM(STUFF((SELECT ';' + CAST((@shared_document_path + '\' + REPLACE(adi.attachment_file_path, '/', '\')) AS VARCHAR(MAX)) [text()]
				FROM email_notes
			INNER JOIN attachment_detail_info adi 
				ON adi.email_id = notes_id
			WHERE notes_id = en.notes_id
				FOR XML PATH(''), TYPE)
			.value('.','NVARCHAR(MAX)'),1,1,' '))) final_attachment
	FROM email_notes en
	WHERE active_flag = 'y'
		AND send_status = 'n'

	SELECT @count = @@ROWCOUNT

	SELECT @mail_profile = ISNULL(email_profile, @mail_profile) --if not setup in connection string take from input parameter.
	FROM connection_string

	WHILE @count <> 0
	BEGIN
		SELECT @notes_id = notes_id,
			   @send_to = send_to,
			   @send_cc = send_cc,
			   @send_bcc = send_bcc,
			   @subject = [subject],
			   @notes_text = notes_text,
			   @notes_attachment_filename = notes_attachment_filename,
			   @send_from = send_from
		FROM #tmp_email_notes
		WHERE temp_id = @count

		SELECT @message = @notes_text + CHAR(13) + CHAR(13)
		SET @message = @message
		SET @subject = @subject

		IF ISNULL(CHARINDEX('\', @notes_attachment_filename), 0) <> 0
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail @profile_name = @mail_profile,
										 @recipients = @send_to,
										 @copy_recipients = @send_cc,
										 @blind_copy_recipients = @send_bcc,
										 @subject = @Subject,
										 @body = @message,
										 @body_format = 'HTML',
										 @file_attachments = @notes_attachment_filename
										 ,@mailitem_id = @the_mailitem_id OUTPUT;
		END
		ELSE IF @notes_attachment_filename IS NULL
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail @profile_name = @mail_profile,
										 @recipients = @send_to,
										 @copy_recipients = @send_cc,
										 @blind_copy_recipients = @send_bcc,
										 @subject = @Subject,
										 @body = @message,
										 @body_format = 'HTML'
										 ,@mailitem_id = @the_mailitem_id OUTPUT;
		END
		ELSE
		BEGIN
			DECLARE @query AS VARCHAR(1000)

			IF LOWER(SUBSTRING(@notes_attachment_filename, 1, 5)) = 'EXEC '
				SET @query = N'SET NOCOUNT ON;' + @notes_attachment_filename + '; SET NOCOUNT OFF;'
			ELSE
				SET @query = N'SET NOCOUNT ON;SELECT *  FROM ' + @notes_attachment_filename + '; SET NOCOUNT OFF;'

			EXEC msdb.dbo.sp_send_dbmail @profile_name = @mail_profile,
										 @recipients = @send_to,
										 @copy_recipients = @send_cc,
										 @blind_copy_recipients = @send_bcc,
										 @subject = @Subject,
										 @body = @message,
										 @body_format = 'HTML',
										 @query = @query,
										 @exclude_query_output = 0,
										 @attach_query_result_as_file = 1,
										 @query_attachment_filename = 'detail_report.csv',
										 @query_result_header = 1,
										 @query_result_width = 32767,
										 @query_result_separator = '	',
										 @query_result_no_padding = 1
										 ,@mailitem_id = @the_mailitem_id OUTPUT;
		END

		IF @@ERROR <> 0
		BEGIN
			EXEC spa_print 'ERROR'
			
			--update email_type to 'f' to know it is failed
			UPDATE Email_Notes
			SET email_type = 'f'
				, mailitem_id = @the_mailitem_id
			WHERE notes_id = @notes_id
		END
		ELSE
		BEGIN
			UPDATE Email_Notes
			SET send_status = 'y'
				, mailitem_id = @the_mailitem_id
			WHERE notes_id = @notes_id

			EXEC spa_print 'SUCCESS'
		END

		SELECT @count = @count - 1
	END

	/** CAPTURE FAILED EMAIL ITEMS FROM DB MAIL LOG AND UPDATE EMAIL NOTES FOR EMAIL TYPE **/
	update en
		set en.email_type = 'f'
	from email_notes en
	inner join msdb.dbo.sysmail_faileditems sf on sf.mailitem_id = en.mailitem_id
END
