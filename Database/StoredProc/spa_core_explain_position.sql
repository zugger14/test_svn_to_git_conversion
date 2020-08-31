
--/****** Object:  StoredProcedure [dbo].[spa_calc_explain_position]    Script Date: 02/29/2012 18:27:15 ******/
if OBJECT_ID('spa_core_explain_position') is not null
drop proc dbo.spa_core_explain_position
GO

create PROC [dbo].[spa_core_explain_position] 
	@as_of_date_from  DATETIME
	,@as_of_date_to DATETIME = NULL
	,@deal_level VARCHAR(1) = 'y',
	@index varchar(1000)=null,
	@commodity varchar(1000)=null
	,@process_id varchar(150)
	,@call_from int=0 --0=explain position, 1=explain mtm for price change calculation, 2=value report price change
AS


/*


DECLARE @as_of_date_from   DATETIME = '2012-01-29'
,@as_of_date_to           DATETIME = '2012-02-29'
,@deal_level VARCHAR(1) = 'y'
,@process_id varchar(150)='7E560273_FF47_4BBF_987D_FEE97F7520CC'



----value_id	type_id	code
----17401	17400	New Deal
----17402	17400	Deleted Deal
----17403	17400	Forecast Volume Change
----17404	17400	Deal Change
----17405	17400	Volume delivered


--*/

DECLARE @baseload_block_type       VARCHAR(10)
DECLARE @baseload_block_define_id  VARCHAR(10)--,@orginal_summary_option CHAR(1)
DECLARE @explain_position          VARCHAR(200)
DECLARE @st1                       VARCHAR(MAX),
        @st2                       VARCHAR(MAX),
        @st2_0                     VARCHAR(MAX),
        @st2a                      VARCHAR(MAX),
        @st2b                      VARCHAR(MAX),
        @st3                       VARCHAR(MAX),
        @st4                       VARCHAR(MAX),
        @st5                       VARCHAR(MAX),
        @st_fields                  VARCHAR(MAX),
        @st_group_by               VARCHAR(MAX),
        @st_from               VARCHAR(MAX),
		@source_deal_header  VARCHAR(200),
		@source_deal_detail  VARCHAR(200),
		@report_hourly_position_breakdown  VARCHAR(200),
		@delta_report_hourly_position_breakdown  VARCHAR(200),
		@report_hourly_position_breakdown_detail  VARCHAR(200),
		@delta_report_hourly_position_breakdown_detail  VARCHAR(200),
		@report_hourly_position_breakdown_detail_delivered  VARCHAR(200),
		@report_hourly_position_breakdown_detail_ending  VARCHAR(200),
		@user_login_id    VARCHAR(50),@delivered_position  VARCHAR(200),
		@position_detail VARCHAR(150)

	
SET @process_id = isnull(@process_id,REPLACE(newid(),'-','_'))
	
