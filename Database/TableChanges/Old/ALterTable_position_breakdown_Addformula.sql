IF COL_LENGTH('report_hourly_position_breakdown', 'formula') IS NULL
BEGIN
	ALTER TABLE report_hourly_position_breakdown ADD formula VARCHAR(100)
	PRINT 'Column report_hourly_position_breakdown.formula added.'
END
ELSE
BEGIN
	PRINT 'Column report_hourly_position_breakdown.formula already exists.'
END
GO 

IF COL_LENGTH('deal_position_break_down', 'formula') IS NULL
BEGIN
	ALTER TABLE deal_position_break_down ADD formula VARCHAR(100)
	PRINT 'Column deal_position_break_down.formula added.'
END
ELSE
BEGIN
	PRINT 'Column deal_position_break_down.formula already exists.'
END
GO 