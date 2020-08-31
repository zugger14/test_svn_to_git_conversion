IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104600, 'Maintain Settlement Netting Group', 'Maintain Settlement Netting Group', 10100000, 'windowMaintainNettingGrp')
 	PRINT ' Inserted 10104600 - Maintain Settlement Netting Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104600 - Maintain Settlement Netting Group already EXISTS.'
END
