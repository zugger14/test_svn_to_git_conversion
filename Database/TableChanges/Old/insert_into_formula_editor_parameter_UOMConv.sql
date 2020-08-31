IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 835 AND field_label = 'From UOM')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (835, 'From UOM', 'd', '',  'From UOM','','EXEC spa_getsourceuom @flag = s','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 835 AND field_label = 'To UOM')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (835, 'To UOM', 'd', '',  'To UOM','','EXEC spa_getsourceuom @flag = s','0','0','','2','farrms_admin', GETDATE())
END