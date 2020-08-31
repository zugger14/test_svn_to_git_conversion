
/****** Object:  Table [dbo].[source_deal_delta_value]    Script Date: 09/25/2013 12:35:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_delta_value]') AND type in (N'U'))
	PRINT 'Table name already exists.'
ELSE
BEGIN	
	CREATE TABLE [dbo].[source_deal_delta_value](
		[run_date] [datetime] NULL,
		[as_of_date] [datetime] NULL,
		[source_deal_detail_id] [int] NULL,
		[source_deal_header_id] [int] NULL,
		[curve_id] [int] NULL,
		[term_start] [datetime] NOT NULL,
		[term_end] [datetime] NULL,
		[physical_financial_flag] [varchar](20) NULL,
		[counterparty_id] [int] NULL,
		[Position] [float] NULL,
		[market_value_delta] [float] NULL,
		[contract_value_delta] [float] NULL,
		[avg_value] [float] NULL,
		[delta_value] [float] NULL,
		[avg_delta_value] [float] NULL,
		[currency_id] INT REFERENCES dbo.source_currency(source_currency_id),
		[pnl_source_value_id] INT NULL
	) ON [PRIMARY]
	
	PRINT 'Table [dbo].[source_deal_delta_value] created.'

END
	
SET ANSI_PADDING OFF
GO
--drop table [dbo].[source_deal_delta_value]


