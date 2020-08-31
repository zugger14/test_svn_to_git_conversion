IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch1]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[source_price_curve_arch1](
	[source_curve_def_id] [int] NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[Assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[curve_value] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[bid_value] [float] NULL,
	[ask_value] [float] NULL,
	[is_dst] [int] NOT NULL,
	) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[source_price_curve_arch2](
	[source_curve_def_id] [int] NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[Assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[curve_value] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[bid_value] [float] NULL,
	[ask_value] [float] NULL,
	[is_dst] [int] NOT NULL,
	) ON [PRIMARY]
END

GO