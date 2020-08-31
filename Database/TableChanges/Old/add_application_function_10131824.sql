IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131824)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131824, 'Import from Source System - ICE Deal Data Import', 'ICE Deal Data Import', 10131701, NULL)
 	PRINT ' Inserted 10131824 - Import from Source System - ICE Deal Data Import.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131824 - Import from Source System - ICE Deal Data Import already EXISTS.'
END


