SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_message_tag]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_message_tag] (
    	[workflow_message_tag_id]		INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[workflow_message_tag_name]     VARCHAR(1000) NOT NULL,
    	[workflow_message_tag]			VARCHAR(1000) NOT NULL,
    	[module_id]						INT,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_message_tag EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_workflow_message_tag]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_message_tag]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_message_tag]
ON [dbo].[workflow_message_tag]
FOR UPDATE
AS
    UPDATE workflow_message_tag
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_message_tag t
      INNER JOIN DELETED u ON t.[workflow_message_tag_id] = u.[workflow_message_tag_id]
GO