SET @user_login_id = dbo.FNADBUser() 

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM   static_data_value WHERE  [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

IF @baseload_block_define_id IS NULL
    SET @baseload_block_define_id = 'NULL'

SET @source_deal_header = dbo.FNAProcessTableName('source_deal_header', @user_login_id, @process_id)
set  @source_deal_detail = dbo.FNAProcessTableName('source_deal_detail', @user_login_id, @process_id)

set  @report_hourly_position_breakdown = dbo.FNAProcessTableName('report_hourly_position_breakdown', @user_login_id, @process_id)
set  @delta_report_hourly_position_breakdown = dbo.FNAProcessTableName('delta_report_hourly_position_breakdown', @user_login_id, @process_id)
set  @report_hourly_position_breakdown_detail = dbo.FNAProcessTableName('report_hourly_position_breakdown_detail', @user_login_id, @process_id)
set  @delta_report_hourly_position_breakdown_detail = dbo.FNAProcessTableName('delta_report_hourly_position_breakdown_detail', @user_login_id, @process_id)
set  @report_hourly_position_breakdown_detail_delivered = dbo.FNAProcessTableName('report_hourly_position_breakdown_detail_delivered', @user_login_id, @process_id)
set  @report_hourly_position_breakdown_detail_ending = dbo.FNAProcessTableName('report_hourly_position_breakdown_detail_ending', @user_login_id, @process_id)
set  @position_detail = dbo.FNAProcessTableName('explain_position_detail', @user_login_id, @process_id)
set @delivered_position=dbo.FNAProcessTableName('delivered_position', @user_login_id, @process_id)
	
	--proxy_curve_id,tou will populate during record save.
	
	
	
if OBJECT_ID(@report_hourly_position_breakdown) is not null
exec('drop table '+@report_hourly_position_breakdown)

if OBJECT_ID(@delta_report_hourly_position_breakdown) is not null
exec('drop table '+@delta_report_hourly_position_breakdown)

if OBJECT_ID(@report_hourly_position_breakdown_detail) is not null
exec('drop table '+@report_hourly_position_breakdown_detail)

if OBJECT_ID(@delta_report_hourly_position_breakdown_detail) is not null
exec('drop table '+@delta_report_hourly_position_breakdown_detail)

if OBJECT_ID(@report_hourly_position_breakdown_detail_ending) is not null
exec('drop table '+@report_hourly_position_breakdown_detail_ending)

if OBJECT_ID(@report_hourly_position_breakdown_detail_delivered) is not null
exec('drop table '+@report_hourly_position_breakdown_detail_delivered)

if OBJECT_ID(@position_detail) is not null
exec('drop table '+@position_detail)

	
--BEGIN TRY

--SET @st2='
--	create table '+@position_detail+' (
--		source_deal_header_id int,
--		physical_financial_flag varchar(1)
--		,[curve_id] int 
--		,[proxy_curve_id] int
--		,[term_start] date
--		,expiration_date date, Hr tinyint,dst tinyint
--		,deal_volume_uom_id int,formula_breakdown bit,
--		[deal_status_id] int,[counterparty_id] int
--		,[user_toublock_id] int,[toublock_id] int,
--		book_deal_type_map_id int,
--		OB_Volume	numeric(20,10),
--		new_delta	numeric(20,10),
--		modify_delta	numeric(20,10),
--		forecast_delta	numeric(20,10),
--		deleted_delta	numeric(20,10),
--		delivered_delta	numeric(20,10),
--		CB_Volume	numeric(20,10),fixation bit
--	)'

--exec(@st2)

if ISNULL(@call_from,0)<>1  --1=explain mtm for price change calculation( for price change the financial position is not required, so ignoring financial position)
begin
	set @st1='
		select 	'+case when @deal_level='y' then 'sdh.source_deal_header_id,' else '' end +'rowid=identity(int,1,1),u.physical_financial_flag,u.[curve_id],u.[term_start] ,u.expiration_date,u.deal_volume_uom_id
			,sdh.book_deal_type_map_id,sdh.[deal_status_id],sdh.[counterparty_id]
			,u.formula,u.term_end,sum(u.calc_volume) calc_volume,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts
			,0 fixation ,u.commodity_id,982 granularity, 0 period
		into ' +@report_hourly_position_breakdown+'
		from report_hourly_position_breakdown u  (nolock)
			inner JOIN '+ @source_deal_header +' sdh  ON u.source_deal_header_id=sdh.source_deal_header_id AND sdh.deal_date<='''+convert(varchar(10),@as_of_date_to,120)+'''  -- and ISNULL(sdh.product_id,4101)<>4100  	
		GROUP BY '+case when @deal_level='y' then 'sdh.source_deal_header_id,' else '' end +'
			u.physical_financial_flag,u.[curve_id],u.[term_start] ,u.expiration_date,u.deal_volume_uom_id
			,sdh.book_deal_type_map_id,sdh.[deal_status_id],sdh.[counterparty_id]
			,u.formula,u.term_end,cast(convert(varchar(10),sdh.create_ts,120) as date),u.commodity_id
	'
	exec spa_print @st1
	EXEC(@st1)
			
	set @st1='select '+case when @deal_level='y' then 'sdh.source_deal_header_id,' else '' end +' rowid=identity(int,1,1),u.physical_financial_flag,u.[curve_id],u.[term_start] ,u.expiration_date,u.deal_volume_uom_id
			,sdh.book_deal_type_map_id,sdh.[deal_status_id],sdh.[counterparty_id]
			,u.formula,u.term_end,u.delta_type,sum(u.calc_volume) calc_volume,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts
			,0 fixation ,u.commodity_id,982 granularity, 0 period
		into '+@delta_report_hourly_position_breakdown+ '
		from delta_report_hourly_position_breakdown u  (nolock)  
			inner JOIN '+@source_deal_header +' sdh  ON u.source_deal_header_id=sdh.source_deal_header_id 
	 			and (CONVERT(VARCHAR(10),u.as_of_date,120)>'''+convert(varchar(10),@as_of_date_from,120)+'''  and CONVERT(VARCHAR(10),u.as_of_date,120)<='''+convert(varchar(10),@as_of_date_to,120)+''' )
				AND u.deal_date<='''+convert(varchar(10),@as_of_date_to,120)+'''	-- and ISNULL(sdh.product_id,4101)<>4100 
		GROUP BY '+case when @deal_level='y' then 'sdh.source_deal_header_id,' else '' end +'
			u.physical_financial_flag,u.[curve_id],u.[term_start] ,u.expiration_date,u.deal_volume_uom_id
			,sdh.book_deal_type_map_id,sdh.[deal_status_id],sdh.[counterparty_id],u.formula,u.term_end,delta_type
			,cast(convert(varchar(10),sdh.create_ts,120) as date),u.commodity_id
	'

	exec spa_print @st1
	EXEC(@st1)
	exec('create index indx_rowid_'+@process_id + ' on '+@report_hourly_position_breakdown +'(rowid)')
	exec('create index indx_curve_'+@process_id + ' on '+@report_hourly_position_breakdown +'(curve_id,term_start,term_end)')


	--not current month remaining days ratio position breakdown
	set @st1='	
		select '+case when @deal_level='y' then 's.source_deal_header_id,' else '' end +' s.rowid,cast(hb.term_date as DATE) term_start
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12'
			
	set @st2=',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
			,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
			,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) 
				WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)	ELSE s.expiration_date END expiration_date 
				,s.fixation  '
				 
	set @st3=' into '+ @report_hourly_position_breakdown_detail+'
		from '+@report_hourly_position_breakdown +' s  (nolock) 
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id  
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply 
			(
				select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,''292037'')	
				and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END 
			) term_hrs
			outer apply 
			( 
				select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join 
				(
					select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END 
				) ex on ex.exp_date=hbt.term_date
				where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,292037)	
				and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END
			) term_hrs_exp
			left join hour_block_term hb (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,292037)
				and  hb.block_type=COALESCE(spcd.block_type,12000) and hb.term_date between s.term_start  and s.term_end  
			 outer apply 
			  (
		  		select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
			  AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
			  ) hg   
			 outer apply 
			 (
		 		select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')
			 ) hg1   
			 outer APPLY
			 (
		 		select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+convert(varchar(10),@as_of_date_from,120)+'''  THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
						AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
						AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')
			 ) remain_month  
			WHERE 
			 COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800
			 AND (
	     		(isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) 
	     		or (isnull(spcd.hourly_volume_allocation,17601)<17603 )
				)	 
			  and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) 
				WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
				 ELSE s.expiration_date END>'''+convert(varchar(10),@as_of_date_from,120)+''' 
			 		   and   hb.term_date>'''+convert(varchar(10),@as_of_date_from,120)+'''    
		'
		
	exec spa_print @st1
	exec spa_print @st2
	exec spa_print @st3
	EXEC(@st1+@st2+@st3)
		
	set @st1='			 	   
		select '+case when @deal_level='y' then 's.source_deal_header_id,' else '' end +'s.rowid,cast(hb.term_date as DATE) term_start
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12'

	set @st2=',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
			,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
			,case when ISNULL(spcd1.ratio_option,spcd.ratio_option) =18800 then ISNULL(hg1.hol_date_to,''9999-01-01'')
			else		
				CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) 
					WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
					 ELSE s.expiration_date END 
			end expiration_date,s.fixation'

	set @st3=' into '+@delta_report_hourly_position_breakdown_detail+'
		from '+@delta_report_hourly_position_breakdown +' s  (nolock) 
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
		left JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id  
		outer apply 
		(	select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
			and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END 
		) term_hrs
		outer apply 
		( 
			select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join 
			(
				select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END 
			) ex on ex.exp_date=hbt.term_date
			where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
			and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END
		) term_hrs_exp
		left join hour_block_term hb (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,292037)
			and  hb.block_type=COALESCE(spcd.block_type,12000) and hb.term_date between s.term_start  and s.term_end  
		outer apply 
		(	select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
			  AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
		 ) hg   
		 outer apply 
		 ( 	select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h 
	 		where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
		 ) hg1   
		 outer APPLY
		 ( 	select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+convert(varchar(10),@as_of_date_from,120)+'''  THEN 1 else 0 END) remain_days
	 		 from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')
		 ) remain_month  
		WHERE ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+convert(varchar(10),@as_of_date_from,120)+''' ) OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		 AND (
     		(isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) 
     		or (isnull(spcd.hourly_volume_allocation,17601)<17603 )
			)	 
		  and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) 
			WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date)
			 ELSE s.expiration_date END>'''+convert(varchar(10),@as_of_date_from,120)+'''  
		 and   hb.term_date>'''+convert(varchar(10),@as_of_date_from,120)+'''    
		'	  
		
	exec spa_print @st1
	exec spa_print @st2
	exec spa_print @st3
	EXEC(@st1+@st2+@st3)
			  
			  
		-- delivered position
	set @st1='select '+case when @deal_level='y' then 's.source_deal_header_id,' else '' end +'s.rowid,cast(hb.term_date as DATE) term_start
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days )/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12'

	set @st2=',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days_to-remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
				,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_from,120)+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
				, ISNULL(hg1.hol_date_to,''9999-01-01'') expiration_date,s.fixation '
				
	set @st3=' into '+@report_hourly_position_breakdown_detail_delivered+'
			from '+@report_hourly_position_breakdown +' s  (nolock)  
				left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id   --46315
				LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
				outer apply 
				(	select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
						and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END 
				) term_hrs
				outer apply 
				( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join 
					(	select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END 
					) ex on ex.exp_date=hbt.term_date
					where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
						and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END
				) term_hrs_exp
				left join hour_block_term hb (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,292037)
					and  hb.block_type=COALESCE(spcd.block_type,12000) and hb.term_date between s.term_start  and s.term_end  
			outer apply 
				  (	select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
					  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
						  AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
				  ) hg   
				 outer apply 
				 ( 	select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h 
			 		where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
				 ) hg1   
				 outer APPLY
				 ( 	select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+convert(varchar(10),@as_of_date_from,120)+'''  THEN 1 else 0 END) remain_days
			 		,SUM(CASE WHEN h.exp_date>'''+convert(varchar(10),@as_of_date_to,120)+'''  THEN 1 else 0 END) remain_days_to from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
							AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
							AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800  AND s.formula NOT IN(''REBD'')
				 ) remain_month  
			
				WHERE (ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+convert(varchar(10),@as_of_date_from,120)+''') 
			--	AND s.formula NOT IN(''REBD'')  
				 and   hb.term_date>'''+convert(varchar(10),@as_of_date_from,120)+''' 
				and  remain_month.remain_days_to<>remain_month.remain_days
	'
		
	exec spa_print @st1
	exec spa_print @st2
	exec spa_print @st3
	EXEC(@st1+@st2+@st3)	

	--current month remaining days ratio; 
	set @st1='select '+case when @deal_level='y' then 's.source_deal_header_id,' else '' end +'s.rowid,cast(hb.term_date as DATE) term_start
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days )/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12'

	set @st2=',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''' )) AS VARCHAR)+''-01'' THEN ISNULL((remain_month.remain_days)/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
				,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+convert(varchar(10),@as_of_date_to,120)+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
				, ISNULL(hg1.hol_date_to,''9999-01-01'') expiration_date,s.fixation '

	set @st3=' 	into '+@report_hourly_position_breakdown_detail_ending+'
		from '+@report_hourly_position_breakdown +' s  (nolock)  
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id   --46315
		LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
		outer apply 
		(	select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
				and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END 
		) term_hrs
		outer apply 
		( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join 
			(
				select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END 
			) ex on ex.exp_date=hbt.term_date
			where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
				and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END
		) term_hrs_exp
		left join hour_block_term hb (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,292037)
				and  hb.block_type=COALESCE(spcd.block_type,12000) and hb.term_date between s.term_start  and s.term_end  
		 outer apply 
		 ( 	select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
			  AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 
		  ) hg   
		 outer apply 
		 ( 	select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h 
	 			where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END 
		 ) hg1   
		 outer APPLY
		 ( 	select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+convert(varchar(10),@as_of_date_to,120)+'''  THEN 1 else 0 END) remain_days
	 		,SUM(CASE WHEN h.exp_date>'''+convert(varchar(10),@as_of_date_to,120)+'''  THEN 1 else 0 END) remain_days_to from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
				AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
				AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')
		 ) remain_month  
		WHERE (ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+convert(varchar(10),@as_of_date_to,120)+''' ) 
		--	AND s.formula NOT IN(''REBD'') 
			and   hb.term_date>'''+convert(varchar(10),@as_of_date_to,120)+'''  
			and case when ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+convert(varchar(10),@as_of_date_to,120)+''' 
		'		
		
	exec spa_print @st1
	exec spa_print @st2
	exec spa_print @st3
	EXEC(@st1+@st2+@st3)
			  
	exec('create index indx_rowid_detail'+@process_id + ' on '+@report_hourly_position_breakdown_detail +'(rowid)')
	exec('create index indx_rowid_detail1'+@process_id + ' on '+@delta_report_hourly_position_breakdown_detail +'(rowid)')
	exec('create index indx_rowid_detail2'+@process_id + ' on '+@report_hourly_position_breakdown_detail_delivered +'(rowid)')
	exec('create index indx_rowid_detail3'+@process_id + ' on '+@report_hourly_position_breakdown_detail_ending +'(rowid)')

end 		  		  
declare @hr_columns varchar(max),@fin_columns varchar(max),@phy_columns varchar(max)

set @fin_columns=case when @deal_level='y' then 'h.source_deal_header_id,' else '' end +'h.physical_financial_flag,h.[curve_id],e.expiration_date,h.deal_volume_uom_id,h.book_deal_type_map_id
	,h.[deal_status_id],h.[counterparty_id],e.[term_start] '+case ISNULL(@call_from,0) when 1 then ',e.location_id ' when 2 then ',h.source_system_book_id1,h.source_system_book_id2,h.source_system_book_id3,h.source_system_book_id4' else '' end 

set @phy_columns=case when @deal_level='y' then 'e.source_deal_header_id,' else '' end +'e.physical_financial_flag,e.[curve_id],e.expiration_date,e.deal_volume_uom_id,sdh.book_deal_type_map_id
	,sdh.[deal_status_id],sdh.[counterparty_id]	,e.[term_start] '+case ISNULL(@call_from,0) when 1 then ',e.location_id ' when 2 then ',e.source_system_book_id1,e.source_system_book_id2,e.source_system_book_id3,e.source_system_book_id4' else '' end 

set @hr_columns=',e.hr1,e.hr2,e.hr3,e.hr4,e.hr5,e.hr6,e.hr7,e.hr8,e.hr9,e.hr10,e.hr11,e.hr12,e.hr13,e.hr14,e.hr15,e.hr16,e.hr17,e.hr18,e.hr19,e.hr20,e.hr21 ,e.hr22 ,e.hr23,e.hr24,e.hr25'


SET @st1='Select '+case when @deal_level='y' then 'u.source_deal_header_id,' else '' end +'u.physical_financial_flag,u.[curve_id]'+case ISNULL(@call_from,0) when 2 then ',u.source_system_book_id1,u.source_system_book_id2,u.source_system_book_id3,u.source_system_book_id4' else '' end +'
	,case when u.formula_breakdown=0 and spcd.commodity_id=-1 and cast(substring(hr,3,2) AS INT)>18  then u.[term_start]+1 else	u.[term_start] end [term_start]
	,case when u.formula_breakdown=0 and spcd.commodity_id=-1 and cast(substring(hr,3,2) AS INT)>18 then u.expiration_date+1 else u.expiration_date end expiration_date
	,'+case when ISNULL(@call_from,0) =2 then   'cast(substring(hr,3,2) AS INT)'
	else '	
	case when u.formula_breakdown=0 and spcd.commodity_id=-1 then
		case when cast(substring(hr,3,2) AS INT)>18 and  cast(substring(hr,3,2) AS INT)<>25 then cast(substring(hr,3,2) AS INT)-18
		when cast(substring(hr,3,2) AS INT)<19 then cast(substring(hr,3,2) AS INT)+6
		else cast(substring(hr,3,2) AS INT) end
	else case when cast(substring(hr,3,2) AS INT)=25 then 3 else cast(substring(hr,3,2) AS INT) end end'
	end  +' Hr,
	u.deal_volume_uom_id,u.formula_breakdown,u.[book_deal_type_map_id],u.[deal_status_id],u.[counterparty_id]
	,sum(case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0
		else
		(case when abs(u.deal_status_id)=5607 then 0 else 	  
			case when u.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) + ''' AND u.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''  and u.delta_type=1111
				then u.Volume else 0 end
		end) --ending
		-(
			(case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0 else
			 case when abs(u.deal_status_id)=5607 then 0 else case when u.delta_type=9999 then 0 else case when u.delta_type=17404 then u.Volume  else 0 end end end end)--modify
			 +
			 ( case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0 else 
				case when abs(u.deal_status_id)=5607 then case when u.deal_status_id<0 then u.Volume else -1* u.Volume end else 
	  			case when u.delta_type=9999 then  0 else case when u.delta_type=17402 then u.Volume  else 0 end end end end) --deleted
			+
			( 
			case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0	else
			case when abs(u.deal_status_id)=5607 then 0 else 
				case when u.delta_type=9999 then 0 else case when u.delta_type=17403 then u.Volume  else 0 end end end end
			)  ---re-forecast' 
			 +CASE isnull(@call_from,0) when 0 THEN '
				+
				(
					case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0
					else
					   case when abs(u.deal_status_id)=5607 then 0 else 
						 case when u.delta_type=9999 then   u.Volume  else  
	  						  case when (u.expiration_date<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' or u.[term_start]<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') and u.delta_type=1111
								then -1*u.Volume else 0 end
					end end end
				) --delivered'
			else ''  END +'
		)
	end ) OB_Volume ---- begin balance=ending balance - delta 
	,sum(	case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' 
			then
				(case when abs(u.deal_status_id)=5607 then 0 else 	  
					case when u.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) + ''' AND u.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''  and u.delta_type=1111
						then u.Volume else 0 end
				end) --ending
				-(
					(case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0 else
					 case when abs(u.deal_status_id)=5607 then 0 else case when u.delta_type=9999 then 0 else case when u.delta_type=17404 then u.Volume  else 0 end end end end)--modify
					 +
					 ( case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0 else 
						case when abs(u.deal_status_id)=5607 then case when u.deal_status_id<0 then u.Volume else -1* u.Volume end else 
	  					case when u.delta_type=9999 then  0 else case when u.delta_type=17402 then u.Volume  else 0 end end end end) --deleted
					+
					( 
					case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0	else
					case when abs(u.deal_status_id)=5607 then 0 else 
						case when u.delta_type=9999 then 0 else case when u.delta_type=17403 then u.Volume  else 0 end end end end
					)  ---re-forecast
					+
					(
						case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0
						else
						   case when abs(u.deal_status_id)=5607 then 0 else 
							 case when u.delta_type=9999 then   u.Volume  else  
	  							  case when (u.expiration_date<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' or u.[term_start]<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') and u.delta_type=1111
									then -1*u.Volume else 0 end
						end end end
					) --delivered
				)
			else 0 end ) new_delta
	  ,sum(case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0 else
			 case when abs(u.deal_status_id)=5607 then 0 else case when u.delta_type=9999 then 0 else case when u.delta_type=17404 then u.Volume  else 0 end end end end) modify_delta
	  ,sum( case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0 else 
			case when abs(u.deal_status_id)=5607 then case when u.deal_status_id<0 then u.Volume else -1* u.Volume end else 
	  		case when u.delta_type=9999 then  0 else case when u.delta_type=17402 then u.Volume  else 0 end end end end) deleted_delta
	  ,sum( case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0	else
			case when abs(u.deal_status_id)=5607 then 0 else 
				case when u.delta_type=9999 then 0 else case when u.delta_type=17403 then u.Volume  else 0 end end end end) forecast_delta		  
	  ,sum(case when u.create_ts > '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''  and u.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' then 0
		else
	   case when abs(u.deal_status_id)=5607 then 0 else 
		 case when u.delta_type=9999 then   u.Volume  else  
	  		  case when (u.expiration_date<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' or u.[term_start]<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') and u.delta_type=1111
				then -1*u.Volume else 0 end
		end end end) delivered_delta
	  ,sum( case when abs(u.deal_status_id)=5607 then 0 else 	  
		case when u.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) + ''' AND u.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''  and u.delta_type=1111
			then u.Volume else 0 end
		end) CB_Volume ,u.fixation
		INTO ' +@position_detail
			
