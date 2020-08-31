--add file_name in deal_detail_hour to store source file name
IF COL_LENGTH('report_hourly_position_deal', 'deal_status_id') IS NULL 
	ALTER TABLE dbo.report_hourly_position_deal ADD deal_status_id INT NULL
GO

IF COL_LENGTH('report_hourly_position_profile', 'deal_status_id') IS NULL 
	ALTER TABLE dbo.report_hourly_position_profile ADD deal_status_id INT NULL
GO

IF COL_LENGTH('report_hourly_position_breakdown', 'deal_status_id') IS NULL 
	ALTER TABLE dbo.report_hourly_position_breakdown ADD deal_status_id INT NULL
GO

--add file_name in deal_detail_hour to store source file name
IF COL_LENGTH('delta_report_hourly_position_deal', 'deal_status_id') IS NULL 
	ALTER TABLE dbo.delta_report_hourly_position_deal ADD deal_status_id INT NULL
GO

IF COL_LENGTH('delta_report_hourly_position_profile', 'deal_status_id') IS NULL 
	ALTER TABLE dbo.delta_report_hourly_position_profile ADD deal_status_id INT NULL
GO

IF COL_LENGTH('delta_report_hourly_position_breakdown', 'deal_status_id') IS NULL 
	ALTER TABLE dbo.delta_report_hourly_position_breakdown ADD deal_status_id INT NULL
GO

IF COL_LENGTH('delta_report_hourly_position_breakdown', 'term_end') IS NULL 
	ALTER TABLE dbo.delta_report_hourly_position_breakdown ADD term_end DATETIME NULL
GO
