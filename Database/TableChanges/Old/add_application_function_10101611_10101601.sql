IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101611)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10101611, 'Run Scheduled Job', 'Run Scheduled Job', 10101600)
    PRINT '10101611 INSERTED.'
END
ELSE
BEGIN
    PRINT '10101611 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101601)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10101601, 'Update Scheduled Job', 'Update Scheduled Job', 10101600)
    PRINT '10101601 INSERTED.'
END
ELSE
BEGIN
    PRINT '10101601 ALREADY EXISTS.'
END

