IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121010, 'Maintain Group 1(Process) IU', 'Maintain Group 1(Process) IU', 10121000, 'windowMaintainComplianceProcessIU')
 	PRINT ' Inserted 10121010 - Maintain Group 1(Process) IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121010 - Maintain Group 1(Process) IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121011, 'Delete Group 1(Process)', 'Delete Group 1(Process)', 10121000, NULL)
 	PRINT ' Inserted 10121011 -Delete Group 1(Process).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121011 -Delete Group 1(Process) already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121012)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121012, 'Maintain Group 2 (Risks) IU', 'Maintain Group 2 (Risks) IU', 10121000, 'windowMaintainComplianceRisksIU')
 	PRINT ' Inserted 10121012 - Maintain Group 2 (Risks) IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121012 - Maintain Group 2 (Risks) IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121013)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121013, 'Delete Group 2 (Risks)', 'Delete Group 2 (Risks)', 10121000, NULL)
 	PRINT ' Inserted 10121013 - Delete Group 2 (Risks).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121013 - Delete Group 2 (Risks) already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10121014)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10121014, 'Maintain Compliance Activity', 'Maintain Compliance Activity', 10121000, 'compActDetail')
 	PRINT ' Inserted 10121014 - Maintain Compliance Activity.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121014 - Maintain Compliance Activity already EXISTS.'
END
