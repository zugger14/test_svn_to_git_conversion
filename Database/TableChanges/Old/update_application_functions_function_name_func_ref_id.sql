IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10151010)
BEGIN 
	UPDATE application_functions
		SET function_name = 'Curve Values Add/Save/Delete'
	WHERE function_id = 10151010
END 

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10163110)
BEGIN 
	UPDATE application_functions
		SET func_ref_id = NULL 
	WHERE function_id = 10163110
END 

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10163111)
BEGIN 
	UPDATE application_functions
		SET func_ref_id = NULL 
	WHERE function_id = 10163111
END 