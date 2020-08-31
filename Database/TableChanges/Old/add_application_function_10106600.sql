IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106600, 'Rules Workflow', 'Rules Workflow', 10100000, 'windowRulesWorkflow')
 	PRINT ' Inserted 10106600 - Rules Workflow.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106600 - Rules Workflow already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106610, 'Add/Save', 'Rules Workflow IU', 10106600, NULL)
 	PRINT ' Inserted 10106610 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106610 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106611)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106611, 'Delete', 'Rules Workflow Delete', 10106600, NULL)
 	PRINT ' Inserted 10106611 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106611 - Delete already EXISTS.'
END