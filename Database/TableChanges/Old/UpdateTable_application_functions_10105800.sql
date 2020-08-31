-- COUNTERPARTY RENAME

--IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105800)
--BEGIN
--	UPDATE application_functions
--	SET
--		function_name = 'Counterparty Menu',
--		function_desc = 'Counterparty Menu'
--	WHERE function_id = 10105800
--END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105800)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'View',
		function_desc = 'View'
	WHERE function_id = 10105800
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105810)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Add/Save',
		function_desc = 'Add/Save'
	WHERE function_id = 10105810
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105811)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Delete',
		function_desc = 'Delete'
	WHERE function_id = 10105811
END

--

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105812)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Contact Add/Save',
		function_desc = 'Contact Add/Save'
	WHERE function_id = 10105812
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105813)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Contact Delete',
		function_desc = 'Contact Delete'
	WHERE function_id = 10105813
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105814)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Bank Info Add/Save',
		function_desc = 'Bank Info Add/Save'
	WHERE function_id = 10105814
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105815)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Bank Info Delete',
		function_desc = 'Bank Info Delete'
	WHERE function_id = 10105815
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105816)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Contract Add/Save',
		function_desc = 'Contract Add/Save'
	WHERE function_id = 10105816
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105817)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Contract Delete',
		function_desc = 'Contract Delete'
	WHERE function_id = 10105817
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105818)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'External ID Add/Save',
		function_desc = 'External ID Add/Save'
	WHERE function_id = 10105818
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105819)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'External ID Delete',
		function_desc = 'External ID Delete'
	WHERE function_id = 10105819
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105820)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Broker Add/Save',
		function_desc = 'Broker Add/Save'
	WHERE function_id = 10105820
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105821)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Broker Delete',
		function_desc = 'Broker Delete'
	WHERE function_id = 10105821
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10105822)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Document',
		function_desc = 'Document'
	WHERE function_id = 10105822
END