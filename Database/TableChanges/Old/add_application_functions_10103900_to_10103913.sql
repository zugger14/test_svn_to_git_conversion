IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103900)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103900, 'Setup Deal Status and Confirmation Rule', 'Setup Deal Status and Confirmation Rule', 10100000, 'windowSetupDealStatusConfirmationRule')
 	PRINT ' Inserted 10103900 - Setup Deal Status and Confirmation Rule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103900 - Setup Deal Status and Confirmation Rule already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103910)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103910, 'Setup Deal Status and Confirmation Rule IU', 'Setup Deal Status and Confirmation Rule IU', 10103900, 'windowStatusRuleHeader')
 	PRINT ' Inserted 10103910 - Setup Deal Status and Confirmation Rule IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103910 - Setup Deal Status and Confirmation Rule IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103911)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103911, 'Delete Setup Deal Status and Confirmation Rule', 'Delete Setup Deal Status and Confirmation Rule', 10103900, NULL)
 	PRINT ' Inserted 10103911 - Delete Setup Deal Status and Confirmation Rule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103911 - Delete Setup Deal Status and Confirmation Rule already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103912)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103912, 'Setup Deal Status and Confirmation Rule Detail', 'Setup Deal Status and Confirmation Rule Detai', 10103910, 'windowStatusRuleDetail')
 	PRINT ' Inserted 10103912 - Setup Deal Status and Confirmation Rule Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103912 - Setup Deal Status and Confirmation Rule Detail already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103913)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103913, 'Delete Setup Deal Status and Confirmation Rule Detail', 'Delete Setup Deal Status and Confirmation Rule Detail', 10103910, NULL)
 	PRINT ' Inserted 10103913 - Delete Setup Deal Status and Confirmation Rule Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103913 - Delete Setup Deal Status and Confirmation Rule Detail already EXISTS.'
END
