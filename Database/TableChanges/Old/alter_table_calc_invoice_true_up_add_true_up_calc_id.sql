
IF COL_LENGTH('calc_invoice_true_up','true_up_invoice_number') IS NOT NULL
	ALTER TABLE calc_invoice_true_up DROP COLUMN true_up_invoice_number
GO

IF COL_LENGTH('calc_invoice_true_up','true_up_calc_id') IS NULL
	ALTER TABLE calc_invoice_true_up ADD true_up_calc_id INT NULL
GO



