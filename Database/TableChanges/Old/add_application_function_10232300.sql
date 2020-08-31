IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10232300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10232300, 'Run Assessment', 'Run Assessment', 10230000, 'windowRunAssessment', '_accounting/derivative/transaction_processing/des_of_a_hedge/des.of.a.hedge.php?type=hedge_affectiveness_assessment')
 	PRINT ' Inserted 10232300 - Run Assessment.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10232300 - Run Assessment already EXISTS.'
END
