
IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'IX_source_deal_pnl_details_Deal_volume_contract_value')
	DROP INDEX [IX_source_deal_pnl_details_Deal_volume_contract_value] ON [dbo].[source_deal_pnl_detail]
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'IX_source_deal_pnl_details_Deal_volume_contract_value')
	CREATE NONCLUSTERED INDEX [IX_source_deal_pnl_details_Deal_volume_contract_value] ON [dbo].[source_deal_pnl_detail] ([source_deal_header_id],[Leg],[pnl_as_of_date],[term_start],[term_end])INCLUDE ([deal_volume],[contract_value])
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_term_end_DA765')
	DROP INDEX [IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_term_end_DA765] ON [dbo].[source_deal_pnl_detail]
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_term_end_DA765')
	CREATE NONCLUSTERED INDEX [IXNC_source_deal_pnl_detail_pnl_as_of_date_term_start_term_end_DA765] ON [dbo].[source_deal_pnl_detail] ([pnl_as_of_date],[term_start],[term_end])INCLUDE ([source_deal_header_id],[Leg],[deal_volume],[contract_value])
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve]') AND name = N'IX_source_price_curve_As_of_date_SPC_SCDI_MD')
	DROP INDEX [IX_source_price_curve_As_of_date_SPC_SCDI_MD] ON [dbo].[source_price_curve]
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve]') AND name = N'IX_source_price_curve_As_of_date_SPC_SCDI_MD')
	CREATE NONCLUSTERED INDEX [IX_source_price_curve_As_of_date_SPC_SCDI_MD] ON [dbo].[source_price_curve] ([source_curve_def_id],[maturity_date])
	INCLUDE ([as_of_date])
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[index_fees_breakdown]') AND name = N'UC_index_fees_breakdown')
	DROP INDEX [UC_index_fees_breakdown] ON [dbo].[index_fees_breakdown]
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[index_fees_breakdown]') AND name = N'UC_index_fees_breakdown')
CREATE UNIQUE CLUSTERED INDEX [UC_index_fees_breakdown] ON [dbo].[index_fees_breakdown]
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[leg] ASC,
	[term_start] ASC,
	[term_end] ASC,
	[field_id] ASC,
	[contract_mkt_flag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO