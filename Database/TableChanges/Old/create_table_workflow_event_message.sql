SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_event_message]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_event_message (
		event_message_id			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		event_trigger_id			INT REFERENCES event_trigger(event_trigger_id) NOT NULL,
		event_message_name			VARCHAR(100) NOT NULL,
		message_template_id			INT,
		[message]					VARCHAR(1000),
		mult_approval_required		CHAR(1) NOT NULL DEFAULT 'n',
		comment_required			CHAR(1),
		approval_action_required	CHAR(1),
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_event_message EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_event_message]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_event_message]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_event_message]
ON [dbo].[workflow_event_message]
FOR UPDATE
AS
    UPDATE workflow_event_message
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_event_message t
      INNER JOIN DELETED u ON t.event_message_id = u.event_message_id
GO