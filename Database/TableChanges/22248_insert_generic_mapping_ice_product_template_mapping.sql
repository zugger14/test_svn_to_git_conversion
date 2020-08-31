SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000256)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000256, 'ICE Product', 'ICE Product', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000256 - ICE Product.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000256 - ICE Product already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000256)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000256, 'ICE Product', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000256
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ICE Product Template Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ICE Product Template Mapping', 4, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ICE Product Template Mapping'
	  , total_columns_used = 4
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ICE Product Template Mapping'
END

DECLARE @mapping_table_id INT
	  , @ice_product INT
	  , @template INT
	  , @deal_type INT
	  , @product_group INT
	  , @template_id INT
	  , @deal_type_id INT
	  , @product_group_id INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ICE Product Template Mapping'

SELECT @ice_product = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000256

SELECT @template = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 307058

SELECT @deal_type = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 300374

SELECT @product_group = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 309215

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id, clm4_label, clm4_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'ICE Product', @ice_product, 'Template', @template, 'Deal Type', @deal_type, 'Product Group', @product_group, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'ICE Product'
	  , clm1_udf_id = @ice_product
	  , clm2_label = 'Template'
	  , clm2_udf_id = @template
	  , clm3_label = 'Deal Type'
	  , clm3_udf_id = @deal_type
	  , clm4_label = 'Product Group'
	  , clm4_udf_id = @product_group	  
	  , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ICE Product Template Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Capacity Futures' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Capacity'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Capacity'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Capacity'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Capacity Futures', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NG LD1 Futures' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'NG LD1 Futures', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NGX Fin FUT FF, FP for IESO Peak' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'NGX Fin FUT FF, FP for IESO Peak', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Off-Peak Futures' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Off-Peak Futures', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Off-Peak Futures (1 MW)' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Off-Peak Futures (1 MW)', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Peak Futures' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Peak Futures', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Peak Futures (1 MW)' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Peak Futures (1 MW)', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Peak Futures (25 MW)' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Peak Futures (25 MW)', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Peak Futures (50 MW)' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Financial'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Swap'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Swap'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Peak Futures (50 MW)', @template_id, @deal_type_id, @product_group_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Peak Futures Option' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @template_id = NULL

	SELECT @template_id = template_id
	FROM source_deal_header_template sdht 
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  
	LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id 
	WHERE sdht.is_active = 'y' 
	AND template_name = 'Options'

	SET @deal_type_id = NULL

	SELECT @deal_type_id = source_deal_type_id
	FROM source_deal_type 
	WHERE sub_type = 'n'
	AND deal_type_id = 'Options'

	SET @product_group_id = NULL

	SELECT @product_group_id = value_id
	FROM static_data_value
	WHERE [type_id] = 27000
	AND code = 'Options'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value)
	SELECT @mapping_table_id, 'Peak Futures Option', @template_id, @deal_type_id, @product_group_id
END