
/****** Object:  Table [dbo].[deal_detail_hour_breakdown]    Script Date: 1/8/2016 2:40:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_detail_hour_breakdown]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
 BEGIN
	CREATE TABLE [dbo].[deal_detail_hour_breakdown](
		[term_date] [datetime] NULL,
		[profile_id] [int] NULL,
		[Volume] [numeric](38, 20) NULL,
		[create_ts] [datetime] NULL DEFAULT (getdate()),
		[create_user] [varchar](20) NULL DEFAULT ([dbo].[fnadbUser]())
	)

	

END
