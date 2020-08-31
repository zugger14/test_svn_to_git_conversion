IF EXISTS (SELECT 1 FROM application_functions where function_id = 10163411) 
BEGIN 
	UPDATE application_functions SET func_ref_id = 10163400 WHERE function_id = 10163411
	PRINT 'Updated Application FunctionID-10163411'
END 
ELSE
BEGIN
	PRINT 'Application FunctionID-10163411 Does Not Exist' 
END