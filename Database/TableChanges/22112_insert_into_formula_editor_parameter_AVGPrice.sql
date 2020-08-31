IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE field_label = 'Curve ID' AND tooltip = 'Curve ID' AND function_name = 'AVGPrice')
BEGIN
	INSERT INTO formula_editor_parameter(field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, blank_option, arg_referrence_field_value_id, function_name)
	SELECT 'Curve ID', 'd', NULL, 'Curve ID', 0, 'EXEC spa_GetAllPriceCurveDefinitions @flag = s', 1, 0, NULL, 1, 0, NULL, 'AVGPrice'
END
 

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE field_label = 'Month From' AND tooltip = 'Month From' AND function_name = 'AVGPrice')
BEGIN
	INSERT INTO formula_editor_parameter(field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, blank_option, arg_referrence_field_value_id, function_name)
	SELECT 'Month From', 't', NULL, 'Month From', 0, NULL, 1, 0, NULL, 1, 0, NULL, 'AVGPrice'
END
 

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE field_label = 'Month To' AND tooltip = 'Month To' AND function_name = 'AVGPrice')
BEGIN
	INSERT INTO formula_editor_parameter(field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, blank_option, arg_referrence_field_value_id, function_name)
	SELECT 'Month To', 't', NULL, 'Month To', 0, NULL, 1, 0, NULL, 1, 0, NULL, 'AVGPrice'
END