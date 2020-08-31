IF COL_LENGTH('stmt_counterparty_invoice_detail','invoice_line_item_id') IS NULL
BEGIN
	ALTER TABLE stmt_counterparty_invoice_detail 
	ADD invoice_line_item_id INT
END