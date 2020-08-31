IF NOT EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code = 'update_index_from_location')
BEGIN
	INSERT INTO adiha_default_codes(default_code_id, default_code, code_description, code_def, instances)
	VALUES(56, 'update_index_from_location', 'Update Index from Location', 'Update Index from Location', 1)
	
	INSERT INTO adiha_default_codes_params(seq_no, default_code_id, var_name, [type_id], var_length, value_type)
	VALUES(1, 56, 'update_index_from_location', 3, NULL, 'h')
	
	INSERT INTO adiha_default_codes_values(instance_no, default_code_id, seq_no, var_value, [description])
	VALUES(1, 56, 1, 1, 'Take Index from Location')
	
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES(56, 0, 'Do not take Index from Location')
	
	INSERT INTO adiha_default_codes_values_possible(default_code_id, var_value, [description]) 
	VALUES(56, 1, 'Take Index from Location')
END