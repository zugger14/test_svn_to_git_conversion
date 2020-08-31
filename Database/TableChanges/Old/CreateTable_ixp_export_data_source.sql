SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[ixp_export_data_source]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_export_data_source] (
    	[ixp_export_data_source_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_rules_id]               INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[export_table]				 INT NULL,
    	[export_table_alias]         VARCHAR(500) NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_export_data_source EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_export_data_source]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_export_data_source]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_export_data_source]
ON [dbo].[ixp_export_data_source]
FOR UPDATE
AS
    UPDATE ixp_export_data_source
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_export_data_source t
      INNER JOIN DELETED u ON t.[ixp_export_data_source_id] = u.[ixp_export_data_source_id]
GO