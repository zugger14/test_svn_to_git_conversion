IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10105810)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10105810, 'Setup Counterparty IU', 'Setup Counterparty IU', 10105800, NULL, NULL)
 	PRINT ' Inserted 10105810 - Setup Counterparty  IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105810 - Setup Counterparty IU already EXISTS.'
END

IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10105811)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10105811, 'Setup Counterparty Delete', 'Setup Counterparty Delete', 10105800, NULL, NULL)
 	PRINT ' Inserted 10105811 - Setup Counterparty  Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105811 - Setup Counterparty Delete already EXISTS.'
END