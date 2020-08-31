DELETE FROM application_functional_users WHERE function_id = 10106200
DELETE FROM application_functional_users WHERE function_id = 10106210
DELETE FROM application_functional_users WHERE function_id = 10106211
DELETE FROM application_functional_users WHERE function_id = 10106212

DELETE af1 FROM application_functions af 
INNER JOIN application_functions af1 ON af.function_id = af1.func_ref_id
WHERE af1.func_ref_id = 10106200 AND af.function_name = 'Setup Weather Data'

DELETE FROM application_functions WHERE function_id = 10106200 AND function_name = 'Setup Weather Data'


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166200)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required, function_parameter)
	VALUES (10166200, 'Setup Weather Data', 'Setup Weather Data', 10160000, NULL, NULL, '_setup/setup_weather_data/setup.weather.data.php', 0, 10166200)
	PRINT 'INSERTED 10166200 - Setup Weather Data.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET		
		file_path = '_setup/setup_weather_data/setup.weather.data.php'
	WHERE function_id = 10166200
	PRINT 'Application FunctionID 10166200 - Setup Weather Data already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166210)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166210, 'Add', 'Add', 10166200, '', NULL, '', 0)
 	PRINT ' Inserted 10166210 - Add.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166210 - Add already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166211)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166211, 'Delete', 'Delete', 10166200, '', NULL, '', 0)
 	PRINT ' Inserted 10166211 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166211 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166212)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10166212, 'Weather Value Add/Save/Delete', 'Weather Value Add/Save/Delete', 10166200, '', NULL, '', 0)
 	PRINT ' Inserted 10166212 - Weather Value Add/Save/Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166212 - Weather Value Add/Save/Delete already EXISTS.'
END

