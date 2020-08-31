IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10232000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10232000, 'Run Hedging Relationship Types Report', 'Run Hedging Relationship Types Report', 10230000, 'windowRunSetupHedgingRelationshipsTypesReport')
 	PRINT ' Inserted 10232000 - Run Hedging Relationship Types Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10232000 - Run Hedging Relationship Types Report already EXISTS.'
END
