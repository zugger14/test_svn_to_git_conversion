SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_event_message_documents]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_event_message_documents (
		[message_document_id]		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[event_message_id]			INT REFERENCES workflow_event_message(event_message_id) NOT NULL,
		[document_template_id]		INT NOT NULL,
		[effective_date]			DATETIME NULL,
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_event_message_documents EXISTS'
END

GO

IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'workflow_event_message_documents'
                    AND ccu.COLUMN_NAME = 'document_template_id'
)
BEGIN
	DECLARE @constraint_name VARCHAR(100)
	SELECT @constraint_name = tc.CONSTRAINT_NAME
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'workflow_event_message_documents'
                    AND ccu.COLUMN_NAME = 'document_template_id'
	EXEC('ALTER TABLE [dbo].[workflow_event_message_documents] DROP CONSTRAINT [' + @constraint_name + ']') 
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_event_message_documents]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_event_message_documents]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_event_message_documents]
ON [dbo].[workflow_event_message_documents]
FOR UPDATE
AS
    UPDATE workflow_event_message_documents
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_event_message_documents t
      INNER JOIN DELETED u ON t.message_document_id = u.message_document_id
GO