SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_activities_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_activities_audit(
		workflow_activity_audit_id	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		workflow_activity_id		INT REFERENCES workflow_activities(workflow_activity_id) NOT NULL,
		workflow_trigger_id			INT REFERENCES event_trigger(event_trigger_id) NOT NULL,
		as_of_date					DATETIME NULL DEFAULT GETDATE(),
		control_prior_status		INT,
		control_new_status			INT,
		activity_desc				VARCHAR(250),
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_activities_audit EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_activities_audit]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_activities_audit]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_activities_audit]
ON [dbo].[workflow_activities_audit]
FOR UPDATE
AS
    UPDATE workflow_activities_audit
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_activities_audit t
      INNER JOIN DELETED u ON t.workflow_activity_audit_id = u.workflow_activity_audit_id
GO