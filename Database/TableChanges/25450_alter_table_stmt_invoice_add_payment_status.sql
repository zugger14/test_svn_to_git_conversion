IF COL_LENGTH('dbo.stmt_invoice','payment_status') IS NULL
BEGIN
	ALTER TABLE stmt_invoice
	ADD payment_status CHAR(1) NULL
END

