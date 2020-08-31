IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182514)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182514, 'Maintain What-If scenario Portfolio IU', 'Maintain What-If scenario Portfolio IU', 10182510, 'windowWhatIfScenarioPortfolio')
 	PRINT ' Inserted 10182514 - Maintain What-If scenario Portfolio IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182514 - Maintain What-If scenario Portfolio IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182515)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182515, 'Delete Maintain What-If scenario Portfolio', 'Delete Maintain What-If scenario Portfolio', 10182510, NULL)
 	PRINT ' Inserted 10182515 - Delete Maintain What-If scenario Portfolio.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182515 - Delete Maintain What-If scenario Portfolio already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182516)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182516, 'Maintain What-if Scenario Other Details IU', 'Maintain What-if Scenario Other Details IU', 10182510, 'windowWhatIfScenarioOther')
 	PRINT ' Inserted 10182516 - Maintain What-if Scenario Other Details IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182516 - Maintain What-if Scenario Other Details IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182517)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182517, 'Delete Maintain What-if Scenario Other Details', 'Delete Maintain What-if Scenario Other Details', 10182510, NULL)
 	PRINT ' Inserted 10182517 - Delete Maintain What-if Scenario Other Details.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182517 - Delete Maintain What-if Scenario Other Details already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182518)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182518, 'Maintain What-if scenario builder detail IU', 'Maintain What-if scenario builder detail IU', 10182512, 'windowWhatIfScenarioDetailBuilder')
 	PRINT ' Inserted 10182518 - Maintain What-if scenario builder detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182518 - Maintain What-if scenario builder detail IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182519)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182519, 'Delete Maintain What-if scenario builder detail', 'Delete Maintain What-if scenario builder detail', 10182512, NULL)
 	PRINT ' Inserted 10182519 - Delete Maintain What-if scenario builder detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182519 - Delete Maintain What-if scenario builder detail already EXISTS.'
END