IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163601)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163601, 'Flow Optimization Run Solver', 'Flow Optimization Run Solver', 10163600, '')
 	PRINT ' Inserted 10163601 - Flow Optimization Run Solver.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163601 - Flow Optimization Run Solver already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163602)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163602, 'Flow Optimization Save Schedule', 'Flow Optimization Save Schedule', 10163600, '')
 	PRINT ' Inserted 10163602 - Flow Optimization Save Schedule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163602 - Flow Optimization Save Schedule already EXISTS.'
END
