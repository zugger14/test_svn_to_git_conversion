IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10102512)
	PRINT 'Manage Privilege'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10102512,'Manage Privilege','Manage Privilege Setup Location',10102500, NULL);
END

IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10102612)
	PRINT 'Manage Privilege'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10102612,'Manage Privilege','Manage Privilege Setup Price Curve',10102600, NULL);
END

IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10105812)
	PRINT 'Manage Privilege'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10105812,'Manage Privilege','Manage Privilege Setup Counterparty',10105800, NULL);
END


