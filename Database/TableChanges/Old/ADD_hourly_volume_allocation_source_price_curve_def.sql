IF COL_LENGTH('source_price_curve_def', 'hourly_volume_allocation') IS NULL 
	ALTER TABLE source_price_curve_def ADD hourly_volume_allocation INT
	
	
	