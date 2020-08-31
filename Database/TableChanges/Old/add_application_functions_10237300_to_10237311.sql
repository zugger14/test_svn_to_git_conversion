IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237300, 'View/Update Cum PNL Series', 'View/Update Cum PNL Series', 10230000, 'windowViewUpdateCumPNLSeries')
 	PRINT ' Inserted 10237300 - View/Update Cum PNL Series.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237300 - View/Update Cum PNL Series already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237310, 'View/Update Cum PNL Series IU', 'View/Update Cum PNL Series IU', 10237300, 'windowViewUpdateCumPNLSeriesIU')
 	PRINT ' Inserted 10237310 - View/Update Cum PNL Series IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237310 - View/Update Cum PNL Series IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237311)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237311, 'Delete Cum PNL Series', 'Delete Cum PNL Series', 10237300, NULL)
 	PRINT ' Inserted 10237311 - Delete Cum PNL Series.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237311 - Delete Cum PNL Series already EXISTS.'
END
