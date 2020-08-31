SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Delta of financial position breakdown

	Columns
	as_of_date : Date of data changed
	source_deal_header_id : Deal ID foreign key to source_deal_header 
	curve_id : Financial curve ID
	term_start : Financial term start
	deal_date : Deal Date
	deal_volume_uom_id : UOM ID 
	calc_volume : Financial position
	create_ts : Record insert timestamp
	create_user : Record insert user
	delta_type : Delta type
	expiration_date : Expiration date
	term_end : Financial term end
	formula : Formula contract side
	source_deal_detail_id : Deal detail ID foreign key to source_deal_detail
	rowid : Filter group ID foreign Key to position_report_group_map
	physical_curve_id : Physical curve id
	location_id : Location ID
	commodity_id : Commodity ID
	counterparty_id : Counterparty ID
	trader_id : Trader ID
	contract_id : Contract ID
	subbook_id : Sub book ID
	deal_status_id : Deal status ID
	deal_type : Deal type
	pricing_type : Pricing type
	internal_portfolio_id : Product group
	physical_financial_flag : Physical or Financial flag
	source_system_book_id1 : Book identifier ID1
	source_system_book_id2 : Book identifier ID2
	source_system_book_id3 : Book identifier ID3
	source_system_book_id4 : Book identifier ID4
	fas_book_id : FAS book ID

*/

if OBJECT_ID('[delta_report_hourly_position_breakdown]') is not null
DROP VIEW delta_report_hourly_position_breakdown
go

CREATE VIEW dbo.delta_report_hourly_position_breakdown
WITH SCHEMABINDING 
AS
SELECT 
	m.as_of_date,
	m.source_deal_header_id,
	m.curve_id,
	m.term_start,
	m.deal_date,
	m.deal_volume_uom_id,
	m.calc_volume,
	m.create_ts,
	m.create_user,
	m.delta_type,
	m.expiration_date,
	m.term_end,
	m.formula,
	m.source_deal_detail_id,
	m.rowid
	,g.curve_id physical_curve_id
	,g.location_id
	,g.commodity_id 
	,g.counterparty_id
	,g.trader_id
	,g.contract_id
	,g.subbook_id
	,g.deal_status_id
	,g.deal_type
	,g.pricing_type
	,g.internal_portfolio_id
	,'f' physical_financial_flag
   	,ssbm.source_system_book_id1
	,ssbm.source_system_book_id2
	,ssbm.source_system_book_id3
	,ssbm.source_system_book_id4
	,ssbm.fas_book_id
FROM [dbo].[delta_report_hourly_position_breakdown_main] m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id
