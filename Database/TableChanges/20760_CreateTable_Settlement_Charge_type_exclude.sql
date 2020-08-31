SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[settlement_charge_type_exclude]', N'U') IS  NULL
BEGIN

	CREATE TABLE [dbo].[settlement_charge_type_exclude](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[charge_type_id] [int] NOT NULL,
		[counterparty_id] [int] NULL,
		[internal_counterparty_id] [int] NULL,
		[contract_id] [int] NULL,
		[commodity_id] [int] NULL,
		[deal_type_id] [int] NULL,
		[deal_sub_type_id] [int] NULL,
		[internal_deal_type_id] [int] NULL,
		[internal_deal_sub_type_id] [int] NULL,
		[product_id] [int] NULL,
		[pricing_type] [int] NULL,
		[create_ts] [datetime] NULL DEFAULT (getdate()),
		[create_user] [varchar](50) NULL DEFAULT ([dbo].[FNADBUser]()),
		[update_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL
	)
END
	

	SET ANSI_PADDING OFF
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([charge_type_id])
	REFERENCES [dbo].[static_data_value] ([value_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([commodity_id])
	REFERENCES [dbo].[source_commodity] ([source_commodity_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([contract_id])
	REFERENCES [dbo].[contract_group] ([contract_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([counterparty_id])
	REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([deal_type_id])
	REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([deal_sub_type_id])
	REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([internal_counterparty_id])
	REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([internal_deal_type_id])
	REFERENCES [dbo].[internal_deal_type_subtype_types] ([internal_deal_type_subtype_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([internal_deal_sub_type_id])
	REFERENCES [dbo].[internal_deal_type_subtype_types] ([internal_deal_type_subtype_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([pricing_type])
	REFERENCES [dbo].[static_data_value] ([value_id])
	GO

	ALTER TABLE [dbo].[settlement_charge_type_exclude]  WITH CHECK ADD FOREIGN KEY([product_id])
	REFERENCES [dbo].[static_data_value] ([value_id])
	GO


