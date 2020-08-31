--DELETE FROM application_functional_users WHERE function_id = 10105800
DELETE FROM application_functional_users WHERE function_id = 10105810
DELETE FROM application_functional_users WHERE function_id = 10105811
DELETE FROM application_functional_users WHERE function_id = 10105812
DELETE FROM application_functional_users WHERE function_id = 10105813
DELETE FROM application_functional_users WHERE function_id = 10105814
DELETE FROM application_functional_users WHERE function_id = 10105815
DELETE FROM application_functional_users WHERE function_id = 10105816
DELETE FROM application_functional_users WHERE function_id = 10105817
DELETE FROM application_functional_users WHERE function_id = 10105818
DELETE FROM application_functional_users WHERE function_id = 10105819

--DELETE FROM application_functions WHERE function_id = 10105800
DELETE FROM application_functions WHERE function_id = 10105810
DELETE FROM application_functions WHERE function_id = 10105811
DELETE FROM application_functions WHERE function_id = 10105812
DELETE FROM application_functions WHERE function_id = 10105813
DELETE FROM application_functions WHERE function_id = 10105814
DELETE FROM application_functions WHERE function_id = 10105815
DELETE FROM application_functions WHERE function_id = 10105816
DELETE FROM application_functions WHERE function_id = 10105817
DELETE FROM application_functions WHERE function_id = 10105818
DELETE FROM application_functions WHERE function_id = 10105819

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105800)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105800, 'Setup Counterparty', 'Setup Counterparty', NULL, NULL )
	PRINT 'INSERTED 10105800 - Setup Counterparty.'
END
ELSE
BEGIN
	UPDATE application_functions SET function_name = 'Setup Counterparty' WHERE function_id = 10105800
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105810)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105810, 'Add/Save', 'Add/Save', NULL, NULL )
	PRINT 'INSERTED 10105810 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105810 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105811)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105811, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10105811 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105811 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105815)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105815, 'Contact', 'Contact', NULL, NULL )
	PRINT 'INSERTED 10105815 - Contact.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105815 - Contact already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105816)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105816, 'Add/Save', 'Add/Save', NULL, NULL )
	PRINT 'INSERTED 10105816 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105816 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105817)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105817, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10105817 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105817 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105830)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105830, 'Contract', 'Contract', NULL, NULL )
	PRINT 'INSERTED 10105830 - Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105830 - Contract already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105831)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105831, 'Add/Save', 'Add/Save', NULL, NULL )
	PRINT 'INSERTED 10105831 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105831 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105832)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105832, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10105832 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105832 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105845)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105845, 'Bank Info', 'Bank Info', NULL, NULL )
	PRINT 'INSERTED 10105845 - Bank Info.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105845 - Bank Info already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105846)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105846, 'Add/Save', 'Add/Save', NULL, NULL )
	PRINT 'INSERTED 10105846 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105846 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105847)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105847, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10105847 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105847 - Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105860)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105860, 'External ID', 'External ID', NULL, NULL )
	PRINT 'INSERTED 10105860 - External ID.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105860 - External ID already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105862)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105862, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10105862 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105862 - Delete already EXISTS.'
END

