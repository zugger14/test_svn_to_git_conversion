IF COL_LENGTH('source_fee_tiered_value', 'value') IS NOT NULL
BEGIN
    ALTER TABLE source_fee_tiered_value ALTER COLUMN value FLOAT
END
GO

IF COL_LENGTH('source_fee_tiered_value', 'from_volume') IS NOT NULL
BEGIN
    ALTER TABLE source_fee_tiered_value ALTER COLUMN from_volume FLOAT
END
GO

IF COL_LENGTH('source_fee_tiered_value', 'to_value') IS NOT NULL
BEGIN
    ALTER TABLE source_fee_tiered_value ALTER COLUMN to_value FLOAT
END
GO