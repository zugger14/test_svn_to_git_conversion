--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004700)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004700, 'Deal Match', 'Deal Match', NULL, '_deal_capture/deal_match/deal.match.php', NULL, NULL, 0)
	PRINT ' Inserted 20004700 - Deal Match.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004700 - Deal Match already EXISTS.'
END
GO

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004701)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004701, 'Add/Save', '', 20004700, '', NULL, NULL, 0)
	PRINT ' Inserted 20004701 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004701 - Add/Save already EXISTS.'
END
GO

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004702)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004702, 'Delete', '', 20004700, '', NULL, NULL, 0)
	PRINT ' Inserted 20004702 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004702 - Delete already EXISTS.'
END
GO

---Other Templates
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004703)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004703, 'Deal Match Filter1', '', 20004700, '', NULL, NULL, 0)
	PRINT ' Inserted 20004703 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004703 - Deal Match Filter1 already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20004704)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20004704, 'Deal Match Filter2', '', 20004700, '', NULL, NULL, 0)
	PRINT ' Inserted 20004704 - Deal Match Filter2.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20004704 - Deal Match Filter2 already EXISTS.'
END
GO