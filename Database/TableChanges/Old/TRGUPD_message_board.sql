SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_message_board]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_message_board]
GO

CREATE TRIGGER [dbo].[TRGUPD_message_board]
ON [dbo].[message_board]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.message_board
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.message_board sc
      INNER JOIN DELETED u ON sc.message_id = u.message_id  
	    

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
		update_user,
		update_ts,
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
		dbo.FNADBUser(),
		GETDATE(),
		process_id,
		process_type,
		reminderDate,
		source_id,
		delActive,
		message_attachment,
		is_alert,
		is_alert_processed,
		'update'
	FROM INSERTED