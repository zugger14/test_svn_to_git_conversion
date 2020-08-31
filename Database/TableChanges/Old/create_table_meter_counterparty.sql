GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[meter_counterparty]') AND type in (N'U'))
DROP TABLE [dbo].[meter_counterparty]
go

CREATE TABLE [dbo].[meter_counterparty](
	[meter_counterparty_id] [INT]  IDENTITY(1,1),
	[meter_id] [INT] NOT NULL,
	[counterparty_id] [INT] NULL,
	[term_start] [DATETIME] NULL,
	[term_end] [DATETIME] NULL,
	[create_user] [VARCHAR](50) NULL DEFAULT([dbo].[FNADBUser]()),
	[create_ts] [DATETIME] NULL DEFAULT(GETDATE()),
	[update_user] [VARCHAR] (50) NULL,
	[update_ts] DATETIME NULL
	
) ON [PRIMARY]

SET ANSI_PADDING OFF
GO

