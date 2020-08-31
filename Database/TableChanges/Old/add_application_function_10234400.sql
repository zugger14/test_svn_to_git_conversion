IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10234400, 'Automate Matching of Hedges', 'Automate Matching of Hedges', 12192099, 'windowAutomationMathingHedge', '_accounting/derivative/transaction_processing/auto_matching_hedge/auto.matching.hedge.php')
 	PRINT ' Inserted 10234400 - Automate Matching of Hedges.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234400 - Automate Matching of Hedges already EXISTS.'
END
