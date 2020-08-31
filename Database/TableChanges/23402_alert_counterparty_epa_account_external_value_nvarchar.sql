IF COL_LENGTH('counterparty_epa_account', 'external_value') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_epa_account ALTER COLUMN external_value nvarchar(100)
END
GO
