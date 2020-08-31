IF COL_LENGTH('contract_group_audit', 'netting_statement') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD netting_statement char
END
GO

IF COL_LENGTH('contract_group_audit', 'contract_email_template') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD contract_email_template INT
END
GO

