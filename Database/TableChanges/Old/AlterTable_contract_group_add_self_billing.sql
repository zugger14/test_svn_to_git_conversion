IF COL_LENGTH('contract_group', 'self_billing') IS NULL
BEGIN
    ALTER TABLE contract_group ADD self_billing CHAR(1)
END
GO
