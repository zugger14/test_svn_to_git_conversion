IF EXISTS(SELECT 1 FROM application_functions WHERE	function_id = 10202200)
BEGIN
	UPDATE application_functions SET function_name = 'View Report' WHERE function_id = 10202200
END
ELSE
BEGIN
	PRINT 'Application FunctionId-10202200 does not EXIST.'
END
