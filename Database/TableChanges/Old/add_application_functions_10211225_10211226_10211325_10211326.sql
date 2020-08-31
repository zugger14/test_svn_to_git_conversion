--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211225)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10211225, 'Lock', 'Lock the contract', 10211200, '', '', '', 0)
	PRINT ' Inserted 10211225 - Lock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211225 - Lock already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211226)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10211226, 'Unlock', 'Unlock', 10211200, '', '', '', 0)
	PRINT ' Inserted 10211226 - Unlock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211226 - Unlock already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211325)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10211325, 'Lock', 'Lock for non standard contract.', 10211300, '', '', '', 0)
	PRINT ' Inserted 10211325 - Lock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211325 - Lock already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211326)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10211326, 'Unlock', 'Unlock for non standard contract', 10211300, '', '', '', 0)
	PRINT ' Inserted 10211326 - Unlock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211326 - Unlock already EXISTS.'
END

                    
                    