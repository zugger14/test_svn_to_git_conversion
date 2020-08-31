IF COL_LENGTH('counterparty_contract_address', 'email') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_address ALTER COLUMN email VARCHAR(1000)
END
GO