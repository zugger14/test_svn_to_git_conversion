--ADD FUNCTION IDS FOR EDI PROCESS RIGHTS.
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164301)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164301, 'EDI File Create/Add', 'Right to create and upload EDI Files.', 10164300, '')
 	PRINT ' Inserted 10164301 - EDI File Create/Add.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164301 - EDI File Create/Add already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164302)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164302, 'EDI File Delete', 'Right to delete EDI Files.', 10164300, '')
 	PRINT ' Inserted 10164302 - EDI File Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164302 - EDI File Delete already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164303)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164303, 'EDI File Submit', 'Right to submit EDI Files.', 10164300, '')
 	PRINT ' Inserted 10164303 - EDI File Submit.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164303 - EDI File Submit already EXISTS.'
END
