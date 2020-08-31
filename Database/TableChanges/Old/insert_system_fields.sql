IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'lock_deal_detail')
BEGIN
	INSERT INTO maintain_field_deal(field_id, farrms_field_id, default_label,
									field_type, data_type, default_validation, header_detail,
									system_required, sql_string, field_size, is_disable,
									window_function_id, is_hidden,
									default_value, insert_required, data_flag, update_required)
	SELECT 132, 'lock_deal_detail', 'Lock Deal Detail', 'd', 'char', NULL, 'd', 'y'            
			, 'SELECT ''n'' code, ''No'' Data UNION  SELECT ''y'' code, ''Yes'' Data'
			, NULL, 'n', NULL, 'n', 'n', 'n', 'i', 'y' 
	
END
 
IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'status')
BEGIN
	INSERT INTO maintain_field_deal(field_id, farrms_field_id, default_label,
								field_type, data_type, default_validation, header_detail,
								system_required, sql_string, field_size, is_disable,
								window_function_id, is_hidden,
								default_value, insert_required, data_flag, update_required)
	SELECT 133, 'status', 'Deal Status', 'd', 'int', NULL, 'd', 'y'            
			, 'SELECT value_id, code FROM dbo.static_data_value WHERE [type_id] = 25000'
			, NULL, NULL, NULL, 'n', NULL, 'n', 'i', 'y' 
	
END


--SELECT * 
--UPDATE maintain_field_deal
--SET sql_string = 'SELECT value_id, code FROM dbo.static_data_value WHERE [type_id] = 25000'
--FROM maintain_field_deal WHERE farrms_field_id = 'status'
  
/*
SELECT * FROM maintain_field_template_detail

SELECT * FROM maintain_field_deal 
WHERE farrms_field_id LIKE '%status%'
SELECT MAX(field_id) FROM maintain_field_deal
* */



