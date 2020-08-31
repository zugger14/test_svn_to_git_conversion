IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171510, 'Update Deal Status Deal History', 'Update Deal Status Deal History', 10171500, 'windowDealConfirmStatus')
 	PRINT ' Inserted 10171510 - Update Deal Status Deal History.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171510 - Update Deal Status Deal History already EXISTS.'
END



IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171511, 'Update Deal Status Deal History IU', 'Update Deal Status Deal History IU', 10171500, 'windowDealConfirmStatusIU')
 	PRINT ' Inserted 10171511 - Update Deal Status Deal History IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171511 - Update Deal Status Deal History IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171512)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171512, 'Update Deal Status Update Status', 'Update Deal Status Update Status', 10171500, 'windowDealConfirmStatusIU')
 	PRINT ' Inserted 10171512 - Update Deal Status Update Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171512 - Update Deal Status Update Status already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171513)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171513, 'Update Deal Status General Confirmation', 'Update Deal Status General Confirmation', 10171500, 'windowConfirmGenerate')
 	PRINT ' Inserted 10171513 - Update Deal Status General Confirmation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171513 - Update Deal Status General Confirmation already EXISTS.'
END
