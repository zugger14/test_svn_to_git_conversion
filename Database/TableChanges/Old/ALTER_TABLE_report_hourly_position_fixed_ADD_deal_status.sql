
IF COL_LENGTH('report_hourly_position_fixed', 'deal_status') IS NULL
BEGIN
	ALTER TABLE report_hourly_position_fixed ADD deal_status INT
	PRINT 'Column report_hourly_position_fixed.deal_status added.'
END
ELSE
BEGIN
	PRINT 'Column report_hourly_position_fixed.deal_status already exists.'
END
GO
	

