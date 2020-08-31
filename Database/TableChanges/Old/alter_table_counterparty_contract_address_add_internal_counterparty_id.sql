IF COL_LENGTH('counterparty_contract_address', 'internal_counterparty_id') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD internal_counterparty_id INT REFERENCES dbo.source_counterparty (source_counterparty_id)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'rounding') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD rounding BIGINT
END
GO

