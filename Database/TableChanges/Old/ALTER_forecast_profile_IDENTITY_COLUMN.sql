/*
   Friday, March 04, 20114:27:30 PM
   User: farrms_admin
   Server: ACER_ASPIRE\INSTANCE1
   Database: TRMTracker_Essent_Clean
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
ALTER TABLE dbo.forecast_profile
	DROP CONSTRAINT FK_forecast_profile_static_data_value
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_forecast_profile
	(
	profile_id int NOT NULL IDENTITY (1, 1),
	external_id varchar(50) NOT NULL,
	profile_type int NOT NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL,
	available bit NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_forecast_profile ON
GO
IF EXISTS(SELECT * FROM dbo.forecast_profile)
	 EXEC('INSERT INTO dbo.Tmp_forecast_profile (profile_id, external_id, profile_type, create_user, create_ts, update_user, update_ts, available)
		SELECT profile_id, external_id, profile_type, create_user, create_ts, update_user, update_ts, available FROM dbo.forecast_profile WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_forecast_profile OFF
GO
DROP TABLE dbo.forecast_profile
GO
EXECUTE sp_rename N'dbo.Tmp_forecast_profile', N'forecast_profile', 'OBJECT' 
GO
ALTER TABLE dbo.forecast_profile ADD CONSTRAINT
	FK_forecast_profile_static_data_value FOREIGN KEY
	(
	profile_type
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO


IF NOT EXISTS (
	SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'forecast_profile'
		AND c.name = 'profile_name'
)
ALTER TABLE forecast_profile ADD profile_name VARCHAR(50)


COMMIT
