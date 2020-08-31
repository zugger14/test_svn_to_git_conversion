SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[ixp_custom_import_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_custom_import_mapping] (
    	[ixp_custom_import_mapping_id]  INT IDENTITY(1, 1) NOT NULL,
    	[ixp_rules_id]                  INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[dest_table_id]                 INT REFERENCES ixp_import_query_builder_import_tables(ixp_import_query_builder_import_tables_id) NOT NULL,
    	[destination_column]            VARCHAR(100) NULL,    	
    	[source_table_id]               INT REFERENCES ixp_import_query_builder_tables(ixp_import_query_builder_tables_id) NOT NULL,
    	[source_column]                 VARCHAR(500) NULL,
    	[filter]						VARCHAR(8000) NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_custom_import_mapping EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_custom_import_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_custom_import_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_custom_import_mapping]
ON [dbo].[ixp_custom_import_mapping]
FOR UPDATE
AS
    UPDATE ixp_custom_import_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_custom_import_mapping t
      INNER JOIN DELETED u ON t.[ixp_custom_import_mapping_id] = u.[ixp_custom_import_mapping_id]
GO