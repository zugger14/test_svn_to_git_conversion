IF COL_LENGTH('source_deal_header_template', 'trade_ticket_template_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD trade_ticket_template_id INT
END