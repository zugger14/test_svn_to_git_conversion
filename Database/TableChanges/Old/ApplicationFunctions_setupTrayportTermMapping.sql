/*Added by Pawan Adhikari, 10 May 2011*/

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10103100)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103100,'Setup Trayport Term Mapping','Setup Trayport Term Mapping',10100000,'windowSetupTrayportTermMapping')
	PRINT '10103100 INSERTED'
END
ELSE
	PRINT '10103100 Already Exists'

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10103110)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103110,'Setup Trayport Term Mapping IU','Setup Trayport Term Mapping IU',10103100,'windowSetupTrayportTermMappingIU')
	PRINT '10103110 INSERTED'
END
ELSE
	PRINT '10103110 Already Exists'

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10103111)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103111,'Delete Setup Trayport Term Mapping','Delete Setup Trayport Term Mapping',10103100,'')
	PRINT '10103111 INSERTED'
END
ELSE
	PRINT '10103111 Already Exists'
