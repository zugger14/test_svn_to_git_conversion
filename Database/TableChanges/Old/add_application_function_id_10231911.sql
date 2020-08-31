IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231911)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231911, 'Copy Hedging Relationship Types', 'Copy Hedging Relationship Types', 10231900, NULL)
 	PRINT ' Inserted 10231911 - Copy Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231911 - Copy Hedging Relationship Types already EXISTS.'
END