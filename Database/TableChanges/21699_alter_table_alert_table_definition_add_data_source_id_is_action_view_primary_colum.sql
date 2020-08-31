IF COL_LENGTH('alert_table_definition','data_source_id') IS NULL
	ALTER TABLE alert_table_definition ADD data_source_id INT

IF COL_LENGTH('alert_table_definition','is_action_view') IS NULL
	ALTER TABLE alert_table_definition ADD is_action_view CHAR(1)

IF COL_LENGTH('alert_table_definition','primary_column') IS NULL
	ALTER TABLE alert_table_definition ADD primary_column VARCHAR(2000)