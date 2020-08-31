IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235500, 'Netted Journal Entry Report', 'Netted Journal Entry Report', 10230000, 'windowNettedJournalEntryReport')
 	PRINT ' Inserted 10235500 - Netted Journal Entry Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235500 - Netted Journal Entry Report already EXISTS.'
END
