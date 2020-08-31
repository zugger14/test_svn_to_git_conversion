/*
   Tuesday, January 20, 200912:26:52 PM
   User: farrms_admin
   Server: BAGRAWAL\INSTANCE1
   Database: TRMTracker2_1
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
CREATE TABLE dbo.delivery_status
	(
	Id int NULL,
	deal_transport_id int NULL,
	delivery_status int NULL,
	status_timestamp datetime NULL,
	current_facility int NULL,
	estimated_delivery_date datetime NULL,
	estimated_delivery_time nchar(100) NULL,
	memo1 nchar(10) NULL,
	memo2 nchar(10) NULL
	)  ON [PRIMARY]
GO
COMMIT
select Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.delivery_status', 'Object', 'CONTROL') as Contr_Per 