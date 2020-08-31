IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10107000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10107000, 'Setup As of Date', 'Setup As of Date', 10107000, NULL)
 	PRINT ' Inserted 10107000 - Setup As of Date.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10107000 - Setup As of Date already EXISTS.'
END

UPDATE application_functions SET file_path = '_setup/setup_as_of_date/setup.as.of.date.php' WHERE function_id = 10107000