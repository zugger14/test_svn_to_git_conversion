DELETE FROM formula_editor_parameter WHERE formula_id = 850

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 850 AND field_label = 'Recorder ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (850, 'Recorder ID', 'd', '',  'Recorder ID','','SELECT mi.meter_id, mi.recorderid FROM meter_id mi','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 850 AND field_label = 'Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (850, 'Month', 't', '0',  'Month','','','1','0','','2','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 850 AND field_label = 'Channel')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (850, 'Channel', 'd', '',  'Channel','','SELECT channel, channel_description FROM recorder_properties','1','0','','3','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = 850 AND field_label = 'Block Defination')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (850, 'Block Definition', 'd', '',  'Block Defination','','select '''' [value], '''' [code] UNION ALL select value_id, code from static_data_value where type_id = 10018','0','0','','4','farrms_admin', GETDATE())
END