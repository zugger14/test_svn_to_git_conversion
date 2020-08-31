IF COL_LENGTH('source_price_curve_def', 'holiday_calendar_id') IS NULL
BEGIN
ALTER TABLE source_price_curve_def ADD holiday_calendar_id INT NULL
END
ELSE
BEGIN
	PRINT 'Column holiday_calendar_id already EXISTS'
END