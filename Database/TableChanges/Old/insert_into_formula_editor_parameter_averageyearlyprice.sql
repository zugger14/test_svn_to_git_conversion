IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -873 AND field_label = 'Curve ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-873, 'Curve ID', 'd', '',  'Curve ID','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -873 AND field_label = 'Average Type')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-873, 'Average Type', 'd', '',  'Average Type','','SELECT 0 ID , ''Simple Average'' Value UNION SELECT 1 ID , ''Volume Weighted Average'' Value','0','0','','2','farrms_admin', GETDATE())
END