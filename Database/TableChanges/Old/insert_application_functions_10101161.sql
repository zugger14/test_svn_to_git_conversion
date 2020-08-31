IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101161)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10101161, 'Deal Confirmation Rule', 'Deal Confirmation Rule', 10101115, 'windowDealConfirmationRule', '_setup/confirmation_rule/confirmation_rule.php')
 	PRINT ' Inserted 10101161 - Deal Confirmation Rule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101161 - Deal Confirmation Rule already EXISTS.'
END