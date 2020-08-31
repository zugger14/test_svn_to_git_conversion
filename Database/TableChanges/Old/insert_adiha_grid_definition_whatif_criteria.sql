IF NOT EXISTS (SELECT * FROM adiha_grid_definition agd WHERE agd.grid_name = 'whatif_criteria')
BEGIN
	INSERT INTO adiha_grid_definition 
	(
		grid_name,
		fk_table,
		fk_column,
		load_sql,
		grid_label,
		grid_type,
		grouping_column
	) 
	VALUES
	(
		'whatif_criteria',
		NULL,
		NULL,
		'EXEC(''SELECT mwc.criteria_id AS [ID], mwc.criteria_name AS [Criteria Name], mwc.criteria_description AS [Criteria Description] FROM maintain_whatif_criteria mwc'')',
		NULL,
		'g',
		NULL
	)

	DECLARE @grid_id INT
	SELECT @grid_id  = grid_id FROM adiha_grid_definition agd WHERE agd.grid_name = 'whatif_criteria'

	INSERT INTO adiha_grid_columns_definition 
	(
		grid_id, 
		column_name, 
		column_label, 
		field_type, 
		sql_string, 
		is_editable, 
		is_required,
		column_order,
		is_hidden,
		column_width
	)
	SELECT 
		@grid_id,
		'criteria_id',
		'ID',
		'ro',
		NULL,
		'n',
		'y',
		1,
		'y',
		200
	UNION ALL
		SELECT 
		@grid_id,
		'criteria_name',
		'Name',
		'ro',
		NULL,
		'n',
		'y',
		2,
		'n',
		200
	UNION ALL
		SELECT 
		@grid_id,
		'criteria_description',
		'Description',
		'ro',
		NULL,
		'n',
		'y',
		3,
		'n',
		200
		

	PRINT 'Grid inserted successfully.'
END
ELSE 
BEGIN
	PRINT 'Grid already exist.'
END