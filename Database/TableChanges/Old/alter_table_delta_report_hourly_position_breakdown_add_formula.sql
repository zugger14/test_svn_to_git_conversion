
IF COL_LENGTH('delta_report_hourly_position_breakdown', 'formula') IS NULL
BEGIN
	ALTER TABLE delta_report_hourly_position_breakdown ADD formula varchar(100)
	PRINT 'Column delta_report_hourly_position_breakdown.formula added.'
END
ELSE
BEGIN
	PRINT 'Column delta_report_hourly_position_breakdown.formula already exists.'
END
GO

