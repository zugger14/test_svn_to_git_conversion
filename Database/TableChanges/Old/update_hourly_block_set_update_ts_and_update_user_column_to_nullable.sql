--hourly_block
IF COL_LENGTH('hourly_block', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE hourly_block ALTER COLUMN update_user VARCHAR(50) NULL
END
GO

IF COL_LENGTH('hourly_block', 'update_ts') IS NOT NULL
BEGIN
    ALTER TABLE hourly_block ALTER COLUMN update_ts DATETIME NULL
END
GO

--holiday_block
IF COL_LENGTH('holiday_block', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE holiday_block ALTER COLUMN update_user VARCHAR(50) NULL
END
GO

IF COL_LENGTH('holiday_block', 'update_ts') IS NOT NULL
BEGIN
    ALTER TABLE holiday_block ALTER COLUMN update_ts DATETIME NULL
END
GO


--holiday_block_audit
IF COL_LENGTH('holiday_block_audit', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE holiday_block_audit ALTER COLUMN update_user VARCHAR(50) NULL
END
GO

IF COL_LENGTH('holiday_block_audit', 'update_ts') IS NOT NULL
BEGIN
    ALTER TABLE holiday_block_audit ALTER COLUMN update_ts DATETIME NULL
END
GO


