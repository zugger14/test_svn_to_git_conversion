IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_confirmation_rule]') AND type in (N'U'))
CREATE TABLE [dbo].[deal_confirmation_rule]
(
	rule_id INT,
	counterparty_id INT NOT NULL,
	buy_sell_flag CHAR(1),
	commodity_id INT,
	contract_id INT,
	deal_type_id INT, 
	confirm_template_id INT,
	revision_confirm_template_id INT, 
	CONSTRAINT [PK_deal_confirmation_rule] PRIMARY KEY CLUSTERED 
	(
		[rule_id] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_confirmation_rule_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_confirmation_rule]'))
ALTER TABLE [dbo].[deal_confirmation_rule] ADD CONSTRAINT [FK_deal_confirmation_rule_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_confirmation_rule_source_commodity]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_confirmation_rule]'))
ALTER TABLE [dbo].[deal_confirmation_rule] ADD CONSTRAINT [FK_deal_confirmation_rule_source_commodity] FOREIGN KEY([commodity_id])
REFERENCES [dbo].[source_commodity] ([source_commodity_id])
GO 

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_confirmation_rule_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_confirmation_rule]'))
ALTER TABLE [dbo].[deal_confirmation_rule] ADD CONSTRAINT [FK_deal_confirmation_rule_contract_group] FOREIGN KEY([contract_id])
REFERENCES [dbo].[contract_group] ([contract_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_confirmation_rule_source_deal_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_confirmation_rule]'))
ALTER TABLE [dbo].[deal_confirmation_rule] ADD CONSTRAINT [FK_deal_confirmation_rule_source_deal_type] FOREIGN KEY([deal_type_id])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
GO 