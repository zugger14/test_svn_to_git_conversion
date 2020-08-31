IF COL_LENGTH('invoice_detail', 'invoice_due_date') IS NULL
BEGIN
    ALTER TABLE invoice_detail ADD invoice_due_date datetime
END
GO