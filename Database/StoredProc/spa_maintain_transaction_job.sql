/****** Object:  StoredProcedure [dbo].[spa_maintain_transaction_job]    Script Date: 10/28/2011 21:32:16 ******/
IF EXISTS (
		SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_transaction_job]') AND type IN (N'P',N'PC')
		)
	DROP PROCEDURE [dbo].[spa_maintain_transaction_job]
GO

/****** Object:  StoredProcedure [dbo].[spa_maintain_transaction_job]    Script Date: 10/28/2011 20:36:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Populate hourly position of the deals in portfolio.

	Parameters 
	@process_id : Process Id for input process table of deal list to process
	@insert_type : Insert Type
				- 0 - Incremental FROM frontend
				- 7 - Deal delete
				- 9 - Calculate only financial data only that will will be called from bulk/partial load import
				- 12 - Import from load forecast file;
				- 111 - Calculate both physical and financial position and insert result into process table (call from report)
				- 222 - Calculate physical position only and insert result into process table (call from report)
	@partition_no : Partition No
	@user_login_id : User Login Id of runner

*/


CREATE PROC [dbo].[spa_maintain_transaction_job] @process_id VARCHAR(50)
	,@insert_type INT = 0
	,-- 0=incremental from front	; 1= partial import; 2=bulk import : note: option=9 is to insert only financial data only that will will be called from bulk/partial load import; 7:delete deal; 5:re calculate all existing deal; 12= import from load forecast file; 222 = calc physical position only and insert result into process table; 111=calc both physical and financial position and insert result into process table
	@partition_no INT = NULL ,@user_login_id VARCHAR(30) = NULL
AS
SET NOCOUNT ON

/*

--EXEC spa_maintain_transaction_job 'EE1CC915_2180_4241_81A8_7D9C88779535',0,null,'farrms_admin'



drop table #tmp_header_deal_id
drop table #tmp_position_breakdown
declare @process_id varchar(50),@insert_type int,@partition_no int,@user_login_id varchar(30),@deal_delete varchar(1)
drop table #source_deal_detail_hour
select  @process_id='5D53DC5C_40E1_4183_9584_8EFDFF53ED48',@insert_type=0,@partition_no=1,@user_login_id='farrms_admin',@deal_delete='y'
--report_position_farrms_admin_49AFBFA8_BC35_404B_8590_78F087008D35
--TRUNCATE TABLE select * from adiha_process.dbo.report_position_farrms_admin_E5D1C26F_C332_4A0A_8082_F3936706EEA8
--insert into adiha_process.dbo.report_position_farrms_admin_testing select 4100,'d'
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo








DROP TABLE #report_hourly_position_profile
drop table #report_hourly_position_breakdown_main_inserted
drop table #report_hourly_position_breakdown_main_old

drop table #report_hourly_position_old
drop table #report_hourly_position_inserted
drop table #report_hourly_position_inserted
drop table #report_hourly_position_old
drop table #tmp_term_vol_break_down
drop table #tmp_financial_term
--EXEC TRMTracker_performance.dbo.spa_maintain_transaction_job '5E42CD67_7C90_4498_A6F6_E831F7136155'

--*/
--return
IF object_id('tempdb..#tmp_header_deal_id') IS NOT NULL
	DROP TABLE #tmp_header_deal_id

IF object_id('tempdb..#tmp_position_breakdown') IS NOT NULL
	DROP TABLE #tmp_position_breakdown

IF object_id('tempdb..#source_deal_detail_hour') IS NOT NULL
	DROP TABLE #source_deal_detail_hour

IF object_id('tempdb..#report_hourly_position_profile_main') IS NOT NULL
	DROP TABLE #report_hourly_position_profile_main

IF object_id('tempdb..#report_hourly_position_breakdown_main_inserted') IS NOT NULL
	DROP TABLE #report_hourly_position_breakdown_main_inserted

IF object_id('tempdb..#report_hourly_position_breakdown_main_old') IS NOT NULL
	DROP TABLE #report_hourly_position_breakdown_main_old

IF object_id('tempdb..#report_hourly_position_old') IS NOT NULL
	DROP TABLE #report_hourly_position_old

IF object_id('tempdb..#report_hourly_position_inserted') IS NOT NULL
	DROP TABLE #report_hourly_position_inserted

IF object_id('tempdb..#report_hourly_position_inserted') IS NOT NULL
	DROP TABLE #report_hourly_position_inserted

IF object_id('tempdb..#report_hourly_position_old') IS NOT NULL
	DROP TABLE #report_hourly_position_old

IF object_id('tempdb..#tmp_term_vol_break_down') IS NOT NULL
	DROP TABLE #tmp_term_vol_break_down

IF object_id('tempdb..#tmp_financial_term') IS NOT NULL
	DROP TABLE #tmp_financial_term

IF object_id('tempdb..#tmp_fixation') IS NOT NULL
	DROP TABLE #tmp_fixation

IF object_id('tempdb..#report_hourly_position_financial_main_old') IS NOT NULL
	DROP TABLE #report_hourly_position_financial_main_old

IF object_id('tempdb..#report_hourly_position_financial_main_inserted') IS NOT NULL
	DROP TABLE #report_hourly_position_financial_main_inserted

IF object_id('tempdb..#density_multiplier') IS NOT NULL
	DROP TABLE #density_multiplier
IF object_id('tempdb..#tmp_pos_deal_detail') IS NOT NULL
	DROP TABLE #tmp_pos_deal_detail




DECLARE @col_exp1 VARCHAR(MAX)
	,@col_exp2 VARCHAR(MAX)
	,@col_exp3 VARCHAR(MAX)
	,@col_exp4 VARCHAR(MAX)

DECLARE @st_sql VARCHAR(MAX)
	,@st_from VARCHAR(MAX)
	,@st_sql1 VARCHAR(MAX)
	,@st_sql2 VARCHAR(MAX)
	,@st_sql3 VARCHAR(MAX)
	,@st_sql4 VARCHAR(MAX)
	,@st_sql5 VARCHAR(MAX)
	,@st_sql6 VARCHAR(MAX)
	,@st_sql7 VARCHAR(MAX)
	,@dst_column VARCHAR(MAX)
	,@vol_multiplier VARCHAR(MAX)

DECLARE @inserted_source_deal_detail VARCHAR(150)
	,@effected_deals VARCHAR(130)
	,@orginal_insert_type INT
	,@destination_tbl VARCHAR(max)
	,@deal_detail_hour VARCHAR(130)
	,@maintain_delta INT
	,@deadlock_var NCHAR(3)
	,@run_job_name VARCHAR(150)
	,@source VARCHAR(50)
	,@err_status VARCHAR(1)
	,@remarks VARCHAR(500)
	,@report_hourly_position_deal_main VARCHAR(2500)
	,@report_hourly_position_profile_main VARCHAR(2500)
	,@report_hourly_position_financial_main VARCHAR(2500)
	,@report_hourly_position_breakdown_main VARCHAR(2500)
	,@st_sql0 VARCHAR(max)
	,@ref_location VARCHAR(250)


DECLARE @deal_type INT
	--,@commodity_id INT
	--,@fixation INT
	,@tmp_location_profile varchar(250)
	,@total_yr_fraction varchar(250),@mw_uoms varchar(100) 
	,@mw_id int,@kw_id int,@CFD_id varchar(30)

select @CFD_id=internal_deal_type_subtype_id from internal_deal_type_subtype_types where internal_deal_type_subtype_type='CFD'
set @CFD_id=isnull(@CFD_id,'-1')

select @mw_uoms=ISNULL(@mw_uoms+',','')+cast(source_uom_id as varchar) from source_uom where uom_id in ('MW','KW')
select @mw_id=source_uom_id from source_uom where uom_id in ('MW')
select @kw_id=source_uom_id from source_uom where uom_id in ('KW')

set @mw_uoms=ISNULL(NULLIF(@mw_uoms,''),'-1')
set @mw_id=ISNULL(NULLIF(@mw_id,''),'-1')
set @kw_id=ISNULL(NULLIF(@kw_id,''),'-1')

SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
SET @tmp_location_profile = dbo.FNAProcessTableName('tmp_location_profile', @user_login_id, @process_id)
SET @total_yr_fraction = dbo.FNAProcessTableName('total_yr_fraction', @user_login_id, @process_id)
SET @ref_location = dbo.FNAProcessTableName('ref_location', @user_login_id, @process_id)

SET @report_hourly_position_deal_main = ''
SET @report_hourly_position_profile_main = ''
SET @report_hourly_position_financial_main = ''
SET @report_hourly_position_breakdown_main = ''

DECLARE @default_dst_group VARCHAR(50)

SELECT  @default_dst_group = tz.dst_group_value_id
FROM
	(
		SELECT var_value default_timezone_id 
		FROM dbo.adiha_default_codes_values (NOLOCK) 
		WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
inner join dbo.time_zones tz (NOLOCK) ON tz.timezone_id = df.default_timezone_id


IF OBJECT_ID('tempdb..#process_option') IS NOT NULL
	DROP TABLE #process_option

CREATE TABLE #process_option (
	insert_type INT
	,deal_type INT
	,commodity_id INT
	,fixation INT
)

IF @insert_type <> 7
BEGIN
	SET @st_sql = 'insert into #process_option (insert_type ,deal_type ,commodity_id ,fixation )
			select top 1 insert_type ,deal_type ,commodity_id ,fixation  from ' + @effected_deals

	EXEC (@st_sql)

	SELECT --@insert_type = insert_type,
		@deal_type = deal_type
		--,@commodity_id = commodity_id
		--,@fixation = fixation
	FROM #process_option

	TRUNCATE TABLE #process_option

	SET @st_sql = 'insert into  #process_option (deal_type  )
		select distinct deal_type  from ' + @effected_deals

	EXEC (@st_sql)
END


SET @orginal_insert_type = @insert_type

if @insert_type=1 
set @insert_type=0


SELECT @maintain_delta = var_value FROM adiha_default_codes_values 
WHERE (instance_no = '1') AND (default_code_id = 103) AND (seq_no = 1)

SET @maintain_delta = isnull(@maintain_delta, 0)

DECLARE @baseload_block_type VARCHAR(10) ,@baseload_block_define_id VARCHAR(10)

SET @baseload_block_type = '12000' -- Internal Static Data

SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM static_data_value WHERE [type_id] = 10018
	AND code LIKE 'Base Load' -- External Static Data

IF @baseload_block_define_id IS NULL
	SET @baseload_block_define_id = 'NULL'

--IF isnull(@maintain_delta, 0) <> 0
BEGIN
	CREATE TABLE #report_hourly_position_old (
		[source_deal_header_id] [int] NULL
		,[term_start] [datetime] NULL
		,[deal_date] [datetime] NULL
		,[deal_volume_uom_id] [int] NULL
		,[hr1] NUMERIC(38, 20) NULL
		,[hr2] NUMERIC(38, 20) NULL
		,[hr3] NUMERIC(38, 20) NULL
		,[hr4] NUMERIC(38, 20) NULL
		,[hr5] NUMERIC(38, 20) NULL
		,[hr6] NUMERIC(38, 20) NULL
		,[hr7] NUMERIC(38, 20) NULL
		,[hr8] NUMERIC(38, 20) NULL
		,[hr9] NUMERIC(38, 20) NULL
		,[hr10] NUMERIC(38, 20) NULL
		,[hr11] NUMERIC(38, 20) NULL
		,[hr12] NUMERIC(38, 20) NULL
		,[hr13] NUMERIC(38, 20) NULL
		,[hr14] NUMERIC(38, 20) NULL
		,[hr15] NUMERIC(38, 20) NULL
		,[hr16] NUMERIC(38, 20) NULL
		,[hr17] NUMERIC(38, 20) NULL
		,[hr18] NUMERIC(38, 20) NULL
		,[hr19] NUMERIC(38, 20) NULL
		,[hr20] NUMERIC(38, 20) NULL
		,[hr21] NUMERIC(38, 20) NULL
		,[hr22] NUMERIC(38, 20) NULL
		,[hr23] NUMERIC(38, 20) NULL
		,[hr24] NUMERIC(38, 20) NULL
		,[hr25] NUMERIC(38, 20) NULL
		,[create_ts] [datetime] NULL
		,[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL
		,expiration_date DATETIME
		,period INT
		,granularity INT
		,source_deal_detail_id int
		,rowid int
	)

	CREATE TABLE #report_hourly_position_inserted (
		[source_deal_header_id] [int] NULL
		,[term_start] [datetime] NULL
		,[deal_date] [datetime] NULL
		,[deal_volume_uom_id] [int] NULL
		,[hr1] NUMERIC(38, 20) NULL
		,[hr2] NUMERIC(38, 20) NULL
		,[hr3] NUMERIC(38, 20) NULL
		,[hr4] NUMERIC(38, 20) NULL
		,[hr5] NUMERIC(38, 20) NULL
		,[hr6] NUMERIC(38, 20) NULL
		,[hr7] NUMERIC(38, 20) NULL
		,[hr8] NUMERIC(38, 20) NULL
		,[hr9] NUMERIC(38, 20) NULL
		,[hr10] NUMERIC(38, 20) NULL
		,[hr11] NUMERIC(38, 20) NULL
		,[hr12] NUMERIC(38, 20) NULL
		,[hr13] NUMERIC(38, 20) NULL
		,[hr14] NUMERIC(38, 20) NULL
		,[hr15] NUMERIC(38, 20) NULL
		,[hr16] NUMERIC(38, 20) NULL
		,[hr17] NUMERIC(38, 20) NULL
		,[hr18] NUMERIC(38, 20) NULL
		,[hr19] NUMERIC(38, 20) NULL
		,[hr20] NUMERIC(38, 20) NULL
		,[hr21] NUMERIC(38, 20) NULL
		,[hr22] NUMERIC(38, 20) NULL
		,[hr23] NUMERIC(38, 20) NULL
		,[hr24] NUMERIC(38, 20) NULL
		,[hr25] NUMERIC(38, 20) NULL
		,[create_ts] [datetime] NULL
		,[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL
		,expiration_date DATETIME
		,period INT
		,granularity INT
		,source_deal_detail_id int
		,rowid int
	)

	CREATE TABLE #report_hourly_position_financial_main_old (
		[source_deal_header_id] [int] NULL
		,[term_start] [datetime] NULL
		,[deal_date] [datetime] NULL
		,[deal_volume_uom_id] [int] NULL
		,[hr1] NUMERIC(38, 20) NULL
		,[hr2] NUMERIC(38, 20) NULL
		,[hr3] NUMERIC(38, 20) NULL
		,[hr4] NUMERIC(38, 20) NULL
		,[hr5] NUMERIC(38, 20) NULL
		,[hr6] NUMERIC(38, 20) NULL
		,[hr7] NUMERIC(38, 20) NULL
		,[hr8] NUMERIC(38, 20) NULL
		,[hr9] NUMERIC(38, 20) NULL
		,[hr10] NUMERIC(38, 20) NULL
		,[hr11] NUMERIC(38, 20) NULL
		,[hr12] NUMERIC(38, 20) NULL
		,[hr13] NUMERIC(38, 20) NULL
		,[hr14] NUMERIC(38, 20) NULL
		,[hr15] NUMERIC(38, 20) NULL
		,[hr16] NUMERIC(38, 20) NULL
		,[hr17] NUMERIC(38, 20) NULL
		,[hr18] NUMERIC(38, 20) NULL
		,[hr19] NUMERIC(38, 20) NULL
		,[hr20] NUMERIC(38, 20) NULL
		,[hr21] NUMERIC(38, 20) NULL
		,[hr22] NUMERIC(38, 20) NULL
		,[hr23] NUMERIC(38, 20) NULL
		,[hr24] NUMERIC(38, 20) NULL
		,[hr25] NUMERIC(38, 20) NULL
		,[create_ts] [datetime] NULL
		,[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL
		,expiration_date DATETIME
		,source_deal_detail_id int
		,rowid int,granularity int,[period] int
	)

	CREATE TABLE #report_hourly_position_financial_main_inserted (
		[source_deal_header_id] [int] NULL
		,[term_start] [datetime] NULL
		,[deal_date] [datetime] NULL
		,[deal_volume_uom_id] [int] NULL
		,[hr1] NUMERIC(38, 20) NULL
		,[hr2] NUMERIC(38, 20) NULL
		,[hr3] NUMERIC(38, 20) NULL
		,[hr4] NUMERIC(38, 20) NULL
		,[hr5] NUMERIC(38, 20) NULL
		,[hr6] NUMERIC(38, 20) NULL
		,[hr7] NUMERIC(38, 20) NULL
		,[hr8] NUMERIC(38, 20) NULL
		,[hr9] NUMERIC(38, 20) NULL
		,[hr10] NUMERIC(38, 20) NULL
		,[hr11] NUMERIC(38, 20) NULL
		,[hr12] NUMERIC(38, 20) NULL
		,[hr13] NUMERIC(38, 20) NULL
		,[hr14] NUMERIC(38, 20) NULL
		,[hr15] NUMERIC(38, 20) NULL
		,[hr16] NUMERIC(38, 20) NULL
		,[hr17] NUMERIC(38, 20) NULL
		,[hr18] NUMERIC(38, 20) NULL
		,[hr19] NUMERIC(38, 20) NULL
		,[hr20] NUMERIC(38, 20) NULL
		,[hr21] NUMERIC(38, 20) NULL
		,[hr22] NUMERIC(38, 20) NULL
		,[hr23] NUMERIC(38, 20) NULL
		,[hr24] NUMERIC(38, 20) NULL
		,[hr25] NUMERIC(38, 20) NULL
		,[create_ts] [datetime] NULL
		,[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL
		,expiration_date DATETIME
		,source_deal_detail_id int
		,rowid int,granularity int,[period] int
	)
END

IF OBJECT_ID('tempdb..#minute_break') IS NULL
begin
	CREATE TABLE #minute_break (granularity int,period tinyint, factor numeric(6,2))  

	-- inserting factor for hourly value to break down into lower granularity.
	insert into #minute_break (granularity ,period , factor ) 
	values
	(995,0,12),(995,5,12),(995,10,12),(995,15,12),(995,20,12),(995,25,12),(995,30,12),(995,35,12),(995,40,12),(995,45,12),(995,50,12),(995,55,12), --5Min
	(994,0,6),(994,10,6),(994,20,6),(994,30,6),(994,40,6),(994,50,6), --10Min 
	(987,0,4),(987,15,4),(987,30,4),(987,45,4), --15Min
	(989,0,2),(989,30,2) --30Min
end


--------------------------------------------
BEGIN TRY
	-------------------------------------------
	IF ISNULL(@insert_type, 0) = 5 --re calculating of all existing deals
	BEGIN
		IF OBJECT_ID(@effected_deals) IS NULL
		EXEC ('select source_deal_header_id,isnull(update_user,create_user) create_user,source_deal_detail_id into ' + @effected_deals + ' from source_deal_detail')

		SET @insert_type = 0
	END
	ELSE IF ISNULL(@insert_type, 0) IN (111,222)
	BEGIN
		SET @insert_type = 0
		SET @maintain_delta = 0
		SET @report_hourly_position_deal_main = ' INTO ' + dbo.FNAProcessTableName('report_hourly_position_deal_main', @user_login_id, @process_id)
		SET @report_hourly_position_profile_main = ' INTO ' + dbo.FNAProcessTableName('report_hourly_position_profile_main', @user_login_id, @process_id)
		SET @report_hourly_position_financial_main = ' INTO ' + dbo.FNAProcessTableName('report_hourly_position_financial_main', @user_login_id, @process_id)
		SET @report_hourly_position_breakdown_main = ' INTO ' + dbo.FNAProcessTableName('report_hourly_position_breakdown_main', @user_login_id, @process_id)
	END

	IF OBJECT_ID('tempdb..#tmp_header_deal_id') IS not NULL
		drop table #tmp_header_deal_id

	CREATE TABLE #tmp_header_deal_id (
		source_deal_header_id INT
		,create_user VARCHAR(50) COLLATE DATABASE_DEFAULT
		,granularity INT
		,source_deal_detail_id int
		,rowid int,dst_group_value_id int
	)

	IF OBJECT_ID('tempdb..#tmp_header_deal_id_del') IS not NULL
		drop table #tmp_header_deal_id_del

	CREATE TABLE #tmp_header_deal_id_del (source_deal_detail_id int)

	SET @st_sql = 'INSERT INTO #tmp_header_deal_id_del (source_deal_detail_id) 
		select distinct a.source_deal_detail_id from ' + @effected_deals + ' a 
		inner join source_deal_detail sdd on a.source_deal_detail_id=sdd.source_deal_detail_id 
		where sdd.position_formula_id is null'
	EXEC spa_print @st_sql
	EXEC (@st_sql)

