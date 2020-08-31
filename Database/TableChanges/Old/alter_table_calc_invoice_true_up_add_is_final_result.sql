IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_invoice_true_up' AND COLUMN_NAME = 'is_final_result') 
BEGIN
	ALTER TABLE calc_invoice_true_up ADD is_final_result CHAR(1)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'calc_invoice_true_up' AND COLUMN_NAME = 'true_up_invoice_number') 
BEGIN
	ALTER TABLE calc_invoice_true_up ADD true_up_invoice_number INT
END