-- CORRECTING PREVIOUS RENAMING MISTAKE

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211000)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Maintain Settlement Rules',
		function_desc = 'Maintain Settlement Rules'
	WHERE function_id = 10211000
END

-- STANDARD CONTRACT

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211000)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Standard Contract Menu',
		function_desc = 'Standard Contract Menu',
		func_ref_id = '10211000'
	WHERE function_id = 10211200
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211210)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Add/Save',
		function_desc = 'Add/Save'
	WHERE function_id = 10211210
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211211)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Delete',
		function_desc = 'Delete'
	WHERE function_id = 10211211
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211212)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Copy',
		function_desc = 'Copy'
	WHERE function_id = 10211212
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211216)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Document',
		function_desc = 'Document'
	WHERE function_id = 10211216
END

-- NON STANDARD CONTRACT

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211300)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Non Standard Contract Menu',
		function_desc = 'Non Standard Contract Menu',
		func_ref_id = '10211000'
	WHERE function_id = 10211300
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211310)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Add/Save',
		function_desc = 'Add/Save'
	WHERE function_id = 10211310
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211311)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Delete',
		function_desc = 'Delete'
	WHERE function_id = 10211311
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211312)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Copy',
		function_desc = 'Copy'
	WHERE function_id = 10211312
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211313)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Document',
		function_desc = 'Document'
	WHERE function_id = 10211313
END

-- TRANSPORTATION CONTRACT

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211400)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Transportation Contract Menu',
		function_desc = 'Transportation Contract Menu',
		func_ref_id = '10211000'
	WHERE function_id = 10211400
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211410)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Add/Save',
		function_desc = 'Add/Save'
	WHERE function_id = 10211410
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211411)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Delete',
		function_desc = 'Delete'
	WHERE function_id = 10211411
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211412)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Copy',
		function_desc = 'Copy'
	WHERE function_id = 10211412
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211413)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Document',
		function_desc = 'Document'
	WHERE function_id = 10211413
END

IF NOT EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211414)
BEGIN
	INSERT INTO application_functions
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id,
		requires_at,
		document_path
	)
	VALUES
	(
		'10211414',
		'Delivery Path',
		'Delivery Path',
		'10211400',
		NULL,
		'Back Office/Contract Administration/Maintain Contract.htm'
	)
END

-- CONTRACT CHARGE TYPE

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211022)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Charge Type Add/Save',
		function_desc = 'Charge Type Add/Save'
	WHERE function_id = 10211022
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211026)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Charge Type Delete',
		function_desc = 'Charge Type Delete'
	WHERE function_id = 10211026
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211029)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Charge Type Copy',
		function_desc = 'Charge Type Copy'
	WHERE function_id = 10211029
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211023)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Charge Type GL Code',
		function_desc = 'Charge Type GL Code'
	WHERE function_id = 10211023
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211027)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Charge Type Formula Add/Save',
		function_desc = 'Charge Type Formula Add/Save'
	WHERE function_id = 10211027
END

IF EXISTS (SELECT 1 FROM application_functions AS af WHERE af.function_id = 10211028)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'Charge Type Delete',
		function_desc = 'Charge Type Delete'
	WHERE function_id = 10211028
END

--

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10211000)
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup Standard Contract'
	WHERE function_id = 10211000
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10211300)
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup Non Standard Contract'
	WHERE function_id = 10211300
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10211400)
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup Transportation Contract'
	WHERE function_id = 10211400
END

--

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10105800)
BEGIN
	UPDATE setup_menu
	SET
		display_name = 'Setup Counterparty'
	WHERE function_id = 10105800
END

--

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10105800)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'View'
	WHERE function_id = 10105800
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10211000)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'View'
	WHERE function_id = 10211000
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10211300)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'View'
	WHERE function_id = 10211300
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10211400)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'View'
	WHERE function_id = 10211400
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10211200)
BEGIN
	UPDATE application_functions
	SET
		function_name = 'View'
	WHERE function_id = 10211200
END

