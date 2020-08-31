SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_import_query_builder_tables]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_import_query_builder_tables] (
    	[ixp_import_query_builder_tables_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_rules_id]                        INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[tables_name]                         VARCHAR(200) NULL,
    	[root_table_id]                       INT NULL,
    	[table_alias]                         VARCHAR(100) NULL,
    	[create_user]                         VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                           DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                         VARCHAR(50) NULL,
    	[update_ts]                           DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_import_query_builder_tables EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_import_query_builder_tables]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_query_builder_tables]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_query_builder_tables]
ON [dbo].[ixp_import_query_builder_tables]
FOR UPDATE
AS
    UPDATE ixp_import_query_builder_tables
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_import_query_builder_tables t
      INNER JOIN DELETED u ON t.[ixp_import_query_builder_tables_id] = u.[ixp_import_query_builder_tables_id]
GO