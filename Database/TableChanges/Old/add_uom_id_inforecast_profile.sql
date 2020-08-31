IF COL_LENGTH('forecast_profile', 'uom_id') IS NULL 
	ALTER TABLE forecast_profile ADD uom_id INT
	