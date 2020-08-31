
/****** Object:  Table [dbo].[explain_position]    Script Date: 09/23/2012 09:59:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[price_change_value]') AND type in (N'U'))
DROP TABLE [dbo].[price_change_value]
GO



/****** Object:  Table [dbo].[explain_position]    Script Date: 09/23/2012 09:59:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[price_change_value](

	[as_of_date_from] [datetime] NULL,
	[as_of_date_to] [datetime] NULL,
	[curve_id] [int] NULL,
	[counterparty_id] [int] NULL,
	--[charge_type] [int] NULL,
	[term_start] [datetime] NULL,
	[book_deal_type_map_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[currency_id] [int] NULL,
	[tou_id] [int] NULL,
	price_change_value numeric(28,10),
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL	
	
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


