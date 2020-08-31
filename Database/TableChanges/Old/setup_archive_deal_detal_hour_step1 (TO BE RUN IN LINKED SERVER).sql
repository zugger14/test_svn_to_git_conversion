/*
* Setup archive data for Load Forecast Data (deal_detail_hour).
* Step 1: Create archives tables in destination server (server pointed by linked server FARRMSData).
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create archive table
IF OBJECT_ID(N'adiha_process.dbo.deal_detail_hour_arch1', N'U') IS NULL
BEGIN
	CREATE TABLE adiha_process.dbo.deal_detail_hour_arch1(
		[term_date] [datetime] NOT NULL,
		[profile_id] [int] NULL,
		[Hr1] [float] NULL,
		[Hr2] [float] NULL,
		[Hr3] [float] NULL,
		[Hr4] [float] NULL,
		[Hr5] [float] NULL,
		[Hr6] [float] NULL,
		[Hr7] [float] NULL,
		[Hr8] [float] NULL,
		[Hr9] [float] NULL,
		[Hr10] [float] NULL,
		[Hr11] [float] NULL,
		[Hr12] [float] NULL,
		[Hr13] [float] NULL,
		[Hr14] [float] NULL,
		[Hr15] [float] NULL,
		[Hr16] [float] NULL,
		[Hr17] [float] NULL,
		[Hr18] [float] NULL,
		[Hr19] [float] NULL,
		[Hr20] [float] NULL,
		[Hr21] [float] NULL,
		[Hr22] [float] NULL,
		[Hr23] [float] NULL,
		[Hr24] [float] NULL,
		[Hr25] [float] NULL,
		[partition_value] [int] NULL
	)
END

IF OBJECT_ID(N'adiha_process.dbo.deal_detail_hour_arch2', N'U') IS NULL
BEGIN
	CREATE TABLE adiha_process.dbo.deal_detail_hour_arch2(
		[term_date] [datetime] NOT NULL,
		[profile_id] [int] NULL,
		[Hr1] [float] NULL,
		[Hr2] [float] NULL,
		[Hr3] [float] NULL,
		[Hr4] [float] NULL,
		[Hr5] [float] NULL,
		[Hr6] [float] NULL,
		[Hr7] [float] NULL,
		[Hr8] [float] NULL,
		[Hr9] [float] NULL,
		[Hr10] [float] NULL,
		[Hr11] [float] NULL,
		[Hr12] [float] NULL,
		[Hr13] [float] NULL,
		[Hr14] [float] NULL,
		[Hr15] [float] NULL,
		[Hr16] [float] NULL,
		[Hr17] [float] NULL,
		[Hr18] [float] NULL,
		[Hr19] [float] NULL,
		[Hr20] [float] NULL,
		[Hr21] [float] NULL,
		[Hr22] [float] NULL,
		[Hr23] [float] NULL,
		[Hr24] [float] NULL,
		[Hr25] [float] NULL,
		[partition_value] [int] NULL
	)
END
GO

IF COL_LENGTH('adiha_process.dbo.deal_detail_hour_arch1', 'file_name') IS NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ADD [file_name] VARCHAR(200)
GO

IF COL_LENGTH('deal_detail_hour_arch2', 'file_name') IS NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ADD [file_name] VARCHAR(200)
GO


IF OBJECT_ID('adiha_process.dbo.deal_detail_hour_arch1') IS NOT NULL
BEGIN
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr1] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr2] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr3] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr4] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr5] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr6] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr7] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr8] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr9] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr10] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr11] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr12] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr13] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr14] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr15] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr16] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr17] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr18] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr19] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr20] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr21] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr22] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr23] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr24] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch1 ALTER column	[hr25] numeric(38,20) NULL
END

IF object_id('adiha_process.dbo.deal_detail_hour_arch2') IS NOT NULL
BEGIN
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr1] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr2] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr3] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr4] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr5] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr6] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr7] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr8] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr9] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr10] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr11] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr12] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr13] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr14] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr15] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr16] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr17] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr18] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr19] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr20] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr21] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr22] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr23] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr24] numeric(38,20) NULL
	ALTER TABLE adiha_process.dbo.deal_detail_hour_arch2 ALTER column	[hr25] numeric(38,20) NULL
END

GO 




	