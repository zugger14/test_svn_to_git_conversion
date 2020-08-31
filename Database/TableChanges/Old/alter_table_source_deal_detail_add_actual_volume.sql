IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_detail' AND COLUMN_NAME = 'actual_volume') 
BEGIN
	ALTER TABLE source_deal_detail ADD actual_volume NUMERIC(28, 8)
END