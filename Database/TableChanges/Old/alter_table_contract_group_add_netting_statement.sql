IF COL_LENGTH('contract_group', 'netting_statement') IS NULL
BEGIN
    ALTER TABLE contract_group ADD netting_statement CHAR(1)
END
GO