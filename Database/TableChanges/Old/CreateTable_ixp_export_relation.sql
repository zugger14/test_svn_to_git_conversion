SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[ixp_export_relation]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_export_relation] (
    	[ixp_export_relation_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_rules_id]            INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[from_data_source]        INT REFERENCES ixp_export_data_source(ixp_export_data_source_id) NOT NULL,
    	[to_data_source]          INT REFERENCES ixp_export_data_source(ixp_export_data_source_id) NOT NULL,
    	[from_column]             VARCHAR(500) NULL,
    	[to_column]               VARCHAR(500) NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_export_relation EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_export_relation]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_export_relation]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_export_relation]
ON [dbo].[ixp_export_relation]
FOR UPDATE
AS
    UPDATE ixp_export_relation
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_export_relation t
      INNER JOIN DELETED u ON t.[ixp_export_relation_id] = u.[ixp_export_relation_id]
GO