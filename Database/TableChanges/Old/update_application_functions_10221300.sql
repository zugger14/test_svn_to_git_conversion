IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221300)
BEGIN
	UPDATE application_functions SET func_ref_id = 10221099 WHERE function_id = 10221300
END
ELSE
BEGIN
	PRINT 'Application FunctionId-10221300 already EXIST'
END