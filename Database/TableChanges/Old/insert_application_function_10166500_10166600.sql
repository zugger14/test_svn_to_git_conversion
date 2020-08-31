IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10166500, 'Actualize Schedules', 'Actualize Schedules', 10160000, NULL, '_scheduling_delivery/scheduling_workbench/actualize.schedules.php')
 	PRINT ' Inserted 10166500 - Actualize Schedules.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166500 - Actualize Schedules already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10166600, 'ticket', 'Ticket', 10160000, NULL, '_scheduling_delivery/scheduling_workbench/ticket.php')
 	PRINT ' Inserted 10166600 - Ticket.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166600 - Ticket already EXISTS.'
END



