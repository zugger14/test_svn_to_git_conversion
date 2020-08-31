IF COL_LENGTH('source_price_curve_def', 'derive_on_calculation') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD derive_on_calculation VARCHAR(100) NULL
END
ELSE
BEGIN
    PRINT 'derive_on_calculation Already Exists.'
END 
GO