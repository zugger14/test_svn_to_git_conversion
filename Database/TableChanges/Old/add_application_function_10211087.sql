IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211087)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211087, 'AveragePrice', 'AveragePrice', 10211017, 'windowAveragePrice')
 	PRINT ' Inserted 10211087 - AveragePrice.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211087 - AveragePrice already EXISTS.'
END
GO