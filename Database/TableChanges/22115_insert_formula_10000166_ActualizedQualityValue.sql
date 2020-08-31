IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_name = 'ActualizedQualityValue') 
BEGIN
	INSERT INTO map_function_category(category_id, function_name, is_active)
	VALUES(27407, 'ActualizedQualityValue', 1)
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE function_name = 'ActualizedQualityValue' AND field_label = 'Quality')                                                                                                       
BEGIN
 	INSERT INTO formula_editor_parameter (function_name, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES ('ActualizedQualityValue', 'Quality', 'd', '', 'Quality', '', 'SELECT value_id, code FROM static_data_value WHERE type_id = 29600', '0', '0', '', '2', 'farrms_admin', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ActualizedQualityValue') 
BEGIN
	INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2)
	VALUES ('ActualizedQualityValue', 'dbo.FNARActualizedQualityValue(arg1,CAST(arg2 AS INT))', 'CONVERT(VARCHAR,t.source_deal_detail_id)', 'arg1')
END
GO