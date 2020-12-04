
IF COL_LENGTH('report_hourly_position_financial_main', 'financial_curve_id') IS NULL
BEGIN
	alter table  dbo.[report_hourly_position_financial_main]  add financial_curve_id int
	alter table  dbo.delta_report_hourly_position_financial_main  add financial_curve_id int
END



