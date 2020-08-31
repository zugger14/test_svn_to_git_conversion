GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[st_forecast_hour]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[st_forecast_hour](
	[st_forecast_hour_id] [INT] IDENTITY(1,1) NOT NULL,
	[st_forecast_group_id] [INT] NOT NULL,
	[term_start] DATETIME,
	[Hr1] NUMERIC(38,20),
	[Hr2] NUMERIC(38,20),
	[Hr3] NUMERIC(38,20),
	[Hr4] NUMERIC(38,20),
	[Hr5] NUMERIC(38,20),
	[Hr6] NUMERIC(38,20),
	[Hr7] NUMERIC(38,20),
	[Hr8] NUMERIC(38,20),
	[Hr9] NUMERIC(38,20),
	[Hr10] NUMERIC(38,20),
	[Hr11] NUMERIC(38,20),
	[Hr12] NUMERIC(38,20),
	[Hr13] NUMERIC(38,20),
	[Hr14] NUMERIC(38,20),
	[Hr15] NUMERIC(38,20),
	[Hr16] NUMERIC(38,20),
	[Hr17] NUMERIC(38,20),
	[Hr18] NUMERIC(38,20),
	[Hr19] NUMERIC(38,20),
	[Hr20] NUMERIC(38,20),
	[Hr21] NUMERIC(38,20),
	[Hr22] NUMERIC(38,20),
	[Hr23] NUMERIC(38,20),
	[Hr24] NUMERIC(38,20),
	[Hr25] NUMERIC(38,20),
	[create_user] VARCHAR(30) DEFAULT dbo.FNADBUser() NULL,
	[create_ts] DATETIME DEFAULT GETDATE() NULL,
	[update_user] VARCHAR(30),
	[update_ts] VARCHAR(30)
	
) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table st_forecast_hour already EXISTS'
END

SET ANSI_PADDING OFF
GO