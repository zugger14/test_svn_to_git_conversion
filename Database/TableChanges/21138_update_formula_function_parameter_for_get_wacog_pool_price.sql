IF EXISTS (SELECT 1 FROM formula_editor_parameter AS fep WHERE field_label = 'WACOG Group ID')
BEGIN
	UPDATE formula_editor_parameter
	SET field_type = 'd'
		, sql_string = 'SELECT wacog_group_id AS [Value], wacog_group_name AS [Label] FROM wacog_group'
	WHERE field_label = 'WACOG Group ID'
END