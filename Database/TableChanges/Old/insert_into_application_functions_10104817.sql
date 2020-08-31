IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104817)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104817, 'Data Import\Export Relation Details', 'Data Import\Export Relation Details', 10104800, '')
 	PRINT ' Inserted 10104817 - Data Import\Export Relation Details.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104817 - Data Import\Export Relation Details already EXISTS.'
END