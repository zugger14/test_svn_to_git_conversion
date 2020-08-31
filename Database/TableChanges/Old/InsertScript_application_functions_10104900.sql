-- Script to insert Application Function Id :
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10104900, 'Compose Email', 'Compose Email', 10100000, 'windowEmailSetup', '_setup/compose_email/compose.email.php')

 	PRINT 'Inserted 10104900 - Compose Email.'
END
ELSE
BEGIN
 	UPDATE application_functions SET file_path = '_setup/compose_email/compose.email.php' where function_id = 10104900;

	PRINT 'Updated 10104900 - Compose Email.'
END