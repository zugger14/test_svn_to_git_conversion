IF COL_LENGTH('user_defined_fields_template', 'data_source_type_id') IS  NULL
BEGIN
    ALTER TABLE user_defined_fields_template ADD data_source_type_id INT
END
GO
