IF COL_LENGTH('counterparty_contract_address', 'payables') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD payables INT
END
GO
IF COL_LENGTH('counterparty_contract_address', 'receivables') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD receivables INT
END
GO
IF COL_LENGTH('counterparty_contract_address', 'confirmation') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD confirmation INT
END
GO


