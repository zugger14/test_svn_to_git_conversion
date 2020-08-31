IF COL_LENGTH('source_price_curve_def', 'is_active') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD is_active CHAR(1)
END
GO
