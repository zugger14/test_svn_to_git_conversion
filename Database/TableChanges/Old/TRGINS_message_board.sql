SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_message_board]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_message_board]
GO

CREATE TRIGGER [dbo].[TRGINS_message_board]
ON [dbo].[message_board]
FOR  INSERT
AS
	INSERT INTO message_board_audit
	  (
	    message_id,
		user_login_id,
		source,
		description,
		url_desc,
		url,
		type,
		job_name,
		as_of_date,
		create_ts,
		create_user,
		update_ts,
		update_user,
		process_id,
		process_type,
		reminderDate,
		source_id,
		delActive,
		message_attachment,
		is_alert,
		is_alert_processed,
		user_action
	  )
	SELECT message_id,
		user_login_id,
		source,
		REPLACE(description,'./dev', '.'),
		url_desc,
		url,
		type,
		job_name,
		as_of_date,
		create_ts,
		create_user,
		update_ts,
		update_user,
		process_id,
		process_type,
		reminderDate,
		source_id,
		delActive,
		message_attachment,
		is_alert,
		is_alert_processed,
		'insert'
	FROM   INSERTED
	