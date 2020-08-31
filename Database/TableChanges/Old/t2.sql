if object_id('vwHourly_position_AllFilter_breakdown') is not null
drop view vwHourly_position_AllFilter_breakdown

if object_id('vwHourly_position_AllFilter_Profile') is not null
drop view vwHourly_position_AllFilter_Profile

if object_id('vwHourly_position_AllFilter') is not null
drop view vwHourly_position_AllFilter


--alter table dbo.report_hourly_position_deal add create_ts datetime,	create_usr varchar(30)
--alter table dbo.report_hourly_position_breakdown add create_ts datetime,	create_usr varchar(30)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_curve')
create index indx_report_hourly_position_breakdown_curve on dbo.report_hourly_position_breakdown (curve_id) 

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_term')
create index indx_report_hourly_position_breakdown_term on dbo.report_hourly_position_breakdown (term_start) 

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_deal_date')
create index indx_report_hourly_position_breakdown_deal_date on dbo.report_hourly_position_breakdown (deal_date) 

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_commodity_id')
create index indx_report_hourly_position_breakdown_commodity_id on dbo.report_hourly_position_breakdown (commodity_id)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_counterparty_id') 
create index indx_report_hourly_position_breakdown_counterparty_id on dbo.report_hourly_position_breakdown (counterparty_id) 

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_fas_book_id')
create index indx_report_hourly_position_breakdown_fas_book_id on dbo.report_hourly_position_breakdown (fas_book_id) 

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_source_system_book_id')
create index indx_report_hourly_position_breakdown_source_system_book_id on dbo.report_hourly_position_breakdown (source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_report_hourly_position_breakdown_volume_uom_id') 
create index indx_report_hourly_position_breakdown_volume_uom_id on dbo.report_hourly_position_breakdown (deal_volume_uom_id) 			
			
go
	IF  OBJECT_ID('report_hourly_position_profile') IS NOT NULL
	BEGIN 
		IF  OBJECT_ID('report_hourly_position_profile_tmp') IS  NULL
			SELECT * INTO report_hourly_position_profile_tmp FROM report_hourly_position_profile 
			
		DROP TABLE [dbo].report_hourly_position_profile
	end
			
GO			
	create table dbo.report_hourly_position_profile(
	[partition_value] [int] NOT NULL,
	[source_deal_header_id] [int] ,
	[curve_id] [int] ,
	[location_id] [int] ,
	[term_start] [datetime] ,
	[deal_date] [datetime] ,
	[commodity_id] [int] ,
	[counterparty_id] [int] ,
	[fas_book_id] [int] ,
	[source_system_book_id1] [int] ,
	[source_system_book_id2] [int] ,
	[source_system_book_id3] [int] ,
	[source_system_book_id4] [int] ,
	[deal_volume_uom_id] [int] ,
	[physical_financial_flag] [varchar](1) ,
	[hr1] [float],
	[hr2] [float] ,
	[hr3] [float] ,
	[hr4] [float] ,
	[hr5] [float] ,
	[hr6] [float] ,
	[hr7] [float] ,
	[hr8] [float] ,
	[hr9] [float] ,
	[hr10] [float] ,
	[hr11] [float] ,
	[hr12] [float] ,
	[hr13] [float] ,
	[hr14] [float] ,
	[hr15] [float] ,
	[hr16] [float] ,
	[hr17] [float] ,
	[hr18] [float] ,
	[hr19] [float] ,
	[hr20] [float] ,
	[hr21] [float] ,
	[hr22] [float] ,
	[hr23] [float] ,
	[hr24] [float] ,[hr25] [float],
	create_ts datetime,
	create_usr varchar(30) 
	) ON PS_Farrms(partition_value)
	
go
	create clustered index indx_report_hourly_position_profile ON  dbo.report_hourly_position_profile (partition_value) ON PS_Farrms(partition_value)
	create index indx_report_hourly_position_profile_deal_id on dbo.report_hourly_position_profile(source_deal_header_id) 

	IF  OBJECT_ID('vwHourly_position_AllFilter_profile') IS NOT null
		DROP TABLE [dbo].vwHourly_position_AllFilter_profile
			
GO		
	CREATE VIEW [dbo].vwHourly_position_AllFilter_profile WITH schemabinding 	AS
		SELECT PARTITION_value location_id,COUNT_BIG(*) cnt,curve_id, term_start,deal_date,
		commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
		source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
		SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,SUM(ISNULL(HR4,0)) HR4,
		SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,
		SUM(ISNULL(HR9,0)) HR9,SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
		SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,SUM(ISNULL(HR16,0)) HR16,
		SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,
		SUM(ISNULL(HR21,0)) HR21,SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24,SUM(ISNULL(HR25,0)) HR25
		FROM dbo.report_hourly_position_profile 
		
		GROUP BY PARTITION_value,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
		,deal_volume_uom_id,physical_financial_flag

go

if exists(select 1 from sys.indexes where [name]='IDX_vwHourly_position_AllFilter_Profile')
drop index [IDX_vwHourly_position_AllFilter_Profile] on vwHourly_position_AllFilter_Profile
go

CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter_Profile] ON vwHourly_position_AllFilter_profile
( location_id,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
,deal_volume_uom_id,physical_financial_flag)  ON PS_Farrms(location_id)



