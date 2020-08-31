IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201015)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201015, 'Report Writer Privileges', 'Create Report Writer Privileges for Users and Roles', 10201000, 'windowReportWriterPrivileges')
 	PRINT ' Inserted 10201015 - Report Writer Privileges.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201015 - Report Writer Privileges already EXISTS.'
END