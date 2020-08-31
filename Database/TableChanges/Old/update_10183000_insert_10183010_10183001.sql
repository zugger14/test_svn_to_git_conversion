UPDATE application_functions 
	 SET function_name = 'Maintain Monte Carlo Models',
		function_desc = 'Maintain Monte Carlo Models',
		func_ref_id = 10180000,
		function_call = 'windowMaintainMonteCarloModels'
		 WHERE [function_id] = 10183000
PRINT 'Updated Application Function '

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183010)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183010, 'Monte Carlo Model Parameters Delete', 'Monte Carlo Model Parameters Delete', 10183000, 'windowMaintainMonteCarloModels')
 	PRINT ' Inserted 10183010 - Monte Carlo Model Parameters Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183010 - Monte Carlo Model Parameters Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183001)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183001, 'Define Monte Carlo Model Parameters IU', 'Define Monte Carlo Model Parameters IU', 10183000, 'windowMonteCarloModelParameter')
 	PRINT ' Inserted 10183001 - Define Monte Carlo Model Parameters IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183001 - Define Monte Carlo Model Parameters IU already EXISTS.'
END
