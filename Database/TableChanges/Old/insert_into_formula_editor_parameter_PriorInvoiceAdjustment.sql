IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -909 AND field_label = 'Row Number')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-909, 'Row Number', 't', '',  'Row Number','','','1','0','greater_than_zero','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -909 AND field_label = 'Relative Production Month Number')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-909, 'Relative Production Month Number', 't', '',  'Relative Production Month Number','','','1','0','','2','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -909 AND field_label = 'Relative As Of Date Number')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-909, 'Relative As Of Date Number', 't', '',  'Relative As Of Date Number','','','1','0','greater_than_zero','3','farrms_admin', GETDATE())
END

