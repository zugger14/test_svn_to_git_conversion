SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_fields_mapping_commodity]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_fields_mapping_commodity](
    	[deal_fields_mapping_commodity_id] INT IDENTITY(1, 1) NOT NULL,
    	[deal_fields_mapping_id]		   INT REFERENCES deal_fields_mapping(deal_fields_mapping_id) NOT NULL,
    	[detail_commodity_id]			   INT REFERENCES source_commodity(source_commodity_id) NOT NULL,
    	[create_user]					   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]						   DATETIME NULL DEFAULT GETDATE(),
    	[update_user]					   VARCHAR(50) NULL,
    	[update_ts]						   DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping_commodity EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping_commodity]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping_commodity]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping_commodity]
ON [dbo].[deal_fields_mapping_commodity]
FOR UPDATE
AS
    UPDATE deal_fields_mapping_commodity
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping_commodity t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_commodity_id] = u.[deal_fields_mapping_commodity_id]
GO