IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delete_source_deal_detail' AND COLUMN_NAME = 'cycle') 
BEGIN
	ALTER TABLE delete_source_deal_detail ADD cycle INT
END