
IF OBJECT_ID('vwHourly_position_AllFilter') IS NOT NULL 
DROP VIEW dbo.vwHourly_position_AllFilter

go

if OBJECT_ID('vwHourly_position_AllFilter_breakdown') is not null
drop view [vwHourly_position_AllFilter_breakdown]
go


IF OBJECT_ID('vwHourly_position_AllFilter_Profile') IS NOT NULL 
DROP VIEW dbo.vwHourly_position_AllFilter_Profile



go
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr1] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr2] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr3] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr4] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr5] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr6] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr7] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr8] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr9] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr10] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr11] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr12] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr13] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr14] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr15] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr16] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr17] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr18] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr19] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr20] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr21] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr22] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr23] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr24] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_deal] ALTER column	[hr25] numeric(38,20) NULL



ALTER TABLE [report_hourly_position_profile] ALTER column	[hr1] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr2] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr3] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr4] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr5] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr6] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr7] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr8] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr9] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr10] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr11] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr12] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr13] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr14] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr15] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr16] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr17] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr18] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr19] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr20] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr21] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr22] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr23] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr24] numeric(38,20) NULL
ALTER TABLE [report_hourly_position_profile] ALTER column	[hr25] numeric(38,20) NULL


ALTER TABLE [report_hourly_position_breakdown] ALTER column	[calc_volume] numeric(38,20) NULL


go
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr1] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr2] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr3] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr4] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr5] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr6] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr7] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr8] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr9] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr10] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr11] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr12] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr13] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr14] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr15] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr16] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr17] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr18] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr19] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr20] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr21] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr22] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr23] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr24] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_deal] ALTER column	[hr25] numeric(38,20) NULL



ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr1] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr2] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr3] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr4] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr5] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr6] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr7] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr8] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr9] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr10] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr11] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr12] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr13] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr14] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr15] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr16] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr17] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr18] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr19] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr20] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr21] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr22] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr23] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr24] numeric(38,20) NULL
ALTER TABLE [delta_report_hourly_position_profile] ALTER column	[hr25] numeric(38,20) NULL


ALTER TABLE [delta_report_hourly_position_breakdown] ALTER column	[calc_volume] numeric(38,20) NULL




ALTER TABLE [deal_detail_hour] ALTER column	[hr1] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr2] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr3] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr4] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr5] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr6] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr7] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr8] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr9] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr10] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr11] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr12] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr13] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr14] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr15] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr16] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr17] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr18] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr19] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr20] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr21] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr22] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr23] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr24] numeric(38,20) NULL
ALTER TABLE [deal_detail_hour] ALTER column	[hr25] numeric(38,20) NULL



IF object_id('deal_detail_hour_arch1') IS NOT NULL
BEGIN
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr1] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr2] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr3] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr4] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr5] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr6] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr7] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr8] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr9] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr10] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr11] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr12] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr13] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr14] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr15] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr16] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr17] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr18] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr19] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr20] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr21] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr22] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr23] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr24] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch1] ALTER column	[hr25] numeric(38,20) NULL
END

IF object_id('deal_detail_hour_arch2') IS NOT NULL
BEGIN
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr1] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr2] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr3] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr4] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr5] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr6] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr7] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr8] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr9] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr10] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr11] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr12] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr13] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr14] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr15] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr16] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr17] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr18] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr19] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr20] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr21] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr22] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr23] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr24] numeric(38,20) NULL
	ALTER TABLE [deal_detail_hour_arch2] ALTER column	[hr25] numeric(38,20) NULL
END

GO 
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



