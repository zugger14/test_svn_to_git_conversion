IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211412)
BEGIN
	UPDATE application_functions SET func_ref_id = 10211000 WHERE function_id = 10211412
	PRINT 'UPDATED 10211412 - Setup Contract Component Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211412 - Setup Contract Component Template Does Not EXISTS.'
END
