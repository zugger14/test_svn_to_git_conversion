IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_defined_fields_template' AND column_name = 'data_type')
BEGIN
	UPDATE user_defined_fields_template SET data_type = 'bit' WHERE data_type = 'binary'
	UPDATE user_defined_fields_template SET data_type = 'nchar(1)' WHERE data_type = 'CHAR(1)'
	UPDATE user_defined_fields_template SET data_type = 'nvarchar(250)' WHERE data_type = 'char(10)'
	UPDATE user_defined_fields_template SET data_type = 'numeric(38,20)' WHERE data_type = 'float'
	UPDATE user_defined_fields_template SET data_type = 'numeric(38,20)' WHERE data_type = 'number'
	UPDATE user_defined_fields_template SET data_type = 'numeric(38,20)' WHERE data_type = 'numeric(18,0)'
	UPDATE user_defined_fields_template SET data_type = 'nchar(250)' WHERE data_type = 'nvarchar(50)'
	UPDATE user_defined_fields_template SET data_type = 'nchar(250)' WHERE data_type = 'text'
	UPDATE user_defined_fields_template SET data_type = 'nchar(250)' WHERE data_type = 'VARCHAR(150)'
	UPDATE user_defined_fields_template SET data_type = 'nchar(250)' WHERE data_type = 'VARCHAR(255)'
	UPDATE user_defined_fields_template SET data_type = 'nchar(250)' WHERE data_type = 'varchar(500)'
	UPDATE user_defined_fields_template SET data_type = 'nchar(250)' WHERE data_type = 'VARCHAR(MAX)'
END
