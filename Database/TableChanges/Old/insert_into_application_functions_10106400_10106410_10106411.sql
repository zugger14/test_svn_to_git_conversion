IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106400, 'Template Field Mapping', 'Template Field Mapping', 10100000, 'windowTemplateFieldMapping')
 	PRINT ' Inserted 10106400 - Template Field Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106400 - Template Field Mapping already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106410)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106410, 'Template Field Mapping IU', 'Template Field Mapping IU', 10106400, NULL)
 	PRINT ' Inserted 10106410 - Template Field Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106410 - Template Field Mapping IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106411)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106411, 'Delete Template Field Mapping', 'Delete Template Field Mapping', 10106400, NULL)
 	PRINT ' Inserted 10106411 - Delete Template Field Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106411 - Delete Template Field Mapping already EXISTS.'
END
