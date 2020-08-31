IF  EXISTS (SELECT * FROM sys.indexes 
			WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_settlement]') 
			AND name = N'unq_cur_indx_source_deal_settlement')
DROP INDEX [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement] WITH (ONLINE = OFF)
GO

CREATE UNIQUE INDEX [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement] 
(
	source_deal_header_id, 
	term_start, 
	leg, 
	as_of_date, 
	set_type, 
	shipment_id,
	ticket_detail_id,
	match_info_id
)
GO

IF  EXISTS (SELECT * FROM sys.indexes 
			WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_settlement_tou]') 
			AND name = N'indx_unq_source_deal_settlement_tou')
DROP INDEX [indx_unq_source_deal_settlement_tou] ON [dbo].[source_deal_settlement_tou] WITH (ONLINE = OFF)
GO

CREATE UNIQUE INDEX [indx_unq_source_deal_settlement_tou] ON [dbo].[source_deal_settlement_tou] 
(
	source_deal_header_id, 
	term_start, 
	leg, 
	as_of_date, 
	set_type, 
	tou_id, 
	shipment_id,
	ticket_detail_id,
	match_info_id
)
GO

IF  EXISTS (SELECT * FROM sys.indexes 
			WHERE object_id = OBJECT_ID(N'[dbo].[index_fees_breakdown_settlement]') 
			AND name = N'unq_cur_indx_index_fees_breakdown_settlement')
DROP INDEX [unq_cur_indx_index_fees_breakdown_settlement] ON [dbo].[index_fees_breakdown_settlement] WITH (ONLINE = OFF)
GO

CREATE UNIQUE INDEX [unq_cur_indx_index_fees_breakdown_settlement] ON [dbo].[index_fees_breakdown_settlement] 
(
	source_deal_header_id, 
	term_start, 
	leg, 
	as_of_date, 
	field_id, 
	set_type, 
	shipment_id,
	ticket_detail_id,
	match_info_id
)
GO