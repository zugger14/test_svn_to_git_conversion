DELETE FROM formula_editor_parameter WHERE formula_id = 894
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 894 AND field_label = 'Curve ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (894, 'Curve ID', 'd', '',  'Curve ID','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 894 AND field_label = 'Block Defination')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts, blank_option)
	VALUES (894, 'Block Definition', 'd', '',  'Block Defination','','select '''' [value], '''' [code] UNION ALL select value_id, code from static_data_value where type_id = 10018','0','0','','4','farrms_admin', GETDATE(), 1)
END