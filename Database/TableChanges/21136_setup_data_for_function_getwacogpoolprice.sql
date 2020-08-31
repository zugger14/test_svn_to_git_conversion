--Insert formula in static data value
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000134)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (10000134, 800, 'GetWACOGPoolPrice', 'The function is used to calculate WACOG.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000134 - GetWACOGPoolPrice.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000134 - GetWACOGPoolPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--Insert formula into formula function mapping

--SELECT * FROM formula_function_mapping WHERE function_name LIKE '%wacog%'--'VATPercent'
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GetWACOGPoolPrice')
BEGIN
	INSERT INTO formula_function_mapping
	(
		function_name,
		eval_string,
		arg1
	)
	VALUES
	(
		'GetWACOGPoolPrice',
		'dbo.FNARGetWACOGPoolPrice(CAST(arg1 AS INT))',
		'arg1'
	)
END

--Insert formula into formula_editor_parameter
IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = 10000134)
BEGIN
	INSERT INTO formula_editor_parameter
	(
		formula_id,
		field_label,
		field_type,
		tooltip,
		field_size,
		sql_string,
		is_required,
		is_numeric,
		custom_validation,
		sequence,
		blank_option,
		arg_referrence_field_value_id
	)
	VALUES
	(
		10000134,
		'WACOG Group ID',
		't',
		'WACOG Group ID',
		0,
		NULL,
		1,
		1,
		NULL,
		1,
		0,
		NULL
	)
END

IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = 10000134)
BEGIN
	--INSERT formula to map_function_category
	INSERT INTO map_function_category
	(
		category_id,
		function_id,
		is_active
	)
	VALUES
	(
		27403,
		10000134,
		1
	)
END
