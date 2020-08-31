alter table deal_position_break_down ALTER COLUMN strip_from TINYINT
alter table deal_position_break_down ALTER COLUMN lag TINYINT
alter table deal_position_break_down ALTER COLUMN strip_to TINYINT
alter table deal_position_break_down ALTER COLUMN derived_curve_id INT
alter table deal_position_break_down ALTER COLUMN prior_year SMALLINT


alter table report_hourly_position_breakdown drop column report_detail_id
alter table dbo.report_hourly_position_breakdown add create_ts datetime,	create_usr varchar(30)

if OBJECT_ID('deal_detail_hour') is NOT NULL
BEGIN
	if OBJECT_ID('deal_detail_hour_tmp') is  null
		SELECT * INTO deal_detail_hour_tmp FROM deal_detail_hour
		
	drop table deal_detail_hour

END

	create table dbo.deal_detail_hour(
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



create clustered index indx_deal_detail_hour on  dbo.deal_detail_hour (partition_value) ON PS_Farrms(partition_value)
create index indx_deal_detail_hour_location_id on dbo.deal_detail_hour (location_id,profile_id,term_start,term_date)


alter table deal_position_break_down drop constraint FK_deal_position_break_down_source_deal_detail
GO
IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_deal_position_break_down')
create index indx_deal_position_break_down  ON deal_position_break_down(source_deal_header_id,leg ,del_term_start)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_deal_position_break_down_volume_uom_id')
create index indx_deal_position_break_down_volume_uom_id  ON deal_position_break_down(volume_uom_id)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_deal_position_break_down_curve_id')
create index indx_deal_position_break_down_curve_id  ON deal_position_break_down(curve_id)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_deal_position_break_down_derived_curve_id')
create index indx_deal_position_break_down_derived_curve_id  ON deal_position_break_down(derived_curve_id)


GO
IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_deal_position_break_down_fin_term')
create index indx_deal_position_break_down_fin_term on dbo.deal_position_break_down (fin_term_start)
go
--create index indx_holiday_group_dt on holiday_group (hol_date)

--alter table dbo.deal_detail_hour add term_start datetime
--update deal_detail_hour set term_start=convert(varchar(8),term_date,120)+'01'

IF EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_source_deal_detail_breakdown')
DROP INDEX indx_source_deal_detail_breakdown ON dbo.source_deal_detail

IF EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='IX_source_deal_detail_1')
DROP INDEX IX_source_deal_detail_1 ON dbo.source_deal_detail

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_source_deal_detail_volume_frequency')
CREATE  INDEX indx_source_deal_detail_volume_frequency ON dbo.source_deal_detail(deal_volume_frequency)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_source_deal_detail_curve')
CREATE  INDEX indx_source_deal_detail_curve ON dbo.source_deal_detail(curve_id)



IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_deal_detail_hour_location_id')
create index indx_deal_detail_hour_location_id on dbo.deal_detail_hour (location_id,profile_id,term_start,term_date)

IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_source_price_curve_def_commodity')
create index indx_source_price_curve_def_commodity on dbo.source_price_curve_def(commodity_id)

go


/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deal_position_break_down
	DROP CONSTRAINT PK_deal_position_break_down
GO
ALTER TABLE dbo.deal_position_break_down ADD CONSTRAINT
	PK_deal_position_break_down PRIMARY KEY NONCLUSTERED 
	(
	breakdown_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT


go



/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
DROP INDEX indx_deal_position_break_down ON dbo.deal_position_break_down
GO
CREATE CLUSTERED INDEX indx_deal_position_break_down ON dbo.deal_position_break_down
	(
	source_deal_header_id,
	leg,
	del_term_start
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
COMMIT

IF CHARINDEX('Microsoft SQL Server 2008', @@VERSION,1)<>0
begin
	IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_source_deal_detail_location')
	CREATE  INDEX indx_source_deal_detail_location ON dbo.source_deal_detail(location_id,term_start) where location_id is not null

	if exists (SELECT lock_escalation_desc FROM sys.tables WHERE name = 'deal_detail_hour' and lock_escalation_desc<>'AUTO')
	ALTER TABLE deal_detail_hour SET (LOCK_ESCALATION = AUTO)


	if exists (SELECT lock_escalation_desc FROM sys.tables WHERE name = 'report_hourly_position_profile'  and lock_escalation_desc<>'AUTO')
	ALTER TABLE report_hourly_position_profile SET (LOCK_ESCALATION = AUTO)
END
ELSE 
BEGIN
	IF not EXISTS(SELECT 1 FROM sys.indexes WHERE [NAME]='indx_source_deal_detail_location')
	CREATE  INDEX indx_source_deal_detail_location ON dbo.source_deal_detail(location_id,term_start) --where location_id is not null

END