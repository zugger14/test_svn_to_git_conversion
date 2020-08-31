/****** Object:  Table [dbo].[deal_uom_conversion_factor]    Script Date: 10/15/2014 11:25:12 AM ******/



if object_id('deal_uom_conversion_factor') is null
	CREATE TABLE [dbo].[deal_uom_conversion_factor](
		[source_deal_detail_id] [int] NULL,
		[from_uom_id] [int] NULL,
		[to_uom_id] [int] NULL,
		[conversion_factor] [float] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](30) NULL
	) ON [PRIMARY]
