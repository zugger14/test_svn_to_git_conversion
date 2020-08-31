IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'schedule_volume') 
BEGIN
	ALTER TABLE delete_source_deal_detail ADD schedule_volume NUMERIC(38, 20)
END