IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163100, 'E-tag', 'E-tag', 10160000, 'windowEtagMain')
 	PRINT ' Inserted 10163100 - E-tag.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163100 - E-tag already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163110, 'E-tag Detail IU', 'E-tag Detail IU', 10163100, 'windowEtagDetailIU')
 	PRINT ' Inserted 10163110 - E-tag Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163110 - E-tag Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163111, 'E-tag Match Unmatch', 'E-tag Match Unmatch', 10163100, 'windowEtagMatchUnmatch')
 	PRINT ' Inserted 10163111 - E-tag Match Unmatch.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163111 - E-tag Match Unmatch already EXISTS.'
END