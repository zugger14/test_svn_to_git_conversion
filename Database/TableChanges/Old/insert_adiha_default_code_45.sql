IF NOT EXISTS(SELECT 1 FROM adiha_default_codes adc WHERE adc.default_code_id = 45)
BEGIN
	INSERT INTO adiha_default_codes (default_code_id, default_code, code_description, code_def, instances)
	VALUES (45, 'cube_db_server_instance', 'Cube DB Server Instance', 'Cube DB Server Instance', 1)	
END


IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'SPMDBP06\SPMMS009' AND adcvp.default_code_id = 45)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES (45, 'SPMDBP06\SPMMS009', 'Cube PROD DB Server Instance')
END 

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'SPMDBA06\SPMMS008' AND adcvp.default_code_id = 45)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES(45, 'SPMDBA06\SPMMS008', 'Cube UAT DB Server Instance')
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_params adcp WHERE adcp.default_code_id = 45)
BEGIN
	INSERT INTO adiha_default_codes_params (seq_no, default_code_id, var_name, [type_id], var_length, value_type)
	VALUES (1, 45, 'Cube', 3, NULL, 'h')
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values adcv WHERE adcv.default_code_id = 45 AND adcv.var_value = 'SPMDBP06\SPMMS009')
BEGIN
	INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, [description])
	VALUES (1, 45, 1, 'SPMDBP06\SPMMS009', 'Cube PROD DB Server Instance')
END
