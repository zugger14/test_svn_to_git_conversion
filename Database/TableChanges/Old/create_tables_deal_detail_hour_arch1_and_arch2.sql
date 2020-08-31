BEGIN TRAN

/*
* Setup archive data for Load Forecast Data (deal_detail_hour).
* Step 1: Create archives tables in destination server (server pointed by linked server FARRMSData).
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create archive table
IF OBJECT_ID(N'deal_detail_hour_arch1', N'U') IS NULL
BEGIN
	CREATE TABLE [deal_detail_hour_arch1](
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

IF OBJECT_ID(N'deal_detail_hour_arch2', N'U') IS NULL
BEGIN
	CREATE TABLE [deal_detail_hour_arch2](
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

ROLLBACK