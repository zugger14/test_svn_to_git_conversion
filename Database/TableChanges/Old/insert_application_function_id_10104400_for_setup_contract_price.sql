IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104400, 'Setup Contract Price', 'Setup Contract Price', 10100000, 'windowSetupContractPrice')
 	PRINT ' Inserted 10104400 - Setup Contract Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104400 - Setup Contract Price already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104410)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104410, 'Setup Contract Price IU', 'Setup Contract Price IU', 10104400, 'windowSetupContractPriceIU')
 	PRINT ' Inserted 10104410 - Setup Contract Price IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104410 - Setup Contract Price IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104411)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104411, 'Setup Contract Price Delete', 'Setup Contract Price Delete', 10104400, 'windowSetupContractPriceDelete')
 	PRINT ' Inserted 10104411 - Setup Contract Price Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104411 - Setup Contract Price Delete already EXISTS.'
END
