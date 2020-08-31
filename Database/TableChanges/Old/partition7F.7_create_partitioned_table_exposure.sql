
/****** Object:  Table [dbo].[fx_exposure]    Script Date: 06/21/2012 11:27:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
ALTER TABLE fx_exposure
DROP CONSTRAINT PK_fx_exposure
GO
SP_RENAME fx_exposure , fx_exposure_non_part


CREATE TABLE [dbo].[fx_exposure](
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
	[create_ts] [datetime] NULL,
 CONSTRAINT [PK_fx_exposure] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[exp_side] ASC,
	[phy_fin] ASC,
	[curve_id] ASC,
	[monthly_term] ASC,
	[currency_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_FX_EXPOSURE(as_of_date)
) ON PS_fx_EXPOSURE(as_of_date)

GO

SET ANSI_PADDING OFF
GO

INSERT INTO fx_exposure SELECT * FROM fx_exposure_non_part
