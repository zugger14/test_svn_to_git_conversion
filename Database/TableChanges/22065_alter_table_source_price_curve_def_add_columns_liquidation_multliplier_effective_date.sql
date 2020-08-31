IF COL_LENGTH('source_price_curve_def', 'liquidation_multiplier') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD liquidation_multiplier VARCHAR(1000)
END
GO

IF COL_LENGTH('source_price_curve_def', 'effective_date') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD effective_date char(1)
END
GO