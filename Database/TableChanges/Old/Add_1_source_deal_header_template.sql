IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'trader_id')
BEGIN
	ALTER TABLE source_deal_header_template ADD trader_id INT NULL
END