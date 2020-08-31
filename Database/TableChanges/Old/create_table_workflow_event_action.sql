SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_event_action]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_event_action(
		event_action_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		event_message_id	INT REFERENCES workflow_event_message(event_message_id) NOT NULL,
		status_id			INT NOT NULL,
		alert_id			INT NULL,
		[create_user]		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]			DATETIME NULL DEFAULT GETDATE(),
		[update_user]       VARCHAR(50) NULL,
		[update_ts]         DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_event_action EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_event_action]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_event_action]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_event_action]
ON [dbo].[workflow_event_action]
FOR UPDATE
AS
    UPDATE workflow_event_action
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_event_action t
      INNER JOIN DELETED u ON t.event_action_id = u.event_action_id
GO