IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183413)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183413, 'Hypothetical', 'Hypothetical Setup What if Criteria', 10183400, '')
 	PRINT ' Inserted 10183413 - What-If Analysis - Hypothetical.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183413 - What-If Analysis - Hypothetical already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183414)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183414, 'Add/Save', 'Hypothetical Add/save', 10183413, '')
 	PRINT ' Inserted 10183414 - Hypothetical Add/save.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Update'
	WHERE function_id = 10183414
	PRINT 'Application FunctionID 10183414 - Hypothetical Add/save Updated.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183415)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183415, 'Delete', 'Hypothetical Delete', 10183413, '')
 	PRINT ' Inserted 10183415 - Hypothetical Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183415 - Hypothetical Delete already EXISTS.'
END