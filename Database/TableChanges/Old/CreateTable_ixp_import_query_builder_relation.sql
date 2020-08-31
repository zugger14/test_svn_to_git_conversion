SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_import_query_builder_relation]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_import_query_builder_relation] (
    	[ixp_import_query_builder_relation_id]  INT IDENTITY(1, 1) NOT NULL,
    	[ixp_rules_id]                          INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[from_table_id]                         INT REFERENCES ixp_import_query_builder_tables(ixp_import_query_builder_tables_id) NOT NULL,
    	[from_column]                           VARCHAR(500) NULL,
    	[to_table_id]                           INT REFERENCES ixp_import_query_builder_tables(ixp_import_query_builder_tables_id) NOT NULL,
    	[to_column]                             VARCHAR(500) NULL,
    	[create_user]                           VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                             DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                           VARCHAR(50) NULL,
    	[update_ts]                             DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_import_query_builder_relation EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_import_query_builder_relation]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_query_builder_relation]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_query_builder_relation]
ON [dbo].[ixp_import_query_builder_relation]
FOR UPDATE
AS
    UPDATE ixp_import_query_builder_relation
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_import_query_builder_relation t
      INNER JOIN DELETED u ON t.[ixp_import_query_builder_relation_id] = u.[ixp_import_query_builder_relation_id]
GO