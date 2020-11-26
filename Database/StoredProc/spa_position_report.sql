IF OBJECT_ID(N'[dbo].[spa_position_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_position_report]
GO
/****** Object:  StoredProcedure [dbo].[spa_position_report]    Script Date: 11/23/2020 10:13:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Deal position report of the portfolio.

	Parameters 
	@_summary_option : Summary Option
		 -  'd' Daily, 'h' =hourly,'x'/'y' = 15/30 minute, q=quatar, a=annual
	@_sub_id : sub_id
	@_stra_id : stra_id
	@_book_id : book_id
	@_sub_book_id : sub_book_id
	@_as_of_date : as_of_date
	@_source_deal_header_id : source_deal_header_id
	@_period_from : period_from
	@_period_to : period_to
	@_tenor_option : tenor_option
	@_location_id : location_id
	@_curve_id : curve_id
	@_commodity_id : commodity_id
	@_deal_id : deal_id
	@_location_group_id : location_group_id
	@_grid : grid
	@_country : country
	@_region : region
	@_province : province
	@_station_id : station_id
	@_dam_id : dam_id
	@_deal_status : deal_status
	@_confirm_status : confirm_status
	@_profile : profile
	@_term_start : term_start
	@_term_end : term_end
	@_deal_type : deal_type
	@_deal_sub_type : deal_sub_type
	@_buy_sell_flag : buy_sell_flag
	@_counterparty : counterparty
	@_hour_from : hour_from
	@_hour_to : hour_to
	@_block_group : block_group
	@_parent_counterparty : parent_counterparty
	@_deal_date_from : deal_date_from
	@_deal_date_to : deal_date_to
	@_block_type_group_id : block_type_group_id
	@_trader_id : trader_id
	@_convert_to_uom_id : convert_to_uom_id
	@_physical_financial_flag : physical_financial_flag
	@_include_actuals_from_shape : include_actuals_from_shape
	@_leg : leg
	@_format_option : format_option
	@_group_by : group_by 
		- s - summary (Index/Location  ) 
		- d - detail (deal level) 
	@_round_value : round_value
	@_convert_uom : convert_uom
	@_col_7_to_6 : col_7_to_6
	@_include_no_breakdown : include_no_breakdown
	@_on_fly : on_fly
	@_template_id : template_id
	@_product_id : product_id
	@_mkt_con_flag : mkt_con_flag
	@_contract : contract
	@_pricing_type : pricing_type
	@_formula_curve_id : formula_curve_id
	@_forecast_profile_id : forecast_profile_id
	@_shipper_code_id1 : shipper_code_id1
	@_shipper_code_id2 : shipper_code_id2
	@_reporting_group1 : reporting_group1
	@_reporting_group2 : reporting_group2
	@_reporting_group3 : reporting_group3
	@_reporting_group4 : reporting_group4
	@_reporting_group5 : reporting_group5
  	@_show_delta_volume : show_delta_volume
	@_proxy_curve_view : proxy_curve_view
	@_process_table : process_table
	@_batch_process_id : batch_process_id



*/

CREATE PROCEDURE [dbo].[spa_position_report]
	@_summary_option VARCHAR(6)=null, --  'd' Daily, 'h' =hourly,'x'/'y' = 15/30 minute, q=quatar, a=annual
	@_sub_id varchar(MAX)=null, 
	@_stra_id varchar(MAX)=null,
	@_book_id varchar(MAX)=null,
	@_sub_book_id varchar(MAX)=null,
	@_as_of_date varchar(20)=null,
	@_source_deal_header_id varchar(1000)=null,
	@_period_from varchar(6)=Null,
	@_period_to varchar(6)=NUll,
	@_tenor_option varchar(6)=null,
	@_location_id varchar(1000)=null,
	@_curve_id varchar(1000)=null,
	@_commodity_id varchar(8)=null,
	@_deal_id varchar(1000)=null,
	@_location_group_id  varchar(1000)=null,
	@_grid varchar(1000)=null,
	@_country varchar(MAX)=null,
	@_region varchar(1000)=null,
	@_province varchar(1000)=null,
	@_station_id varchar(1000)=null,
	@_dam_id varchar(1000)=null,
	@_deal_status varchar(8)=null,
	@_confirm_status varchar(8)=null,
	@_profile varchar(8)=null,
	@_term_start varchar(20)=null,
	@_term_end varchar(20)=null,
	@_deal_type varchar(8)=null,
	@_deal_sub_type varchar(8)=null,
	@_buy_sell_flag varchar(6)=null,
	@_counterparty VARCHAR(MAX)=NULL,  
	@_hour_from varchar(6)=null,
	@_hour_to varchar(6)=null,
	@_block_group varchar(10)=null,
	@_parent_counterparty VARCHAR(10) = NULL,
	@_deal_date_from  VARCHAR(20)=Null,
	@_deal_date_to  VARCHAR(20)=Null,
	@_block_type_group_id  VARCHAR(20)=Null,
	@_trader_id  VARCHAR(20)=Null,
	@_convert_to_uom_id  VARCHAR(20)=Null,
	@_physical_financial_flag NCHAR(6)=null,
	@_include_actuals_from_shape varCHAR(6)=null,
	@_leg VARCHAR(6)=null ,
	@_format_option char(6)	='r',
	@_group_by CHAR(6)='d' , -- s:summary (Index/Location  ) ; d=detail (deal level) 
	@_round_value varchar(6) ='4',
	@_convert_uom INT=null,
	@_col_7_to_6 VARCHAR(6)='n',
	@_include_no_breakdown varchar(6)='n' ,
	@_on_fly bit=0,
	@_template_id VARCHAR(1000)=Null,
	@_product_id VARCHAR(1000)=Null,
	@_mkt_con_flag VARCHAR(1000)=NULL,
	@_contract VARCHAR(1000)=NULL,
	@_pricing_type VARCHAR(100)=NULL,
	@_formula_curve_id VARCHAR(1000)=NULL,
	@_forecast_profile_id VARCHAR(1000)=NULL,
	@_shipper_code_id1 VARCHAR(1000)=NULL,
	@_shipper_code_id2 VARCHAR(1000)=NULL,
	@_reporting_group1 VARCHAR(1000)=NULL,
	@_reporting_group2 VARCHAR(1000)=NULL,
	@_reporting_group3 VARCHAR(1000)=NULL,
	@_reporting_group4 VARCHAR(1000)=NULL,
	@_reporting_group5 VARCHAR(1000)=NULL,
  	@_show_delta_volume CHAR(6) = null, -------------?????????? done
	@_proxy_curve_view CHAR(6)=null,
	@_process_table varchar(500)=null,
	@_batch_process_id VARCHAR(100)=NULL
AS
SET NOCOUNT ON

/*

--  select * from report_hourly_position_deal where source_deal_header_id=349

-- 'x01d','x02d','x03d'


DECLARE @_contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @_contextinfo
SET NOCOUNT off

declare
	@_summary_option VARCHAR(6)='h00d', --  'd' Daily, 'h' =hourly,'x'/'y' = 15/30 minute, q=quatar, a=annual
	@_sub_id varchar(MAX)=null, 
	@_stra_id varchar(MAX)=null,
	@_book_id varchar(MAX)=null,
	@_sub_book_id varchar(MAX)=null,
	@_as_of_date varchar(20)='2021-01-01',
	@_source_deal_header_id varchar(1000)=29178,
	@_period_from varchar(6)=0,
	@_period_to varchar(6)=0,
	@_tenor_option varchar(6)='a',
	@_location_id varchar(1000)=null,
	@_curve_id varchar(1000)=null,
	@_commodity_id varchar(8)=null,
	@_deal_id varchar(1000)=null,
	@_location_group_id  varchar(1000)=null,
	@_grid varchar(1000)=null,
	@_country varchar(1000)=null,
	@_region varchar(1000)=null,
	@_province varchar(1000)=null,
	@_station_id varchar(1000)=null,
	@_dam_id varchar(1000)=null,
	@_deal_status varchar(8)=null,
	@_confirm_status varchar(8)=null,
	@_profile varchar(8)=null,
	@_term_start varchar(20)='2021-01-01',
	@_term_end varchar(20)='2021-01-02',
	@_deal_type varchar(8)=null,
	@_deal_sub_type varchar(8)=null,
	@_buy_sell_flag varchar(6),
	@_counterparty VARCHAR(MAX)=NULL,  
	@_hour_from varchar(6)=null,
	@_hour_to varchar(6)=null,
	@_block_group varchar(10)=null,
	@_parent_counterparty VARCHAR(10) = NULL,
	@_deal_date_from  VARCHAR(20)=Null,
	@_deal_date_to  VARCHAR(20)=Null,
	@_block_type_group_id  VARCHAR(20)=null, -- 50000143,
	@_trader_id  VARCHAR(20)=Null,
	@_convert_to_uom_id  VARCHAR(20)=Null,
	@_physical_financial_flag NCHAR(6),
	@_include_actuals_from_shape varCHAR(6), --????????
	@_leg VARCHAR(6) ,
	@_format_option char(1)	='r',
	@_group_by CHAR(1)='d' , -- s:summary r(Index/Location  ) ; d=detail (deal level) 
	@_round_value varchar(1) =null,
	@_convert_uom INT=null,
	@_col_7_to_6 VARCHAR(1)='n',
	@_include_no_breakdown varchar(1)='n' , --- ????????????????
	@_on_fly bit=0,
	@_template_id VARCHAR(1000)=Null,
	@_product_id VARCHAR(1000)=Null,
	@_mkt_con_flag VARCHAR(1000)=null, --???????????
	@_contract VARCHAR(1000)=NULL,
	@_pricing_type VARCHAR(100)=NULL,
	@_formula_curve_id VARCHAR(1000),
	@_forecast_profile_id VARCHAR(1000),
	@_shipper_code_id1 VARCHAR(1000),
	@_shipper_code_id2 VARCHAR(1000),
	@_reporting_group1 VARCHAR(1000),
	@_reporting_group2 VARCHAR(1000),
	@_reporting_group3 VARCHAR(1000),
	@_reporting_group4 VARCHAR(1000),
	@_reporting_group5 VARCHAR(1000),
	@_show_delta_volume CHAR(1) = null, -------------?????????? done
	@_proxy_curve_view CHAR(1),
	@_process_table varchar(500)=null,
	@_batch_process_id VARCHAR(100)=NULL

exec dbo.spa_drop_all_temp_table


--  drop table adiha_process.dbo.aaa_new
--  select * from adiha_process.dbo.aaa_new order by term_start_disp,block_name

-- */


declare
	@_sql_select VARCHAR(MAX)        
	,@_report_type INT   
	,@_storage_inventory_sub_type_id INT  
	,@_sel_sql VARCHAR(1000)  
	,@_group_sql VARCHAR(200)           
	,@_block_sql VARCHAR(100)  
	,@_col_name VARCHAR(20)  
	,@_frequency VARCHAR(20)  
	,@_term_END_parameter VARCHAR(100)  
	,@_term_start_parameter VARCHAR(100)  
	,@_actual_summary_option     CHAR(1)  
	,@_hour_pivot_table          VARCHAR(100)
	,@_position_deal varchar(250) ,@_position_no_breakdown varchar(250)
	,@_remain_month VARCHAR(1000)
	,@_column_level              VARCHAR(100)
	,@_temp_process_id           VARCHAR(100)
	,@_org_summary_option CHAR(6) =@_summary_option

/* List reports

x03s: 15 Mins Position Summary Report
x03d: 15 Mins Position Extract Report
x02s: 15 Mins Position Summary Report by Book
x01d: 15 Mins Power Position Report by Deal
x01s: 15 Mins Power Position Report by Location
x02d: 15 Mins Position Report by Deal with Profile filter


h00s: Hourly Position Summary Report
h00d: Hourly Position Extract Report
d00s: Daily Position Summary Report
d00d: Daily Position Extract Report
m00s: Monthly Position Summary Report
m00d: Monthly Position Extract Report



*/



-------START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
DECLARE @_sqry2  VARCHAR(MAX)

DECLARE @_user_login_id     VARCHAR(50),@_hypo_breakdown VARCHAR(MAX)
	,@_hypo_breakdown1 VARCHAR(MAX) ,@_hypo_breakdown2 VARCHAR(MAX),@_hypo_breakdown3 VARCHAR(MAX)
	
DECLARE @_baseload_block_type VARCHAR(10)
DECLARE @_baseload_block_define_id VARCHAR(10)
Declare @_fltr_param varchar(max)

CREATE TABLE #source_deal_header_id (source_deal_header_id VARCHAR(200))

DECLARE @_view_nameq VARCHAR(100),@_volume_clm VARCHAR(MAX),@_view_name1 VARCHAR(100)

DECLARE @_dst_column VARCHAR(2000),@_vol_multiplier VARCHAR(2000) ,@_rhpb VARCHAR(MAX)
	,@_rhpb1 VARCHAR(MAX) ,@_rhpb2 VARCHAR(MAX),@_rhpb3 VARCHAR(MAX),@_rhpb4 VARCHAR(MAX),@_rhpba1 VARCHAR(MAX)
	,@_sqry  VARCHAR(MAX),@_scrt varchar(max) ,@_sqry1  VARCHAR(MAX)
	,@_rpn VARCHAR(MAX),@_rpn1 VARCHAR(MAX) ,@_rpn2 VARCHAR(MAX),@_rpn3 VARCHAR(MAX)

declare 
	@_select_st1 VARCHAR(MAX) ,@_select_st2 VARCHAR(MAX),@_select_st3 VARCHAR(MAX)
	,@_from_st1 VARCHAR(MAX) ,@_from_st2 VARCHAR(MAX),@_from_st3 VARCHAR(MAX)
	,@_where_st1 VARCHAR(MAX) ,@_where_st2 VARCHAR(MAX),@_where_st3 VARCHAR(MAX)
	,@_group_st1 VARCHAR(MAX),@_process_output_table VARCHAR(250) =''
	,@_unpvt VARCHAR(250) =''
	,@_tmp_pos_detail_power VARCHAR(250)
	,@_tmp_pos_detail_gas VARCHAR(250)

declare @_commodity_str varchar(max),@_rhpb_0 varchar(max),@_commodity_str1 varchar(max)

declare @_std_whatif_deals varchar(250)  ,@_hypo_deal_header varchar(250)
	,@_effected_deals varchar(250), @_hypo_deal_detail varchar(250)
	,@_position_hypo varchar(250)--, @_position_breakdown varchar(250)

if @_org_summary_option  like 'h%'
	set @_summary_option='h' 
else if @_org_summary_option like 'x%'
	set @_summary_option='x'
else if @_org_summary_option like 'y%'
	set @_summary_option='y'
else if @_org_summary_option like 'm%'
	set @_summary_option='m'
else if @_org_summary_option like 'd%'
	set @_summary_option='d'
else if @_org_summary_option like 'a%'
	set @_summary_option='a'
else 
	set @_summary_option='m'

if @_org_summary_option in ('t')
	set @_group_by='d'

SET @_temp_process_id=isnull(@_batch_process_id,dbo.FNAGetNewID())
SET @_user_login_id = dbo.FNADBUser() 

if isnull(@_process_table,'')=''
begin
	if  isnull(@_batch_process_id,'')=''
		set @_process_output_table=''
	else
	begin
		set @_process_output_table=' into '+dbo.FNAProcessTableName('batch_process', @_user_login_id, @_temp_process_id)
	end
end
else
begin
	if object_id(@_process_table) is not null  exec('drop table '+@_process_table)
	set @_process_output_table=' into '+	@_process_table
end

DECLARE @_default_dst_group VARCHAR(50) --='102202'

SELECT  @_default_dst_group = tz.dst_group_value_id
FROM
	(
		SELECT var_value default_timezone_id  FROM dbo.adiha_default_codes_values  
		WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
inner join dbo.time_zones tz  ON tz.timezone_id = df.default_timezone_id


SET @_effected_deals = dbo.FNAProcessTableName('report_position', @_user_login_id, @_temp_process_id)
SET @_unpvt = dbo.FNAProcessTableName('unpvt', @_user_login_id, @_temp_process_id)
SET @_tmp_pos_detail_power = dbo.FNAProcessTableName('tmp_pos_detail_power', @_user_login_id, @_temp_process_id)
SET @_tmp_pos_detail_gas = dbo.FNAProcessTableName('tmp_pos_detail_gas', @_user_login_id, @_temp_process_id)


DECLARE @_dst_group_value_id INT

SELECT @_dst_group_value_id = tz.dst_group_value_id FROM dbo.adiha_default_codes_values adcv
	INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adcv.instance_no = 1 AND adcv.default_code_id = 36 AND adcv.seq_no = 1



CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    
exec spa_print 'CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)  '  

SET @_Sql_Select ='   
	INSERT INTO #books
	SELECT DISTINCT book.entity_id,
		ssbm.source_system_book_id1,
		ssbm.source_system_book_id2,
		ssbm.source_system_book_id3,
		ssbm.source_system_book_id4 fas_book_id
	FROM   portfolio_hierarchy book
		INNER JOIN Portfolio_hierarchy stra
			ON  book.parent_entity_id = stra.entity_id
		INNER JOIN source_system_book_map ssbm
			ON  ssbm.fas_book_id = book.entity_id
	WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)  ' 
	+ CASE WHEN @_as_of_date IS NULL THEN ' AND 1=2 ' ELSE '' END 
        
IF @_sub_id IS NOT NULL   
	SET @_Sql_Select = @_Sql_Select + ' AND stra.parent_entity_id IN  ( '+ @_sub_id + ') '              
IF @_stra_id IS NOT NULL   
	SET @_Sql_Select = @_Sql_Select + ' AND (stra.entity_id IN('  + @_stra_id + ' ))'           
IF @_book_id IS NOT NULL   
	SET @_Sql_Select = @_Sql_Select + ' AND (book.entity_id IN('   + @_book_id + ')) '   
IF @_sub_book_id IS NOT NULL
	SET @_Sql_Select = @_Sql_Select + ' AND ssbm.book_deal_type_map_id IN (' + @_sub_book_id + ' ) '

exec spa_print @_Sql_Select   
EXEC ( @_Sql_Select)    

CREATE  INDEX [IX_Book] ON [#books]([fas_book_id])                    




SELECT rowid,clm_name, is_dst, alias_name, RIGHT('0' + CAST(LEFT(clm_name, 2) + 1 AS VARCHAR(10)), 2) + '_' + RIGHT(clm_name, 2) [process_clm_name]
	INTO #period_display_format
FROM dbo.FNAGetPivotGranularityColumn(@_term_start,@_term_end,case @_summary_option when 'h' then 982 when 'x' then 987 when 'y' then 989 else null end,@_dst_group_value_id) 
where 1= case when @_summary_option in ( 'h','x','y') then 1 else 0 end  
	and  @_as_of_date IS not NULL



select @_as_of_date=isnull(@_as_of_date,'9900-01-01')
--,@_term_start=isnull(@_term_start,'1900-01-01') ,
--	@_term_end=isnull(@_term_end,'9900-01-01') 
	,@_round_value=isnull(@_round_value,4)
--	select @_fltr_param return 

declare @_region_id varchar(3)

SELECT @_region_id =  cast(case region_id
		WHEN 1 THEN  101
		WHEN 3 THEN  110
		WHEN 2 THEN 103
		WHEN 5 THEN 104
		WHEN 4 THEN 105
		ELSE 120
	END as varchar)
FROM   application_users	WHERE  user_login_id = @_user_login_id 

-- If group by proxy curvem set group by ='l' and assign another variable
SET @_proxy_curve_view = 'n'

SET @_hour_pivot_table=dbo.FNAProcessTableName('hour_pivot', @_user_login_id,@_temp_process_id)  
SET @_position_deal=dbo.FNAProcessTableName('position_deal', @_user_login_id,@_temp_process_id)  
SET @_position_no_breakdown=dbo.FNAProcessTableName('position_no_breakdown', @_user_login_id,@_temp_process_id)  

--SET @_position_breakdown=dbo.FNAProcessTableName('position_breakdown', @_user_login_id,@_temp_process_id)  

SET @_baseload_block_type = '12000'	-- Internal Static Data
SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

IF @_baseload_block_define_id IS NULL 
	SET @_baseload_block_define_id = 'NULL'

IF @_hour_from IS NOT NULL
BEGIN
	IF @_hour_to IS NULL
		SET @_hour_to=@_hour_from
END	
ELSE
BEGIN
	IF @_hour_to IS NOT NULL
		SET @_hour_from= @_hour_to
END

IF NULLIF(@_format_option,'') IS NULL
	SET @_format_option='c'
	
DECLARE @_term_start_temp datetime,@_term_END_temp datetime  
 
CREATE TABLE #temp_deals 
(source_deal_header_id int, source_deal_detail_id int,term_start date,term_end date,as_of_date date,dst_group_value_id int,leg int, delta float
,physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT, pricing_type INT, internal_portfolio_id INT,template_id int, internal_deal_type_value_id int, internal_deal_subtype_value_id int
)
 
 
IF @_period_from IS NOT NULL AND @_period_to IS NULL
	SET @_period_to = @_period_from

IF @_period_from IS NULL AND @_period_to IS NOT NULL
	SET @_period_from = @_period_to


IF nullif(@_period_from,'1900') IS NOT NULL  
BEGIN   
	SET  @_term_start_temp= dbo.FNAGetTermStartDate('m', convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01', cast(@_period_from as int))
END  

IF nullif(@_period_to,'1900') IS NOT NULL  
BEGIN  
	SET  @_term_END_temp = dbo.FNAGetTermStartDate('m',convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+'01', cast(@_period_to as int)+1)
	set @_term_END_temp=dateadd(DAY,-1,@_term_END_temp)
END  

SET @_term_start=convert(varchar(20),isnull(@_term_start_temp ,@_term_start),120)
SET @_term_end=convert(varchar(20),isnull(@_term_END_temp ,@_term_end),120)


select @_term_start=isnull(@_term_start,'1900-01-01'),@_term_end=isnull(@_term_end,'9999-01-01')

--select @_term_start,@_term_end

IF @_term_start IS NOT NULL AND @_term_END IS NULL              
	SET @_term_END = @_term_start   
	           
IF @_term_start IS NULL AND @_term_END IS NOT NULL              
	SET @_term_start = @_term_END       	  
  
IF @_deal_date_from IS NOT NULL AND @_deal_date_to IS NULL              
	SET @_deal_date_to = @_deal_date_from  
	            
IF @_deal_date_from IS NULL AND @_deal_date_to IS NOT NULL              
	SET @_deal_date_from = @_deal_date_to  
   
----print 'CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    '


if @_group_by='d'
begin

	SET @_Sql_Select = '
	insert into #temp_deals(source_deal_header_id,source_deal_detail_id,term_start,term_end,dst_group_value_id
		,physical_financial_flag,pricing_type,internal_portfolio_id,template_id,internal_deal_type_value_id,internal_deal_subtype_value_id) 
	select sdh.source_deal_header_id,sdd.source_deal_detail_id,'''+@_term_start+''','''+@_term_end+''',tz.dst_group_value_id 
		,sdd.physical_financial_flag, sdh.pricing_type, sdh.internal_portfolio_id,sdh.template_id
		,sdh.internal_deal_type_value_id,sdh.internal_deal_subtype_value_id
	from dbo.source_deal_header sdh 
		inner join #books b on sdh.source_system_book_id1=b.source_system_book_id1 and sdh.source_system_book_id2=b.source_system_book_id2 
			and sdh.source_system_book_id3=b.source_system_book_id3 and sdh.source_system_book_id4=b.source_system_book_id4
		inner join source_deal_detail sdd  on sdh.source_deal_header_id=sdd.source_deal_header_id
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status 
		left JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
		where  sdh.source_deal_type_id IS NOT NULL '
		+case when @_source_deal_header_id is not null then ' and sdh.source_deal_header_id in ('+@_source_deal_header_id+')' else '' end
		+case when @_deal_type is not null then ' and sdh.source_deal_type_id ='+@_deal_type else '' end
		+CASE WHEN @_counterparty IS NOT NULL THEN ' AND sdh.counterparty_id IN (' + @_counterparty + ')'ELSE '' END
		+CASE WHEN @_trader_id IS NOT NULL THEN ' AND sdh.trader_id IN (' + @_trader_id + ')'ELSE '' END
		+CASE WHEN @_contract IS NOT NULL THEN ' AND sdh.contract_id IN (' + @_contract + ')'ELSE '' END
		+CASE WHEN @_deal_status IS NOT NULL THEN ' AND sdh.deal_status IN('+@_deal_status+')' ELSE '' END
		+CASE WHEN @_deal_date_from IS NOT NULL THEN ' AND sdh.deal_date>='''+@_deal_date_from +''' AND sdh.deal_date<='''+@_deal_date_to +'''' ELSE '' END  
		+CASE WHEN @_as_of_date IS NOT NULL THEN ' AND sdh.deal_date<='''+convert(varchar(10),@_as_of_date,120) +'''' ELSE '' END 
		+CASE WHEN @_product_id IS NOT NULL THEN ' AND sdh.internal_portfolio_id IN (' + @_product_id + ')'ELSE '' END
		+CASE WHEN @_curve_id IS NOT NULL THEN ' AND sdd.curve_id=' + @_curve_id  ELSE '' END
		+CASE WHEN @_location_id IS NOT NULL THEN ' AND sdd.location_id=' + @_location_id  ELSE '' END
		+CASE WHEN @_physical_financial_flag IS NOT NULL THEN ' AND sdd.physical_financial_flag=''' + @_physical_financial_flag+''''  ELSE '' END
		+CASE WHEN @_location_id IS NOT NULL THEN ' AND sdh.pricing_type=' + @_pricing_type  ELSE '' END

-- these below columns are not in position view
		+CASE WHEN @_template_id IS NOT NULL THEN ' AND sdh.template_id IN (' + @_template_id + ')' ELSE '' END
		+case when @_deal_id is not null then ' and sdh.deal_id LIKE ''%'+@_deal_id+ '%''' else '' end
		+case when @_confirm_status is not null then ' and sdh.confirm_status_type in ('+@_confirm_status+')' else '' end
		+case when @_profile is not null then ' and sdh.internal_desk_id in ('+@_profile+')' else '' end
		+case when @_deal_sub_type is not null then ' and sdh.deal_sub_type_type_id ='+@_deal_sub_type else '' end
		+CASE WHEN @_buy_sell_flag is not null THEN ' AND  sdd.buy_sell_flag='''+@_buy_sell_flag+'''' ELSE '' END

	exec spa_print @_Sql_Select  
	EXEC(@_Sql_Select)   

	IF @_show_delta_volume = 'y'
		update td set delta=case when td.leg=1 then sdpdo.DELTA when td.leg=2 then sdpdo.DELTA2 else 1 end
		from #temp_deals td 
		inner join source_deal_pnl_detail_options sdpdo on  sdpdo.source_deal_header_id = td.source_deal_header_id
				AND sdpdo.as_of_date = @_as_of_date AND sdpdo.term_start = td.term_start

end



create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)

IF ISNULL(@_mkt_con_flag, 'b') = 'b'
BEGIN
	insert into #term_date(block_define_id  ,term_date,term_start,term_end,
		hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
		,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
	)
	select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
		hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
		,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
		,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
	from (
		select distinct td.dst_group_value_id,
			isnull(spcd.block_define_id,nullif(@_baseload_block_define_id,'NULL')) block_define_id,s.term_start,s.term_end 
		from report_hourly_position_breakdown s    INNER JOIN #temp_deals td on s.source_deal_header_id=td.source_deal_header_id
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
			left JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id=s.curve_id 
			--left JOIN  vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id
			--	AND ISNULL(tz.formula_curve_id,-1)=ISNULL(s.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(s.location_id,-1)
	) a
	outer apply	(
		select h.* from hour_block_term h  where block_define_id=a.block_define_id and h.block_type=12000 
			and term_date between a.term_start  and a.term_end --and term_date>@_as_of_date
			and h.dst_group_value_id=a.dst_group_value_id
	) hb	
END

IF OBJECT_ID(N'tempdb..#temp_block_type_group_table') IS NOT NULL
	DROP TABLE #temp_block_type_group_table

CREATE TABLE #temp_block_type_group_table(block_type_group_id INT, block_type_id INT, block_name VARCHAR(200),hourly_block_id INT)

IF (@_block_type_group_id IS NOT NULL)	
	SET @_Sql_Select = 'INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
		SELECT block_type_group_id,block_type_id,block_name,hourly_block_id 				
		FROM block_type_group 
		WHERE block_type_group_id=' + CAST(@_block_type_group_id AS VARCHAR(100))
ELSE 
	SET @_Sql_Select ='INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
		SELECT NULL block_type_group_id, NULL block_type_id, ''Base load'' block_name, '+@_baseload_block_define_id+' hourly_block_id'

exec spa_print @_Sql_Select   
EXEC ( @_Sql_Select) 

--***************************              
--END of source book map table and build index              
--*****************************     

-- Collect Required Deals  

declare @_report_hourly_position_deal varchar(250)
	,@_report_hourly_position_profile varchar(250)
	,@_report_hourly_position_financial varchar(250)
	,@_report_hourly_position_breakdown varchar(250)

set @_select_st1=''
set @_select_st2 =''

if @_group_by='s' -- summary
begin
	set @_report_hourly_position_deal='vwHourly_position_AllFilter s '
	set @_report_hourly_position_profile='vwHourly_position_AllFilter_profile s '
	set @_report_hourly_position_financial= 'vwHourly_position_AllFilter_financial s '
	set @_report_hourly_position_breakdown= 'vwHourly_position_AllFilter_breakdown s '

end
else if @_group_by='d'   -- detail
begin
	if @_summary_option='z' --deal term 
	begin
		SET @_view_nameq='source_deal_detail'	
		SET @_view_name1='source_deal_detail'
	end
	else if @_summary_option in ('d','m') -- daily,monthly
	begin
		set @_report_hourly_position_deal='dbo.report_hourly_position_deal s '
		set @_report_hourly_position_profile='dbo.report_hourly_position_profile s '
		set @_report_hourly_position_financial= 'dbo.report_hourly_position_financial s '
		set @_report_hourly_position_breakdown= 'dbo.report_hourly_position_breakdown s '
	end
	else if @_summary_option in ('x','y','h') -- hourly
	begin
		set @_report_hourly_position_deal='dbo.report_hourly_position_deal s '
		set @_report_hourly_position_profile='dbo.report_hourly_position_profile s '
		set @_report_hourly_position_financial= 'dbo.report_hourly_position_financial s '
		set @_report_hourly_position_breakdown= 'dbo.report_hourly_position_breakdown s '
	end
end


-- repeat filter specially for group_by='s' Summary as already filter in above for detail option
SET @_scrt=''

SET @_scrt= 
	CASE WHEN @_term_start IS NOT NULL THEN ' AND s.term_start>='''+@_term_start +''' AND s.term_start<='''+@_term_end +'''' ELSE '' END 
	+CASE WHEN @_commodity_id IS NOT NULL THEN ' AND s.commodity_id IN ('+@_commodity_id+')' ELSE '' END
	+CASE WHEN @_curve_id IS NOT NULL THEN ' AND s.curve_id IN ('+@_curve_id+')' ELSE '' END
	+CASE WHEN @_location_id IS NOT NULL THEN ' AND s.location_id IN ('+@_location_id+')' ELSE '' END
	+CASE WHEN isnull(@_tenor_option,'a') <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END  
	+CASE WHEN isnull(@_physical_financial_flag,'b') <>'b' THEN ' AND s.physical_financial_flag='''+@_physical_financial_flag+'''' ELSE '' END
	+case when @_deal_type is not null then ' and s.deal_type ='+@_deal_type else '' end
	+CASE WHEN @_counterparty IS NOT NULL THEN ' AND s.counterparty_id IN (' + @_counterparty + ')'ELSE '' END
	+CASE WHEN @_trader_id IS NOT NULL THEN ' AND s.trader_id IN (' + @_trader_id + ')'ELSE '' END
	+CASE WHEN @_deal_status IS NOT NULL THEN ' AND s.deal_status_id IN('+@_deal_status+')' ELSE '' END
	+CASE WHEN @_deal_date_from IS NOT NULL THEN ' AND s.deal_date>='''+@_deal_date_from +''' AND s.deal_date<='''+@_deal_date_to +'''' ELSE '' END  
	+CASE WHEN @_as_of_date IS NOT NULL THEN ' AND s.deal_date<='''+convert(varchar(10),@_as_of_date,120) +'''' ELSE '' END 
	+CASE WHEN @_product_id IS NOT NULL THEN ' AND s.internal_portfolio_id IN (' + @_product_id + ')'ELSE '' END
	+CASE WHEN @_pricing_type IS NOT NULL THEN ' AND s.pricing_type=' + @_pricing_type  ELSE '' END

exec dbo.spa_print @_scrt

----------Start hourly_position_breakdown=null------------------------------------------------------------

if (isnull(@_include_no_breakdown,'n')='y' or  (@_group_by='d' and @_summary_option='z')) AND ISNULL(@_mkt_con_flag, 'b') = 'm' -- detail
begin

	SET @_scrt= 
		CASE WHEN @_term_start IS NOT NULL THEN ' AND sdd.term_start>='''+@_term_start +''' AND sdd.term_start<='''+@_term_end +'''' ELSE '' END 
		+CASE WHEN @_commodity_id IS NOT NULL THEN ' AND sdh.commodity_id IN ('+@_commodity_id+')' ELSE '' END
		+CASE WHEN @_curve_id IS NOT NULL THEN ' AND sdd.curve_id IN ('+@_curve_id+')' ELSE '' END
		+CASE WHEN @_location_id IS NOT NULL THEN ' AND sdd.location_id IN ('+@_location_id+')' ELSE '' END
		+CASE WHEN @_tenor_option <> 'a' THEN ' AND sdd.expiration_date>'''+@_as_of_date+''' AND sdd.term_start>'''+@_as_of_date+'''' ELSE '' END  
		+CASE WHEN isnull(@_physical_financial_flag,'b') <>'b' THEN ' AND sdd.physical_financial_flag='''+@_physical_financial_flag+'''' ELSE '' END

	set @_rpn='
		select sdh.source_deal_header_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3
		,sdh.source_system_book_id4,sdh.deal_date,sdh.counterparty_id,sdh.deal_status deal_status_id
		,sdd.curve_id,isnull(sdd.location_id,-1) location_id,sdd.term_start,sdd.term_end,sdd.total_volume,spcd.commodity_id
		,sdd.physical_financial_flag,sdd.deal_volume_uom_id,bk.fas_book_id,sdd.contract_expiration_date expiration_date,
		isnull(spcd.block_define_id,'+@_baseload_block_define_id+') block_define_id,sdd.source_deal_detail_id,td.dst_group_value_id
		,sdh.trader_id,sdh.contract_id,sdd.subbook_id,sdh.source_deal_type_id deal_type,sdh.pricing_type,sdh.internal_portfolio_id
		into '+ @_position_no_breakdown+'
		from source_deal_header sdh  '
			+case when isnull(@_include_no_breakdown,'n')='y' then 
				' inner join source_deal_header_template sdht on sdh.template_id=sdht.template_id and sdht.hourly_position_breakdown is null
			' else '' end +'
			inner join #temp_deals td on td.source_deal_header_id=sdh.source_deal_header_id
			inner join source_deal_detail sdd  on sdh.source_deal_header_id=sdd.source_deal_header_id
			--left JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
			--	AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status 
			INNER JOIN #books bk ON bk.source_system_book_id1=sdh.source_system_book_id1 AND bk.source_system_book_id2=sdh.source_system_book_id2 
			AND bk.source_system_book_id3=sdh.source_system_book_id3 AND bk.source_system_book_id4=sdh.source_system_book_id4
			left JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id=sdd.curve_id 
		where 1=1
		'+ @_scrt

	exec spa_print @_rpn
	exec(@_rpn)
end



if isnull(@_include_no_breakdown,'n')='y'
begin

	create table #term_date_no_break
	(
		block_define_id int ,term_date date,term_start date,term_end date,
		hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint
		,hr6 tinyint,hr7 tinyint,hr8 tinyint,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint
		,hr14 tinyint,hr15 tinyint,hr16 tinyint,hr17 tinyint,hr18 tinyint,hr19 tinyint
		,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int,volume_mult int,dst_group_value_id int
	)

	set @_rpn='
	insert into #term_date_no_break
	(
		block_define_id,term_date,term_start,term_end,
		hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 ,hr17 
		,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour,volume_mult,dst_group_value_id
	)
	select distinct a.block_define_id,hb.term_date,a.term_start ,a.term_end,
		hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
		,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,hb.volume_mult,a.dst_group_value_id
		from '+@_position_no_breakdown+' a
			outer apply	(
				select h.* from hour_block_term h  where block_define_id=a.block_define_id and h.block_type=12000 
					and term_date between a.term_start  and a.term_end --and term_date>'''+convert(varchar(10),@_as_of_date,120) +'''
					and h.dst_group_value_id=a.dst_group_value_id 
		) hb
	'
		
	exec spa_print @_rpn
	exec(@_rpn)

	create index indxterm_dat_no_break on #term_date_no_break(dst_group_value_id,block_define_id,term_start,term_end)
	
	SET @_dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
	
	SET @_vol_multiplier='*cast(cast(s.total_volume as numeric(26,12))/nullif(term_hrs.term_hrs,0) as numeric(28,16))'
		--+case when @_summary_option in ('x','y')  then ' /hrs.factor '	else '' end
	
	SET @_rpn='Union all
	select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,cast(isnull(hb.hr1,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END '+ @_vol_multiplier +'  AS Hr1
		,cast(isnull(hb.hr2,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr2
		,cast(isnull(hb.hr3,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr3
		,cast(isnull(hb.hr4,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr4
		,cast(isnull(hb.hr5,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr5
		,cast(isnull(hb.hr6,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr6
		,cast(isnull(hb.hr7,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr7
		,cast(isnull(hb.hr8,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr8
		,cast(isnull(hb.hr9,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr9
		,cast(isnull(hb.hr10,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr10
		,cast(isnull(hb.hr11,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr11
		,cast(isnull(hb.hr12,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr12
		,cast(isnull(hb.hr13,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr13'
	
	SET @_rpn1= ',cast(isnull(hb.hr14,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr14
		,cast(isnull(hb.hr15,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr15
		,cast(isnull(hb.hr16,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr16
		,cast(isnull(hb.hr17,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr17
		,cast(isnull(hb.hr18,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr18
		,cast(isnull(hb.hr19,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr19
		,cast(isnull(hb.hr20,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr20
		,cast(isnull(hb.hr21,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr21
		,cast(isnull(hb.hr22,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr22
		,cast(isnull(hb.hr23,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr23
		,cast(isnull(hb.hr24,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END'+ @_vol_multiplier+'  AS Hr24
		,'+@_dst_column+ @_vol_multiplier+' AS Hr25 ' 

	SET @_rpn2=
		',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
		,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date ,''y'' AS is_fixedvolume 
		,deal_status_id ,s.trader_id,s.contract_id,s.subbook_id,s.deal_type,s.pricing_type,s.internal_portfolio_id,-1 rowid
	from '+@_position_no_breakdown + ' s '+
		case when  @_group_by='s' then '' else ' 
			inner join #temp_deals td on  td.source_deal_detail_id=s.source_deal_detail_id
		'
		end+'
		left join #term_date_no_break hb on hb.term_start = s.term_start and hb.term_end=s.term_end  and hb.block_define_id=s.block_define_id 
			and hb.dst_group_value_id=s.dst_group_value_id
		outer apply ( select sum(volume_mult) term_hrs from #term_date_no_break h where h.term_start = s.term_start and h.term_end=s.term_end  and h.term_date>''' + @_as_of_date +''') term_hrs
	    where 1=1' +@_scrt
end

---------end hourly_position_breakdown=null------------------------------------------------------------
	
-------------------------------------------------------------------------------------------------------
-------------------Collect position into @_position_deal from all position table ------------------------------------

if isnull(@_physical_financial_flag,'b')<>'p' AND ISNULL(@_mkt_con_flag, 'b') <> 'm'
BEGIN 
	SET @_dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  

	SET @_remain_month ='*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@_as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@_as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)'
	--+case when @_summary_option in ('x','y')  then ' /hrs.factor '	else '' end    
		
	SET @_vol_multiplier='/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))'

	SET @_rhpb='select s.curve_id,'+ CASE WHEN @_view_name1='vwHourly_position_AllFilter' THEN '-1' ELSE 'ISNULL(s.location_id,-1)' END +' location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr1
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr2
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr3
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr4
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr5
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr6
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr7
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr8
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr9
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr10
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr11
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr12
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr13'
		
	SET @_rhpb1= ',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr14
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr15
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr16
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr17
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr18
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr19
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr20
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr21
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr22
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr23
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @_vol_multiplier +@_remain_month+'  AS Hr24
		,(cast(cast(s.calc_volume as numeric(22,10))* '+@_dst_column+' as numeric(22,10))) '+ @_vol_multiplier +@_remain_month+' AS Hr25 ' 
		
	SET @_rhpb2=case when  @_group_by='s' then '' else ',s.source_deal_header_id,s.source_deal_detail_id' end +		',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''y'' AS is_fixedvolume 
	,s.deal_status_id  ,s.trader_id,s.contract_id,s.subbook_id,s.deal_type,s.pricing_type,s.internal_portfolio_id,s.rowid
	from '+@_report_hourly_position_breakdown 
	+	case when  @_group_by='s' then '' else ' 
		inner join #temp_deals td on  td.source_deal_detail_id=s.source_deal_detail_id
		'
	end+'
		INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			' +CASE WHEN  @_group_by='d' and @_source_deal_header_id IS NOT NULL THEN ' and s.source_deal_header_id IN (' +CAST(@_source_deal_header_id AS VARCHAR) + ')' ELSE '' END 
		+'	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 ' 
		+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
			' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id ' ELSE '' END 
		+' left JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id=s.curve_id 
		LEFT JOIN source_price_curve_def spcd1  On spcd1.source_curve_def_id=spcd.settlement_curve_id
		outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@_baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END  and hbt.dst_group_value_id='+@_default_dst_group+'
		 ) term_hrs
		outer apply (
		 select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date --and  hbt.dst_group_value_id='+@_default_dst_group+'
		where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@_baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END and hbt.dst_group_value_id='+@_default_dst_group+'
			) term_hrs_exp
		left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,'+@_baseload_block_define_id+') and hb.term_start = s.term_start and hb.term_end=s.term_end  --and hb.term_date>''' + @_as_of_date +'''
		outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
		outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
		outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@_as_of_date+''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
			AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
			AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month 
	 where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@_as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		    AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
	' +CASE WHEN @_tenor_option <> 'a' THEN ' and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@_as_of_date+'''' ELSE '' END +
	@_scrt
			
END

SET @_sqry='select s.curve_id,s.location_id,s.term_start,s.Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
	,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16
	,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
	+case when  @_group_by='s' then '' else ',s.source_deal_header_id,s.source_deal_detail_id' end +',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1
	,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,s.deal_status_id  ,s.trader_id,s.contract_id,s.subbook_id,s.deal_type,s.pricing_type,s.internal_portfolio_id,s.rowid
INTO '+ @_position_deal +'  
from '+@_report_hourly_position_deal+
case when  @_group_by='s' then '' else ' 
	inner join #temp_deals td on  s.term_start between td.term_start and td.term_end
		and td.source_deal_detail_id=s.source_deal_detail_id
	'
end+'
	INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
	left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
+ @_scrt 

SET @_sqry1='
union all
select s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
	,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16
	,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
	+case when  @_group_by='s' then '' else ',s.source_deal_header_id,s.source_deal_detail_id' end 
	+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
	,s.expiration_date,''n'' AS is_fixedvolume,s.deal_status_id ,s.trader_id,s.contract_id,s.subbook_id,s.deal_type,s.pricing_type,s.internal_portfolio_id,s.rowid
	 from '+@_report_hourly_position_profile
	+ case when  @_group_by='s' then '' else ' 
		inner join #temp_deals td on  s.term_start between td.term_start and td.term_end
			and td.source_deal_detail_id=s.source_deal_detail_id
		'
	end
	+' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
			AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
			AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 
				
SET @_sqry2='
union all
select s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
	,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16
	,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
	+case when  @_group_by='s' then '' else ',s.source_deal_header_id,s.source_deal_detail_id' end 
	+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3
	,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,s.deal_status_id 
	,s.trader_id,s.contract_id,s.subbook_id,s.deal_type,s.pricing_type,s.internal_portfolio_id,s.rowid
from '+@_report_hourly_position_financial
+case when  @_group_by='s' then '' else ' 
	inner join #temp_deals td on  s.term_start between td.term_start and td.term_end
		and td.source_deal_detail_id=s.source_deal_detail_id
'end+'
	INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
	left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id
	'	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
		' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 			

IF isnull(@_physical_financial_flag,'b')<>'p'
	SET @_rhpb	='
		union all 
		' + @_rhpb	
ELSE
BEGIN
	SET @_rhpb	=''
	SET @_rhpb1	=''
	SET @_rhpb2	=''
	SET @_rhpb3	=''
END	
				
set @_rpn=isnull(@_rpn,'')
set @_rpn1= isnull(@_rpn1,'')
set @_rpn2=isnull(@_rpn2,'')

exec spa_print @_select_st1
exec spa_print @_select_st2
exec spa_print @_sqry
exec spa_print @_sqry1
exec spa_print @_sqry2
exec spa_print @_rhpb
exec spa_print @_rhpb1
exec spa_print @_rhpb2
exec spa_print @_rpn
exec spa_print @_rpn1
exec spa_print @_rpn2

exec(@_select_st1+@_select_st2	+@_sqry +@_sqry1+@_sqry2+ @_rhpb+ @_rhpb1+ @_rhpb2+ @_rpn+@_rpn1+@_rpn2)
		
exec('
	CREATE INDEX indx_tmp_subqry1'+@_temp_process_id+' ON '+@_position_deal +'(curve_id);
	CREATE INDEX indx_tmp_subqry2'+@_temp_process_id+' ON '+@_position_deal +'(location_id);
	CREATE INDEX indx_tmp_subqry3'+@_temp_process_id+' ON '+@_position_deal +'(counterparty_id)'
)

--end
-------------------END Collect position into @_position_deal from all position table -----------------------
-------------------------------------------------------------------------------------------------------


if @_convert_to_uom_id IS not NULL
begin

	SELECT from_source_uom_id convert_from_uom_id
		,to_source_uom_id convert_to_uom_id
		,conversion_factor
	INTO #unit_conversion
	FROM rec_volume_unit_conversion
	WHERE state_value_id IS NULL
		AND curve_id IS NULL
		AND assignment_type_value_id IS NULL
		AND to_curve_id IS NULL
end

IF @_group_by='d'
begin
	IF @_show_delta_volume = 'y'
	begin
		set @_select_st1='
			update s set
				hr1=hr1*t.delta,
				hr2=hr2*t.delta,
				hr3=hr3*t.delta,
				hr4=hr4*t.delta,
				hr5=hr5*t.delta,
				hr6=hr6*t.delta,
				hr7=hr7*t.delta,
				hr8=hr8*t.delta,
				hr9=hr9*t.delta,
				hr10=hr10*t.delta,
				hr11=hr11*t.delta,
				hr12=hr12*t.delta,
				hr13=hr13*t.delta,
				hr14=hr14*t.delta,
				hr15=hr15*t.delta,
				hr16=hr16*t.delta,
				hr17=hr17*t.delta,
				hr18=hr18*t.delta,
				hr19=hr19*t.delta,
				hr20=hr20*t.delta,
				hr21=hr21*t.delta,
				hr22=hr22*t.delta,
				hr23=hr23*t.delta,
				hr24=hr24*t.delta,
				hr25=hr25*t.delta
			from '+@_position_deal+' s
				inner join #temp_deals t on t.source_deal_detail_id=s.source_deal_detail_id
		'
		exec spa_print @_select_st1
		exec(@_select_st1)
	end


	select distinct sdd.source_deal_header_id,s.term_date, 
	case when is_dst=1 then 25 else s.hours end [hours], isnull(s.period,0) period, 1 non_money
		into #tmp_delta_0 -- select * from  #tmp_delta_0
	from source_deal_pnl_breakdown s
		inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
			and  td.internal_deal_type_value_id=103 and td.internal_deal_subtype_value_id=102
		 inner JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_header_id = s.source_deal_header_id
			and sdd.leg =s.leg and s.term_date between sdd.term_start and sdd.term_end
	where leg_mtm_deal<0  and s.as_of_date=@_as_of_date 
		and @_summary_option IN ('h','x','y') 

	create index indx_90909 on #tmp_delta_0 (source_deal_header_id,term_date,[hours], [period])

	if object_id('tempdb..#tmp_delta_pvt') is not null drop table #tmp_delta_pvt

	select * 
		into #tmp_delta_pvt -- select * from #tmp_delta_pvt
	from #tmp_delta_0  SourceTable
	Pivot 
	(
	max(non_money) for [hours]
		in ( [1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
	) pr
	if @@rowcount>0
	begin
		set @_sqry='update t set
			[hr1]=[hr1]*isnull([1],0.0000),
			[hr2]=[hr2]*isnull([2],0.0000),
			[hr3]=[hr3]*isnull([3],0.0000),
			[hr4]=[hr4]*isnull([4],0.0000),
			[hr5]=[hr5]*isnull([5],0.0000),
			[hr6]=[hr6]*isnull([6],0.0000),
			[hr7]=[hr7]*isnull([7],0.0000),
			[hr8]=[hr8]*isnull([8],0.0000),
			[hr9]=[hr9]*isnull([9],0.0000),
			[hr10]=[hr10]*isnull([10],0.0000),
			[hr11]=[hr11]*isnull([11],0.0000),
			[hr12]=[hr12]*isnull([12],0.0000),
			[hr13]=[hr13]*isnull([13],0.0000),
			[hr14]=[hr14]*isnull([14],0.0000),
			[hr15]=[hr15]*isnull([15],0.0000),
			[hr16]=[hr16]*isnull([16],0.0000),
			[hr17]=[hr17]*isnull([17],0.0000),
			[hr18]=[hr18]*isnull([18],0.0000),
			[hr19]=[hr19]*isnull([19],0.0000),
			[hr20]=[hr20]*isnull([20],0.0000),
			[hr21]=[hr21]*isnull([21],0.0000),
			[hr22]=[hr22]*isnull([22],0.0000),
			[hr23]=[hr23]*isnull([23],0.0000),
			[hr24]=[hr24]*isnull([24],0.0000),
			[hr25]=[hr25]*isnull([25],0.0000)
		from '+@_position_deal+ ' t 
			inner join #tmp_delta_pvt d on d.source_deal_header_id=t.source_deal_header_id
				and d.term_date=t.term_start and d.period=t.period
		'
		EXEC spa_print  @_sqry
		exec(@_sqry)
	end


	if @_convert_to_uom_id IS not NULL  --This is deal detail level conversion
	begin
		set @_select_st1='
			select distinct sdd.source_deal_detail_id,vw.term_start
			, isnull(case when sdd.physical_financial_flag=''p'' then cf_p.factor else cf_f.factor,1) end density_mult
			into #density_multiplier
			from #temp_deals vw 
				inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=vw.source_deal_detail_id 
				left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id --and spcd.conversion_value_id
				left join source_minor_location sml on sml.source_minor_location_id=sdd.location_id and sml.conversion_value_id is not null
				left join forecast_profile fp on fp.profile_id=COALESCE(sdd.profile_id,sml.profile_id,sml.proxy_profile_id)
				left join [dbo].[conversion_factor] h_p on h_p.conversion_value_id=sml.conversion_value_id	
					and h_p.from_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) and h_p.to_uom='+@_convert_to_uom_id+'
				left join [dbo].[conversion_factor] h_f on h_f.conversion_value_id=spcd.conversion_value_id
					and h_f.from_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) and h_f.to_uom='+@_convert_to_uom_id+'
				outer apply
				(
					select max(d.effective_date) effective_date from  [conversion_factor_detail] d where d.conversion_factor_id=h_p.conversion_factor_id
						and d.effective_date<=vw.term_start
				) cf_p_date
				outer apply
				(
					select max(d.effective_date) effective_date from [dbo].[conversion_factor_detail] d where d.conversion_factor_id=h_f.conversion_factor_id
						and d.effective_date<=vw.term_start
				) cf_f_date
				left join [dbo].[conversion_factor_detail] cf_p on cf_p.conversion_factor_id=h_p.conversion_factor_id
					and cf_p.effective_date=cf_p_date.effective_date
				left join dbo.[conversion_factor_detail] cf_f on cf_f.conversion_factor_id=h_f.conversion_factor_id
					and cf_f.effective_date=cf_f_date.effective_date
			where not (cf_p.factor is null and cf_f.factor is null);

			update s set
				hr1=hr1*isnull(t.density_mult,1),
				hr2=hr2*isnull(t.density_mult,1),
				hr3=hr3*isnull(t.density_mult,1),
				hr4=hr4*isnull(t.density_mult,1),
				hr5=hr5*isnull(t.density_mult,1),
				hr6=hr6*isnull(t.density_mult,1),
				hr7=hr7*isnull(t.density_mult,1),
				hr8=hr8*isnull(t.density_mult,1),
				hr9=hr9*isnull(t.density_mult,1),
				hr10=hr10*isnull(t.density_mult,1),
				hr11=hr11*isnull(t.density_mult,1),
				hr12=hr12*isnull(t.density_mult,1),
				hr13=hr13*isnull(t.density_mult,1),
				hr14=hr14*isnull(t.density_mult,1),
				hr15=hr15*isnull(t.density_mult,1),
				hr16=hr16*isnull(t.density_mult,1),
				hr17=hr17*isnull(t.density_mult,1),
				hr18=hr18*isnull(t.density_mult,1),
				hr19=hr19*isnull(t.density_mult,1),
				hr20=hr20*isnull(t.density_mult,1),
				hr21=hr21*isnull(t.density_mult,1),
				hr22=hr22*isnull(t.density_mult,1),
				hr23=hr23*isnull(t.density_mult,1),
				hr24=hr24*isnull(t.density_mult,1),
				hr25=hr25*isnull(t.density_mult,1)
			from '+@_position_deal+' s
				inner join #density_multiplier t on t.source_deal_detail_id=s.source_deal_detail_id
		'

		exec spa_print @_select_st1
		exec(@_select_st1)
	end

end

if @_convert_to_uom_id IS not NULL --This is uom level conversion so seperate from above conversion
begin
	set @_select_st1='
		update s set
			hr1=hr1*isnull(unt.conversion_factor,1),
			hr2=hr2*isnull(unt.conversion_factor,1),
			hr3=hr3*isnull(unt.conversion_factor,1),
			hr4=hr4*isnull(unt.conversion_factor,1),
			hr5=hr5*isnull(unt.conversion_factor,1),
			hr6=hr6*isnull(unt.conversion_factor,1),
			hr7=hr7*isnull(unt.conversion_factor,1),
			hr8=hr8*isnull(unt.conversion_factor,1),
			hr9=hr9*isnull(unt.conversion_factor,1),
			hr10=hr10*isnull(unt.conversion_factor,1),
			hr11=hr11*isnull(unt.conversion_factor,1),
			hr12=hr12*isnull(unt.conversion_factor,1),
			hr13=hr13*isnull(unt.conversion_factor,1),
			hr14=hr14*isnull(unt.conversion_factor,1),
			hr15=hr15*isnull(unt.conversion_factor,1),
			hr16=hr16*isnull(unt.conversion_factor,1),
			hr17=hr17*isnull(unt.conversion_factor,1),
			hr18=hr18*isnull(unt.conversion_factor,1),
			hr19=hr19*isnull(unt.conversion_factor,1),
			hr20=hr20*isnull(unt.conversion_factor,1),
			hr21=hr21*isnull(unt.conversion_factor,1),
			hr22=hr22*isnull(unt.conversion_factor,1),
			hr23=hr23*isnull(unt.conversion_factor,1),
			hr24=hr24*isnull(unt.conversion_factor,1),
			hr25=hr25*isnull(unt.conversion_factor,1)
		from '+@_position_deal+' s
			inner join #unit_conversion unt ON unt.convert_from_uom_id=s.deal_volume_uom_id AND unt.convert_to_uom_id='+CAST(@_convert_to_uom_id AS VARCHAR) +'
	'

	exec spa_print @_select_st1
	exec(@_select_st1)
end
	
-------------------------------------------------------------------------------------------------------
-------------------UNPIVOT @_position_deal into @_unpvt -----------------------
SET @_volume_clm=''''+ 	CASE @_summary_option
		when 'x' THEN '15 Min'
		when 'y' THEN '30 Min'
		when 'h' THEN 'Hourly'
		when 'd' THEN 'Daily'
		when 'm' THEN 'Monthly'
		when 'q' THEN 'Quarterly'
		when 'a' THEN 'Annually'
	end+''' Frequency ,
	ROUND((cast(SUM(hb1.hr1*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr7 else hb.hr1 end *' else '' end +'vw.hr1 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '7' ELSE '1' END  +',
	ROUND((cast(SUM(hb1.hr2*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr8 else hb.hr2 end *' else '' end +'vw.hr2 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '8' ELSE '2' END  +',
	ROUND((cast(SUM(hb1.hr3*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr3 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '9' ELSE '3' END  +',
	ROUND((cast(SUM(hb1.hr4*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr10 else hb.hr4 end *' else '' end +'vw.hr4 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '10' ELSE '4' END  +',
	ROUND((cast(SUM(hb1.hr5*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr11 else hb.hr5 end *' else '' end +'vw.hr5 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '11' ELSE '5' END  +',
	ROUND((cast(SUM(hb1.hr6*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr12 else hb.hr6 end *' else '' end +'vw.hr6 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '12' ELSE '6' END  +',
	ROUND((cast(SUM(hb1.hr7*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr13 else hb.hr7 end *' else '' end +'vw.hr7 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '13' ELSE '7' END  +',
	ROUND((cast(SUM(hb1.hr8*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr14 else hb.hr8 end *' else '' end +'vw.hr8 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '14' ELSE '8' END  +',
	ROUND((cast(SUM(hb1.hr9*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr15 else hb.hr9 end *' else '' end +'vw.hr9 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '15' ELSE '9' END  +',
	ROUND((cast(SUM(hb1.hr10*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr16 else hb.hr10 end *' else '' end +'vw.hr10 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '16' ELSE '10' END  +',
	ROUND((cast(SUM(hb1.hr11*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr17 else hb.hr11 end *' else '' end +'vw.hr11 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '17' ELSE '11' END  +',
	ROUND((cast(SUM(hb1.hr12*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr18 else hb.hr12 end *' else '' end +'vw.hr12 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '18' ELSE '12' END  +',
	ROUND((cast(SUM(hb1.hr13*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr19 else hb.hr13 end *' else '' end +'vw.hr13 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '19' ELSE '13' END  +',
	ROUND((cast(SUM(hb1.hr14*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr20 else hb.hr14 end *' else '' end +'vw.hr14 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '20' ELSE '14' END  +',
	ROUND((cast(SUM(hb1.hr15*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr21 else hb.hr15 end *' else '' end +'vw.hr15 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '21' ELSE '15' END  +',
	ROUND((cast(SUM(hb1.hr16*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr22 else hb.hr16 end *' else '' end +'vw.hr16 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '22' ELSE '16' END  +',
	ROUND((cast(SUM(hb1.hr17*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr23 else hb.hr17 end *' else '' end +'vw.hr17 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '23' ELSE '17' END  +',
	ROUND((cast(SUM(hb1.hr18*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr24 else hb.hr18 end *' else '' end +'vw.hr18 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '24' ELSE '18' END  +',
	ROUND((cast(SUM(hb1.hr19*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr1 else hb.hr19 end *' else '' end +'vw.hr19 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '1' ELSE '19' END  +',
	ROUND((cast(SUM(hb1.hr20*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr2 else hb.hr20 end *' else '' end +'vw.hr20 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '2' ELSE '20' END  +',
	ROUND((cast(SUM(hb1.hr21*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr3 else hb.hr21 end *' else '' end +'vw.hr21 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '3' ELSE '21' END  +',
	ROUND((cast(SUM(hb1.hr22*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr4 else hb.hr22 end *' else '' end +'vw.hr22 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '4' ELSE '22' END  +',
	ROUND((cast(SUM(hb1.hr23*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr5 else hb.hr23 end *' else '' end +'vw.hr23 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '5' ELSE '23' END  +',
	ROUND((cast(SUM(hb1.hr24*cast('+ case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr6 else hb.hr24 end *' else '' end +'vw.hr24 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr'+ CASE WHEN ISNULL(@_col_7_to_6,'n')='y' AND @_format_option<>'r' THEN '6' ELSE '24' END  +',
	'+CASE WHEN @_format_option ='r' THEN +'ROUND((cast(SUM(hb1.hr3*cast('+case WHEN @_group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr25 as numeric(20,8))'+CASE WHEN @_convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @_round_value + ') Hr25,' ELSE '' END

SET @_Sql_Select='
	SELECT '+case when  @_group_by='s' then '' else 'vw.source_deal_detail_id,vw.source_deal_header_id,' end 
		+'vw.physical_financial_flag,su.source_uom_id,isnull(spcd1.source_curve_def_id,spcd.source_curve_def_id) source_curve_def_id,vw.location_id,vw.counterparty_id,vw.fas_book_id,'
		+CASE WHEN  @_summary_option IN ('d','h','x','y')  THEN 'vw.term_start' ELSE CASE WHEN @_summary_option='m' THEN 'convert(varchar(8),vw.term_start,120)+''01''' WHEN @_summary_option='a' THEN 'convert(varchar(5),vw.term_start,120)+''01-01''' 
		WHEN @_summary_option='q' THEN 'CONVERT(VARCHAR(5),vw.term_start, 120)+case DATEPART(q,vw.term_start) when 1 then ''01'' when 2 then ''04'' when 3 then ''07'' when 4 then ''10'' end +''-01''' ELSE 'vw.term_start' END END+' [Term],vw.period [Period], '
			+ @_volume_clm+' max(su.uom_name) [UOM],MAX(vw.commodity_id) commodity_id,MAX(vw.is_fixedvolume) is_fixedvolume,vw.source_system_book_id1,vw.source_system_book_id2,vw.source_system_book_id3,vw.source_system_book_id4
			,max(ISNULL(grp.block_type_id, spcd.source_curve_def_id))  block_type_id,max(ISNULL(grp.block_name, spcd.curve_name)) block_name
		, max(sdv_block_group.code) [user_defined_block] ,max(sdv_block_group.value_id) [user_defined_block_id]
		,max(grp.block_type_group_id) block_type_group_id
		,grp.hourly_block_id,vw.trader_id,vw.contract_id,vw.subbook_id,vw.deal_type,vw.pricing_type,vw.internal_portfolio_id,vw.deal_status_id,vw.rowid
		,sum(hb1.volume_mult)  tot_hours, max(hb1.dst_applies) dst_applies
	INTO '+@_hour_pivot_table 
	+' FROM  '

SET @_rhpb3=
' vw ' + CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = vw.deal_status_id'  ELSE '' END +'
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=vw.curve_id 
	LEFT JOIN  source_price_curve_def spcd1 ON  spcd1.source_curve_def_id='+CASE WHEN @_proxy_curve_view = 'y' THEN  'spcd.proxy_curve_id' ELSE 'spcd.source_curve_def_id' END
+'  LEFT JOIN source_minor_location sml  ON sml.source_minor_location_id=vw.location_id
	left join static_data_value sdv1  on sdv1.value_id =sml.grid_value_id
	left join static_data_value sdv   on sdv.value_id =sml.country
	left join static_data_value sdv2  on sdv2.value_id =sml.region
	left join static_data_value sdv_prov  on sdv_prov.value_id =sml.province
	LEFT JOIN static_data_value sdv3  ON sdv3.value_id =sml.station_id
	LEFT JOIN static_data_value sdv4  ON sdv4.value_id =sml.dam_id
	left join source_major_location mjr  on  sml.source_major_location_ID=mjr.source_major_location_ID
	left join source_counterparty scp  on vw.counterparty_id = scp.source_counterparty_id	
	LEFT JOIN source_uom su  on su.source_uom_id=coalesce(vw.deal_volume_uom_id,spcd.display_uom_id,spcd.uom_id)
	CROSS JOIN #temp_block_type_group_table grp
	LEFT JOIN  hour_block_term hb1   ON hb1.dst_group_value_id='+@_default_dst_group+' 
		and hb1.block_define_id=COALESCE(grp.hourly_block_id,'+@_baseload_block_define_id+') AND hb1.term_date=vw.term_start
	LEFT JOIN static_data_value sdv_block_group  ON sdv_block_group.value_id = grp.block_type_group_id
WHERE 1=1 ' +
	CASE WHEN @_term_start IS NOT NULL THEN ' AND vw.term_start>='''+CAST(@_term_start AS VARCHAR)+''' AND vw.term_start<='''+CAST(@_term_END AS VARCHAR)+'''' ELSE '' END  
	+CASE WHEN @_parent_counterparty IS NOT NULL THEN ' AND  scp.parent_counterparty_id = ' + CAST(@_parent_counterparty AS VARCHAR) ELSE  '' END
	+CASE WHEN @_tenor_option <> 'a' THEN ' AND vw.expiration_date>'''+@_as_of_date+''' AND vw.term_start>'''+@_as_of_date+'''' ELSE '' END  
	+CASE WHEN @_country IS NOT NULL THEN ' AND sdv.value_id in('+ @_country +')' ELSE '' END
	+CASE WHEN @_region IS NOT NULL THEN ' AND sdv2.value_id in('+ @_region +')' ELSE '' END
	+CASE WHEN @_location_group_id IS NOT NULL THEN ' AND mjr.source_major_location_id='+ @_location_group_id ELSE '' END
	+CASE WHEN @_grid IS NOT NULL THEN ' AND sdv1.value_id in('+ @_grid +')' ELSE '' END
	+CASE WHEN @_province IS NOT NULL THEN ' AND sdv_prov.value_id in('+ @_province +')' ELSE '' END
	+CASE WHEN @_station_id IS NOT NULL THEN ' AND sdv3.value_id in('+ @_station_id+')' ELSE '' END
	+CASE WHEN @_dam_id IS NOT NULL THEN ' AND sdv4.value_id in('+ @_dam_id+')' ELSE '' END
+' GROUP BY '+case when  @_group_by='s' then '' else ' vw.source_deal_detail_id,vw.source_deal_header_id,'
	end +'isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),vw.location_id,'
+CASE WHEN  @_org_summary_option IN ('d','h','x','y')  THEN 'vw.term_start' 
ELSE 
	CASE WHEN @_summary_option='m' THEN 'convert(varchar(8),vw.term_start,120)+''01''' WHEN @_summary_option='a' THEN 'convert(varchar(5),vw.term_start,120)+''01-01''' 
		WHEN @_summary_option='q' THEN 'CONVERT(VARCHAR(5),vw.term_start, 120)+case DATEPART(q,vw.term_start) when 1 then ''01'' when 2 then ''04'' when 3 then ''07'' when 4 then ''10'' end +''-01'''  ELSE 'vw.term_start' END 
END
+',vw.period,su.source_uom_id,vw.physical_financial_flag,vw.counterparty_id,vw.fas_book_id,vw.source_system_book_id1,vw.source_system_book_id2
,vw.source_system_book_id3,vw.source_system_book_id4,grp.hourly_block_id
,vw.trader_id,vw.contract_id,vw.subbook_id,vw.deal_type,vw.pricing_type,vw.internal_portfolio_id,vw.deal_status_id,vw.rowid' 

exec spa_print '==============================================Aggregation=================================================='

exec spa_print @_Sql_Select
exec spa_print @_position_deal
exec spa_print @_rhpb3
	
exec(@_Sql_Select+@_position_deal+@_rhpb3)

SET @_rhpb_0= ' 
select unpvt.*,case when mv.[date] is null then 0 else 1 end dst,'
	+CASE WHEN  @_summary_option IN ('h','x','y')  THEN 'CASE WHEN commodity_id=-1 AND is_fixedvolume =''n'' AND  ([hours]<7 OR [hours]=25) THEN dateadd(DAY,1,unpvt.[term]) ELSE unpvt.[term] END' else  '[term]' end +' [term_date]
	,cast(case when mv.[date] is null and [Hours]<>25 then [Hours] else mv.[hour]+CASE WHEN commodity_id=-1 AND is_fixedvolume =''n'' then 18 else 0 end end as int) hr
into '+@_unpvt +'
from (
		SELECT '+case when  @_group_by='s' then '' else 's.source_deal_detail_id,s.source_deal_header_id,'  end
		+'s.source_curve_def_id,s.commodity_id,s.[Term],s.Period,s.is_fixedvolume,s.physical_financial_flag,s.source_uom_id,[UOM],counterparty_id,location_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,
			CAST( s.hr1 AS NUMERIC(38,20)) [1],
			CAST( s.hr2-case when m.[hour]=2 and s.commodity_id<>-1 then s.hr25 else 0 end  AS NUMERIC(38,20)) [2],
			CAST( s.hr3-case when m.[hour]=3 and s.commodity_id<>-1 then s.hr25 else 0 end AS NUMERIC(38,20)) [3],
			CAST( s.hr4 AS NUMERIC(38,20)) [4],
			CAST( s.hr5 AS NUMERIC(38,20)) [5],
			CAST( s.hr6 AS NUMERIC(38,20)) [6],
			CAST(s.hr7 AS NUMERIC(38,20)) [7],
			CAST(s.hr8 AS NUMERIC(38,20)) [8],
			CAST(s.hr9 AS NUMERIC(38,20)) [9],
			CAST( s.hr10 AS NUMERIC(38,20)) [10],
			CAST( s.hr11 AS NUMERIC(38,20)) [11],
			CAST( s.hr12 AS NUMERIC(38,20)) [12],
			CAST( s.hr13 AS NUMERIC(38,20)) [13],
			CAST( s.hr14 AS NUMERIC(38,20)) [14],
			CAST( s.hr15 AS NUMERIC(38,20)) [15],
			CAST( s.hr16 AS NUMERIC(38,20)) [16],
			CAST( s.hr17 AS NUMERIC(38,20)) [17],
			CAST( s.hr18 AS NUMERIC(38,20)) [18],
			CAST( s.hr19 AS NUMERIC(38,20)) [19],
			CAST( s.hr20 - case when m.[hour]+case when s.commodity_id=-1 then 18 else 0 end=20 then s.hr25 else 0 end AS NUMERIC(38,20)) [20],
			CAST( s.hr21 - case when m.[hour]+case when s.commodity_id=-1 then 18 else 0 end=21 then s.hr25 else 0 end AS NUMERIC(38,20)) [21],
			CAST( s.hr22 AS NUMERIC(38,20)) [22],
			CAST( s.hr23 AS NUMERIC(38,20)) [23],
			CAST( s.hr24 AS NUMERIC(38,20)) [24],
			CAST( s.hr25 AS NUMERIC(38,20)) [25]
			, block_type_id,block_name, [user_defined_block] ,[user_defined_block_id],block_type_group_id,hourly_block_id
			,trader_id,contract_id,subbook_id,deal_type,pricing_type,internal_portfolio_id,deal_status_id,rowid,tot_hours,dst_applies
		FROM '+@_hour_pivot_table+' s
			LEFT JOIN mv90_DST m  ON s.[term]=m.[date] AND m.insert_delete=''i'' 

	) p
	UNPIVOT
	(Volume for Hours IN
		([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
	) AS unpvt
	LEFT JOIN mv90_DST mv  ON unpvt.[term]=mv.[date] AND mv.insert_delete=''i'' AND unpvt.[Hours]=25 --and dst_applies=''y''
	--LEFT JOIN mv90_DST mv1  ON unpvt.[term]=mv1.[date]-1 AND mv1.insert_delete=''d''  and dst_applies=''y''
	--	AND  unpvt.[Hours]=case when commodity_id=-1 and mv1.[date] IS not NULL then mv1.Hour+18 else mv1.Hour end		
WHERE  (((unpvt.[Hours]=25 AND mv.[date] IS NOT NULL) OR (unpvt.[Hours]<>25)) 
--AND (mv1.[date] IS NULL)
)'
	+ CASE WHEN @_hour_from IS NOT NULL THEN ' and cast(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END as int) between '+CAST(@_hour_from AS VARCHAR) +' and ' +CAST(@_hour_to AS VARCHAR) ELSE '' END 
	+CASE WHEN @_block_type_group_id is not null  THEN ' and Volume is not null' else '' end
	+';
	CREATE NONCLUSTERED INDEX indx_unpvt111 ON '+@_unpvt +' ([source_curve_def_id]) INCLUDE ([Hours],[term_date]);
'

exec spa_print '=======================================Unpivot=============================================='

exec spa_print @_rhpb_0 
exec( @_rhpb_0)

---------------END data preparation for report output------------------------------------------
--return

exec spa_print '--===============================================================================================---'
exec spa_print '----- Logic for final output format of reports'
exec spa_print '--================================================================================================-'

declare @term_columns varchar(max),@term_group varchar(max),@extra_logic1 varchar(max)

Declare @common_columns varchar(max),@other_columns varchar(max),@group_by_columns varchar(max)
,@from_clause varchar(max),@where_clause varchar(max),@order_by_clause varchar(max)

set @extra_logic1=''
-- Build SELECT clause -----------------------------------------

set @term_group=case @_summary_option
	when 'a' then ' CONVERT(VARCHAR(4),vw.term_date, 120)+''-01-01'''
	when 'q' then 'CONVERT(VARCHAR(5),vw.term_date, 120)+case DATEPART(q,vw.term_date) when 1 then ''01'' when 2 then ''04'' when 3 then ''07'' when 4 then ''10'' end +''-01'''
	when 'm' then 'CONVERT(VARCHAR(8),vw.term_date, 120)+''01'''
else 'CONVERT(VARCHAR(10),vw.term_date, 120)' end

set @term_columns=@term_group+' term_start_disp,convert(varchar(4),max(vw.term_date),120) term_year,
	max(pdf.alias_name) period_alias_name,max(pdf.rowid) hr_rowid,
'
+
case when @_summary_option='a' then
	case when @_org_summary_option='a001' then ''
		when @_org_summary_option='a002' then ''
	else '' end
when @_summary_option='q' then
	case when @_org_summary_option='q001' then ''
		when @_org_summary_option='q002' then ''
	else '' end+
	' 
		''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter]
	'
when @_summary_option='m' then
	case when @_org_summary_option='a001' then ''
		when @_org_summary_option='a002' then ''
	else '' end+
	' 
		''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter]
		,RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) [term_start_month]
		,DATENAME(m,max(vw.term_date)) [term_start_month_name]
		,convert(varchar(4),max(vw.term_date),120) + '' - '' + RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) term_year_month
	'
when @_summary_option='d' then
	case when @_org_summary_option='a001' then ''
		when @_org_summary_option='a002' then ''
	else '' end+
	' 
		''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter]
		,RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) [term_start_month]
		,DATENAME(m,max(vw.term_date)) [term_start_month_name]
		,DATENAME(d,max(vw.term_date)) [term_day]
		,convert(varchar(4),max(vw.term_date),120) + '' - '' + RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) term_year_month
	'
when @_summary_option in ('h','x','y') then
	case when @_org_summary_option='h001' then ''
		when @_org_summary_option='h002' then ''
		when @_org_summary_option='x001' then ''
		when @_org_summary_option='x002' then ''
		when @_org_summary_option='x003' then ''
		when @_org_summary_option='x004' then ''
		when @_org_summary_option='y001' then ''
		when @_org_summary_option='y002' then ''
	else '' end+
	' 
	''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter]
	,RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) [term_start_month]
	,DATENAME(m,max(vw.term_date)) [term_start_month_name]
	,DATENAME(d,max(vw.term_date)) [term_day]
	,vw.[hr] term_hour
	,vw.DST'+case when @_summary_option IN ('x','y') then ',vw.Period' else ',max(vw.Period)' end+' term_period
	,convert(varchar(4),max(vw.term_date),120) + '' - '' + RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) term_year_month
	'

end

set @common_columns=case when  @_group_by='s' then ',max(vw.source_curve_def_id) index_id' 
	else 
	'
		,vw.source_deal_detail_id,vw.source_deal_header_id,vw.source_deal_header_id deal_id,max(sdh.deal_id) ref_id
		,max(sdd.leg) leg,case when max(sdd.buy_sell_flag)=''b'' then ''Buy'' else ''Sell'' end buy_sell,vw.source_curve_def_id index_id
' 
	end+'
	,max(vw.commodity_id) commodity_id
	,max(vw.Term) Term
	,max(vw.hr) Hours
	,max(vw.term_date) term_date
	,max(vw.Period) Period
	,sum(vw.Volume) Position
	,max(vw.UOM) postion_uom	
	,max(vw.is_fixedvolume) is_fixedvolume
	,max(vw.source_uom_id) source_uom_id
	,max(vw.counterparty_id) counterparty
	,max(vw.location_id) location_id
	,max(vw.source_system_book_id1) source_system_book_id1
	,max(vw.source_system_book_id2) source_system_book_id2
	,max(vw.source_system_book_id3) source_system_book_id3
	,max(vw.source_system_book_id4) source_system_book_id4
	,max(vw.block_type_id) block_type_id
	,max(vw.block_name) block_name
	,max(vw.user_defined_block) user_defined_block
	,max(vw.user_defined_block_id) user_defined_block_id
	--,max(vw.block_type_group_id) block_type_group_id
	,vw.hourly_block_id
	,max(vw.trader_id) trader_id
	,max(vw.contract_id) contract
	,max(vw.deal_type) deal_type
	,max(vw.pricing_type) pricing_type
	,max(vw.internal_portfolio_id) product_id 
	,max(cg.contract_name) [Contract name]
	,max(sc.counterparty_name) [Counterparty name]
	,max(com.commodity_name) commodity_name
	,max(sdv_product.code) [product_group]
	,max(sdt.source_deal_type_name)	[Deal Type Name]
	,max(mjr.location_name) location_group
	,max(sdv_price.code) [pricing type name]
	'+
	case when @_org_summary_option='x02s' then
		',sub.entity_id sub_id
		,stra.entity_id stra_id
		,vw.fas_book_id book_id
	'
	else
		',max(sub.entity_id) sub_id
		,max(stra.entity_id) stra_id
		,max(vw.fas_book_id) book_id
		'
	end +'
	,max(vw.subbook_id) sub_book_id
	,max(vw.deal_status_id) deal_status_id
	,CASE WHEN max(vw.physical_financial_flag) = ''p'' THEN ''Physical'' ELSE ''Financial'' END physical_financial_flag
	,CASE WHEN max(vw.physical_financial_flag) = ''f'' THEN max(coalesce(sml.Location_Name, spcd.curve_name)) ELSE max(sml.Location_Name) END location
	,max(isnull(spcd1.curve_name,spcd.curve_name)) [index]
	
'


set @_fltr_param=','''+
	isnull(@_summary_option,'    ') + ''' summary_option,'''+
	--case when @_group_by='d' then '' else 
	--	isnull(@_deal_id,'    ') + ''' deal_id,''' 
	--	+isnull(@_source_deal_header_id,'    ') + ''' source_deal_header_id,'''
	--end +
	isnull(@_as_of_date,'    ') + ''' as_of_date,'''+
	isnull(@_period_from,'    ') + ''' period_from,'''+
	isnull(@_period_to,'    ') + ''' period_to,'''+
	isnull(@_tenor_option,'    ') + ''' tenor_option, '''+
	isnull(@_deal_status,'    ') + ''' deal_status,'''+
	isnull(@_confirm_status,'    ') + ''' confirm_status,'''+	 
	isnull(@_term_start,'    ') + ''' term_start,'''+
	isnull(@_term_end,'    ') + ''' term_end,'''+
	isnull(@_mkt_con_flag,'    ') + ''' mkt_con_flag,'''+
	isnull(@_group_by,'    ') + ''' group_by,'''+
	isnull(@_block_group,'    ') + ''' block_group,'''+
	isnull(@_deal_date_from,'    ') + ''' deal_date_from,'''+
	isnull(@_deal_date_to,'    ') + ''' 	deal_date_to, '''+
	isnull(@_block_type_group_id,'    ') + ''' block_type_group_id,'''+
	isnull(@_convert_to_uom_id,'    ') + ''' convert_to_uom_id,''' +
	isnull(@_buy_sell_flag,'    ') + ''' buy_sell_flag,''' +
	isnull(@_proxy_curve_view,'    ') + ''' proxy_curve_view,''' +
	isnull(@_formula_curve_id,'    ') + ''' formula_curve_id,''' +
	isnull(@_include_actuals_from_shape,'    ') + ''' include_actuals_from_shape,''' +
	isnull(@_include_no_breakdown,'    ') + ''' include_no_breakdown,''' +
	isnull(@_deal_sub_type,'    ') + ''' deal_sub_type,''' +
	--isnull(@_leg,'    ') + ''' leg,''' +
	isnull(@_show_delta_volume,'    ') + ''' show_delta_volume,''' +
	isnull(@_forecast_profile_id,'    ') + ''' forecast_profile_id'


if @_summary_option='a' 
begin
	if @_org_summary_option='a001' 
		set @other_columns=''
	else if @_org_summary_option='a002'
		set @other_columns=''
	else 
		set @other_columns=''
end
else if @_summary_option='q' 
begin
	set @other_columns=''
end
else if @_summary_option='m' 
begin
	if @_org_summary_option in ('m00d','m00s') 
	begin
		set @other_columns='

			,max(psc.counterparty_name) parent_counterparty
			,max(sdv2.value_id) region_id
			,max(sdv.value_id) country_id
			,max(sdv1.value_id) grid_id
			,max(mjr.source_major_location_id) location_group_id
			,max(com.commodity_name) commodity
			,max(sb1.source_book_name) book_identifier1
			,max(sb2.source_book_name) book_identifier2
			,max(sb3.source_book_name) book_identifier3
			,max(sb4.source_book_name) book_identifier4
			,max(tdr.trader_name) trader
		'
		+case when @_group_by='d' then '
			,max(sdd.profile_id) profile_id
			,max(sdh.confirm_status_type) confirm_status_id
			--,max(sdh.deal_sub_type_type_id) deal_sub_type_id
			,max(reporting_group1.code) reporting_group1_name
			,max(reporting_group2.code) reporting_group2_name
			,max(reporting_group3.code) reporting_group3_name
			,max(reporting_group4.code) reporting_group4_name
			,max(reporting_group5.code) reporting_group5_name
			,max(ag_t.agg_term) agg_term
			,max(sdht.template_name) template_name
			,max(sdht.template_id) template_id
			,max(sdh.description1) description1
			,max(sdh.description2) description2
			,max(sdh.description3) description3
			,max(sdh.description4) description4
			,max(sdh.counterparty_id2) counterparty_id2
			,max(sub.entity_name) sub
			,max(stra.entity_name) strategy
			,max(book.entity_name) book
			,max(ssbm.logical_name) AS sub_book
			,max(sdd.deal_volume) [Deal Volume]
				,max(su.uom_name) [Volume UOM]
				,CASE max(sdd.deal_volume_frequency) WHEN   ''h'' THEN ''Hourly''
					WHEN ''d'' THEN ''Daily''
					WHEN ''m'' THEN ''Monthly''
					WHEN ''t'' THEN ''Term''
					WHEN ''a'' THEN  ''Annually''     
					WHEN ''x'' THEN ''15 Minutes''      
					WHEN ''y'' THEN  ''30 Minutes''   
				END  [deal_volume_frequency]   
			,max(sdh.deal_date) deal_date
			,max(vw.tot_hours)  tot_hours

		' else '' end
	end


end
else if @_summary_option='d' 
begin
	if @_org_summary_option in ('d00d','d00s') 
	begin

		set @other_columns='
			,max(psc.counterparty_name) parent_counterparty
			,max(sdv2.value_id) region_id
			,max(sdv.value_id) country_id
			,max(sdv1.value_id) grid_id
			,max(mjr.source_major_location_id) location_group_id
			,max(com.commodity_name) commodity
			,max(sb1.source_book_name) book_identifier1
			,max(sb2.source_book_name) book_identifier2
			,max(sb3.source_book_name) book_identifier3
			,max(sb4.source_book_name) book_identifier4
			,max(tdr.trader_name) trader

			'
			+case when @_group_by='d' then '
				,max(sdd.profile_id) profile_id
				,max(sdh.confirm_status_type) confirm_status_id
				,max(reporting_group1.code) reporting_group1_name
				,max(reporting_group2.code) reporting_group2_name
				,max(reporting_group3.code) reporting_group3_name
				,max(reporting_group4.code) reporting_group4_name
				,max(reporting_group5.code) reporting_group5_name
				,max(ag_t.agg_term) agg_term
				,max(sdht.template_name) template_name
				,max(sdht.template_id) template_id
				,max(sdh.description1) description1
				,max(sdh.description2) description2
				,max(sdh.description3) description3
				,max(sdh.description4) description4
				,max(sdh.counterparty_id2) counterparty_id2
				,max(sub.entity_name) sub
				,max(stra.entity_name) strategy
				,max(book.entity_name) book
				,max(ssbm.logical_name) AS sub_book
				,max(sdd.deal_volume) [Deal Volume]
				,max(su.uom_name) [Volume UOM]
				,CASE max(sdd.deal_volume_frequency) WHEN   ''h'' THEN ''Hourly''
					WHEN ''d'' THEN ''Daily''
					WHEN ''m'' THEN ''Monthly''
					WHEN ''t'' THEN ''Term''
					WHEN ''a'' THEN  ''Annually''     
					WHEN ''x'' THEN ''15 Minutes''      
					WHEN ''y'' THEN  ''30 Minutes''   
				END  [deal_volume_frequency]   

				,max(sdh.deal_date) deal_date
				,max(vw.tot_hours)  tot_hours


			' else '' end
	end
end
else if @_summary_option='h' 
begin
	if @_org_summary_option in ('h00d','h00s') 
	begin
		set @other_columns='
			,max(psc.counterparty_name) parent_counterparty
			,max(sdv2.value_id) region_id
			,max(sdv.value_id) country_id
			,max(sdv1.value_id) grid_id
			,max(mjr.source_major_location_id) location_group_id
			,max(com.commodity_name) commodity
			,max(sb1.source_book_name) book_identifier1
			,max(sb2.source_book_name) book_identifier2
			,max(sb3.source_book_name) book_identifier3
			,max(sb4.source_book_name) book_identifier4
			,max(tdr.trader_name) trader

			'
			+case when @_group_by='d' then '
				,max(sdd.profile_id) profile_id
				,max(sdh.confirm_status_type) confirm_status_id
				--,max(sdh.deal_sub_type_type_id) deal_sub_type_id
				,max(reporting_group1.code) reporting_group1_name
				,max(reporting_group2.code) reporting_group2_name
				,max(reporting_group3.code) reporting_group3_name
				,max(reporting_group4.code) reporting_group4_name
				,max(reporting_group5.code) reporting_group5_name
				,max(ag_t.agg_term) agg_term
				,max(sdht.template_name) template_name
				,max(sdht.template_id) template_id
				,max(sdh.description1) description1
				,max(sdh.description2) description2
				,max(sdh.description3) description3
				,max(sdh.description4) description4
				,max(sdh.counterparty_id2) counterparty_id2
				,max(sub.entity_name) sub
				,max(stra.entity_name) strategy
				,max(book.entity_name) book
				,max(ssbm.logical_name) AS sub_book
				,max(sdh.deal_date) deal_date
				,max(coalesce(sddh.actual_volume, sdd.actual_volume,sddh.schedule_volume, sdd.schedule_volume,sddh.deal_volume, sdd.deal_volume)) best_avial_volume
				,max(sdd.actual_volume) [Actual Volume]
				,max(sdd.schedule_volume) [Scheduled Volume]
				,max(sdd.deal_volume) [Deal Volume]
				,max(su.uom_name) [Volume UOM]
				,CASE max(sdd.deal_volume_frequency) WHEN   ''h'' THEN ''Hourly''
					WHEN ''d'' THEN ''Daily''
					WHEN ''m'' THEN ''Monthly''
					WHEN ''t'' THEN ''Term''
					WHEN ''a'' THEN  ''Annually''     
					WHEN ''x'' THEN ''15 Minutes''      
					WHEN ''y'' THEN  ''30 Minutes''   
				END  [deal_volume_frequency]   
				,max(ISNULL(sdv_curve_tou.code,''Base Load'')) curve_tou
				,max(sdv_block.code) [block_definition]
			' else '' end
	end
end
else if @_summary_option='x' 
begin
	if @_org_summary_option in ('x01s','x02s') --'15 Mins Power Position Report by Location'
	begin
		set @other_columns='
			,max(sc.counterparty_name) parent_counterparty
			,max(sdv2.value_id) region_id
			,max(sdv.value_id) country_id
			,max(sdv1.value_id) grid_id
			,max(mjr.source_major_location_id) location_group_id
			,max(sub.entity_name) sub
			,max(stra.entity_name) strategy
			,max(book.entity_name) book
			,max(ssbm.logical_name) sub_book

		'
	end
	else if @_org_summary_option in('x01d','x03d') --15 Mins Power Position Report by Deal
	begin
		set @other_columns='
			,max(sc.counterparty_name) parent_counterparty
			,max(sdv2.value_id) region_id
			,max(sdv.value_id) country_id
			,max(sdv1.value_id) grid_id
			,max(mjr.source_major_location_id) location_group_id
			,max(sdh.confirm_status_type) confirm_status_id
			,max(sdh.deal_sub_type_type_id) deal_sub_type_id
			,max(sdd.profile_id) profile_id
			,max(sdh.reporting_group1) reporting_group1
			,max(sdh.reporting_group2) reporting_group2 
			,max(sdh.reporting_group3) reporting_group3
			,max(sdh.reporting_group4) reporting_group4
			,max(sdh.reporting_group5) reporting_group5
			,max(reporting_group1.code) reporting_group1_name
			,max(reporting_group2.code) reporting_group2_name
			,max(reporting_group3.code) reporting_group3_name
			,max(reporting_group4.code) reporting_group4_name
			,max(reporting_group5.code) reporting_group5_name
			,max(sub.entity_name) sub
			,max(stra.entity_name) strategy
			,max(book.entity_name) book
			,max(ssbm.logical_name) AS sub_book

		'
	end
	else if @_org_summary_option='x02d' --15 Mins Position Report by Deal with Profile filter
	begin

		set @extra_logic1='
			select sdd.source_deal_detail_id,sdd.formula_curve_id,sdd.profile_id,scmd1.shipper_code1,scmd1.shipper_code shipper_code2
				,sdd.shipper_code1 shipper_code_id1,sdd.shipper_code2 shipper_code_id2,scmd1.external_id external_id1
			into #sdd_shipper_code
			from source_deal_detail sdd
				inner join #temp_deals td on td.source_deal_header_id=sdd.source_deal_header_id
				left join shipper_code_mapping_detail scmd1 on scmd1.shipper_code_mapping_detail_id=sdd.shipper_code1
			where 1=1 
		'
		--select * from #sdd_shipper_code
		--select * from #temp_deals
			+isnull(' AND sdd.shipper_code1 in (' + @_shipper_code_id1+')','')
			+isnull(' AND sdd.shipper_code2 in (' + @_shipper_code_id2+')','')
			+isnull(' AND sdd.profile_id in (' + @_forecast_profile_id+')','')
			+isnull(' AND sdd.formula_curve_id in (' + @_formula_curve_id+')','')


		set @other_columns='
			,max(sc.counterparty_name) parent_counterparty
			,max(sdv2.value_id) region_id
			,max(sdv.value_id) country_id
			,max(sdv1.value_id) grid_id
			,max(mjr.source_major_location_id) location_group_id
			,max(sdh.confirm_status_type) confirm_status_id
			,max(sdh.deal_sub_type_type_id) deal_sub_type_id
			,max(sdd.profile_id) forecast_profile_id
			,max(sdd.formula_curve_id) formula_curve_id
			,max(sdh.reporting_group1) reporting_group1
			,max(sdh.reporting_group2) reporting_group2 
			,max(sdh.reporting_group3) reporting_group3
			,max(sdh.reporting_group4) reporting_group4
			,max(sdh.reporting_group5) reporting_group5
			,max(reporting_group1.code) reporting_group1_name
			,max(reporting_group2.code) reporting_group2_name
			,max(reporting_group3.code) reporting_group3_name
			,max(reporting_group4.code) reporting_group4_name
			,max(reporting_group5.code) reporting_group5_name
			,max(ssc.shipper_code_id1) shipper_code_id1
			,max(ssc.shipper_code_id2) shipper_code_id2
		'
	end
end


-- End Build SELECT clause -----------------------------------------

-- Build FROM clause -----------------------------------------

set @from_clause=@_process_output_table +'
FROM '+ @_unpvt+' vw 
	left join #period_display_format pdf on pdf.[process_clm_name]= right(''0''+cast(vw.[hr] as varchar),2)+''_''+right(''0''+cast(vw.[period] as varchar),2)
		and pdf.is_dst=vw.dst
	left JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id = vw.source_curve_def_id 
	LEFT JOIN  source_price_curve_def spcd1 ON  spcd1.source_curve_def_id='
		+CASE WHEN @_proxy_curve_view = 'y' THEN  'spcd.proxy_curve_id' ELSE 'spcd.source_curve_def_id' END+'
	LEFT JOIN source_commodity com   ON com.source_commodity_id=vw.commodity_id 
	LEFT JOIN source_minor_location sml  ON sml.source_minor_location_id = vw.location_id
	LEFT JOIN source_major_location mjr  ON sml.source_major_location_ID=mjr.source_major_location_ID
	LEFT JOIN portfolio_hierarchy book  ON book.entity_id = vw.fas_book_id 
	LEFT JOIN portfolio_hierarchy stra  ON stra.entity_id = book.parent_entity_id 
	LEFT JOIN portfolio_hierarchy sub  ON sub.entity_id = stra.parent_entity_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = vw.counterparty_id 
	LEFT JOIN source_counterparty psc ON psc.source_counterparty_id=sc.parent_counterparty_id
	LEFT JOIN static_data_value sdv1  ON sdv1.value_id =sml.grid_value_id
	LEFT JOIN static_data_value sdv  ON sdv.value_id =sml.country
	LEFT JOIN static_data_value sdv2  ON sdv2.value_id =sml.region
	LEFT JOIN source_system_book_map ssbm WITH (NOLOCK) ON ssbm.source_system_book_id1 = vw.source_system_book_id1
		AND ssbm.source_system_book_id2 = vw.source_system_book_id2
		AND ssbm.source_system_book_id3 = vw.source_system_book_id3
		AND ssbm.source_system_book_id4 = vw.source_system_book_id4
	LEFT JOIN static_data_value sdv6 ON sdv6.value_id = vw.internal_portfolio_id
	left join source_traders tdr on tdr.source_trader_id=vw.trader_id 
	LEFT JOIN source_book sb1 ON sb1.source_book_id = vw.source_system_book_id1
	LEFT JOIN source_book sb2 ON sb2.source_book_id = vw.source_system_book_id2
	LEFT JOIN source_book sb3 ON sb3.source_book_id = vw.source_system_book_id3
	LEFT JOIN source_book sb4 ON sb4.source_book_id = vw.source_system_book_id4
	LEFT JOIN contract_group cg ON cg.contract_id = vw.contract_id
	LEFT JOIN static_data_value sdv_product ON sdv_product.value_id = vw.internal_portfolio_id AND sdv_product.type_id = 39800	
	left join source_deal_type sdt on sdt.source_deal_type_id=vw.deal_type
	LEFT JOIN static_data_value sdv_price ON sdv_price.value_id = vw.pricing_type AND sdv_price.type_id = 46700

	'

+ case when @_group_by='d' then '
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = vw.source_deal_header_id 
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = vw.source_deal_detail_id
	LEFT JOIN static_data_value reporting_group1 ON reporting_group1.value_id = sdh.[reporting_group1] AND reporting_group1.type_id = 113000
	LEFT JOIN static_data_value reporting_group2 ON reporting_group2.value_id = sdh.[reporting_group2] AND reporting_group2.type_id = 113100
	LEFT JOIN static_data_value reporting_group3 ON reporting_group3.value_id = sdh.[reporting_group3] AND reporting_group3.type_id = 113200
	LEFT JOIN static_data_value reporting_group4 ON reporting_group4.value_id = sdh.[reporting_group4] AND reporting_group4.type_id = 113300
	LEFT JOIN static_data_value reporting_group5 ON reporting_group5.value_id = sdh.[reporting_group5] AND reporting_group5.type_id = 113400
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	LEFT JOIN source_uom su ON su.source_uom_id= sdd.deal_volume_uom_id
	OUTER APPLY(SELECT TOP 1 CASE WHEN sdd.term_start<'''+@_as_of_date+''' THEN '' '' + CAST(YEAR(sdd.term_start) AS VARCHAR) + ''-YTD''
				WHEN MONTH(sdd.term_start)=MONTH('''+@_as_of_date+''') AND YEAR(sdd.term_start)=YEAR('''+@_as_of_date+''') THEN 
					CAST(YEAR(sdd.term_start) AS VARCHAR) + '' - Current Month''
				WHEN DATEDIFF(m,'''+@_as_of_date+''',sdd.term_start) <=3  THEN 
					convert(varchar(4),sdd.term_start,120) +''-''+ ''M'' + CAST(DATEDIFF(m,'''+@_as_of_date+''',sdd.term_start) AS VARCHAR) +'' ''+ ''('' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(sdd.term_start),-1)),3)) + '')''
				WHEN YEAR('''+@_as_of_date+''') =  YEAR(sdd.term_start) THEN 
					convert(varchar(4),sdd.term_start,120) + ''-''+ ''Q'' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR)
				ELSE  
					CAST(YEAR(sdd.term_start) AS VARCHAR) 
			END agg_term FROM portfolio_mapping_tenor
		) ag_t
	' 
	+	case when @_org_summary_option='h00d' then
	'
		LEFT JOIN static_data_value sdv_block ON sdv_block.value_id  = spcd.block_define_id
		LEFT JOIN static_data_value sdv_curve_tou ON sdv_curve_tou.value_id = spcd.curve_tou
	'
	else '' end
	+ CASE WHEN @_include_actuals_from_shape = 'y' THEN '
			OUTER APPLY (
				SELECT sddh.term_date, sddh.actual_volume, sddh.schedule_volume, sddh.volume deal_volume
				FROM source_deal_detail_hour sddh
				WHERE sddh.source_deal_detail_id = sdd.source_deal_detail_id
			) sddh
		'
		ELSE '
			OUTER APPLY (
				SELECT NULL term_date, NULL actual_volume, NULL schedule_volume, NULL deal_volume
			) sddh
		'
		END
else '' end
+
case when @_org_summary_option='x02d' then
	'
		inner join	#sdd_shipper_code ssc on ssc.source_deal_detail_id=vw.source_deal_detail_id
	'
else '' end




-- End Build FROM clause -----------------------------------------

-- Build GROUP BY clause -----------------------------------------

set @group_by_columns ='
GROUP BY '+ @term_group+ 
	case when @_group_by='d' then ',vw.source_deal_detail_id,vw.source_deal_header_id,vw.source_curve_def_id' 
	else 
		case when @_org_summary_option='x02s' then
			',sub.entity_id,stra.entity_id,vw.fas_book_id'
		else ',vw.rowid' end 
	end	+',vw.hourly_block_id'
	+
	case when @_summary_option IN ('h','x','y') then 
		',vw.[hr],vw.DST' +case when @_summary_option IN ('x','y') then ',vw.Period,pdf.alias_name,pdf.rowid' else '' end
	else '' end
	


-- End Build GROUP BY clause -----------------------------------------



exec spa_print '================================================Final Query===================================================================='
exec spa_print @extra_logic1
exec spa_print ';'
exec spa_print 'SELECT '
exec spa_print @term_columns
exec spa_print @common_columns 
exec spa_print @other_columns 
exec spa_print @_fltr_param
exec spa_print @from_clause
exec spa_print @where_clause
exec spa_print @group_by_columns
exec spa_print @order_by_clause

exec(
	@extra_logic1+';
	SELECT '
	+ @term_columns
	+ @common_columns 
	+ @other_columns 
	+ @_fltr_param
	+ @from_clause
	+ @where_clause
	+ @group_by_columns
	+ @order_by_clause
)


