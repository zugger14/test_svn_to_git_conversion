IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_invoice_volume' AND COLUMN_NAME = 'inventory')
BEGIN
	ALter table calc_invoice_volume ADD inventory CHAR(1)

END