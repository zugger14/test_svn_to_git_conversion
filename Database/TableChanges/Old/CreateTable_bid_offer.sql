/****** Object:  Table [dbo].[bid_offer]    Script Date: 07/12/2009 15:51:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bid_offer]') AND type in (N'U'))
DROP TABLE [dbo].[bid_offer]
/****** Object:  Table [dbo].[bid_offer]    Script Date: 07/12/2009 15:51:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bid_offer](
	[bid_offer_id] [int] IDENTITY(1,1) NOT NULL,
	[location_id] [int] NOT NULL,
	[offer_date] [datetime] NOT NULL,
	[offer_hour] [int] NOT NULL,
	[volume1] [float] NULL,
	[price1] [float] NULL,
	[volume2] [float] NULL,
	[price2] [float] NULL,
	[volume3] [float] NULL,
	[price3] [float] NULL,
	[volume4] [float] NULL,
	[price4] [float] NULL,
	[volume5] [float] NULL,
	[price5] [float] NULL,
	[volume6] [float] NULL,
	[price6] [float] NULL,
	[volume7] [float] NULL,
	[price7] [float] NULL,
	[volume8] [float] NULL,
	[price8] [float] NULL,
	[volume9] [float] NULL,
	[price9] [float] NULL,
	[volume10] [float] NULL,
	[price10] [float] NULL,
 CONSTRAINT [PK_bid_offer] PRIMARY KEY CLUSTERED 
(
	[bid_offer_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
