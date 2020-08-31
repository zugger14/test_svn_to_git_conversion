IF COL_LENGTH('calc_formula_value', 'counterparty_limit_id') IS NULL
BEGIN
	ALTER TABLE calc_formula_value add counterparty_limit_id INT
	PRINT 'Column calc_formula_value.counterparty_limit_id added.'
END
ELSE
BEGIN
	PRINT 'Column calc_formula_value.counterparty_limit_id already exists.'
END
GO

