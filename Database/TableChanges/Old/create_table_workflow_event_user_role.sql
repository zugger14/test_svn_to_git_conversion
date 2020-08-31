SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_event_user_role]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_event_user_role(
		event_user_role_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		event_message_id		INT REFERENCES workflow_event_message(event_message_id) NOT NULL,
		user_login_id			VARCHAR(50) REFERENCES application_users(user_login_id) NULL,
		role_id					INT REFERENCES application_security_role(role_id) NULL,
		[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(50) NULL,
		[update_ts]				DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_event_user_role EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_event_user_role]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_event_user_role]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_event_user_role]
ON [dbo].[workflow_event_user_role]
FOR UPDATE
AS
    UPDATE workflow_event_user_role
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_event_user_role t
      INNER JOIN DELETED u ON t.event_user_role_id = u.event_user_role_id
GO