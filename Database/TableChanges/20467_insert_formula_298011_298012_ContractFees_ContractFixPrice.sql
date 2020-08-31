-- Static Data
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 298011)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (298011, 800, 'ContractFees', 'ContractFees', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 298011 - ContractFees.'
END
ELSE
BEGIN
    PRINT 'Static data value 298011 - ContractFees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 298012)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (298012, 800, 'ContractFixPrice', 'ContractFixPrice', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 298012 - ContractFixPrice.'
END
ELSE
BEGIN
    PRINT 'Static data value 298012 - ContractFixPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--map_function_category
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE category_id = 27403 AND function_id = 298011)
BEGIN
	INSERT INTO map_function_category (category_id, function_id, is_active)
	SELECT 27403, 298011, 1
END

IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE category_id = 27403 AND function_id = 298012)
BEGIN
	INSERT INTO map_function_category (category_id, function_id, is_active)
	SELECT 27403, 298012, 1
END

-- formula_function_mapping
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractFees')
BEGIN
	INSERT INTO formula_function_mapping(function_name, eval_string, arg1,arg2,arg3,arg4)
	SELECT	'ContractFees',
			'dbo.FNARContractFees(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4)',
			'arg1',
			'arg2',
			'CONVERT(VARCHAR,t.contract_id)',
			'CONVERT(VARCHAR(20),t.prod_date,120)'
END

IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractFixPrice')
BEGIN
	INSERT INTO formula_function_mapping(function_name, eval_string, arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9)
	SELECT	'ContractFixPrice',
			'dbo.FNARContractFixPrice(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4,arg5,arg6,cast(arg7 as int),cast(arg8 as int),cast(arg9 as int))',
			'arg1',
			'arg2',
			'CONVERT(VARCHAR,t.contract_id)',
			'CONVERT(VARCHAR(20),t.prod_date,120)',
			'CONVERT(VARCHAR(20),t.as_of_date,120)',
			'convert(VARCHAR(20),t.prod_date,120)',
			'convert(VARCHAR,t.hour)',
			'convert(VARCHAR,t.mins)',
			'convert(VARCHAR,t.is_dst)'
END
ELSE 
BEGIN
	UPDATE formula_function_mapping
	SET eval_string = 'dbo.FNARContractFixPrice(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4,arg5,arg6,cast(arg7 as int),cast(arg8 as int),cast(arg9 as int))',
		arg5 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
		arg6 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
		arg7 = 'convert(VARCHAR,t.hour)',
		arg8 = 'convert(VARCHAR,t.mins)',
		arg9 = 'convert(VARCHAR,t.is_dst)'
	WHERE function_name = 'ContractFixPrice'
END

-- formula_editor_parameter
IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = 298011 AND field_label ='Product Type' )
BEGIN
	INSERT INTO formula_editor_parameter(formula_id, field_label, field_type,tooltip, sql_string, is_required, is_numeric, sequence, blank_option)
	SELECT 298011, 'Product Type', 'd', 'Product Type', 'SELECT value_id, code FROM static_data_value WHERE type_id = 101100', 0, 1, 1, 0
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = 298011 AND field_label ='Charges' )
BEGIN
	INSERT INTO formula_editor_parameter(formula_id, field_label, field_type,tooltip, sql_string, is_required, is_numeric, sequence, blank_option)
	SELECT 298011, 'Charges', 'd', 'Charges', 'SELECT field_name, Field_label FROM user_defined_fields_template WHERE internal_field_type = 18730', 0, 1, 2, 0
END


IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = 298012 AND field_label ='Product Type' )
BEGIN
	INSERT INTO formula_editor_parameter(formula_id, field_label, field_type,tooltip, sql_string, is_required, is_numeric, sequence, blank_option)
	SELECT 298012, 'Product Type', 'd', 'Product Type', 'SELECT value_id, code FROM static_data_value WHERE type_id = 101100', 0, 1, 1, 1
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = 298012 AND field_label ='Option' )
BEGIN
	INSERT INTO formula_editor_parameter(formula_id, field_label, field_type,tooltip, sql_string, is_required, is_numeric, sequence, blank_option)
	SELECT 298012, 'Option', 'd', 'Option', 'SELECT 0 [value], ''Index Price'' [code] UNION ALL SELECT 1, ''Adder'' UNION ALL SELECT 2, ''Fixed Price''', 0, 1, 2, 0
END
ELSE
BEGIN
	UPDATE formula_editor_parameter
	SET sql_string = 'SELECT 0 [value], ''Index Price'' [code] UNION ALL SELECT 1, ''Adder'' UNION ALL SELECT 2, ''Fixed Price'''
	WHERE formula_id = 298012 AND field_label ='Option'
END