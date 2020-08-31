IF EXISTS (SELECT 1 FROM application_functions where function_id =  10211216)
BEGIN
	UPDATE application_functions SET function_desc = 'Deploy', func_ref_id = 10211213 WHERE function_id = 10211216
	PRINT 'Updated Application FunctionId-10211216'
END
ELSE 
BEGIN
	PRINT 'Application FunctionID-10211216 Does Not Exist'
END