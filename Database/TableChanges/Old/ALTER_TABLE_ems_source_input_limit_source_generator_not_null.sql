ALTER TABLE ems_source_input_limit ALTER COLUMN source_generator_id INT NULL


IF OBJECT_ID(N'DF_ems_source_input_limit_create_user', N'D') IS NULL
	ALTER TABLE dbo.ems_source_input_limit ADD CONSTRAINT
		DF_ems_source_input_limit_create_user DEFAULT ([dbo].[FNADBUser]()) FOR create_user
GO

IF OBJECT_ID(N'DF_ems_source_input_limit_create_ts', N'D') IS NULL
	ALTER TABLE dbo.ems_source_input_limit ADD CONSTRAINT
		DF_ems_source_input_limit_create_ts DEFAULT GETDATE() FOR create_ts
GO


ALTER TABLE ems_source_input_limit ALTER COLUMN update_user VARCHAR(50) NULL
ALTER TABLE ems_source_input_limit ALTER COLUMN update_ts datetime NULL

