IF OBJECT_ID('spa_position_report') IS NOT NULL
DROP PROCEDURE [dbo].[spa_position_report]
GO


CREATE proc [dbo].[spa_position_report]
	@_summary_option VARCHAR(6)=null, --  'd' Daily, 'h' =hourly,'x'/'y' = 15/30 minute, q=quatar, a=annual
	@_sub_id varchar(1000)=null, 
	@_stra_id varchar(1000)=null,
	@_book_id varchar(1000)=null,
	@_sub_book_id varchar(1000)=null,
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
	@_country varchar(1000)=null,
	@_region varchar(1000)=null,
	@_province varchar(1000)=null,
	@_deal_status varchar(8)=null,
	@_confirm_status varchar(8)=null,
	@_profile varchar(8)=null,
	@_term_start varchar(20)=null,
	@_term_end varchar(20)=null,
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
	@_block_type_group_id  VARCHAR(20)=Null,
	@_trader_id  VARCHAR(20)=Null,
	@_convert_to_uom_id  VARCHAR(20)=Null,
	@_physical_financial_flag NCHAR(6),
	@_include_actuals_from_shape varCHAR(6),
	@_leg VARCHAR(6) ,
	@_format_option char(1)	='r',
	@_group_by CHAR(1)='d' , -- s:summary (Index/Location  ) ; d=detail (deal level) 
	@_round_value varchar(1) ='4',
	@_convert_uom INT=null,
	@_col_7_to_6 VARCHAR(1)='n',
	@_include_no_breakdown varchar(1)='n' ,
	@_on_fly bit=0,
	@_internal_portfolio_id varchar(100)=null,
	@_template_id VARCHAR(1000)=Null,
	@_product_id VARCHAR(1000)=Null,
	@_show_delta_position VARCHAR(1000)=null,
	@_process_table varchar(500)=null,
	@_batch_process_id VARCHAR(100)=NULL
as
set nocount on