set @st2='	FROM 
	(
	select '+ @phy_columns +CASE WHEN ISNULL(@call_from,0)=1 THEN ',e.granularity,e.period' ELSE '' END +'
		,cast(sum(e.hr1) as numeric(26,10)) hr1,cast(sum(e.hr2) as numeric(26,10)) hr2 ,cast(sum(e.hr3) as numeric(26,10)) hr3 ,cast(sum(e.hr4) as numeric(26,10)) hr4 ,cast(sum(e.hr5) as numeric(26,10)) hr5 ,cast(sum(e.hr6) as numeric(26,10)) hr6 ,cast(sum(e.hr7) as numeric(26,10)) hr7 ,cast(sum(e.hr8) as numeric(26,10)) hr8
				,cast(sum(e.hr9) as numeric(26,10)) hr9 ,cast(sum(e.hr10) as numeric(26,10)) hr10 ,cast(sum(e.hr11) as numeric(26,10)) hr11 ,cast(sum(e.hr12) as numeric(26,10)) hr12 ,cast(sum(e.hr13) as numeric(26,10)) hr13 ,cast(sum(e.hr14) as numeric(26,10)) hr14 ,cast(sum(e.hr15) as numeric(26,10)) hr15 ,cast(sum(e.hr16) as numeric(26,10)) hr16
				,cast(sum(e.hr17) as numeric(26,10)) hr17 ,cast(sum(e.hr18) as numeric(26,10)) hr18 ,cast(sum(e.hr19) as numeric(26,10)) hr19 ,cast(sum(e.hr20) as numeric(26,10)) hr20 ,cast(sum(e.hr21 ) as numeric(26,10)) hr21 ,cast(sum(e.hr22 ) as numeric(26,10)) hr22 ,cast(sum(e.hr23) as numeric(26,10)) hr23 ,cast(sum(e.hr24) as numeric(26,10)) hr24,cast(sum(e.hr25) as numeric(26,10)) hr25
		,0 formula_breakdown,1111 delta_type,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts,0 fixation 
	FROM [dbo].[report_hourly_position_profile] e 
	inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
		and e.expiration_date>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +'''
	group by '+@phy_columns+CASE WHEN ISNULL(@call_from,0)=1 THEN ',e.granularity,e.period' ELSE '' END +',cast(convert(varchar(10),sdh.create_ts,120) as date)
	UNION ALL
	select '+ @phy_columns +CASE WHEN ISNULL(@call_from,0)=1 THEN ',e.granularity,e.period' ELSE '' END +'
	,sum(e.hr1) hr1,sum(e.hr2) hr2 ,sum(e.hr3) hr3 ,sum(e.hr4) hr4 ,sum(e.hr5) hr5 ,sum(e.hr6) hr6 ,sum(e.hr7) hr7 ,sum(e.hr8) hr8
		,sum(e.hr9) hr9 ,sum(e.hr10) hr10 ,sum(e.hr11) hr11 ,sum(e.hr12) hr12 ,sum(e.hr13) hr13 ,sum(e.hr14) hr14 ,sum(e.hr15) hr15 ,sum(e.hr16) hr16
		,sum(e.hr17) hr17 ,sum(e.hr18) hr18 ,sum(e.hr19) hr19 ,sum(e.hr20) hr20 ,sum(e.hr21 ) hr21 ,sum(e.hr22 ) hr22 ,sum(e.hr23) hr23 ,sum(e.hr24) hr24,sum(e.hr25)  hr25
	,0 formula_breakdown,1111 delta_type,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts,0 fixation 
	FROM [dbo].[report_hourly_position_deal] e 
	inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
		and e.expiration_date>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +'''
	group by '+@phy_columns+CASE WHEN ISNULL(@call_from,0)=1 THEN ',e.granularity,e.period' ELSE '' END +',cast(convert(varchar(10),sdh.create_ts,120) as date)

	'
		
set @st3='	
	UNION ALL
		select '+ @fin_columns+@hr_columns +',1 formula_breakdown,1111 delta_type,h.create_ts,e.fixation  FROM '+@report_hourly_position_breakdown_detail+' e
			left join '+ @report_hourly_position_breakdown+ ' h on h.rowid=e.rowid
	UNION ALL
		select '+ @fin_columns+@hr_columns +',1 formula_breakdown,delta_type,h.create_ts,e.fixation  from  '+ @delta_report_hourly_position_breakdown_detail+ ' e 			
			left join '+ @delta_report_hourly_position_breakdown+ ' h on h.rowid=e.rowid
	union all
		select '+ @fin_columns+@hr_columns +',1 formula_breakdown,9999 delta_type,h.create_ts,e.fixation  FROM '+@report_hourly_position_breakdown_detail_delivered+' e
			left join '+ @report_hourly_position_breakdown+ ' h on h.rowid=e.rowid
	UNION ALL
		select '+ @fin_columns+@hr_columns +',1 formula_breakdown,1111 delta_type,h.create_ts,e.fixation  FROM '+@report_hourly_position_breakdown_detail_ending+' e
			left join '+ @report_hourly_position_breakdown+ ' h on h.rowid=e.rowid
	UNION ALL
	select '+ @phy_columns +'
	,sum(e.hr1) hr1,sum(e.hr2) hr2 ,sum(e.hr3) hr3 ,sum(e.hr4) hr4 ,sum(e.hr5) hr5 ,sum(e.hr6) hr6 ,sum(e.hr7) hr7 ,sum(e.hr8) hr8
		,sum(e.hr9) hr9 ,sum(e.hr10) hr10 ,sum(e.hr11) hr11 ,sum(e.hr12) hr12 ,sum(e.hr13) hr13 ,sum(e.hr14) hr14 ,sum(e.hr15) hr15 ,sum(e.hr16) hr16
		,sum(e.hr17) hr17 ,sum(e.hr18) hr18 ,sum(e.hr19) hr19 ,sum(e.hr20) hr20 ,sum(e.hr21 ) hr21 ,sum(e.hr22 ) hr22 ,sum(e.hr23) hr23 ,sum(e.hr24) hr24,sum(e.hr25)  hr25
	,0 formula_breakdown,1111 delta_type,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts,0 fixation 
	FROM [dbo].[report_hourly_position_financial] e 
	inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
		and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_from,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''
	group by '+@phy_columns+',cast(convert(varchar(10),sdh.create_ts,120) as date)			
		
	UNION ALL
	select '+ @phy_columns +'
	,sum(e.hr1) hr1,sum(e.hr2) hr2 ,sum(e.hr3) hr3 ,sum(e.hr4) hr4 ,sum(e.hr5) hr5 ,sum(e.hr6) hr6 ,sum(e.hr7) hr7 ,sum(e.hr8) hr8
		,sum(e.hr9) hr9 ,sum(e.hr10) hr10 ,sum(e.hr11) hr11 ,sum(e.hr12) hr12 ,sum(e.hr13) hr13 ,sum(e.hr14) hr14 ,sum(e.hr15) hr15 ,sum(e.hr16) hr16
		,sum(e.hr17) hr17 ,sum(e.hr18) hr18 ,sum(e.hr19) hr19 ,sum(e.hr20) hr20 ,sum(e.hr21 ) hr21 ,sum(e.hr22 ) hr22 ,sum(e.hr23) hr23 ,sum(e.hr24) hr24,sum(e.hr25)  hr25
	,0 formula_breakdown,e.delta_type delta_type,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts,0 fixation 
	FROM [dbo].[delta_report_hourly_position_financial] e 
		inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id 
			and  [expiration_date]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +''' and 
				(CONVERT(VARCHAR(10),e.as_of_date,120)> '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''
				 and CONVERT(VARCHAR(10),e.as_of_date,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') AND e.[term_start]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end,120) +'''
		group by '+@phy_columns+',sdh.create_ts,e.delta_type		
		
			'			
			
			
set @st4='			
	union all	
		select '+ @phy_columns +',sum(e.hr1) hr1,sum(e.hr2) hr2 ,sum(e.hr3) hr3 ,sum(e.hr4) hr4 ,sum(e.hr5) hr5 ,sum(e.hr6) hr6 ,sum(e.hr7) hr7 ,sum(e.hr8) hr8
			,sum(e.hr9) hr9 ,sum(e.hr10) hr10 ,sum(e.hr11) hr11 ,sum(e.hr12) hr12 ,sum(e.hr13) hr13 ,sum(e.hr14) hr14 ,sum(e.hr15) hr15 ,sum(e.hr16) hr16
			,sum(e.hr17) hr17 ,sum(e.hr18) hr18 ,sum(e.hr19) hr19 ,sum(e.hr20) hr20 ,sum(e.hr21 ) hr21 ,sum(e.hr22 ) hr22 ,sum(e.hr23) hr23 ,sum(e.hr24) hr24,sum(e.hr25) hr25
			,0 formula_breakdown,e.delta_type,sdh.create_ts,0 fixation 
		FROM [dbo].[delta_report_hourly_position] e 
		inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id   and ISNULL(sdh.product_id,4101)=4101
			and  [expiration_date]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +''' and 
				(CONVERT(VARCHAR(10),e.as_of_date,120)> '''+CONVERT(VARCHAR(10),@as_of_date_from,120) +'''
				 and CONVERT(VARCHAR(10),e.as_of_date,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') AND e.[term_start]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end,120) +'''
		group by '+@phy_columns+',sdh.create_ts,e.delta_type
) p
'



