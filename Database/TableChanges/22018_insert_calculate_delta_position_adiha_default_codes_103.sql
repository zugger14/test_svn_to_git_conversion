IF NOT EXISTS (SELECT 1 FROM adiha_default_codes WHERE default_code_id = 103)
BEGIN
	INSERT INTO adiha_default_codes
	VALUES(103, 'calculate_delta_position', 'Calculate Delta Position', 'Calculate Delta Position', 1)
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 103)
BEGIN
	INSERT INTO adiha_default_codes_values
	VALUES(1, 103, 1, 1, 'Calculate delta position')
END

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 103 AND var_value = 0)
BEGIN
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES(103, 0, 'Do not calculate delta position')
END

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 103 AND var_value = 1)
BEGIN	
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES(103, 1, 'Calculate delta position')
END