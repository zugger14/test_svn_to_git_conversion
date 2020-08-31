IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10141900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10141900, 'Load Forecast Report', 'Load Forecast Report', 10202200, 'windowRunLoadForecastReport', 'NULL')
 	PRINT ' Inserted 10141900 - Load Forecast Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10141900 - Load Forecast Report already EXISTS.'
END
