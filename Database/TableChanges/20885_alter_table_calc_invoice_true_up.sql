IF COL_LENGTH('calc_invoice_true_up','invoice_type') IS NULL
	ALTER TABLE calc_invoice_true_up ADD invoice_type CHAR(1)
GO
