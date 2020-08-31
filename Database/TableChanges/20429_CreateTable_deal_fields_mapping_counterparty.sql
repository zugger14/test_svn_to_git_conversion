SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_fields_mapping_counterparty]', N'U') IS NULL
BEGIN
   CREATE TABLE [dbo].[deal_fields_mapping_counterparty](
   	[deal_fields_mapping_counterparty_id] INT IDENTITY(1, 1) NOT NULL,
   	[deal_fields_mapping_id]     INT REFERENCES deal_fields_mapping(deal_fields_mapping_id) NOT NULL,
   	[counterparty_type]          CHAR(1) NULL,
   	[entity_type]                INT REFERENCES static_data_value(value_id) NULL,
   	[counterparty_id]            INT REFERENCES source_counterparty(source_counterparty_id) NULL,
   	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
   	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
   	[update_user]                VARCHAR(50) NULL,
   	[update_ts]                  DATETIME NULL
   )

END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping_counterparty EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping_counterparty]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping_counterparty]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping_counterparty]
ON [dbo].[deal_fields_mapping_counterparty]
FOR UPDATE
AS
    UPDATE deal_fields_mapping_counterparty
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping_counterparty t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_counterparty_id] = u.[deal_fields_mapping_counterparty_id]
GO