IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211210, 'Maintain Contract IU', 'Maintain Contract IU', 10211200, 'windowMaintainContractIU')
 	PRINT ' Inserted 10211210 - Maintain Contract IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211210 - Maintain Contract IU already EXISTS.'
END
