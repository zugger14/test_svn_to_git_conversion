IF COL_LENGTH('source_fee', 'value') IS NOT NULL
BEGIN
    ALTER TABLE source_fee ALTER COLUMN value FLOAT
END
GO