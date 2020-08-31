IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104800)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104800, 'Data Import/Export  ', 'Data Import/Export  ', NULL, NULL )
	PRINT 'INSERTED 10104800 - Data Import/Export  .'
END
ELSE
BEGIN
	UPDATE application_functions SET function_name = 'Data Import/Export  ' WHERE function_id = 10104800
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104810)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104810, 'Add/Save', 'Add/Save', NULL, NULL )
	PRINT 'INSERTED 10104810 - Add/Save.'
END
ELSE
BEGIN
	UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10104810
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104811)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104811, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10104811 - Delete.'
END
ELSE
BEGIN
	UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10104811
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104812)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104812, 'Run', 'Run', NULL, NULL )
	PRINT 'INSERTED 10104812 - Run.'
END
ELSE
BEGIN
	UPDATE application_functions SET function_name = 'Run' WHERE function_id = 10104812
END