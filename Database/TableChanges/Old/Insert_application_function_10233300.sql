IF NOT EXISTS ( SELECT 1 FROM application_functions AS af WHERE af.function_id = 10233300)
BEGIN
	INSERT INTO application_functions
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id,
		requires_at,
		document_path,
		function_call,
		process_map_id,
		file_path,
		book_required
	)
	VALUES
	(
		10233300,
		'Copy Prior MTM Value',
		'Copy Prior MTM Value',
		10230000,
		NULL,
		NULL,
		'windowPriorMTM',
		NULL,
		'_accounting/derivative/ongoing_assessment/copy_piror_mtm/copy.piror.mtm.php',
		0
	)
	
	PRINT 'Function Copy Prior MTM Value inserted.'
END
ELSE 
	BEGIN
		PRINT 'Function Copy Prior MTM Value already exist.'
	END