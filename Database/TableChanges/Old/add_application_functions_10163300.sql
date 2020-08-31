IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10163300, 'Map Rate Schedules', 'Map Rate Schedules', 10160000, NULL, '_scheduling_delivery/gas/map_rate_schedule/map.rate.schedule.php')
 	PRINT ' Inserted 10163300 - Map Rate Schedules.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163300 - Map Rate Schedules already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163310, 'Add/Save', 'Add/Save', 10163300, NULL)
 	PRINT ' Inserted 10163310 - Add/Save'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163310 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163311)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163311, 'Delete', 'Delete', 10163300, NULL)
 	PRINT ' Inserted 10163311 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163311 - Delete already EXISTS.'
END

