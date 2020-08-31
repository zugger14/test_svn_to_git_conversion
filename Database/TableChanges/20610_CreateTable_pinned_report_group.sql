SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pinned_report_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pinned_report_group](
    	[pinned_report_group_id]     INT IDENTITY(1, 1) NOT NULL,
    	[group_name]                 VARCHAR(100) NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table pinned_report_group EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pinned_report_group]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pinned_report_group]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pinned_report_group]
ON [dbo].[pinned_report_group]
FOR UPDATE
AS
    UPDATE pinned_report_group
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pinned_report_group t
      INNER JOIN DELETED u ON t.[pinned_report_group_id] = u.[pinned_report_group_id]
GO