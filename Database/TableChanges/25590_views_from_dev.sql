
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
	

go



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



IF OBJECT_ID('vwPosition_deal') IS NOT NULL 
DROP VIEW dbo.vwPosition_deal

go

CREATE VIEW [dbo].vwPosition_deal WITH schemabinding 	AS
	SELECT COUNT_BIG(*) cnt,term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period,
		SUM(isnull(HR1,0)) HR1,SUM(isnull(HR2,0)) HR2,SUM(isnull(HR3,0)) HR3,SUM(isnull(HR4,0)) HR4,
		SUM(isnull(HR5,0)) HR5,SUM(isnull(HR6,0)) HR6,SUM(isnull(HR7,0)) HR7,SUM(isnull(HR8,0)) HR8,
		SUM(isnull(HR9,0)) HR9,SUM(isnull(HR10,0)) HR10,SUM(isnull(HR11,0)) HR11,SUM(isnull(HR12,0)) HR12,
		SUM(isnull(HR13,0)) HR13,SUM(isnull(HR14,0)) HR14,SUM(isnull(HR15,0)) HR15,SUM(isnull(HR16,0)) HR16,
		SUM(isnull(HR17,0)) HR17,SUM(isnull(HR18,0)) HR18,SUM(isnull(HR19,0)) HR19,SUM(isnull(HR20,0)) HR20,
		SUM(isnull(HR21,0)) HR21,SUM(isnull(HR22,0)) HR22,SUM(isnull(HR23,0)) HR23,SUM(isnull(HR24,0)) HR24,SUM(isnull(HR25,0)) HR25
	FROM dbo.report_hourly_position_deal_main 
	GROUP BY term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period


GO

CREATE UNIQUE CLUSTERED INDEX [IDX_vwPosition_deal] ON [dbo].[vwPosition_deal] 
(	term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period ) 


go


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



IF OBJECT_ID('vwPosition_profile') IS NOT NULL 
DROP VIEW dbo.vwPosition_profile

go

CREATE VIEW [dbo].vwPosition_profile WITH schemabinding 	AS
	SELECT COUNT_BIG(*) cnt,term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period,
		SUM(isnull(HR1,0)) HR1,SUM(isnull(HR2,0)) HR2,SUM(isnull(HR3,0)) HR3,SUM(isnull(HR4,0)) HR4,
		SUM(isnull(HR5,0)) HR5,SUM(isnull(HR6,0)) HR6,SUM(isnull(HR7,0)) HR7,SUM(isnull(HR8,0)) HR8,
		SUM(isnull(HR9,0)) HR9,SUM(isnull(HR10,0)) HR10,SUM(isnull(HR11,0)) HR11,SUM(isnull(HR12,0)) HR12,
		SUM(isnull(HR13,0)) HR13,SUM(isnull(HR14,0)) HR14,SUM(isnull(HR15,0)) HR15,SUM(isnull(HR16,0)) HR16,
		SUM(isnull(HR17,0)) HR17,SUM(isnull(HR18,0)) HR18,SUM(isnull(HR19,0)) HR19,SUM(isnull(HR20,0)) HR20,
		SUM(isnull(HR21,0)) HR21,SUM(isnull(HR22,0)) HR22,SUM(isnull(HR23,0)) HR23,SUM(isnull(HR24,0)) HR24,SUM(isnull(HR25,0)) HR25
	FROM dbo.report_hourly_position_profile_main
	GROUP BY term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period


GO

CREATE UNIQUE CLUSTERED INDEX [IDX_vwPosition_profile] ON [dbo].vwPosition_profile 
(	term_start,deal_volume_uom_id,rowid,deal_date,expiration_date,period ) 


go



IF OBJECT_ID('vwHourly_position_AllFilter') IS NOT NULL 
DROP VIEW dbo.vwHourly_position_AllFilter

go

CREATE VIEW [dbo].[vwHourly_position_AllFilter] AS
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
	FROM dbo.vwPosition_deal pos 
		left join dbo.position_report_group_map map on pos.rowid=map.rowid
		left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id
	
go


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
		,'f' physical_financial_flag
		,ssbm.source_system_book_id1
		,ssbm.source_system_book_id2
		,ssbm.source_system_book_id3
		,ssbm.source_system_book_id4
		,ssbm.fas_book_id
FROM dbo.vwPosition_breakdown pos 
	left join dbo.position_report_group_map map on pos.rowid=map.rowid
	left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id



go





IF OBJECT_ID('vwHourly_position_AllFilter_Profile') IS NOT NULL 
DROP VIEW dbo.vwHourly_position_AllFilter_Profile

go

CREATE VIEW [dbo].[vwHourly_position_AllFilter_profile] 
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
FROM dbo.vwPosition_profile pos 
	left join dbo.position_report_group_map map on pos.rowid=map.rowid
	left join source_system_book_map ssbm on ssbm.book_deal_type_map_id=map.subbook_id




go










SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Delta position value of market side deal

	Columns
	as_of_date : Date position changed
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
	delta_type : Delta type
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
if OBJECT_ID('[delta_report_hourly_position]') is not null
DROP VIEW delta_report_hourly_position
go

CREATE VIEW dbo.delta_report_hourly_position
WITH SCHEMABINDING 
AS
SELECT 
	m.as_of_date,
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
	m.[delta_type],
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
FROM [dbo].delta_report_hourly_position_main m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id



go
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


go
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


go
if OBJECT_ID('[report_hourly_position_fixed]') is not null
DROP VIEW report_hourly_position_fixed
go

SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go


/**
	Position breakdown of fixation deal

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

CREATE VIEW dbo.report_hourly_position_fixed
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

FROM [dbo].report_hourly_position_fixed_main m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id


go
SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Delta financial position breakdown of physical allocation position.

	Columns
	as_of_date : Date position changed
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
	delta_type : Delta type
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
if OBJECT_ID('[delta_report_hourly_position_financial]') is not null
DROP VIEW delta_report_hourly_position_financial
go

CREATE VIEW dbo.delta_report_hourly_position_financial
WITH SCHEMABINDING 
AS
SELECT 
	m.as_of_date,
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
	m.[delta_type],
--	m.[expiration_date],
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
FROM [dbo].delta_report_hourly_position_financial_main m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id



go

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



go

SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Financial position breakdown of physical allocation position.

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
	ssbm.source_system_book_id1 : Book identifier ID1
	ssbm.source_system_book_id2 : Book identifier ID2
	ssbm.source_system_book_id3 : Book identifier ID3
	ssbm.source_system_book_id4 : Book identifier ID4
	ssbm.fas_book_id : FAS book ID

*/	
if OBJECT_ID('[report_hourly_position_financial]') is not null
DROP VIEW report_hourly_position_financial
go

CREATE VIEW dbo.report_hourly_position_financial
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
FROM [dbo].report_hourly_position_financial_main m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
 left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id



go
SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
/**
	Financial position breakdown of formula

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

if OBJECT_ID('[report_hourly_position_breakdown]') is not null
DROP VIEW dbo.report_hourly_position_breakdown
go

CREATE VIEW dbo.report_hourly_position_breakdown
WITH SCHEMABINDING 
AS
SELECT 
	m.source_deal_header_id,
	m.curve_id,
	m.term_start,
	m.deal_date,
	m.deal_volume_uom_id,
	m.calc_volume,
	m.create_ts,
	m.create_user,
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
FROM [dbo].[report_hourly_position_breakdown_main] m
 left join dbo.position_report_group_map g on g.rowid=m.rowid
left join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id
