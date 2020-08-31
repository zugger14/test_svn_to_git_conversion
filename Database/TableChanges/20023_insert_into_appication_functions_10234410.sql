IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234410)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234410, 'Run', 'Match Transaction Automate Matching of Hedges', 10234400, NULL)
 	PRINT ' Inserted 10234410 - Match Transaction Automate Matching of Hedges.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234410 - Match Transaction Automate Matching of Hedges already EXISTS.'
END