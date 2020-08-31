IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10105000, 'Setup Menu', 'Setup Menu', 10100000, NULL)
 	PRINT ' Inserted 10105000 - Setup Menu.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105000 - Setup Menu already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105010)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10105010, 'Setup Menu IU', 'Setup Menu IU', 10105000, 'windowSetupMenuIU')
 	PRINT ' Inserted 10105010 - Setup Menu IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105010 - Setup Menu IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105011)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10105011, 'Setup Menu Delete', 'Setup Menu Delete', 10105000, 'windowSetupMenuDel')
 	PRINT ' Inserted 10105011 - Setup Menu Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105011 - Setup Menu Delete already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105012)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10105012, 'Setup Menu Hide', 'Setup Menu Hide', 10105000, 'windowSetupMenuHide')
 	PRINT ' Inserted 10105012 - Setup Menu Hide.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105012 - Setup Menu Hide already EXISTS.'
END
