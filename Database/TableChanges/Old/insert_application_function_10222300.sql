IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10222300)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10222300, 'Run Settlement', 'Run Settlement', 10220000, 'windowRunSettlement')
 	PRINT ' Inserted 10222300 - Run Settlement.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10222300 - Run Settlement already EXISTS.'
END	


