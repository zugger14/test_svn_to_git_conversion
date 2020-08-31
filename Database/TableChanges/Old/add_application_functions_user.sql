IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111000)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10111000, 'Setup User', 'Setup User', 10110000, 'windowMaintainUsers', 'Administration/Users and Roles/maintain users.htm', '_users_roles/maintain_users/maintain.users.php', 1)
	PRINT 'INSERTED 10111000 - Setup User.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Setup User', 
			function_desc = 'Setup User', 
			func_ref_id = 10110000, 
			function_call = 'windowMaintainUsers', 
			document_path = 'Administration/Users and Roles/maintain users.htm', 
			file_path = '_users_roles/maintain_users/maintain.users.php', 
			book_required = 1
	WHERE function_id = 10111000

	PRINT 'UPDATED 10111000 - Setup User.'

END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111011)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111011, 'Add', 'Add', 10111000, NULL, 1 )
	PRINT 'INSERTED 10111011 - Add.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Add', 
			function_desc = 'Add', 
			func_ref_id = 10111000, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111011

	PRINT 'UPDATED 10111011 - Add.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111012)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111012, 'Save', 'Save', 10111000, NULL, 1 )
	PRINT 'INSERTED 10111012 - Save.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Save', 
			function_desc = 'Save', 
			func_ref_id = 10111000, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111012

	PRINT 'UPDATED 10111012 - Save.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111013)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111013, 'Change Password', 'Change Password', 10111000, NULL, 1)
	PRINT 'INSERTED 10111013 - Change Password.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Change Password', 
			function_desc = 'Change Password', 
			func_ref_id = 10111000, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111013

	PRINT 'UPDATED 10111013 - Change Password.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111014)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111014, 'Delete', 'Delete', 10111000, NULL, 1)
	PRINT 'INSERTED 10111014 - Delete.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Delete', 
			function_desc = 'Delete', 
			func_ref_id = 10111000, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111014

	PRINT 'UPDATED 10111014 - Delete.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111015)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111015, 'User Role', 'User Role', 10111000, NULL, 1)
	PRINT 'INSERTED 10111015 - User Role.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'User Role', 
			function_desc = 'User Role', 
			func_ref_id = 10111000, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111015

	PRINT 'UPDATED 10111015 - User Role.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111016)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111016, 'Add/Save', 'Add/Save', 10111015, NULL, 1)
	PRINT 'INSERTED 10111016 - Add/Save.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Add/Save', 
			function_desc = 'Add/Save', 
			func_ref_id = 10111015, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111016

	PRINT 'UPDATED 10111016 - Add/Save.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111017)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111017, 'Delete', 'Delete', 10111015, NULL )
	PRINT 'INSERTED 10111017 - Delete.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Delete', 
			function_desc = 'Delete', 
			func_ref_id = 10111015, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111017

	PRINT 'UPDATED 10111017 - Delete.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111030)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111030, 'User Privilege', 'User Privilege', 10111000, NULL, 1)
	PRINT 'INSERTED 10111030 - User Privilege.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'User Privilege', 
			function_desc = 'User Privilege', 
			func_ref_id = 10111000, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111030

	PRINT 'UPDATED 10111030 - User Privilege.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111031)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, book_required)
	VALUES (10111031, 'Add/Save', 'Add/Save', 10111030, NULL, 1)
	PRINT 'INSERTED 10111031 - Add/Save.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Add/Save', 
			function_desc = 'Add/Save', 
			func_ref_id = 10111030, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111031

	PRINT 'UPDATED 10111031 - Add/Save.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111032)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call,book_required)
	VALUES (10111032, 'Delete', 'Delete', 10111030, NULL, 1)
	PRINT 'INSERTED 10111032 - Delete.'
END
ELSE
BEGIN
	UPDATE application_functions
		SET function_name = 'Delete', 
			function_desc = 'Delete', 
			func_ref_id = 10111030, 
			function_call = NULL, 
			document_path = NULL, 
			file_path = NULL, 
			book_required = 1
	WHERE function_id = 10111032

	PRINT 'UPDATED 10111032 - Delete.'
END