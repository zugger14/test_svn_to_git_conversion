IF COL_LENGTH('user_defined_fields_template', 'split_positive_and_negative_commodity') IS NOT NULL
BEGIN
	ALTER TABLE	user_defined_fields_template
	DROP COLUMN split_positive_and_negative_commodity 
END
GO