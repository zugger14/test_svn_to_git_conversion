DELETE FROM formula_editor_parameter WHERE formula_id = -927
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -927 AND field_label = 'Mapping Name')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-927, 'Mapping Name', 'd', '',  'Mapping Name','','SELECT gmh.mapping_table_id [Value], gmh.mapping_name [Code] FROM generic_mapping_header gmh WHERE gmh.mapping_name IN (''APX Markup'',''Endex Markup'')','0','0','','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -927 AND field_label = 'Value')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	--VALUES (-874, 'Granularity', 'd', '',  'Granularity','','SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978','0','0','','2','farrms_admin', GETDATE())
	VALUES (-927, 'Row', 't', '',  'Row','','','0','0','','2','farrms_admin', GETDATE())
END






