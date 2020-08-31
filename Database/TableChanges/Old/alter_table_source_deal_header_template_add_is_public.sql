IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'is_public')
BEGIN
	ALTER TABLE source_deal_header_template ADD is_public CHAR(1)
END