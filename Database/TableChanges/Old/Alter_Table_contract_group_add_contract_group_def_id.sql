IF COL_LENGTH('contract_group', 'contract_group_def_id') IS NULL
BEGIN
    ALTER TABLE contract_group ADD contract_group_def_id INT
END

IF COL_LENGTH('contract_group', 'contract_type_def_id') IS NULL
BEGIN
    ALTER TABLE contract_group ADD contract_type_def_id INT
END
GO

IF COL_LENGTH('contract_group', 'contract_email_template') IS NULL
BEGIN
    ALTER TABLE contract_group ADD contract_email_template INT
END
GO


