IF COL_LENGTH('counterparty_contract_address', 'time_zone') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD time_zone INT
END
GO
