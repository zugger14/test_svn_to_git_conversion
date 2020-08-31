IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10236400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10236400, 'Run Available Hedge Capacity Exception Report', 'Run Available Hedge Capacity Exception Report', 10230000, 'windowRunAvailableHedgeCapacityExceptionReport')
 	PRINT ' Inserted 10236400 - Run Available Hedge Capacity Exception Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10236400 - Run Available Hedge Capacity Exception Report already EXISTS.'
END