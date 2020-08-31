IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105800)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Menu',
		function_desc = 'Counterparty Menu'
	WHERE function_id = 10105800
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105810)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Add/Save',
		function_desc = 'Counterparty Add/Save'
	WHERE function_id = 10105810
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105811)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Delete',
		function_desc = 'Counterparty Delete'
	WHERE function_id = 10105811
END

-- TABS

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105812)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Contact Add/Save',
		function_desc = 'Counterparty Contact Add/Save'
	WHERE function_id = 10105812
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105813)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Contact Delete',
		function_desc = 'Counterparty Contact Delete'
	WHERE function_id = 10105813
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105814)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Bank Add/Save',
		function_desc = 'Counterparty Bank Add/Save'
	WHERE function_id = 10105814
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105815)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Bank Delete',
		function_desc = 'Counterparty Bank Delete'
	WHERE function_id = 10105815
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105816)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Contract Add/Save',
		function_desc = 'Counterparty Contract Add/Save'
	WHERE function_id = 10105816
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105817)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Contract Delete',
		function_desc = 'Counterparty Contract Delete'
	WHERE function_id = 10105817
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105818)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty External ID Add/Save',
		function_desc = 'Counterparty External ID Add/Save'
	WHERE function_id = 10105818
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105819)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty External ID Delete',
		function_desc = 'Counterparty External ID Delete'
	WHERE function_id = 10105819
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105820)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Broker Add/Save',
		function_desc = 'Counterparty Broker Add/Save'
	WHERE function_id = 10105820
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105821)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Counterparty Broker Delete',
		function_desc = 'Counterparty Broker Delete'
	WHERE function_id = 10105821
END
