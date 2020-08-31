DELETE FROM formula_editor_parameter WHERE formula_id = -861
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -861 AND field_label = 'Curve ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-861, 'Curve ID', 'd', '',  'Curve ID','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','1','0','','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -861 AND field_label = 'Period')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-861, 'Period', 'd', '',  'Period','','SELECT 0 [id], ''0'' [value] UNION ALL SELECT 1 [id], ''1'' [value] UNION ALL SELECT 2 [id], ''2'' [value] ','1','1','','2','farrms_admin', GETDATE())
END


