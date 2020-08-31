IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'formula_curve_id')
BEGIN
	ALTER TABLE delete_source_deal_detail ADD formula_curve_id int NULL
END
GO 

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'price_uom_id')
BEGIN
	ALTER TABLE delete_source_deal_detail ADD price_uom_id INT NULL
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'category')
BEGIN
	ALTER TABLE delete_source_deal_detail ADD category int NULL
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'profile_code')
BEGIN
	ALTER TABLE delete_source_deal_detail ADD profile_code INT NULL
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'pv_party')
BEGIN
	ALTER TABLE delete_source_deal_detail ADD pv_party INT NULL
END
GO