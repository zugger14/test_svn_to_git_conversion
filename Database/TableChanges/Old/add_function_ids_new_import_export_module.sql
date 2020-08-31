IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104800, 'Data Import/Export', 'Data Import/Export', 10100000, 'windowDataImportExport')
 	PRINT ' Inserted 10104800 - Data Import/Export.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104800 - Data Import/Export already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104810)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104810, 'Data Import\Export UI', 'Data Import\Export IU', 10104800, 'windowDataImportExportIU')
 	PRINT ' Inserted 10104810 - Data Import\Export UI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104810 - Data Import\Export UI already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104811)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104811, 'Data Import\Export Del', 'Data Import\Exportr Del', 10104800, '')
 	PRINT ' Inserted 10104811 - Data Import\Export Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104811 - Data Import\Export Del already EXISTS.'
END
