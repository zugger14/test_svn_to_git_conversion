IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102700)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102700,'Archive Data','Archive Data',10100000,'windowSetupArchiveData')
	PRINT '10102700 INSERTED'
END