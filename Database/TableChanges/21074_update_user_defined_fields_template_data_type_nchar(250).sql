IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_defined_fields_template' AND column_name = 'data_type')
BEGIN
	UPDATE user_defined_fields_template SET data_type = 'nvarchar(250)' WHERE data_type = 'nchar(250)'
END