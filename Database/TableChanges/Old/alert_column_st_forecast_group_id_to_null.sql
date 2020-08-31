IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'short_term_forecast_mapping' AND column_name = 'st_forecast_group_id')
	ALTER TABLE short_term_forecast_mapping ALTER COLUMN st_forecast_group_id INTEGER NULL
