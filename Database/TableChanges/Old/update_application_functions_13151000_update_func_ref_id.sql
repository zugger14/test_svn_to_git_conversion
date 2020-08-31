/*
* alter func_ref_id for function_id: 13151000 (Run Calc Dynamic Limit)
*/
IF EXISTS (SELECT 1 FROM application_functions af WHERE af.function_id = 13151000)
BEGIN
	UPDATE application_functions
	SET func_ref_id =  10230000
	WHERE function_id = 13151000
	
	PRINT 'Update success.'
END
ELSE
	PRINT 'Function ID 13151000 does not exist.'
	
