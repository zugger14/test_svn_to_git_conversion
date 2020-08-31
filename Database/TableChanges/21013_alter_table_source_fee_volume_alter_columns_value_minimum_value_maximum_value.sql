IF COL_LENGTH('source_fee_volume', 'value') IS NOT NULL
BEGIN
    ALTER TABLE source_fee_volume ALTER COLUMN value FLOAT
END
GO

IF COL_LENGTH('source_fee_volume', 'minimum_value') IS NOT NULL
BEGIN
    ALTER TABLE source_fee_volume ALTER COLUMN minimum_value FLOAT
END
GO

IF COL_LENGTH('source_fee_volume', 'maximum_value') IS NOT NULL
BEGIN
    ALTER TABLE source_fee_volume ALTER COLUMN maximum_value FLOAT
END
GO