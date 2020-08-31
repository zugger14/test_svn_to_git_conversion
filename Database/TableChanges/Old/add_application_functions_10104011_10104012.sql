IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104011)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104011, 'Deal Status Privilege Mapping IU', 'Deal Status Privilege Mapping IU', 10104000, 'windowDealStatusPrivilegeMapping')
 	PRINT ' Inserted 10104011 - Deal Status Privilege Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104011 - Deal Status Privilege Mapping IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104012)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104012, 'Delete Deal Status Privilege Mapping', 'Delete Deal Status Privilege Mapping', 10104000, '')
 	PRINT ' Inserted 10104012 - Delete Deal Status Privilege Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104012 - Delete Deal Status Privilege Mapping already EXISTS.'
END