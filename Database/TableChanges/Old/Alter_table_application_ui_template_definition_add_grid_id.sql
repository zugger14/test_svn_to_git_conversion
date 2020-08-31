IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'application_ui_template_fields' AND COLUMN_NAME = 'grid_id')
BEGIN
	ALTER TABLE application_ui_template_fields ADD  grid_id VARCHAR(100) NULL
END
