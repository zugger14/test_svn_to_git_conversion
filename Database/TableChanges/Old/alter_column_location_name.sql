IF COL_LENGTH('save_confirm_status', 'location_name') IS NOT NULL
BEGIN
    ALTER TABLE save_confirm_status ALTER COLUMN location_name VARCHAR(2000)
END
GO

IF COL_LENGTH('save_confirm_status', 'external_trade_id') IS NOT NULL
BEGIN
    ALTER TABLE save_confirm_status ALTER COLUMN external_trade_id VARCHAR(2000)
END
GO
