IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102517)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102517, 'Source Minor Location Nomination Group IU', 'Source Minor Location Nomination Group IU', 10102510, '')
 	PRINT ' Inserted 10102517 - Source Minor Location Nomination Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102517 - Source Minor Location Nomination Group IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102518)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102518, 'Source Minor Location Nomination Group Delete', 'Source Minor Location Nomination Group Delete', 10102510, '')
 	PRINT ' Inserted 10102518 - Source Minor Location Nomination Group Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102518 - Source Minor Location Nomination Group Delete already EXISTS.'
END