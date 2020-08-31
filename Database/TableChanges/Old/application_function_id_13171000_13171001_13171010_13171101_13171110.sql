UPDATE application_functions 
	 SET function_name = 'Setup Trayport Term Mapping Staging',
		function_desc = 'Setup Trayport Term Mapping Staging',
		func_ref_id = 13170000,
		function_call = 'windowSetupTrayportTermMappingStaging'
		 WHERE [function_id] = 10103100
PRINT 'Updated Application Function '



UPDATE application_functions 
	 SET function_name = 'Pratos Mapping',
		function_desc = 'Pratos Mapping',
		func_ref_id = 13170000,
		function_call = 'windowPratosMapping'
		 WHERE [function_id] = 10103200
PRINT 'Updated Application Function '

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13170000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13170000, 'Mapping Setup', 'Mapping Setup', 10100000, NULL)
 	PRINT ' Inserted 13170000 - Mapping Setup.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13170000 - Mapping Setup already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171000, 'ST Forecast Mapping', 'ST Forecast Mapping', 13170000, NULL)
 	PRINT ' Inserted 13171000 - ST Forecast Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171000 - ST Forecast Mapping already EXISTS.'
END


UPDATE application_functions 
	 SET function_name = 'Mapping Setup',
		function_desc = 'Mapping Setup',
		func_ref_id = 10100000,
		function_call = NULL
		 WHERE [function_id] = 13170000
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'ST Forecast Mapping',
		function_desc = 'ST Forecast Mapping',
		func_ref_id = 13170000,
		function_call = 'windowSTForecastMapping'
		 WHERE [function_id] = 13171000
PRINT 'Updated Application Function '



IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171001)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171001, 'ST Forecast Mapping IU', 'ST Forecast Mapping IU', 13171000, NULL)
 	PRINT ' Inserted 13171001 - ST Forecast Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171001 - ST Forecast Mapping IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171010)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171010, 'ST Forecast Mapping Delete', 'ST Forecast Mapping Delete', 13171000, NULL)
 	PRINT ' Inserted 13171010 - ST Forecast Mapping Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171010 - ST Forecast Mapping Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171101)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171101, 'ST Forecast Allocation Mapping IU', 'ST Forecast Allocation Mapping IU', 13171000, NULL)
 	PRINT ' Inserted 13171101 - ST Forecast Allocation Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171101 - ST Forecast Allocation Mapping IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171110)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171110, 'ST Forecast Allocation Mapping Delete', 'ST Forecast Allocation Mapping Delete', 13171000, NULL)
 	PRINT ' Inserted 13171110 - ST Forecast Allocation Mapping Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171110 - ST Forecast Allocation Mapping Delete already EXISTS.'
END
