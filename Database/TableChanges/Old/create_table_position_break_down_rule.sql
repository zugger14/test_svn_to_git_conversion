
/****** Object:  Table [dbo].[position_break_down_rule]    Script Date: 11/23/2010 15:29:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[position_break_down_rule](
	[strip_from] [int] NOT NULL,
	[lag] [int] NOT NULL,
	[strip_to] [int] NOT NULL,
	[phy_month] [int] NOT NULL,
	[phy_day] [int] NOT NULL,
	[multiplier] [float] NOT NULL,
	[pricing_term] [int] NOT NULL,
 CONSTRAINT [PK_position_break_down_rule_1] PRIMARY KEY CLUSTERED 
(
	[strip_from] ASC,
	[lag] ASC,
	[strip_to] ASC,
	[phy_month] ASC,
	[phy_day] ASC,
	[pricing_term] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
