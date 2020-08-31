IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10167100, 'Forecast Price', 'Forecast Price', 10160000, 'windowForecastPrice', '_scheduling_delivery/forecast_price/forecast.price.php')
 	PRINT ' Inserted 10167100 - Forecast Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167100 - Forecast Price already EXISTS.'
END
