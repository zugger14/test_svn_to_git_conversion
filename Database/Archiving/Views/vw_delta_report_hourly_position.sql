IF OBJECT_ID('delta_report_hourly_position') IS NOT NULL 
DROP VIEW dbo.delta_report_hourly_position

go

CREATE VIEW [dbo].[delta_report_hourly_position]
AS
SELECT * FROM delta_report_hourly_position_arch1
UNION ALL
SELECT * FROM delta_report_hourly_position_arch2


