UPDATE application_functions
SET function_name = 'Add/Save',
	function_desc = 'Add/Save'
WHERE function_id = 10106110

UPDATE application_functions
SET function_name = 'Delete',
	function_desc = 'Delete'
WHERE function_id = 10106111

DELETE FROM application_functional_users WHERE function_id = 10106113
DELETE FROM application_functions WHERE function_id = 10106113

/*
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106115)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106115, 'Series Values', 'Series Values', 10106100, '', NULL, '', 0)
 	PRINT ' Inserted 10106115 - Series Value'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106115 - Series Value  already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106116)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106116, 'Add/Save', 'Add/Save', 10106115, '', NULL, '', 0)
 	PRINT ' Inserted 10106116 - Add/Save'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106116 - Add/Save  already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106117)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106117, 'Delete', 'Delete', 10106115, '', NULL, '', 0)
 	PRINT ' Inserted 10106213 - Delete'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106117 - Delete  already EXISTS.'
END
*/