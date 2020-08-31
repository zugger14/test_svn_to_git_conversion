IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'application_ui_layout_grid' AND  COLUMN_NAME = 'grid_object_name')
BEGIN
	ALTER TABLE application_ui_layout_grid ADD grid_object_name VARCHAR(200)
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'application_ui_layout_grid' AND  COLUMN_NAME = 'grid_object_unique_column')
BEGIN
	ALTER TABLE application_ui_layout_grid ADD grid_object_unique_column VARCHAR(200)
END