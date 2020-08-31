IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106100)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106100, 'Setup Time Series', 'Setup Time Series', 10100000, NULL, NULL, '_setup/setup_time_series/setup.time.series.php', 0)
	PRINT 'INSERTED 10106100 - Setup Time Series.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106100 - Setup Time Series already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106110, 'Time Series IU', 'Time Series IU', 10106100, '', NULL, '', 0)
 	PRINT ' Inserted 10106110 - Time Series IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106110 - Time Series IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106111, 'Time Series Delete', 'Time Series Delete', 10106100, '', NULL, '', 0)
 	PRINT ' Inserted 10106111 - Time Series Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106111 - Time Series Delete already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106112)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106112, 'Series Values IU', 'Series Values IU', 10106100, '', NULL, '', 0)
 	PRINT ' Inserted 10106112 - Series Values IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106112 - Series Values IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106113)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10106113, 'Series Values Delete', 'Series Values Delete', 10106100, '', NULL, '', 0)
 	PRINT ' Inserted 10106113 - Series Values Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106113 - Series Values Delete already EXISTS.'
END
