IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106710)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106710, 'Approve', 'Workflow Activity Approve', 10106700, NULL)
 	PRINT ' Inserted 10106710 - Approve.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106710 - Approve already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106711)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106711, 'Unapprove', 'Workflow Activity Unapprove', 10106700, NULL)
 	PRINT ' Inserted 10106711 - Unapprove.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106711 - Unapprove already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106712)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106712, 'Delete', 'Workflow Activity Delete', 10106700, NULL)
 	PRINT ' Inserted 10106712 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106712 - Delete already EXISTS.'
END