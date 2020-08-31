
IF OBJECT_ID(N'[dbo].source_price_curve_arch1', N'U') IS NOT NULL
	DROP TABLE [dbo].[source_price_curve_arch1]

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
 CONSTRAINT [PK_source_price_curve_arch1] PRIMARY KEY NONCLUSTERED 
(
	[source_curve_def_id] ASC,
	[as_of_date] ASC,
	[Assessment_curve_type_value_id] ASC,
	[curve_source_value_id] ASC,
	[maturity_date] ASC,
	[is_dst] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[source_price_curve_arch1] ADD  CONSTRAINT [DF_source_price_curve_is_dst_arch1]  DEFAULT ((0)) FOR [is_dst]
GO

IF OBJECT_ID(N'[dbo].deal_detail_hour_arch1', N'U') IS NOT NULL
	DROP TABLE [dbo].[deal_detail_hour_arch1]

CREATE TABLE [dbo].[deal_detail_hour_arch1](
	[term_date] [datetime] NOT NULL,
	[profile_id] [int] NULL,
	[Hr1] [numeric](38, 20) NULL,
	[Hr2] [numeric](38, 20) NULL,
	[Hr3] [numeric](38, 20) NULL,
	[Hr4] [numeric](38, 20) NULL,
	[Hr5] [numeric](38, 20) NULL,
	[Hr6] [numeric](38, 20) NULL,
	[Hr7] [numeric](38, 20) NULL,
	[Hr8] [numeric](38, 20) NULL,
	[Hr9] [numeric](38, 20) NULL,
	[Hr10] [numeric](38, 20) NULL,
	[Hr11] [numeric](38, 20) NULL,
	[Hr12] [numeric](38, 20) NULL,
	[Hr13] [numeric](38, 20) NULL,
	[Hr14] [numeric](38, 20) NULL,
	[Hr15] [numeric](38, 20) NULL,
	[Hr16] [numeric](38, 20) NULL,
	[Hr17] [numeric](38, 20) NULL,
	[Hr18] [numeric](38, 20) NULL,
	[Hr19] [numeric](38, 20) NULL,
	[Hr20] [numeric](38, 20) NULL,
	[Hr21] [numeric](38, 20) NULL,
	[Hr22] [numeric](38, 20) NULL,
	[Hr23] [numeric](38, 20) NULL,
	[Hr24] [numeric](38, 20) NULL,
	[Hr25] [numeric](38, 20) NULL,
	[partition_value] [int] NULL,
	[FILE_NAME] [varchar](200) NULL,
	[create_ts] [datetime] NULL,
	[period] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[deal_detail_hour_arch1] SET (LOCK_ESCALATION = AUTO)
GO
ALTER TABLE [dbo].[deal_detail_hour_arch1] ADD  DEFAULT (getdate()) FOR [create_ts]

