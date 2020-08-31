/****** Object:  Table [dbo].[contract_formula_rounding]    Script Date: 07/24/2011 22:29:48 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[contract_formula_rounding]') AND type in (N'U'))

	CREATE TABLE [dbo].[contract_formula_rounding](
		[contract_id] [int] NULL,
		[formula_currency] [int] NULL,
		[formula_rounding] [int] NULL
	) ON [PRIMARY]

GO


