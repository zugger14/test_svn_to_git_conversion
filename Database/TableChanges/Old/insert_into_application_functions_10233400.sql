IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10233400, 'Run Measurement', 'Run Measurement', 10233499, 'windowRunMeasurement', '_valuation_risk_analysis/run_measurement/run.measurement.php')
 	PRINT ' Inserted 10233400 - Run Measurement.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233400 - Run Measurement already EXISTS.'
END