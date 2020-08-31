IF EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 10183410)
	PRINT 'Add/Save'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10183410,'Add/Save','Setup What if Criteria IU',10183400, NULL);
END

IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10183411)
	PRINT 'Delete'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10183411,'Delete','Delete Setup What if Criteria',10183400, NULL);
END

IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10183412)
	PRINT 'Run'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10183412,'Run','Run Setup What if Criteria',10183400, NULL);
END