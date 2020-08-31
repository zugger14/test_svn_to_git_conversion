IF OBJECT_ID(N'DF_Report_record_create_ts', N'D') IS NULL
	ALTER TABLE dbo.Report_record ADD CONSTRAINT
		DF_Report_record_create_ts DEFAULT GETDATE() FOR create_ts
GO
IF OBJECT_ID(N'DF_Report_record_create_user', N'D') IS NULL
	ALTER TABLE dbo.Report_record ADD CONSTRAINT
		DF_Report_record_create_user DEFAULT dbo.FNADBUser() FOR create_user
GO
