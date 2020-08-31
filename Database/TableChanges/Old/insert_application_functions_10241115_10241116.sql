IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241115)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10241115, 'Write Off Apply Cash', 'Write Off Apply Cash', 10241100)
    PRINT '10241115 INSERTED.'
END
ELSE
BEGIN
    PRINT '10241115 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241116)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10241116, 'Update Apply Cash', 'Update Apply Cash', 10241100)
    PRINT '10241116 INSERTED.'
END
ELSE
BEGIN
    PRINT '10241116 ALREADY EXISTS.'
END