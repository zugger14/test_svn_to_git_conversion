IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE var_value = '32' AND default_code_id = 36)
	BEGIN
		INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
		VALUES (36, 32, '(GMT -8:00) Pacific Standard Time (US & Canada)')
		PRINT 'Successfully Inserted'
	END
	
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE var_value = '33' AND default_code_id = 36)
	BEGIN
		INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) 
		VALUES (36, 33, '(GMT -7:00) Mountain Prevailing Time (US & Canada)')
		PRINT 'Successfully Inserted'
	END

	
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE var_value = '34' AND default_code_id = 36)
	BEGIN
		INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) 
		VALUES (36, 34, '(GMT -6:00) Central Prevailing Time (US & Canada), Mexico City')
		PRINT 'Successfully Inserted'
	END


IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE var_value = '35' AND default_code_id = 36)
	BEGIN
		INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) 
		VALUES (36, 35, '(GMT -5:00) Eastern Standard Time (US & Canada), Bogota, Lima')
		PRINT 'Successfully Inserted'
	END