---- Date	: 2nd April 2012
---- Author : Santosh Gupta 
---- Purpose: This script will insert adiha code 46 & 47 for F10 feature. These codes will be used while creating synonym of all objects 
----		  of Production server at Archive Server
-- 

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes adc WHERE adc.default_code_id = 46)
BEGIN
	INSERT INTO adiha_default_codes (default_code_id, default_code, code_description, code_def, instances)
	VALUES (46, 'application_database', 'Application Database', 'Application Database', 1)	
END

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes adc WHERE adc.default_code_id = 47)
BEGIN
	INSERT INTO adiha_default_codes (default_code_id, default_code, code_description, code_def, instances)
	VALUES (47, 'archive_database', 'Archive Database', 'Archive Database', 1)	
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_params adcp WHERE adcp.default_code_id = 46)
BEGIN
	INSERT INTO adiha_default_codes_params (seq_no, default_code_id, var_name, [type_id], var_length, value_type)
	VALUES (1, 46, 'TRMTracker_Essent_Aplication', 3, NULL, 'h')
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_params adcp WHERE adcp.default_code_id = 47)
BEGIN
	INSERT INTO adiha_default_codes_params (seq_no, default_code_id, var_name, [type_id], var_length, value_type)
	VALUES (1, 47, 'TRMTracker_Essent_Archive', 3, NULL, 'h')
END
-----APPLICATION DATABASE
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'TRMTracker_Essent' AND adcvp.default_code_id = 46)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES (46, 'TRMTracker_Essent', 'TRMTracker_Essent')
END 

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'TRMTracker_UAT' AND adcvp.default_code_id = 46)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES(46, 'TRMTracker_UAT', 'TRMTracker_UAT')
END

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'TRMTracker' AND adcvp.default_code_id = 46)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES (46, 'TRMTracker', 'TRMTracker')
END 

-----ARCHIVE DATABASE
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'TRMTracker_Essent' AND adcvp.default_code_id = 47)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES (47, 'TRMTracker_Essent', 'TRMTracker_Essent')
END 

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'TRMTracker_UAT' AND adcvp.default_code_id = 47)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES(47, 'TRMTracker_UAT', 'TRMTracker_UAT')
END

IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible adcvp WHERE adcvp.var_value = 'TRMTracker' AND adcvp.default_code_id = 47)
BEGIN
	INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description])
	VALUES (47, 'TRMTracker', 'TRMTracker')
END 



-----APPLICATION DATABASE

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values adcv WHERE adcv.default_code_id = 46 AND adcv.var_value = 'TRMTracker_Essent')
BEGIN
	INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, [description])
	VALUES (1, 46, 1, 'TRMTracker_Essent', 'TRMTracker_Essent')
END


-----ARCHIVE DATABASE

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values adcv WHERE adcv.default_code_id = 47 AND adcv.var_value = 'TRMTracker_Essent')
BEGIN
	INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, [description])
	VALUES (1, 47, 1, 'TRMTracker_Essent', 'TRMTracker_Essent')
END