IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234500, 'View Outstanding Automation Results', 'View Outstanding Automation Results', 10230000, 'windowViewOutstandingAutomationResults')
 	PRINT ' Inserted 10234500 - View Outstanding Automation Results.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234500 - View Outstanding Automation Results already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234510, 'Get Status View Outstanding Automation Results', 'Get Status View Outstanding Automation Results', 10234500, NULL)
 	PRINT ' Inserted 10234510 - Get Status View Outstanding Automation Results.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234510 - Get Status View Outstanding Automation Results already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234511)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234511, 'Delete View Outstanding Automation Results', 'Delete View Outstanding Automation Results', 10234500, NULL)
 	PRINT ' Inserted 10234511 - Delete View Outstanding Automation Results.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234511 - Delete View Outstanding Automation Results already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234512)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234512, 'Approve Relationships View Outstanding Automation Results', 'Approve Relationships View Outstanding Automation Results', 10234500, NULL)
 	PRINT ' Inserted 10234512 - Approve Relationships View Outstanding Automation Results.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234512 - Approve Relationships View Outstanding Automation Results already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234513)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234513, 'Update Items View Outstanding Automation Results', 'Update Items View Outstanding Automation Results', 10234500, 'windowviewoutstandautoresIU')
 	PRINT ' Inserted 10234513 - Update Items View Outstanding Automation Results.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234513 - Update Items View Outstanding Automation Results already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234514)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234514, 'Finalized Approved Transactions', 'Finalized Approved Transactions', 10234500, NULL)
 	PRINT ' Inserted 10234514 - Finalized Approved Transactions.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234514 - Finalized Approved Transactions already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234515)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234515, 'Hedge Relationship Type Detail', 'Hedge Relationship Type Detail', 10234500, 'windowSelectHedgeRelationMatch')
 	PRINT ' Inserted 10234515 - Hedge Relationship Type Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234515 - Hedge Relationship Type Detail already EXISTS.'
END

