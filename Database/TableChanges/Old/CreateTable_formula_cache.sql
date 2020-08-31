/****** Object:  Table [dbo].[formula_cache]    Script Date: 03/16/2011 13:05:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[formula_cache]') AND type in (N'U'))
DROP TABLE [dbo].[formula_cache]
/****** Object:  Table [dbo].[formula_cache]    Script Date: 03/16/2011 13:05:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[formula_cache](
	[curve_id] [int] NULL,
	[curve_source_id] [int] NULL,
	[as_of_date] [datetime] NULL,
	[term_date] DATETIME NULL,
	[relative_year] [int] NULL,
	[strip_month_from] [int] NULL,
	[lag_months] [int] NULL,
	[strip_month_to] [int] NULL,
	[convert_to_currency] [int] NULL,
	[price_adder] [float] NULL,
	[volume_multiplier] [float] NULL,
	[formula_value] FLOAT NULL
) ON [PRIMARY]
