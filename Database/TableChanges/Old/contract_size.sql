/****** Object:  Table [dbo].[contract_size]    Script Date: 01/15/2009 14:41:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[contract_size]') AND type in (N'U'))
DROP TABLE [dbo].[contract_size]
GO

CREATE TABLE [dbo].[contract_size](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[contract_id] [int] NOT NULL,
	[counterparty_id] [int] NOT NULL,
	[commodity_id] [int] NOT NULL,
	[volume] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom_id] [int] NOT NULL,
 CONSTRAINT [PK_contract_size] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[contract_size]  WITH CHECK ADD  CONSTRAINT [FK_contract_size_contract_group] FOREIGN KEY([contract_id])
REFERENCES [dbo].[contract_group] ([contract_id])
GO
ALTER TABLE [dbo].[contract_size]  WITH CHECK ADD  CONSTRAINT [FK_contract_size_source_commodity] FOREIGN KEY([commodity_id])
REFERENCES [dbo].[source_commodity] ([source_commodity_id])
GO
ALTER TABLE [dbo].[contract_size]  WITH CHECK ADD  CONSTRAINT [FK_contract_size_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO
ALTER TABLE [dbo].[contract_size]  WITH CHECK ADD  CONSTRAINT [FK_contract_size_source_uom] FOREIGN KEY([uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])