IF EXISTS (SELECT 1 FROM formula_editor_parameter fep WHERE formula_id = (SELECT sdv.value_id FROM static_data_value sdv WHERE sdv.code = 'Curve15') AND fep.field_label = 'Granularity')
BEGIN
	UPDATE fep
	SET field_label = 'Multiplier',
		field_type = 't',
		tooltip = 'Multiplier',
		sql_string = ''
	FROM formula_editor_parameter fep
	WHERE formula_id = (SELECT sdv.value_id FROM static_data_value sdv WHERE sdv.code = 'Curve15') AND fep.field_label = 'Granularity'
	
	PRINT 'Data successfully updated.'
END
ELSE
	PRINT 'Data doesn''t exist.'