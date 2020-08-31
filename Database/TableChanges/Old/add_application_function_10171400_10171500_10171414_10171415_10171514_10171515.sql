IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171400, 'Update Deal and Confirmation', 'Update Deal and Confirmation', 10170000, 'windowUpdateConfirmModule')
 	PRINT ' Inserted 10171400 - Update Deal and Confirmation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171400 - Update Deal and Confirmation already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171414)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171414, 'Lock Update & Confirm Transactions', 'Lock Update & Confirm Transactions', 10171400, NULL)
 	PRINT ' Inserted 10171414 - Lock Update & Confirm Transactions.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171414 - Lock Update & Confirm Transactions already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171415)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171415, 'UnLock Update & Confirm Transactions', 'Lock Update & Confirm Transactions', 10171400, NULL)
 	PRINT ' Inserted 10171415 - UnLock Update & Confirm Transactions.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171415 - UnLock Update & Confirm Transactions already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171500, 'Update Deal Status', 'Update Deal Status', 10170000, 'windowUpdateModule')
 	PRINT ' Inserted 10171500 - Update Deal Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171500 - Update Deal Status already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171514)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171514, 'Lock Update Deal Status', 'Lock Update Deal Status', 10171500, NULL)
 	PRINT ' Inserted 10171514 - Lock Update Deal Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171514 - Lock Update Deal Status already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171515)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10171515, 'UnLock Update Deal Status', 'UnLock Update Deal Status', 10171500, NULL)
 	PRINT ' Inserted 10171515 - UnLock Update Deal Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171515 - UnLock Update Deal Status already EXISTS.'
END


