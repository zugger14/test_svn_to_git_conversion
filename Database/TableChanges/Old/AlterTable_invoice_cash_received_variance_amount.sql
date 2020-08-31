IF COL_LENGTH('invoice_cash_received', 'variance_amount') IS NULL
BEGIN
    ALTER TABLE invoice_cash_received ADD variance_amount FLOAT NULL
END
GO