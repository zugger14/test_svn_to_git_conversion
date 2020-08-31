IF EXISTS(SELECT 1 FROM application_functions WHERE	function_id = 10211413)
BEGIN
	UPDATE application_functions SET function_name = 'Delete', function_desc = 'Delete' WHERE function_id = 10211413
END
ELSE
BEGIN
	PRINT 'Application FunctionId-10211413 does not EXIST.'
END