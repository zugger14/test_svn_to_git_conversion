IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103410)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10103410, 'Maintain Field Group IU', 'Maintain Field Group IU', 10103300)
    PRINT '10103410 INSERTED.'
END
ELSE
BEGIN
    PRINT '10103410 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103411)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10103411, 'Delete Maintain Field Group', 'Delete Maintain Field Group', 10103300)
    PRINT '10103411 INSERTED.'
END
ELSE
BEGIN
    PRINT '10103411 ALREADY EXISTS.'
END

