IF COL_LENGTH('pratos_formula_mapping', 'curve_type') IS NULL
BEGIN
	ALTER TABLE pratos_formula_mapping add curve_type VARCHAR(100)

	PRINT 'Column pratos_formula_mapping.curve_type added.'
END
ELSE
BEGIN
	PRINT 'Column pratos_formula_mapping.curve_type already exists.'
END
GO 

IF COL_LENGTH('pratos_formula_mapping', 'id') IS NULL
BEGIN
	ALTER TABLE pratos_formula_mapping ADD id INT IDENTITY(1, 1)

	PRINT 'Column pratos_formula_mapping.id added.'
END
ELSE
BEGIN
	PRINT 'Column pratos_formula_mapping.id already exists.'
END
GO 