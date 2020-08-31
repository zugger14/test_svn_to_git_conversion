SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[approved_product]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].approved_product(
		approved_product_id				INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		approved_counterparty_id		INT REFERENCES approved_counterparty(approved_counterparty_id) NOT NULL,
		counterparty_product_id			INT REFERENCES counterparty_products(counterparty_product_id) NOT NULL,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].approved_product EXISTS'
END


GO

IF OBJECT_ID('[dbo].[TRGUPD_approved_product]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_approved_product]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_approved_product]
ON [dbo].[approved_product]
FOR UPDATE
AS
    UPDATE approved_product
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM approved_product t
      INNER JOIN DELETED u ON t.approved_product_id = u.approved_product_id
GO