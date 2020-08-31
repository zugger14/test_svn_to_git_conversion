IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10235400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10235400, 'Run Journal Entry Report', 'Run Journal Entry Report', 10230000, 'windowRunJournalEntryReport')
 	PRINT ' Inserted 10235400 - Run Journal Entry Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10235400 - Run Journal Entry Report already EXISTS.'
END
