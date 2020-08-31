SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Position breakdown of deal volume source shaped and deal volume

	Columns
	source_deal_header_id : Deal ID foreign key to source_deal_header 
	term_start : Term start
	deal_date : Deal date
	deal_volume_uom_id : UOM ID
	hr1 : Hour 1 Psition
	hr2 : Hour 2 Psition
	hr3 : Hour 3 Psition
	hr4 : Hour 4 Psition
	hr5 : Hour 5 Psition
	hr6 : Hour 6 Psition
	hr7 : Hour 7 Psition
	hr8 : Hour 8 Psition
	hr9 : Hour 9 Psition
	hr10 : Hour 10 Psition
	hr11 : Hour 11 Psition
	hr12 : Hour 12 Psition
	hr13 : Hour 13 Psition
	hr14 : Hour 14 Psition
	hr15 : Hour 15 Psition
	hr16 : Hour 16 Psition
	hr17 : Hour 17 Psition
	hr18 : Hour 18 Psition
	hr19 : Hour 19 Psition
	hr20 : Hour 20 Psition
	hr21 : Hour 21 Psition
	hr22 : Hour 22 Psition
	hr23 : Hour 23 Psition
	hr24 : Hour 24 Psition
	hr25 : Hour 25 Psition
	expiration_date : Expiration date
	period : Period
	granularity : Granularity position breakdown
	source_deal_detail_id : Deal detail ID foreign key to source_deal_detail
	rowid : Filter group ID foreign Key to position_report_group_map
	create_ts : Create timestamp
	create_user : Create user
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
	ssbm.source_system_book_id1 : Book identifier ID1
	ssbm.source_system_book_id2 : Book identifier ID2
	ssbm.source_system_book_id3 : Book identifier ID3
	ssbm.source_system_book_id4 : Book identifier ID4
	ssbm.fas_book_id : FAS book ID
*/	
if OBJECT_ID('[report_hourly_position_deal]') is not null
DROP VIEW report_hourly_position_deal
go

CREATE VIEW dbo.report_hourly_position_deal
WITH SCHEMABINDING 
AS
SELECT 
	m.[source_deal_header_id],
	m.[term_start],
	m.[deal_date],
	m.[deal_volume_uom_id],
	m.[hr1],
	m.[hr2],
	m.[hr3],
	m.[hr4],
	m.[hr5],
	m.[hr6],
	m.[hr7],
	m.[hr8],
	m.[hr9],
	m.[hr10],
	m.[hr11],
	m.[hr12],
	m.[hr13],
	m.[hr14],
	m.[hr15],
	m.[hr16],
	m.[hr17],
	m.[hr18],
	m.[hr19],
	m.[hr20],
	m.[hr21],
	m.[hr22],
	m.[hr23],
	m.[hr24],
	m.[hr25],
	m.[expiration_date],
	m.[period],
	m.[granularity],
	m.[source_deal_detail_id],
	m.[rowid]
	,m.create_ts
	,m.create_user
	,g.curve_id
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
	,g.physical_financial_flag
   	,ssbm.source_system_book_id1
	,ssbm.source_system_book_id2
	,ssbm.source_system_book_id3
	,ssbm.source_system_book_id4
	,ssbm.fas_book_id

FROM [dbo].report_hourly_position_deal_main m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id
