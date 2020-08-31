/*
   Wednesday, August 26, 20093:45:52 PM
   User: farrms_admin
   Server: MSINGH\INSTANCE1
   Database: TRMTracker
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
ALTER TABLE dbo.working_days
	DROP CONSTRAINT FK_working_days_static_data_value
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.working_days WITH NOCHECK ADD CONSTRAINT
	FK_working_days_static_data_value FOREIGN KEY
	(
	block_value_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT
