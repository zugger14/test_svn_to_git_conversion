IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131025)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path, file_path, book_required)
	VALUES (10131025, 'Generate Confirmation', 'Generate Confirmation', '10131000', NULL, NULL, '_deal_capture\maintain_deals\generate.confirmation.php', 1)
	PRINT 'INSERTED 10131025 - Generate Confirmation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131025 - Generate Confirmation already EXISTS.'
END