IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183100)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call, file_path, book_required)
    VALUES (10183100, 'Run Monte Carlo Simulation', 'Run Monte Carlo Simulation', 10180000, NULL, '_valuation_risk_analysis/run_montecarlo_simulation/run.montecarlo.simulation.php', 1) 
    PRINT ' Inserted 10183100 - Run Monte Carlo Simulation.'
END
ELSE
BEGIN 
    PRINT'Application FunctionID 10183100 - Run Monte Carlo Simulation already EXISTS.'
END