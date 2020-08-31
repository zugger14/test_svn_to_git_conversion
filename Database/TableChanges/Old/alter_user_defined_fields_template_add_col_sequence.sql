IF COL_LENGTH('user_defined_fields_template', 'sequence') IS NULL
BEGIN
	ALTER TABLE user_defined_fields_template ADD sequence INT
	PRINT 'Column user_defined_fields_template.sequence added.'
END
ELSE
BEGIN
	PRINT 'Column user_defined_fields_template.sequence already exists.'
END
GO
IF COL_LENGTH('user_defined_fields_template', 'leg') IS NULL
BEGIN
	ALTER TABLE user_defined_fields_template ADD leg INT
	PRINT 'Column user_defined_fields_template.leg added.'
END
ELSE
BEGIN
	PRINT 'Column user_defined_fields_template.leg already exists.'
END
GO
