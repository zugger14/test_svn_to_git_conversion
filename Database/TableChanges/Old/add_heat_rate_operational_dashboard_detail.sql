IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'operational_dashboard_detail' AND COLUMN_NAME = 'heat_rate') 
BEGIN
	alter table [dbo].[operational_dashboard_detail] add [heat_rate] [numeric](20, 8) NULL
END


