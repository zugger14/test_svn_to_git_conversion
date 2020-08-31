IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201500)
BEGIN
    INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
    VALUES (10201500, 'View SSRS Reports', 'Listing of External Links of SSRS Reports', 10200000, 'windowRunSSRSReportLisiting')
    PRINT '10201500 INSERTED.'
END
ELSE
BEGIN
    PRINT '10201500 ALREADY EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201600)
BEGIN
    INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
    VALUES (10201600, 'Write SSRS Reports', 'Management of SSRS Reports', 10200000, 'windowRunSSRSReportWriter')
    PRINT '10201600 INSERTED.'
END
ELSE
BEGIN
    PRINT '10201600 ALREADY EXISTS.'
END