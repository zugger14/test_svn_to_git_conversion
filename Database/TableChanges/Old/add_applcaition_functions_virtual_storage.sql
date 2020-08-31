IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162300)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES (10162300, 'Virtual Gas Storage', 'Virtual Gas Storage', 10160000)
    PRINT '10162300 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162300 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162301)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
    VALUES (10162301,'Virtual Gas Storage IU','Virtual Gas Storage IU',10162300)
    PRINT '10162301 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162301 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162311)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
    VALUES (10162311, 'Virtual Gas Storage Delete', 'Virtual Gas Storage Delete', 10162300)
    PRINT '10162311 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162311 ALREADY EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162310)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
    VALUES (10162310, 'General Asset Information Insert', 'General Asset Information Insert', 10162300)
    PRINT '10162310 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162310 ALREADY EXISTS.'
END
