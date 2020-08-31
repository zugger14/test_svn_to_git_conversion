IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101080)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101080, 'Commodity Attribute', 'Commodity Attribute', 10101000, '')
 	PRINT ' Inserted 10101080 - Commodity Attribute.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101080 - Commodity Attribute already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101081)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101081, 'Commodity Attribute IU', 'Commodity Attribute IU', 10101080, '')
 	PRINT ' Inserted 10101081 - Commodity Attribute IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101081 - Commodity Attribute IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101082)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101082, 'Commodity Attribute Delete', 'Commodity Attribute Delete', 10101080, '')
 	PRINT ' Inserted 10101082 - Commodity Attribute Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101082 - Commodity Attribute Delete already EXISTS.'
END