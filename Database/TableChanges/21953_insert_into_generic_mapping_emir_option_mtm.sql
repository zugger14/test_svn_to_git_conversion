DELETE udft
FROM user_defined_fields_template udft
INNER JOIN static_data_value sdv
	ON sdv.value_id = udft.field_id
WHERE sdv.type_id = 5500
	AND sdv.code = 'As of Date '

DELETE 
FROM static_data_value
WHERE type_id = 5500
	AND code = 'As of Date '

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000180)
BEGIN
	INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000180, 'As of Date', 'As of Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000180 - As of Date.'
END
SET IDENTITY_INSERT static_data_value OFF   

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000180)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, field_label, Field_type, data_type, sql_string, udf_type, field_id)
	VALUES (-10000180, 'As of Date', 'a', 'DATETIME', NULL, 'h', -10000180)
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000181)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000181, 'Call/Put', 'Call/Put', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000181 - Call/Put.'
END
SET IDENTITY_INSERT static_data_value OFF            

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000181)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, field_label, Field_type, data_type, sql_string, udf_type, field_id)
	VALUES (-10000181, 'Call/Put', 'd', 'CHAR(1)', 'SELECT * FROM (VALUES(''c'', ''Call''), (''p'', ''Put'')) t(a, b)', 'h', -10000181)
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000182)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000182, 'Expiration Date', 'Expiration Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000182 - Expiration Date.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = -10000182)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, field_label, Field_type, data_type, sql_string, udf_type, field_id)
	VALUES (-10000182, 'Expiration Date', 'a', 'DATETIME', NULL, 'h', -10000182)
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000183)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000183, 'Market Price', 'Market Price', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000183 - Market Price.'
END
SET IDENTITY_INSERT static_data_value OFF 

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000183)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, field_label, Field_type, data_type, sql_string, udf_type, field_id)
	VALUES (-10000183, 'Market Price', 't', 'float', NULL, 'h', -10000183)
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'EMIR Option MTM')
BEGIN
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used)
	VALUES ('EMIR Option MTM', 6)
END

DECLARE @mapping_table_id INT

SELECT @mapping_table_id = ISNULL(mapping_table_id, IDENT_CURRENT('generic_mapping_header')) FROM generic_mapping_header WHERE mapping_name = 'EMIR Option MTM'

DECLARE @as_of_date	INT,
		@index INT,
		@strike_price INT,
		@call_put INT,
		@expiration_date INT,
		@market_price INT

SELECT @as_of_date = udf_template_id FROM user_defined_fields_template WHERE field_name = -10000180
SELECT @index = udf_template_id FROM user_defined_fields_template WHERE field_name = 307377
SELECT @strike_price = udf_template_id FROM user_defined_fields_template WHERE field_name = -10000127
SELECT @call_put = udf_template_id FROM user_defined_fields_template WHERE field_name = -10000181
SELECT @expiration_date = udf_template_id FROM user_defined_fields_template WHERE field_name = -10000182
SELECT @market_price = udf_template_id FROM user_defined_fields_template WHERE field_name = -10000183


IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id, 
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id,
		clm6_label, clm6_udf_id,
		unique_columns_index,
		required_columns_index
	)
	VALUES (
		@mapping_table_id,
		'As of Date', @as_of_date,
		'Index', @index,
		'Strike Price', @strike_price,
		'Call/Put', @call_put,
		'Expiration Date', @expiration_date,
		'Market Price', @market_price,
		'1,2,3,4,5',
		'1,2,3,4,5,6'
	)
END