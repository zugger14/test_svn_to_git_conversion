
/****** Object:  Table [dbo].[hedge_deferral_values]    Script Date: 09/07/2011 14:29:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hedge_deferral_values]') AND type in (N'U'))
DROP TABLE [dbo].[hedge_deferral_values]
GO

/****** Object:  Table [dbo].[hedge_deferral_values]    Script Date: 09/07/2011 14:29:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[hedge_deferral_values](
	[as_of_date] [datetime] NOT NULL,
	[set_type] [varchar](1) NOT NULL,
	[eff_test_profile_id] [int] NULL,
	[source_deal_header_id] [int] NOT NULL,
	[cash_flow_term] [datetime] NOT NULL,
	[pnl_term] [datetime] NOT NULL,
	[strip_from] [int] NULL,
	[lag] [int] NULL,
	[strip_to] [int] NULL,
	[und_mtm] [float] NULL,
	[dis_mtm] [float] NULL,
	[und_pnl] [float] NULL,
	[dis_pnl] [float] NULL,
	[per_alloc] [float] NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](50) NULL,
 CONSTRAINT [PK_hedge_deferral_values] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[set_type] ASC,
	[source_deal_header_id] ASC,
	[cash_flow_term] ASC,
	[pnl_term] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


