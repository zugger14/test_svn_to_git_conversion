IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211068)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211068, 'Contract Value', 'Contract Value', 10211017, 'windowContractValue')
 	PRINT ' Inserted 10211068 - Contract Value.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211068 - Contract Value already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211069)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211069, 'PrevEvents', 'PrevEvents', 10211017, 'windowPrevEvents')
 	PRINT ' Inserted 10211069 - PrevEvents.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211069 - PrevEvents already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211070)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211070, 'EODHours', 'EODHours', 10211017, 'windowEODHours')
 	PRINT ' Inserted 10211070 - EODHours.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211070 - EODHours already EXISTS.'
END

