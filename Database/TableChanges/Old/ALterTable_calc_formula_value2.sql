IF COL_LENGTH('calc_formula_value', 'allocation_volume') IS NULL
BEGIN
	ALTER TABLE calc_formula_value add allocation_volume FLOAT
	PRINT 'Column calc_formula_value.allocation_volume added.'
END
ELSE
BEGIN
	PRINT 'Column calc_formula_value.allocation_volume already exists.'
END
GO

