IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -888 AND field_label = 'UDF Charges')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-888, 'UDF Charges', 'd', '',  'UDF Charges','','SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code','0','0','','1','farrms_admin', GETDATE())
END