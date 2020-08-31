IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_counterparty] FOREIGN KEY([counterparty_id_from])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_counterparty1]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_counterparty1] FOREIGN KEY([counterparty_id_to])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_system_book_map]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_system_book_map] FOREIGN KEY([source_book_mapping_id_from])
REFERENCES [dbo].[source_system_book_map] ([book_deal_type_map_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_system_book_map1]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_system_book_map1] FOREIGN KEY([source_book_mapping_id_to])
REFERENCES [dbo].[source_system_book_map] ([book_deal_type_map_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_traders]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_traders] FOREIGN KEY([trader_id_from])
REFERENCES [dbo].[source_traders] ([source_trader_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_traders1]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_traders1] FOREIGN KEY([trader_id_to])
REFERENCES [dbo].[source_traders] ([source_trader_id])
GO