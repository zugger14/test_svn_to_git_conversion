
/****** Object:  Table [dbo].[index_fees_breakdown]    Script Date: 08/31/2011 15:19:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[index_fees_breakdown]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[index_fees_breakdown](
	[index_fees_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[leg] [int] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[field_id] [int] NULL,
	[field_name] [varchar](100) NULL,
	[price] [float] NULL,
	[total_price] [float] NULL,
	[volume] [float] NULL,
	[value] [float] NULL,
	[contract_value] [float] NULL,
	[internal_type] [int] NULL,
	[tab_group_name] [int] NULL,
	[udf_group_name] [int] NULL,
	[sequence] [int] NULL,
	[fee_currency_id] [int] NULL,
	[currency_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
 CONSTRAINT [PK_index_fees_breakdown] PRIMARY KEY CLUSTERED 
(
	[index_fees_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[index_fees_breakdown]') AND name = N'IX_index_fees_breakdown')
CREATE UNIQUE NONCLUSTERED INDEX [IX_index_fees_breakdown] ON [dbo].[index_fees_breakdown] 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[field_id] ASC,
	[leg] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
