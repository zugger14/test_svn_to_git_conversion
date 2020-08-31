IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10184000)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10184000, 'Run MTM Simulation', 'Run MTM Simulation', 10180000, NULL, NULL, '_valuation_risk_analysis/run_mtm_process/run.mtm.simulation.php', 0)
	PRINT 'INSERTED 10184000.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10184000 already EXISTS.'
END


