IF EXISTS(SELECT 1 FROM adiha_default_codes WHERE default_code_id = 105 AND instances = 1)
BEGIN
	UPDATE adiha_default_codes SET default_code = 'limits_in_credit_exposure', code_description = 'Limits in Credit Exposure', code_def = 'Limits in Credit Exposure' WHERE default_code_id = 105 AND instances = 1
END

IF EXISTS(SELECT * FROM adiha_default_codes_values_possible WHERE default_code_id = 105)
BEGIN
	UPDATE adiha_default_codes_values_possible SET description = 'Take only approved Limits' WHERE default_code_id = 105 AND var_value = 0
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 105)
BEGIN
	UPDATE adiha_default_codes_values_possible SET description = 'Take all Limits' WHERE default_code_id = 105 AND var_value = 1
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 106 AND instance_no = 1)
BEGIN
	UPDATE adiha_default_codes_values SET description = 'Take all Collaterals' WHERE default_code_id = 106 AND instance_no = 1 AND var_value = 1
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 106)
BEGIN
	UPDATE adiha_default_codes_values_possible SET description = 'Take only approved collaterals' WHERE default_code_id = 106 AND var_value = 0
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 106)
BEGIN
	UPDATE adiha_default_codes_values_possible SET description = 'Take all Collaterals' WHERE default_code_id = 106 AND var_value = 1
END

IF EXISTS(SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 106 AND instance_no = 1)
BEGIN
	UPDATE adiha_default_codes_values SET description = 'Take all Collaterals' WHERE default_code_id = 106 AND instance_no = 1 AND var_value = 1
END