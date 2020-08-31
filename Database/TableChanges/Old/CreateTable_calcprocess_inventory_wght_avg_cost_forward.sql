USE [TRMTracker_Essent]
GO
/****** Object:  Table [dbo].[calcprocess_inventory_wght_avg_cost_forward]    Script Date: 10/10/2011 11:53:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calcprocess_inventory_wght_avg_cost_forward]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calcprocess_inventory_wght_avg_cost_forward](
	[as_of_date] [datetime] NOT NULL,
	[term_date]  [datetime] NOT NULL,
	[gl_code] [int] NULL,
	[wght_avg_cost] [float] NULL,
	[total_inventory] [float] NULL,
	[total_units] [float] NULL,
	[inventory_account_type] [varchar](100) NULL,
	[inventory_account_name] [varchar](100) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[group_id] [int] NULL,
	[gl_account_id] [int] NULL,
	[uom_id] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
