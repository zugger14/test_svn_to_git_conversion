IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182500, 'Maintain What-If scenario', 'Maintain What-If scenario', 10180000, 'windowWhatIfScenario')
 	PRINT ' Inserted 10182500 - Maintain What-If scenario.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182500 - Maintain What-If scenario already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182510, 'Maintain What-If scenario Builder', 'Maintain What-If scenario Builder', 10182500, 'windowWhatIfScenarioDetail')
 	PRINT ' Inserted 10182510 - Maintain What-If scenario Builder.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182510 - Maintain What-If scenario Builder already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182511, 'Delete Maintain What-If scenario', 'Delete Maintain What-If scenario', 10182500, NULL)
 	PRINT ' Inserted 10182511 - Delete Maintain What-If scenario.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182511 - Delete Maintain What-If scenario already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182700)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182700, 'Run What-If Scenario Report', 'Run What-If Scenario Report', 10180000, 'windowWhatIfScenarioReport')
 	PRINT ' Inserted 10182700 - Run What-If Scenario Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182700 - Run What-If Scenario Report already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182512)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182512, 'Maintain What-If scenario Builder IU', 'Maintain What-If scenario Builder IU', 10182510, NULL)
 	PRINT ' Inserted 10182512 - Maintain What-If scenario Builder IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182512 - Maintain What-If scenario Builder IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182513)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182513, 'Delete Maintain What-If scenario Builder IU', 'Delete Maintain What-If scenario Builder IU', 10182510, NULL)
 	PRINT ' Inserted 10182513 - Delete Maintain What-If scenario Builder IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182513 - Delete Maintain What-If scenario Builder IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10181213, 'VaR Measurement Criteria Detail IU', 'VaR Measurement Criteria Detail IU', 10181211, NULL)
 	PRINT ' Inserted 10181213 - VaR Measurement Criteria Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181213 - VaR Measurement Criteria Detail IU already EXISTS.'
END
