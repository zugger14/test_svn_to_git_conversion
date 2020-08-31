IF COL_LENGTH('invoice_cash_received', 'settle_status') IS NULL
BEGIN
    ALTER TABLE invoice_cash_received ADD settle_status CHAR(1) NULL
END
GO