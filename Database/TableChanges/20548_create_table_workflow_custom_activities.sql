SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_custom_activities]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_custom_activities]
    (
    	[workflow_custom_activity_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[workflow_custom_activity_desc]	VARCHAR(5000) NULL,
		[workflow_group_id]				INT NULL,
		[modules_event_id]				INT NULL,
    	[status]						INT NULL,
		[source_column]					VARCHAR(100) NULL,
		[source_id]						INT NULL,
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_custom_activities EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_workflow_custom_activities]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_custom_activities]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_custom_activities]
ON [dbo].[workflow_custom_activities]
FOR UPDATE
AS
    UPDATE workflow_custom_activities
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_custom_activities t
      INNER JOIN DELETED u ON t.[workflow_custom_activity_id] = u.[workflow_custom_activity_id]
GO