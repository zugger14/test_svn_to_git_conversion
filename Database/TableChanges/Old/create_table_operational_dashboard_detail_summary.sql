
/****** Object:  Table [dbo].[operational_dashboard_detail]    Script Date: 11/11/2015 3:49:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[operational_dashboard_detail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[operational_dashboard_detail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL,
	[location_id] [int] NULL,
	[term_date] [datetime] NULL,
	[hr] [varchar](5) NULL,
	[term_hr] [datetime] NULL,
	[volume] [float] NULL,
	[price] [float] NULL,
	[status] [float] NULL,
	[order_id] [int] NOT NULL,
	[udf_time_series_id] [int] NULL,
	[tot_sales] [numeric](38, 20) NULL,
	[min_cap_vol] [float] NULL,
	[max_cap_vol] [float] NULL,
	[remaining_cap_volume] [float] NULL,
	[running_sum_cap_vol] [numeric](12, 0) NULL,
	[tot_cap_vol] [numeric](12, 0) NULL,
	[MMBTU_required] [numeric](12, 0) NULL,
	[fuel_om] [numeric](12, 0) NULL,
	[mwh] [numeric](12, 0) NULL,
	[MMBTU_required1] [numeric](12, 0) NULL,
	[fuel_om1] [numeric](12, 0) NULL,
	[mwh1] [numeric](12, 0) NULL,
	[total_cost] [numeric](12, 0) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
 CONSTRAINT [PK_operational_dashboard_detail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[operational_dashboard_summary]    Script Date: 11/11/2015 3:49:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[operational_dashboard_summary]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[operational_dashboard_summary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[row_id] [int] NOT NULL,
	[group1] [varchar](500) NULL,
	[group2] [varchar](500) NULL,
	[deal_id] [varchar](100) NULL,
	[ref_id] [int] NULL,
	[term_dt] [datetime] NULL,
	[value] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__operation__creat__3FB2DA6E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[operational_dashboard_detail] ADD  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__operation__creat__40A6FEA7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[operational_dashboard_detail] ADD  DEFAULT (getdate()) FOR [create_ts]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__operation__creat__419B22E0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[operational_dashboard_summary] ADD  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__operation__creat__428F4719]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[operational_dashboard_summary] ADD  DEFAULT (getdate()) FOR [create_ts]
END

GO

IF COL_LENGTH(N'[operational_dashboard_summary]', 'is_dst') IS NULL
BEGIN
	ALTER TABLE operational_dashboard_summary ADD is_dst INT
END

GO

IF COL_LENGTH(N'[operational_dashboard_detail]', 'is_dst') IS NULL
BEGIN
	ALTER TABLE  operational_dashboard_detail ADD is_dst INT
END

