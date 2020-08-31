SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000254)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000254, 'ICE Hub', 'ICE Hub', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000254 - ICE Hub.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000254 - ICE Hub already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000254)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000254, 'ICE Hub', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000254
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000255)
AND NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index ID')
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000255, 'Index ID', 'Index ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000255 - Index ID.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000255 - Index ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000255)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000255, 'Index ID', 'd', 'VARCHAR(100)', 'y', 'EXEC spa_source_price_curve_def_maintain @flag=''h''', 'h', 100, -10000255
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ICE Hub Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ICE Hub Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ICE Hub Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ICE Hub Mapping'
END

DECLARE @mapping_table_id INT
	  , @ice_hub INT
	  , @index_id INT
	  , @index_id_value INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ICE Hub Mapping'

SELECT @ice_hub = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000254

SELECT @index_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000255

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'ICE Hub', @ice_hub, 'Index ID', @index_id, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'ICE Hub'
	  , clm1_udf_id = @ice_hub
	  , clm2_label = 'Index ID'
	  , clm2_udf_id = @index_id
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ICE Hub Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'AD Hub DA')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'PJM_DA_LMP_AD Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'AD Hub DA', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Henry')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYMEX_HenryHub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Henry', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Indiana Hub DA')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'MISO_DA_LMP_Indiana Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Indiana Hub DA', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Indiana Hub DA Off-Peak')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'MISO_DA_LMP_Indiana Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Indiana Hub DA Off-Peak', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Mid C')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'WECC_DA_LMP_Mid-C'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Mid C', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Mid C (Daily)')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'WECC_DA_LMP_Mid-C'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Mid C (Daily)', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Nepool MH DA')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'ISONE_DA_LMP_.H.INTERNAL_HUB'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Nepool MH DA', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Nepool MH DA (Daily)')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'ISONE_DA_LMP_.H.INTERNAL_HUB'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Nepool MH DA (Daily)', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Nepool MH DA Off-Peak')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'ISONE_DA_LMP_.H.INTERNAL_HUB'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Nepool MH DA Off-Peak', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NP15 DA')
BEGIN
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NP15 DA', NULL
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO A')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone A'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO A', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO A (Daily)')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone A'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO A (Daily)', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO A Off-Peak')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone A'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO A Off-Peak', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO F')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone F'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO F', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO G')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone G'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO G', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO G (Daily)')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone G'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO G (Daily)', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO G Off-Peak')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'NYISO_DA_LMP_Zone G'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO G Off-Peak', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NYISO Lower Hudson Valley')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'Capacity_NYISO_Zone G-H-I'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NYISO Lower Hudson Valley', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Ontario')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'IESO_RT_LMP_HOEP'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Ontario', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'PJM WH DA')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'PJM_DA_LMP_Western Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'PJM WH DA', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'PJM WH DA (Daily)')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'PJM_DA_LMP_Western Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'PJM WH DA (Daily)', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'PJM WH DA Off-Peak')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'PJM_DA_LMP_Western Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'PJM WH DA Off-Peak', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'PJM WH RT')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'PJM_DA_LMP_Western Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'PJM WH RT', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'PJM WH RT (800 MWh)')
BEGIN
	SET @index_id_value = NULL

	SELECT @index_id_value = source_curve_def_id
	FROM source_price_curve_def
	WHERE curve_id = 'PJM_DA_LMP_Western Hub'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'PJM WH RT (800 MWh)', @index_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'SP15 DA')
BEGIN
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'SP15 DA', NULL
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'SP15 DA (Daily)')
BEGIN
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'SP15 DA (Daily)', NULL
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'SP15 DA Off-Peak')
BEGIN
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'SP15 DA Off-Peak', NULL
END