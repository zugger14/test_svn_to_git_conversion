DELETE FROM formula_editor_parameter WHERE formula_id = -901
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -901 AND field_label = 'Mapping Table')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-901, 'Mapping Table', 'd', '',  'Mapping Table','','SELECT mapping_table_id, mapping_name FROM generic_mapping_header WHERE mapping_name IN (''Contract Meters'', ''Contract Curves'', ''Contract Value'')','0','0','','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -901 AND field_label = 'Logical Name')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-901, 'Logical Name', 'd', '',  'Logical Name','','SELECT max(generic_mapping_values_id), clm3_value FROM generic_mapping_values GROUP BY clm3_value','0','0','','2','farrms_admin', GETDATE())
END


