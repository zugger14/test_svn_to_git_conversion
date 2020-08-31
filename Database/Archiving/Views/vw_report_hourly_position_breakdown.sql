IF OBJECT_ID('report_hourly_position_breakdown') IS NOT NULL 
DROP VIEW dbo.report_hourly_position_breakdown

go

CREATE VIEW [dbo].[report_hourly_position_breakdown]
AS
SELECT * FROM report_hourly_position_breakdown_arch1
UNION ALL
SELECT * FROM report_hourly_position_breakdown_arch2