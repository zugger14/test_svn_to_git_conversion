/****** Object:  Table [dbo].[invoice_cash_received]    Script Date: 01/01/2009 17:08:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
drop TABLE [dbo].[invoice_cash_received]
go

CREATE TABLE [dbo].[invoice_cash_received](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[save_invoice_detail_id] [int] NOT NULL,
	[received_date] [datetime] NOT NULL,
	[cash_received] [float] NOT NULL,
	[comments] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[invoice_cash_received]  WITH CHECK ADD  CONSTRAINT [FK_invoice_cash_received_save_invoice_detail] FOREIGN KEY([save_invoice_detail_id])
REFERENCES [dbo].[save_invoice_detail] ([save_invoice_detail_id])