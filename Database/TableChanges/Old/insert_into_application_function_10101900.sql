IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101900)
	BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10101900, 'Setup Logical Trade Lock', 'Setup Logical Trade Lock', 10100000, NULL, NULL, '_setup/setup_logical_trade_lock/setup.logical.trade.lock.php', 0)
	PRINT 'INSERTED 10101900.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101900 already EXISTS.'
END


