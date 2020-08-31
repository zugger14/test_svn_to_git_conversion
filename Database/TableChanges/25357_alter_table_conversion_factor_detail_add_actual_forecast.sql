IF COL_LENGTH('conversion_factor_detail', 'actual_forecast') IS NULL
BEGIN
	 /**
	  Add column actual_forecast
	*/
	 ALTER TABLE conversion_factor_detail ADD actual_forecast NCHAR(1) 
END
GO





