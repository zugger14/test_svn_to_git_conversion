IF COL_LENGTH('counterparty_contract_rate_schedule', 'rate_schedule_id') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_rate_schedule ALTER COLUMN rate_schedule_id INT NULL
END
GO
