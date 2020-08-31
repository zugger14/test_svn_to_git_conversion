IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'trade_ticket_template')
BEGIN
	ALTER TABLE source_deal_header_template ADD trade_ticket_template CHAR(1)
END