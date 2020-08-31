DELETE FROM formula_editor_parameter WHERE formula_id = -855
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -855 AND field_label = 'Curve ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-855, 'Curve ID', 'd', '',  'Curve ID','','EXEC spa_GetAllPriceCurveDefinitions ''s''','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -855 AND field_label = 'Granularity')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts, blank_option)
	VALUES (-855, 'Granularity', 'd', '',  'Granularity','','SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978','0','0','','2','farrms_admin', GETDATE(), 1)
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -855 AND field_label = 'Index Group')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts, blank_option)
	VALUES (-855, 'Index Group', 'd', '',  'Index Group','','SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 15100','0','0','','3','farrms_admin', GETDATE(), 1)
END
