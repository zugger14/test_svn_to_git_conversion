IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131215)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131215, 'Maintain Environmental Transactions IU', 'Maintain Environmental Transactions IU', 10131200, 'windowMaintainRecDeals')
 	PRINT ' Inserted 10131215 - Maintain Environmental Transactions IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131215 - Maintain Environmental Transactions IU already EXISTS.'
END