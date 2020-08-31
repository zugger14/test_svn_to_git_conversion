IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201900, 'Run Data Import/Export Audit Report', 'Run Data Import/Export Audit Report', 10200000, 'windowDataImportExportAuditReport')
 	PRINT ' Inserted 10201900 - Run Data Import/Export Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201900 - Run Data Import/Export Audit Report already EXISTS.'
END