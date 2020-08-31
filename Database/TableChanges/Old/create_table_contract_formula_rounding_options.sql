

/****** Object:  Table [dbo].[contract_formula_rounding_options]    Script Date: 06/21/2011 22:40:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[contract_formula_rounding_options]') AND type in (N'U'))
DROP TABLE [dbo].[contract_formula_rounding_options]
GO

/****** Object:  Table [dbo].[contract_formula_rounding_options]    Script Date: 06/21/2011 22:40:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[contract_formula_rounding_options](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[contract_id] [int] NOT NULL,
	[curve_id] INT NOT NULL,
	[index_round_value] [int] NULL,
	[fx_round_value] [int] NULL,
	[total_round_value] [int] NULL,
 CONSTRAINT [PK_contract_formula_rounding_options] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


