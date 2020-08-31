--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163610)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10163610, 'Match', 'Match', 10163600, '_scheduling_delivery/gas/flow_optimization.php', NULL, NULL, 0)
	PRINT ' Inserted 10163610 - Match.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163610 - Match already EXISTS.'
END

                    