/*

The view vwHourly_position_AllFilter_breakdown is depend on view vwPosition_breakdown, so put both views in same file

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


IF OBJECT_ID('vwHourly_position_AllFilter_breakdown') IS NOT NULL
DROP VIEW [vwHourly_position_AllFilter_breakdown]
GO

if OBJECT_ID('vwposition_breakdown') is not null
drop view [vwposition_breakdown]
go

CREATE VIEW [dbo].[vwposition_breakdown] WITH schemabinding 	AS
	SELECT COUNT_BIG(*) cnt,term_start,term_end,curve_id financial_curve_id,deal_volume_uom_id, rowid,deal_date,expiration_date,
		sum(isnull(calc_volume,0)) calc_volume,formula
	FROM dbo.report_hourly_position_breakdown_main
	GROUP BY term_start,term_end,curve_id,rowid,deal_volume_uom_id,deal_date,expiration_date,formula

GO

if not exists(select 1 from sys.indexes where [name]='ucindx_vwposition_breakdown')
create unique clustered index ucindx_vwposition_breakdown on vwposition_breakdown  
(term_start,term_end,financial_curve_id,deal_volume_uom_id,rowid,deal_date,expiration_date,formula) 
--ON PS_position_report_hourly_position_breakdown(term_start)



GO

CREATE VIEW [dbo].[vwHourly_position_AllFilter_breakdown] 	
AS

SELECT
		pos.term_start,pos.deal_volume_uom_id,pos.rowid,pos.deal_date,pos.expiration_date,
		pos.term_end,pos.financial_curve_id curve_id,pos.calc_volume,pos.formula
		,map.curve_id physical_curve_id
		,null location_id
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
FROM dbo.vwPosition_breakdown pos WITH(NOEXPAND)
	left join dbo.position_report_group_map map on pos.rowid=map.rowid
	left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id
	