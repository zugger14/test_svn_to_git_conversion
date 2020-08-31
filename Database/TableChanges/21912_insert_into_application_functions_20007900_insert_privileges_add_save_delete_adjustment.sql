--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007901)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20007901, 'Add/Save', 'Add or Save Privilege', 20007900, NULL, NULL, 0)
    PRINT ' Inserted 20007901 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20007901 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007902)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20007902, 'Delete', 'Delete Privilege', 20007900, NULL, NULL, 0)
    PRINT ' Inserted 20007902 - .'
END
ELSE
BEGIN
	IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007902 AND function_name = 'Delete Match')
	BEGIN
		--Update application_functions
		UPDATE application_functions
		SET function_name = 'Delete Match',
			function_desc = 'Delete Match Privilege'
			WHERE [function_id] = 20007902
		PRINT 'Updated .'
	END
    PRINT 'Application FunctionID 20007902 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007903)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20007903, 'Auto Adjustment', 'Auto Adjustment Privilege', 20007900, NULL, NULL, 0)
    PRINT ' Inserted 20007903 - .'
END
ELSE
BEGIN
	IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_name = 'Auto Adjustment' AND function_id = 20007903)
	BEGIN
		UPDATE application_functions
		SET function_name = 'Auto Adjustment'
		WHERE function_id = 20007903
	END
    PRINT 'Application FunctionID 20007903 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20007904)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20007904, 'Manual Adjustment', 'Manual Adjustment Privilege', 20007900, NULL, NULL, 0)
    PRINT ' Inserted 20007904 - .'
END
ELSE
BEGIN
	IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_name = 'Manual Adjustment' AND function_id = 20007904)
	BEGIN
		UPDATE application_functions 
		SET function_name = 'Manual Adjustment'
		WHERE function_id = 20007904
	END
    PRINT 'Application FunctionID 20007904 -  already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 20007905)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, document_path, file_path, book_required)
    VALUES (20007905, 'Delete Match Deal', 'Delete Deals From Matched Deals', 20007900, NULL, NULL, 0)
    PRINT ' Inserted 20007905 - .'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 20007905 -  already EXISTS.'
END