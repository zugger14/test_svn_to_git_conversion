IF COL_LENGTH('alert_reports','file_option_type') IS NULL 
	ALTER TABLE alert_reports ADD file_option_type CHAR(1)
GO
