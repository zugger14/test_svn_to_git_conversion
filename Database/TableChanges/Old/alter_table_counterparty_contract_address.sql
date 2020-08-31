IF COL_LENGTH('counterparty_contract_address', 'contract_start_date') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD contract_start_date DATETIME
END
GO

IF COL_LENGTH('counterparty_contract_address', 'contract_end_date') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD contract_end_date DATETIME
END
GO

IF COL_LENGTH('counterparty_contract_address', 'apply_netting_rule') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD apply_netting_rule CHAR(1)
END
GO