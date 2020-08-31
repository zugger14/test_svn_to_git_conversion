/****** Object:  Table [dbo].[calc_invoice_summary]    Script Date: 12/16/2008 17:14:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP TABLE [dbo].[calc_invoice_summary]
GO

CREATE TABLE [dbo].[calc_invoice_summary](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[formula_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[seq_number] [int] NULL,
	[prod_date] [datetime] NULL,
	[as_of_date] [datetime] NULL,
	[value] [float] NULL,
	[counterparty_id] [int] NULL,
	[contract_id] [int] NULL,
	[calc_id] [int] NULL,
 CONSTRAINT [PK_calc_invoice_summary] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[calc_invoice_summary]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_summary_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE