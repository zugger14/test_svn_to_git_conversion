IF COL_LENGTH('calc_formula_value', 'finalized') IS NULL
BEGIN
    ALTER TABLE calc_formula_value ADD finalized CHAR(1)
END
GO
UPDATE calc_formula_value SET finalized = 'n'
WHERE finalized IS NULL
GO

IF COL_LENGTH('calc_formula_value', 'finalized_date') IS NULL
BEGIN
    ALTER TABLE calc_formula_value ADD finalized_date DATETIME
END
GO

IF COL_LENGTH('calc_invoice_Volume_variance', 'finalized_date') IS NULL
BEGIN
    ALTER TABLE calc_invoice_Volume_variance ADD finalized_date DATETIME
END
GO

IF COL_LENGTH('calc_invoice_volume', 'finalized_date') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume ADD finalized_date DATETIME
END
GO

IF COL_LENGTH('calc_invoice_Volume_variance', 'original_invoice') IS NULL
BEGIN
    ALTER TABLE calc_invoice_Volume_variance ADD original_invoice INT
END
GO

