/*

The view vwHourly_position_AllFilter_financial is depend on view vwPosition_financial, so put both views in same file

*/


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


SET ARITHABORT ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET ANSI_PADDING ON
GO

SET ANSI_WARNINGS ON
GO

SET NUMERIC_ROUNDABORT OFF
GO


IF OBJECT_ID('vwHourly_position_AllFilter_financial') IS NOT NULL 
DROP VIEW dbo.vwHourly_position_AllFilter_financial

go
IF OBJECT_ID('vwPosition_financial') IS NOT NULL 
DROP VIEW dbo.vwPosition_financial

go

CREATE VIEW [dbo].vwPosition_financial WITH schemabinding 	AS
	SELECT COUNT_BIG(*) cnt,term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period,
		SUM(isnull(HR1,0)) HR1,SUM(isnull(HR2,0)) HR2,SUM(isnull(HR3,0)) HR3,SUM(isnull(HR4,0)) HR4,
		SUM(isnull(HR5,0)) HR5,SUM(isnull(HR6,0)) HR6,SUM(isnull(HR7,0)) HR7,SUM(isnull(HR8,0)) HR8,
		SUM(isnull(HR9,0)) HR9,SUM(isnull(HR10,0)) HR10,SUM(isnull(HR11,0)) HR11,SUM(isnull(HR12,0)) HR12,
		SUM(isnull(HR13,0)) HR13,SUM(isnull(HR14,0)) HR14,SUM(isnull(HR15,0)) HR15,SUM(isnull(HR16,0)) HR16,
		SUM(isnull(HR17,0)) HR17,SUM(isnull(HR18,0)) HR18,SUM(isnull(HR19,0)) HR19,SUM(isnull(HR20,0)) HR20,
		SUM(isnull(HR21,0)) HR21,SUM(isnull(HR22,0)) HR22,SUM(isnull(HR23,0)) HR23,SUM(isnull(HR24,0)) HR24,SUM(isnull(HR25,0)) HR25
	FROM dbo.report_hourly_position_financial_main 
	GROUP BY term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period


GO

CREATE UNIQUE CLUSTERED INDEX [IDX_vwPosition_financial] ON [dbo].[vwPosition_financial] 
(	term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period )



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
		,'f' physical_financial_flag
		,ssbm.source_system_book_id1
		,ssbm.source_system_book_id2
		,ssbm.source_system_book_id3
		,ssbm.source_system_book_id4
		,ssbm.fas_book_id
FROM dbo.vwPosition_financial pos WITH(NOEXPAND)
	left join dbo.position_report_group_map map on pos.rowid=map.rowid
	left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id
 