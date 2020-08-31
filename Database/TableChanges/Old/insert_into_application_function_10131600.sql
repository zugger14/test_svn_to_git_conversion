IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131600)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10131600, 'Transfer Book Position', 'Transfer Book Position', 10130000, NULL, NULL, '_deal_capture/transfer_book_position/transfer.book.position.php', 0)
	PRINT 'INSERTED 10131600.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131600 already EXISTS.'
END
