/****** Object:  Table [dbo].[fx_exposure]    Script Date: 07/24/2011 21:41:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fx_exposure]') AND type in (N'U'))
DROP TABLE [dbo].[fx_exposure]
GO

/****** Object:  Table [dbo].[fx_exposure]    Script Date: 07/24/2011 15:53:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[fx_exposure](
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[exp_side] [varchar](10) NOT NULL,
	[phy_fin] [varchar](1) NOT NULL,
	[curve_id] [int] NOT NULL,
	[monthly_term] [datetime] NOT NULL,
	[volume] [float] NULL,
	[volume_uom_id] INT NULL,
	[uom_conv_factor] [int] NULL,
	[curve_value] [float] NULL,
	[fx_exposure] [float] NULL,
	[currency_id] [int] NOT NULL,
	[price_uom_id] INT NULL,
	[create_user] varchar(50) NULL,
	[create_ts] datetime NULL,
 CONSTRAINT [PK_fx_exposure] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[exp_side] ASC,
	[phy_fin] ASC,
	[curve_id] ASC,
	[monthly_term] ASC,
	[currency_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


