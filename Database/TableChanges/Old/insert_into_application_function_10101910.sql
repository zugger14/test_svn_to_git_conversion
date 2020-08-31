IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101910)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101910, 'Add/Save', 'Add/Save', 10101900, 'windowAddSave')
 	PRINT ' Inserted 10101910 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101910 - Deal Add/Save already EXISTS.'
END

