IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101177)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101177, 'Maintain Contract Address', 'Maintain Contract Address', 10101115, 'windowCounterpartyContractAddress')
 	PRINT ' Inserted 10101177 - Maintain Contract Address.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101177 - Maintain Contract Address already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101178)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101178, 'Maintain Contract Address IU', 'Maintain Contract Address IU', 10101115, 'windowCounterpartyContractAddressIU')
 	PRINT ' Inserted 10101178 - Maintain Contract Address IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101178 - Maintain Contract Address IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101179)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101179, 'Maintain Contract Address Delete', 'Maintain Contract Address Delete', 10101115, NULL)
 	PRINT ' Inserted 10101179 - Maintain Contract Address Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101179 - Maintain Contract Address Delete already EXISTS.'
END