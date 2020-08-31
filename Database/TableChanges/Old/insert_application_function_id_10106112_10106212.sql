DELETE FROM application_functional_users WHERE function_id = 10106112
DELETE FROM application_functions WHERE function_id = 10106112

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106112)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106112, 'Series Value Add/Save/Delete', 'Series Value Add/Save/Delete', 10106100, '', NULL, '', 0)
 	PRINT ' Inserted 10106112 - Series Value Add/Save/Delete'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106112 - Series Value Add/Save/Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106212)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106212, 'Weather Value Add/Save/Delete', 'Weather Value Add/Save/Delete', 10106200, '', NULL, '', 0)
 	PRINT ' Inserted 10106212 - Weather Value Add/Save/Delete'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106212 - Weather Value Add/Save/Delete already EXISTS.'
END

