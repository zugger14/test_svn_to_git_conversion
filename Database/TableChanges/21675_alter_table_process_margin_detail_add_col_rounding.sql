
IF COL_LENGTH(N'process_margin_detail', N'rounding') IS NULL
BEGIN 
	ALTER TABLE process_margin_detail ADD rounding INT
END	  



