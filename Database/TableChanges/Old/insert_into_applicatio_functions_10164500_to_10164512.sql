IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164500, 'Regulatory Submission', 'Source remit report', 10160000, NULL)
 	PRINT ' Inserted 10164500 - Regulatory Submission.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164500 - Regulatory Submission already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164510, 'Generate', 'Generate remit', 10164500, NULL)
 	PRINT ' Inserted 10164510 - Regulatory Submission IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164510 - Regulatory Submission IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164511)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164511, 'Delete', 'Delete remit', 10164500, NULL)
 	PRINT ' Inserted 10164511 - Regulatory Submission Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164511 - Regulatory Submission Delete already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164512)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10164512, 'Submit', 'Submit remit', 10164500, NULL)
 	PRINT ' Inserted 10164512 - Regulatory Submission Submit.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164512 - Regulatory Submission Submit already EXISTS.'
END

