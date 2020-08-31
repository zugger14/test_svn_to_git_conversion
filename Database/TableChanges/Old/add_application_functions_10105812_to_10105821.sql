-- Counterparty Contact

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105812)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105812, 'Counterparty Contact IU', 'Counterparty Contact IU', 10105810, NULL)
 	PRINT ' Inserted 10105812 - Counterparty Contact IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105812 - Counterparty Contact IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105813)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105813, 'Counterparty Contact Delete', 'Counterparty Contact Delete', 10105810, NULL)
 	PRINT ' Inserted 10105813 - Counterparty Contact Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105813 - Counterparty Contact Delete already EXISTS.'
END

-- Counterparty Bank Info

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105814)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105814, 'Counterparty Bank Info IU', 'Counterparty Bank Info IU', 10105810, NULL)
 	PRINT ' Inserted 10105814 - Counterparty Bank Info.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105814 - Counterparty Bank Info already IU EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105815)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105815, 'Counterparty Bank Info Delete', 'Counterparty Bank Info Delete', 10105810, NULL)
 	PRINT ' Inserted 10105815 - Counterparty Bank Info Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105815 - Counterparty Bank Info Delete already EXISTS.'
END

-- Counterparty Contracts

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105816)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105816, 'Counterparty Contract IU', 'Counterparty Contract IU', 10105810, NULL)
 	PRINT ' Inserted 10105816 - Counterparty Contract IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105816 - Counterparty Contract IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105817)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105817, 'Counterparty Contract Delete', 'Counterparty Contract Delete', 10105810, NULL)
 	PRINT ' Inserted 10105817 - Counterparty Contract Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105817 - Counterparty Contract Delete already EXISTS.'
END

--external ID

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105818)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105818, 'Counterparty External ID IU', 'Counterparty External ID IU', 10105810, NULL)
 	PRINT ' Inserted 10105818 - Counterparty External ID IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105818 - Counterparty External ID IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105819)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105819, 'Counterparty External ID Delete', 'Counterparty External ID Delete', 10105810, NULL)
 	PRINT ' Inserted 10105819 - Counterparty External ID Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105819 - Counterparty External ID Delete already EXISTS.'
END

--broker fees

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105820)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105820, 'Counterparty Broker Fees IU', 'Counterparty Broker Fees IU', 10105810, NULL)
 	PRINT ' Inserted 10105820 - Counterparty Broker Fees IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105820 - Counterparty Broker Fees IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105821)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105821, 'Counterparty Broker Fees Delete', 'Counterparty Broker Fees Delete', 10105810, NULL)
 	PRINT ' Inserted 10105821 - Counterparty Broker Fees Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105821 - Counterparty Broker Fees Delete already EXISTS.'
END