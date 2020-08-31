--Row Function
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 820 AND field_label = 'Row')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (820, 'Row', 't', '',  'Row Value','','','1','0','greater_than_zero','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 820 AND field_label = 'Offset')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (820, 'Offset', 't', '',  'Offset Value','','','0','0','','2','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 820 AND field_label = 'Aggregation')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (820, 'Aggregation', 'd', '',  'Aggregation Value','','SELECT 0 ID , ''SUM'' Value UNION SELECT 1 ID , ''AVERAGE'' Value','0','0','','3','farrms_admin', GETDATE())
END

--UDFValue
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 861 AND field_label = 'UDF Charges')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (861, 'UDF Charges', 'd', '',  'UDF Charges','','SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code','0','0','','1','farrms_admin', GETDATE())
END

--DealFVolm
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -849 AND field_label = 'UDF Charges')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-849, 'UDF Charges', 'd', '',  'UDF Charges','','SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code','0','0','','1','farrms_admin', GETDATE())
END

--RollingAVG
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 821 AND field_label = 'Number of Row')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (821, 'Number of Row', 't', '',  'Number of Rows','','','1','0','greater_than_zero','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 821 AND field_label = 'Number of Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (821, 'Number of Month', 't', '',  'Number of Month','','','1','0','greater_than_zero','2','farrms_admin', GETDATE())
END

--RollingSum
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 828 AND field_label = 'Row No')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (828, 'Row No', 't', '',  'Row No','','','1','0','greater_than_zero','1','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 828 AND field_label = 'No of month to sum')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (828, 'No of month to sum', 't', '',  'No of month to sum','','','1','0','greater_than_zero','2','farrms_admin', GETDATE())
END
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 828 AND field_label = 'No of month to skip')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (828, 'No of month to skip', 't', '',  'No of month to skip','','','1','0','greater_than_zero','3','farrms_admin', GETDATE())
END
