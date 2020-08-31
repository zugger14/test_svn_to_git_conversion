IF COL_LENGTH('user_defined_fields_template', 'currency_field_id') IS NULL
BEGIN
    ALTER TABLE user_defined_fields_template ADD currency_field_id INT
END
ELSE PRINT 'currency_field_id - Field already exists'
GO