--set @st3='INSERT INTO ' +@position_detail+'
--	('+case when @deal_level='y' then 'source_deal_header_id,' else '' end +'physical_financial_flag ,[curve_id] ,[term_start] ,expiration_date, Hr
--	,deal_volume_uom_id ,formula_breakdown,[book_deal_type_map_id] ,[deal_status_id],[counterparty_id]
--	,OB_Volume,	new_delta,modify_delta,deleted_delta,forecast_delta,delivered_delta,CB_Volume,fixation ) '

--print @st3

if ISNULL(@call_from,0)<>1
begin
	set @st5='
		UNPIVOT
		(Volume for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
		)AS u 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=u.curve_id 
		where Volume<>0  ' 	
		+ CASE WHEN @index IS NULL THEN '' ELSE ' AND u.curve_id IN (' +@index +')' END 
		 +CASE WHEN @commodity IS NULL THEN '' ELSE ' AND spcd.commodity_id IN (' +@commodity +')' END
		 +CASE isnull(@call_from,0) when 1 THEN ' AND formula_breakdown=0 ' ELSE ''  END
	+'	group by '+case when @deal_level='y' then 'u.source_deal_header_id,' else '' end +'
			u.physical_financial_flag,u.[curve_id],u.[term_start] ,u.expiration_date,cast(substring(hr,3,2) AS INT)
			,u.deal_volume_uom_id,u.formula_breakdown,u.[book_deal_type_map_id],u.[deal_status_id],u.[counterparty_id]
			,u.fixation ,spcd.commodity_id	'+case ISNULL(@call_from,0) when 2 then ',u.source_system_book_id1,u.source_system_book_id2,u.source_system_book_id3,u.source_system_book_id4' else '' end 

	EXEC spa_print @st1	
	EXEC spa_print @st2 
	EXEC spa_print @st3 
	EXEC spa_print @st4
	EXEC spa_print @st5
	exec( @st1+ @st2 +@st3+ @st4 +@st5)
	exec ('create index indx_curve_position_detail_'+ @process_id + ' on  '+  @position_detail + ' (curve_id,term_start)')
	
