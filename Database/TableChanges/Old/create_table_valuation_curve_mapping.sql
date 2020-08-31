GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[valuation_curve_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[valuation_curve_mapping]
go

CREATE TABLE [dbo].[valuation_curve_mapping](
	[valuation_curve_mapping_id] [INT]  IDENTITY(1,1),
	[commodity_id] [INT] NULL,
	[country] [INT] NULL,
	[book_id] [INT] NULL,
	[region] [INT],
	[grid] [INT],
	[forward_curve] INT,
	[spot_price_curve] INT,
	[imbalance_curve] INT,
	[create_user] [VARCHAR](50) NULL DEFAULT([dbo].[FNADBUser]()),
	[create_ts] [DATETIME] NULL DEFAULT(GETDATE()),
	[update_user] [VARCHAR] (50) NULL,
	[update_ts] DATETIME NULL
	
) ON [PRIMARY]

SET ANSI_PADDING OFF
GO

