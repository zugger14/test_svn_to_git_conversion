IF COL_LENGTH('counterparty_bank_info', 'currency') IS NULL
BEGIN
    ALTER TABLE counterparty_bank_info ADD currency INT NULL
END
GO