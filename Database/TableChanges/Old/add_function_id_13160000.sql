IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13160000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13160000, 'Hedging Relationship Audit Report', 'Hedging Relationship Audit Report', 10230000, NULL)
 	PRINT ' Inserted 13160000 - Hedging Relationship Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13160000 - Hedging Relationship Audit Report already EXISTS.'
END