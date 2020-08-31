IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'option_settlement_date')
BEGIN
	ALTER TABLE source_deal_header ADD option_settlement_date datetime

END