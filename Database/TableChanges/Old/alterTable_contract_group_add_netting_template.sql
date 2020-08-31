IF COL_LENGTH('contract_group', 'netting_template') IS NULL
BEGIN
    ALTER TABLE contract_group ADD netting_template INT
END
GO