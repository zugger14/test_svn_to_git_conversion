IF COL_LENGTH('save_invoice', 'invoice_notes') IS NULL
BEGIN
    ALTER TABLE save_invoice ADD invoice_notes VARCHAR(500)
END
GO