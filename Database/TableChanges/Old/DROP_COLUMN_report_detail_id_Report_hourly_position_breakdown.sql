/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/

IF EXISTS (SELECT 1 FROM sys.columns WHERE [name]='report_detail_id' AND [object_id]= OBJECT_ID('report_hourly_position_breakdown'))
	ALTER TABLE dbo.report_hourly_position_breakdown	DROP COLUMN report_detail_id