go
	IF  OBJECT_ID('report_hourly_position_profile_blank') IS NOT null
		DROP TABLE [dbo].report_hourly_position_profile_blank
			
GO			
	create table dbo.report_hourly_position_profile_blank(
	[partition_value] [int] NOT NULL,
	[source_deal_header_id] [int] ,
	[curve_id] [int] ,
	[location_id] [int] ,
	[term_start] [datetime] ,
	[deal_date] [datetime] ,
	[commodity_id] [int] ,
	[counterparty_id] [int] ,
	[fas_book_id] [int] ,
	[source_system_book_id1] [int] ,
	[source_system_book_id2] [int] ,
	[source_system_book_id3] [int] ,
	[source_system_book_id4] [int] ,
	[deal_volume_uom_id] [int] ,
	[physical_financial_flag] [varchar](1) ,
	[hr1] [float],
	[hr2] [float] ,
	[hr3] [float] ,
	[hr4] [float] ,
	[hr5] [float] ,
	[hr6] [float] ,
	[hr7] [float] ,
	[hr8] [float] ,
	[hr9] [float] ,
	[hr10] [float] ,
	[hr11] [float] ,
	[hr12] [float] ,
	[hr13] [float] ,
	[hr14] [float] ,
	[hr15] [float] ,
	[hr16] [float] ,
	[hr17] [float] ,
	[hr18] [float] ,
	[hr19] [float] ,
	[hr20] [float] ,
	[hr21] [float] ,
	[hr22] [float] ,
	[hr23] [float] ,
	[hr24] [float] ,[hr25] [float],
	create_ts datetime,
	create_usr varchar(30) ) ON PS_Farrms(partition_value)
	
go
	create clustered index indx_report_hourly_position_profile_blank ON  dbo.report_hourly_position_profile_blank (partition_value) ON PS_Farrms(partition_value)




go
IF  OBJECT_ID('report_hourly_position_deal') IS NOT NULL
begin
	IF  OBJECT_ID('report_hourly_position_deal_tmp') IS NULL
		select *  into report_hourly_position_deal_tmp from report_hourly_position_deal
		
	DROP TABLE [dbo].report_hourly_position_deal
end			
GO			
create table dbo.report_hourly_position_deal(
	[source_deal_header_id] [int] ,
	[curve_id] [int] ,
	[location_id] [int] ,
	[term_start] [datetime] ,
	[deal_date] [datetime] ,
	[commodity_id] [int] ,
	[counterparty_id] [int] ,
	[fas_book_id] [int] ,
	[source_system_book_id1] [int] ,
	[source_system_book_id2] [int] ,
	[source_system_book_id3] [int] ,
	[source_system_book_id4] [int] ,
	[deal_volume_uom_id] [int] ,
	[physical_financial_flag] [varchar](1) ,
	[hr1] [float],
	[hr2] [float] ,
	[hr3] [float] ,
	[hr4] [float] ,
	[hr5] [float] ,
	[hr6] [float] ,
	[hr7] [float] ,
	[hr8] [float] ,
	[hr9] [float] ,
	[hr10] [float] ,
	[hr11] [float] ,
	[hr12] [float] ,
	[hr13] [float] ,
	[hr14] [float] ,
	[hr15] [float] ,
	[hr16] [float] ,
	[hr17] [float] ,
	[hr18] [float] ,
	[hr19] [float] ,
	[hr20] [float] ,
	[hr21] [float] ,
	[hr22] [float] ,
	[hr23] [float] ,
	[hr24] [float] ,[hr25] [float],
	create_ts datetime,
	create_usr varchar(30) ) 
	

	create index indx_report_hourly_position_deal_deal_id on dbo.report_hourly_position_deal(source_deal_header_id) 

	IF  OBJECT_ID('vwHourly_position_AllFilter') IS NOT null
		DROP view [dbo].vwHourly_position_AllFilter
			
