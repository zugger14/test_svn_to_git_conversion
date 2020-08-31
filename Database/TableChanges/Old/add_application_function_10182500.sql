IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182500, 'Maintain What-If Scenario', 'Maintain What-If Scenario', 10180000, 'windowWhatIfScenario')
 	PRINT ' Inserted 10182500 - Maintain What-If Scenario.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182500 - Maintain What-If scenario already EXISTS.'
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10182500)
	Begin
	UPDATE application_functions 					
	SET file_path = '_valuation_risk_analysis/maintain_what_if_scenario/maintain.scenario.php'
	WHERE function_id = 10182500
	End
ELSE
PRINT 'function_id doesnot exists'