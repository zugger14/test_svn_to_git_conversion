DELETE FROM formula_editor_parameter WHERE formula_id = -899
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -899 AND field_label = 'Curve ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-899, 'Curve ID', 'd', '',  'Curve ID','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -899 AND field_label = 'Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-899, 'Month', 't', '0',  'Month','','','1','1','greater_than_zero','2','farrms_admin', GETDATE())
END