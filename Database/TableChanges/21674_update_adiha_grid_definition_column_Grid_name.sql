
IF NOT EXISTS(SELECT 1 FROM adiha_grid_definition where grid_name = 'import_data_interface')
BEGIN 
	UPDATE adiha_grid_definition SET grid_name = 'import_data_interface' where grid_id = 292
END