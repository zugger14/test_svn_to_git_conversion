IF NOT EXISTS (SELECT 1 FROM adiha_grid_definition WHERE grid_name = 'view_scheduled_job')
BEGIN
	INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column)
	VALUES ('view_scheduled_job', '', '', 'EXEC spa_get_schedule_job @flag=''s''', '', 'g', NULL)
	
	DECLARE @grid_id INT
	SET @grid_id = SCOPE_IDENTITY();
	
	INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden)
	SELECT @grid_id,'job_id','Job ID','ro',NULL,'y','y',1,'n' UNION ALL
	SELECT @grid_id,'name','Job Name','ro',NULL,'y','y',2,'n' UNION ALL
	SELECT @grid_id,'date_created','Date Created','ro',NULL,'y','y',3,'n' UNION ALL
	SELECT @grid_id,'next_scheduled_run_date','Next Scheduled Run Date','ro',NULL,'y','y',4,'n' UNION ALL
	SELECT @grid_id,'last_exectued_step_date','Last Executed Date','ro',NULL,'y','y',5,'n' UNION ALL
	SELECT @grid_id,'owner_sid','Job Owner','ro',NULL,'y','y',6,'n' UNION ALL
	SELECT @grid_id,'run_status','Job Status','ro',NULL,'y','y',7,'n' UNION ALL
	SELECT @grid_id,'date_modified','Date Modified','ro',NULL,'y','y',8,'n' UNION ALL
	SELECT @grid_id,'job_owner','Job Owner','ro',NULL,'y','y',9,'n'
	
END
ELSE 
BEGIN
	PRINT 'Data already exists.'
END	