/*

--  select * from report_hourly_position_deal where source_deal_header_id=349



DECLARE @_contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @_contextinfo

declare
	@_summary_option VARCHAR(6)='h', --  'd' Detail, 'h' =hourly,'x'/'y' = 15/30 minute, q=quatar, a=annual
	@_sub_id varchar(1000)=null, 
	@_stra_id varchar(1000)=null,
	@_book_id varchar(1000)=null,
	@_sub_book_id varchar(1000)=null,
	@_as_of_date varchar(20)='2019-12-13',
	@_source_deal_header_id varchar(1000)=19738,
	@_period_from varchar(6)=Null,
	@_period_to varchar(6)=NUll,
	@_tenor_option varchar(6)='a',
	@_location_id varchar(1000)=null, 	-- 2670
	@_curve_id varchar(1000)=null,  -- 7105
	@_commodity_id varchar(8)=null,
	@_deal_id varchar(1000)=null,
	@_location_group_id  varchar(1000)=null,
	@_grid varchar(1000)=null,
	@_country varchar(1000)=null,
	@_region varchar(1000)=null,
	@_province varchar(1000)=null,
	@_deal_status varchar(8)=null,
	@_confirm_status varchar(8)=null,
	@_profile varchar(8)=null,
	@_term_start varchar(20)=null,
	@_term_end varchar(20)=null,
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
	@_block_type_group_id  VARCHAR(20)=null, --307043,307063
	@_trader_id  VARCHAR(20)=Null,
	@_convert_to_uom_id  VARCHAR(20)=Null,
	@_physical_financial_flag VARCHAR(6)=null,
	@_include_actuals_from_shape VARCHAR(6),
	@_leg VARCHAR(6)
	, @_format_option char(1)	='r',
	@_group_by CHAR(1)='d' , -- s:summary (Index/Location  ) ; d=detail (deal level) 
	@_round_value char(1) ='4',
	@_convert_uom INT=null,
	@_col_7_to_6 VARCHAR(1)='n',
	@_include_no_breakdown varchar(1)='n' 
	,@_on_fly bit=0
	,@_internal_portfolio_id varchar(100)=null
	,@_template_id VARCHAR(1000)=Null
	,@_product_id VARCHAR(1000)=Null
	,@_show_delta_position VARCHAR(1000)=null -- support only for @_group_by='d'
	,@_process_table varchar(500)=null
	,@_batch_process_id VARCHAR(100)=NULL

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



-------START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
DECLARE @_sqry2  VARCHAR(MAX)

DECLARE @_user_login_id     VARCHAR(50), @_proxy_curve_view  CHAR(1),@_hypo_breakdown VARCHAR(MAX)
	,@_hypo_breakdown1 VARCHAR(MAX) ,@_hypo_breakdown2 VARCHAR(MAX),@_hypo_breakdown3 VARCHAR(MAX)
	
DECLARE @_baseload_block_type VARCHAR(10)
DECLARE @_baseload_block_define_id VARCHAR(10)
Declare @_fltr_param varchar(max)

CREATE TABLE #source_deal_header_id (source_deal_header_id VARCHAR(200) COLLATE DATABASE_DEFAULT)

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
	,@_delta_factor_column varchar(1000)

set @_delta_factor_column=case when isnull(@_show_delta_position,'n')='y' and @_group_by='d' then 'coalesce(sdpdo.DELTA,sdpdo2.DELTA2,1)*' else '' end

if @_org_summary_option in ('x','y','t')
	set @_summary_option='h' 
else if @_org_summary_option like 'm%'
	set @_summary_option='m'
else if @_org_summary_option like 'd%'
	set @_summary_option='d'
else if @_org_summary_option like 'a%'
	set @_summary_option='a'
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

DECLARE @_default_dst_group VARCHAR(50)

SELECT  @_default_dst_group = tz.dst_group_value_id
FROM
	(
		SELECT var_value default_timezone_id  FROM dbo.adiha_default_codes_values (NOLOCK) 
		WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
inner join dbo.time_zones tz (NOLOCK) ON tz.timezone_id = df.default_timezone_id

SET @_effected_deals = dbo.FNAProcessTableName('report_position', @_user_login_id, @_temp_process_id)
SET @_unpvt = dbo.FNAProcessTableName('unpvt', @_user_login_id, @_temp_process_id)
SET @_tmp_pos_detail_power = dbo.FNAProcessTableName('tmp_pos_detail_power', @_user_login_id, @_temp_process_id)
SET @_tmp_pos_detail_gas = dbo.FNAProcessTableName('tmp_pos_detail_gas', @_user_login_id, @_temp_process_id)

CREATE TABLE #unit_conversion(  
	convert_from_uom_id INT,  
	convert_to_uom_id INT,  
	conversion_factor NUMERIC(38,20)  
)  

set @_as_of_date=isnull(@_as_of_date,'9900-01-01')

set @_fltr_param=','''+
	isnull(@_sub_id,'    ') + ''' sub_id,'''+ 
	isnull(@_stra_id,'    ') + ''' stra_id,'''+
	isnull(@_book_id,'    ') + ''' book_id,'''+
	isnull(@_sub_book_id,'    ') + ''' sub_book_id,'''+
	isnull(@_summary_option,'    ') + ''' summary_option,cast('''+
	isnull(@_as_of_date,'    ') + ''' as datetime) as_of_date,'''+
	isnull(@_source_deal_header_id,'    ') + ''' source_deal_header_id,'''+
	isnull(@_period_from,'    ') + ''' period_from,'''+
	isnull(@_period_to,'    ') + ''' period_to,'''+
	isnull(@_tenor_option,'    ') + ''' tenor_option, '''+
	isnull(@_location_id,'    ') + ''' location_id,'''+
	isnull(@_curve_id,'    ') + ''' curve_id,'''+
	isnull(@_commodity_id,'    ') + ''' commodity_id,'''+
--	isnull(@_deal_id,'    ') + ''' deal_id,'''+
	isnull(@_deal_status,'    ') + ''' deal_status,'''+
	isnull(@_confirm_status,'    ') + ''' confirm_status,cast(MAX(vw.term_date) as datetime) term_start,
	cast(MAX(sdd02.term_end) as datetime) term_end,'''+	 
	--isnull(@_term_start,'    ') + ''' term_start,'''+
	--isnull(@_term_end,'    ') + ''' term_end,'''+
	isnull(@_deal_type,'    ') + ''' deal_type, '''+
--	isnull(@_buy_sell_flag,'    ') + ''' buy_sell_flag,'''+
	isnull(@_counterparty,'    ') + ''' counterparty,'''+
	isnull(@_block_group,'    ') + ''' block_group,cast('''+
	isnull(@_deal_date_from,'    ') + ''' as datetime) deal_date_from,cast('''+
	isnull(@_deal_date_to,'    ') + ''' as datetime) deal_date_to, '''+
	isnull(@_block_type_group_id,'    ') + ''' block_type_group_id,'''+
	isnull(@_trader_id,'    ') + ''' trader_id,'''+
	isnull(@_convert_to_uom_id,'    ') + ''' convert_to_uom_id,'''+
	isnull(@_internal_portfolio_id,'    ') + ''' internal_portfolio_id,'''+
	isnull(@_template_id,'    ') + ''' template_id ,'''+
	isnull(@_show_delta_position,'    ') + ''' show_delta_position,'''+
	isnull(@_product_id,'    ') + '''product_id'
	
	--isnull(@_physical_financial_flag,'    ') + ''' physical_financial_flag'


--Miss parameter in filter.
	 --@_location_group_id  varchar(1000)=null,
	 --@_grid varchar(1000)=null,
	 --@_country varchar(1000)=null,
	 --@_region varchar(1000)=null,
	 --@_province varchar(1000)=null,
	 --@_profile varchar(8)=null,
	-- @_deal_sub_type varchar(8)=null,
	 --@_hour_from varchar(6)=null,
	 --@_hour_to varchar(6)=null,
	-- @_parent_counterparty VARCHAR(10) = NULL,
	-- @_include_actuals_from_shape varCHAR(6),
	-- @_leg VARCHAR(6) ,
	--@_format_option char(1)	='r',
	--@_group_by CHAR(1)='d' , -- s:summary(Index/Location  ) ; d=detail(deal level) 
	--@_round_value varchar(1) ='4',
	--@_convert_uom INT=null,
	--@_col_7_to_6 VARCHAR(1)='n',
	--@_include_no_breakdown varchar(1)='n' 
	--,@_on_fly bit=0



INSERT INTO #unit_conversion(convert_from_uom_id,convert_to_uom_id,conversion_factor)    
SELECT   
	from_source_uom_id,  to_source_uom_id,  conversion_factor  
FROM  rec_volume_unit_conversion  
WHERE  state_value_id IS NULL  
  AND curve_id IS NULL  
  AND assignment_type_value_id IS NULL  
  AND to_curve_id IS NULL  

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
 
CREATE TABLE #temp_deals ( source_deal_header_id int)
 
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
      
CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    

SET @_Sql_Select ='   
	INSERT INTO #books
	SELECT DISTINCT book.entity_id,
		ssbm.source_system_book_id1,
		ssbm.source_system_book_id2,
		ssbm.source_system_book_id3,
		ssbm.source_system_book_id4 fas_book_id
	FROM   portfolio_hierarchy book(NOLOCK)
			INNER JOIN Portfolio_hierarchy stra(NOLOCK)
				ON  book.parent_entity_id = stra.entity_id
			INNER JOIN source_system_book_map ssbm
				ON  ssbm.fas_book_id = book.entity_id
	WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)  ' 

        
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


create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)


if @_group_by='d'
begin
	SET @_Sql_Select = '
		insert into #temp_deals(source_deal_header_id) select sdh.source_deal_header_id from dbo.source_deal_header sdh 
		inner join #books b on sdh.source_system_book_id1=b.source_system_book_id1 and sdh.source_system_book_id2=b.source_system_book_id2 
			and sdh.source_system_book_id3=b.source_system_book_id3 and sdh.source_system_book_id4=b.source_system_book_id4
		where 1=1 --sdh.source_deal_type_id<>1177
		 '
			+case when @_source_deal_header_id is not null then ' and sdh.source_deal_header_id in ('+@_source_deal_header_id+')' else '' end
			+case when @_deal_id is not null then ' and sdh.deal_id LIKE ''%'+@_deal_id+ '%''' else '' end
			+case when @_confirm_status is not null then ' and sdh.confirm_status_type in ('+@_confirm_status+')' else '' end
			+case when @_profile is not null then ' and sdh.internal_desk_id in ('+@_profile+')' else '' end
			+case when @_deal_type is not null then ' and sdh.source_deal_type_id ='+@_deal_type else '' end
			+case when @_deal_sub_type is not null then ' and sdh.deal_sub_type_type_id ='+@_deal_sub_type else '' end
			+CASE WHEN @_counterparty IS NOT NULL THEN ' AND sdh.counterparty_id IN (' + @_counterparty + ')'ELSE '' END
			+CASE WHEN @_trader_id IS NOT NULL THEN ' AND sdh.trader_id IN (' + @_trader_id + ')'ELSE '' END
			+CASE WHEN @_deal_status IS NOT NULL THEN ' AND sdh.deal_status IN('+@_deal_status+')' ELSE '' END
			+CASE WHEN @_deal_date_from IS NOT NULL THEN ' AND sdh.deal_date>='''+@_deal_date_from +''' AND sdh.deal_date<='''+@_deal_date_to +'''' ELSE '' END  
			+CASE WHEN @_as_of_date IS NOT NULL THEN ' AND sdh.deal_date<='''+convert(varchar(10),@_as_of_date,120) +'''' ELSE '' END 
			+CASE WHEN @_internal_portfolio_id IS NOT NULL THEN ' AND sdh.internal_portfolio_id IN (' + @_internal_portfolio_id + ')'ELSE '' END
			+CASE WHEN @_template_id IS NOT NULL THEN ' AND sdh.template_id IN (' + @_template_id + ')'ELSE '' END
			+CASE WHEN @_product_id IS NOT NULL THEN ' AND sdh.internal_portfolio_id IN (' + @_product_id + ')'ELSE '' END

	exec spa_print @_Sql_Select  
	EXEC(@_Sql_Select)   
	

	insert into #term_date(block_define_id  ,term_date,term_start,term_end,
		hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
		,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
	)
	select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
		hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
		,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
		,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
	from (
		select distinct tz.dst_group_value_id,
			isnull(spcd.block_define_id,nullif(@_baseload_block_define_id,'NULL')) block_define_id,s.term_start,s.term_end 
		from report_hourly_position_breakdown s  (nolock)  INNER JOIN #temp_deals td on s.source_deal_header_id=td.source_deal_header_id
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			left JOIN  vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id
				AND ISNULL(tz.formula_curve_id,-1)=ISNULL(s.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(s.location_id,-1)
		) a
		outer apply	(
			select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
				and term_date between a.term_start  and a.term_end --and term_date>@_as_of_date
				and h.dst_group_value_id=a.dst_group_value_id
		) hb	
	

end



IF OBJECT_ID(N'tempdb..#temp_block_type_group_table') IS NOT NULL
	DROP TABLE #temp_block_type_group_table

CREATE TABLE #temp_block_type_group_table(block_type_group_id INT, block_type_id INT, block_name VARCHAR(200) COLLATE DATABASE_DEFAULT,hourly_block_id INT)

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


----print 'CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(2,1))    '

CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(6,2))  

set @_summary_option=isnull(nullif(@_summary_option,'1900'),'m')


if @_summary_option='y' --30 minutes
begin
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,48),(981,30,2)

	insert into #minute_break ( granularity ,period , factor )  --hourly
	values (982,0,2),(982,30,2)
end    
else if @_summary_option='x' --15 minutes
begin
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,96),(981,15,96),(981,30,96),(981,45,4)

	insert into #minute_break ( granularity ,period , factor )  --hourly
	values (982,0,4),(982,15,4),(982,30,4),(982,45,4)
	
	insert into #minute_break ( granularity ,period , factor )  --30 minute
	values (989,15,2),(989,45,2)
end
     
  
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

if @_on_fly=0
begin
	if @_group_by='s' -- summary
	begin
		set @_report_hourly_position_deal='vwHourly_position_AllFilter s WITH(NOEXPAND)'
		set @_report_hourly_position_profile='vwHourly_position_AllFilter_profile s WITH(NOEXPAND)'
		set @_report_hourly_position_financial= 'vwHourly_position_AllFilter_financial s WITH(NOEXPAND)'
		set @_report_hourly_position_breakdown= 'vwHourly_position_AllFilter_breakdown s WITH(NOEXPAND)'

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
			set @_report_hourly_position_deal='dbo.report_hourly_position_deal s (nolock)'
			set @_report_hourly_position_profile='dbo.report_hourly_position_profile s (nolock)'
			set @_report_hourly_position_financial= 'dbo.report_hourly_position_financial s (nolock)'
			set @_report_hourly_position_breakdown= 'dbo.report_hourly_position_breakdown s (nolock)'
		end
		else if @_summary_option='h' -- hourly
		begin
			set @_report_hourly_position_deal='dbo.report_hourly_position_deal s (nolock)'
			set @_report_hourly_position_profile='dbo.report_hourly_position_profile s (nolock)'
			set @_report_hourly_position_financial= 'dbo.report_hourly_position_financial s (nolock)'
			set @_report_hourly_position_breakdown= 'dbo.report_hourly_position_breakdown s (nolock)'
		end
	end
end --@_on_fly=0
else 
begin --@_on_fly=1
	set @_Sql_Select='
		SELECT sdh.source_deal_header_id,''i'' [Action],'''+@_user_login_id+''' create_user,111 insert_type,max(isnull(sdh.internal_desk_id,17300)) deal_type ,
			max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation into '
			+@_effected_deals+'
		FROM  #temp_deals h inner join source_deal_header sdh on h.source_deal_header_id=sdh.source_deal_header_id
				inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
				left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		group by sdh.source_deal_header_id
	'
	exec spa_print  @_Sql_Select
	exec(@_Sql_Select)

	exec spa_print  '@_process_id: '
	exec spa_print  @_temp_process_id
	exec spa_print  '@_user_login_id: ' 
	exec spa_print  @_user_login_id

	exec [dbo].[spa_maintain_transaction_job]
		@_process_id=@_temp_process_id,
		@_insert_type=111 , -- 222 = calc physical position only and insert result into process table; 111=calc both physical and financial position and insert result into process table .(This option support sp is applied in Release Version..
		@_partition_no =NULL,
		@_user_login_id  =@_user_login_id

	--these process table will be created by calling sp exec [dbo].[spa_maintain_transaction_job_new]
	set @_report_hourly_position_deal=dbo.FNAProcessTableName('report_hourly_position_deal', @_user_login_id, @_temp_process_id) 
	set @_report_hourly_position_profile=dbo.FNAProcessTableName('report_hourly_position_profile', @_user_login_id, @_temp_process_id) 
	set @_report_hourly_position_financial= dbo.FNAProcessTableName('report_hourly_position_financial', @_user_login_id, @_temp_process_id)
	set @_report_hourly_position_breakdown= dbo.FNAProcessTableName('report_hourly_position_breakdown', @_user_login_id, @_temp_process_id) 


	if  @_group_by='s'
	begin
		set @_select_st1='SELECT ddh.curve_id,ddh.location_id,ddh.term_start term_start,ddh.deal_date,
			SUM(ISNULL(ddh.HR1,0)) HR1,SUM(ISNULL(ddh.HR2,0)) HR2,SUM(ISNULL(ddh.HR3,0)) HR3,
			SUM(ISNULL(ddh.HR4,0)) HR4,SUM(ISNULL(ddh.HR5,0)) HR5,SUM(ISNULL(ddh.HR6,0)) HR6,
			SUM(ISNULL(ddh.HR7,0)) HR7,SUM(ISNULL(ddh.HR8,0)) HR8,SUM(ISNULL(ddh.HR9,0)) HR9,
			SUM(ISNULL(ddh.HR10,0)) HR10,SUM(ISNULL(ddh.HR11,0)) HR11,SUM(ISNULL(ddh.HR12,0)) HR12,
			SUM(ISNULL(ddh.HR13,0)) HR13,SUM(ISNULL(ddh.HR14,0)) HR14,SUM(ISNULL(ddh.HR15,0)) HR15,
			SUM(ISNULL(ddh.HR16,0)) HR16,SUM(ISNULL(ddh.HR17,0)) HR17,SUM(ISNULL(ddh.HR18,0)) HR18,
			SUM(ISNULL(ddh.HR19,0)) HR19,SUM(ISNULL(ddh.HR20,0)) HR20,SUM(ISNULL(ddh.HR21,0)) HR21,
			SUM(ISNULL(ddh.HR22,0)) HR22,SUM(ISNULL(ddh.HR23,0)) HR23,SUM(ISNULL(ddh.HR24,0)) HR24,
			SUM(ISNULL(ddh.HR25,0)) HR25 
			,ddh.commodity_id,ddh.counterparty_id,ddh.fas_book_id,
			ddh.source_system_book_id1,ddh.source_system_book_id2,ddh.source_system_book_id3,
			ddh.source_system_book_id4,ddh.deal_volume_uom_id,ddh.physical_financial_flag,ddh.expiration_date,
			ddh.deal_status_id,ddh.period,ddh.granularity
			into #vwHourly_position_AllFilter
		FROM '+@_report_hourly_position_deal+' ddh 
		GROUP BY ddh.curve_id,ddh.location_id,ddh.term_start,ddh.deal_date,ddh.commodity_id,ddh.counterparty_id
			,ddh.fas_book_id,ddh.source_system_book_id1,ddh.source_system_book_id2,ddh.source_system_book_id3
			,ddh.source_system_book_id4,ddh.deal_volume_uom_id,ddh.physical_financial_flag,ddh.expiration_date
			,ddh.deal_status_id,ddh.period,ddh.granularity;

		SELECT  location_id,curve_id, term_start,deal_date,
				commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
				source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
				SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,SUM(ISNULL(HR4,0)) HR4,
				SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,
				SUM(ISNULL(HR9,0)) HR9,SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
				SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,SUM(ISNULL(HR16,0)) HR16,
				SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,
				SUM(ISNULL(HR21,0)) HR21,SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24
				,SUM(ISNULL(HR25,0)) HR25,
				expiration_date,deal_status_id,period,granularity
		into #vwHourly_position_AllFilter_profile
		FROM '+@_report_hourly_position_profile+ '
		GROUP BY location_id,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id
			,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
			,deal_volume_uom_id,physical_financial_flag,expiration_date,deal_status_id,period,granularity;
		'

		set @_select_st2 ='
		SELECT curve_id,ddh.location_id,term_start term_start,deal_date,
			SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,
			SUM(ISNULL(HR4,0)) HR4,SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,
			SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,SUM(ISNULL(HR9,0)) HR9,
			SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
			SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,
			SUM(ISNULL(HR16,0)) HR16,SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,
			SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,SUM(ISNULL(HR21,0)) HR21,
			SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24,
			SUM(ISNULL(HR25,0)) HR25,commodity_id,counterparty_id,
			fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,
			source_system_book_id4,deal_volume_uom_id,physical_financial_flag,expiration_date,
			deal_status_id,period,granularity
		into #vwHourly_position_AllFilter_financial
		FROM '+@_report_hourly_position_financial+' ddh
		GROUP BY curve_id,location_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3
			,source_system_book_id4,deal_volume_uom_id,physical_financial_flag,expiration_date,deal_status_id,period,granularity;
		'	
		+ case when object_id(@_report_hourly_position_breakdown) is null then '' else '
			SELECT	curve_id, term_start,term_end,deal_date,
				commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
				source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
				SUM(ISNULL(calc_volume,0)) calc_volume,expiration_date,deal_status_id, formula, source_deal_header_id, location_id
			into #vwHourly_position_AllFilter_breakdown
			FROM '+@_report_hourly_position_breakdown +'
			GROUP BY curve_id,term_start,term_end,deal_date,commodity_id,counterparty_id,fas_book_id
				,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
				,deal_volume_uom_id,physical_financial_flag,expiration_date,deal_status_id
				,formula,source_deal_header_id, location_id;
		' end

		set @_report_hourly_position_deal='#vwHourly_position_AllFilter'
		set @_report_hourly_position_profile='#vwHourly_position_AllFilter_profile'
		set @_report_hourly_position_financial= '#vwHourly_position_AllFilter_financial'
		set @_report_hourly_position_breakdown= '#vwHourly_position_AllFilter_breakdown'
	end

	set @_report_hourly_position_deal=@_report_hourly_position_deal+' s'
	set @_report_hourly_position_profile=@_report_hourly_position_profile+' s'
	set @_report_hourly_position_financial=@_report_hourly_position_financial+' s'
	set @_report_hourly_position_breakdown=@_report_hourly_position_breakdown+' s'
end



----print '-----------------------@_scrt'
SET @_scrt=''

SET @_scrt= CASE WHEN @_source_deal_header_id IS NOT NULL and @_group_by='d' THEN ' AND s.source_deal_header_id IN ('+ CAST(@_source_deal_header_id AS VARCHAR) + ')' ELSE '' END
	+CASE WHEN @_term_start IS NOT NULL THEN ' AND s.term_start>='''+@_term_start +''' AND s.term_start<='''+@_term_end +'''' ELSE '' END 
	+CASE WHEN @_commodity_id IS NOT NULL THEN ' AND s.commodity_id IN ('+@_commodity_id+')' ELSE '' END
	+CASE WHEN @_curve_id IS NOT NULL THEN ' AND s.curve_id IN ('+@_curve_id+')' ELSE '' END
	+CASE WHEN @_location_id IS NOT NULL THEN ' AND s.location_id IN ('+@_location_id+')' ELSE '' END
	+CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END  
	+CASE WHEN isnull(@_physical_financial_flag,'b') <>'b' THEN ' AND s.physical_financial_flag='''+@_physical_financial_flag+'''' ELSE '' END

exec dbo.spa_print @_scrt
----print '--------------------------------------------'

----------Start hourly_position_breakdown=null------------------------------------------------------------

if isnull(@_include_no_breakdown,'n')='y' or  (@_group_by='d' and @_summary_option='z')  -- detail
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
		isnull(spcd.block_define_id,'+@_baseload_block_define_id+') block_define_id,sdd.source_deal_detail_id,tz.dst_group_value_id
		into '+ @_position_no_breakdown+'
		from source_deal_header sdh with (nolock) '
			+case when isnull(@_include_no_breakdown,'n')='y' then 
				' inner join source_deal_header_template sdht on sdh.template_id=sdht.template_id and sdht.hourly_position_breakdown is null
			' else '' end +'
			inner join #temp_deals td on td.source_deal_header_id=sdh.source_deal_header_id
			inner join source_deal_detail sdd with (nolock) on sdh.source_deal_header_id=sdd.source_deal_header_id
			left JOIN  vwDealTimezone tz on tz.source_deal_header_id=sdd.source_deal_header_id
				AND ISNULL(tz.curve_id,-1)=ISNULL(sdd.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(sdd.location_id,-1)
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status 
			INNER JOIN #books bk ON bk.source_system_book_id1=sdh.source_system_book_id1 AND bk.source_system_book_id2=sdh.source_system_book_id2 
			AND bk.source_system_book_id3=sdh.source_system_book_id3 AND bk.source_system_book_id4=sdh.source_system_book_id4
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=sdd.curve_id 
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
		,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,hb.volume_mult,tz.dst_group_value_id
		from '+@_position_no_breakdown+' a
			left JOIN  vwDealTimezone tz on tz.source_deal_header_id=a.source_deal_header_id
				AND ISNULL(tz.curve_id,-1)=ISNULL(a.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(a.location_id,-1)
			outer apply	(
				select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
					and term_date between a.term_start  and a.term_end --and term_date>'''+convert(varchar(10),@_as_of_date,120) +'''
					and h.dst_group_value_id=tz.dst_group_value_id 
		) hb
	'
		
	exec spa_print @_rpn
	exec(@_rpn)

	create index indxterm_dat_no_break on #term_date_no_break(dst_group_value_id,block_define_id,term_start,term_end)
	
	SET @_dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
	
	SET @_vol_multiplier='*cast(cast(s.total_volume as numeric(26,12))/nullif(term_hrs.term_hrs,0) as numeric(28,16))'
		+case when @_summary_option in ('x','y')  then ' /hrs.factor '	else '' end
	
	SET @_rpn='Union all
	select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,'+case when @_summary_option in ('x','y')  then ' hrs.period ' else '0' end +' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
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
	',s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date ,''y'' AS is_fixedvolume ,deal_status_id 
	from '+@_position_no_breakdown + ' s inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
		left join #term_date_no_break hb on hb.term_start = s.term_start and hb.term_end=s.term_end  and hb.block_define_id=s.block_define_id 
			and hb.dst_group_value_id=s.dst_group_value_id'
	+case when @_summary_option in ('x','y')  then 
		' left join #minute_break hrs on hrs.granularity=982 '
	else '' end+'
		outer apply ( select sum(volume_mult) term_hrs from #term_date_no_break h where h.term_start = s.term_start and h.term_end=s.term_end  and h.term_date>''' + @_as_of_date +''') term_hrs
	    where 1=1' +@_scrt

end

---------end hourly_position_breakdown=null------------------------------------------------------------
	
if isnull(@_physical_financial_flag,'b')<>'p' 
BEGIN 

	SET @_dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  

	SET @_remain_month ='*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@_as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@_as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)'+case when @_summary_option in ('x','y')  then ' /hrs.factor '	else '' end    
		
	SET @_vol_multiplier='/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))'

	SET @_rhpb='select s.curve_id,'+ CASE WHEN @_view_name1='vwHourly_position_AllFilter' THEN '-1' ELSE 'ISNULL(s.location_id,-1)' END +' location_id,hb.term_date term_start,'+case when @_summary_option in ('x','y')  then ' hrs.period '	else '0' end +' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
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
		
	SET @_rhpb2=	case when  @_group_by='s' then '' else ',s.source_deal_header_id' end +		',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''y'' AS is_fixedvolume ,deal_status_id 
	from '+@_report_hourly_position_breakdown +' 
		inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
		INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN ' and s.source_deal_header_id IN (' +CAST(@_source_deal_header_id AS VARCHAR) + ')' ELSE '' END 
		+'	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 ' 
		+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
		' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id ' ELSE '' END 
		+' left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
		LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
		left JOIN  vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id
			AND ISNULL(tz.formula_curve_id,-1)=ISNULL(s.curve_id,-1) AND ISNULL(tz.location_id,-1)=ISNULL(s.location_id,-1)
		outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@_baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END  and hbt.dst_group_value_id=tz.dst_group_value_id 
		 ) term_hrs
		outer apply (
		 select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date --and  hbt.dst_group_value_id=tz.dst_group_value_id
		where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@_baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@_baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END and hbt.dst_group_value_id=tz.dst_group_value_id
			) term_hrs_exp
		left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,'+@_baseload_block_define_id+') and hb.term_start = s.term_start and hb.term_end=s.term_end  --and hb.term_date>''' + @_as_of_date +'''
		outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
		outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
		outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@_as_of_date+''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month 
					'
	+case when @_summary_option in ('x','y')  then 
		' left join #minute_break hrs on hrs.granularity=982 '
	else '' end+'
	 where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@_as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		    AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
	' +CASE WHEN @_tenor_option <> 'a' THEN ' and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@_as_of_date+'''' ELSE '' END +
			@_scrt
			
END


exec spa_print '================================================Source Position=========================================================='

SET @_sqry='select s.curve_id,s.location_id,s.term_start,'
	+case  @_summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) END else  COALESCE(hrs.period,s.period) end'
	when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
	else '0' end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
	+case  @_summary_option when 'y' then  
		@_delta_factor_column+'s.hr1/COALESCE(hrs.factor,1) hr1, '+@_delta_factor_column+'s.hr2/COALESCE(hrs.factor,1) hr2
		,'+@_delta_factor_column+'s.hr3/COALESCE(hrs.factor,1) hr3, '+@_delta_factor_column+'s.hr4/COALESCE(hrs.factor,1) hr4
		, '+@_delta_factor_column+'s.hr5/COALESCE(hrs.factor,1) hr5, '+@_delta_factor_column+'s.hr6/COALESCE(hrs.factor,1) hr6
		, '+@_delta_factor_column+'s.hr7/COALESCE(hrs.factor,1) hr7, '+@_delta_factor_column+'s.hr8/COALESCE(hrs.factor,1) hr8
		, '+@_delta_factor_column+'s.hr9/COALESCE(hrs.factor,1) hr9, '+@_delta_factor_column+'s.hr10/COALESCE(hrs.factor,1) hr10
		, '+@_delta_factor_column+'s.hr11/COALESCE(hrs.factor,1) hr11, '+@_delta_factor_column+'s.hr12/COALESCE(hrs.factor,1) hr12
		, '+@_delta_factor_column+'s.hr13/COALESCE(hrs.factor,1) hr13, '+@_delta_factor_column+'s.hr14/COALESCE(hrs.factor,1) hr14
		, '+@_delta_factor_column+'s.hr15/COALESCE(hrs.factor,1) hr15, '+@_delta_factor_column+'s.hr16/COALESCE(hrs.factor,1) hr16
		, '+@_delta_factor_column+'s.hr17/COALESCE(hrs.factor,1) hr17, '+@_delta_factor_column+'s.hr18/COALESCE(hrs.factor,1) hr18
		, '+@_delta_factor_column+'s.hr19/COALESCE(hrs.factor,1) hr19, '+@_delta_factor_column+'s.hr20/COALESCE(hrs.factor,1) hr20
		, '+@_delta_factor_column+'s.hr21/COALESCE(hrs.factor,1) hr21, '+@_delta_factor_column+'s.hr22/COALESCE(hrs.factor,1) hr22
		,'+@_delta_factor_column+'s.hr23/COALESCE(hrs.factor,1) hr23, '+@_delta_factor_column+'s.hr24/COALESCE(hrs.factor,1) hr24
		, '+@_delta_factor_column+'s.hr25/COALESCE(hrs.factor,1) hr25'				
	when 'x' then  
		@_delta_factor_column+'s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, '+@_delta_factor_column+'s.hr2 /COALESCE(hrs.factor,m30.factor,1) hr2
		,'+@_delta_factor_column+'s.hr3 /COALESCE(hrs.factor,m30.factor,1) hr3, '+@_delta_factor_column+'s.hr4 /COALESCE(hrs.factor,m30.factor,1) hr4
		, '+@_delta_factor_column+'s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, '+@_delta_factor_column+'s.hr6 /COALESCE(hrs.factor,m30.factor,1) hr6
		, '+@_delta_factor_column+'s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, '+@_delta_factor_column+'s.hr8 /COALESCE(hrs.factor,m30.factor,1) hr8
		, '+@_delta_factor_column+'s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, '+@_delta_factor_column+'s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
		, '+@_delta_factor_column+'s.hr11 /COALESCE(hrs.factor,m30.factor,1) hr11, '+@_delta_factor_column+'s.hr12 /COALESCE(hrs.factor,m30.factor,1) hr12
		, '+@_delta_factor_column+'s.hr13 /COALESCE(hrs.factor,m30.factor,1) hr13, '+@_delta_factor_column+'s.hr14 /COALESCE(hrs.factor,m30.factor,1) hr14
		, '+@_delta_factor_column+'s.hr15 /COALESCE(hrs.factor,m30.factor,1) hr15, '+@_delta_factor_column+'s.hr16 /COALESCE(hrs.factor,m30.factor,1) hr16
		, '+@_delta_factor_column+'s.hr17 /COALESCE(hrs.factor,m30.factor,1) hr17, '+@_delta_factor_column+'s.hr18 /COALESCE(hrs.factor,m30.factor,1) hr18
		, '+@_delta_factor_column+'s.hr19 /COALESCE(hrs.factor,m30.factor,1) hr19, '+@_delta_factor_column+'s.hr20 /COALESCE(hrs.factor,m30.factor,1) hr20
		, '+@_delta_factor_column+'s.hr21 /COALESCE(hrs.factor,m30.factor,1) hr21, '+@_delta_factor_column+'s.hr22 /COALESCE(hrs.factor,m30.factor,1) hr22
		, '+@_delta_factor_column+'s.hr23 /COALESCE(hrs.factor,m30.factor,1) hr23, '+@_delta_factor_column+'s.hr24 /COALESCE(hrs.factor,m30.factor,1) hr24
		, '+@_delta_factor_column+'s.hr25/COALESCE(hrs.factor,m30.factor,1) hr25'				
	else 
		@_delta_factor_column+'s.hr1 hr1,'+@_delta_factor_column+'s.hr2 hr2,'+@_delta_factor_column+'s.hr3 hr3,'+@_delta_factor_column+'s.hr4 hr4,'+@_delta_factor_column+'s.hr5 hr5,'+@_delta_factor_column+'s.hr6 hr6,'+@_delta_factor_column+'s.hr7 hr7,'+@_delta_factor_column+'s.hr8 hr8,'+@_delta_factor_column+'s.hr9 hr9,'+@_delta_factor_column+'s.hr10 hr10,'+@_delta_factor_column+'s.hr11 hr11,'+@_delta_factor_column+'s.hr12 hr12,'+@_delta_factor_column+'s.hr13 hr13,'+@_delta_factor_column+'s.hr14 hr14,'+@_delta_factor_column+'s.hr15 hr15,'+@_delta_factor_column+'s.hr16 hr16,'+@_delta_factor_column+'s.hr17 hr17,'+@_delta_factor_column+'s.hr18 hr18,'+@_delta_factor_column+'s.hr19 hr19,'+@_delta_factor_column+'s.hr20 hr20,'+@_delta_factor_column+'s.hr21 hr21,'+@_delta_factor_column+'s.hr22 hr22,'+@_delta_factor_column+'s.hr23 hr23,'+@_delta_factor_column+'s.hr24 hr24,'+@_delta_factor_column+'s.hr25 hr25'
	end
	+case when  @_group_by='s' then '' else ',s.source_deal_header_id' end +',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1
		,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id 
	INTO '+ @_position_deal +'  
	from '+@_report_hourly_position_deal+
	case when  @_group_by='s' then '' else ' 
		inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
	'
	end
	+ case when isnull(@_show_delta_position,'n')='y' and @_group_by='d' then '
		left join source_deal_pnl_detail_options sdpdo on sdpdo.source_deal_header_id=s.source_deal_header_id 
			and s.term_start between sdpdo.term_start and eomonth(sdpdo.term_start) and sdpdo.curve_1=s.curve_id and sdpdo.as_of_date='''+@_as_of_date+'''
		left join source_deal_pnl_detail_options sdpdo2 on sdpdo2.source_deal_header_id=s.source_deal_header_id 
			and s.term_start between sdpdo2.term_start and eomonth(sdpdo2.term_start) and sdpdo.curve_1=s.curve_id
			and isnull(sdpdo.term_start,sdpdo2.term_start)=sdpdo2.term_start and sdpdo2.as_of_date='''+@_as_of_date+'''
		' 
	else '' end+'
		INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
			AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
			AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+case  @_summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
		when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
				left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
		else ''
	end
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 

SET @_sqry1='
	union all
	select s.curve_id,s.location_id,s.term_start,'
		+case  @_summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end'
				when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
				else '0'
		end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
		+case  @_summary_option	when 'y' then  
				' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
				, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1)  hr25'				
			when 'x' then  
				' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
				s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
				, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25'				
			else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
		end+case when  @_group_by='s' then '' else ',s.source_deal_header_id' end 
+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id
from '+@_report_hourly_position_profile+
	case when  @_group_by='s' then '' else ' 
		inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
		'
	end
+' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
		AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
		AND bk.source_system_book_id4=s.source_system_book_id4 
	left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
	' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+case  @_summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
		when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
			left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
	else '' end
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 
				
SET @_sqry2='
	union all
	select s.curve_id,s.location_id,s.term_start,'
	+case  @_summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end'
		when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
		else '0' end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
		+case  @_summary_option	when 'y' then  
				' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
				,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
				,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
				, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
				, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
				, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
				, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
				, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
				, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
				, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
				, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
				, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
				, s.hr25/COALESCE(hrs.factor,1)  hr25'				
			when 'x' then  
				' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
				s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
				, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
				, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
				, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
				, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
				, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
				, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
				, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
				, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
				, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
				, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
				, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25'				
			else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
		end
		+case when  @_group_by='s' then '' else ',s.source_deal_header_id' end 
	+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id
	from '+@_report_hourly_position_financial
	+case when  @_group_by='s' then '' else ' 
		inner join #temp_deals td on td.source_deal_header_id=s.source_deal_header_id
	'
	end+'
		INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
			AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
			AND bk.source_system_book_id4=s.source_system_book_id4 
		left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id '	
	+ CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
		' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
	+case  @_summary_option	when 'y' then  
			' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
		when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
				left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
		else ''
	end
	+' WHERE  1=1 ' +CASE WHEN @_tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@_as_of_date+''' AND s.term_start>'''+@_as_of_date+'''' ELSE '' END
	+ @_scrt 			

IF isnull(@_physical_financial_flag,'b')<>'p'
	SET @_rhpb	='	union all 
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
		
exec('CREATE INDEX indx_tmp_subqry1'+@_temp_process_id+' ON '+@_position_deal +'(curve_id);
	CREATE INDEX indx_tmp_subqry2'+@_temp_process_id+' ON '+@_position_deal +'(location_id);
	CREATE INDEX indx_tmp_subqry3'+@_temp_process_id+' ON '+@_position_deal +'(counterparty_id)'
)

--end


if @_group_by='d' and @_summary_option='z'  -- detail
begin
	set @_rhpb=''
	set @_volume_clm=''
	set @_commodity_str=''
	set @_rhpb=''
	set @_commodity_str1=''

	set @_rhpb_0='
		select s.source_deal_detail_id,s.source_deal_header_id,s.curve_id source_curve_def_id,s.location_id,s.term_start,s.term_start term_date,s.term_end,0 period,max(s.deal_date) deal_date
			,max(s.deal_volume_uom_id) deal_volume_uom_id,max(s.physical_financial_flag) physical_financial_flag
			,max(s.commodity_id) commodity_id,max(s.counterparty_id) counterparty_id,max(s.fas_book_id) fas_book_id
			,max(s.source_system_book_id1) source_system_book_id1,max(s.source_system_book_id2) source_system_book_id2
			,max(s.source_system_book_id3) source_system_book_id3,max(s.source_system_book_id4) source_system_book_id4
			,max(s.expiration_date) expiration_date,''n'' AS is_fixedvolume ,max(deal_status_id) deal_status_id
			,sum(s.total_volume) Volume, null block_name
		into '+@_unpvt+ '
		from '+@_position_no_breakdown + ' s 
		group by s.source_deal_detail_id,s.source_deal_header_id, s.curve_id,s.location_id,s.term_start,s.term_end
	'
end
else
begin

	SET @_volume_clm=''''+ 	CASE @_summary_option
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


	SET @_Sql_Select='SELECT '+case when  @_group_by='s' then '' else 'isnull(sdd.source_deal_detail_id,sdd_fin.source_deal_detail_id) source_deal_detail_id,' end 
		+'vw.physical_financial_flag,su.source_uom_id,isnull(spcd1.source_curve_def_id,spcd.source_curve_def_id) source_curve_def_id,vw.location_id,vw.counterparty_id,vw.fas_book_id,'
		+CASE WHEN  @_summary_option IN ('d','h','x','y')  THEN 'vw.term_start' ELSE CASE WHEN @_summary_option='m' THEN 'convert(varchar(8),vw.term_start,120)+''01''' WHEN @_summary_option='a' THEN 'convert(varchar(5),vw.term_start,120)+''01-01''' 
		WHEN @_summary_option='q' THEN 'CONVERT(VARCHAR(5),vw.term_start, 120)+case DATEPART(q,vw.term_start) when 1 then ''01'' when 2 then ''04'' when 3 then ''07'' when 4 then ''10'' end +''-01'''  ELSE 'vw.term_start' END END+' [Term], '
		+CASE WHEN  @_summary_option IN ('x','y')  THEN 'vw.period' ELSE '0' END+' [Period], '
			+ @_volume_clm+' max(su.uom_name) [UOM],MAX(vw.commodity_id) commodity_id,MAX(vw.is_fixedvolume) is_fixedvolume,vw.source_system_book_id1,vw.source_system_book_id2,vw.source_system_book_id3,vw.source_system_book_id4
			,max(ISNULL(grp.block_type_id, spcd.source_curve_def_id))  block_type_id,max(ISNULL(grp.block_name, spcd.curve_name)) block_name
		, max(sdv_block_group.code) [user_defined_block] ,max(sdv_block_group.value_id) [user_defined_block_id],max(grp.block_type_group_id) block_type_group_id,grp.hourly_block_id
		INTO '+@_hour_pivot_table 
	+' FROM  '

	SET @_rhpb3=
		'  vw ' + CASE WHEN  @_deal_status IS NULL AND @_source_deal_header_id IS NULL THEN 
		' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = vw.deal_status_id'  ELSE '' END +'
		INNER JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=vw.curve_id 
	'+case when  @_group_by='s' then '' else '
		left join dbo.source_deal_detail sdd on sdd.source_deal_header_id=vw.source_deal_header_id 
			and CASE WHEN vw.physical_financial_flag=''f'' and vw.is_fixedvolume=''y'' then isnull(sdd.formula_curve_id,sdd.curve_id) else sdd.curve_id end=vw.curve_id 
			and vw.term_start between sdd.term_start and sdd.term_end and vw.is_fixedvolume=''n''
		outer apply
		( select top(1) * from dbo.source_deal_detail where vw.is_fixedvolume=''y'' 
			and source_deal_header_id=vw.source_deal_header_id and vw.curve_id =isnull(sdd.formula_curve_id,vw.curve_id) and vw.term_start between term_start and term_end
		) sdd_fin 
	' end +'
		LEFT JOIN  source_price_curve_def spcd1 (nolock) ON  spcd1.source_curve_def_id='+CASE WHEN @_proxy_curve_view = 'y' THEN  'spcd.proxy_curve_id' ELSE 'spcd.source_curve_def_id' END
	+'  LEFT JOIN source_minor_location sml (nolock) ON sml.source_minor_location_id=vw.location_id
		left join static_data_value sdv1 (nolock) on sdv1.value_id=sml.grid_value_id
		left join static_data_value sdv (nolock)  on sdv.value_id=sml.country
		left join static_data_value sdv2 (nolock) on sdv2.value_id=sml.region
		left join static_data_value sdv_prov (nolock) on sdv_prov.value_id=sml.province
		left join source_major_location mjr (nolock) on  sml.source_major_location_ID=mjr.source_major_location_ID
		left join source_counterparty scp (nolock) on vw.counterparty_id = scp.source_counterparty_id	
		LEFT JOIN source_uom su (nolock) on su.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
		CROSS JOIN #temp_block_type_group_table grp
		LEFT JOIN  hour_block_term hb1 WITH (NOLOCK)  ON hb1.dst_group_value_id='+@_default_dst_group+' 
			and hb1.block_define_id=COALESCE(grp.hourly_block_id,'+@_baseload_block_define_id+') AND hb1.term_date=vw.term_start
		LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK) ON sdv_block_group.value_id = grp.block_type_group_id
	WHERE 1=1 ' +
		CASE WHEN @_term_start IS NOT NULL THEN ' AND vw.term_start>='''+CAST(@_term_start AS VARCHAR)+''' AND vw.term_start<='''+CAST(@_term_END AS VARCHAR)+'''' ELSE '' END  
		+CASE WHEN @_parent_counterparty IS NOT NULL THEN ' AND  scp.parent_counterparty_id = ' + CAST(@_parent_counterparty AS VARCHAR) ELSE  '' END
		+CASE WHEN @_counterparty IS NOT NULL THEN ' AND vw.counterparty_id IN (' + @_counterparty + ')' ELSE '' END
		+CASE WHEN @_commodity_id IS NOT NULL THEN ' AND vw.commodity_id IN('+@_commodity_id+')' ELSE '' END
		+CASE WHEN @_curve_id IS NOT NULL THEN ' AND vw.curve_id IN('+@_curve_id+')' ELSE '' END
		+CASE WHEN @_location_id IS NOT NULL THEN ' AND vw.location_id IN('+@_location_id+')' ELSE '' END
		+CASE WHEN @_tenor_option <> 'a' THEN ' AND vw.expiration_date>'''+@_as_of_date+''' AND vw.term_start>'''+@_as_of_date+'''' ELSE '' END  
		+CASE WHEN isnull(@_physical_financial_flag,'b') <>'b' THEN ' AND vw.physical_financial_flag='''+@_physical_financial_flag+'''' ELSE '' END
		+CASE WHEN @_country IS NOT NULL THEN ' AND sdv.value_id='+ CAST(@_country AS VARCHAR) ELSE '' END
		+CASE WHEN @_region IS NOT NULL THEN ' AND sdv2.value_id='+ CAST(@_region AS VARCHAR) ELSE '' END
		+CASE WHEN @_location_group_id IS NOT NULL THEN ' AND mjr.source_major_location_id='+ @_location_group_id ELSE '' END
		+CASE WHEN @_grid IS NOT NULL THEN ' AND sdv1.value_id='+ @_grid ELSE '' END
		+CASE WHEN @_province IS NOT NULL THEN ' AND sdv_prov.value_id='+ @_province ELSE '' END
 		+CASE WHEN @_deal_status IS NOT NULL THEN ' AND deal_status_id IN('+@_deal_status+')' ELSE '' END
		+CASE WHEN @_buy_sell_flag is not null and @_group_by<>'s' THEN ' AND  isnull(sdd.buy_sell_flag,sdd_fin.buy_sell_flag)='''+@_buy_sell_flag+'''' ELSE '' END
	+' GROUP BY '+case when  @_group_by='s' then '' else '
			 isnull(sdd.source_deal_detail_id,sdd_fin.source_deal_detail_id ),'
		end +'isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),vw.location_id,'
	+CASE WHEN  @_org_summary_option IN ('d','h','x','y')  THEN 'vw.term_start' 
	ELSE 
		CASE WHEN @_summary_option='m' THEN 'convert(varchar(8),vw.term_start,120)+''01''' WHEN @_summary_option='a' THEN 'convert(varchar(5),vw.term_start,120)+''01-01''' 
			WHEN @_summary_option='q' THEN 'CONVERT(VARCHAR(5),vw.term_start, 120)+case DATEPART(q,vw.term_start) when 1 then ''01'' when 2 then ''04'' when 3 then ''07'' when 4 then ''10'' end +''-01'''  ELSE 'vw.term_start' END 
	END
	+CASE WHEN  @_org_summary_option IN ('x','y')  THEN ',vw.period' ELSE '' END 
	+ ',su.source_uom_id,vw.physical_financial_flag,vw.counterparty_id,vw.fas_book_id,vw.source_system_book_id1,vw.source_system_book_id2
	,vw.source_system_book_id3,vw.source_system_book_id4,grp.hourly_block_id' 

	exec spa_print '==============================================Aggregation=================================================='

	exec spa_print @_Sql_Select
	exec spa_print @_position_deal
	exec spa_print @_rhpb3
	
	exec(@_Sql_Select+@_position_deal+@_rhpb3)

	SET @_rhpb_0= ' 
		select *,'
		+CASE WHEN  @_summary_option IN ('h','x','y')  THEN 'CASE WHEN commodity_id=-1 AND is_fixedvolume =''n'' AND  ([hours]<7 OR [hours]=25) THEN dateadd(DAY,1,[term]) ELSE [term] END' else  '[term]' end +' [term_date]
		into '+@_unpvt +'
		from (
			SELECT '+case when  @_group_by='s' then '' else 's.source_deal_detail_id,'  end+'s.source_curve_def_id,s.commodity_id,s.[Term],s.Period,s.is_fixedvolume,s.physical_financial_flag,s.source_uom_id,[UOM],counterparty_id,location_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,
				CAST( s.hr1 AS NUMERIC(38,20)) [1],
				CAST( s.hr2 AS NUMERIC(38,20)) [2],
				CAST( s.hr3 AS NUMERIC(38,20)) [3],
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
				CAST( s.hr20 AS NUMERIC(38,20)) [20],
				CAST( s.hr21 AS NUMERIC(38,20)) [21],
				CAST( s.hr22 AS NUMERIC(38,20)) [22],
				CAST( s.hr23 AS NUMERIC(38,20)) [23],
				CAST( s.hr24 AS NUMERIC(38,20)) [24],
				CAST( 0 AS NUMERIC(38,20)) [25],null dst_hr,null add_dst_hour
				, block_type_id,   block_name, [user_defined_block] ,[user_defined_block_id],block_type_group_id,hourly_block_id
			FROM '+@_hour_pivot_table+' s
		) p
		UNPIVOT
		(Volume for Hours IN
			([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
		) AS unpvt
		WHERE NOT ([hours]=abs(isnull(add_dst_hour,0)) AND add_dst_hour<0) '
		+CASE WHEN @_block_type_group_id is not null  THEN ' and Volume is not null' else '' end
		+';
		CREATE NONCLUSTERED INDEX indx_unpvt111 ON '+@_unpvt +' ([source_curve_def_id]) INCLUDE ([Hours],[term_date]);
	'

end

exec spa_print '=======================================Unpivot=============================================='

exec spa_print @_rhpb_0 
exec( @_rhpb_0)
---------------END data preparation for report output------------------------------------------




--print '-----------------------------------------------------------------------------------------------'
--print '----- Logic for final output format of reports'
--print '--------------------------------------------------------------------------------------------------'

set @_select_st1 =''
set @_select_st2 =''
set @_select_st3 =''
set @_from_st1 =''
set @_from_st2 =''
set @_from_st3 =''


declare @term_st varchar(max),@term_group varchar(max)

set @term_group=case @_summary_option
	when 'a' then ' CONVERT(VARCHAR(4),vw.term_date, 120)+''-01-01'''
	when 'q' then 'CONVERT(VARCHAR(5),vw.term_date, 120)+case DATEPART(q,vw.term_date) when 1 then ''01'' when 2 then ''04'' when 3 then ''07'' when 4 then ''10'' end +''-01'''
	when 'm' then 'CONVERT(VARCHAR(8),vw.term_date, 120)+''01'''
else 'CONVERT(VARCHAR(10),vw.term_date, 120)' end



set @term_st='SELECT '+@term_group+' term_start_disp,convert(varchar(4),max(vw.term_date),120) term_year,'
+case @_summary_option
when 'a' then
' 
	null [term_quarter],
	null [term_start_month],
	null [term_start_month_name],
	null [term_day],
	null term_hour,
	null DST,
	null term_period,null term_year_month,
'
when 'q' then
' 
	''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter],
	null [term_start_month],
	null [term_start_month_name],
	null [term_day],
	null term_hour,
	null DST,
	null term_period,null term_year_month,
'

when 'm' then
' 
	''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter],
	RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) [term_start_month],
	DATENAME(m,max(vw.term_date)) [term_start_month_name],
	null [term_day],
	null term_hour,
	null DST,
	null term_period,convert(varchar(4),max(vw.term_date),120) + '' - '' + RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) term_year_month,
'
when 'd' then
' 
	''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter],
	RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) [term_start_month],
	DATENAME(m,max(vw.term_date)) [term_start_month_name],
	DATENAME(d,max(vw.term_date)) [term_day],
	null term_hour,
	null DST,
	null term_period,convert(varchar(4),max(vw.term_date),120) + '' - '' + RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) term_year_month,
'
else
' 
	''Q'' + CAST(DATEPART(q,max(vw.term_date)) AS VARCHAR) [term_quarter],
	RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) [term_start_month],
	DATENAME(m,max(vw.term_date)) [term_start_month_name],
	DATENAME(d,max(vw.term_date)) [term_day],
	CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END term_hour,
	CASE WHEN vw.[Hours] = 25 THEN 0 ELSE 	
		CASE WHEN CAST(convert(varchar(10),vw.[term_date],120)+'' ''+RIGHT(''00''+CAST(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END -1 AS VARCHAR),2)+'':00:000'' AS DATETIME) BETWEEN CAST(convert(varchar(10),mv2.[date],120)+'' ''+CAST(mv2.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME) 
			AND CAST(convert(varchar(10),mv3.[date],120)+'' ''+CAST(mv3.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME)
		THEN 1 ELSE 0 END 
	END AS DST,
	vw.Period term_period,convert(varchar(4),max(vw.term_date),120) + '' - '' + RIGHT(''0''+ CAST(MONTH(max(vw.term_date)) AS VARCHAR(2)), 2) term_year_month,
'
end
	

-- 1=term_start_disp, 7=term_hour, 8=DST
set @_group_st1 ='
GROUP BY '+ @term_group+ ',vw.fas_book_id,vw.source_system_book_id1,vw.source_system_book_id2,vw.source_system_book_id3,vw.source_system_book_id4,
	vw.location_id,vw.source_curve_def_id,vw.block_name,vw.Period'+case when @_group_by='d' then ',sdh.source_deal_header_id' else '' end
+case when @_summary_option IN ('h') then 
	',CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END,
	CASE WHEN vw.[Hours] = 25 THEN 0 ELSE 	
		CASE WHEN CAST(convert(varchar(10),vw.[term_date],120)+'' ''+RIGHT(''00''+CAST(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END -1 AS VARCHAR),2)+'':00:000'' AS DATETIME) BETWEEN CAST(convert(varchar(10),mv2.[date],120)+'' ''+CAST(mv2.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME) 
			AND CAST(convert(varchar(10),mv3.[date],120)+'' ''+CAST(mv3.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME)
		THEN 1 ELSE 0 END 
	END' else '' end


 
set @_select_st1=@term_st+ ' 
	max(sub.entity_name) sub,max(stra.entity_name) strategy,
	max(book.entity_name) book,max(ssbm.logical_name) sub_book,
	CASE WHEN max(vw.physical_financial_flag) = ''p'' THEN ''Physical'' ELSE ''Financial'' END physical_financial_flag,
	vw.source_curve_def_id,
	vw.location_id source_minor_location_id,
	CASE WHEN MAX(vw.physical_financial_flag) = ''f'' THEN MAX(sdv_ig.code) ELSE MAX(ISNULL(sml_proxy.location_name, sml.Location_Name)) END location,
	max(mjr.location_name) location_group
	,max(sml.country) location_group1
	,CASE WHEN max(vw.physical_financial_flag) = ''p'' THEN max(sdv2.code) ELSE MAX(sdv_region.code) END location_group2
	,max(sml.province) location_group3
	,max(sdv1.code) location_group4,
	max(spcd.curve_name) [index],
	max(vw.block_name) block_name,
	max(sdv_sbg1.code) sub_book_group1,
	max(sdv_sbg2.code) sub_book_group2,
	max(sdv_sbg3.code) sub_book_group3,
	max(sdv_sbg4.code) sub_book_group4,
	sum('+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ' cast(isnull(uc.conversion_factor,1) as numeric(21,16))*vw.volume' else 'vw.volume' end +') Position ,
	max(su_pos_uom.uom_name) postion_uom,max(nh.no_hrs) no_hrs
	,sum('+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ' cast(isnull(uc.conversion_factor,1) as numeric(21,16))*vw.volume' else 'vw.volume' end +')/nullif(max(nh.no_hrs),0) Position_mwh 
	,max(su1.uom_name) converted_uom
	,CASE WHEN max(vw.physical_financial_flag) = ''p'' THEN max(sml.region) ELSE MAX(sml_fin_location.region) END [region]   
'

 
if @_group_by='d' ----- DETAIL
begin
 	set @_select_st1= @_select_st1+'
		,max(com.commodity_name) commodity,
		max(sdv5.code) pricing_type,
		max(sdv6.code) product_group,
		max(sdt.source_deal_type_name) [Deal Type],
		max(tdr.trader_name) [Trader],
		max(sc.counterparty_name) counterparty_name,
		max(sc.counterparty_name) parent_counterparty,
		max(cg.contract_name) [Contract],
		max(ag_t.agg_term) agg_term,
		'+case when  @_include_actuals_from_shape = 'y' then 'ISNULL(sum(sddh.deal_volume), max(sdd.deal_volume))' else 'max(sdd.deal_volume)' end+' [Deal Volume] ,
		max(su.uom_name) [Volume UOM],sdh.source_deal_header_id deal_id,max(sdh.deal_id) ref_id
		,max(sdd.buy_sell_flag)  buy_sell_flag
	'
	set @_group_st1 =@_group_st1 --+',sdh.source_deal_header_id'
 
end
else if @_org_summary_option IN ('t')
begin
	
 
	set @_select_st1=
	'
	SELECT Sum(vw.volume) AS [Position] ,convert(varchar(7),vw.term_date,120) [Term Year Month]
	,CASE WHEN sml.Location_Name IS NOT NULL THEN spcd.curve_name + ''/'' + sml.Location_Name ELSE spcd.curve_name END AS [Location/Index], vw.block_name [Block Name], su_pos_uom.uom_name [Position UOM], ssbm.logical_name [Book],sum(nh.no_hrs) no_hrs
	,sum('+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ' cast(isnull(uc.conversion_factor,1) as numeric(21,16))*vw.volume' else 'vw.volume' end +')/nullif(sum(nh.no_hrs),0) Position_mwh 
	'
	set @_group_st1 =
	'
	GROUP BY  
		convert(varchar(7),vw.term_date,120) ,vw.block_name
		, spcd.curve_name ,sml.Location_Name 
		, vw.block_name
		, su_pos_uom.uom_name
		, ssbm.logical_name
	'

end


 
-------------------------------------------------------------------------------------------------------------------------------------------------
------------------- START building FROM clause-----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

set @_from_st1=@_process_output_table +
'
FROM '+ @_unpvt+' vw 
	LEFT JOIN source_commodity com  WITH (NOLOCK) ON com.source_commodity_id=vw.commodity_id 
	LEFT JOIN source_minor_location sml WITH (NOLOCK) ON sml.source_minor_location_id = vw.location_id
	INNER JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id = vw.source_curve_def_id  
	LEFT JOIN #no_hrs nh on nh.block_define_id=COALESCE(vw.hourly_block_id,'+@_baseload_block_define_id+') and nh.term_date=vw.term_date
	LEFT JOIN static_data_value sdv1 WITH (NOLOCK) ON sdv1.value_id=sml.grid_value_id
	LEFT JOIN static_data_value sdv WITH (NOLOCK) ON sdv.value_id=sml.country
	LEFT JOIN static_data_value sdv_ig WITH (NOLOCK) ON sdv_ig.value_id=spcd.index_group
	LEFT JOIN source_minor_location sml_proxy WITH (NOLOCK) ON sml_proxy.source_minor_location_id = sml.proxy_location_id
	LEFT JOIN static_data_value sdv2 WITH (NOLOCK) ON sdv2.value_id=sml.region
	LEFT JOIN static_data_value sdv_prov WITH (NOLOCK) ON sdv_prov.value_id=sml.Province
	LEFT JOIN source_major_location mjr WITH (NOLOCK) ON sml.source_major_location_ID=mjr.source_major_location_ID
	'
+case when @_org_summary_option IN ('t') then '
	LEFT JOIN source_uom AS su_pos_uom WITH (NOLOCK) ON su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)
	LEFT JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = vw.source_deal_detail_id
	LEFT JOIN source_deal_header sdh WITH (NOLOCK) ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_system_book_map ssbm WITH (NOLOCK) ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
'
else '
	LEFT JOIN portfolio_hierarchy book WITH (NOLOCK) ON book.entity_id = vw.fas_book_id 
	LEFT JOIN portfolio_hierarchy stra WITH (NOLOCK) ON stra.entity_id = book.parent_entity_id 
	LEFT JOIN portfolio_hierarchy sub WITH (NOLOCK) ON sub.entity_id = stra.parent_entity_id
	LEFT JOIN source_system_book_map ssbm WITH (NOLOCK) ON ssbm.source_system_book_id1 = vw.source_system_book_id1
		AND ssbm.source_system_book_id2 = vw.source_system_book_id2
		AND ssbm.source_system_book_id3 = vw.source_system_book_id3
		AND ssbm.source_system_book_id4 = vw.source_system_book_id4
	LEFT JOIN source_book sb1 WITH (NOLOCK) ON sb1.source_book_id = vw.source_system_book_id1
	LEFT JOIN source_book sb2 WITH (NOLOCK) ON sb2.source_book_id = vw.source_system_book_id2
	LEFT JOIN source_book sb3 WITH (NOLOCK) ON sb3.source_book_id = vw.source_system_book_id3
	LEFT JOIN source_book sb4 WITH (NOLOCK) ON sb4.source_book_id = vw.source_system_book_id4
	LEFT JOIN static_data_value sdv_sbg1 ON sdv_sbg1.value_id = ssbm.sub_book_group1
	LEFT JOIN static_data_value sdv_sbg2 ON sdv_sbg2.value_id = ssbm.sub_book_group2
	LEFT JOIN static_data_value sdv_sbg3 ON sdv_sbg3.value_id = ssbm.sub_book_group3
	LEFT JOIN static_data_value sdv_sbg4 ON sdv_sbg4.value_id = ssbm.sub_book_group4
	--LEFT join static_data_value trans_type ON trans_type.value_id = ssbm.fas_deal_type_value_id
	LEFT JOIN  source_price_curve_def spcd_proxy WITH (NOLOCK) ON spcd_proxy.source_curve_def_id=spcd.proxy_curve_id
	LEFT JOIN  source_price_curve_def spcd_proxy_curve3 WITH (NOLOCK) ON spcd_proxy_curve3.source_curve_def_id=spcd.proxy_curve_id3
	LEFT JOIN  source_price_curve_def spcd_monthly_index WITH (NOLOCK) ON spcd_monthly_index.source_curve_def_id=spcd.monthly_index
	LEFT JOIN  source_price_curve_def spcd_proxy_curve_def WITH (NOLOCK) ON spcd_proxy_curve_def.source_curve_def_id=spcd.proxy_source_curve_def_id
	LEFT JOIN source_system_description sssd WITH (NOLOCK) ON sssd.source_system_id = spcd_monthly_index.source_system_id
	LEFT JOIN source_system_description sssd2 WITH (NOLOCK) ON sssd.source_system_id = spcd_proxy_curve3.source_system_id
	LEFT JOIN source_uom AS su_pos_uom WITH (NOLOCK) ON su_pos_uom.source_uom_id = '+CASE WHEN @_convert_to_uom_id IS NOT NULL THEN @_convert_to_uom_id ELSE 'ISNULL(spcd.display_uom_id,spcd.uom_id)' END+'
	LEFT JOIN source_uom su_uom  WITH (NOLOCK)ON su_uom.source_uom_id= spcd.uom_id
	LEFT JOIN source_uom su_uom_proxy3 WITH (NOLOCK) ON su_uom_proxy3.source_uom_id= ISNULL(spcd_proxy_curve3.display_uom_id,spcd_proxy_curve3.uom_id)--spcd_proxy_curve3.display_uom_id
	LEFT JOIN source_uom su_uom_proxy2 WITH (NOLOCK) ON su_uom_proxy2.source_uom_id= ISNULL(spcd_monthly_index.display_uom_id,spcd_monthly_index.uom_id)
	LEFT JOIN source_uom su_uom_proxy_curve_def WITH (NOLOCK) ON su_uom_proxy_curve_def.source_uom_id= ISNULL(spcd_proxy_curve_def.display_uom_id,spcd_proxy_curve_def.uom_id)--spcd_proxy_curve_def.display_uom_id
	LEFT JOIN source_uom su_uom_proxy_curve WITH (NOLOCK) ON su_uom_proxy_curve.source_uom_id= ISNULL(spcd_proxy.display_uom_id,spcd_proxy.uom_id)
	LEFT JOIN source_counterparty sc WITH (NOLOCK) ON sc.source_counterparty_id = vw.counterparty_id 
	LEFT JOIN source_counterparty psc  WITH (NOLOCK) ON psc.source_counterparty_id=sc.parent_counterparty_id
'
end


set @_from_st2=
case when  @_group_by='d' then '	
		LEFT JOIN source_deal_detail sdd WITH (NOLOCK) ON sdd.source_deal_detail_id = vw.source_deal_detail_id
		LEFT JOIN source_deal_header sdh WITH (NOLOCK) ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN static_data_value sdv_deal_staus WITH (NOLOCK) ON sdv_deal_staus.value_id = sdh.deal_status
		LEFT JOIN static_data_value sdv_profile WITH (NOLOCK) ON sdv_profile.value_id = sdh.internal_desk_id
		LEFT JOIN static_data_value sdv_confirm WITH (NOLOCK) ON sdv_confirm.value_id = sdh.confirm_status_type
		LEFT JOIN contract_group cg  WITH (NOLOCK) ON cg.contract_id = sdh.contract_id
		left join source_traders tdr on tdr.source_trader_id=sdh.trader_id 
		LEFT JOIN source_uom su  WITH (NOLOCK)ON su.source_uom_id= sdd.deal_volume_uom_id
		LEFT JOIN static_data_value sdv_block WITH (NOLOCK) ON sdv_block.value_id  = sdh.block_define_id
		LEFT JOIN static_data_value sdv_entity WITH (NOLOCK) ON sdv_entity.value_id  = sc.type_of_entity
		LEFT JOIN source_counterparty bkr WITH (NOLOCK) ON bkr.source_counterparty_id = sdh.broker_id 
		left join source_deal_type sdt on sdt.source_deal_type_id=sdh.source_deal_type_id
		left join source_deal_type sdst on sdst.source_deal_type_id=sdh.deal_sub_type_type_id
		LEFT JOIN internal_deal_type_subtype_types idtst ON idtst.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
		LEFT JOIN internal_deal_type_subtype_types idtst1 ON idtst1.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
		LEFT JOIN source_deal_header sdh1 on sdh1.source_deal_header_id = sdh.structured_deal_id
		LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		LEFT JOIN source_counterparty sc2 ON sc2.source_counterparty_id = sdh.counterparty_id2
		LEFT JOIN static_data_value sdv5 ON sdv5.value_id = sdh.pricing_type
		LEFT JOIN static_data_value sdv6 ON sdv6.value_id = sdh.internal_portfolio_id
		LEFT JOIN source_minor_location sml_fin_location ON sml_fin_location.source_minor_location_id = spcd.location_id
		LEFT JOIN static_data_value sdv_region WITH (NOLOCK) ON sdv_region.value_id = sml_fin_location.region
	'
end

if  @_org_summary_option not IN ('t')
begin
	set @_from_st3=
	case when  @_group_by='d' then 
	'
		OUTER APPLY
		(
			SELECT CASE WHEN sdd.term_start<'''++@_as_of_date++''' THEN '' '' + CAST(YEAR(sdd.term_start) AS VARCHAR) + ''-YTD''
				WHEN MONTH(sdd.term_start)=MONTH('''+@_as_of_date+''') AND YEAR(sdd.term_start)=YEAR('''+@_as_of_date+''') THEN 
					CAST(YEAR(sdd.term_start) AS VARCHAR) + '' - Current Month''
				WHEN DATEDIFF(m,'''+@_as_of_date+''',sdd.term_start) <=3  THEN 
					convert(varchar(4),sdd.term_start,120) +''-''+ ''M'' + CAST(DATEDIFF(m,'''+@_as_of_date+''',sdd.term_start) AS VARCHAR) +'' ''+ ''('' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(sdd.term_start),-1)),3)) + '')''
				WHEN YEAR('''+@_as_of_date+''') =  YEAR(sdd.term_start) THEN 
					convert(varchar(4),sdd.term_start,120) + ''-''+ ''Q'' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR)
				ELSE  
					CAST(YEAR(sdd.term_start) AS VARCHAR) 
				END agg_term --FROM portfolio_mapping_tenor
		) ag_t
		' 
	else '' end
	+	
	CASE WHEN @_include_actuals_from_shape = 'y' THEN '
		OUTER APPLY (
			SELECT sddh.term_date, sddh.actual_volume, sddh.schedule_volume, sddh.volume deal_volume
			FROM source_deal_detail_hour sddh WHERE sddh.source_deal_detail_id = sdd.source_deal_detail_id
		) sddh
		'
	ELSE '
		OUTER APPLY (
			SELECT NULL term_date, NULL actual_volume, NULL schedule_volume, NULL deal_volume
		) sddh
	'
	END
	+
	'
		OUTER APPLY (
			SELECT sdd01.term_end
			FROM source_deal_detail sdd01 WHERE sdd01.source_deal_detail_id = vw.source_deal_detail_id
			--.source_deal_header_id = sdh.source_deal_header_id AND sdd01.term_start = vw.term_date
			 
		) sdd02
	'
	+ CASE WHEN @_convert_to_uom_id IS NOT NULL THEN ' LEFT JOIN #unit_conversion uc ON uc.convert_from_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id) AND uc.convert_to_uom_id='+CAST(@_convert_to_uom_id AS VARCHAR) 
	+' LEFT JOIN source_uom su1 on su1.source_uom_id='+CAST(@_convert_to_uom_id AS VARCHAR)  
	ELSE  
		' LEFT JOIN source_uom su1 (nolock) on su1.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)'
	END
	+case when  @_org_summary_option IN ('h','x','y') then '
		LEFT JOIN mv90_DST mv (nolock) ON vw.[term_date]=mv.[date]
			AND mv.insert_delete=''i'' AND vw.[Hours]=25 and mv.dst_group_value_id='+@_default_dst_group+'
		LEFT JOIN mv90_DST mv1 (nolock) ON vw.[term_date]=mv1.[date]
			AND mv1.insert_delete=''d'' AND mv1.Hour=vw.[Hours] and mv1.dst_group_value_id='+@_default_dst_group+'
		LEFT JOIN mv90_DST mv2 (nolock) ON YEAR(vw.[term_date])=(mv2.[YEAR])
			AND mv2.insert_delete=''d'' and mv2.dst_group_value_id='+@_default_dst_group+'
		LEFT JOIN mv90_DST mv3 (nolock) ON YEAR(vw.[term_date])=(mv3.[YEAR])
			AND mv3.insert_delete=''i'' and mv3.dst_group_value_id='+@_default_dst_group+'
	WHERE  (((vw.[Hours]=25 AND mv.[date] IS NOT NULL) OR (vw.[Hours]<>25)) AND (mv1.[date] IS NULL))'
	+ CASE WHEN @_hour_from IS NOT NULL THEN ' and cast(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE vw.[Hours] END as int) between '+CAST(@_hour_from AS VARCHAR) +' and ' +CAST(@_hour_to AS VARCHAR) ELSE '' END 
	else '' end
	+CASE WHEN isnull(@_physical_financial_flag,'b')<>'b'  THEN ' and vw.physical_financial_flag = ''' + @_physical_financial_flag + '''' ELSE '' END
	+CASE WHEN @_leg IS NOT NULL and @_group_by<>'s' THEN ' AND sdd.leg ='+@_leg ELSE '' END 
end

------------------- END building FROM clause-----------------------------------------------------------------------------------------------------



declare @_no_hrs varchar(max)

set @_no_hrs='
SELECT  hourly_block_id block_define_id,[term] term_date into #tmp111 FROM '+ @_unpvt +' s group by hourly_block_id,[term]
select COALESCE(vw.block_define_id,'+@_baseload_block_define_id+') block_define_id,vw.term_date,sum(hbt.volume_mult) no_hrs
into #no_hrs
from #tmp111 vw 
	inner join hour_block_term hbt on dst_group_value_id='+@_default_dst_group+' and hbt.block_define_id = COALESCE(vw.block_define_id,'+@_baseload_block_define_id+')
		and  hbt.term_date between vw.term_date and dbo.FNAGetTermEndDate('''+@_summary_option +''',vw.term_date,0)
	group by COALESCE(vw.block_define_id,'+@_baseload_block_define_id+'), vw.term_date

 
'

exec spa_print '================================================Final===================================================================='
exec spa_print @_no_hrs
exec spa_print @_select_st1 
exec spa_print @_select_st2 
--exec spa_print @_select_st3
exec spa_print @_fltr_param
exec spa_print @_from_st1
exec spa_print @_from_st2
exec spa_print @_from_st3
exec spa_print @_group_st1
--+@_select_st3


exec(@_no_hrs+@_select_st1 +@_select_st2 +@_fltr_param+@_from_st1+@_from_st2+@_from_st3+@_group_st1)





