IF COL_LENGTH('[invoice_cash_received]', '[received_date]') IS NULL
BEGIN
    ALTER TABLE [invoice_cash_received] ALTER COLUMN [received_date] DATETIME NULL
END
GO