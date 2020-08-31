IF NOT EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code = 'use_correlated_random_value')
BEGIN
	INSERT INTO adiha_default_codes(default_code_id, default_code, code_description, code_def, instances)
	VALUES(58, 'use_correlated_random_value', 'Use correlated random numbers in Monte Carlo simulation', 'Use correlated random numbers in Monte Carlo simulation', 1)
	
	INSERT INTO adiha_default_codes_params(seq_no, default_code_id, var_name, [type_id], var_length, value_type)
	VALUES(1, 58, 'use_correlated_random_value', 3, NULL, 'h')
	
	INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description])
	VALUES(1, 58, 1, 1, 'Use correlated random numbers in Monte Carlo simulation')
	
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES(58, 0, 'Do not use correlated random numbers in Monte Carlo simulation')
	
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES(58, 1, 'Use correlated random numbers in Monte Carlo simulation')
END