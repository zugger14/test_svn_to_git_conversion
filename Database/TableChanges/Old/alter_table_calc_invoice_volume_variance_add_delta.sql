IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_invoice_volume_variance' AND COLUMN_NAME = 'delta') 
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD delta CHAR(1)
END