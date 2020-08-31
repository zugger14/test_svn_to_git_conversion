IF COL_LENGTH('contract_group', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE contract_group ADD settlement_date INT NULL
END
GO