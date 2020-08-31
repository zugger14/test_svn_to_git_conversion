IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104500, 'Setup Deal Reference ID Prefix', 'Setup Deal Reference ID Prefix', 10100000, 'windowSetupDealReferenceIdPrefix')
 	PRINT ' Inserted 10104500 - Setup Deal Reference ID Prefix.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104500 - Setup Deal Reference ID Prefix already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104510, 'Setup Deal Reference ID Prefix IU', 'Setup Setup Deal Reference ID Prefix IU', 10104500, 'windowSetupDealReferenceIdPrefixIU')
 	PRINT ' Inserted 10104510 - Setup Deal Reference ID Prefix IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104510 - Setup Deal Reference ID Prefix IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104511, 'Setup Deal Reference ID Prefix Delete', 'Setup Deal Reference ID Prefix Delete', 10104500, NULL)
 	PRINT ' Inserted 10104511 - Setup Deal Reference ID Prefix Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104511 - Setup Deal Reference ID Prefix Delete already EXISTS.'
END