CREATE VIEW [dbo].[vwHourly_position_AllFilter] WITH schemabinding
AS
SELECT
		COUNT_BIG(*) cnt,	curve_id,ddh.location_id,
		term_start term_start,
		deal_date,
		SUM(ISNULL(HR1,0)) HR1,
		SUM(ISNULL(HR2,0)) HR2,
		SUM(ISNULL(HR3,0)) HR3,
		SUM(ISNULL(HR4,0)) HR4,
		SUM(ISNULL(HR5,0)) HR5,
		SUM(ISNULL(HR6,0)) HR6,
		SUM(ISNULL(HR7,0)) HR7,
		SUM(ISNULL(HR8,0)) HR8,
		SUM(ISNULL(HR9,0)) HR9,
		SUM(ISNULL(HR10,0)) HR10,
		SUM(ISNULL(HR11,0)) HR11,
		SUM(ISNULL(HR12,0)) HR12,
		SUM(ISNULL(HR13,0)) HR13,
		SUM(ISNULL(HR14,0)) HR14,
		SUM(ISNULL(HR15,0)) HR15,
		SUM(ISNULL(HR16,0)) HR16,
		SUM(ISNULL(HR17,0)) HR17,
		SUM(ISNULL(HR18,0)) HR18,
		SUM(ISNULL(HR19,0)) HR19,
		SUM(ISNULL(HR20,0)) HR20,
		SUM(ISNULL(HR21,0)) HR21,
		SUM(ISNULL(HR22,0)) HR22,
		SUM(ISNULL(HR23,0)) HR23,
		SUM(ISNULL(HR24,0)) HR24,
		SUM(ISNULL(HR25,0)) HR25,
		commodity_id,
		counterparty_id,
		fas_book_id,
		source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,
		source_system_book_id4,deal_volume_uom_id,physical_financial_flag,expiration_date,
		deal_status_id
	FROM
		dbo.report_hourly_position_deal ddh
	GROUP BY
		curve_id,location_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2
		,source_system_book_id3,source_system_book_id4,deal_volume_uom_id,physical_financial_flag,expiration_date,deal_status_id


GO


CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter] ON [dbo].[vwHourly_position_AllFilter] 
(
	[location_id] ASC,
	[curve_id] ASC,
	[term_start] ASC,
	[deal_date] ASC,
	[commodity_id] ASC,
	[counterparty_id] ASC,
	[fas_book_id] ASC,
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC,
	[deal_volume_uom_id] ASC,
	[physical_financial_flag] ASC,expiration_date ASC,
	[deal_status_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


GO


CREATE VIEW [dbo].[vwHourly_position_AllFilter_breakdown] WITH schemabinding 	AS
	SELECT COUNT_BIG(*) cnt,curve_id, term_start,term_end,deal_date,isnull(location_id,-1) location_id,
	commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
	source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,	sum(isnull(calc_volume,0)) calc_volume,expiration_date,deal_status_id
	FROM dbo.report_hourly_position_breakdown
		GROUP BY curve_id,term_start,term_end,deal_date,isnull(location_id,-1),commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
	,deal_volume_uom_id,physical_financial_flag,expiration_date,deal_status_id

GO

if not exists(select 1 from sys.indexes where [name]='ucindx_vwHourly_position_AllFilter_breakdown')
create unique clustered index ucindx_vwHourly_position_AllFilter_breakdown on vwHourly_position_AllFilter_breakdown  (curve_id,term_start,term_end,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
	,deal_volume_uom_id,physical_financial_flag,location_id,expiration_date,deal_status_id)
	
GO



CREATE VIEW [dbo].[vwHourly_position_AllFilter_profile] WITH schemabinding 	AS
		SELECT PARTITION_value, location_id,COUNT_BIG(*) cnt,curve_id, term_start,deal_date,
		commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
		source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
			SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,SUM(ISNULL(HR4,0)) HR4,
			SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,
			SUM(ISNULL(HR9,0)) HR9,SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
			SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,SUM(ISNULL(HR16,0)) HR16,
			SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,
			SUM(ISNULL(HR21,0)) HR21,SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24,SUM(ISNULL(HR25,0)) HR25,
		expiration_date,deal_status_id
		FROM dbo.report_hourly_position_profile 
		GROUP BY PARTITION_value,location_id,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
		,deal_volume_uom_id,physical_financial_flag,expiration_date,deal_status_id



GO

/****** Object:  Index [IDX_vwHourly_position_AllFilter_Profile]    Script Date: 03/31/2011 13:10:48 ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter_Profile] ON [dbo].[vwHourly_position_AllFilter_profile] 
(	PARTITION_value ASC ,
	[location_id] ASC,
	[curve_id] ASC,
	[term_start] ASC,
	[deal_date] ASC,
	[commodity_id] ASC,
	[counterparty_id] ASC,
	[fas_book_id] ASC,
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC,
	[deal_volume_uom_id] ASC,
	[physical_financial_flag] ASC,
	expiration_date ASC,
	deal_status_id ASC
) on PS_Farrms(PARTITION_value)
