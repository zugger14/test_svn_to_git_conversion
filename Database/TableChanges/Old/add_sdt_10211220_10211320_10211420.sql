--select * from application_functions where func_ref_id =10211200
--select * from application_functions where func_ref_id =10211300
--select * from application_functions where func_ref_id =10211400

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211220)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10211220, 'Maintain Privilege', 'Maintain Privilege', '10211200', NULL, NULL, NULL, 0)
	PRINT 'INSERTED 10211220 -Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211220 - Privilege already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211320)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10211320, 'Maintain Privilege', 'Maintain Privilege', '10211300', NULL, NULL, NULL, 0)
	PRINT 'INSERTED 10211320 -Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211320 - Privilege already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211420)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10211420, 'Maintain Privilege', 'Maintain Privilege', '10211400', NULL, NULL, NULL, 0)
	PRINT 'INSERTED 10211420 -Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211420 - Privilege already EXISTS.'
END
GO

