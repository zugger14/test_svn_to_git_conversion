IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221317)
BEGIN  
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call) VALUES 
	(10221317, 'Shadow Calc Lock Unlock', 'Shadow Calc Lock Unlock', 10221300, NULL)  
	PRINT ' Inserted 10221317 - Shadow Calc Lock Unlock.'
END
ELSE
BEGIN 
	PRINT 'Application FunctionID 10221317 - Shadow Calc Lock Unlock already EXISTS.'
END