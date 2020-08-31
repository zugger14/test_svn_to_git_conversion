IF NOT EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10162600)
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
			function_parameter,
			module_type,
			book_required
		)
		VALUES
		(
			10162600,
			'Pipeline Imbalance Report',
			'Pipeline Imbalance Report',
			10202200,
			NULL,
			NULL,
			'windowImbalance',
			NULL,
			NULL,
			1
		)
	
		PRINT 'Pipeline Imbalance Report function id created successfully.'
	END
ELSE
	BEGIN
		PRINT 'Pipeline Imbalance Report function id already exists.'
	END