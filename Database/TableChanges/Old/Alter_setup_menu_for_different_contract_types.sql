IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211024)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211024, 'Contract Non Standard Contract', 'Contract Non Standard Contract', 10211000, 'windowNonStandardContract')
 	PRINT ' Inserted 10211024 - Contract Non Standard Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211024 - Contract Non Standard Contract already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211024 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10211024, 'windowNonStandardContract', 'Maintain Non Standard Contract', '', 1, 10210000, 10000000, 133, 0)
    PRINT 'Non Standard Contract - 10211024 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10211024 already exists.'
END


IF EXISTS(SELECT 1 FROM application_functions WHERE function_id=10162700)
BEGIN
	UPDATE application_functions
	SET file_path='_contract_administration/maintain_contract_group/maintain.contract.transportation.php'
	WHERE function_id=10162700
END


IF EXISTS(SELECT 1 FROM application_functions WHERE function_id=10211024)
BEGIN
	UPDATE application_functions
	SET file_path='_contract_administration/maintain_contract_group/maintain.contract.nonstandard.php'
	WHERE function_id=10211024
END

IF EXISTS(SELECT 1 FROM setup_menu WHERE window_name='windowMaintainContract')
BEGIN
	UPDATE setup_menu
	set display_name='Maintain Standard Contract'
	WHERE window_name='windowMaintainContract'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38402)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38402, 38400, 'Transportation', 'Transportation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38402 - Transportation.'
END
ELSE
BEGIN
	PRINT 'Static data value 38402 - Transportation already EXISTS.'
END