IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'st_forecast_group_header' AND column_name = 'delivery_redelivery')
	ALTER TABLE st_forecast_group_header
		DROP COLUMN delivery_redelivery
GO