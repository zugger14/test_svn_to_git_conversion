--Maintain What If Criteria 
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183412)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183412, 'Maintain What If Criteria IU Portfolio IU', 'Maintain What If Criteria IU Portfolio IU', 10183400, 'windowWhatIfScenarioPortfolio')
 	PRINT ' Inserted 10183412 - Maintain What If Criteria IU Portfolio IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183412 - Maintain What If Criteria IU Portfolio IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183413)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183413, 'Maintain What If Criteria IU Others IU', 'Maintain What If Criteria IU Others IU', 10183400, 'windowWhatIfScenarioOther')
 	PRINT ' Inserted 10183413 - Maintain What If Criteria IU Others IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183413 - Maintain What If Criteria IU Others IU already EXISTS.'
END


--Maintain Portfolio Group

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183212)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183212, 'Maintain Portfoio Group Detail IU', 'Maintain Portfoio Group Detail IU', 10183200, 'windowWhatIfScenarioPortfolio')
 	PRINT ' Inserted 10183212 - Maintain Portfoio Group Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183212 - Maintain Portfoio Group Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183213, 'Maintain Portfoio Group Detail Other IU', 'Maintain Portfoio Group Detail Other IU', 10183200, 'windowWhatIfScenarioOther')
 	PRINT ' Inserted 10183213 - Maintain Portfoio Group Detail Other IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183213 - Maintain Portfoio Group Detail Other IU already EXISTS.'
END
