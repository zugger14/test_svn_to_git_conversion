IF COL_LENGTH('source_price_curve_def', 'curve_definition') IS NOT NULL
BEGIN
    ALTER TABLE source_price_curve_def ALTER COLUMN curve_definition VARCHAR(8000)
END
GO