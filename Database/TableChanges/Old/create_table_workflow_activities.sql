SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_activities]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_activities(
		workflow_activity_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		workflow_trigger_id			INT REFERENCES event_trigger(event_trigger_id) NOT NULL,
		as_of_date					DATETIME NULL DEFAULT GETDATE(),
		user_login_id				VARCHAR(50) NULL,
		event_message_id			INT REFERENCES workflow_event_message(event_message_id) NOT NULL,
		control_status				INT NULL,
		approved_by					VARCHAR(50) REFERENCES application_users(user_login_id) NULL,
		approved_date				DATETIME,
		message						VARCHAR(1000),
		comments					VARCHAR(4000),
		process_id					VARCHAR(200),
		process_table				VARCHAR(200),
		source_column				VARCHAR(300),
		source_id					VARCHAR(100),
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_activities EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_activities]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_activities]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_activities]
ON [dbo].[workflow_activities]
FOR UPDATE
AS
    UPDATE workflow_activities
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_activities t
      INNER JOIN DELETED u ON t.workflow_activity_id = u.workflow_activity_id
GO