SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_event_message_details]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_event_message_details (
		[message_detail_id]			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[event_message_document_id]	INT NOT NULL,
		[message_template_id]		INT NULL,
		[message]					VARCHAR(500) NULL,
		[counterparty_contact_type]	INT NOT NULL,
		[delivery_method]			INT NOT NULL,
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_event_message_details EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_event_message_details]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_event_message_details]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_event_message_details]
ON [dbo].[workflow_event_message_details]
FOR UPDATE
AS
    UPDATE workflow_event_message_details
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_event_message_details t
      INNER JOIN DELETED u ON t.message_detail_id = u.message_detail_id
GO