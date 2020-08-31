IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237000, 'Maintain Manual Journal Entries', 'Maintain Manual Journal Entries', 10230000, 'windowMaintainManualJournalEntries')
 	PRINT ' Inserted 10237000 - Maintain Manual Journal Entries.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237000 - Maintain Manual Journal Entries already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237010, 'Maintain Manual Journal Entries IU', 'Maintain Manual Journal Entries IU', 10237000, NULL)
 	PRINT ' Inserted 10237010 - Maintain Manual Journal Entries IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237010 - Maintain Manual Journal Entries IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237012)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237012, 'Maintain Manual Journal Entries Detail', 'Maintain Manual Journal Entries Detail', 10237000, NULL)
 	PRINT ' Inserted 10237012 - Maintain Manual Journal Entries Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237012 - Maintain Manual Journal Entries Detail already EXISTS.'
END
