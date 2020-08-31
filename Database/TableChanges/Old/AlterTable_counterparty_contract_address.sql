IF COL_LENGTH('counterparty_contract_address', 'parent_counterparty_id') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_address DROP COLUMN [parent_counterparty_id]
END
GO

IF COL_LENGTH('counterparty_contract_address', 'user_action') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_address DROP COLUMN [user_action]
END
GO

IF COL_LENGTH('counterparty_contract_address', 'counterparty_id') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_address DROP COLUMN [counterparty_id]
END
GO

IF COL_LENGTH('counterparty_contract_address', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD [counterparty_id] INT
END
GO

IF COL_LENGTH('counterparty_contract_address', 'counterparty_description') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_address DROP COLUMN [counterparty_description]
END
GO

IF COL_LENGTH('counterparty_contract_address', 'counterparty_full_name') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD [counterparty_full_name] VARCHAR(400)
END
GO
