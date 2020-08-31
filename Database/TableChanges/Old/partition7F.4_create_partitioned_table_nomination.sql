
/****** Object:  Table [dbo].[deal_detail_hour]    Script Date: 05/23/2012 02:14:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SP_RENAME deal_detail_hour , deal_detail_hour_non_part

IF OBJECT_ID(N'[dbo].[deal_detail_hour]', N'U') IS NULL
CREATE TABLE [dbo].[deal_detail_hour](
	[term_date]			DATETIME   NOT NULL,
	[profile_id]		INT  NULL,
	[Hr1]				NUMERIC (38, 20) NULL,
	[Hr2]				NUMERIC (38, 20) NULL,
	[Hr3]				NUMERIC (38, 20) NULL,
	[Hr4]				NUMERIC (38, 20) NULL,
	[Hr5]				NUMERIC (38, 20) NULL,
	[Hr6]				NUMERIC (38, 20) NULL,
	[Hr7]				NUMERIC (38, 20) NULL,
	[Hr8]				NUMERIC (38, 20) NULL,
	[Hr9]				NUMERIC (38, 20) NULL,
	[Hr10]				NUMERIC (38, 20) NULL,
	[Hr11]				NUMERIC (38, 20) NULL,
	[Hr12]				NUMERIC (38, 20) NULL,
	[Hr13]				NUMERIC (38, 20) NULL,
	[Hr14]				NUMERIC (38, 20) NULL,
	[Hr15]				NUMERIC (38, 20) NULL,
	[Hr16]				NUMERIC (38, 20) NULL,
	[Hr17]				NUMERIC (38, 20) NULL,
	[Hr18]				NUMERIC (38, 20) NULL,
	[Hr19]				NUMERIC (38, 20) NULL,
	[Hr20]				NUMERIC (38, 20) NULL,
	[Hr21]				NUMERIC (38, 20) NULL,
	[Hr22]				NUMERIC (38, 20) NULL,
	[Hr23]				NUMERIC (38, 20) NULL,
	[Hr24]				NUMERIC (38, 20) NULL,
	[Hr25]				NUMERIC (38, 20) NULL,
	[partition_value]	INT  NULL,
	[FILE_NAME]			VARCHAR (200) NULL,
	[create_ts]			DATETIME  NULL
) ON ps_nomination(term_date)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[deal_detail_hour] SET (LOCK_ESCALATION = AUTO)
GO

ALTER TABLE [dbo].[deal_detail_hour] ADD  DEFAULT (getdate()) FOR [create_ts]
GO


INSERT INTO deal_detail_hour SELECT * FROM deal_detail_hour_non_part