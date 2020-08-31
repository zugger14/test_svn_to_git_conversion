IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10183600, 'Maintain Scenario Group', 'Maintain Scenario Group', 10180000, 'windowManitainScenarioGroup')
 	PRINT ' Inserted 10183600 - Maintain Scenario Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183600 - Maintain Scenario Group already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10183610, 'Maintain Scenario Group IU', 'Maintain Scenario Group IU', 10183600, 'windowMaintainScenarioIU')
 	PRINT ' Inserted 10183610 - Maintain Scenario Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183610 - Maintain Scenario Group IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183611)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10183611, 'Maintain Scenario Group Delete', 'Maintain Scenario Group Delete', 10183600, NULL)
 	PRINT ' Inserted 10183611 - Maintain Scenario Group Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183611 - Maintain Scenario Group Delete already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183415)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10183415, 'Maintain Whatif Criteria Scenario Detail', 'Maintain Whatif Criteria Scenario Detail', 10183400, 'windowMaintainWhatIfCriteriaScenarioIU')
 	PRINT ' Inserted 10183415 - Maintain Whatif Criteria Scenario Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183415 - Maintain Whatif Criteria Scenario Detail already EXISTS.'
END
