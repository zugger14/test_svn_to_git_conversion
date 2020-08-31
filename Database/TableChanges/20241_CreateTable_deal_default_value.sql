SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_default_value]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_default_value] (
    	[deal_default_value_id]           INT IDENTITY(1, 1) NOT NULL,
    	[deal_type_id]                    INT FOREIGN KEY REFERENCES source_deal_type(source_deal_type_id) NOT NULL,
    	[pricing_type]                    INT FOREIGN KEY REFERENCES static_data_value(value_id) NULL,
    	[commodity]						  INT FOREIGN KEY REFERENCES source_commodity(source_commodity_id) NULL,
    	[internal_deal_type]			  INT FOREIGN KEY REFERENCES internal_deal_type_subtype_types(internal_deal_type_subtype_id) NULL,
    	[internal_deal_sub_type]		  INT FOREIGN KEY REFERENCES internal_deal_type_subtype_types(internal_deal_type_subtype_id) NULL,
    	[actual_granularity]			  INT FOREIGN KEY REFERENCES static_data_value(value_id) NULL,
    	[volume_frequency]				  CHAR(1) NULL,
    	[term_frequency]				  CHAR(1) NULL,
    	[pay_opposite]					  CHAR(1) NULL,
    	--
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_default_value EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_default_value]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_default_value]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_default_value]
ON [dbo].[deal_default_value]
FOR UPDATE
AS
    UPDATE deal_default_value
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_default_value t
      INNER JOIN DELETED u ON t.[deal_default_value_id] = u.[deal_default_value_id]
GO