IF COL_LENGTH('calc_formula_value', 'is_dst') IS NULL
BEGIN
	ALTER TABLE calc_formula_value add is_dst INT
	PRINT 'Column calc_formula_value.is_dst added.'
END
ELSE
BEGIN
	PRINT 'Column calc_formula_value.is_dst already exists.'
END
GO

IF COL_LENGTH('calc_formula_value', 'source_deal_header_id') IS NULL
BEGIN
	ALTER TABLE calc_formula_value add source_deal_header_id INT
	PRINT 'Column calc_formula_value.source_deal_header_id added.'
END
ELSE
BEGIN
	PRINT 'Column calc_formula_value.source_deal_header_id already exists.'
END
GO