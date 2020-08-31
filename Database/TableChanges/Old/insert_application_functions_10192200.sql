IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10192200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10192200, 'Calculate Credit Value Adjustment', 'Calculate Credit Value Adjustment', 10190000, 'windowCalcCreditValueAdjustment', '_credit_risks_analysis/calculate_credit_value_adjustment/calculate.credit.value.adjustment.php')
 	PRINT ' Inserted 10192200 - Calculate Credit Value Adjustment.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10192200 - Calculate Credit Value Adjustment already EXISTS.'
END
