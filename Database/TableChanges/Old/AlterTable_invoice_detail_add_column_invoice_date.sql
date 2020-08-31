IF COL_LENGTH('invoice_detail', 'invoice_date') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD invoice_date datetime
END
GO

IF COL_LENGTH('invoice_detail', 'invoice_ref_no') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD invoice_ref_no VARCHAR(100)
END
GO


IF COL_LENGTH('invoice_detail', 'short_text') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD short_text VARCHAR(200)
END
GO

IF COL_LENGTH('invoice_detail', 'invoice_description') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD invoice_description VARCHAR(500)
END
GO
