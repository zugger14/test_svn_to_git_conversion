IF COL_LENGTH('stmt_invoice_audit','payment_status') IS NULL
BEGIN
	ALTER TABLE stmt_invoice_audit
	ADD payment_status CHAR(1) NULL
END


