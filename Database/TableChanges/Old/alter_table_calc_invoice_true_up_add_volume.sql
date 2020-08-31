IF COL_LENGTH('calc_invoice_true_up', 'volume') IS NULL
	ALTER TABLE calc_invoice_true_up ADD volume NUMERIC(18,4)
GO