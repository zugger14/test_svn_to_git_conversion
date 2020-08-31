IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105822)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10105822, 'Counterparty Document', 'Counterparty Document', 10105800, NULL)
 	PRINT ' Inserted 10105822 - Counterparty Document.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105822 - Counterparty Document exists.'
END