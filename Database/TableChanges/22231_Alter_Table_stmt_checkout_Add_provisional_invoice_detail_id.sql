IF COL_LENGTH(N'stmt_checkout', N'provisional_invoice_detail_id') IS NULL
BEGIN
	ALTER TABLE stmt_checkout ADD provisional_invoice_detail_id INT
END