end
else if ISNULL(@call_from,0)=1
BEGIN

	set @phy_columns=case when @deal_level='y' then 'e.source_deal_header_id,' else '' end +'e.physical_financial_flag,e.[curve_id],e.expiration_date,e.deal_volume_uom_id,sdh.book_deal_type_map_id,e.granularity,e.period
		,sdh.[deal_status_id],sdh.[counterparty_id]	,e.[term_start] '+case ISNULL(@call_from,0) when 1 then ',e.location_id ' when 2 then ',e.source_system_book_id1,e.source_system_book_id2,e.source_system_book_id3,e.source_system_book_id4' else '' end 
	
	set @st1='select p.source_deal_header_id,physical_financial_flag ,p.[curve_id] ,p.[term_start] ,p.expiration_date,isnull(p.location_id,-1) location_id,spcd.commodity_id
			,p.deal_volume_uom_id ,max(p.formula_breakdown) formula_breakdown,p.[book_deal_type_map_id] ,p.[deal_status_id],p.[counterparty_id],	sum(p.hr1) hr1,sum(p.hr2) hr2 ,sum(p.hr3) hr3 ,sum(p.hr4) hr4 ,sum(p.hr5) hr5 ,sum(p.hr6) hr6 ,sum(p.hr7) hr7 ,sum(p.hr8) hr8
			,sum(p.hr9) hr9 ,sum(p.hr10) hr10 ,sum(p.hr11) hr11 ,sum(p.hr12) hr12 ,sum(p.hr13) hr13 ,sum(p.hr14) hr14 ,sum(p.hr15) hr15 ,sum(p.hr16) hr16
			,sum(p.hr17) hr17 ,sum(p.hr18) hr18 ,sum(p.hr19) hr19 ,sum(p.hr20) hr20 ,sum(p.hr21 ) hr21 ,sum(p.hr22 ) hr22 ,sum(p.hr23) hr23 ,sum(p.hr24) hr24,sum(p.hr25) hr25,
			sum(p.hr1+p.hr2+p.hr3+p.hr4+p.hr5+p.hr6+p.hr7+p.hr8+p.hr9+p.hr10+p.hr11+p.hr12+p.hr13+p.hr14+p.hr15+p.hr16+p.hr17+p.hr18+p.hr19+p.hr20+p.hr21+p.hr22+p.hr23+p.hr24) tot_vol,
			sum(case when p.hr1<>0 then 1 else 0 end +case when p.hr2<>0 then 1 else 0 end+case when p.hr3<>0 then 1 else 0 end+case when p.hr4<>0 then 1 else 0 end+case when p.hr5<>0 then 1 else 0 end+case when p.hr6<>0 then 1 else 0 end+case when p.hr7<>0 then 1 else 0 end+case when p.hr8<>0 then 1 else 0 end
			+case when p.hr9<>0 then 1 else 0 end+case when p.hr10<>0 then 1 else 0 end+case when p.hr11<>0 then 1 else 0 end+case when p.hr12<>0 then 1 else 0 end+case when p.hr13<>0 then 1 else 0 end+case when p.hr14<>0 then 1 else 0 end+case when p.hr15<>0 then 1 else 0 end+case when p.hr16<>0 then 1 else 0 end
			+case when p.hr17<>0 then 1 else 0 end+case when p.hr18<>0 then 1 else 0 end+case when p.hr19<>0 then 1 else 0 end+case when p.hr20<>0 then 1 else 0 end+case when p.hr21<>0 then 1 else 0 end+case when p.hr22<>0 then 1 else 0 end+case when p.hr23<>0 then 1 else 0 end+case when p.hr24<>0 then 1 else 0 end) avg_divider,max(p.granularity) granularity,p.period
		INTO ' +@position_detail	
	
	set @st3='union all
		select '+ @phy_columns +'
			,cast(sum(e.hr1) as numeric(26,10)) hr1,cast(sum(e.hr2) as numeric(26,10)) hr2 ,cast(sum(e.hr3) as numeric(26,10)) hr3 ,cast(sum(e.hr4) as numeric(26,10)) hr4 ,cast(sum(e.hr5) as numeric(26,10)) hr5 ,cast(sum(e.hr6) as numeric(26,10)) hr6 ,cast(sum(e.hr7) as numeric(26,10)) hr7 ,cast(sum(e.hr8) as numeric(26,10)) hr8
			,cast(sum(e.hr9) as numeric(26,10)) hr9 ,cast(sum(e.hr10) as numeric(26,10)) hr10 ,cast(sum(e.hr11) as numeric(26,10)) hr11 ,cast(sum(e.hr12) as numeric(26,10)) hr12 ,cast(sum(e.hr13) as numeric(26,10)) hr13 ,cast(sum(e.hr14) as numeric(26,10)) hr14 ,cast(sum(e.hr15) as numeric(26,10)) hr15 ,cast(sum(e.hr16) as numeric(26,10)) hr16
			,cast(sum(e.hr17) as numeric(26,10)) hr17 ,cast(sum(e.hr18) as numeric(26,10)) hr18 ,cast(sum(e.hr19) as numeric(26,10)) hr19 ,cast(sum(e.hr20) as numeric(26,10)) hr20 ,cast(sum(e.hr21 ) as numeric(26,10)) hr21 ,cast(sum(e.hr22 ) as numeric(26,10)) hr22 ,cast(sum(e.hr23) as numeric(26,10)) hr23 ,cast(sum(e.hr24) as numeric(26,10)) hr24,cast(sum(e.hr25) as numeric(26,10)) hr25 
			,0 formula_breakdown,1111 delta_type,cast(convert(varchar(10),sdh.create_ts,120) as date) create_ts,0 fixation 
		FROM [dbo].[report_hourly_position_fixed] e 
		inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id  
			and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date_to,120) +'''
		group by '+@phy_columns+',cast(convert(varchar(10),sdh.create_ts,120) as date)
		'
				
	set @st4='			
		union all	
			select '+ @phy_columns +',-1*sum(e.hr1) hr1,-1*sum(e.hr2) hr2 ,-1*sum(e.hr3) hr3 ,-1*sum(e.hr4) hr4 ,-1*sum(e.hr5) hr5 ,-1*sum(e.hr6) hr6 ,-1*sum(e.hr7) hr7 ,-1*sum(e.hr8) hr8
				,-1*sum(e.hr9) hr9 ,-1*sum(e.hr10) hr10 ,-1*sum(e.hr11) hr11 ,-1*sum(e.hr12) hr12 ,-1*sum(e.hr13) hr13 ,-1*sum(e.hr14) hr14 ,-1*sum(e.hr15) hr15 ,-1*sum(e.hr16) hr16
				,-1*sum(e.hr17) hr17 ,-1*sum(e.hr18) hr18 ,-1*sum(e.hr19) hr19 ,-1*sum(e.hr20) hr20 ,-1*sum(e.hr21 ) hr21 ,-1*sum(e.hr22 ) hr22 ,-1*sum(e.hr23) hr23 ,-1*sum(e.hr24) hr24,-1*sum(e.hr25) hr25
				,0 formula_breakdown,e.delta_type,sdh.create_ts,0 fixation 
			FROM [dbo].[delta_report_hourly_position] e 
			inner JOIN '+ @source_deal_header +' sdh  ON e.source_deal_header_id=sdh.source_deal_header_id   and ISNULL(sdh.product_id,4101)=4101
				and  [expiration_date]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end ,120) +''' and 
					(CONVERT(VARCHAR(10),e.as_of_date,120)> '''+CONVERT(VARCHAR(10), @as_of_date_from,120) +'''
					 and CONVERT(VARCHAR(10),e.as_of_date,120)<='''+CONVERT(VARCHAR(10),@as_of_date_to,120) +''') AND e.[term_start]>'''+CONVERT(VARCHAR(10),case when ISNULL(@call_from,0)=1 then @as_of_date_to else @as_of_date_from end,120) +'''
			group by '+@phy_columns+',sdh.create_ts,e.delta_type
	) p
	'

	set @st5='
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=p.curve_id 
		where p.create_ts<='''+CONVERT(VARCHAR(10),@as_of_date_from,120) +''' and abs(p.deal_status_id)<>5607 ' 	
			+CASE WHEN @index IS NULL THEN '' ELSE ' AND p.curve_id IN (' +@index +')' END 
			 +CASE WHEN @commodity IS NULL THEN '' ELSE ' AND spcd.commodity_id IN (' +@commodity +')' END
			 +CASE isnull(@call_from,0) when 1 THEN ' AND formula_breakdown=0 ' ELSE ''  END
	+' group by p.source_deal_header_id,p.physical_financial_flag,p.[curve_id],p.[term_start] ,p.expiration_date,location_id
			,p.deal_volume_uom_id,p.[book_deal_type_map_id],p.[deal_status_id],p.[counterparty_id],spcd.commodity_id,p.period'	
	
	EXEC spa_print @st1
	EXEC spa_print @st2 
	EXEC spa_print @st3
	EXEC spa_print @st4
	EXEC spa_print @st5
	exec( @st1+ @st2 + @st3+@st4 +@st5)
	
	exec ('create index indx_position_detail_'+ @process_id + ' on  '+  @position_detail + ' (source_deal_header_id,curve_id,location_id,term_start)')
end


	