IF OBJECT_ID('report_hourly_position_profile') IS NOT NULL 
DROP VIEW dbo.report_hourly_position_profile

go

CREATE VIEW [dbo].[report_hourly_position_profile]
AS
SELECT * FROM report_hourly_position_profile_arch1
UNION ALL
SELECT * FROM report_hourly_position_profile_arch2