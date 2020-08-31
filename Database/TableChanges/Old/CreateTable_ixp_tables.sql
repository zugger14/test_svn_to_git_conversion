SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_tables]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_tables] (
    	[ixp_tables_id]				 INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_tables_name]         VARCHAR(100) NULL,
    	[ixp_tables_description]  VARCHAR(100) NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_tables EXISTS'
END
 
GO


SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_tables]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_tables]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_tables]
ON [dbo].[ixp_tables]
FOR UPDATE
AS
    UPDATE ixp_tables
    SET    update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM   ixp_tables t
    INNER JOIN DELETED u ON  t.ixp_tables_id = u.ixp_tables_id
GO