SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_contacts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_contacts]
    (
    	[workflow_contacts_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[module_id]				INT NOT NULL,
		[email_group]			VARCHAR(1000) NULL,
		[email_group_query]		VARCHAR(MAX) NULL,
		[group_type]				CHAR(1) NULL, 
		[email_address_query]		VARCHAR(MAX) NULL, 
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_contacts EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_workflow_contacts]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_contacts]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_contacts]
ON [dbo].[workflow_contacts]
FOR UPDATE
AS
    UPDATE workflow_contacts
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_contacts t
      INNER JOIN DELETED u ON t.[workflow_contacts_id] = u.[workflow_contacts_id]
GO