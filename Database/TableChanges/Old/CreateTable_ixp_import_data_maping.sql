SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_import_data_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_import_data_mapping] (
    	[ixp_import_data_mapping_id] INT IDENTITY(1, 1) NOT NULL,
		[ixp_rules_id]               INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
		[dest_table_id]              INT NULL,
		[source_column_name]		 VARCHAR(100) NULL,
		[dest_column_name]           VARCHAR(100) NULL,
		[column_function]            VARCHAR(1000) NULL,
		[column_aggregation]         VARCHAR(500) NULL,
    	[create_user]				 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				 VARCHAR(50) NULL,
    	[update_ts]					 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_import_data_mapping EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_import_data_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_data_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_data_mapping]
ON [dbo].[ixp_import_data_mapping]
FOR UPDATE
AS
    UPDATE ixp_import_data_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_import_data_mapping t
      INNER JOIN DELETED u ON t.[ixp_import_data_mapping_id] = u.[ixp_import_data_mapping_id]
GO