/*Added by Poojan Shrestha, 15 Feb 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102500)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102500,'Setup Location','Setup Location',10100000,'windowSetupLocation')
	PRINT '10102500 INSERTED'
END

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102510)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102510,'Setup Location IU','Setup Location IU',10102500,'windowSetupLocationIU')
	PRINT '10102510 INSERTED'
END