IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10236600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10236600, 'Tagging Audit Report', 'Tagging Audit Report', 10230000, 'windowRunTaggingAuditReport')
 	PRINT ' Inserted 10236600 - Tagging Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10236600 - Tagging Audit Report already EXISTS.'
END
