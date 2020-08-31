SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_type_pricing_maping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_type_pricing_maping](
    	[deal_type_pricing_maping_id]     INT IDENTITY(1, 1) NOT NULL,
    	[template_id]                     INT FOREIGN KEY REFERENCES source_deal_header_template(template_id) NOT NULL,
    	[source_deal_type_id]             INT FOREIGN KEY REFERENCES source_deal_type(source_deal_type_id) NOT NULL,
    	[pricing_type]                    INT FOREIGN KEY REFERENCES static_data_value(value_id) NULL,
    	[fixed_price]                     BIT NULL DEFAULT 0,
    	[curve_id]                        BIT NULL DEFAULT 0,
    	[price_adder]                     BIT NULL DEFAULT 0,
    	[formula_id]                      BIT NULL DEFAULT 0,
    	[multiplier]					  BIT NULL DEFAULT 0,
    	[pricing_start]					  BIT NULL DEFAULT 0,
    	[pricing_end]                     BIT NULL DEFAULT 0,
    	[detail_pricing]				  BIT NULL DEFAULT 0,    	
    	[pricing_tab]                     BIT NULL DEFAULT 0,
    	-- 
    	[create_user]                     VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                       DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                     VARCHAR(50) NULL,
    	[update_ts]                       DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_type_pricing_maping EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_type_pricing_maping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_type_pricing_maping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_type_pricing_maping]
ON [dbo].[deal_type_pricing_maping]
FOR UPDATE
AS
    UPDATE deal_type_pricing_maping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_type_pricing_maping t
      INNER JOIN DELETED u ON t.[deal_type_pricing_maping_id] = u.[deal_type_pricing_maping_id]
GO