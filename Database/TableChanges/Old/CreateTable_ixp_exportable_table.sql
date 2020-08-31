SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_exportable_table]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_exportable_table] (
    	[ixp_exportable_table_id]           INT IDENTITY(1, 1) NOT NULL,
    	[ixp_exportable_table_name]         VARCHAR(100) NULL,
    	[ixp_exportable_table_description]  VARCHAR(500) NULL,
    	[create_user]                       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                         DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                       VARCHAR(50) NULL,
    	[update_ts]                         DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_exportable_table EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_exportable_table]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_exportable_table]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_exportable_table]
ON [dbo].[ixp_exportable_table]
FOR UPDATE
AS
    UPDATE ixp_exportable_table
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_exportable_table t
      INNER JOIN DELETED u ON t.[ixp_exportable_table_id] = u.[ixp_exportable_table_id]
GO