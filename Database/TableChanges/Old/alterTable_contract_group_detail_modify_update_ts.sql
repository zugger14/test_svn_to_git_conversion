IF COL_LENGTH('contract_group_detail', 'update_ts') IS NOT NULL
BEGIN
    ALTER TABLE contract_group_detail ALTER COLUMN update_ts DATETIME
END
GO