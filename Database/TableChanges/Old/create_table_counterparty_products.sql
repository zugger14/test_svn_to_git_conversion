SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterparty_products]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].counterparty_products(
		counterparty_product_id			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		counterparty_id					INT REFERENCES source_counterparty(source_counterparty_id) NOT NULL,
		buy_sell						CHAR(1) NOT NULL,
		commodity_id					INT NOT NULL,
		commodity_origin_id				INT REFERENCES commodity_origin(commodity_origin_id) NULL,
		is_organic						CHAR(1) NULL DEFAULT 'n',
		commodity_form_id				INT REFERENCES commodity_form(commodity_form_id) NULL,
		commodity_form_attribute1		INT REFERENCES commodity_form_attribute1(commodity_form_attribute1_id) NULL,
		commodity_form_attribute2		INT REFERENCES commodity_form_attribute2(commodity_form_attribute2_id) NULL,
		commodity_form_attribute3		INT REFERENCES commodity_form_attribute3(commodity_form_attribute3_id) NULL,
		commodity_form_attribute4		INT REFERENCES commodity_form_attribute4(commodity_form_attribute4_id) NULL,
		commodity_form_attribute5		INT REFERENCES commodity_form_attribute5(commodity_form_attribute5_id) NULL,
		trader_id						INT NULL,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].counterparty_products EXISTS'
END


GO

IF OBJECT_ID('[dbo].[TRGUPD_counterparty_products]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_counterparty_products]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_products]
ON [dbo].[counterparty_products]
FOR UPDATE
AS
    UPDATE counterparty_products
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM counterparty_products t
      INNER JOIN DELETED u ON t.counterparty_product_id = u.counterparty_product_id
GO