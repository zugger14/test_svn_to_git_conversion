DELETE afu 
FROM application_functional_users afu 
	INNER JOIN application_functions af 
		ON afu.function_id = af.function_id 
WHERE function_name IN ('Update Deal Volume', 'Update Schedule Volume', 'Update Actual Volume')

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_name = 'Update Deal Volume')
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131031, 'Update Deal Volume', 'Update Deal Volume', 10131018, NULL)
 	PRINT ' Inserted 10131031 - Update Deal Volume.'
END
ELSE
BEGIN
	UPDATE application_functions 
	SET function_id = 10131031 
	WHERE function_name = 'Update Deal Volume' 
END	

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_name = 'Update Schedule Volume')
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131032, 'Update Schedule Volume', 'Update Schedule Volume', 10131018, NULL)
 	PRINT ' Inserted 10131032 - Update Schedule Volume.'
END
ELSE
BEGIN
UPDATE application_functions 
SET function_id = 10131032 
WHERE function_name = 'Update Schedule Volume' 
END	

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_name = 'Update Actual Volume')
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131033, 'Update Actual Volume', 'Update Actual Volume', 10131018, NULL)
 	PRINT ' Inserted 10131033 - Update Actual Volume.'
END
ELSE
BEGIN
	UPDATE application_functions 
	SET function_id = 10131033
	WHERE function_name = 'Update Actual Volume' 
END	