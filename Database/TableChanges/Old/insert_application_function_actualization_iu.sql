IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166510, 'Actualize Schedules IU', 'Actualize Schedules IU', 10166500, NULL)
 	PRINT ' Inserted 10166510 - Actualize Schedules IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166510 - Actualize Schedules IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166610, 'Ticket IU', 'Ticket IU', 10166600, NULL)
 	PRINT ' Inserted 10166610 - Ticket IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166610 - Ticket IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166611)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166611, 'Ticket Delete', 'Ticket Delete', 10166600, NULL)
 	PRINT ' Inserted 10166611 - Ticket Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166611 - Ticket Delete already EXISTS.'
END

