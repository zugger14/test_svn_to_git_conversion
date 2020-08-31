/****** Object:  Table [dbo].[deal_calc_cashflow_earnings]    Script Date: 07/22/2010 15:53:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_calc_cashflow_earnings_detail]') AND type in (N'U'))
DROP TABLE [dbo].[deal_calc_cashflow_earnings_detail]
GO
/****** Object:  Table [dbo].[deal_calc_cashflow_earnings]    Script Date: 07/22/2010 15:53:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_calc_cashflow_earnings_detail](
	[casflow_earnings_detail_id] INT IDENTITY(1,1) NOT NULL,
	[formula_id] INT,
	[sequence_number] INT,
	[as_of_date] DATETIME,
	[deal_id] INT,
	[term_start] DATETIME,
	[leg] INT,
	[formula_str]VARCHAR(5000),
	[value] NUMERIC(38, 20),
 CONSTRAINT [PK_deal_calc_cashflow_earnings_detail] PRIMARY KEY CLUSTERED 
(
	[casflow_earnings_detail_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
