IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104000, 'Define Deal Status Privilege', 'Define Deal Status Privilege', 10100000, 'windowMaintainDefinationInternal_desk')
 	PRINT ' Inserted 10104000 - Define Deal Status Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104000 - Define Deal Status Privilege already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104010)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104010, 'Define Deal Status Privilege Detail', 'Define Deal Status Privilege Detail', 10104000, 'windowMaintainDefinationInternal_portfolio')
 	PRINT ' Inserted 10104010 - Define Deal Status Privilege Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104010 - Define Deal Status Privilege Detail already EXISTS.'
END
