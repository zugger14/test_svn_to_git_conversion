--SELECT * FROM adiha_default_codes
--SELECT * FROM adiha_default_codes_params
--SELECT * FROM adiha_default_codes_values

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes WHERE code_def = 'Setup Menu')
BEGIN
	INSERT INTO adiha_default_codes(default_code_id, default_code
								, code_description
								, code_def
								, instances)	
	VALUES(51, 'spa_setup_menu', 'Manage Setup Menu parameters', 'Setup Menu', 1)						
END
ELSE
	PRINT 'Setup menu already exists.'
	
GO

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_params WHERE var_name = 'spa_setup_menu')
BEGIN
	INSERT INTO adiha_default_codes_params(seq_no, default_code_id
								, var_name
								, [type_id] 
								, var_length
								, value_type)	
	VALUES(1, 51, 'spa_setup_menu', 3, NULL, 'h')						
END
ELSE
	PRINT 'Data already exists.'
	
GO

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values WHERE [description] = 'Setup Menu')
BEGIN
	INSERT INTO adiha_default_codes_values(instance_no, default_code_id
								, seq_no
								, var_value
								, [description])	
	VALUES(1, 51, 1, 1, 'Setup Menu')						
END
ELSE
	PRINT 'Data already exists.'
	
GO





