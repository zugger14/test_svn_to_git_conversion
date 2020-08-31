IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10105800, 'Setup Counterparty', 'Setup Counterparty', 10100000, 'windowSetupCounterparty', '_setup/setup_counterparty/setup.counterparty.php')
 	PRINT ' Inserted 10105800 - Setup Counterparty.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105800 - Setup Counterparty already EXISTS.'
END