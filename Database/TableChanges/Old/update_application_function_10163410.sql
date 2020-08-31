IF EXISTS (SELECT 1 FROM application_functions where function_id =  10163410)
BEGIN
	UPDATE application_functions SET func_ref_id = 10163400 WHERE function_id = 10163410
	PRINT 'Updated Application FunctionId-10163410'
END
ELSE 
BEGIN
	PRINT 'Application FunctionID-10163410 Does Not Exist'
END