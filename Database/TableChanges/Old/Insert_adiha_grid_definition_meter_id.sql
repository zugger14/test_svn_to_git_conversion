IF NOT EXISTS (SELECT * FROM adiha_grid_definition agd WHERE agd.grid_name = 'meter_id')
BEGIN
	INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, is_tree_grid, grouping_column)
	VALUES ('meter_id', NULL, NULL, 'n', NULL)
	
	DECLARE @grid_id INT
	SELECT @grid_id  = grid_id FROM adiha_grid_definition agd WHERE agd.grid_name = 'meter_id'
	
	INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required)
	SELECT @grid_id, 'meter_id', 'Meter Id', 'ro', NULL, 'n', 'y' UNION ALL
	SELECT @grid_id, 'recorderid', 'Meter Name ', 'ro',NULL,  'y', 'y'
END


