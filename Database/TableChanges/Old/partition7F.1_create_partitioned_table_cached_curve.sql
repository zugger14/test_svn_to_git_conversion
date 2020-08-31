

/****** Object:  Table [dbo].[cached_curves_value]    Script Date: 06/15/2012 17:44:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SP_RENAME cached_curves_value , cached_curves_value_non_part
CREATE TABLE [dbo].[cached_curves_value](
	[Master_ROWID] [int] NULL,
	[value_type] [varchar](1) NULL,
	[term] [datetime] NULL,
	[pricing_option] [tinyint] NULL,
	[curve_value] [float] NULL,
	[org_mid_value] [float] NULL,
	[org_ask_value] [float] NULL,
	[org_bid_value] [float] NULL,
	[org_fx_value] [float] NULL,
	[as_of_date] [datetime] NULL,
	[curve_source_id] [int] NULL,
	[create_ts] [datetime] NULL,
	[bid_ask_curve_value] [float] NULL
) ON ps_cached_curve(as_of_date)

GO
INSERT INTO cached_curves_value SELECT * FROM cached_curves_value_non_part 

SET ANSI_PADDING OFF
GO


