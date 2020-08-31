IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'report_writer_column' AND COLUMN_NAME = 'control_type')
	ALTER TABLE report_writer_column ADD control_type varchar(250)
	
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'report_writer_column' AND COLUMN_NAME = 'data_source')
	ALTER TABLE report_writer_column ADD data_source VARCHAR(8000)
	
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'report_writer_column' AND COLUMN_NAME = 'default_value')
	ALTER TABLE report_writer_column ADD default_value VARCHAR(500)