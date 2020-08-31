SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[source_price_percentile_delta]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[source_price_percentile_delta](
	[source_price_percentile_id] [int] IDENTITY(1,1) NOT NULL,
	[run_date] [date] NOT NULL,
	[source_curve_def_id] [int] NOT NULL,
	[percentile] [int] NULL,
	[as_of_date] [date] NULL,
	[assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[is_dst] [tinyint] NOT NULL,
	[curve_value_main] [float] NULL,
	[curve_value_sim] [float] NULL,
	[curve_value_avg] [float] NULL,
	[curve_value_delta] [float] NULL,
	[curve_value_avg_delta] [float] NULL,
	[create_user] [varchar](100) NOT NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](100) NULL,
	[update_ts] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[source_price_percentile_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[source_price_percentile_delta] ADD  CONSTRAINT [DF_source_price_percentile_delta_create_user]  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]

ALTER TABLE [dbo].[source_price_percentile_delta] ADD  CONSTRAINT [DF_source_price_percentile_delta_create_ts]  DEFAULT (getdate()) FOR [create_ts]

END

