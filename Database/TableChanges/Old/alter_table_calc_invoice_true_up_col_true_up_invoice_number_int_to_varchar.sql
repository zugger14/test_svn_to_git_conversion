IF COL_LENGTH('calc_invoice_true_up','true_up_invoice_number') IS NOT NULL
	ALTER TABLE calc_invoice_true_up ALTER COLUMN true_up_invoice_number VARCHAR(255)
GO