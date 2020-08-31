SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_import_where_clause]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_import_where_clause] (
    	[ixp_import_where_clause_id]  INT IDENTITY(1, 1) NOT NULL,
    	[rules_id]                    INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[table_id]                    INT NULL,
    	[ixp_import_where_clause]     VARCHAR(500) NULL,
    	[create_user]                 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                   DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                 VARCHAR(50) NULL,
    	[update_ts]                   DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_import_where_clause EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_import_where_clause]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_where_clause]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_where_clause]
ON [dbo].[ixp_import_where_clause]
FOR UPDATE
AS
    UPDATE ixp_import_where_clause
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_import_where_clause t
      INNER JOIN DELETED u ON t.[ixp_import_where_clause_id] = u.[ixp_import_where_clause_id]
GO