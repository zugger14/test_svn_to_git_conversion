IF COL_LENGTH('contract_group', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE contract_group ADD settlement_calendar INT NULL
END
GO