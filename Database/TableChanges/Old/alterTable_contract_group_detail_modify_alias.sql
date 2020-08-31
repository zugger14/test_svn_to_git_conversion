IF COL_LENGTH('contract_group_detail', 'alias') IS NOT NULL
BEGIN
    ALTER TABLE contract_group_detail ALTER COLUMN alias INT
END
GO
