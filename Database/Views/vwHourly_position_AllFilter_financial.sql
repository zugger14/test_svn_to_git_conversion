


IF OBJECT_ID('vwHourly_position_AllFilter_financial') IS NOT NULL 
DROP VIEW dbo.vwHourly_position_AllFilter_financial

go

CREATE VIEW [dbo].[vwHourly_position_AllFilter_financial] 
 AS
SELECT
		pos.term_start,pos.deal_volume_uom_id,pos.rowid,pos.deal_date,pos.expiration_date,pos.[period],
		ISNULL(HR1,0) HR1,
		ISNULL(HR2,0) HR2,
		ISNULL(HR3,0) HR3,
		ISNULL(HR4,0) HR4,
		ISNULL(HR5,0) HR5,
		ISNULL(HR6,0) HR6,
		ISNULL(HR7,0) HR7,
		ISNULL(HR8,0) HR8,
		ISNULL(HR9,0) HR9,
		ISNULL(HR10,0) HR10,
		ISNULL(HR11,0) HR11,
		ISNULL(HR12,0) HR12,
		ISNULL(HR13,0) HR13,
		ISNULL(HR14,0) HR14,
		ISNULL(HR15,0) HR15,
		ISNULL(HR16,0) HR16,
		ISNULL(HR17,0) HR17,
		ISNULL(HR18,0) HR18,
		ISNULL(HR19,0) HR19,
		ISNULL(HR20,0) HR20,
		ISNULL(HR21,0) HR21,
		ISNULL(HR22,0) HR22,
		ISNULL(HR23,0) HR23,
		ISNULL(HR24,0) HR24,
		ISNULL(HR25,0) HR25
		,map.curve_id
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
FROM dbo.vwPosition_financial pos WITH(NOEXPAND)
	left join dbo.position_report_group_map map on pos.rowid=map.rowid
	left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id
