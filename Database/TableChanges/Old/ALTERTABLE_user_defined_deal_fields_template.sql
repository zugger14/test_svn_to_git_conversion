
IF COL_LENGTH('user_defined_deal_fields_template', 'internal_field_type') IS NULL
BEGIN
	ALTER TABLE user_defined_deal_fields_template ADD internal_field_type INT
	PRINT 'Column user_defined_deal_fields_template.internal_field_type added.'
END
ELSE
BEGIN
	PRINT 'Column user_defined_deal_fields_template.internal_field_type already exists.'
END
GO

IF COL_LENGTH('user_defined_deal_fields_template', 'currency_field_id') IS NULL
BEGIN
	ALTER TABLE user_defined_deal_fields_template ADD currency_field_id INT
	PRINT 'Column user_defined_deal_fields_template.currency_field_id added.'
END
ELSE
BEGIN
	PRINT 'Column user_defined_deal_fields_template.currency_field_id already exists.'
END
GO
