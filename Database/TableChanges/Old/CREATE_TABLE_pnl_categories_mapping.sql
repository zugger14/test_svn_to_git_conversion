/****** Object:  Table [dbo].[pnl_categories_mapping]    Script Date: 06/06/2012 21:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pnl_categories_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pnl_categories_mapping](
	[counterparty_id] [int] NULL,
	[contract_id] [int] NULL,
	[buy_sell_flag] [char](1) NULL,
	[source_deal_type_id] [int] NULL,
	[charge_type_id] [int] NULL,
	[gl_code] [varchar](50) NULL,
	[cat1] [varchar](50) NULL,
	[cat2] [varchar](50) NULL,
	[cat3] [varchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pnl_categories_mapping]') AND name = N'IX_pnl_categories_mapping')
CREATE NONCLUSTERED INDEX [IX_pnl_categories_mapping] ON [dbo].[pnl_categories_mapping] 
(
	[counterparty_id] ASC,
	[buy_sell_flag] ASC,
	[charge_type_id] ASC,
	[contract_id] ASC,
	[source_deal_type_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
