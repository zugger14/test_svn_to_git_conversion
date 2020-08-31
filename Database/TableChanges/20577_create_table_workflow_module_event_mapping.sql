SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_module_event_mapping]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].workflow_module_event_mapping (
		mapping_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		module_id		INT,
		event_id		INT,
		is_active		INT NULL,
		[create_user]	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]		DATETIME NULL DEFAULT GETDATE(),
		[update_user]	VARCHAR(50) NULL,
		[update_ts]		DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].workflow_module_event_mapping EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_module_event_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_module_event_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_module_event_mapping]
ON [dbo].[workflow_module_event_mapping]
FOR UPDATE
AS
    UPDATE workflow_module_event_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_module_event_mapping t
      INNER JOIN DELETED u ON t.mapping_id = u.mapping_id
GO