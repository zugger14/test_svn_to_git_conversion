IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106700, 'Manage Approval', 'Manage Approval', 10100000, 'windowManageApproval')
 	PRINT ' Inserted 10106700 - Manage Approval.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106700 - Manage Approval already EXISTS.'
END