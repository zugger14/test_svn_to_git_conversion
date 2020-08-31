/*
   Thursday, April 02, 20092:24:32 PM
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
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.user_defined_deal_fields_template ADD
	field_id int NULL
GO
ALTER TABLE dbo.user_defined_deal_fields_template ADD CONSTRAINT
	FK_user_defined_deal_fields_template_static_data_value FOREIGN KEY
	(
	field_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
