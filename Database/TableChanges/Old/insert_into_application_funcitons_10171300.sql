IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10171300, 'Run Unconfirmed Exception Report', 'Run Unconfirmed Exception Report', 10170000, 'windowUnconfirmedExeptionReport')
 	PRINT ' Inserted 10171300 - Run Unconfirmed Exception Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171300 - Run Unconfirmed Exception Report already EXISTS.'
END