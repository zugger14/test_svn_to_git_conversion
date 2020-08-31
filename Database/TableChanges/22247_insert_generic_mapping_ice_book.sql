IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ICE Book Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ICE Book Mapping', 3, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ICE Book Mapping'
	  , total_columns_used = 3
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ICE Book Mapping'
END

DECLARE @mapping_table_id INT
	  , @ice_trader INT
	  , @ice_hub INT
	  , @sub_book INT
	  , @sub_book_id INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ICE Book Mapping'

SELECT @ice_trader = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000252

SELECT @ice_hub = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000254

SELECT @sub_book = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -5674

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'ICE Trader', @ice_trader, 'ICE Hub', @ice_hub, 'Sub Book', @sub_book, '1,2,3'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'ICE Trader'
	  , clm1_udf_id = @ice_trader
	  , clm2_label = 'ICE Hub'
	  , clm2_udf_id = @ice_hub
	  , clm3_label = 'Sub Book'
	  , clm3_udf_id = @sub_book
	  , unique_columns_index = '1,2,3'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ICE Book Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'pmadonna4' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_NE_STR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'pmadonna4', 'Indiana Hub DA', @sub_book_id

	SET @sub_book_id = NULL
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'tdziedzic1' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_NY_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'tdziedzic1', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'ftrottier' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @sub_book_id = NULL
	
	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_WC_STR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'ftrottier', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'pcooke89' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_NY_STR_Commercial'
	
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'pcooke89', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'slaroche' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_QC_LTR_Commercial'
	
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'slaroche', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'amcdonald1' AND mapping_table_id = @mapping_table_id AND clm2_value = 'Indiana Hub DA')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_MI_STR_Commercial'
	
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'amcdonald1', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'amcdonald1' AND mapping_table_id = @mapping_table_id AND clm2_value = 'Indiana Hub DA Off-Peak')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_MI_STR_Commercial'
	
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'amcdonald1', 'Indiana Hub DA Off-Peak', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'amcdonald1' AND mapping_table_id = @mapping_table_id AND clm2_value = 'MISO_DA_LMP_Indiana Hub')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_PJM_STR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'amcdonald1', 'MISO_DA_LMP_Indiana Hub', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'golsen5' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_NE_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'golsen5', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'csener2' AND mapping_table_id = @mapping_table_id AND clm2_value = 'Indiana Hub DA')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_MI_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'csener2', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'csener2' AND mapping_table_id = @mapping_table_id AND clm2_value = 'Indiana Hub DA Off-Peak')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_MI_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'csener2', 'Indiana Hub DA Off-Peak', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'csener2' AND mapping_table_id = @mapping_table_id AND clm2_value = 'MISO_DA_LMP_Indiana Hub')
BEGIN
	SET @sub_book_id = NULL
	
	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_PJM_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'csener2', 'MISO_DA_LMP_Indiana Hub', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'sishwanthlal' AND mapping_table_id = @mapping_table_id AND clm2_value = 'Indiana Hub DA')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_MI_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'sishwanthlal', 'Indiana Hub DA', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'sishwanthlal' AND mapping_table_id = @mapping_table_id AND clm2_value = 'Indiana Hub DA Off-Peak')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_MI_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'sishwanthlal', 'Indiana Hub DA Off-Peak', @sub_book_id
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'sishwanthlal' AND mapping_table_id = @mapping_table_id AND clm2_value = 'MISO_DA_LMP_Indiana Hub')
BEGIN
	SET @sub_book_id = NULL

	SELECT @sub_book_id = book_deal_type_map_id
	FROM source_system_book_map
	WHERE logical_name = 'BMLP_PJM_LTR_Commercial'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value)
	SELECT @mapping_table_id, 'sishwanthlal', 'MISO_DA_LMP_Indiana Hub', @sub_book_id
END