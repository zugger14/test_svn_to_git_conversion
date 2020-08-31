IF COL_LENGTH('calc_invoice_true_up','as_of_date') IS NOT NULL
	ALTER TABLE calc_invoice_true_up ALTER COLUMN as_of_date DATETIME NOT NULL
GO

IF COL_LENGTH('calc_invoice_true_up','prod_date') IS NOT NULL
	ALTER TABLE calc_invoice_true_up ALTER COLUMN prod_date DATETIME NOT NULL
GO

IF COL_LENGTH('calc_invoice_true_up','prod_date_to') IS NOT NULL
	ALTER TABLE calc_invoice_true_up ALTER COLUMN prod_date_to DATETIME NULL
GO
