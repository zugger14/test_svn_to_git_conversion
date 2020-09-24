
IF OBJECT_ID('vwHourly_position_AllFilter_breakdown') IS NOT NULL
DROP VIEW [vwHourly_position_AllFilter_breakdown]
GO

CREATE VIEW [dbo].[vwHourly_position_AllFilter_breakdown] 	
AS

SELECT
		pos.term_start,pos.deal_volume_uom_id,pos.rowid,pos.deal_date,pos.expiration_date,
		pos.term_end,pos.financial_curve_id curve_id,pos.calc_volume,pos.formula
		,map.curve_id physical_curve_id
		,map.location_id
		,map.commodity_id
		,map.counterparty_id
		,map.trader_id
		,map.contract_id
		,map.subbook_id
		,map.deal_status_id
		,map.deal_type
		,map.pricing_type
		,map.internal_portfolio_id
		,map.physical_financial_flag
		,ssbm.source_system_book_id1
		,ssbm.source_system_book_id2
		,ssbm.source_system_book_id3
		,ssbm.source_system_book_id4
		,ssbm.fas_book_id
FROM dbo.vwPosition_breakdown pos WITH(NOEXPAND)
	left join dbo.position_report_group_map map on pos.rowid=map.rowid
	left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id


