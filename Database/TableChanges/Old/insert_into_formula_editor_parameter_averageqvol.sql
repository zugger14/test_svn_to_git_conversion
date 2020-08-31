IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -898 AND field_label = 'Recorder ID')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-898, 'Recorder ID', 'd', '',  'Recorder ID','','SELECT mi.meter_id, mi.recorderid FROM meter_id mi','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = -898 AND field_label = 'Channel')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-898, 'Channel', 'd', '',  'Channel','','SELECT channel, channel_description FROM recorder_properties','0','0','','1','farrms_admin', GETDATE())
END

