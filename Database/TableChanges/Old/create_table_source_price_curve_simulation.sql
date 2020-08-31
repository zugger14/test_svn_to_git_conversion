if OBJECT_ID('[source_price_curve_simulation]') is null
CREATE TABLE [dbo].[source_price_curve_simulation](
	run_date date,
	[source_curve_def_id] [int] NOT NULL,
	[as_of_date] date NOT NULL,
	[Assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[curve_value] [float] NOT NULL,
	[bid_value] [float] NULL,
	[ask_value] [float] NULL,
	[is_dst] [tinyint] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL
)

GO
