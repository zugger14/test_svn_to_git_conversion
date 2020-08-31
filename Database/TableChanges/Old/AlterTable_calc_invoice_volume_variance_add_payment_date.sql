IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_invoice_volume_variance' AND COLUMN_NAME = 'payment_date')
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD payment_date DATETIME
END