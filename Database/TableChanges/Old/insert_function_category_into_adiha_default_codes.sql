--Insert Function Category Defination.
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 60) 
BEGIN
	
	INSERT INTO adiha_default_codes(default_code_id, default_code, code_description, code_def, instances) 
	VALUES(60, 'function_category', 'Function Category', 'Function Category', 1)	
	
END
ELSE PRINT 'Function Category defination already exists. '
GO

-- Insert the parameter name.
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_params WHERE seq_no = 1 AND default_code_id = 60)
BEGIN	
	INSERT INTO adiha_default_codes_params
	(
		seq_no,
		default_code_id,
		var_name,
		[type_id],
		var_length,
		value_type
	)
	VALUES
	(
		1,
		60,
		'function_category',
		3,
		NULL,
		'h'
	)
END
ELSE PRINT 'Function Category parameter already exists. '
GO

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 60 AND var_value = 0)
BEGIN
	--Insert possible values of the parameter.
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES (60, 0, 'Function Category')	
END
ELSE PRINT 'Function Category parameter already exists. '
GO
	
--Configured value of the parameter.
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 60 AND instance_no = 1 AND seq_no = 1)
BEGIN
	INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description]) 
	VALUES( 1, 60, 1, 0, 'Function Category')END
ELSE PRINT 'Function Category parameter value already exists. '
GO