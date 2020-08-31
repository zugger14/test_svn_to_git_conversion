IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233900, 'Hedging Relationship Report', 'Hedging Relationship Report', 10230000, 'windowRunHedgeRelationshipReport')
 	PRINT ' Inserted 10233900 - Hedging Relationship Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233900 - Hedging Relationship Report already EXISTS.'
END