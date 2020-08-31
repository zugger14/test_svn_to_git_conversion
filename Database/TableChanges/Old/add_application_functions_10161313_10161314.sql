IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161313)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161313, 'Maintain Delivery Schedule Detail IU', 'Maintain Delivery Schedule Detail IU', 10161312, 'windowRunDeliveryStatusIU')
 	PRINT ' Inserted 10161313 - Maintain Delivery Schedule Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161313 - Maintain Delivery Schedule Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161314)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161314, 'Maintain Delivery Schedule Detail Delete', 'Maintain Delivery Schedule Detail Delete', 10161312, '')
 	PRINT ' Inserted 10161314 - Maintain Delivery Schedule Detail Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161314 - Maintain Delivery Schedule Detail Delete already EXISTS.'
END
