IF COL_LENGTH('user_defined_fields_template', 'udf_category') IS NULL
BEGIN
    ALTER TABLE user_defined_fields_template ADD udf_category INT
END
ELSE PRINT 'udf_category - Field already exists'
GO

