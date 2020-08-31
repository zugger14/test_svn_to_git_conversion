IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = '10222300')
BEGIN
	UPDATE application_functions 
	SET function_name = 'Run Deal Settlement'
		,function_desc = 'Run Deal Settlement'
	WHERE function_id = '10222300' 
END
ELSE
	PRINT 'Data can not be updated.'
	
	
IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = '10221000' )
BEGIN
	UPDATE application_functions 
	SET function_name = 'Run Contract Settlement'
		,function_desc = 'Run Contract Settlement'
	WHERE function_id = '10221000' 
END
ELSE
	PRINT 'Data can not be updated.'
	

