IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142321)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142321, 'Exclude ST dates IU', 'Exclude ST dates IU', 10142320, 'windowExcludeSTDates')
 	PRINT ' Inserted 10142321 - Exclude ST dates IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142321 - Exclude ST dates IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142322)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142322, 'Exclude ST dates Del', 'Exclude ST dates Del', 10142320, 'windowExcludeSTDates')
 	PRINT ' Inserted 10142322 - Exclude ST dates Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142322 - Exclude ST dates Del already EXISTS.'
END
