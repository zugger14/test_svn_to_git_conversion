IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211213)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211213, 'Contract Report Template', 'Contract Report Template', 10211010, 'windowContractReportTemplate')
 	PRINT ' Inserted 10211213 - Contract Report Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211213 - Contract Report Template already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211214)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211214, 'Contract Report Template IU', 'Contract Report Template IU', 10211213, 'windowContractReportTemplateIU')
 	PRINT ' Inserted 10211214 - Contract Report Template IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211214 - Contract Report Template IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211215)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211215, 'Contract Report Template Delete', 'Contract Report Template Delete', 10211213, NULL)
 	PRINT ' Inserted 10211215 - Contract Report Template Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211215 - Contract Report Template Delete already EXISTS.'
END
