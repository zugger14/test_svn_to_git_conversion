
IF COL_LENGTH('limit_tracking_curve', 'tenor_month_from') IS NULL
BEGIN
	alter table limit_tracking_curve add tenor_month_from int, tenor_month_to int
	PRINT 'Column limit_tracking_curve.tenor_month_from added.'
END
ELSE
BEGIN
	PRINT 'Column limit_tracking_curve.tenor_month_from already exists.'
END
GO
