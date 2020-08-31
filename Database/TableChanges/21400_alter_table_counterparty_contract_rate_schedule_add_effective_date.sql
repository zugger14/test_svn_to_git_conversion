IF COL_LENGTH('counterparty_contract_rate_schedule', 'effective_date') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_rate_schedule ADD effective_date DATE
END
GO
