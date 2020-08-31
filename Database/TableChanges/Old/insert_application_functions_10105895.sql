IF NOT EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105895 AND af.function_name = 'Meter')
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, book_required)
	SELECT 10105895, 'Meter', 'Meter', 10105800, 0 UNION ALL
	SELECT 10105896, 'Add/Save', 'Add/Save', 10105895, 0 UNION ALL
	SELECT 10105897, 'Delete', 'Delete', 10105895, 0
	
	PRINT 'Application Function ''Meter'' inserted successfully.'
END
ELSE 
	BEGIN
		PRINT 'Application Function ''Meter'' already exist.'
	END