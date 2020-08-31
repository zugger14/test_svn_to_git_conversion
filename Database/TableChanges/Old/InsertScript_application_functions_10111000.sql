IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10111000, 'Maintain Users', 'Maintain Users', 10200000, 'windowMaintainUsers', '_users_roles/maintain_users/maintain.users.php')
 	PRINT ' Inserted 10111000 - Maintain Users.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111000 - already EXISTS.'
END
