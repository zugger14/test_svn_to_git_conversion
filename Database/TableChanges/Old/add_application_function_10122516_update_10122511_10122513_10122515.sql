IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122516)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122516, 'Maintain Alerts Run', 'Maintain Alerts Run', 10122500, '')
 	PRINT ' Inserted 10122516 - Maintain Alerts Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122516 - Maintain Alerts Run already EXISTS.'
END

UPDATE application_functions 
	 SET function_name = 'Maintain Alerts Delete',
		function_desc = 'Maintain Alerts Delete',
		func_ref_id = 10122500,
		function_call = ''
WHERE [function_id] = 10122511
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Maintain Alerts Module Event Mapping Delete',
		function_desc = 'Maintain Alerts Module Event Mapping Delete',
		func_ref_id = 10122500,
		function_call = ''
WHERE [function_id] = 10122513
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Maintain Alerts Event Mapping Delete',
		function_desc = 'Maintain Alerts Event Mapping Delete',
		func_ref_id = 10122500,
		function_call = ''
WHERE [function_id] = 10122515
PRINT 'Updated Application Function '

