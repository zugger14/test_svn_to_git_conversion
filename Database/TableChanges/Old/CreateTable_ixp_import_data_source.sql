SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_import_data_source]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_import_data_source] (
    	[ixp_import_data_source_id]  INT IDENTITY(1, 1) NOT NULL,
    	[rules_id]					 INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[data_source_type]			 INT NULL,
    	[connection_string]          VARCHAR(5000) NULL,
    	[data_source_location]       VARCHAR(5000) NULL,
    	[destination_table]          INT NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_import_data_source EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_import_data_source]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_import_data_source]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_import_data_source]
ON [dbo].[ixp_import_data_source]
FOR UPDATE
AS
    UPDATE ixp_import_data_source
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_import_data_source t
      INNER JOIN DELETED u ON t.[ixp_import_data_source_id] = u.[ixp_import_data_source_id]
GO