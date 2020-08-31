IF EXISTS (SELECT 1 FROM SYS.TRIGGERS WHERE [object_id] = OBJECT_ID(N'[dbo].[TRGINSTD_message_board]'))
	DROP TRIGGER [dbo].[TRGINSTD_message_board]
GO

CREATE TRIGGER [dbo].[TRGINSTD_message_board] ON [dbo].[message_board]
INSTEAD OF INSERT
AS
BEGIN  
	INSERT INTO [dbo].[message_board] (
		[user_login_id], [source], [description], [url_desc], [url], [type], [job_name], [as_of_date], [process_id], [process_type], [reminderDate], 
		[source_id], [delActive], [message_attachment], [is_alert], [is_alert_processed], [additional_message], [is_read], [workflow_activity_id]
	)
	SELECT i.[user_login_id], i.[source], i.[description], i.[url_desc], i.[url], i.[type], i.[job_name], i.[as_of_date], i.[process_id], i.[process_type], i.[reminderDate], 
		   i.[source_id], i.[delActive], i.[message_attachment], i.[is_alert], i.[is_alert_processed], i.[additional_message], i.[is_read], i.[workflow_activity_id]
	FROM INSERTED i
	INNER JOIN application_users au
		ON au.[user_login_id] = i.[user_login_id]
	WHERE au.[user_active] = 'y'
END
GO