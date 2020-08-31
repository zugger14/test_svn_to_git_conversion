/****** Object:  Table [dbo].[source_price_curve_cache]    Script Date: 07/24/2012 05:26:57 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_cache]') AND type in (N'U'))
	CREATE TABLE [dbo].[source_price_curve_cache](
		[as_of_date] [datetime] NULL,
		[maturity_date] [datetime] NULL,
		[curve_id] [int] NULL,
		[curve_value] [float] NULL,
		[process_id] [varchar](100) NULL,
		[block_define_id] INT
	) ON [PRIMARY]


