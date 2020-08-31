IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171410)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171410, 'Update Deal Status and Confirmation Deal History', 'Update Deal Status and Confirmation Deal History', 10171400, 'windowDealConfirmStatus')
 	PRINT ' Inserted 10171410 - Update Deal Status and Confirmation Deal History.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171410 - Update Deal Status and Confirmation Deal History already EXISTS.'
END



IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171411)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171411, 'Update Deal Status and Confirmation Deal History IU', 'Update Deal Status and Confirmation Deal History IU', 10171400, 'windowDealConfirmStatusIU')
 	PRINT ' Inserted 10171411 - Update Deal Status and Confirmation Deal History IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171411 - Update Deal Status and Confirmation Deal History IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171412)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171412, 'Update Deal Status and Confirmation Update Status', 'Update Deal Status and Confirmation Update Status', 10171400, 'windowDealConfirmStatusIU')
 	PRINT ' Inserted 10171412 - Update Deal Status and Confirmation Update Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171412 - Update Deal Status and Confirmation Update Status already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171413)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171413, 'Update Deal Status and Confirmation General Confirmation', 'Update Deal Status and Confirmation General Confirmation', 10171400, 'windowConfirmGenerate')
 	PRINT ' Inserted 10171413 - Update Deal Status and Confirmation General Confirmation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171413 - Update Deal Status and Confirmation General Confirmation already EXISTS.'
END

