IF COL_LENGTH('user_defined_fields_template', 'window_id') IS NULL
BEGIN
    ALTER TABLE user_defined_fields_template ADD [window_id] INT
END