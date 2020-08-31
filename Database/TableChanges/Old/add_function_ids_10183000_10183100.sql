IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183000, 'Define Monte Carlo Model Parameters', 'Define Monte Carlo Model Parameters', 10180000, 'windowMonteCarloModelParameter')
 	PRINT ' Inserted 10183000 - Define Monte Carlo Model Parameters.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183000 - Define Monte Carlo Model Parameters already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183100)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183100, 'Run Monte Carlo Simulation', 'Run Monte Carlo Simulation', 10180000, 'windowRunMonteCarloSimulation')
 	PRINT ' Inserted 10183100 - Run Monte Carlo Simulation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183100 - Run Monte Carlo Simulation already EXISTS.'
END
