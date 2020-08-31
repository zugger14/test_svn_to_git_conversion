DELETE FROM formula_editor_parameter WHERE formula_id = -926
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id =-926 AND field_label = 'Curve ID1')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-926, 'Curve ID1', 'd', '',  'Curve ID1','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -926 AND field_label = 'Curve ID2')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-926, 'Curve ID2', 'd', '',  'Curve ID2','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -926 AND field_label = 'Holiday')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-926, 'Holiday', 'd', '',  'Holiday','','SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 10017 ORDER BY code','0','0','','1','farrms_admin', GETDATE())
END