ALTER TABLE dbo.process_risk_controls_dependency DROP CONSTRAINT FK_process_risk_controls_dependency_process_risk_controls1


/*
   Friday, April 10, 20096:13:33 PM
   User: farrms_admin
   Server: SMAHARJAN\INSTANCE1
   Database: TRM_Tracker
   Application: 
*/

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
ALTER TABLE dbo.process_risk_controls_dependency ADD CONSTRAINT
	FK_process_risk_controls_dependency_process_risk_controls_dependency FOREIGN KEY
	(
	risk_control_id_depend_on
	) REFERENCES dbo.process_risk_controls_dependency
	(
	risk_control_dependency_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
