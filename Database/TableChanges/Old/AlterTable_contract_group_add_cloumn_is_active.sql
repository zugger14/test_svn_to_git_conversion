IF COL_LENGTH('contract_group', 'is_active') IS NULL
BEGIN
    ALTER TABLE contract_group ADD is_active CHAR(1)
END
GO
