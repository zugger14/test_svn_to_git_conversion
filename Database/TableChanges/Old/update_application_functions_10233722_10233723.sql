IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233722)
BEGIN
    INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
    VALUES (10233722, 'Manage Hedged Item dicing', 'Manage Hedged Item dicing', 10233700, 'windowDiceHedgedItem')
    PRINT '10233722 INSERTED.'
END
ELSE
BEGIN
    PRINT '10233722 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233723)
BEGIN
    INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
    VALUES (10233723, 'Delete Hedged Item dicing', 'Delete Hedged Item dicing', 10233700, 'windowDiceHedgedItem')
    PRINT '10233723 INSERTED.'
END
ELSE
BEGIN
    PRINT '10233723 ALREADY EXISTS.'
END
