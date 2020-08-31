SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_fields_mapping_uom]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_fields_mapping_uom] (
    	[deal_fields_mapping_uom_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[deal_fields_mapping_id]  INT REFERENCES deal_fields_mapping(deal_fields_mapping_id) NOT NULL,
		[uom_id]				  INT REFERENCES source_uom (source_uom_id) NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping_uom EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping_uom]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping_uom]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping_uom]
ON [dbo].[deal_fields_mapping_uom]
FOR UPDATE
AS
    UPDATE deal_fields_mapping_uom
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping_uom t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_uom_id] = u.[deal_fields_mapping_uom_id]
GO