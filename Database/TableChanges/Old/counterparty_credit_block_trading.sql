
CREATE TABLE [dbo].[counterparty_credit_block_trading](
	[counterparty_credit_block_id] [int] IDENTITY(1,1) NOT NULL,
	[counterparty_credit_info_id] [int] NOT NULL,
	[comodity_id] [int] NOT NULL,
	[deal_type_id] [int] NOT NULL,
 CONSTRAINT [PK_counterparty_credit_block_trading] PRIMARY KEY CLUSTERED 
(
	[counterparty_credit_block_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[counterparty_credit_block_trading]  WITH CHECK ADD  CONSTRAINT [FK_counterparty_credit_block_trading_counterparty_credit_info] FOREIGN KEY([counterparty_credit_info_id])
REFERENCES [dbo].[counterparty_credit_info] ([counterparty_credit_info_id])
GO
ALTER TABLE [dbo].[counterparty_credit_block_trading] CHECK CONSTRAINT [FK_counterparty_credit_block_trading_counterparty_credit_info]
GO
ALTER TABLE [dbo].[counterparty_credit_block_trading]  WITH CHECK ADD  CONSTRAINT [FK_counterparty_credit_block_trading_source_commodity] FOREIGN KEY([comodity_id])
REFERENCES [dbo].[source_commodity] ([source_commodity_id])
GO
ALTER TABLE [dbo].[counterparty_credit_block_trading] CHECK CONSTRAINT [FK_counterparty_credit_block_trading_source_commodity]
GO
ALTER TABLE [dbo].[counterparty_credit_block_trading]  WITH CHECK ADD  CONSTRAINT [FK_counterparty_credit_block_trading_source_deal_type] FOREIGN KEY([deal_type_id])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
GO
ALTER TABLE [dbo].[counterparty_credit_block_trading] CHECK CONSTRAINT [FK_counterparty_credit_block_trading_source_deal_type]