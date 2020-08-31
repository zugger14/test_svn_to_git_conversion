SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_event_message_email]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_event_message_email]
    (
    	[workflow_event_message_email_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[message_detail_id]			INT NOT NULL,
		[group_type]				CHAR(1) NULL, 
		[workflow_contacts_id]		INT NULL,
		[query_value]				VARCHAR(1000) NULL, 
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_event_message_email EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_workflow_event_message_email]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_event_message_email]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_event_message_email]
ON [dbo].[workflow_event_message_email]
FOR UPDATE
AS
    UPDATE workflow_event_message_email
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_event_message_email t
      INNER JOIN DELETED u ON t.[workflow_event_message_email_id] = u.[workflow_event_message_email_id]
GO