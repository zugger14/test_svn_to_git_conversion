IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10167000, 'Forecast Load', 'Forecast Load', 10160000, 'windowForecastLoad', '_scheduling_delivery/forecast_load/forecast.load.php')
 	PRINT ' Inserted 10167000 - Forecast Load.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167000 - Forecast Load already EXISTS.'
END