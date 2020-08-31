IF EXISTS (SELECT 1 FROM application_functions AS af WHERE function_id = 10101034)
BEGIN 
	UPDATE application_functions SET func_ref_id = NULL WHERE function_id = 10101034
END 
IF EXISTS (SELECT 1 FROM application_functions AS af WHERE function_id = 10101070)
BEGIN 
	UPDATE application_functions SET func_ref_id = NULL WHERE function_id = 10101070
END 
IF EXISTS (SELECT 1 FROM application_functions AS af WHERE function_id = 10101080)
BEGIN 
	UPDATE application_functions SET func_ref_id = NULL WHERE function_id = 10101080
END 