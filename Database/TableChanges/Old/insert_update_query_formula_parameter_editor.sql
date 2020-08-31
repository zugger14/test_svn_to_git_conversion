IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = -801 AND field_label = 'Block Definition') 
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label ,field_type ,default_value ,tooltip ,field_size ,sql_string ,is_required ,is_numeric ,custom_validation ,sequence, blank_option)
	VALUES (-801, 'Block Definition', 'd', NULL, 'Block Definition', 0, 'select value_id, code from static_data_value where type_id = 10018', 0, 0, NULL, 1, 1)
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = -801 AND field_label = 'Block Type') 
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label ,field_type ,default_value ,tooltip ,field_size ,sql_string ,is_required ,is_numeric ,custom_validation ,sequence, blank_option)
	VALUES (-801, 'Block Type', 'd', NULL, 'Block Type', 0, 'SELECT value_id, code FROM static_data_value WHERE [type_id]=12000', 0, 0, NULL, 2, 1)
END

UPDATE formula_editor_parameter
SET default_value = 0
WHERE formula_id = 813 
	AND field_label = 'Prior Month'

DELETE 
FROM formula_editor_parameter
WHERE field_label = 'Granularity'
	AND formula_id = -916

IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -857)
BEGIN
	INSERT INTO map_function_category(category_id, function_id)
	VALUES (27407, -857)
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = -857 AND field_label = 'Meter ID') 
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label ,field_type ,default_value ,tooltip ,field_size ,sql_string ,is_required ,is_numeric ,custom_validation ,sequence, blank_option)
	VALUES (-857, 'Meter ID', 'd', NULL, 'Meter ID', 0, 'SELECT mi.meter_id, mi.recorderid FROM meter_id mi', 1, 0, NULL, 1, 1)
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = -857 AND field_label = 'Channel') 
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label ,field_type ,default_value ,tooltip ,field_size ,sql_string ,is_required ,is_numeric ,custom_validation ,sequence, blank_option)
	VALUES (-857, 'Channel', 'd', NULL, 'Channel', 0, 'SELECT channel, channel_description FROM recorder_properties', 1, 0, NULL, 1, 1)
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = -857 AND field_label = 'Curve ID') 
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label ,field_type ,default_value ,tooltip ,field_size ,sql_string ,is_required ,is_numeric ,custom_validation ,sequence, blank_option)
	VALUES (-857, 'Curve ID', 'd', NULL, 'Curve ID', 0, 'EXEC spa_GetAllPriceCurveDefinitions @flag = s', 0, 0, NULL, 1, 1)
END

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE formula_id = -857 AND field_label = 'Number of Continous Hours') 
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label ,field_type ,default_value ,tooltip ,field_size ,sql_string ,is_required ,is_numeric ,custom_validation ,sequence, blank_option)
	VALUES (-857, 'Number of Continous Hours', 't', '', 'Number of Continous Hours', 0, '', 1, 0, NULL, 1, 1)
END