GO		
	CREATE VIEW [dbo].[vwHourly_position_AllFilter] WITH schemabinding 	AS
		SELECT location_id,COUNT_BIG(*) cnt,curve_id, term_start,deal_date,
		commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
		source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
		SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,SUM(ISNULL(HR4,0)) HR4,
		SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,
		SUM(ISNULL(HR9,0)) HR9,SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
		SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,SUM(ISNULL(HR16,0)) HR16,
		SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,
		SUM(ISNULL(HR21,0)) HR21,SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24,SUM(ISNULL(HR25,0)) HR25
		FROM dbo.report_hourly_position_deal 
		GROUP BY location_id,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
		,deal_volume_uom_id,physical_financial_flag
go

if exists(select 1 from sys.indexes where [name]='IDX_vwHourly_position_AllFilter')
drop index IDX_vwHourly_position_AllFilter on dbo.vwHourly_position_AllFilter
go
CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_AllFilter] ON [vwHourly_position_AllFilter]
(location_id,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
,deal_volume_uom_id,physical_financial_flag) 

go
		
		

	create table dbo.deal_detail_hour_blank(
		[term_date] [datetime] NOT NULL,
		[profile_id] [int] NULL,
		[location_id] [int] NULL,
		[Hr1] [float] NULL,
		[Hr2] [float] NULL,
		[Hr3] [float] NULL,
		[Hr4] [float] NULL,
		[Hr5] [float] NULL,
		[Hr6] [float] NULL,
		[Hr7] [float] NULL,
		[Hr8] [float] NULL,
		[Hr9] [float] NULL,
		[Hr10] [float] NULL,
		[Hr11] [float] NULL,
		[Hr12] [float] NULL,
		[Hr13] [float] NULL,
		[Hr14] [float] NULL,
		[Hr15] [float] NULL,
		[Hr16] [float] NULL,
		[Hr17] [float] NULL,
		[Hr18] [float] NULL,
		[Hr19] [float] NULL,
		[Hr20] [float] NULL,
		[Hr21] [float] NULL,
		[Hr22] [float] NULL,
		[Hr23] [float] NULL,
		[Hr24] [float] NULL,
		[Hr25] [float] NULL,
		[term_start] [datetime] NULL,
		partition_value int ) ON PS_Farrms(partition_value)

create clustered index indx_deal_detail_hour_blank on  dbo.deal_detail_hour_blank (partition_value) ON PS_Farrms(partition_value)

