--insert fields

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'contractual_volume')
BEGIN
	INSERT INTO maintain_field_deal(field_id, farrms_field_id, default_label,
									field_type, data_type, default_validation, header_detail,
									system_required, sql_string, field_size, is_disable,
									window_function_id, is_hidden,
									default_value, insert_required, data_flag, update_required)
	SELECT 135, 'contractual_volume', 'Contractual volume', 't', 'number', NULL, 'd', 'n'            
			, NULL
			, NULL, 'n', NULL, 'n', NULL, 'n', 'i', 'n' 
	
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'contractual_uom_id')
BEGIN
	INSERT INTO maintain_field_deal(field_id, farrms_field_id, default_label,
									field_type, data_type, default_validation, header_detail,
									system_required, sql_string, field_size, is_disable,
									window_function_id, is_hidden,
									default_value, insert_required, data_flag, update_required)
	SELECT 136, 'contractual_uom_id', 'Contractual UOM ID', 'd', 'int', NULL, 'd', 'n'            
			, 'exec spa_getsourceuom @flag=''s'''
			, NULL, 'n', NULL, 'n', NULL, 'n', 'i', 'n' 
	
END

GO
