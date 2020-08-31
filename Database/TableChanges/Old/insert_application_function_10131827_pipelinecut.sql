IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131827)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131827, 'Import from Source System - Pipeline Cut', 'Pipeline Cut Import', 10131701, NULL)
 	PRINT ' Inserted 10131827 - Import from Source System - Pipeline Cut.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131827 - Import from Source System - Pipeline Cut already EXISTS.'
END
