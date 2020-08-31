SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_import_relation]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_import_relation] (
    	[ixp_import_relation_id]  INT IDENTITY(1, 1) NOT NULL,
    	[ixp_rules_id]            INT NOT NULL,
    	[ixp_relation_alias]      VARCHAR(100) NULL,
    	[relation_source_type]    INT NULL,
    	[connection_string]       VARCHAR(5000) NULL,
    	[relation_location]       VARCHAR(5000) NULL,
    	[join_clause]			  VARCHAR(MAX) NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_import_relation EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_import_relation]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_relation]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_relation]
ON [dbo].[ixp_import_relation]
FOR UPDATE
AS
    UPDATE ixp_import_relation
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_import_relation t
      INNER JOIN DELETED u ON t.[ixp_import_relation_id] = u.[ixp_import_relation_id]
GO