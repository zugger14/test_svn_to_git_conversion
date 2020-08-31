IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10171700, 'Send Confirmation', 'Send Confirmation', 10170000, 'windowSendConfirmation')
 	PRINT ' Inserted 10171700 - Send Confirmation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171700 - Send Confirmation already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171710)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10171710, 'Maintain Deal Confirmation Status', 'Maintain Deal Confirmation Status', 10171700, 'windowDealConfirmationStatus')
 	PRINT ' Inserted 10171710 - Maintain Deal Confirmation Status.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10171710 - Maintain Deal Confirmation Status already EXISTS.'
END

