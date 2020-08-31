IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10181400, 'Calculate Volatility, Correlation and Expected Return', 'Calculate Volatility, Correlation and Expected Return', 10180000, '_valuation_risk_analysis/calculate_volatility_correlation/calculate.volatility.correlation.php')
 	PRINT ' Inserted 10181400 - Calculate Volatility, Correlation and Expected Return.'
END
ELSE
BEGIN
	UPDATE application_functions SET file_path = '_valuation_risk_analysis/calculate_volatility_correlation/calculate.volatility.correlation.php'
	WHERE function_id = 10181400
	PRINT 'Application FunctionID 10181400 - Calculate Volatility, Correlation and Expected Return already exists.'
END
