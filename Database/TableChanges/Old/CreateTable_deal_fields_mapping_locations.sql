SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_fields_mapping_locations]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_fields_mapping_locations](
    	[deal_fields_mapping_locations_id] INT IDENTITY(1, 1) NOT NULL,
    	[deal_fields_mapping_id]     INT REFERENCES deal_fields_mapping(deal_fields_mapping_id)  NULL,
    	[location_id]                INT REFERENCES source_minor_location(source_minor_location_id)  NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping_locations EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping_locations]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping_locations]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping_locations]
ON [dbo].[deal_fields_mapping_locations]
FOR UPDATE
AS
    UPDATE deal_fields_mapping_locations
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping_locations t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_locations_id] = u.[deal_fields_mapping_locations_id]
GO