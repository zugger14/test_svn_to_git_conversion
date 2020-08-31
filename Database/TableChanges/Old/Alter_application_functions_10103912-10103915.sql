IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103914)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103914, 'Setup Deal Status and Confirmation workflow activities', 'Setup Deal Status and Confirmation workflow activities', 10103900, 'windowStatusWorkflow')
 	PRINT ' Inserted 10103914 - Setup Deal Status and Confirmation workflow activities.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103914 - Setup Deal Status and Confirmation workflow activities already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103915)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103915, 'Delete Deal Status and Confirmation workflow activities', 'Delete Deal Status and Confirmation workflow activities', 10103900, NULL)
 	PRINT ' Inserted 10103915 - Delete Deal Status and Confirmation workflow activities.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103915 - Delete Deal Status and Confirmation workflow activities already EXISTS.'
END


UPDATE application_functions 
	 SET function_name = 'Setup Deal Status and Confirmation Rule Detail',
		function_desc = 'Setup Deal Status and Confirmation Rule Detai',
		func_ref_id = 10103900,
		function_call = 'windowStatusRuleDetail'
		 WHERE [function_id] = 10103912
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Delete Setup Deal Status and Confirmation Rule Detail',
		function_desc = 'Delete Setup Deal Status and Confirmation Rule Detail',
		func_ref_id = 10103900,
		function_call = NULL
		 WHERE [function_id] = 10103913
PRINT 'Updated Application Function '


DELETE FROM application_functional_users WHERE function_id = 10103901
DELETE FROM application_functions WHERE function_id = 10103901