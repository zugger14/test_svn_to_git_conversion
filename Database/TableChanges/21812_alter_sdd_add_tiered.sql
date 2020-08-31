  
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_audit' AND COLUMN_NAME = 'tiered') 
BEGIN
	ALTER TABLE source_deal_detail_audit ADD tiered CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail' AND COLUMN_NAME = 'tiered') 
BEGIN
	ALTER TABLE source_deal_detail ADD tiered CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'tiered') 
BEGIN
	ALTER TABLE delete_source_deal_detail ADD tiered CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_template' AND COLUMN_NAME = 'tiered') 
BEGIN
	ALTER TABLE source_deal_detail_template ADD tiered CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_audit' AND COLUMN_NAME = 'pricing_description') 
BEGIN
	ALTER TABLE source_deal_detail_audit ADD pricing_description VARCHAR(500)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail' AND COLUMN_NAME = 'pricing_description') 
BEGIN
	ALTER TABLE source_deal_detail ADD pricing_description VARCHAR(500)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'pricing_description') 
BEGIN
	ALTER TABLE delete_source_deal_detail ADD pricing_description VARCHAR(500)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail_template' AND COLUMN_NAME = 'pricing_description') 
BEGIN
	ALTER TABLE source_deal_detail_template ADD pricing_description VARCHAR(500)
END