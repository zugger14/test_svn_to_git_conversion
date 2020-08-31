/*Added by Poojan Shrestha, 07 Mar 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102800)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102800,'Setup Profile','Setup Profile',10100000,'windowSetupProfile')
	PRINT '10102800 INSERTED'
END

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102810)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102810,'Setup Profile IU','Setup Profile IU',10102800,'windowSetupProfileIU')
	PRINT '10102810 INSERTED'
END