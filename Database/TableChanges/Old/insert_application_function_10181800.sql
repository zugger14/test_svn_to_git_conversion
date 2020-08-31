IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10181800, 'Run Implied Volatility Calculation', 'Run Implied Volatility Calculation', 10180000, 'windowCalImpVolatility', '_valuation_risk_analysis/run_implied_volatility_calculation/run.implied.volatility.calculation.php')
 	PRINT ' Inserted 10181800 - Run Implied Volatility Calculation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181800 - Run Implied Volatility Calculation already EXISTS.'
END