IF OBJECT_ID('report_hourly_position_deal') IS NOT NULL 
DROP VIEW dbo.report_hourly_position_deal

go

CREATE VIEW [dbo].[report_hourly_position_deal]
AS
SELECT * FROM report_hourly_position_deal_arch1
UNION ALL
SELECT * FROM report_hourly_position_deal_arch2