go

		
DECLARE @i INT,@st VARCHAR(MAX)
SET @i=1
WHILE @i<=150
BEGIN
	set @st='
		IF  OBJECT_ID(''stage_report_hourly_position_profile_' +RIGHT('00'+CAST(@i AS VARCHAR),3) +''') IS NOT null
			DROP TABLE [dbo].stage_report_hourly_position_profile_' +RIGHT('00'+CAST(@i AS VARCHAR),3) +'
	create table dbo.stage_report_hourly_position_profile_' +RIGHT('00'+CAST(@i AS VARCHAR),3) +'(
	[partition_value] [int] NOT NULL,
	[source_deal_header_id] [int] ,
	[curve_id] [int] ,
	[location_id] [int] ,
	[term_start] [datetime] ,
	[deal_date] [datetime] ,
	[commodity_id] [int] ,
	[counterparty_id] [int] ,
	[fas_book_id] [int] ,
	[source_system_book_id1] [int] ,
	[source_system_book_id2] [int] ,
	[source_system_book_id3] [int] ,
	[source_system_book_id4] [int] ,
	[deal_volume_uom_id] [int] ,
	[physical_financial_flag] [varchar](1) ,
	[hr1] [float],
	[hr2] [float] ,
	[hr3] [float] ,
	[hr4] [float] ,
	[hr5] [float] ,
	[hr6] [float] ,
	[hr7] [float] ,
	[hr8] [float] ,
	[hr9] [float] ,
	[hr10] [float] ,
	[hr11] [float] ,
	[hr12] [float] ,
	[hr13] [float] ,
	[hr14] [float] ,
	[hr15] [float] ,
	[hr16] [float] ,
	[hr17] [float] ,
	[hr18] [float] ,
	[hr19] [float] ,
	[hr20] [float] ,
	[hr21] [float] ,
	[hr22] [float] ,
	[hr23] [float] ,
	[hr24] [float] ,[hr25] [float]
	,create_ts datetime
	,create_usr varchar(30) ) ON FG_Farrms_' +RIGHT('00'+CAST(@i AS VARCHAR),3)
	
	print(@st)
	EXEC(@st)
		
	set @st='
		create clustered index indx_stage_report_hourly_position_profile_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +' on dbo.stage_report_hourly_position_profile_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'(partition_value) ON FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'
	--	create index indx_stage_report_hourly_position_profile_stage_deal_id_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +' on dbo.stage_report_hourly_position_profile_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'(source_deal_header_id) 
		'
	print(@st)
	EXEC(@st)

	set @st='if object_id(''vwHourly_position_profile_AllFilter_stage_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +''') IS not null 
		drop	VIEW [dbo].[vwHourly_position_profile_AllFilter_stage_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +']'
	print(@st)
	EXEC(@st)	



	set @st='
		CREATE VIEW [dbo].[vwHourly_position_profile_AllFilter_stage_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'] WITH schemabinding 	AS
		SELECT PARTITION_value,COUNT_BIG(*) cnt,curve_id, term_start,deal_date,
		commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
		source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
		SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,SUM(ISNULL(HR4,0)) HR4,
		SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,
		SUM(ISNULL(HR9,0)) HR9,SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
		SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,SUM(ISNULL(HR16,0)) HR16,
		SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,
		SUM(ISNULL(HR21,0)) HR21,SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24
		FROM dbo.stage_report_hourly_position_profile_'+RIGHT('00'+CAST(@i AS VARCHAR),3) + '
		GROUP BY PARTITION_value,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
		,deal_volume_uom_id,physical_financial_flag	'
		
		print(@st)
		EXEC(@st)
		
	set @st='	
		CREATE UNIQUE CLUSTERED INDEX [IDX_vwHourly_position_Profile_AllFilter_stage_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'] ON [vwHourly_position_Profile_AllFilter_stage_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +']
		( partition_value,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
		,deal_volume_uom_id,physical_financial_flag) ON FG_Farrms_' +RIGHT('00'+CAST(@i AS VARCHAR),3)

	print(@st)
	EXEC(@st)
		
		
		--SET @st='create unique clustered index indx_vwHourly_position_AllFilter_hr_'+RIGHT('00'+CAST(@i AS VARCHAR)) +' on dbo.[vwHourly_position_AllFilter_'+RIGHT('00'+CAST(@i AS VARCHAR)) +'] (location_id,header_rowid,term_start)  ON FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR)) 
		--EXEC(@st)


	set @st='
		IF  OBJECT_ID(''stage_deal_detail_hour_' +RIGHT('00'+CAST(@i AS VARCHAR),3) +''') IS NOT null
			DROP TABLE [dbo].stage_deal_detail_hour_' +RIGHT('00'+CAST(@i AS VARCHAR),3) +'
		create table dbo.stage_deal_detail_hour_' +RIGHT('00'+CAST(@i AS VARCHAR),3) +'(
		[term_date] [datetime] NOT NULL,
		[profile_id] [int] NULL,
		[location_id] [int] NULL,
		[Hr1] [float] NULL,
		[Hr2] [float] NULL,
		[Hr3] [float] NULL,
		[Hr4] [float] NULL,
		[Hr5] [float] NULL,
		[Hr6] [float] NULL,
		[Hr7] [float] NULL,
		[Hr8] [float] NULL,
		[Hr9] [float] NULL,
		[Hr10] [float] NULL,
		[Hr11] [float] NULL,
		[Hr12] [float] NULL,
		[Hr13] [float] NULL,
		[Hr14] [float] NULL,
		[Hr15] [float] NULL,
		[Hr16] [float] NULL,
		[Hr17] [float] NULL,
		[Hr18] [float] NULL,
		[Hr19] [float] NULL,
		[Hr20] [float] NULL,
		[Hr21] [float] NULL,
		[Hr22] [float] NULL,
		[Hr23] [float] NULL,
		[Hr24] [float] NULL,
		[Hr25] [float] NULL,
		[term_start] [datetime] NULL,
		partition_value int ) ON FG_Farrms_' +RIGHT('00'+CAST(@i AS VARCHAR),3)
			
	print(@st)
	EXEC(@st)
		
	set @st='create clustered index indx_stage_deal_detail_hour_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +' on dbo.stage_deal_detail_hour_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'(partition_value) ON FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR),3)
	print(@st)
	EXEC(@st)



	SET @i=@i+1
END
------------------------------------------------------------------------------------------------------
