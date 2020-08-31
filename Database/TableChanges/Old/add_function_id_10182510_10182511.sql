
IF EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 10182510)
	PRINT 'Add/Save'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10182510,'Add/Save','Maintain What-If scenario IU',10182500, NULL);
END

IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10182511)
	PRINT 'Delete'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10182511,'Delete','Delete Maintain What-If scenario',10182500, NULL);
END
