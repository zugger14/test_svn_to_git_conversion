/****** Object:  Table [dbo].[deal_calc_cashflow_earnings]    Script Date: 07/22/2010 15:53:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_calc_cashflow_earnings]') AND type in (N'U'))
DROP TABLE [dbo].[deal_calc_cashflow_earnings]
GO
/****** Object:  Table [dbo].[deal_calc_cashflow_earnings]    Script Date: 07/22/2010 15:53:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_calc_cashflow_earnings](
	[casflow_earnings_id] INT IDENTITY(1,1) NOT NULL,
	[as_of_date] DATETIME NULL,
	[source_deal_header_id] INT NULL,
	[term_start] DATETIME NULL,
	[term_end] DATETIME NULL,
	[model_type] INT NULL,
	[value] NUMERIC(38,20) NULL,
 CONSTRAINT [PK_deal_calc_cashflow_earnings] PRIMARY KEY CLUSTERED 
(
	[casflow_earnings_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
