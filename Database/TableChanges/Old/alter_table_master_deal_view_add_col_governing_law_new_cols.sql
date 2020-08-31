--header level columns
IF COL_LENGTH('master_deal_view', 'governing_law') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD governing_law VARCHAR(500)
	PRINT 'Column ''governing_law'' added.'
END
ELSE PRINT 'Column ''governing_law'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'payment_term') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD payment_term VARCHAR(1000)
	PRINT 'Column ''payment_term'' added.'
END
ELSE PRINT 'Column ''payment_term'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'arbitration') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD arbitration VARCHAR(500)
	PRINT 'Column ''arbitration'' added.'
END
ELSE PRINT 'Column ''arbitration'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'counterparty2_trader') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD counterparty2_trader VARCHAR(500)
	PRINT 'Column ''counterparty2_trader'' added.'
END
ELSE PRINT 'Column ''counterparty2_trader'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'counterparty_trader') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD counterparty_trader VARCHAR(500)
	PRINT 'Column ''counterparty_trader'' added.'
END
ELSE PRINT 'Column ''counterparty_trader'' already exists.'
GO

--detail level columns
IF COL_LENGTH('master_deal_view', 'batch_id') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD batch_id VARCHAR(10)
	PRINT 'Column ''batch_id'' added.'
END
ELSE PRINT 'Column ''batch_id'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'buyer_seller_option') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD buyer_seller_option VARCHAR(200)
	PRINT 'Column ''buyer_seller_option'' added.'
END
ELSE PRINT 'Column ''buyer_seller_option'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'crop_year') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD crop_year VARCHAR(10)
	PRINT 'Column ''crop_year'' added.'
END
ELSE PRINT 'Column ''crop_year'' already exists.'
GO

IF COL_LENGTH('master_deal_view', 'product_description') IS NULL
BEGIN
	ALTER TABLE dbo.master_deal_view ADD product_description VARCHAR(500)
	PRINT 'Column ''product_description'' added.'
END
ELSE PRINT 'Column ''product_description'' already exists.'
GO
