IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 813 AND field_label = 'Contract')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (813, 'Contract', 'd', '',  'Contract','','select contract_id, contract_name from contract_group','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 813 AND field_label = 'Charge Type')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (813, 'Charge Type', 'd', '',  'Charge Type','','select value_id, code from static_data_value where type_id = 10019','0','0','','2','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 813 AND field_label = 'Row Number')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (813, 'Row Number', 't', '',  'Row Number','','','1','0','greater_than_zero','3','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 813 AND field_label = 'Prior Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (813, 'Prior Month', 't', '',  'Prior Month','','','1','0','greater_than_zero','4','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 813 AND field_label = 'Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (813, 'Month', 'd', '',  'Month','','SELECT 1 ID , ''1'' Value UNION SELECT 2 ID , ''2'' Value UNION SELECT 3 ID , ''3'' Value','0','0','','5','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 813 AND field_label = 'Relative As of Date')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (813, 'Relative As of Date', 'd', '',  'Relative As of Date','','SELECT -1 ID , ''Prior As of Date'' Value UNION SELECT 0 ID , ''Max As of Date'' Value UNION SELECT 1 ID , ''Same As of Date'' Value','0','0','','6','farrms_admin', GETDATE())
END
