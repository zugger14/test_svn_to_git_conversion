
/****** Object:  Table [dbo].[stage_fx_exposure]    Script Date: 06/21/2012 11:27:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[fx_exposure_arch1]', N'U') IS NULL

CREATE TABLE [dbo].[fx_exposure_arch1](
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[exp_side] [varchar](10) NOT NULL,
	[phy_fin] [varchar](1) NOT NULL,
	[curve_id] [int] NOT NULL,
	[monthly_term] [datetime] NOT NULL,
	[volume] [float] NULL,
	[volume_uom_id] [int] NULL,
	[uom_conv_factor] [int] NULL,
	[curve_value] [float] NULL,
	[fx_exposure] [float] NULL,
	[currency_id] [int] NOT NULL,
	[price_uom_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL
) 

GO

SET ANSI_PADDING OFF
GO


---arch2 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[fx_exposure_arch2]', N'U') IS NULL

CREATE TABLE [dbo].[fx_exposure_arch2](
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[exp_side] [varchar](10) NOT NULL,
	[phy_fin] [varchar](1) NOT NULL,
	[curve_id] [int] NOT NULL,
	[monthly_term] [datetime] NOT NULL,
	[volume] [float] NULL,
	[volume_uom_id] [int] NULL,
	[uom_conv_factor] [int] NULL,
	[curve_value] [float] NULL,
	[fx_exposure] [float] NULL,
	[currency_id] [int] NOT NULL,
	[price_uom_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL
) 

GO

SET ANSI_PADDING OFF
GO
