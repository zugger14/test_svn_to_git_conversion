IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101192)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101192, 'Maintain Counterparty Contacts IU', 'Maintain Counterparty Contacts IU', 10101115, 'windowCounterpartyContactDetail')
 	PRINT ' Inserted 10101192 - Maintain Counterparty Contacts IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101192 - Maintain Counterparty Contacts IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101193)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101193, 'Delete Counterparty Contacts', 'Delete Counterparty Contacts', 10101115, NULL)
 	PRINT ' Inserted 10101193 - Delete Counterparty Contacts.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101193 - Delete Counterparty Contacts already EXISTS.'
END
