/*
   Tuesday, December 09, 20083:06:14 PM
   User: farrms_admin
   Server: SMAHARJAN\INSTANCE1
   Database: TRM_Master
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
CREATE TABLE dbo.Tmp_meter_id
	(
	meter_id int NOT NULL,
	recorderid varchar(100) NOT NULL,
	description varchar(255) NULL,
	meter_manufacturer varchar(100) NULL,
	meter_type varchar(100) NULL,
	meter_serial_number varchar(100) NULL,
	meter_certification datetime NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
IF EXISTS(SELECT * FROM dbo.meter_id)
	 EXEC('INSERT INTO dbo.Tmp_meter_id (recorderid, description, meter_manufacturer, meter_type, meter_serial_number, meter_certification, create_user, create_ts, update_user, update_ts)
		SELECT recorderid, description, meter_manufacturer, meter_type, meter_serial_number, meter_certification, create_user, create_ts, update_user, update_ts FROM dbo.meter_id WITH (HOLDLOCK TABLOCKX)')
GO
ALTER TABLE dbo.meter_id_allocation
	DROP CONSTRAINT FK_meter_id_allocation_meter_id
GO
ALTER TABLE dbo.Calc_Invoice_Volume_variance
	DROP CONSTRAINT FK_Calc_Invoice_Volume_meter_id
GO
ALTER TABLE dbo.recorder_properties
	DROP CONSTRAINT FK_recorder_properties_meter_id
GO
ALTER TABLE dbo.recorder_generator_map
	DROP CONSTRAINT FK_recorder_generator_map_meter_id
GO
DROP TABLE dbo.meter_id
GO
EXECUTE sp_rename N'dbo.Tmp_meter_id', N'meter_id', 'OBJECT' 
GO
ALTER TABLE dbo.meter_id ADD CONSTRAINT
	PK_meter_id PRIMARY KEY CLUSTERED 
	(
	recorderid
	) WITH( PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.meter_id ADD CONSTRAINT
	IX_meter_id UNIQUE NONCLUSTERED 
	(
	recorderid
	) WITH( PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
select Has_Perms_By_Name(N'dbo.meter_id', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.meter_id', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.meter_id', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.recorder_generator_map WITH NOCHECK ADD CONSTRAINT
	FK_recorder_generator_map_meter_id FOREIGN KEY
	(
	recorderid
	) REFERENCES dbo.meter_id
	(
	recorderid
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.recorder_generator_map', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.recorder_generator_map', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.recorder_generator_map', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.recorder_properties WITH NOCHECK ADD CONSTRAINT
	FK_recorder_properties_meter_id FOREIGN KEY
	(
	recorderid
	) REFERENCES dbo.meter_id
	(
	recorderid
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.recorder_properties', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.recorder_properties', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.recorder_properties', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Calc_Invoice_Volume_variance WITH NOCHECK ADD CONSTRAINT
	FK_Calc_Invoice_Volume_meter_id FOREIGN KEY
	(
	recorderid
	) REFERENCES dbo.meter_id
	(
	recorderid
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Calc_Invoice_Volume_variance', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Calc_Invoice_Volume_variance', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Calc_Invoice_Volume_variance', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.meter_id_allocation WITH NOCHECK ADD CONSTRAINT
	FK_meter_id_allocation_meter_id FOREIGN KEY
	(
	recorderid
	) REFERENCES dbo.meter_id
	(
	recorderid
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.meter_id_allocation', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.meter_id_allocation', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.meter_id_allocation', 'Object', 'CONTROL') as Contr_Per 