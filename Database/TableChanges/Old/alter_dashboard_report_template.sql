
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
COMMIT
select Has_Perms_By_Name(N'dbo.dashboardReportName', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.dashboardReportName', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.dashboardReportName', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.dashboard_report_template ADD
	report_template_name int NULL
GO
ALTER TABLE dbo.dashboard_report_template ADD CONSTRAINT
	FK_dashboard_report_template_dashboardReportName FOREIGN KEY
	(
	report_template_name
	) REFERENCES dbo.dashboardReportName
	(
	template_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.dashboard_report_template', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.dashboard_report_template', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.dashboard_report_template', 'Object', 'CONTROL') as Contr_Per 