-- delete of orphant deal_detail_id's position
	SET @st_sql = 'INSERT INTO #tmp_header_deal_id_del (source_deal_detail_id) 
		select del.source_deal_detail_id from (
			select distinct source_deal_header_id from ' + @effected_deals + ') a
			outer apply (
				select distinct p.source_deal_detail_id
				from  report_hourly_position_profile_main p
					left join source_deal_detail sdd on  sdd.source_deal_detail_id=p.source_deal_detail_id
						and sdd.source_deal_header_id=a.source_deal_header_id
				where sdd.source_deal_detail_id is null
					and p.source_deal_header_id=a.source_deal_header_id
				union
				select distinct p.source_deal_detail_id
				from  report_hourly_position_deal_main p
					left join source_deal_detail sdd on  sdd.source_deal_detail_id=p.source_deal_detail_id
						and sdd.source_deal_header_id=a.source_deal_header_id
				where sdd.source_deal_detail_id is null
					and p.source_deal_header_id=a.source_deal_header_id
				union
				select distinct p.source_deal_detail_id
				from  report_hourly_position_fixed_main p
					left join source_deal_detail sdd on  sdd.source_deal_detail_id=p.source_deal_detail_id
						and sdd.source_deal_header_id=a.source_deal_header_id
				where sdd.source_deal_detail_id is null
					and p.source_deal_header_id=a.source_deal_header_id

		) del'

	EXEC spa_print @st_sql
	EXEC (@st_sql)


	---------------------------------------------------------------------------------------------------------
	--deleting deal
	-----------------------------------------------------------------------------------------------------------------	
	IF ISNULL(@insert_type, 0) = 7 --while deleting deal
	BEGIN

		SET @st_sql = 'DELETE rhpd ' + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
			' output getdate() as_of_date, deleted.source_deal_header_id,deleted.term_start
			,deleted.deal_date,deleted.deal_volume_uom_id,-1*deleted.hr1,-1*deleted.hr2
			,-1*deleted.hr3,-1*deleted.hr4,-1*deleted.hr5,-1*deleted.hr6,-1*deleted.hr7,-1*deleted.hr8,-1*deleted.hr9
			,-1*deleted.hr10,-1*deleted.hr11,-1*deleted.hr12,-1*deleted.hr13,-1*deleted.hr14,-1*deleted.hr15
			,-1*deleted.hr16,-1*deleted.hr17,-1*deleted.hr18,-1*deleted.hr19,-1*deleted.hr20,-1*deleted.hr21
			,-1*deleted.hr22,-1*deleted.hr23,-1*deleted.hr24,-1*deleted.hr25,deleted.create_ts,deleted.create_user,17402 delta_type ,deleted.expiration_date,DELETED.period,DELETED.granularity,deleted.source_deal_detail_id,deleted.rowid
		into dbo.delta_report_hourly_position_main(as_of_date,source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12
		,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,delta_type,expiration_date,period,granularity,source_deal_detail_id,rowid)'
		END 
	+ ' FROM report_hourly_position_deal_main rhpd
			INNER JOIN #tmp_header_deal_id_del d ON  rhpd.source_deal_detail_id = d.source_deal_detail_id ' 

		EXEC spa_print @st_sql
		EXEC (@st_sql)

		SET @st_sql = 'DELETE rhpf ' + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
			' output getdate() as_of_date, deleted.source_deal_header_id,deleted.term_start,deleted.deal_date,deleted.deal_volume_uom_id
	,-1*deleted.hr1,-1*deleted.hr2,-1*deleted.hr3,-1*deleted.hr4,-1*deleted.hr5,-1*deleted.hr6,-1*deleted.hr7,-1*deleted.hr8,-1*deleted.hr9,-1*deleted.hr10,-1*deleted.hr11,-1*deleted.hr12
	,-1*deleted.hr13,-1*deleted.hr14,-1*deleted.hr15,-1*deleted.hr16,-1*deleted.hr17,-1*deleted.hr18,-1*deleted.hr19
	,-1*deleted.hr20,-1*deleted.hr21,-1*deleted.hr22,-1*deleted.hr23
	,-1*deleted.hr24,-1*deleted.hr25,deleted.create_ts,deleted.create_user,17402 delta_type ,deleted.expiration_date
	,DELETED.period, DELETED.granularity,deleted.source_deal_detail_id,deleted.rowid
	into dbo.delta_report_hourly_position_main(as_of_date,source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,delta_type,expiration_date,period,granularity,source_deal_detail_id,rowid)'
	END +
	' FROM report_hourly_position_profile_main rhpf INNER JOIN #tmp_header_deal_id_del d ON rhpf.source_deal_detail_id = d.source_deal_detail_id'

		EXEC spa_print @st_sql
		EXEC (@st_sql)

		SET @st_sql = 'DELETE rhpd ' + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN ''
		ELSE '	output getdate() as_of_date, deleted.source_deal_header_id,deleted.term_start
			,deleted.deal_date,deleted.deal_volume_uom_id
			,deleted.create_ts,deleted.create_user,-1*deleted.calc_volume,17402 delta_type ,deleted.expiration_date,DELETED.term_end
			,DELETED.formula,deleted.source_deal_detail_id,deleted.rowid,deleted.granularity
		into dbo.delta_report_hourly_position_breakdown_main(as_of_date,source_deal_header_id,term_start,deal_date,deal_volume_uom_id,create_ts,create_user,calc_volume
			,delta_type,expiration_date,term_end,formula,source_deal_detail_id,rowid,granularity) '
		END + 
		' FROM report_hourly_position_breakdown_main rhpd
			INNER JOIN #tmp_header_deal_id_del d ON rhpd.source_deal_detail_id = d.source_deal_detail_id '

		EXEC spa_print @st_sql
		EXEC (@st_sql)

		RETURN
	END

	----------------------------------------------------------------------------------------------------------
	--fixed data inserting
	-----------------------------------------------------------------------------------------------------------------


	IF EXISTS (SELECT TOP 1 1 FROM #tmp_header_deal_id_del) AND @orginal_insert_type NOT IN ( 111 ,222 ) --delete updated deals before inserting
	BEGIN
		SET @st_sql = 'delete s ' + CASE 
			WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
			' output deleted.source_deal_header_id,deleted.term_start,deleted.deal_date,deleted.deal_volume_uom_id,deleted.hr1,deleted.hr2,deleted.hr3,deleted.hr4,deleted.hr5,deleted.hr6,deleted.hr7,deleted.hr8,deleted.hr9,deleted.hr10,deleted.hr11,deleted.hr12,deleted.hr13,deleted.hr14,deleted.hr15,deleted.hr16,deleted.hr17,deleted.hr18,deleted.hr19,deleted.hr20,deleted.hr21,deleted.hr22,deleted.hr23,deleted.hr24,deleted.hr25,deleted.create_ts,deleted.create_user,deleted.expiration_date,deleted.period,deleted.granularity,deleted.source_deal_detail_id,deleted.rowid 
		into #report_hourly_position_old (source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid)'
		END 
		+ ' 
		From report_hourly_position_deal_main s 
			INNER JOIN #tmp_header_deal_id_del h ON s.source_deal_detail_id=h.source_deal_detail_id' -- where h.[action]=''u''' 

		EXEC spa_print @st_sql
		EXEC (@st_sql)

		SET @st_sql = 'delete s ' + CASE 
		WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
	' output deleted.source_deal_header_id,deleted.term_start,deleted.deal_date,deleted.deal_volume_uom_id,deleted.hr1,deleted.hr2,deleted.hr3,deleted.hr4,deleted.hr5,deleted.hr6,deleted.hr7,deleted.hr8,deleted.hr9,deleted.hr10,deleted.hr11,deleted.hr12,deleted.hr13,deleted.hr14,deleted.hr15,deleted.hr16,deleted.hr17,deleted.hr18,deleted.hr19,deleted.hr20,deleted.hr21,deleted.hr22,deleted.hr23,deleted.hr24,deleted.hr25,deleted.create_ts,deleted.create_user,deleted.expiration_date,deleted.period,deleted.granularity ,deleted.source_deal_detail_id,deleted.rowid
		into #report_hourly_position_old (source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid)'
		END 
	+ ' from report_hourly_position_profile_main s INNER JOIN #tmp_header_deal_id_del h ON s.source_deal_detail_id=h.source_deal_detail_id' -- where h.[action]=''u'''

		EXEC spa_print @st_sql
		EXEC (@st_sql)
	END

	IF object_id('tempdb..#density_multiplier') IS NOT NULL
		DROP TABLE #density_multiplier

	CREATE TABLE #density_multiplier (
		source_deal_detail_id INT,physical_density_mult NUMERIC(38,16),financial_density_mult NUMERIC(38, 16)
	)

	IF ISNULL(@insert_type, 0) IN (0,12) --and isnull(@deal_delete,'n')='n'
	BEGIN
		TRUNCATE TABLE #tmp_header_deal_id

		SET @st_sql = 'INSERT INTO #tmp_header_deal_id (source_deal_header_id,create_user,granularity,source_deal_detail_id) 
		select max(ed.source_deal_header_id),max(ed.create_user)
			,max(hourly_position_breakdown) hourly_position_breakdown
			--,982 hourly_position_breakdown
			,source_deal_detail_id
		FROM ' + @effected_deals + ' ed (nolock) 
			INNER JOIN source_deal_header sdh (nolock) on ed.source_deal_header_id=sdh.source_deal_header_id 
			INNER JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id
				AND hourly_position_breakdown is not null AND ISNULL(sdht.internal_deal_type_value_id,-1) <> 19 ----- Filter the Actual Storage Deals(Inventory)
		GROUP BY ed.source_deal_detail_id'

		EXEC spa_print @st_sql
		EXEC (@st_sql)

		CREATE INDEX indx_tmp_header_deal_id_zzz ON #tmp_header_deal_id (source_deal_detail_id)

		SET @destination_tbl = CASE WHEN isnull(@orginal_insert_type, 0) IN (111,222) THEN '' ELSE 
		'insert into dbo.report_hourly_position_deal_main(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid) output inserted.source_deal_header_id,inserted.term_start,inserted.deal_date,inserted.deal_volume_uom_id,inserted.hr1,inserted.hr2,inserted.hr3,inserted.hr4,inserted.hr5,inserted.hr6,inserted.hr7,inserted.hr8,inserted.hr9,inserted.hr10,inserted.hr11,inserted.hr12,inserted.hr13,inserted.hr14,inserted.hr15,inserted.hr16,inserted.hr17,inserted.hr18,inserted.hr19,inserted.hr20,inserted.hr21,inserted.hr22,inserted.hr23,inserted.hr24,inserted.hr25,inserted.create_ts,inserted.create_user,inserted.expiration_date,inserted.period,inserted.granularity,inserted.source_deal_detail_id,inserted.rowid 
		into #report_hourly_position_inserted(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid) '
		END

	update ed set dst_group_value_id=isnull(tz.dst_group_value_id, @default_dst_group)
	FROM source_deal_detail sdd  with (nolock)
		INNER JOIN #tmp_header_deal_id ed  with (nolock) ON ed.source_deal_detail_id = sdd.source_deal_detail_id 
		left join dbo.vwDealTimezone tz  on  tz.source_deal_header_id=sdd.source_deal_header_id
				and tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 
		
	insert into #density_multiplier (source_deal_detail_id,physical_density_mult,financial_density_mult)
		select distinct sdd.source_deal_detail_id,isnull(cf_p1.factor,cf_p.factor),cf_f.factor
	from #tmp_header_deal_id sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id --and spcd.conversion_value_id
		left join source_minor_location sml on sml.source_minor_location_id=sdd.location_id and sml.conversion_value_id is not null
		left join forecast_profile fp on fp.profile_id=COALESCE(sdd.profile_id,sml.profile_id,sml.proxy_profile_id)
		left join [dbo].[conversion_factor] h_p on h_p.conversion_value_id=sml.conversion_value_id	
			and h_p.from_uom=sdd.deal_volume_uom_id and h_p.to_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		left join [dbo].[conversion_factor] h_p1 on h_p1.conversion_value_id=sml.conversion_value_id	
			and h_p1.from_uom=fp.uom_id and h_p1.to_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		left join [dbo].[conversion_factor] h_f on h_f.conversion_value_id=spcd.conversion_value_id
			and h_f.from_uom=sdd.deal_volume_uom_id and h_f.to_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		outer apply
		(
			select max(d.effective_date) effective_date from  [conversion_factor_detail] d where d.conversion_factor_id=h_p.conversion_factor_id
				and d.effective_date<=sdd.term_start
		) cf_p_date
		outer apply
		(
			select max(d.effective_date) effective_date from [dbo].[conversion_factor_detail] d where d.conversion_factor_id=h_p1.conversion_factor_id
				and d.effective_date<=sdd.term_start
		) cf_p1_date
		outer apply
		(

			select max(d.effective_date) effective_date from [dbo].[conversion_factor_detail] d where d.conversion_factor_id=h_f.conversion_factor_id
				and d.effective_date<=sdd.term_start
		) cf_f_date
		left join [dbo].[conversion_factor_detail] cf_p on cf_p.conversion_factor_id=h_p.conversion_factor_id
			and cf_p.effective_date=cf_p_date.effective_date
		left join [dbo].[conversion_factor_detail] cf_p1 on cf_p1.conversion_factor_id=h_p1.conversion_factor_id
			and cf_p1.effective_date=cf_p1_date.effective_date
		left join dbo.[conversion_factor_detail] cf_f on cf_f.conversion_factor_id=h_f.conversion_factor_id
			and cf_f.effective_date=cf_f_date.effective_date

	if object_id('tempdb..#position_report_group_map') is not null
		drop table #position_report_group_map

	select 
		sdd.source_deal_detail_id
		,isnull(sdd.curve_id,-1) curve_id
		, isnull(sdd.location_id,-1) location_id
		,coalesce(spcd.commodity_id,sdh.commodity_id,-1) commodity_id
		,isnull(sdh.counterparty_id,-1) counterparty_id
		,isnull(sdh.trader_id,-1) trader_id
		,isnull(sdh.contract_id,-1) contract_id
		,ssbm.book_deal_type_map_id subbook_id
		--,coalesce(sdd.position_uom,spcd.display_uom_id,spcd.uom_id,-1) deal_volume_uom_id
		,isnull(sdh.deal_status,-1) deal_status_id
		,isnull(sdh.source_deal_type_id,-1) deal_type 
		,isnull(sdh.pricing_type,-1) pricing_type
		,isnull(sdh.internal_portfolio_id,-1) internal_portfolio_id
		,isnull(sdd.physical_financial_flag,'p') physical_financial_flag
	into #position_report_group_map
	FROM  source_deal_header sdh (nolock) 
		INNER JOIN source_deal_detail sdd (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id
		INNER JOIN source_system_book_map ssbm (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
			and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
			and sdh.source_system_book_id4=ssbm.source_system_book_id4
		LEFT JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=sdd.curve_id

	insert into dbo.position_report_group_map (
		curve_id
		,location_id
		,commodity_id
		,counterparty_id
		,trader_id
		,contract_id
		,subbook_id
		--,deal_volume_uom_id
		,deal_status_id
		,deal_type 
		,pricing_type
		,internal_portfolio_id
		,physical_financial_flag
	)
	select distinct 
		isnull(s.curve_id,-1)
		,isnull(s.location_id,-1)
		,isnull(s.commodity_id,-1)
		,isnull(s.counterparty_id,-1)
		,isnull(s.trader_id,-1)
		,isnull(s.contract_id,-1)
		,isnull(s.subbook_id,-1)
		--,s.deal_volume_uom_id
		,isnull(s.deal_status_id,-1)
		,isnull(s.deal_type,-1)
		,isnull(s.pricing_type,-1)
		,isnull(s.internal_portfolio_id,-1)
		,isnull(s.physical_financial_flag,'p')
	from #position_report_group_map s 
		left join position_report_group_map d on s.curve_id=d.curve_id
			and s.location_id=d.location_id
			and s.commodity_id=d.commodity_id
			and s.counterparty_id=d.counterparty_id
			and s.trader_id=d.trader_id
			and s.contract_id=d.contract_id
			and s.subbook_id=d.subbook_id
		--	and s.deal_volume_uom_id=d.deal_volume_uom_id
			and s.deal_status_id=d.deal_status_id
			and s.deal_type =d.deal_type
			and s.pricing_type=d.pricing_type
			and s.internal_portfolio_id=d.internal_portfolio_id
			and s.physical_financial_flag=d.physical_financial_flag
	where d.rowid is null

	update thdi set rowid=d.rowid
	from #tmp_header_deal_id thdi 
		inner join #position_report_group_map s on s.source_deal_detail_id=thdi.source_deal_detail_id
		inner join position_report_group_map d  on s.curve_id=d.curve_id
			and s.location_id=d.location_id
			and s.commodity_id=d.commodity_id
			and s.counterparty_id=d.counterparty_id
			and s.trader_id=d.trader_id
			and s.contract_id=d.contract_id
			and s.subbook_id=d.subbook_id
			--and s.deal_volume_uom_id=d.deal_volume_uom_id
			and s.deal_status_id=d.deal_status_id
			and s.deal_type =d.deal_type
			and s.pricing_type=d.pricing_type
			and s.internal_portfolio_id=d.internal_portfolio_id
			and s.physical_financial_flag=d.physical_financial_flag

	--deal
	IF EXISTS ( SELECT * FROM #process_option WHERE deal_type = 17302 ) 
		--AND ISNULL(@fixation, 4101) <> 4100 --shaped deal AND NOT FIXATION DEAL
	BEGIN
		set @col_exp2='case when sdd.deal_volume_uom_id in ('+@mw_uoms+') then sddh.volume/isnull(mw.factor,1) else sddh.volume end'

		SET @st_sql='
		SELECT sddh.source_deal_detail_id,term_date
			,CASE WHEN sddh.granularity IN (987,989)THEN right(hr, 2) ELSE 0 END period,sddh.granularity
			,cast(sum(CASE WHEN cast(left(hr, 2) AS INT) = 1 THEN CASE WHEN sddh.granularity = 981 THEN volume ELSE '+@col_exp2+' END 
				ELSE 0 END) AS NUMERIC(28, 14)) [1]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 2 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [2]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 3 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [3]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 4 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [4]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 5 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [5]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 6 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [6]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 7 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [7]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 8 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [8]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 9 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [9]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 10 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [10]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 11 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [11]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 12 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [12]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 13 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [13]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 14 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [14]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 15 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [15]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 16 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [16]'
		set @st_sql1='
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 17 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [17]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 18 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [18]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 19 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [19]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 20 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [20]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 21 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [21]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 22 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [22]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 23 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [23]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN cast(left(hr, 2) AS INT) = 24 THEN  '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [24]
			,cast(sum(CASE WHEN sddh.granularity = 981 THEN 0
				ELSE CASE WHEN is_dst = 1 THEN '+@col_exp2+' ELSE 0 END END) AS NUMERIC(24, 14)) [25]
		INTO #source_deal_detail_hour
		FROM source_deal_detail_hour sddh(NOLOCK)
			INNER JOIN source_deal_detail sdd(NOLOCK) ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #tmp_header_deal_id thdi ON thdi.source_deal_detail_id = sddh.source_deal_detail_id 
			left join (select distinct granularity , factor from #minute_break) mw on mw.granularity=sddh.granularity
		where  ISNULL(sdh.product_id,4101)<>4100
		GROUP BY sddh.source_deal_detail_id
			,sddh.term_date,CASE WHEN sddh.granularity IN (987,989) THEN right(hr, 2) ELSE 0 END,sddh.granularity
		HAVING count(*) > 0;
			
		create index idx_source_deal_detail_hour_001 on #source_deal_detail_hour (source_deal_detail_id) ;
		create index idx_source_deal_detail_hour_002 on #source_deal_detail_hour (source_deal_detail_id,term_date) 
			;
		'

		SET @dst_column = 'cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END,0)<=0 THEN 0 else 1 end as numeric(1,0))'
				--BEGIN TRAN ---tran01
				--Inserting for hourly data
		SET @col_exp3 = 'cast(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) as numeric(21,16))
			*cast(cast(cast(ISNULL(sdd.multiplier,1) as numeric(21,16))*cast(ISNULL(sdd.volume_multiplier2,1) as numeric(21,16)) as numeric(21,16))
			*cast(CASE WHEN sdd.buy_sell_flag=''b'' THEN 1 ELSE -1 END  as numeric(1,0)) as numeric(21,16))'

		SET @st_sql2 = @destination_tbl + '
				SELECT 	sdh.source_deal_header_id,sddh.term_date term_start,max(sdh.deal_date) deal_date,
				COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id,
				SUM([1]*' + @col_exp3 + ') AS Hr1, SUM([2]*' + @col_exp3 + ')  AS Hr2, 
				SUM([3]*' + @col_exp3 + ')  AS Hr3, SUM([4]*' + @col_exp3 + ')  AS Hr4, '

		SET @st_sql3 = 'SUM([5]*' + @col_exp3 + ')  AS Hr5, 
				SUM([6]*' + @col_exp3 + ')  AS Hr6, 
				SUM([7]*' + @col_exp3 + ')  AS Hr7,       
				SUM([8]*' + @col_exp3 + ')  AS Hr8,       
				SUM([9]*' + @col_exp3 + ')  AS Hr9,  
				SUM([10]*' + @col_exp3 + ')  AS Hr10, 
			SUM([11]*' + @col_exp3 + ')  AS Hr11,
			SUM([12]*' + @col_exp3 + ')  AS Hr12, 
				SUM([13]*' + @col_exp3 + ')  AS Hr13, 	SUM([14]*' + @col_exp3 + ')  AS Hr14, 
				SUM([15]*' + @col_exp3 + ')  AS Hr15,   SUM([16]*' + @col_exp3 + ')  AS Hr16,       
				SUM([17]*' + @col_exp3 + ')  AS Hr17, 	SUM([18]*' + @col_exp3 + ')  AS Hr18, 
				SUM([19]*' + @col_exp3 + ')  AS Hr19, SUM([20]*' + @col_exp3 + ')  AS Hr20 ,
				SUM([21]*' + @col_exp3 + ')  AS Hr21,	SUM([22]*' + @col_exp3 + ')  AS Hr22, 
				SUM([23]*' + @col_exp3 + ')  AS Hr23, SUM([24]*' + @col_exp3 + ')  AS Hr24, 
				SUM([25]*' + @col_exp3 + ') AS Hr25,getdate() create_ts,max(thdi.create_user),isnull(h_grp.exp_date,sddh.term_date) expiration_date
				,isnull(sddh.period,0) period,sddh.granularity,thdi.source_deal_detail_id,thdi.rowid'



--select * from static_data_value where value_id= 17606
		SET @st_sql4 = @report_hourly_position_deal_main + 
		'
		FROM  source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
				and sdd.curve_id is not null and ISNULL(sdh.internal_desk_id,17300)=17302
			INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id
			INNER JOIN #source_deal_detail_hour sddh (nolock) on sddh.source_deal_detail_id=sdd.source_deal_detail_id and sddh.granularity<>981 
			LEFT JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=sdd.curve_id
			left join rec_volume_unit_conversion conv (nolock) on conv.from_source_uom_id=sdd.deal_volume_uom_id
					and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
			LEFT JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id		
			left join #density_multiplier dm on sdd.source_deal_detail_id=dm.source_deal_detail_id
			outer apply (select MAX(exp_date) exp_date from holiday_group where  hol_group_value_id=spcd.exp_calendar_id
						and ((sdd.physical_financial_flag=''p'' and sdh.internal_deal_subtype_value_id='+@CFD_id+') or sdd.physical_financial_flag=''f'' or ISNULL(spcd.hourly_volume_allocation,17601) =17606)
						and sddh.term_date between hol_date AND isnull(nullif(hol_date_to,''1900-01-01''),hol_date)
				) h_grp 
		WHERE   sddh.term_date is not null  
				--spcd.formula_id IS  NULL 
				AND sdd.fixed_float_leg=''t''  AND ISNULL(sdh.product_id,4101)<>4100
				AND ISNULL(sdht.internal_deal_type_value_id,-1)<>21 --- Do not include Schedule
				and sdd.position_formula_id is null
		group by sdh.source_deal_header_id,sddh.term_date,
				COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id),sddh.period,sddh.granularity
				,thdi.source_deal_detail_id,thdi.rowid,isnull(h_grp.exp_date,sddh.term_date) ;'

			--breakdown shaped deal for granularity daily into hourly	
		SET @col_exp2 = 'cast(cast(sddh.[1] as numeric(24,12))/nullif(isnull(hb_term.term_hours,term_hrs_exp.term_no_hrs),0) AS NUMERIC(32,16))'
		SET @col_exp3 = 'cast(CASE WHEN sdd.buy_sell_flag=''b'' THEN 1 ELSE -1 END as numeric(1,0))'
            	

			
		SET @st_sql5 = @destination_tbl + ' SELECT sdh.source_deal_header_id,
			hb.term_date  term_start,max(sdh.deal_date) deal_date,
			COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id,
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 7 ELSE 1  END THEN 1.000 else 0 end + isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr7 ELSE hb.hr1 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr1,  
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 8 ELSE 2 END THEN 1.000 else 0 end + isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr8 ELSE hb.hr2 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr2, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 9 ELSE 3 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr9 ELSE hb.hr3 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr3, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 10 ELSE 4 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr10 ELSE hb.hr4 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr4, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 11 ELSE 5 END THEN 1 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr11 ELSE hb.hr5 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr5, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 12 ELSE 6 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr12 ELSE hb.hr6 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr6,
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 13 ELSE 7 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr13 ELSE hb.hr7 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr7,       
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 14 ELSE 8 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr14 ELSE hb.hr8 END,0) as numeric(1,0)))*' + @col_exp2 +'*' + @col_exp3 + ' )  AS Hr8, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 15 ELSE 9 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr15 ELSE hb.hr9 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr9,  
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 16 ELSE 10 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr16 ELSE hb.hr10 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr10, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 17 ELSE 11 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr17 ELSE hb.hr11 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr11, '
			
		SET @st_sql6 = 'SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 18 ELSE 12 END THEN 1 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr18 ELSE hb.hr12 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr12, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 19 ELSE 13 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr19 ELSE hb.hr13 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr13, 	
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 20 ELSE 14 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr20 ELSE hb.hr14 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr14, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 21 ELSE 15 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr21 ELSE hb.hr15 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr15,   
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 22 ELSE 16 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr22 ELSE hb.hr16 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr16,       
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 23 ELSE 17 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr23 ELSE hb.hr17 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr17, 	
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 24 ELSE 18 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr24 ELSE hb.hr18 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr18, 
			SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 1 ELSE 19 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr1 ELSE hb.hr19 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr19, 
			SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 2 ELSE 20 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr2 ELSE hb.hr20 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr20 ,
			SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 3 ELSE 21 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr3 ELSE hb.hr21 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 +' )  AS Hr21,	
			SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 4 ELSE 22 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr4 ELSE hb.hr22 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr22, 
			SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 5 ELSE 23 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr5 ELSE hb.hr23 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr23, 
			SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 6 ELSE 24 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr6 ELSE hb.hr24 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr24, 
			SUM(isnull(' + @dst_column + ',0)*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr25,getdate() create_ts,max(thdi.create_user) create_user
			,isnull(h_grp.exp_date,hb.term_date) expiration_date,0 period,982 granularity,thdi.source_deal_detail_id,thdi.rowid'
		
		SET @st_from = @report_hourly_position_deal_main + 
				'
		 FROM source_deal_header sdh  with (nolock) 
			INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id 
				 and  ISNULL(sdh.internal_desk_id,17300)=17302
			INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id 
			--INNER JOIN source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
			--	and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
			--	and sdh.source_system_book_id4=ssbm.source_system_book_id4
			INNER JOIN #source_deal_detail_hour sddh (NOLOCK) ON sddh.source_deal_detail_id = sdd.source_deal_detail_id 
				AND sddh.granularity=981 
			LEFT JOIN source_price_curve_def spcd  with (nolock) ON spcd.source_curve_def_id=sdd.curve_id
			LEFT JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply ( select nullif(sum(volume_mult),0) term_hours from hour_block_term (nolock) where
				dst_group_value_id=isnull(thdi.dst_group_value_id,'+@default_dst_group+') and
				block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,'+ @baseload_block_define_id + ')
				AND term_date=sddh.term_date and (isnull(spcd.hourly_volume_allocation,17601) <17603 or sdd.physical_financial_flag=''p'')
			) hb_term		
			outer apply (
				select sum(volume_mult) term_no_hrs from hour_block_term hbt (nolock) 
					inner join (select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) and h.exp_date=sddh.term_date 
					) ex on ex.exp_date=hbt.term_date
				where  hbt.dst_group_value_id=isnull(thdi.dst_group_value_id,'+@default_dst_group+') and hbt.block_define_id=COALESCE(spcd.block_define_id,' + @baseload_block_define_id + ') 
				and hbt.term_date =sddh.term_date
				and  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and sdd.physical_financial_flag=''f''
			) term_hrs_exp
			LEFT JOIN hour_block_term hb WITH (NOLOCK) ON hb.dst_group_value_id = isnull(thdi.dst_group_value_id,'+@default_dst_group+') 
				AND hb.block_define_id = COALESCE(spcd.block_define_id, sdh.block_define_id, ' + @baseload_block_define_id + ')  
				AND hb.block_type = COALESCE(spcd.block_type, sdh.block_type, ' + @baseload_block_type + ')
				and hb.term_date =sddh.term_date
			left join rec_volume_unit_conversion conv (nolock) on conv.from_source_uom_id=sdd.deal_volume_uom_id
				and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
			outer apply  (select distinct exp_date from holiday_group h (nolock) where h.exp_date=hb.term_date and h.hol_group_value_id=ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) and h.exp_date =sddh.term_date ) hg  
			LEFT OUTER JOIN hour_block_term hb1 (nolock) ON hb1.dst_group_value_id=isnull(thdi.dst_group_value_id,'+@default_dst_group+')
				AND hb1.block_define_id=hb.block_define_id
				AND hb1.term_date-1=hb.term_date
			LEFT JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id			
			outer apply (
				select MAX(exp_date) exp_date from holiday_group where  hol_group_value_id=spcd.exp_calendar_id
					and ((sdd.physical_financial_flag=''p'' and sdh.internal_deal_subtype_value_id='+@CFD_id+') or sdd.physical_financial_flag=''f'' or   ISNULL(spcd.hourly_volume_allocation,17601) =17606)
					and hb.term_date between hol_date AND isnull(nullif(hol_date_to,''1900-01-01''),hol_date)
			) h_grp 
			LEFT JOIN report_hourly_position_deal_main rhpd
				ON rhpd.source_deal_detail_id = sdd.source_deal_detail_id
				 AND rhpd.term_start = hb.term_date
			where     hb.term_date is not null 
				--spcd.formula_id IS  NULL 
				AND (sdd.fixed_float_leg = ''t'')  AND ISNULL(sdh.product_id, 4101) <> 4100	
				AND ((ISNULL(spcd.hourly_volume_allocation, 17601) IN (17603, 17604) 
					  AND hg.exp_date IS NOT NULL) OR (ISNULL(spcd.hourly_volume_allocation,17601) < 17603) OR sdd.physical_financial_flag = ''p'')
					AND ISNULL(sdht.internal_deal_type_value_id,-1) NOT IN(21,20) --- Do not include nomination and schedule
					and sdd.position_formula_id is null AND rhpd.source_deal_header_id IS NULL
			GROUP BY sdh.source_deal_header_id,  hb.term_date,
				ISNULL(h_grp.exp_date, hb.term_date), COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id), thdi.source_deal_detail_id,thdi.rowid '

			EXEC spa_print @st_sql
			EXEC spa_print @st_sql1
			EXEC spa_print @st_sql2
			EXEC spa_print @st_sql3
			EXEC spa_print @st_sql4
			EXEC spa_print @st_sql5
			EXEC spa_print @st_sql6
			EXEC spa_print @st_from

			EXEC (@st_sql + @st_sql1 + @st_sql2 + @st_sql3 + @st_sql4 + @st_sql5 + @st_sql6 + @st_from)
		END --shaped deal

		--Inserting for fixed deal data
		IF EXISTS ( SELECT 1 FROM #process_option WHERE deal_type = 17300 )
		-- AND ISNULL(@fixation, 4101) <> 4100 --deal_volume deal AND NOT FIXATION DEAL
		BEGIN
			SET @col_exp2 = 'cast(CASE WHEN pdd.deal_volume_frequency in (''h'',''x'',''y'') THEN cast(pdd.deal_volume  as numeric(22,10)) *pdd.conversion_factor*cast(pdd.multiplier *pdd.volume_multiplier2 as numeric(21,16)) ELSE cast(pdd.total_volume as numeric(26,10))/(isnull(hb_term_day.no_days,term_hrs_exp_day.no_days)*isnull(hb_term.term_hours,term_hrs_exp.term_no_hrs)) END AS NUMERIC(32,16))'

			SET @col_exp3 = 'cast(CASE WHEN pdd.buy_sell_flag=''b'' THEN 1.000000 ELSE -1.000000 END /case when pdd.deal_detail_volume_uom_id in ('+@mw_uoms+') then isnull(mb.factor,1) else 1.00 end as numeric(20,18))'
            	
			SET @dst_column = 'cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END,0)<=0 THEN 0 else 1 end as numeric(1,0))'

			SET @st_sql0 ='
				select distinct sdh.source_deal_header_id,isnull(sdd.curve_id,-1) curve_id,isnull(sdd.location_id,-1) location_id
					,sdh.deal_date ,spcd.commodity_id,sdh.counterparty_id,ssbm.fas_book_id
					,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3 ,sdh.source_system_book_id4
					,COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id, sdd.deal_volume_frequency
					,cast(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) as numeric(21,16)) conversion_factor
					,cast(isnull(sdd.multiplier,1) as numeric(21,16)) multiplier,cast(ISNULL(sdd.volume_multiplier2,1) as numeric(21,16)) volume_multiplier2
					,sdd.buy_sell_flag ,sdd.deal_volume,sddp.total_volume,isnull(thdi.dst_group_value_id,'+@default_dst_group+') dst_group_value_id
					,COALESCE(spcd.block_define_id,sdh.block_define_id,' + @baseload_block_define_id + ') block_define_id
					,ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) exp_calendar_id, sdd.term_start ,sdd.term_END
					,isnull(spcd.hourly_volume_allocation,17601) hourly_volume_allocation,sdd.physical_financial_flag
					,thdi.create_user,thdi.granularity,thdi.source_deal_detail_id,thdi.rowid,sdd.deal_volume_uom_id deal_detail_volume_uom_id
					,sdh.internal_deal_subtype_value_id
				into #tmp_pos_deal_detail
				FROM  source_deal_header sdh  with (nolock) 
					INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id --  and sdd.curve_id is not null
					INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id  
						and ISNULL(sdh.internal_desk_id,17300)=17300 --and ISNULL(sdh.product_id,-1)<>4100  --this condition is for applying fixation so it will not inserted for fixation logic.
					INNER JOIN source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
						and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
						and sdh.source_system_book_id4=ssbm.source_system_book_id4
					left join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
					LEFT JOIN source_price_curve_def spcd  with (nolock) ON spcd.source_curve_def_id=sdd.curve_id
					LEFT JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
					left join rec_volume_unit_conversion conv (nolock) on conv.from_source_uom_id=sdd.deal_volume_uom_id
						and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
					left join #density_multiplier dm on sdd.source_deal_detail_id=dm.source_deal_detail_id
					LEFT JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id			
				where   
					sdd.position_formula_id IS NULL and  (sdd.fixed_float_leg=''t'') AND ISNULL(sdh.product_id,4101)<>4100	
						AND ISNULL(sdht.internal_deal_type_value_id,-1) NOT IN(21,20) --- Do not include nomination and schedule
				;
		'
			
		SET @st_sql = @destination_tbl + ' SELECT max(pdd.source_deal_header_id),
			hb.term_date term_start,max(pdd.deal_date) deal_date,max(pdd.deal_volume_uom_id),
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 7 ELSE 1  END THEN 1.000 else 0 end + isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr7 ELSE hb.hr1 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 +') AS Hr1,  
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 8 ELSE 2 END THEN 1.000 else 0 end + isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr8 ELSE hb.hr2 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr2, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 9 ELSE 3 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr9 ELSE hb.hr3 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr3, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 10 ELSE 4 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr10 ELSE hb.hr4 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr4, '
			
		SET @st_sql1 = '
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 11 ELSE 5 END THEN 1 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr11 ELSE hb.hr5 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr5, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 12 ELSE 6 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr12 ELSE hb.hr6 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr6,
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 13 ELSE 7 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr13 ELSE hb.hr7 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr7,
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 14 ELSE 8 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr14 ELSE hb.hr8 END,0) as numeric(1,0)))*' + @col_exp2 + '*'+ @col_exp3 + ') AS Hr8, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 15 ELSE 9 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr15 ELSE hb.hr9 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr9,  
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 16 ELSE 10 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr16 ELSE hb.hr10 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr10, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 17 ELSE 11 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr17 ELSE hb.hr11 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr11, '
			
		SET @st_sql2 = '
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 18 ELSE 12 END THEN 1 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr18 ELSE hb.hr12 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr12, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 19 ELSE 13 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr19 ELSE hb.hr13 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr13, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 20 ELSE 14 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr20 ELSE hb.hr14 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr14, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 21 ELSE 15 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr21 ELSE hb.hr15 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr15,  
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 22 ELSE 16 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr22 ELSE hb.hr16 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr16,  
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 23 ELSE 17 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr23 ELSE hb.hr17 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr17, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 24 ELSE 18 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr24 ELSE hb.hr18 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr18, '
	
		SET @st_sql3 = '
			sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 1 ELSE 19 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr1 ELSE hb.hr19 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr19, 
			sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 2 ELSE 20 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr2 ELSE hb.hr20 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr20 ,
			sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 3 ELSE 21 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr3 ELSE hb.hr21 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr21,	
			sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 4 ELSE 22 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr4 ELSE hb.hr22 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr22, 
			sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 5 ELSE 23 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr5 ELSE hb.hr23 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr23, 
			sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 6 ELSE 24 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr6 ELSE hb.hr24 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr24, 
			sum(isnull(' +@dst_column + ',0)*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr25,getdate() create_ts,max(pdd.create_user) create_user,isnull(h_grp.exp_date,hb.term_date) expiration_date
		,isnull(mb.period,0) period ,max(pdd.granularity) granularity,pdd.source_deal_detail_id,pdd.rowid'
			
		SET @st_from = @report_hourly_position_deal_main + ' 
			From #tmp_pos_deal_detail pdd
				LEFT JOIN hour_block_term hb with (nolock) on hb.dst_group_value_id=pdd.dst_group_value_id  and hb.block_define_id= pdd.block_define_id 
					and hb.term_date between pdd.term_start and pdd.term_end
				LEFT OUTER JOIN hour_block_term hb1 (nolock) ON hb1.dst_group_value_id=pdd.dst_group_value_id
					AND hb1.block_define_id=pdd.block_define_id AND hb1.term_date-1=hb.term_date
				outer apply 
					(	select distinct exp_date from holiday_group h (nolock) 
						where h.exp_date=hb.term_date and h.hol_group_value_id=pdd.exp_calendar_id
						and h.exp_date between pdd.term_start  and pdd.term_END 
					) hg  
				outer apply (select MAX(exp_date) exp_date from holiday_group where  hol_group_value_id=pdd.exp_calendar_id
						and ((pdd.physical_financial_flag=''p'' and pdd.internal_deal_subtype_value_id='+@CFD_id+') or pdd.physical_financial_flag=''f'' or pdd.hourly_volume_allocation =17606)
						and hb.term_date between hol_date AND isnull(nullif(hol_date_to,''1900-01-01''),hol_date)
					) h_grp 
				outer apply 
					( select nullif(count(1),0) no_days from hour_block_term (nolock) where
							dst_group_value_id=pdd.dst_group_value_id AND block_define_id = pdd.block_define_id
							and	term_date between pdd.term_start and pdd.term_end and (pdd.hourly_volume_allocation <17603 or pdd.physical_financial_flag=''p'') and hol_date is null
						and volume_mult<>0
					) hb_term_day		
				outer apply 
					(
						select nullif(count(1),0) no_days from hour_block_term hbt (nolock) inner join 
							(select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=pdd.exp_calendar_id 
									and h.exp_date between pdd.term_start  and pdd.term_END 
							) ex on ex.exp_date=hbt.term_date
						where hbt.dst_group_value_id=pdd.dst_group_value_id AND hbt.block_define_id=pdd.block_define_id
							and hbt.term_date between pdd.term_start  and pdd.term_END
							and pdd.hourly_volume_allocation IN(17603,17604) and pdd.physical_financial_flag=''f'' and hbt.hol_date is null
					and hbt.volume_mult<>0
					) term_hrs_exp_day
				outer apply ( select nullif(sum(volume_mult),0) term_hours from hour_block_term (nolock) where
					dst_group_value_id=pdd.dst_group_value_id AND block_define_id = pdd.block_define_id
					and term_date=hb.term_date and (pdd.hourly_volume_allocation <17603 or pdd.physical_financial_flag=''p'')
				) hb_term			
				outer apply (
					select sum(volume_mult) term_no_hrs from hour_block_term hbt (nolock) inner join 
						(
							select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=pdd.exp_calendar_id and h.exp_date=hb.term_date
						) ex on ex.exp_date=hbt.term_date
					where  hbt.dst_group_value_id=pdd.dst_group_value_id
						and hbt.block_define_id=pdd.block_define_id and hbt.term_date=hb.term_date
						and pdd.hourly_volume_allocation IN(17603,17604) and pdd.physical_financial_flag=''f'' 
				) term_hrs_exp
			left join #minute_break mb on mb.granularity=pdd.granularity  
				where hb.term_date is not null 
					and ((pdd.hourly_volume_allocation IN(17603,17604) and  hg.exp_date is not null) or pdd.hourly_volume_allocation<17603 or (pdd.hourly_volume_allocation=17605 and pdd.physical_financial_flag=''f'') or pdd.physical_financial_flag=''p'')
				group by pdd.source_deal_detail_id,pdd.rowid,hb.term_date,isnull(h_grp.exp_date,hb.term_date),isnull(mb.period,0)
		'

		EXEC spa_print @st_sql0
		EXEC spa_print @st_sql
		EXEC spa_print @st_sql1
		EXEC spa_print @st_sql2
		EXEC spa_print @st_sql3
		EXEC spa_print @st_from

		EXEC (@st_sql0+@st_sql + @st_sql1 + @st_sql2 + @st_sql3 + @st_from)



			--Inserting for Schedule deals whose nomination does not exists
		SET @col_exp2 = 'cast(CASE WHEN pdd.deal_volume_frequency=''h'' THEN pdd.deal_volume *pdd.conversion_factor*cast(pdd.multiplier*pdd.volume_multiplier2 as numeric(21,16)) ELSE pdd.total_volume/nullif(isnull(hb_term_day.no_days,term_hrs_exp_day.no_days)*isnull(CASE WHEN pdd.commodity_id=-1 THEN nullif(hb_term1.volume_mult,0) ELSE nullif(hb_term.volume_mult,0) END ,term_hrs_exp.term_no_hrs),0) END AS NUMERIC(32,16))'

			SET @col_exp3 = 'cast(CASE WHEN pdd.buy_sell_flag=''b'' THEN 1.000000 ELSE -1.000000 END /case when pdd.deal_volume_uom_id in ('+@mw_uoms+') then isnull(mb.factor,1) else 1.00 end as numeric(20,18))'

		SET @dst_column = 'cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END,0)<=0 THEN 0 else 1 end as numeric(1,0))'


		SET @st_sql0 ='
		select distinct sdh.source_deal_header_id,isnull(sdd.curve_id,-1) curve_id,isnull(sdd.location_id,-1) location_id
				,sdh.deal_date ,spcd.commodity_id,sdh.counterparty_id,ssbm.fas_book_id
				,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3 ,sdh.source_system_book_id4
				,COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) deal_volume_uom_id, sdd.deal_volume_frequency
				,cast(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) as numeric(21,16)) conversion_factor
				,cast(isnull(sdd.multiplier,1) as numeric(21,16)) multiplier,cast(ISNULL(sdd.volume_multiplier2,1) as numeric(21,16)) volume_multiplier2
				,sdd.buy_sell_flag ,sdd.deal_volume,sddp.total_volume,isnull(thdi.dst_group_value_id,'+@default_dst_group+') dst_group_value_id
				,COALESCE(spcd.block_define_id,sdh.block_define_id,' + @baseload_block_define_id + ') block_define_id
				,ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) exp_calendar_id, sdd.term_start ,sdd.term_END
				,isnull(spcd.hourly_volume_allocation,17601) hourly_volume_allocation,sdd.physical_financial_flag
				,thdi.create_user,ISNULL(sdh.product_id,4101) product_id,thdi.source_deal_detail_id,thdi.rowid,thdi.granularity
				--,sdh.internal_deal_subtype_value_id 
			into #tmp_pos_deal_detail
			FROM  source_deal_header sdh  with (nolock) 
				INNER JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id AND sdht.internal_deal_type_value_id IN(21) --- Only include schduled storage deals 		
				INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id --  and sdd.curve_id is not null
				INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id  
					AND ISNULL(sdh.internal_desk_id,17300)=17300 --and ISNULL(sdh.product_id,-1)<>4100  --this condition is for applying fixation so it will not inserted for fixation logic.
				INNER JOIN source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
				and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
				 and sdh.source_system_book_id4=ssbm.source_system_book_id4
				left join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
				LEFT JOIN source_price_curve_def spcd  with (nolock) ON spcd.source_curve_def_id=sdd.curve_id
				LEFT JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
				left join rec_volume_unit_conversion conv (nolock) on conv.from_source_uom_id=sdd.deal_volume_uom_id
					and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
				left join #density_multiplier dm on sdd.source_deal_detail_id=dm.source_deal_detail_id	
				LEFT JOIN source_deal_header sdh1 (nolock) ON sdh1.close_reference_id = sdh.source_deal_header_id  -- get the nomination deals
					AND ISNULL(sdh1.internal_deal_type_value_id,-1)=20  -- for storage types
			WHERE   sdd.fixed_float_leg=''t'' AND sdh.product_id<>4100 and sdd.position_formula_id is null	;
			'

			SET @st_sql = @destination_tbl + ' SELECT max(pdd.source_deal_header_id),
				hb.term_date term_start,max(pdd.deal_date) deal_date,max(pdd.deal_volume_uom_id),
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 7 ELSE 1  END THEN 1.000 else 0 end + isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr7 ELSE hb.hr1 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr1,  
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 8 ELSE 2 END THEN 1.000 else 0 end + isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr8 ELSE hb.hr2 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr2, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 9 ELSE 3 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr9 ELSE hb.hr3 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr3, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 10 ELSE 4 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr10 ELSE hb.hr4 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr4, '
		
			SET @st_sql1 = '
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 11 ELSE 5 END THEN 1 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr11 ELSE hb.hr5 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr5, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 12 ELSE 6 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr12 ELSE hb.hr6 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr6,
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 13 ELSE 7 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr13 ELSE hb.hr7 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr7,       
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 14 ELSE 8 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr14 ELSE hb.hr8 END,0) as numeric(1,0)))*' + @col_exp2 +'*' + @col_exp3 + ') AS Hr8, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 15 ELSE 9 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr15 ELSE hb.hr9 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr9,  
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 16 ELSE 10 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr16 ELSE hb.hr10 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr10, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 17 ELSE 11 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr17 ELSE hb.hr11 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr11, '
		
			SET @st_sql2 = '
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 18 ELSE 12 END THEN 1 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr18 ELSE hb.hr12 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr12, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 19 ELSE 13 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr19 ELSE hb.hr13 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr13, 	
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 20 ELSE 14 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr20 ELSE hb.hr14 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr14, 
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 21 ELSE 15 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr21 ELSE hb.hr15 END,0) as numeric(1,0)))*' +@col_exp2 + '*' + @col_exp3 + ') AS Hr15,   
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 22 ELSE 16 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr22 ELSE hb.hr16 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr16,       
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 23 ELSE 17 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr23 ELSE hb.hr17 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr17, 	
				sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN pdd.commodity_id=-1 THEN 24 ELSE 18 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb.hr24 ELSE hb.hr18 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr18, '
			
			SET @st_sql3 = '
				sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 1 ELSE 19 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr1 ELSE hb.hr19 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr19, 
				sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 2 ELSE 20 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr2 ELSE hb.hr20 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr20 ,
				sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 3 ELSE 21 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr3 ELSE hb.hr21 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr21,	
				sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 4 ELSE 22 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr4 ELSE hb.hr22 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr22, 
				sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 5 ELSE 23 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr5 ELSE hb.hr23 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr23, 
				sum((cast(CASE WHEN isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN pdd.commodity_id=-1 THEN 6 ELSE 24 END THEN 1.000 else 0 end +isnull(CASE WHEN pdd.commodity_id=-1 THEN hb1.hr6 ELSE hb.hr24 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ')  AS Hr24, 
				sum(isnull(' +@dst_column + ',0)*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr25,getdate() create_ts,max(pdd.create_user) create_user
				,hb.term_date expiration_date,isnull(mb.period,0) period,max(pdd.granularity) granularity,pdd.source_deal_detail_id,pdd.rowid' --15 minute & 30 min is replace by  hour
			
			SET @st_from = @report_hourly_position_deal_main + 
					'
			 From #tmp_pos_deal_detail pdd
				outer apply (
					select nullif(count(1),0) no_days from hour_block_term (nolock) where
						dst_group_value_id=pdd.dst_group_value_id AND block_define_id = pdd.block_define_id
						and term_date between pdd.term_start and pdd.term_end and (pdd.hourly_volume_allocation <17603 or pdd.physical_financial_flag=''p'') and volume_mult<>0
				) hb_term_day	
				outer apply (
					select nullif(count(1),0) no_days from hour_block_term hbt (nolock) 
						inner join (select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=pdd.exp_calendar_id and h.exp_date between pdd.term_start  and pdd.term_END ) ex on ex.exp_date=hbt.term_date
					where  hbt.dst_group_value_id=pdd.dst_group_value_id and hbt.block_define_id=pdd.block_define_id
						and hbt.term_date between pdd.term_start  and pdd.term_END and pdd.hourly_volume_allocation IN(17603,17604) and pdd.physical_financial_flag=''f'' and hbt.volume_mult<>0
				) term_hrs_exp_day
				LEFT JOIN hour_block_term hb with (nolock) on
					hb.dst_group_value_id=pdd.dst_group_value_id and hb.block_define_id=pdd.block_define_id
					and hb.term_date between pdd.term_start and pdd.term_end
				LEFT OUTER JOIN hour_block_term hb1 (nolock) ON  hb1.dst_group_value_id=hb.dst_group_value_id
					AND hb1.block_define_id=hb.block_define_id AND hb1.term_date-1=hb.term_date
				left join hour_block_term hb_term1 (nolock) 
					on  hb_term1.dst_group_value_id=pdd.dst_group_value_id AND hb_term1.block_define_id =pdd.block_define_id
					and hb_term1.term_date = hb1.term_date and (pdd.hourly_volume_allocation <17603 or pdd.physical_financial_flag=''p'')
				left join hour_block_term hb_term (nolock) on hb_term.dst_group_value_id=pdd.dst_group_value_id
					AND hb_term.block_define_id = pdd.block_define_id and
						hb_term.term_date=hb.term_date and (pdd.hourly_volume_allocation <17603 or pdd.physical_financial_flag=''p'')
				outer apply (
					select  nullif(sum(volume_mult),0) term_no_hrs from hour_block_term hbt (nolock) inner join 
					(select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=pdd.exp_calendar_id and h.exp_date=hb.term_date ) ex 
						on hbt.dst_group_value_id=pdd.dst_group_value_id
							 and hbt.block_define_id=pdd.block_define_id and hbt.term_date=hb.term_date and
						ex.exp_date=hbt.term_date and pdd.hourly_volume_allocation IN(17603,17604) and pdd.physical_financial_flag=''f''
				) term_hrs_exp	
				outer apply  (select distinct exp_date from holiday_group h (nolock) WHERE h.exp_date=hb.term_date and h.hol_group_value_id=pdd.exp_calendar_id
					 and h.exp_date between pdd.term_start  and pdd.term_END ) hg 
				LEFT JOIN report_hourly_position_deal rhpd 
					ON rhpd.source_deal_detail_id = pdd.source_deal_detail_id
						AND rhpd.term_start = hb.term_date  and isnull(rhpd.curve_id,-1)=-1
				left join #minute_break mb on mb.granularity=pdd.granularity  
			WHERE   rhpd.source_deal_header_id IS NULL AND hb.term_date is not null
					and ((pdd.hourly_volume_allocation IN(17603,17604) and  hg.exp_date is not null) or (pdd.hourly_volume_allocation<17603 )  or pdd.physical_financial_flag=''p'')
			group by pdd.source_deal_detail_id,pdd.rowid,hb.term_date,isnull(mb.period,0)
	'
			EXEC spa_print @st_sql0
			EXEC spa_print @st_sql
			EXEC spa_print @st_sql1
			EXEC spa_print @st_sql2
			EXEC spa_print @st_sql3
			EXEC spa_print @st_from

			EXEC (@st_sql0+@st_sql + @st_sql1 + @st_sql2 + @st_sql3 + @st_from)
		END --deal_volume	
	END

	-----------------------------------------------------------------------------------------------------
	--profile & forcaste data inserting
	--------------------------------------------------------------------------------------------------------
	--if isnull(@deal_type,17301)=17301 --profile & forcaste  deal
	BEGIN
		SET @deal_detail_hour = 'dbo.deal_detail_hour'

		IF @orginal_insert_type = 12
		BEGIN
			SET @insert_type = 0
			/*
			TRUNCATE TABLE #tmp_header_deal_id

			SET @st_sql = 'INSERT INTO #tmp_header_deal_id (source_deal_header_id,create_user,source_deal_detail_id) 
			select max(ed.source_deal_header_id),max(ed.create_user) ,ed.source_deal_detail_id
			from ' + @effected_deals + ' ed (nolock) INNER JOIN source_deal_header sdh (nolock) on ed.source_deal_header_id=sdh.source_deal_header_id 
			INNER JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id and hourly_position_breakdown is not null
			GROUP BY ed.source_deal_detail_id'

			EXEC spa_print @st_sql

			EXEC (@st_sql)
			*/
			IF EXISTS (SELECT 1	FROM #tmp_header_deal_id) AND isnull(@orginal_insert_type, 0) NOT IN (111,222) --delete updated deals before inserting
			BEGIN
				SET @st_sql = 'delete s ' + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
			' output deleted.source_deal_header_id,deleted.term_start,deleted.deal_date,deleted.deal_volume_uom_id,deleted.hr1,deleted.hr2,deleted.hr3,deleted.hr4,deleted.hr5,deleted.hr6,deleted.hr7,deleted.hr8,deleted.hr9,deleted.hr10,deleted.hr11,deleted.hr12,deleted.hr13,deleted.hr14,deleted.hr15,deleted.hr16,deleted.hr17,deleted.hr18,deleted.hr19,deleted.hr20,deleted.hr21,deleted.hr22,deleted.hr23,deleted.hr24,deleted.hr25,deleted.create_ts,deleted.create_user,deleted.expiration_date,deleted.period,deleted.granularity
			,deleted.source_deal_detail_id,deleted.rowid 
			into #report_hourly_position_old(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid) '
			END + ' 
			from report_hourly_position_profile_main s INNER JOIN #tmp_header_deal_id h ON s.source_deal_detail_id=h.source_deal_detail_id
			   inner join source_deal_detail sdd on sdd.source_deal_detail_id=h.source_deal_detail_id
			where sdd.position_formula_id is null
			  ' -- where h.[action]=''u'''\

				EXEC spa_print @st_sql
				EXEC (@st_sql)
			END
		END

		--IF ISNULL(@insert_type, 0) = 0
		--BEGIN
			SET @destination_tbl = 'dbo.report_hourly_position_profile_main'
		--END
		

		SET @destination_tbl = CASE WHEN isnull(@orginal_insert_type, 0) IN (111,222) THEN '' ELSE ' INSERT INTO ' + @destination_tbl + '(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid)' 
		+ CASE WHEN ISNULL(@insert_type, 0) = 0 THEN ' output inserted.source_deal_header_id,inserted.term_start,inserted.deal_date,inserted.deal_volume_uom_id,inserted.hr1,inserted.hr2,inserted.hr3,inserted.hr4,inserted.hr5,inserted.hr6,inserted.hr7,inserted.hr8,inserted.hr9,inserted.hr10,inserted.hr11,inserted.hr12,inserted.hr13,inserted.hr14,inserted.hr15,inserted.hr16,inserted.hr17,inserted.hr18,inserted.hr19,inserted.hr20,inserted.hr21,inserted.hr22,inserted.hr23,inserted.hr24,inserted.hr25,inserted.create_ts,inserted.create_user,inserted.expiration_date,inserted.period,inserted.granularity,inserted.source_deal_detail_id,inserted.rowid
		into #report_hourly_position_inserted(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid)
		'
	 ELSE '' END END

	--	IF isnull(@fixation, 4101) <> 4100 --orginal or not fixation deal
		BEGIN
			--IF OBJECT_ID('tempdb..#tmp_location_profile1') IS NOT NULL
			--	DROP TABLE #tmp_location_profile1

			IF  OBJECT_ID('tempdb..#tmp_profile_data') IS  NOT NULL
				DROP TABLE #tmp_profile_data

			IF  OBJECT_ID('tempdb..#tmp_location_profile_mtj') IS  NOT NULL
				DROP TABLE #tmp_location_profile_mtj

			IF  OBJECT_ID('tempdb..#temp_deal_detail_hour') IS NOT NULL
				DROP TABLE #temp_deal_detail_hour

			IF OBJECT_ID('tempdb..#tmp_profile_header') IS NOT NULL
				DROP TABLE #tmp_profile_header

			create table #tmp_location_profile_mtj (
				 source_deal_detail_id int
				,profile_id int
				,profile_type int
				,term_date date
				,term_start date
				,term_end date
				,dst_group_value_id int
			)

		set @st_sql='insert into #tmp_location_profile_mtj (source_deal_detail_id,profile_id,profile_type,term_start,term_end,dst_group_value_id ) SELECT source_deal_detail_id,profile_id,profile_type,term_start,term_end,dst_group_value_id FROM '+@tmp_location_profile
		
		EXEC spa_print @st_sql
		exec(@st_sql)


		select tlp.profile_id,sdh.source_deal_header_id, isnull(sdd.curve_id,-1) curve_id,isnull(sdd.location_id,-1) location_id,sdh.deal_date,spcd.commodity_id,sdh.counterparty_id,ssbm.fas_book_id
			,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4,COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) volume_uom_id,sdd.physical_financial_flag ,sdd.term_start,sdd.term_end
			,COALESCE(spcd.block_define_id,sdh.block_define_id,@baseload_block_define_id ) block_define_id,COALESCE(spcd.block_type,sdh.block_type,@baseload_block_type) block_type
			--,case when tlp.profile_type is null then 
			--cast(CASE WHEN sdd.deal_volume_frequency='h' THEN cast(sdd.deal_volume  as numeric(20,10)) *cast(cast(ISNULL(sdd.multiplier,1) as numeric(21,16)) *cast(ISNULL(sdd.volume_multiplier2,1) as numeric(21,16)) as numeric(21,16)) ELSE cast(sddp.total_volume as numeric(26,10))/nullif(hb_term.term_hours,0) END AS numeric(32,16))
			--else 
			--cast(cast(COALESCE(case when sdd.physical_financial_flag='p' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) as numeric(21,16))*cast(COALESCE(conv1.conversion_factor,1) as numeric(21,16)) as numeric(21,16))*cast(ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1) AS  numeric(25,16))
			--end  * cast(CASE WHEN sdd.buy_sell_flag='b' THEN 1 ELSE -1 END as numeric(1,0)) AS Hr_factor
			,case when tlp.profile_type is null then 
				cast(CASE WHEN sdd.deal_volume_frequency='h' THEN cast(sdd.deal_volume  as numeric(20,10)) *cast(cast(ISNULL(sdd.multiplier,1) as numeric(21,16)) *cast(ISNULL(sdd.volume_multiplier2,1) as numeric(21,16)) as numeric(21,16)) ELSE cast(sdd.total_volume as numeric(26,10))/nullif(hb_term.term_hours,0) END AS numeric(32,16))
			 else 
				cast(COALESCE(case when sdd.physical_financial_flag='p' then dm.physical_density_mult else dm.financial_density_mult end,conv1.conversion_factor,conv.conversion_factor,1) as numeric(21,16))
				*cast(ISNULL(sdd.multiplier,1)*case when sdd.deal_volume_uom_id =@mw_id or sdd.deal_volume_uom_id =@kw_id then ISNULL(sdd.volume_multiplier2,1)/isnull(mw.factor,1.00) else ISNULL(sdd.volume_multiplier2,1) end  AS numeric(25,16))
			end * cast(CASE WHEN sdd.buy_sell_flag='b' THEN 1 ELSE -1 END as numeric(1,0)) AS Hr_factor

			,isnull(sdh.product_id,4101) product_id,sdh.internal_desk_id,sdd.standard_yearly_volume,tlp.profile_type,sdd.term_end expiration_date
			,sdh.close_reference_id ref_deal_id ,isnull(sdh.product_id,4101) fixation,ISNULL(sdd.multiplier,1) multiplier
			,ISNULL(sdd.volume_multiplier2,1) volume_multiplier2,sdh.deal_status
			,tlp.dst_group_value_id,thdi.source_deal_detail_id,thdi.rowid,thdi.granularity
			,sdh.internal_deal_subtype_value_id
		INTO #tmp_profile_header
		FROM source_deal_detail	sdd
			inner join source_minor_location sml  on sdd.location_id=sml.source_minor_location_id
			inner join #tmp_location_profile_mtj tlp on tlp.source_deal_detail_id=sdd.source_deal_detail_id 
			INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id 
			INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
				and  ISNULL(sdh.internal_desk_id,17300)=17301
			left join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
			left join source_system_book_map ssbm on sdh.source_system_book_id1=ssbm.source_system_book_id1
				and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
				and sdh.source_system_book_id4=ssbm.source_system_book_id4
			left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
			left join forecast_profile fp on fp.profile_id=tlp.profile_id
			left join rec_volume_unit_conversion conv on conv.from_source_uom_id=fp.uom_id and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) 
			left join rec_volume_unit_conversion conv1 on conv1.from_source_uom_id=sdd.deal_volume_uom_id and conv1.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) 		
			left join #density_multiplier dm on sdd.source_deal_detail_id=dm.source_deal_detail_id 
			outer apply 
			( 
				select nullif(sum(volume_mult),0) term_hours from hour_block_term where dst_group_value_id=tlp.dst_group_value_id 
					AND block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,@baseload_block_define_id )
					and term_date between sdd.term_start and sdd.term_end  
			) hb_term
			left join (select distinct granularity,factor from #minute_break) mw on mw.granularity=thdi.granularity
		
		where  (sdd.fixed_float_leg='t') AND ISNULL(sdh.product_id,4101)<>4100 and sdd.position_formula_id is null



			/* Added to handle case of duplicate term date caused by blocks. 
				Same term date hour data is summed to handle the issue
			*/

		

		select DISTINCT profile_id into #tmp_profile_data  FROM #tmp_location_profile_mtj

		SELECT term_date,ddh.profile_id,isnull([period],0) [period],SUM(Hr1) Hr1,SUM(Hr2) Hr2,SUM(Hr3) Hr3,SUM(Hr4) Hr4,SUM(Hr5) Hr5,SUM(Hr6) Hr6,
			SUM(Hr7) Hr7,SUM(Hr8) Hr8,SUM(Hr9) Hr9,SUM(Hr10) Hr10,SUM(Hr11) Hr11,SUM(Hr12) Hr12,SUM(Hr13) Hr13,SUM(Hr14) Hr14,
			SUM(Hr15) Hr15,SUM(Hr16) Hr16,SUM(Hr17) Hr17,SUM(Hr18) Hr18,SUM(Hr19) Hr19,SUM(Hr20) Hr20,SUM(Hr21) Hr21,SUM(Hr22) Hr22,
			SUM(Hr23) Hr23,SUM(Hr24) Hr24,SUM(Hr25) Hr25
		INTO #temp_deal_detail_hour
		FROM deal_detail_hour ddh INNER JOIN #tmp_profile_data tfd
			ON tfd.profile_id = ddh.profile_id
		GROUP BY ddh.term_date,ddh.profile_id,[period]

		SET @deal_detail_hour = '#temp_deal_detail_hour'
		CREATE INDEX indx_tmp_profile_header_profile_id ON #tmp_profile_header (profile_id)

		CREATE INDEX indx_tmp_profile_header_block ON #tmp_profile_header (block_define_id)

		CREATE INDEX index_tmp_profile_headerwww ON #tmp_profile_header ([source_deal_header_id],location_id,curve_id)
		CREATE INDEX index_tmp_profile_headernnn ON #tmp_profile_header ([source_deal_detail_id])

		CREATE INDEX indx_tmp_profile_header_term ON #tmp_profile_header (term_start,term_end)

		set @st_sql='UPDATE #tmp_profile_header
		SET Hr_factor = cast(Hr_factor AS NUMERIC(24, 16)) 
		* cast(CASE WHEN commodity_id = - 2 AND profile_type = 17502 THEN ---Power profile type=National profile
			cast(cast(sdd.standard_yearly_volume AS NUMERIC(24, 14)) / nullif(yr.tot_yr_fraction, 0) AS NUMERIC(26, 14))
			ELSE sdd.standard_yearly_volume END AS NUMERIC(26, 14))
		FROM #tmp_profile_header sdd
			LEFT JOIN '+@total_yr_fraction+'  yr ON sdd.[source_deal_header_id] = yr.source_deal_header_id
				AND sdd.location_id = yr.location_id AND sdd.curve_id = yr.curve_id AND yr.yr = year(sdd.term_start)
		WHERE profile_type <> 17500
			AND profile_type IS NOT NULL --profile_type:forecast
			'

		exec spa_print @st_sql
		exec(@st_sql)


		SET @dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 else 1 end as numeric(1,0))'

		--inserting FOR PROFILE TYPE =Forecast (profile_type=17500 )  and commodity= not GAS
		--	IF @commodity_id IS NULL OR @commodity_id <> - 1
		BEGIN
			SET @st_sql = @destination_tbl + 
			'
			SELECT distinct tph.source_deal_header_id,hb.term_date term_start,deal_date,volume_uom_id deal_volume_uom_id,
				CASE WHEN hb.Hr1=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr1 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr1,
				CASE WHEN hb.Hr2=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr2 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr2,
				CASE WHEN hb.Hr3=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr3 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr3,
				CASE WHEN hb.Hr4=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr4 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr4,
				CASE WHEN hb.Hr5=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr5 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr5,
				CASE WHEN hb.Hr6=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr6 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr6,
		'
			SET @st_sql1 = 
				'CASE WHEN hb.Hr7=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr7 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr7,
				CASE WHEN hb.Hr8=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr8 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr8,
				CASE WHEN hb.Hr9=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr9 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr9,
				CASE WHEN hb.Hr10=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr10 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr10,
				CASE WHEN hb.Hr11=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr11 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr11,
				CASE WHEN hb.Hr12=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr12 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr12,
				CASE WHEN hb.Hr13=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr13 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr13,
				CASE WHEN hb.Hr14=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr14 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr14,
				CASE WHEN hb.Hr15=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr15 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr15,
			'
			SET @st_sql2 = 
			'
				CASE WHEN hb.Hr16=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr16 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr16,
				CASE WHEN hb.Hr17=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr17 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr17,
				CASE WHEN hb.Hr18=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr18 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr18,
				CASE WHEN hb.Hr19=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr19 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr19,
				CASE WHEN hb.Hr20=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr20 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr20,
				CASE WHEN hb.Hr21=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr21 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr21,
				CASE WHEN hb.Hr22=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr22 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr22,
				CASE WHEN hb.Hr23=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr23 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr23,
				CASE WHEN hb.Hr24=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr24 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr24,
				Cast(cast(ISNULL(ddh.Hr25,0) as numeric(24,14))*isnull(' 
					+ @dst_column + ',0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) AS Hr25 
				,getdate() create_ts,thdi.create_user,COALESCE(h_grp.exp_date,tph.expiration_date,tph.term_start) expiration_date
				,isnull(ddh.period,0) period,thdi.granularity,tph.source_deal_detail_id,tph.rowid
			'
			SET @st_from = @report_hourly_position_profile_main + '
			FROM  #tmp_profile_header tph  
				inner JOIN hour_block_term hb (nolock) on hb.dst_group_value_id=tph.dst_group_value_id and hb.block_define_id=tph.block_define_id 
					and hb.term_date between tph.term_start and tph.term_end  AND tph.commodity_id<>-1
				inner join ' + @deal_detail_hour + ' ddh (nolock) on tph.profile_id=ddh.profile_id AND  hb.term_date=ddh.term_date
				LEFT JOIN #tmp_header_deal_id thdi ON tph.source_deal_detail_id=thdi.source_deal_detail_id
				outer apply (select MAX(exp_date) exp_date from holiday_group h
					inner join source_price_curve_def spcd on  h.hol_group_value_id=spcd.exp_calendar_id
						and spcd.source_curve_def_id=tph.curve_id and h.hol_group_value_id=spcd.exp_calendar_id
						and ((tph.physical_financial_flag=''p'' and tph.internal_deal_subtype_value_id='+@CFD_id+') or tph.physical_financial_flag=''f'' or  ISNULL(spcd.hourly_volume_allocation,17601) =17606)
						and tph.term_start between h.hol_date AND isnull(nullif(h.hol_date_to,''1900-01-01''),h.hol_date)
				) h_grp 
			where tph.profile_type is NOT NULL and hb.term_date is not null
				'

				EXEC spa_print @st_sql
				EXEC spa_print @st_sql1
				EXEC spa_print @st_sql2
				EXEC spa_print @st_from
				EXEC (@st_sql + @st_sql1 + @st_sql2 + @st_from)
			END --if @commodity_id is null or @commodity_id<>-1

			SET @dst_column = 'cast(CASE WHEN isnull(CASE WHEN tph.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END,0)<=0 THEN 0 else 1 end as numeric(1,0))'

			--inserting FOR PROFILE TYPE =Forecast (profile_type=17500 ) and commodity=GAS
		--	IF  @commodity_id = - 1
			BEGIN
				SET @st_sql = @destination_tbl + 
				'
				SELECT distinct tph.source_deal_header_id,hb.term_date term_start,deal_date,volume_uom_id deal_volume_uom_id,
					CASE WHEN hb.Hr7=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr7 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr1,
					CASE WHEN hb.Hr8=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr8 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr2,
					CASE WHEN hb.Hr9=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr9 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr3,
					CASE WHEN hb.Hr10=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr10 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr4,
					CASE WHEN hb.Hr11=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr11 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr5,
					CASE WHEN hb.Hr12=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr12 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr6,
			'
			SET @st_sql1 = 
				'CASE WHEN hb.Hr13=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr13 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr7,
				CASE WHEN hb.Hr14=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr14 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr8,
				CASE WHEN hb.Hr15=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr15 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr9,
				CASE WHEN hb.Hr16=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr16 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr10,
				CASE WHEN hb.Hr17=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr17 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr11,
				CASE WHEN hb.Hr18=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr18 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr12,
				CASE WHEN hb.Hr19=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr19 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr13,
				CASE WHEN hb.Hr20=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr20 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr14,
				CASE WHEN hb.Hr21=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr21 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr15,
			'
			SET @st_sql2 = 
					'
				CASE WHEN hb.Hr22=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr22 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr16,
				CASE WHEN hb.Hr23=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr23 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr17,
				CASE WHEN hb.Hr24=0  THEN 0 ELSE  cast(ISNULL( ddh.Hr24 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr18,
				CASE WHEN hb1.Hr1=0  THEN 0 ELSE  cast(ISNULL( ddh1.Hr1 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr19,
				CASE WHEN hb1.Hr2=0  THEN 0 ELSE  cast(ISNULL( ddh1.Hr2 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr20,
				CASE WHEN hb1.Hr3=0  THEN 0 ELSE  cast(ISNULL( ddh1.Hr3 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr21,
				CASE WHEN hb1.Hr4=0  THEN 0 ELSE  cast(ISNULL( ddh1.Hr4 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr22,
				CASE WHEN hb1.Hr5=0  THEN 0 ELSE  cast(ISNULL( ddh1.Hr5 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr23,
				CASE WHEN hb1.Hr6=0  THEN 0 ELSE  cast(ISNULL( ddh1.Hr6 ,0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) END Hr24,
				Cast(cast(ISNULL(ddh1.Hr25,0) as numeric(24,14))*isnull(' 
				+ @dst_column + ',0) as numeric(24,14))*cast(tph.Hr_factor as numeric(26,16)) AS Hr25 ,getdate() create_ts,thdi.create_user,COALESCE(h_grp.exp_date,tph.expiration_date,tph.term_start) expiration_date,isnull(ddh.period,0) period,thdi.granularity,tph.source_deal_detail_id,tph.rowid
			'
			SET @st_from = @report_hourly_position_profile_main + '
			FROM  #tmp_profile_header tph  
				inner JOIN hour_block_term hb (nolock) on hb.dst_group_value_id=tph.dst_group_value_id and hb.block_define_id=tph.block_define_id 		and hb.term_date between tph.term_start AND tph.term_end  AND tph.commodity_id=-1
				left join ' + @deal_detail_hour + ' ddh (nolock) on tph.profile_id=ddh.profile_id AND  hb.term_date=ddh.term_date
				LEFT OUTER JOIN hour_block_term hb1 (nolock) ON hb1.dst_group_value_id=hb.dst_group_value_id
					AND hb1.block_define_id=hb.block_define_id
					AND hb1.term_date-1=hb.term_date
				inner join ' + @deal_detail_hour + 
					' ddh1 (nolock) on tph.profile_id=ddh1.profile_id AND  hb1.term_date=ddh1.term_date and ddh.period=ddh1.period
				LEFT JOIN #tmp_header_deal_id thdi ON tph.source_deal_detail_id=thdi.source_deal_detail_id
				outer apply (select MAX(exp_date) exp_date from holiday_group h
					inner join source_price_curve_def spcd on  h.hol_group_value_id=spcd.exp_calendar_id
						and spcd.source_curve_def_id=tph.curve_id and h.hol_group_value_id=spcd.exp_calendar_id
						and ((tph.physical_financial_flag=''p'' and tph.internal_deal_subtype_value_id='+@CFD_id+') or tph.physical_financial_flag=''f'' or ISNULL(spcd.hourly_volume_allocation,17601) =17606)
						and tph.term_start between h.hol_date AND isnull(nullif(h.hol_date_to,''1900-01-01''),h.hol_date)
				) h_grp 
				where tph.profile_type is NOT NULL and hb.term_date is not null
					and tph.profile_id is not null
				'

				EXEC spa_print @st_sql
				EXEC spa_print @st_sql1
				EXEC spa_print @st_sql2
				EXEC spa_print @st_from

				EXEC (@st_sql + @st_sql1 + @st_sql2 + @st_from)
			END


			SET @dst_column = 'cast(CASE WHEN isnull(CASE WHEN tph.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END,0)<=0 THEN 0 else 1 end as numeric(1,0))'
			---------------------------------------------------------------------------
			-- Forecast deal that do not have profile id in location table treat as deal volume type where hourly position is equal for all the hour of the term
			------------------------------------------------------------------
			SET @st_sql = @destination_tbl + 
			'
			SELECT distinct tph.source_deal_header_id,hb.term_date term_start,tph.deal_date,
			tph.volume_uom_id deal_volume_uom_id,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 7 ELSE 1  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr7 ELSE hb.hr1 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr1,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 8 ELSE 2  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr8 ELSE hb.hr2 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr2,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 9 ELSE 3  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr9 ELSE hb.hr3 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr3,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 10 ELSE 4  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr10 ELSE hb.hr4 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr4,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 11 ELSE 5  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr11 ELSE hb.hr5 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr5,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 12 ELSE 6  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr12 ELSE hb.hr6 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr6,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 13 ELSE 7  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr13 ELSE hb.hr7 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr7,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 14 ELSE 8  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr14 ELSE hb.hr8 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr8,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 15 ELSE 9  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr15 ELSE hb.hr9 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr9,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 16 ELSE 10  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr16 ELSE hb.hr10 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr10,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 17 ELSE 11  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr17 ELSE hb.hr11 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr11,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 18 ELSE 12  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr18 ELSE hb.hr12 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr12,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 19 ELSE 13  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr19 ELSE hb.hr13 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr13,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 20 ELSE 14  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr20 ELSE hb.hr14 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr14,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 21 ELSE 15  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr21 ELSE hb.hr15 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr15,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 22 ELSE 16  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr22 ELSE hb.hr16 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr16,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 23 ELSE 17  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr23 ELSE hb.hr17 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr17,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 24 ELSE 18  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr24 ELSE hb.hr18 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr18,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 1 ELSE 19  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr1 ELSE hb.hr19 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr19,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 2 ELSE 20  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr2 ELSE hb.hr20 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr20,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 3 ELSE 21  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr3 ELSE hb.hr21 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr21,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 4 ELSE 22  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr4 ELSE hb.hr22 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr22,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 5 ELSE 23  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr5 ELSE hb.hr23 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1) Hr23,
			 (cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN tph.commodity_id=-1 THEN 6 ELSE 24  END THEN 1.000 else 0 end + isnull(CASE WHEN tph.commodity_id=-1 THEN hb.hr6 ELSE hb.hr24 END,0) as numeric(1,0)))*tph.Hr_factor/isnull(mb.factor,1)/isnull(mb.factor,1) Hr24,
			 isnull(' 
				+ @dst_column + ',0)*tph.Hr_factor/isnull(mb.factor,1) AS Hr25 ,getdate() create_ts,thdi.create_user,COALESCE(h_grp.exp_date,tph.expiration_date,tph.term_start) expiration_date,isnull(mb.period,0) period,thdi.granularity,tph.source_deal_detail_id,tph.rowid'
		SET @st_from = @report_hourly_position_profile_main + 
		'
		FROM  #tmp_profile_header tph  
			LEFT JOIN hour_block_term hb (nolock) on hb.dst_group_value_id=tph.dst_group_value_id and hb.block_define_id=tph.block_define_id 			and hb.term_date between tph.term_start AND tph.term_end 
			LEFT OUTER JOIN hour_block_term hb1 (nolock) ON hb1.dst_group_value_id=tph.dst_group_value_id
				AND hb1.block_define_id=hb.block_define_id AND hb1.term_date-1=hb.term_date
			LEFT JOIN #tmp_header_deal_id thdi ON tph.source_deal_detail_id=thdi.source_deal_detail_id
			outer apply (select MAX(exp_date) exp_date from holiday_group h
				inner join source_price_curve_def spcd on  h.hol_group_value_id=spcd.exp_calendar_id
					and spcd.source_curve_def_id=tph.curve_id and h.hol_group_value_id=spcd.exp_calendar_id
					and ((tph.physical_financial_flag=''p'' and tph.internal_deal_subtype_value_id='+@CFD_id+') or tph.physical_financial_flag=''f'' or  ISNULL(spcd.hourly_volume_allocation,17601) =17606)
					and tph.term_start between h.hol_date AND isnull(nullif(h.hol_date_to,''1900-01-01''),h.hol_date)
				) h_grp 
			left join #minute_break mb on mb.granularity=thdi.granularity  
			where tph.profile_type is null and hb.term_date is not null
		'

			EXEC spa_print @st_sql
			EXEC spa_print @st_from

			EXEC (@st_sql + @st_from)

		END --orginal or not fixation deal
	END --isnull(@deal_type,17301)=17301 --profile & forcaste  deal
		--------###############################################################			
		--------########## Break down Fixed Physical deal and save in different table

	IF  isnull(@orginal_insert_type, 0) NOT IN (111,222)
	BEGIN
		SET @st_sql = ' DELETE rhpf ' + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
		' output deleted.source_deal_header_id,deleted.term_start,deleted.deal_date,deleted.deal_volume_uom_id,deleted.hr1,deleted.hr2,deleted.hr3,deleted.hr4,deleted.hr5,deleted.hr6,deleted.hr7,deleted.hr8,deleted.hr9,deleted.hr10,deleted.hr11,deleted.hr12,deleted.hr13,deleted.hr14,deleted.hr15,deleted.hr16,deleted.hr17,deleted.hr18,deleted.hr19,deleted.hr20,deleted.hr21,deleted.hr22,deleted.hr23,deleted.hr24,deleted.hr25,deleted.create_ts,deleted.create_user,deleted.expiration_date,deleted.period,deleted.granularity,deleted.source_deal_detail_id,deleted.rowid 
		into #report_hourly_position_old (source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid) '
			END + '
		FROM report_hourly_position_fixed_main  rhpf (nolock)
			INNER JOIN #tmp_header_deal_id_del thdi on rhpf.source_deal_detail_id=thdi.source_deal_detail_id '

		EXEC spa_print @st_sql

		EXEC (@st_sql)


		--	set @col_exp1='cast(ISNULL(sdd.multiplier,1) as numeric(21,16))*cast(ISNULL(sdd.volume_multiplier2,1) as numeric(21,16))* cast(CASE WHEN sdd.buy_sell_flag=''b'' THEN 1 ELSE -1 END as numeric(1,0))'
		SET @col_exp1 = 'cast(ISNULL(sdd.multiplier,1) as numeric(21,16))'
		SET @col_exp2 = '1'
		SET @st_sql = ' INSERT INTO dbo.report_hourly_position_fixed_main(source_deal_header_id,term_start,deal_date
				,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17
				,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period, granularity,source_deal_detail_id,rowid
			)' + CASE WHEN ISNULL(@insert_type, 0) = 0 THEN 
			' output inserted.source_deal_header_id,inserted.term_start,inserted.deal_date,inserted.deal_volume_uom_id,inserted.hr1,inserted.hr2,inserted.hr3,inserted.hr4,inserted.hr5,inserted.hr6,inserted.hr7,inserted.hr8,inserted.hr9,inserted.hr10,inserted.hr11,inserted.hr12,inserted.hr13,inserted.hr14,inserted.hr15,inserted.hr16,inserted.hr17,inserted.hr18,inserted.hr19,inserted.hr20,inserted.hr21,inserted.hr22,inserted.hr23,inserted.hr24,inserted.hr25,inserted.create_ts,inserted.create_user,inserted.expiration_date,inserted.period,inserted.granularity ,inserted.source_deal_detail_id,inserted.rowid
			into #report_hourly_position_inserted (source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid)'
		 ELSE '' END + '
		SELECT
			sdh.source_deal_header_id,
			ISNULL(rhpp.term_start,rhpd.term_start) term_start,MAX(sdh.deal_date) deal_date
			,MAX(ISNULL(rhpp.deal_volume_uom_id,rhpd.deal_volume_uom_id)) deal_volume_uom_id,
			SUM(ISNULL(rhpp.hr1,rhpd.hr1)*' + @col_exp1 + '*' + @col_exp2 + ') hr1,
			SUM(ISNULL(rhpp.hr2,rhpd.hr2)*' + @col_exp1 + '*' + @col_exp2 + ') hr2,
			SUM(ISNULL(rhpp.hr3,rhpd.hr3)*' + @col_exp1 + '*' + @col_exp2 + ') hr3,
			SUM(ISNULL(rhpp.hr4,rhpd.hr4)*' + @col_exp1 + '*' + @col_exp2 + ') hr4,
			SUM(ISNULL(rhpp.hr5,rhpd.hr5)*' + @col_exp1 + '*' + @col_exp2 + ') hr5,
			SUM(ISNULL(rhpp.hr6,rhpd.hr6)*' + @col_exp1 + '*' + @col_exp2 + ') hr6,
			SUM(ISNULL(rhpp.hr7,rhpd.hr7)*' + @col_exp1 + '*' + @col_exp2 + ') hr7,
			SUM(ISNULL(rhpp.hr8,rhpd.hr8)*' + @col_exp1 + '*' + @col_exp2 + ') hr8,
			SUM(ISNULL(rhpp.hr9,rhpd.hr9)*' + @col_exp1 + '*' + @col_exp2 + ') hr9,
			SUM(ISNULL(rhpp.hr10,rhpd.hr10)*' + @col_exp1 + '*' + @col_exp2 + ') hr10,
			SUM(ISNULL(rhpp.hr11,rhpd.hr11)*' + @col_exp1 + '*' + @col_exp2 + ') hr11,
			SUM(ISNULL(rhpp.hr12,rhpd.hr12)*' + @col_exp1 + '*' + @col_exp2 + ') hr12,
			SUM(ISNULL(rhpp.hr13,rhpd.hr13)*' + @col_exp1 + '*' + @col_exp2 + ') hr13,
			SUM(ISNULL(rhpp.hr14,rhpd.hr14)*' + @col_exp1 + '*' + @col_exp2 + ') hr14,
			SUM(ISNULL(rhpp.hr15,rhpd.hr15)*' + @col_exp1 + '*' + @col_exp2 + ') hr15,
			SUM(ISNULL(rhpp.hr16,rhpd.hr16)*' + @col_exp1 + '*' + @col_exp2 + ') hr16,
			SUM(ISNULL(rhpp.hr17,rhpd.hr17)*' + @col_exp1 + '*' + @col_exp2 + ') hr17,
			SUM(ISNULL(rhpp.hr18,rhpd.hr18)*' + @col_exp1 + '*' + @col_exp2 + ') hr18,
			SUM(ISNULL(rhpp.hr19,rhpd.hr19)*' + @col_exp1 + '*' + @col_exp2 + ') hr19,
			SUM(ISNULL(rhpp.hr20,rhpd.hr20)*' + @col_exp1 + '*' + @col_exp2 + ') hr20,
			SUM(ISNULL(rhpp.hr21,rhpd.hr21)*' + @col_exp1 + '*' + @col_exp2 + ') hr21,
			SUM(ISNULL(rhpp.hr22,rhpd.hr22)*' + @col_exp1 + '*' + @col_exp2 + ') hr22,
			SUM(ISNULL(rhpp.hr23,rhpd.hr23)*' + @col_exp1 + '*' + @col_exp2 + ') hr23,
			SUM(ISNULL(rhpp.hr24,rhpd.hr24)*' + @col_exp1 + '*' + @col_exp2 + ') hr24,
			SUM(ISNULL(rhpp.hr25,rhpd.hr25)*' + @col_exp1 + '*' + @col_exp2 + ') hr25
			,getdate() create_ts,max(thdi.create_user) create_user,ISNULL(rhpp.expiration_date,rhpd.expiration_date) expiration_date,
			coalesce(rhpp.period,rhpd.period,0) period
			,ISNULL(rhpp.granularity,rhpd.granularity) granularity,thdi.source_deal_detail_id,thdi.rowid
		'
		SET @st_sql1 ='		
		FROM source_deal_header sdh  with (nolock) 
			INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id 
			INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id --and ISNULL(sdh.internal_desk_id,17300)=17300
			INNER JOIN source_deal_header sdh1 (nolock) ON sdh1.source_deal_header_id=sdh.close_reference_id
			LEFT JOIN source_deal_detail sdd1 (nolock) ON sdd1.source_deal_header_id=sdh1.source_deal_header_id
				AND isnull(sdd1.curve_id,-1)=coalesce(sdd.curve_id,sdd1.curve_id,-1)
				AND sdd1.term_start=sdd.term_start AND sdd.leg=sdd1.leg
			LEFT JOIN report_hourly_position_profile rhpp (nolock) ON rhpp.term_start BETWEEN sdd.term_start AND sdd.term_end
				AND rhpp.source_deal_detail_id=sdd1.source_deal_detail_id
			LEFT JOIN report_hourly_position_deal rhpd (nolock) ON 
				 rhpd.term_start BETWEEN sdd.term_start AND sdd.term_end and rhpd.source_deal_detail_id = thdi.source_deal_detail_id
			left join source_price_curve_def spcd (nolock) on spcd.source_curve_def_id=ISNULL(rhpp.curve_id,rhpd.curve_id)
		WHERE
			ISNULL(sdh.product_id,4101)=4100 AND ISNULL(sdh.internal_desk_id,17300)=17301  and ISNULL(rhpp.term_start,rhpd.term_start) is not null
		GROUP BY thdi.source_deal_detail_id,thdi.rowid,sdh.source_deal_header_id,sdd.curve_id,ISNULL(rhpp.term_start,rhpd.term_start),sdd.location_id
		,coalesce(rhpp.period,rhpd.period,0),ISNULL(rhpp.granularity,rhpd.granularity),ISNULL(rhpp.expiration_date,rhpd.expiration_date)							
			'

		EXEC spa_print @st_sql
		EXEC spa_print @st_sql1
		EXEC (@st_sql + @st_sql1)

		---###### for fixation deals with fixed volume use the volume from the same deal
		SET @col_exp2 = 'cast(CASE WHEN sdd.deal_volume_frequency=''h'' THEN cast(sdd.deal_volume  as numeric(22,10)) *cast(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) as numeric(21,16))*cast(cast(ISNULL(sdd.multiplier,1) as numeric(21,16)) *cast(ISNULL(sdd.volume_multiplier2,1) as numeric(15,10)) as numeric(21,16)) ELSE cast(sddp.total_volume as numeric(26,10))/nullif(isnull(hb_term.term_hours,term_hrs_exp.term_no_hrs),0) END AS NUMERIC(32,16))'
		SET @col_exp3 = 'cast(CASE WHEN buy_sell_flag=''b'' THEN 1 ELSE -1 END as numeric(1,0))'
		SET @dst_column = 'cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END,0)<=0 THEN 0 else 1 end as numeric(1,0))'
		SET @st_sql = 'insert into dbo.report_hourly_position_fixed_main(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid) ' 
		+ CASE WHEN ISNULL(@insert_type, 0) = 0 THEN 
		' output inserted.source_deal_header_id,inserted.term_start,inserted.deal_date,inserted.deal_volume_uom_id,inserted.hr1,inserted.hr2,inserted.hr3,inserted.hr4,inserted.hr5,inserted.hr6,inserted.hr7,inserted.hr8,inserted.hr9,inserted.hr10,inserted.hr11,inserted.hr12,inserted.hr13,inserted.hr14,inserted.hr15,inserted.hr16,inserted.hr17,inserted.hr18,inserted.hr19,inserted.hr20,inserted.hr21,inserted.hr22,inserted.hr23,inserted.hr24,inserted.hr25,inserted.create_ts,inserted.create_user,inserted.expiration_date,inserted.period,inserted.granularity,inserted.source_deal_detail_id,inserted.rowid
		into #report_hourly_position_inserted(source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,expiration_date,period,granularity,source_deal_detail_id,rowid) '  ELSE '' END + '
		SELECT max(sdh.source_deal_header_id),
			hb.term_date term_start,max(sdh.deal_date) deal_date,max(COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)) deal_volume_uom_id,
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 7 ELSE 1  END THEN 1.000 else 0 end + isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr7 ELSE hb.hr1 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 +') AS Hr1,  
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 8 ELSE 2 END THEN 1.000 else 0 end + isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr8 ELSE hb.hr2 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr2, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 9 ELSE 3 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr9 ELSE hb.hr3 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr3, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 10 ELSE 4 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr10 ELSE hb.hr4 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr4, '
		
		SET @st_sql1 = 'SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 11 ELSE 5 END THEN 1 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr11 ELSE hb.hr5 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr5, 
			sum((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 12 ELSE 6 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr12 ELSE hb.hr6 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr6,
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 13 ELSE 7 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr13 ELSE hb.hr7 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr7,       
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 14 ELSE 8 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr14 ELSE hb.hr8 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr8, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 15 ELSE 9 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr15 ELSE hb.hr9 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr9,  
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 16 ELSE 10 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr16 ELSE hb.hr10 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr10, 
			SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 17 ELSE 11 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr17 ELSE hb.hr11 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr11, '
		
	SET @st_sql2 = 'SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 18 ELSE 12 END THEN 1 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr18 ELSE hb.hr12 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr12, 
		SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 19 ELSE 13 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr19 ELSE hb.hr13 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr13, 	
		SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 20 ELSE 14 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr20 ELSE hb.hr14 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr14, 
		SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 21 ELSE 15 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr21 ELSE hb.hr15 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr15,   
		SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 22 ELSE 16 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr22 ELSE hb.hr16 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr16,       
		SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 23 ELSE 17 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr23 ELSE hb.hr17 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr17, 	
		SUM((cast(CASE WHEN isnull(hb.add_dst_hour,0)=CASE WHEN spcd.commodity_id=-1 THEN 24 ELSE 18 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb.hr24 ELSE hb.hr18 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr18, '
		
	SET @st_sql3 = 'SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 1 ELSE 19 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr1 ELSE hb.hr19 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr19, 
		SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 2 ELSE 20 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr2 ELSE hb.hr20 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr20 ,
		SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 3 ELSE 21 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr3 ELSE hb.hr21 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + 
			' )  AS Hr21,	
		SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 4 ELSE 22 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr4 ELSE hb.hr22 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr22, 
		SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 5 ELSE 23 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr5 ELSE hb.hr23 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr23, 
		SUM((cast(CASE WHEN isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.add_dst_hour ELSE hb.add_dst_hour END ,0)=CASE WHEN spcd.commodity_id=-1 THEN 6 ELSE 24 END THEN 1.000 else 0 end +isnull(CASE WHEN spcd.commodity_id=-1 THEN hb1.hr6 ELSE hb.hr24 END,0) as numeric(1,0)))*' + @col_exp2 + '*' + @col_exp3 + ' )  AS Hr24, 
		SUM(isnull(' + @dst_column + ',0)*' + @col_exp2 + '*' + @col_exp3 + ') AS Hr25,getdate() create_ts,max(thdi.create_user) create_user
		,isnull(h_grp.exp_date,hb.term_date) expiration_date,0 period,max(thdi.granularity) granularity,thdi.source_deal_detail_id,thdi.rowid'
		
	SET @st_from = 
	' FROM source_deal_header sdh  with (nolock) 
		INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id --  and sdd.curve_id is not null
		INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id  
			and ISNULL(sdh.internal_desk_id,17300)=17300 --and ISNULL(sdh.product_id,-1)<>4100  --this condition is for applying fixation so it will not inserted for fixation logic.
		INNER JOIN source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
			and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
				and sdh.source_system_book_id4=ssbm.source_system_book_id4
		left join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
		LEFT JOIN source_price_curve_def spcd  with (nolock) ON spcd.source_curve_def_id=sdd.curve_id
		LEFT JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
		outer apply ( select nullif(sum(volume_mult),0) term_hours from hour_block_term (nolock) where
			dst_group_value_id=isnull(thdi.dst_group_value_id,'+@default_dst_group+') AND block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,'+ @baseload_block_define_id + ')
			and term_date between sdd.term_start and sdd.term_end and (isnull(spcd.hourly_volume_allocation,17601) <17603 or sdd.physical_financial_flag=''p'')
		) hb_term		
		outer apply (
			select sum(volume_mult) term_no_hrs from hour_block_term hbt (nolock) inner join (select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) and h.exp_date between sdd.term_start  and sdd.term_END ) ex on ex.exp_date=hbt.term_date
			where hbt.dst_group_value_id=isnull(thdi.dst_group_value_id,'+@default_dst_group+') 
				and hbt.block_define_id=COALESCE(spcd.block_define_id,' + @baseload_block_define_id +') 
				and hbt.term_date between sdd.term_start  and sdd.term_END 
				and isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and sdd.physical_financial_flag=''f''
		) term_hrs_exp
		LEFT JOIN hour_block_term hb with (nolock) on hb.dst_group_value_id=isnull(thdi.dst_group_value_id,'+@default_dst_group+') AND 
			hb.block_define_id=COALESCE(spcd.block_define_id,sdh.block_define_id,' + @baseload_block_define_id + ')  
			and hb.term_date between sdd.term_start and sdd.term_end
		left join rec_volume_unit_conversion conv (nolock) on conv.from_source_uom_id=sdd.deal_volume_uom_id
				and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		left join #density_multiplier dm on sdd.source_deal_detail_id=dm.source_deal_detail_id 	
		outer apply  (select distinct exp_date from holiday_group h (nolock) where h.exp_date=hb.term_date and h.hol_group_value_id=ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) and h.exp_date between sdd.term_start  and sdd.term_END ) hg  
		LEFT OUTER JOIN hour_block_term hb1 (nolock) ON hb1.dst_group_value_id=hb.dst_group_value_id  
			AND hb1.block_define_id=hb.block_define_id AND hb1.term_date-1=hb.term_date
		outer apply (
			select MAX(exp_date) exp_date from holiday_group where hol_group_value_id=spcd.exp_calendar_id
				and ((sdd.physical_financial_flag=''p'' and sdh.internal_deal_subtype_value_id='+@CFD_id+') or sdd.physical_financial_flag=''f'' or ISNULL(spcd.hourly_volume_allocation,17601) =17606)
				and hb.term_date between hol_date AND isnull(hol_date_to,hol_date)
		) h_grp 
		where  spcd.formula_id IS  NULL and  (sdd.fixed_float_leg=''t'') AND ISNULL(sdh.product_id,4101)= 4100	
				and ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 )  or sdd.physical_financial_flag=''p'') and hb.term_date is not null
		group by thdi.source_deal_detail_id,thdi.rowid,hb.term_date,isnull(h_grp.exp_date,hb.term_date) '

		EXEC spa_print @st_sql
		EXEC spa_print @st_sql1
		EXEC spa_print @st_sql2
		EXEC spa_print @st_sql3
		EXEC spa_print @st_from

		EXEC (@st_sql + @st_sql1 + @st_sql2 + @st_sql3 + @st_from)

		--------------------------------------------------------------------------------------------------------------
		----total volume update
		---------------------------------------------------------------------------------------------------------------
	


	
		SET @st_sql = '
			SELECT isnull(sdd.curve_id, - 1) fixation_curve_id,sdd.term_start,sdd.term_end,sdd.curve_id
				,rl.location_id,sdd.leg,rl.fixation_deal_id,rl.source_deal_header_id,rl.multiplier,rl.volume_multiplier2
			INTO #tmp_fixation
			FROM source_deal_detail sdd(NOLOCK)
			INNER JOIN '+@ref_location+' rl ON rl.[fixation_deal_id] = sdd.[source_deal_header_id]
				AND rl.curve_id = sdd.curve_id
				AND sdd.curve_id IS NOT NULL
			UNION ALL
			SELECT isnull(sdd.curve_id, - 1) fixation_curve_id,sdd.term_start,sdd.term_end,rl.curve_id
				,rl.location_id,sdd.leg,rl.fixation_deal_id
				,rl.source_deal_header_id,rl.multiplier,rl.volume_multiplier2
			FROM source_deal_detail sdd(NOLOCK)
			INNER JOIN '+@ref_location+' rl ON rl.[fixation_deal_id] = sdd.[source_deal_header_id]
				AND sdd.curve_id IS NULL;

			select tft.fixation_deal_id source_deal_header_id,tft.fixation_curve_id curve_id,tft.term_start,tft.term_end,tft.leg,sum(abs(CAST(vol.term_volume AS NUMERIC(22,10))*(CAST(ISNULL(tft.multiplier,1) AS NUMERIC(24,16))*CAST(ISNULL(tft.volume_multiplier2,1) AS NUMERIC(24,16))))) fixation_vol 
			into #fixation_volume
			from #tmp_fixation tft
				outer  apply 
				(
					select term_start,hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24 term_volume 
					from report_hourly_position_profile_main rp 
						inner join dbo.position_report_group_map map on map.rowid=rp.rowid
					where rp.term_start between tft.term_start and tft.term_end 
						and map.curve_id=tft.curve_id and map.location_id=isnull(tft.location_id,-1) and tft.source_deal_header_id=rp.source_deal_header_id
				) vol	
			group by tft.fixation_deal_id ,tft.term_start,tft.term_end,tft.leg,tft.fixation_curve_id;		  	
		
			delete sddp
				FROM source_deal_detail  sdd with (nolock)
				inner join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
				INNER JOIN #fixation_volume f on f.source_deal_header_id=sdd.source_deal_header_id and isnull(sdd.curve_id,-1)=f.curve_id 
					and f.term_start=sdd.term_start and f.term_end=sdd.term_end and f.leg =sdd.leg;

			insert into source_deal_detail_position(source_deal_detail_id,total_volume,position_report_group_map_rowid)
			select sdd.source_deal_detail_id,
				CAST(f.fixation_vol AS NUMERIC(22,10))*cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(21,14))
				,thdi.rowid
			FROM source_deal_detail  sdd with (nolock)
				INNER JOIN #fixation_volume f on f.source_deal_header_id=sdd.source_deal_header_id and isnull(sdd.curve_id,-1)=f.curve_id 
					and f.term_start=sdd.term_start and f.term_end=sdd.term_end and f.leg =sdd.leg	
				left JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id; 
				'

		EXEC spa_print @st_sql
		EXEC (@st_sql)
	END --fixation deal 4100			

	--------------------------------------------------------------------------------------------------------------
	----inserting delta for left hand side deal
	---------------------------------------------------------------------------------------------------------------
	--Delta inserting
	-------------------------------------------------------------------------------------------------------------------------------
	IF isnull(@maintain_delta, 0) = 1 --and ISNULL(@insert_type,0)=0
	BEGIN
		IF EXISTS ( SELECT 1 FROM #report_hourly_position_old )
		BEGIN
			SET @st_sql = 
			'insert into dbo.delta_report_hourly_position_main(as_of_date,source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,delta_type,expiration_date,period,granularity,source_deal_detail_id,rowid)
			select getdate() as_of_date
			,isnull(o.source_deal_header_id,n.source_deal_header_id),isnull(o.term_start,n.term_start),isnull(o.deal_date,n.deal_date),isnull(o.deal_volume_uom_id,n.deal_volume_uom_id),
			isnull(n.hr1,0)-isnull(o.hr1,0) hr1,isnull(n.hr2,0)-isnull(o.hr2,0) hr2,isnull(n.hr3,0)-isnull(o.hr3,0) hr3,isnull(n.hr4,0)-isnull(o.hr4,0) hr4,isnull(n.hr5,0)-isnull(o.hr5,0) hr5,isnull(n.hr6,0)-isnull(o.hr6,0) hr6,isnull(n.hr7,0)-isnull(o.hr7,0) hr7,isnull(n.hr8,0)-isnull(o.hr8,0) hr8,isnull(n.hr9,0)-isnull(o.hr9,0) hr9,isnull(n.hr10,0)-isnull(o.hr10,0) hr10 ,isnull(n.hr11,0)-isnull(o.hr11,0) hr11
			,isnull(n.hr12,0)-isnull(o.hr12,0) hr12,isnull(n.hr13,0)-isnull(o.hr13,0) hr13,isnull(n.hr14,0)-isnull(o.hr14,0) hr14,isnull(n.hr15,0)-isnull(o.hr15,0) hr15,isnull(n.hr16,0)-isnull(o.hr16,0) hr16,isnull(n.hr17,0)-isnull(o.hr17,0) hr17,isnull(n.hr18,0)-isnull(o.hr18,0) hr18,isnull(n.hr19,0)-isnull(o.hr19,0) hr19,isnull(n.hr20,0)-isnull(o.hr20,0) hr20,isnull(n.hr21,0)-isnull(o.hr21,0) hr21
			,isnull(n.hr22,0)-isnull(o.hr22,0) hr22,isnull(n.hr23,0)-isnull(o.hr23,0) hr23,isnull(n.hr24,0)-isnull(o.hr24,0) hr24,isnull(n.hr25,0)-isnull(o.hr25,0) hr25
			,isnull(o.create_ts,getdate()),isnull(o.create_user,dbo.fnadbuser()),' 
		+ CASE WHEN ISNULL(@orginal_insert_type, 0) = 0 THEN '17404' ELSE '17403' END + 
		' delta_type ,isnull(o.expiration_date,n.expiration_date),isnull(o.period ,n.period),isnull(o.granularity ,n.granularity),isnull(o.source_deal_detail_id,n.source_deal_detail_id),isnull(o.rowid,n.rowid)
		from  #report_hourly_position_old o full JOIN  #report_hourly_position_inserted n on o.term_start=n.term_start	 
			and o.source_deal_detail_id=n.source_deal_detail_id and isnull(o.period,0)= isnull(n.period,0)
		where (abs(isnull(n.hr1,0)-isnull(o.hr1,0))	+abs(isnull(n.hr2,0)-isnull(o.hr2,0))
			+abs(isnull(n.hr3,0)-isnull(o.hr3,0))+abs(isnull(n.hr4,0)-isnull(o.hr4,0))
			+abs(isnull(n.hr5,0)-isnull(o.hr5,0))+abs(isnull(n.hr6,0)-isnull(o.hr6,0))
			+abs(isnull(n.hr7,0)-isnull(o.hr7,0))+abs(isnull(n.hr8,0)-isnull(o.hr8,0))
			+abs(isnull(n.hr9,0)-isnull(o.hr9,0))+abs(isnull(n.hr10,0)-isnull(o.hr10,0))
			+abs(isnull(n.hr11,0)-isnull(o.hr11,0))+abs(isnull(n.hr12,0)-isnull(o.hr12,0))
			+abs(isnull(n.hr13,0)-isnull(o.hr13,0))+abs(isnull(n.hr14,0)-isnull(o.hr14,0))
			+abs(isnull(n.hr15,0)-isnull(o.hr15,0))+abs(isnull(n.hr16,0)-isnull(o.hr16,0))
			+abs(isnull(n.hr17,0)-isnull(o.hr17,0))+abs(isnull(n.hr18,0)-isnull(o.hr18,0))
			+abs(isnull(n.hr19,0)-isnull(o.hr19,0))+abs(isnull(n.hr20,0)-isnull(o.hr20,0))
			+abs(isnull(n.hr21,0)-isnull(o.hr21,0))+abs(isnull(n.hr22,0)-isnull(o.hr22,0))
			+abs(isnull(n.hr23,0)-isnull(o.hr23,0))+abs(isnull(n.hr24,0)-isnull(o.hr24,0))
			+abs(isnull(n.hr25,0)-isnull(o.hr25,0)))>0'

			EXEC spa_print @st_sql

			EXEC (@st_sql)
		END
	END

	--------------------------------------------------------------------------------------------------------------
	----formula beakdown or financial data inserting
	---------------------------------------------------------------------------------------------------------------


	IF ISNULL(@insert_type, 0) = 0 OR ISNULL(@insert_type, 0) = 9
	BEGIN
		IF isnull(@maintain_delta, 0) = 1
		BEGIN
			CREATE TABLE #report_hourly_position_breakdown_main_inserted (
				[source_deal_header_id] [int] NULL
				,[curve_id] [int] NULL
				,[term_start] [datetime] NULL
				,[deal_date] [datetime] NULL
				,[deal_volume_uom_id] [int] NULL
				,[create_ts] [datetime] NULL
				,[create_user] [varchar](30) NULL
				,[calc_volume] NUMERIC(38, 20) NULL
				,[term_end] [datetime] NULL
				,expiration_date DATETIME
				,formula VARCHAR(100) NULL
				,source_deal_detail_id int
				,rowid int
				)

			DECLARE @report_hourly_position_breakdown_main_old TABLE (
				[source_deal_header_id] [int] NULL
				,[curve_id] [int] NULL
				,[term_start] [datetime] NULL
				,[deal_date] [datetime] NULL
				,[deal_volume_uom_id] [int] NULL
				,[create_ts] [datetime] NULL
				,[create_user] [varchar](30) NULL
				,[calc_volume] NUMERIC(38, 20) NULL
				,[term_end] [datetime] NULL
				,expiration_date DATETIME
				,deal_status INT
				,formula VARCHAR(100) NULL
				,[source_deal_detail_id] [int] NULL
				,[rowid] [int] NULL
				)

		END

		CREATE TABLE #tmp_financial_term (
			source_deal_header_id INT
			,leg INT
			,curve_id INT
			,del_term_start DATETIME
			,del_term_end DATETIME
			,fin_term_start DATETIME
			,fin_term_end DATETIME
			,multiplier NUMERIC(21, 16)
			,del_vol_multiplier NUMERIC(24, 16)
			,location_id INT
			,hourly_volume_allocation INT
			,physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
			,volume_uom_id INT
			,fin_term_vol NUMERIC(38, 20)
			,expiration_date DATETIME
			,commodity_id INT
			,phy_curve_id INT
			,phy_location_id INT
			,buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT
			,total_volume NUMERIC(26, 10)
			,fixing INT
			,fix_multiplier NUMERIC(21, 16)
			,fix_volume_multiplier2 NUMERIC(21, 16)
			,pay_opposite VARCHAR(1) COLLATE DATABASE_DEFAULT
			,formula VARCHAR(100) COLLATE DATABASE_DEFAULT
			,multiplier2 NUMERIC(21, 16)
			,source_deal_detail_id int
			,rowid int
			)



		/*	
value_id type_id	code
17602	17600	Daily Allocation
17601	17600	Monthly Average Allocations
17600	17600	TOU Allocations	
	*/
	SET @st_sql = 
	'
	INSERT INTO #tmp_financial_term (
		source_deal_header_id ,leg,curve_id ,del_term_start ,del_term_end,fin_term_start,fin_term_end ,multiplier ,del_vol_multiplier 
		,location_id,hourly_volume_allocation,physical_financial_flag,volume_uom_id, expiration_date,commodity_id,phy_curve_id,phy_location_id
		,buy_sell_flag,total_volume,fixing,fix_multiplier,fix_volume_multiplier2,pay_opposite,formula,source_deal_detail_id,rowid)
	SELECT term.source_deal_header_id ,max(term.leg) leg,term.curve_id ,min(term.del_term_start) del_term_start
		,max(term.del_term_end) del_term_end,term.fin_term_start,term.fin_term_end ,avg(term.multiplier) multiplier
		,avg(term.del_vol_multiplier) del_vol_multiplier,term.location_id
		,max(term.hourly_volume_allocation) hourly_volume_allocation,term.physical_financial_flag,term.volume_uom_id
		,term.expiration_date,max(term.commodity_id) commodity_id,term.phy_curve_id,term.phy_location_id,MAX(buy_sell_flag)
		,sum(term.total_volume) total_volume,max(term.fixing) fixing,avg(term.fix_volume_multiplier2) fix_volume_multiplier2
		,avg(term.fix_multiplier) fix_multiplier, max(term.pay_opposite) pay_opposite ,MAX(formula),term.source_deal_detail_id,max(term.rowid) rowid
	from (
		SELECT sdd.source_deal_header_id ,sdd.leg leg,dpbd.curve_id ,dpbd.del_term_start,dateadd(month,1,dpbd.del_term_start)-1 del_term_end
			,min(dpbd.fin_term_start) fin_term_start,max(dpbd.fin_term_end) fin_term_end
			,avg(dpbd.multiplier) multiplier,avg(dpbd.del_vol_multiplier) del_vol_multiplier
			,case when dpbd.derived_curve_id is  null then NULL else sdd.location_id end location_id
			,max(isnull(spcd.hourly_volume_allocation,17601)) hourly_volume_allocation
			,max(COALESCE(spcd.block_define_id,'+ @baseload_block_define_id + ')) block_define_id
			,max(COALESCE(spcd.block_type,sdh.block_type,' + @baseload_block_type + ')) block_type
			,max(case when dpbd.derived_curve_id is  null then ''f'' else sdd.physical_financial_flag end) physical_financial_flag
			,max(COALESCE(sdd.position_uom,spcd1.display_uom_id,spcd1.uom_id)) volume_uom_id
			,max(ISNULL(dpbd.fin_expiration_date,sdd.term_end)) expiration_date,max(spcd.commodity_id) commodity_id,sdd.curve_id phy_curve_id,isnull(sdd.location_id,-1) phy_location_id,
			MAX(sdd.buy_sell_flag) buy_sell_flag,max(sddp.total_volume) total_volume,isnull(max(sdh.product_id),4101) fixing
			,max(sdd.volume_multiplier2) fix_volume_multiplier2 ,max(sdd.multiplier) fix_multiplier,max(sdd.pay_opposite) pay_opposite,
			MAX(formula) formula,thdi.source_deal_detail_id,max(thdi.rowid) rowid				
		FROM  source_deal_header sdh with (nolock) INNER JOIN 
		source_deal_detail sdd  with (nolock) on sdd.source_deal_header_id=sdh.source_deal_header_id ' 
		+ CASE WHEN ISNULL(@insert_type, 0) = 0
			THEN ' INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id' ELSE '' END + '
		INNER JOIN deal_position_break_down dpbd with (nolock) ON dpbd.source_deal_detail_id=sdd.source_deal_detail_id 
		left join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=dpbd.curve_id
		left JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=sdd.curve_id
		WHERE 1=1 --AND sdd.fixed_float_leg=''t'' 
			and isnull(spcd.hourly_volume_allocation,17601) in (17600,17602,17603,17604,17605)
		Group by  sdd.source_deal_header_id,sdd.leg,sdd.curve_id,dpbd.curve_id,sdd.location_id
			,case when dpbd.derived_curve_id is null then NULL else sdd.location_id end,dpbd.del_term_start
			,thdi.source_deal_detail_id
	) term
	Group by  term.source_deal_header_id,term.curve_id,term.phy_curve_id,term.phy_location_id,term.location_id
		,term.fin_term_start,term.fin_term_end,term.expiration_date,term.physical_financial_flag,term.volume_uom_id
		,term.source_deal_detail_id
		'

		EXEC spa_print @st_sql

		EXEC (@st_sql)

		--SELECT * FROM static_data_value WHERE TYPE_ID=17600
		CREATE INDEX indx_tmp_financial_term ON #tmp_financial_term (
			source_deal_header_id
			,phy_curve_id
			,phy_location_id
			,del_term_start
			,del_term_end
			)

		UPDATE #tmp_financial_term
		SET fin_term_vol = cast(isnull(term.multiplier, 1) AS NUMERIC(24, 16)) * cast(term.total_volume AS NUMERIC(30, 16))
			,del_vol_multiplier = cast(isnull(term.del_vol_multiplier, 1) AS NUMERIC(24, 16)) * CASE 
				WHEN pay_opposite = 'y' THEN - 1 ELSE 1 END
			,multiplier2 = CASE WHEN isnull(term.del_vol_multiplier, 1) < 0 THEN -1 ELSE 1 END * CASE WHEN pay_opposite = 'y' THEN -1 ELSE 1 END
		FROM #tmp_financial_term term
		WHERE fixing = 4100

		UPDATE #tmp_financial_term
		SET fin_term_vol = cast(isnull(term.multiplier, 1) AS NUMERIC(24, 16)) * cast(ABS(rp.term_volume) AS NUMERIC(22, 10)) 
			* CASE WHEN term.buy_sell_flag = 'b' AND rp.term_volume < 0 THEN -1 ELSE 1 END
			,del_vol_multiplier = cast(isnull(term.del_vol_multiplier, 1) AS NUMERIC(24, 16))
			,multiplier2 = CASE WHEN isnull(term.del_vol_multiplier, 1) < 0 THEN -1 ELSE 1 END
			,volume_uom_id=rp.deal_volume_uom_id
		FROM #tmp_financial_term term
		INNER JOIN (
				SELECT term.del_term_start
					,term.del_term_end
					,term.source_deal_detail_id
					,max(rp.deal_volume_uom_id) deal_volume_uom_id
					,(sum(hr1 + hr2 + hr3 + hr4 + hr5 + hr6 + hr7 + hr8 + hr9 + hr10 + hr11 + hr12 + hr13 + hr14 + hr15 + hr16 + hr17
					 + hr18 + hr19 + hr20 + hr21 + hr22 + hr23 + hr24)) term_volume
				FROM #report_hourly_position_inserted rp(NOLOCK)
				INNER JOIN (select distinct source_deal_detail_id,del_term_start,del_term_end from #tmp_financial_term  where fixing <> 4100 ) term
					 on term.source_deal_detail_id = rp.source_deal_detail_id
					 and rp.term_start BETWEEN term.del_term_start AND term.del_term_end
				GROUP BY term.source_deal_detail_id
					,term.del_term_start
					,term.del_term_end
			) rp ON  rp.del_term_start = term.del_term_start
				AND rp.del_term_end = term.del_term_end
				AND term.source_deal_detail_id = rp.source_deal_detail_id

		CREATE INDEX indx_tmp_financial_term1 ON #tmp_financial_term (fin_term_start,fin_term_end)

		IF isnull(@orginal_insert_type, 0) NOT IN (111,222)
		BEGIN
			IF ISNULL(@insert_type, 0) = 0
			BEGIN
				IF isnull(@maintain_delta, 0) = 0
					DELETE s FROM report_hourly_position_breakdown_main s
						INNER JOIN #tmp_header_deal_id_del t ON s.source_deal_detail_id = t.source_deal_detail_id
				ELSE
					DELETE s
					OUTPUT deleted.source_deal_header_id
						,deleted.curve_id
						,deleted.term_start
						,deleted.deal_date
						,deleted.deal_volume_uom_id
						,deleted.create_ts
						,deleted.create_user
						,deleted.calc_volume
						,deleted.term_end
						,deleted.expiration_date
						,deleted.formula
						,deleted.source_deal_detail_id
						,deleted.rowid
					INTO @report_hourly_position_breakdown_main_old(source_deal_header_id, curve_id, term_start, deal_date, deal_volume_uom_id, create_ts, create_user, calc_volume, term_end, expiration_date,  formula,source_deal_detail_id,rowid)
					FROM report_hourly_position_breakdown_main s
					INNER JOIN #tmp_header_deal_id_del t ON s.source_deal_detail_id = t.source_deal_detail_id
			END
		END

		--17602	17600	Daily Allocation
		--17600	17600	Monthly Average Allocation
		--17601	17600	TOU Allocation			
		--CREATE INDEX indx_tmp_term_financial_vol ON #tmp_term_financial_vol (source_deal_header_id ,curve_id ,location_id,del_term_start,del_term_end,fin_term_start,fin_term_end )
		--save the record term level(strip_to) volume for 17600 Monthly Average Allocation	
		SET @destination_tbl = CASE WHEN isnull(@orginal_insert_type, 0) IN ( 111 ,222 ) THEN ''
			ELSE 'insert  into dbo.report_hourly_position_breakdown_main(source_deal_header_id,curve_id,term_start,deal_date,deal_volume_uom_id,create_ts,create_user,calc_volume,term_end,expiration_date,formula,source_deal_detail_id,rowid) '
			 + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
				CASE WHEN EXISTS ( SELECT 1 FROM @report_hourly_position_breakdown_main_old )
					THEN ' output inserted.source_deal_header_id,inserted.curve_id,inserted.term_start,inserted.deal_date,inserted.deal_volume_uom_id,inserted.create_ts,inserted.create_user,inserted.calc_volume,inserted.term_end,inserted.expiration_date
					,inserted.formula,inserted.source_deal_detail_id,inserted.rowid
			 into #report_hourly_position_breakdown_main_inserted(source_deal_header_id,curve_id,term_start,deal_date,deal_volume_uom_id,create_ts,create_user,calc_volume,term_end,expiration_date,formula,source_deal_detail_id,rowid) ' ELSE '' END
			END END
		SET @st_sql = @destination_tbl + '
		 SELECT tft.source_deal_header_id,tft.curve_id,tft.fin_term_start term_start,
			max(sdh.deal_date) deal_date
			,max(COALESCE(spcd.display_uom_id,spcd.uom_id) ) deal_volume_uom_id, getdate() create_ts,max(thdi.create_user) create_user,
			sum(tft.fin_term_vol*ISNULL(tft.multiplier2,1)*ISNULL(rvuc.conversion_factor, 1)) AS calc_volume,
			tft.fin_term_end term_end,max(COALESCE(h_grp.exp_date,tft.expiration_date)) expiration_date,MAX(tft.formula) formula,thdi.source_deal_detail_id,max(thdi.rowid) rowid ' + @report_hourly_position_breakdown_main + '
		FROM  source_deal_header sdh  with (nolock)
			INNER JOIN #tmp_financial_term tft ON tft.source_deal_header_id=sdh.source_deal_header_id  
				and isnull(tft.hourly_volume_allocation,17601) IN(17600,17604) -- in (17600,17603) --17603 expiration allocation
			left join source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
				and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
				and sdh.source_system_book_id4=ssbm.source_system_book_id4
			inner JOIN #tmp_header_deal_id thdi ON tft.source_deal_detail_id=thdi.source_deal_detail_id
			outer apply (select MAX(exp_date) exp_date from holiday_group h
				inner join source_price_curve_def spcd on  h.hol_group_value_id=spcd.exp_calendar_id
					and spcd.source_curve_def_id=tft.curve_id and h.hol_group_value_id=spcd.exp_calendar_id
					and tft.fin_term_start between h.hol_date AND isnull(nullif(h.hol_date_to,''1900-01-01''),h.hol_date)
			) h_grp
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=tft.curve_id 
			left join rec_volume_unit_conversion rvuc on rvuc.from_source_uom_id = tft.volume_uom_id
				AND rvuc.to_source_uom_id = COALESCE(spcd.display_uom_id,spcd.uom_id)
		Group by  thdi.source_deal_detail_id,tft.source_deal_header_id,tft.curve_id,tft.location_id,tft.physical_financial_flag, tft.volume_uom_id,tft.commodity_id,tft.fin_term_start,tft.fin_term_end'

		EXEC spa_print @st_sql

		EXEC (@st_sql)

		--save the record day level volume for 17602 Daily Allocation	
		SET @st_sql = @destination_tbl + 
		'
		SELECT tft.source_deal_header_id,	tft.curve_id,ISNULL(vol.term_start,tft.fin_term_start) term_start,
			max(sdh.deal_date) deal_date,max(COALESCE(spcd.display_uom_id,spcd.uom_id) ) deal_volume_uom_id
			, getdate() create_ts,max(thdi.create_user) create_user,	
			sum(ISNULL(ABS(vol.term_volume)*ISNULL(tft.del_vol_multiplier,1)* CASE WHEN tft.buy_sell_flag = ''b'' AND vol.term_volume<0 THEN -1 ELSE 1 END,tft.fin_term_vol*multiplier2)*ISNULL(rvuc.conversion_factor, 1)) AS calc_volume,
			ISNULL(vol.term_start,tft.fin_term_end),max(COALESCE(h_grp.exp_date,tft.expiration_date)) expiration_date
			,MAX(tft.formula) formula,thdi.source_deal_detail_id,max(thdi.rowid) rowid' 
				+ @report_hourly_position_breakdown_main + '
		FROM  source_deal_header sdh  with (nolock)
		INNER JOIN  #tmp_financial_term tft ON tft.source_deal_header_id=sdh.source_deal_header_id  
			and isnull(tft.hourly_volume_allocation,17601)=17602
		left join source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
			and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
			and sdh.source_system_book_id4=ssbm.source_system_book_id4
		OUTER  apply (
			select term_start,hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24 term_volume
			from #report_hourly_position_inserted rp (nolock) where rp.term_start between tft.fin_term_start and tft.fin_term_end and  tft.source_deal_detail_id=rp.source_deal_detail_id
		) vol
		inner JOIN #tmp_header_deal_id thdi ON tft.source_deal_detail_id=thdi.source_deal_detail_id
		outer apply (
			select MAX(exp_date) exp_date from holiday_group h
				inner join source_price_curve_def spcd on  h.hol_group_value_id=spcd.exp_calendar_id
					and    spcd.source_curve_def_id=tft.curve_id and h.hol_group_value_id=spcd.exp_calendar_id
					and ISNULL(vol.term_start,tft.fin_term_start) between h.hol_date AND isnull(nullif(h.hol_date_to,''1900-01-01''),h.hol_date)
		) h_grp 
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=tft.curve_id 
		left join rec_volume_unit_conversion rvuc on rvuc.from_source_uom_id = tft.volume_uom_id
					AND rvuc.to_source_uom_id = COALESCE(spcd.display_uom_id,spcd.uom_id)
		group by thdi.source_deal_detail_id,tft.source_deal_header_id,	tft.curve_id,ISNULL(vol.term_start,tft.fin_term_start),ISNULL(vol.term_start,tft.fin_term_end) '

		EXEC spa_print @st_sql

		EXEC (@st_sql)


		--save the record month level volume for 17601	TOU Allocation	
		SET @st_sql = @destination_tbl + 
			'
		SELECT 
			sdh.source_deal_header_id,
			--dpbd.curve_id,
			case when dpbd.derived_curve_id is  null then dpbd.curve_id else sdd.curve_id end curve_id,
			ISNULL(dpbd.fin_term_start,sdd.term_start) term_start,
			max(sdh.deal_date) deal_date,max(COALESCE(spcd.display_uom_id,spcd.uom_id) ) deal_volume_uom_id
			--max(ISNULL(sdd.position_uom,sdd.deal_volume_uom_id)) deal_volume_uom_id,
			--max(ISNULL(spcd1.display_uom_id,spcd1.uom_id)) deal_volume_uom_id,
		 , getdate() create_ts,max(thdi.create_user) create_user,
			sum(cast(sddp.total_volume as numeric(26,10))* cast(CASE WHEN dpbd.curve_id IS NOT NULL THEN COALESCE((dpbd.del_vol_multiplier/nullif(dpbd.multiplier,0))*
			case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,dpbd.del_vol_multiplier,1)  * CASE WHEN sdh.product_id=4100 THEN CASE WHEN sdd.pay_opposite=''y'' THEN -1 ELSE 1 END ELSE 1 END ELSE CASE WHEN buy_sell_flag=''b'' THEN 1 ELSE -1 END END  as numeric(22,16))*ISNULL(rvuc.conversion_factor, 1))   AS calc_volume,
			ISNULL(dpbd.fin_term_end,sdd.term_end) term_end,COALESCE(h_grp.exp_date,dpbd.fin_expiration_date,sdd.term_end) expiration_date,MAX(dpbd.formula) formula,thdi.source_deal_detail_id,max(thdi.rowid) rowid' 
			+ @report_hourly_position_breakdown_main + '
		FROM  source_deal_header sdh  with (nolock)
		INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id  
		INNER JOIN #tmp_header_deal_id thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id
		INNER JOIN deal_position_break_down dpbd with (nolock) ON dpbd.source_deal_header_id=sdh.source_deal_header_id   
			AND sdd.leg=dpbd.leg AND sdd.term_start=dpbd.del_term_start	-- and dpbd.derived_curve_id IS  NULL
		left join dbo.source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
		left join source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
			and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
			and sdh.source_system_book_id4=ssbm.source_system_book_id4
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=dpbd.curve_id
		left JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=sdd.curve_id
		left join #density_multiplier dm on sdd.source_deal_detail_id=dm.source_deal_detail_id and 	
		 COALESCE(sdd.position_uom,spcd1.display_uom_id,spcd1.uom_id)=COALESCE(sdd.position_uom,spcd1.display_uom_id,spcd1.uom_id)	
		outer apply (select MAX(exp_date) exp_date from holiday_group h
			inner join source_price_curve_def spcd on  h.hol_group_value_id=spcd.exp_calendar_id
				and spcd.source_curve_def_id=case when dpbd.derived_curve_id is  null then dpbd.curve_id else sdd.curve_id end and h.hol_group_value_id=spcd.exp_calendar_id
				and ISNULL(dpbd.fin_term_start,sdd.term_start) between h.hol_date AND isnull(nullif(h.hol_date_to,''1900-01-01''),h.hol_date)
			) h_grp
		left join rec_volume_unit_conversion rvuc on rvuc.from_source_uom_id = COALESCE(sdd.position_uom, spcd1.display_uom_id,spcd1.uom_id)
			AND rvuc.to_source_uom_id = COALESCE(spcd.display_uom_id,spcd.uom_id) 
		WHERE dpbd.derived_curve_id is  null and
		    isnull(spcd.hourly_volume_allocation,17601) IN (17601,17603) --Monthly Average allocation;  17603 expiration allocation;   sdh.product_id:4101=orginal 4100=Fixed
		Group by  thdi.source_deal_detail_id,sdh.source_deal_header_id,case when dpbd.derived_curve_id is  null then dpbd.curve_id else sdd.curve_id end,ISNULL(dpbd.fin_term_start,sdd.term_start),ISNULL(dpbd.fin_term_end,sdd.term_end)
		,case when dpbd.derived_curve_id is  null then NULL else sdd.location_id end
		,ISNULL(dpbd.fin_term_end,sdd.term_end),case when dpbd.derived_curve_id is  null then ''f'' else sdd.physical_financial_flag end, COALESCE(h_grp.exp_date,dpbd.fin_expiration_date,sdd.term_end)'

		EXEC spa_print @st_sql

		EXEC (@st_sql)

		IF isnull(@orginal_insert_type, 0) NOT IN (111,222)
		BEGIN
			SET @st_sql = 'delete s ' + CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
		' output 
			deleted.[source_deal_header_id],deleted.[term_start],deleted.[deal_date],deleted.[deal_volume_uom_id]
			 ,deleted.[hr1],deleted.[hr2],deleted.[hr3],deleted.[hr4],deleted.[hr5],deleted.[hr6],deleted.[hr7],deleted.[hr8],deleted.[hr9],deleted.[hr10],deleted.[hr11],deleted.[hr12],deleted.[hr13],deleted.[hr14],deleted.[hr15],deleted.[hr16],deleted.[hr17],deleted.[hr18],deleted.[hr19],deleted.[hr20],deleted.[hr21],deleted.[hr22]
			 ,deleted.[hr23],deleted.[hr24],deleted.[hr25],deleted.[create_ts] ,deleted.[create_user] ,deleted.source_deal_detail_id,deleted.rowid,deleted.granularity,deleted.[period]
		into #report_hourly_position_financial_main_old([source_deal_header_id],[term_start],[deal_date],[deal_volume_uom_id]
			 ,[hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17]
			 ,[hr18],[hr19],[hr20],[hr21],[hr22]
			 ,[hr23],[hr24],[hr25],[create_ts] ,[create_user],source_deal_detail_id,rowid,granularity,[period]) '
			END + ' from report_hourly_position_financial_main s 
			INNER JOIN #tmp_header_deal_id_del h ON s.source_deal_detail_id=h.source_deal_detail_id' -- where h.[action]=''u'''

			EXEC spa_print @st_sql

			EXEC (@st_sql)
		END

		--save the record day level volume for 17605 Same as physical pos 
		SET @st_sql = CASE WHEN isnull(@orginal_insert_type, 0) IN ( 111,222 ) THEN ''
		ELSE 'insert  into dbo.[report_hourly_position_financial_main] 
			( [source_deal_header_id],[term_start],[deal_date],[deal_volume_uom_id]
			,[hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17],[hr18],[hr19],[hr20],[hr21],[hr22],[hr23],[hr24],[hr25],[create_ts],[create_user],source_deal_detail_id,rowid,granularity,[period])' 
			+ CASE WHEN isnull(@maintain_delta, 0) = 0 THEN '' ELSE 
				CASE WHEN EXISTS ( SELECT 1 FROM #report_hourly_position_financial_main_old ) THEN 
			' 
			output inserted.[source_deal_header_id],inserted.[term_start],inserted.[deal_date],inserted.[deal_volume_uom_id],inserted.[hr1],inserted.[hr2],inserted.[hr3],inserted.[hr4],inserted.[hr5],inserted.[hr6],inserted.[hr7],inserted.[hr8],inserted.[hr9],inserted.[hr10],inserted.[hr11],inserted.[hr12],inserted.[hr13],inserted.[hr14],inserted.[hr15],inserted.[hr16],inserted.[hr17],inserted.[hr18],inserted.[hr19],inserted.[hr20],inserted.[hr21],inserted.[hr22],inserted.[hr23],inserted.[hr24],inserted.[hr25],inserted.[create_ts],inserted.[create_user]
			,inserted.source_deal_detail_id,inserted.rowid,inserted.granularity,inserted.[period]
		into #report_hourly_position_financial_main_inserted 
		 (source_deal_header_id,term_start,deal_date,deal_volume_uom_id
		 ,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16
		 ,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,source_deal_detail_id,rowid,granularity,[period])
		' ELSE '' END
		END
	END
		SET @st_sql1 = 
			'  SELECT   vol.[source_deal_header_id],vol.[term_start],vol.[deal_date],vol.[deal_volume_uom_id],
			CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr1,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr2,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr3
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr4,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr5,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr6
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr7,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr8,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr9
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr10,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr11,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr12
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr13,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr14,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr15
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr16,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr17,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr18
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr19,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr20,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr21
				,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr22,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr23,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr24,CASE WHEN tft.pay_opposite=''y'' THEN -1 ELSE 1 END *hr25
			,getdate() [create_ts],''' 
			+ @user_login_id + ''' [create_user],thdi.source_deal_detail_id,thdi.rowid,thdi.granularity,vol.[period] ' + @report_hourly_position_financial_main + '
		FROM  #tmp_header_deal_id thdi
		INNER JOIN  #tmp_financial_term tft ON tft.source_deal_detail_id=thdi.source_deal_detail_id  and isnull(tft.hourly_volume_allocation,17601)=17605 -- and fixing<>4100
		cross  apply (
			select * from #report_hourly_position_inserted rp (nolock) where rp.term_start between tft.fin_term_start and tft.fin_term_end 
			 and tft.source_deal_detail_id=rp.source_deal_detail_id
		) vol	
	'

		EXEC spa_print @st_sql
		EXEC spa_print @st_sql1
		EXEC (@st_sql + @st_sql1)

		IF isnull(@maintain_delta, 0) = 1 --and ISNULL(@insert_type,0)=0
		BEGIN
			IF EXISTS ( SELECT 1 FROM #report_hourly_position_financial_main_old )
			BEGIN
				SET @st_sql = 
				'insert into dbo.delta_report_hourly_position_financial_main (as_of_date,source_deal_header_id,term_start,deal_date,deal_volume_uom_id,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,create_ts,create_user,delta_type,expiration_date,source_deal_detail_id,rowid,granularity,[period])
				select getdate() as_of_date
					,isnull(o.source_deal_header_id,n.source_deal_header_id),isnull(o.term_start,n.term_start),isnull(o.deal_date,n.deal_date),isnull(o.deal_volume_uom_id,n.deal_volume_uom_id),
					isnull(n.hr1,0)-isnull(o.hr1,0) hr1,isnull(n.hr2,0)-isnull(o.hr2,0) hr2,isnull(n.hr3,0)-isnull(o.hr3,0) hr3,isnull(n.hr4,0)-isnull(o.hr4,0) hr4,isnull(n.hr5,0)-isnull(o.hr5,0) hr5,isnull(n.hr6,0)-isnull(o.hr6,0) hr6,isnull(n.hr7,0)-isnull(o.hr7,0) hr7,isnull(n.hr8,0)-isnull(o.hr8,0) hr8,isnull(n.hr9,0)-isnull(o.hr9,0) hr9,isnull(n.hr10,0)-isnull(o.hr10,0) hr10 ,isnull(n.hr11,0)-isnull(o.hr11,0) hr11
					,isnull(n.hr12,0)-isnull(o.hr12,0) hr12,isnull(n.hr13,0)-isnull(o.hr13,0) hr13,isnull(n.hr14,0)-isnull(o.hr14,0) hr14,isnull(n.hr15,0)-isnull(o.hr15,0) hr15,isnull(n.hr16,0)-isnull(o.hr16,0) hr16,isnull(n.hr17,0)-isnull(o.hr17,0) hr17,isnull(n.hr18,0)-isnull(o.hr18,0) hr18,isnull(n.hr19,0)-isnull(o.hr19,0) hr19,isnull(n.hr20,0)-isnull(o.hr20,0) hr20,isnull(n.hr21,0)-isnull(o.hr21,0) hr21
					,isnull(n.hr22,0)-isnull(o.hr22,0) hr22,isnull(n.hr23,0)-isnull(o.hr23,0) hr23,isnull(n.hr24,0)-isnull(o.hr24,0) hr24,isnull(n.hr25,0)-isnull(o.hr25,0) hr25
					,isnull(o.create_ts,getdate()),isnull(o.create_user,dbo.fnadbuser()),' 
			+ CASE WHEN ISNULL(@orginal_insert_type, 0) = 0 THEN '17404' ELSE '17403' END + 
						' delta_type ,isnull(o.expiration_date,n.expiration_date),isnull(o.source_deal_detail_id,n.source_deal_detail_id),isnull(o.rowid,n.rowid),isnull(o.granularity,n.granularity),isnull(o.[period],n.[period])
				from  #report_hourly_position_financial_main_old o full JOIN  #report_hourly_position_financial_main_inserted n
					on 	o.source_deal_detail_id=n.source_deal_detail_id
					 and isnull(o.curve_id,-1)=isnull(n.curve_id,-1) and ISNULL(o.location_id,-1)=ISNULL(n.location_id,-1) and  o.term_start=n.term_start 
					 and o.physical_financial_flag=n.physical_financial_flag
				where (abs(isnull(n.hr1,0)-isnull(o.hr1,0))	+abs(isnull(n.hr2,0)-isnull(o.hr2,0))
				+abs(isnull(n.hr3,0)-isnull(o.hr3,0))+abs(isnull(n.hr4,0)-isnull(o.hr4,0))
				+abs(isnull(n.hr5,0)-isnull(o.hr5,0))+abs(isnull(n.hr6,0)-isnull(o.hr6,0))
				+abs(isnull(n.hr7,0)-isnull(o.hr7,0))+abs(isnull(n.hr8,0)-isnull(o.hr8,0))
				+abs(isnull(n.hr9,0)-isnull(o.hr9,0))+abs(isnull(n.hr10,0)-isnull(o.hr10,0))
				+abs(isnull(n.hr11,0)-isnull(o.hr11,0))+abs(isnull(n.hr12,0)-isnull(o.hr12,0))
				+abs(isnull(n.hr13,0)-isnull(o.hr13,0))+abs(isnull(n.hr14,0)-isnull(o.hr14,0))
				+abs(isnull(n.hr15,0)-isnull(o.hr15,0))+abs(isnull(n.hr16,0)-isnull(o.hr16,0))
				+abs(isnull(n.hr17,0)-isnull(o.hr17,0))+abs(isnull(n.hr18,0)-isnull(o.hr18,0))
				+abs(isnull(n.hr19,0)-isnull(o.hr19,0))+abs(isnull(n.hr20,0)-isnull(o.hr20,0))
				+abs(isnull(n.hr21,0)-isnull(o.hr21,0))+abs(isnull(n.hr22,0)-isnull(o.hr22,0))
				+abs(isnull(n.hr23,0)-isnull(o.hr23,0))+abs(isnull(n.hr24,0)-isnull(o.hr24,0))
				+abs(isnull(n.hr25,0)-isnull(o.hr25,0)))>0'

				EXEC spa_print @st_sql

				--EXEC (@st_sql)
			END
		END

		--------------------------------------------------------------------------------------------------------------
		----inserting delta for right hand side deal
		---------------------------------------------------------------------------------------------------------------
		--Delta inserting
		-------------------------------------------------------------------------------------------------------------------------------
		IF isnull(@maintain_delta, 0) = 1
		BEGIN
			IF EXISTS ( SELECT 1 FROM #report_hourly_position_old )
				INSERT INTO dbo.delta_report_hourly_position_breakdown_main (
					as_of_date
					,source_deal_header_id
					,curve_id
					,term_start
					,deal_date
					,deal_volume_uom_id
					,create_ts
					,create_user
					,calc_volume
					,delta_type
					,expiration_date
					,term_end
					,formula
					,source_deal_detail_id
					,rowid
					)
				SELECT getdate() as_of_date
					,ISNULL(o.source_deal_header_id, n.source_deal_header_id)
					,ISNULL(o.curve_id, n.curve_id)
					,ISNULL(o.term_start, n.term_start)
					,ISNULL(o.deal_date, n.deal_date)
					,ISNULL(o.deal_volume_uom_id, n.deal_volume_uom_id)
					,ISNULL(o.create_ts, GETDATE())
					,ISNULL(o.create_user, dbo.fnadbuser())
					,isnull(n.calc_volume, 0) - isnull(o.calc_volume, 0) calc_volume
					,CASE 
						WHEN ISNULL(@orginal_insert_type, 0) = 0
							THEN 17404
						ELSE 17403
						END delta_type
					,isnull(o.expiration_date, n.expiration_date)
					,isnull(o.term_end, n.term_end)
					,isnull(o.formula, n.formula),isnull(o.source_deal_detail_id,n.source_deal_detail_id)
					,isnull(o.rowid,n.rowid)
				FROM @report_hourly_position_breakdown_main_old o
				FULL JOIN #report_hourly_position_breakdown_main_inserted n ON o.source_deal_detail_id = n.source_deal_detail_id
					AND ISNULL(o.curve_id, - 1) = ISNULL(n.curve_id, - 1)
					AND o.term_start = n.term_start

				WHERE isnull(n.calc_volume, 0) <> isnull(o.calc_volume, 0)
		END

		
		SET @err_status = 's'
	END
			--------------------------------------------------------------------------------------------------------------
			----inserting delta for left hand side deal
			---------------------------------------------------------------------------------------------------------------
			--Delta inserting
			-------------------------------------------------------------------------------------------------------------------------------
END TRY

BEGIN CATCH
	--IF @@TRANCOUNT>0
	--	ROLLBACK
	---EXEC spa_print ERROR_NUMBER()
	--EXEC spa_print ERROR_message()
	DECLARE @err_no INT
		,@err_msg VARCHAR(1000)
		,@url VARCHAR(max)
		,@desc VARCHAR(max)
		,@spa VARCHAR(max)

	SELECT @err_no = ERROR_NUMBER()
		,@err_msg = ERROR_MESSAGE()
		,@url = ''
		,@desc = ''

	SET @err_msg = REPLACE(@err_msg, '''', ' ')

	UPDATE import_data_files_audit
	SET STATUS = 'e'
	WHERE process_id = @process_id

	IF NOT EXISTS (
			SELECT 'x'
			FROM message_board
			WHERE process_id = @process_id
			)
	BEGIN
		EXEC spa_print @effected_deals

		SET @st_sql = 'insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation,create_user,create_ts) 
			   SELECT  ''' + @process_id + ''',''ERROR'',''Maintain Transaction'',''Maintain Transaction'',''ERROR'',''Error #:' + cast(@err_no AS VARCHAR) + '; Message:' + @err_msg + '[Deal ID:''+CAST(source_deal_header_id AS VARCHAR)+''].'' ,''Please check data.'',create_user usr,GETDATE() dt
			   FROM #tmp_header_deal_id'

		EXEC spa_print @st_sql

		EXEC (@st_sql)

		SET @st_sql = 'insert into source_system_data_import_status_detail(process_id,source,type,[description],create_user,create_ts) 
			   select ''' + @process_id + ''',''Maintain Transaction'',''Error'',''Error #:' + cast(@err_no AS VARCHAR) + '; Message:' + @err_msg + '[Deal ID:''+CAST(source_deal_header_id AS VARCHAR)+''].'',create_user usr,GETDATE() dt
			   FROM #tmp_header_deal_id'

		EXEC spa_print @st_sql

		EXEC (@st_sql)

		DECLARE netting CURSOR
		FOR
		SELECT DISTINCT create_user
		FROM #tmp_header_deal_id

		OPEN netting

		FETCH NEXT
		FROM netting
		INTO @user_login_id

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''

			SELECT @desc = '<a target="_blank" href="' + @url + '">Error found while hourly breakdown position.</a>'

			SET @desc = ISNULL(@desc, 'no message')

			EXEC spa_message_board 'i'
				,@user_login_id
				,NULL
				,'Maintain Transaction'
				,@desc
				,''
				,''
				,'e'
				,'Update total volume'
				,NULL
				,@process_id

			FETCH NEXT
			FROM netting
			INTO @user_login_id
		END

		CLOSE netting

		DEALLOCATE netting
	END
END CATCH
	/************************************* Object: 'spa_maintain_transaction_job' END *************************************/
	
