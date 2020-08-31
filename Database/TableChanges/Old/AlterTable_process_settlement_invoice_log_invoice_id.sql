IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'process_settlement_invoice_log' AND COLUMN_NAME = 'invoice_id')
BEGIN
	ALTER TABLE process_settlement_invoice_log add [invoice_id] INT NULL
END


