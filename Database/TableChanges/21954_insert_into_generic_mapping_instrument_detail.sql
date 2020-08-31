SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000118)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000118, 5500, 'Instrument ID Code', 'Instrument ID Code', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000118 - Instrument ID Code.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000118 - Instrument ID Code already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Instrument ID Code')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000118, 'Instrument ID Code', 't', 'VARCHAR(250)', 'n', '', 'h', NULL, 180, -10000118
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000105)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000105, 5500, 'Instrument Full Name', 'Instrument Full Name', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000105 - Instrument Full Name.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000105 - Instrument Full Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Instrument Full Name')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000105, 'Instrument Full Name', 't', 'VARCHAR(250)', 'n', '', 'h', NULL, 180, -10000105
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000106)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000106, 5500, 'Instrument Classification', 'Instrument Classification', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000106 -  Instrument Classification..'
END
ELSE
BEGIN
    PRINT 'Static data value -10000106 -  Instrument Classification. already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Instrument Classification')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000106, 'Instrument Classification', 't', 'VARCHAR(250)', 'n', '', 'h', NULL, 180, -10000106
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000119)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000119, 5500, 'Underlying Instrument Code', 'Underlying Instrument Code', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000119 - Underlying Instrument Code.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000119 - Underlying Instrument Code already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Underlying Instrument Code')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000119, 'Underlying Instrument Code', 't', 'VARCHAR(250)', 'n', '', 'h', NULL, 180, -10000119
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000120)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000120, 5500, 'Maturity Date', 'Maturity Date', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000120 - Maturity Date.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000120 - Maturity Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Maturity Date')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000120, 'Maturity Date', 'a', 'VARCHAR(250)', 'n', '', 'h', NULL, 180, -10000120
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000121)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000121, 5500, 'Client', 'Client', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000121 - Client.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000121 - Client already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_id = -10000121)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000121, 'Client', 'd', 'VARCHAR(250)', 'n', 'SELECT source_counterparty_id, counterparty_name FROM source_counterparty where counterparty_id IN (''ICE'', ''CME'', ''EEX'')', 'h', NULL, 180, -10000121
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000126)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000126, 5500, 'Option Type', 'Option Type', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000126 - Option Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000126 - Option Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_id = -10000126)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000126, 'Option Type', 'd', 'VARCHAR(250)', 'n', 'SELECT ''c'' id, ''Call'' code UNION ALL SELECT ''p'', ''Put''', 'h', NULL, 180, -10000126
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000127)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000127, 5500, 'Strike Price', 'Strike Price', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000127 - Strike Price.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000127 - Strike Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_id = -10000127)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT -10000127, 'Strike Price', 't', 'VARCHAR(250)', 'n', NULL, 'h', NULL, 180, -10000127
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Instrument Detail')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used) 
	VALUES ('Instrument Detail', 9)
END

DECLARE @instrument_id_code INT,
		@instrument_full_name INT,
		@instrument_classification INT,
		@underlying_instrument_code INT,
		@maturity_date INT,
		@index INT,
		@counterparty_id INT,
		@option_type INT,
		@strike_price INT

SELECT @instrument_id_code = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000118
SELECT @instrument_full_name = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000105
SELECT @instrument_classification = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000106
SELECT @underlying_instrument_code = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000119
SELECT @maturity_date = udf_template_id FROM user_defined_fields_template WHERE Field_id = -10000120
SELECT @index = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'
SELECT @counterparty_id = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000121
SELECT @option_type = udf_template_id FROM user_defined_fields_template WHERE Field_id = -10000126
SELECT @strike_price = udf_template_id FROM user_defined_fields_template WHERE Field_id = -10000127

IF EXISTS (
	SELECT 1 
	FROM generic_mapping_definition gmd 
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id 
    WHERE gmh.mapping_name = 'Instrument Detail'
)
BEGIN
	UPDATE gmd
	SET clm1_label = 'Instrument ID Code',
		clm1_udf_id = @instrument_id_code,
		clm2_label = 'Instrument Full Name',
		clm2_udf_id = @instrument_full_name,
		clm3_label = 'Instrument Classification',
		clm3_udf_id = @instrument_classification,
		clm4_label = 'Underlying Instrument Code',
		clm4_udf_id = @underlying_instrument_code,
		clm5_label = 'Maturity Date',
		clm5_udf_id = @maturity_date,
		clm6_label = 'Index',
		clm6_udf_id = @index,
		clm7_label = 'Client',
	    clm7_udf_id = @counterparty_id,
	    clm8_label = 'Option Type',
	    clm8_udf_id = @option_type,
	    clm9_label = 'Strike Price',
	    clm9_udf_id = @strike_price
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Instrument Detail'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id, clm5_label, clm5_udf_id, clm6_label, clm6_udf_id, clm7_label, clm7_udf_id,
		clm8_label, clm8_udf_id, clm9_label, clm9_udf_id
	)
	SELECT mapping_table_id, 
		   'Instrument ID Code', @instrument_id_code,
		   'Instrument Full Name', @instrument_full_name,
		   'Instrument Classification', @instrument_classification,
		   'Underlying Instrument Code', @underlying_instrument_code,
		   'Maturity Date', @maturity_date,
		   'Index', @index,
		   'Client', @counterparty_id,
		   'Option Type', @option_type,
		   'Strike Price', @strike_price
	FROM generic_mapping_header 
	WHERE mapping_name = 'Instrument Detail'
END