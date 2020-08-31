IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201010, 'Report Writer IU', 'Report Writer IU', 10201000, 'windowtargetreport')
 	PRINT ' Inserted 10201010 - Report Writer IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201010 - Report Writer IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201011, 'Delete Report Writer', 'Delete Report Writer', 10201000, NULL)
 	PRINT ' Inserted 10201011 - Delete Report Writer.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201011 - Delete Report Writer already EXISTS.'
END

