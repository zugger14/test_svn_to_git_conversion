--Update Deal Status and Confirmation
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171417)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171417, 'Update Deal Status and Confirmation Confirm Status', 'Update Deal Status and Confirmation Confirm Status', 10171400, 'windowConfirmStatus')
 	PRINT ' Inserted 10171417 - Update Deal Status and Confirmation Confirm Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171417 - Update Deal Status and Confirmation Confirm Status already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171418)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171418, 'Update Deal Status and Confirmation Confirmation History Detail', 'Update Deal Status and Confirmation Confirmation History Detail', 10171400, 'windowSaveConfirmationHistory')
 	PRINT ' Inserted 10171418 - Update Deal Status and Confirmation Confirmation History Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171418 - Update Deal Status and Confirmation Confirmation History Detail already EXISTS.'
END


--Update Deal Status
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171517)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171517, 'Update Deal Status Confirm Status', 'Update Deal Status General Confirmation', 10171500, 'windowConfirmStatus')
 	PRINT ' Inserted 10171517 - Update Deal Status Confirm Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171517 - Update Deal Status Confirm Status already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171518)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171518, 'Update Deal Status Confirmation History Detail', 'Update Deal Status Confirmation History Detail', 10171500, 'windowSaveConfirmationHistory')
 	PRINT ' Inserted 10171518 - Update Deal Status Confirmation History Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171518 - Update Deal Status Confirmation History Detail already EXISTS.'
END

