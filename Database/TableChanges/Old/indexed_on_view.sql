
if exists(select 1 from sys.indexes where [name]='IDX_vwHourly_position_AllFilter')
drop index IDX_vwHourly_position_AllFilter on dbo.vwHourly_position_AllFilter
go
CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter] ON [vwHourly_position_AllFilter]
(curve_id,location_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
,deal_volume_uom_id,physical_financial_flag)

if exists(select 1 from sys.indexes where [name]='IDX_vwHourly_position_AllFilter_Profile')
drop index [IDX_vwHourly_position_AllFilter_Profile] on vwHourly_position_AllFilter_Profile
go

CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter_Profile] ON [vwHourly_position_AllFilter_Profile]
(curve_id,location_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
,deal_volume_uom_id,physical_financial_flag)

if exists(select 1 from sys.indexes where [name]='IDX_vwHourly_position_AllFilter_breakdown')
drop index [IDX_vwHourly_position_AllFilter_breakdown] on vwHourly_position_AllFilter_breakdown
go

CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter_breakdown] ON [vwHourly_position_AllFilter_breakdown]
(curve_id,location_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
,deal_volume_uom_id,physical_financial_flag)



GO
if exists(select 1 from sys.indexes where [name]='idx_vwHourly_position_monthly_AllFilter')
drop index idx_vwHourly_position_monthly_AllFilter on [vwHourly_position_monthly_AllFilter]
go

/****** Object:  Index [idx_vwHourly_position_monthly_AllFilter]    Script Date: 12/23/2010 23:47:24 ******/
CREATE UNIQUE CLUSTERED INDEX [idx_vwHourly_position_monthly_AllFilter] ON [dbo].[vwHourly_position_monthly_AllFilter] 
(
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC,
	[deal_date] ASC,
	[commodity_id] ASC,
	[counterparty_id] ASC,
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC,
	[deal_volume_uom_id] ASC,
	[physical_financial_flag] ASC,
	[deal_volume_frequency] ASC,
	[buy_sell_flag] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]



GO
if exists(select 1 from sys.indexes where [name]='idx_vwHourly_position_monthly_AllFilter_breakdown')
drop index idx_vwHourly_position_monthly_AllFilter_breakdown on vwHourly_position_monthly_AllFilter_breakdown

GO


CREATE UNIQUE CLUSTERED INDEX [idx_vwHourly_position_monthly_AllFilter_breakdown] ON [dbo].[vwHourly_position_monthly_AllFilter_breakdown] 
(
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC,
	[deal_date] ASC,
	[commodity_id] ASC,
	[counterparty_id] ASC,
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC,
	[deal_volume_uom_id] ASC,
	[physical_financial_flag] ASC,
	[deal_volume_frequency] ASC,
	[buy_sell_flag] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]