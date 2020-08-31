IF COL_LENGTH('source_price_curve_def', 'curve_tou') IS NULL
	ALTER TABLE source_price_curve_def ADD curve_tou INT
GO 

