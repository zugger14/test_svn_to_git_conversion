IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101310, 'Map GL Code IU', 'Map GL Code IU', 10101300, 'windowMapGlCodesIU')
 	PRINT ' Inserted 10101310 - Map GL Code IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101310 - Map GL Code IU already EXISTS.'
END