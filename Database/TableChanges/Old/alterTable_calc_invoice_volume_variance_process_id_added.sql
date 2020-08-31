IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_invoice_volume_variance' AND COLUMN_NAME = 'process_id')
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD process_id VARCHAR(100)

END