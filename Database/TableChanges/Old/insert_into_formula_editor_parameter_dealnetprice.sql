IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -852 AND field_label = 'Deal Type')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-852, 'Deal Type', 'd', '',  'Deal Type','','EXEC spa_getsourcedealtype @flag = s','0','0','','1','farrms_admin', GETDATE())
END