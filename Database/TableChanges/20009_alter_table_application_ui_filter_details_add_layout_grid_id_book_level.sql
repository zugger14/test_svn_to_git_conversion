IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'application_ui_filter_details' AND  COLUMN_NAME = 'layout_grid_id')
BEGIN
	ALTER TABLE application_ui_filter_details ADD layout_grid_id INT
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'application_ui_filter_details' AND  COLUMN_NAME = 'book_level')
BEGIN
	ALTER TABLE application_ui_filter_details ADD book_level VARCHAR(20)
END