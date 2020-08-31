IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183001)
BEGIN
	
	UPDATE application_functional_users
	SET function_id = 10183011
	WHERE function_id = 10183001

	DELETE FROM application_functions WHERE function_id = 10183001
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183011)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183011, 'Define Monte Carlo Model Parameters IU', 'Define Monte Carlo Model Parameters IU', 10183000, 'windowMonteCarloModelParameter')
 	PRINT ' Inserted 10183011 - Define Monte Carlo Model Parameters IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183011 - Define Monte Carlo Model Parameters IU already EXISTS.'
END
