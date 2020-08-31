SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Position breakdown of deal volume source profile and forecast.

	Columns
	source_deal_header_id : Deal ID foreign key to source_deal_header 
	term_start : Term start
	deal_date : Deal date
	deal_volume_uom_id : UOM ID
	hr1 : Hour 1 Position
	hr2 : Hour 2 Position
	hr3 : Hour 3 Position
	hr4 : Hour 4 Position
	hr5 : Hour 5 Position
	hr6 : Hour 6 Position
	hr7 : Hour 7 Position
	hr8 : Hour 8 Position
	hr9 : Hour 9 Position
	hr10 : Hour 10 Position
	hr11 : Hour 11 Position
	hr12 : Hour 12 Position
	hr13 : Hour 13 Position
	hr14 : Hour 14 Position
	hr15 : Hour 15 Position
	hr16 : Hour 16 Position
	hr17 : Hour 17 Position
	hr18 : Hour 18 Position
	hr19 : Hour 19 Position
	hr20 : Hour 20 Position
	hr21 : Hour 21 Position
	hr22 : Hour 22 Position
	hr23 : Hour 23 Position
	hr24 : Hour 24 Position
	hr25 : Hour 25 Position
	expiration_date : Expiration date
	period : Period
	granularity : Granularity position breakdown
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
if OBJECT_ID('[report_hourly_position_profile]') is not null
DROP VIEW report_hourly_position_profile
go

CREATE VIEW dbo.report_hourly_position_profile
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
FROM [dbo].report_hourly_position_profile_main m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id
