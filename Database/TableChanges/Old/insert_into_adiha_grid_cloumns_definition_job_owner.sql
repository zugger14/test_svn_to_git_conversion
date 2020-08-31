DECLARE @grid_id INT
SELECT @grid_id = grid_id FROM adiha_grid_definition WHERE grid_name = 'view_scheduled_job'

IF NOT EXISTS (SELECT 1 FROM adiha_grid_columns_definition WHERE column_name = 'job_owner') 
BEGIN
	INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden)
	SELECT @grid_id,'job_owner','Job Owner','ro',NULL,'y','y',9,'n'
END
ELSE
	PRINT 'Column already exists.'