IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164000, 'Update Welllhead Volume', 'Update Welllhead Volume', 10160000, 'windowUpdateWellheadVolume')
 	PRINT ' Inserted 10164000 - Update Welllhead Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164000 - Update Welllhead Volume already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164010, 'Update Welllhead Volume IU', 'Update Welllhead Volume IU', 10164000, NULL)
 	PRINT ' Inserted 10164010 - Update Welllhead Volume IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164010 - Update Welllhead Volume IU already EXISTS.'
END