
IF OBJECT_ID(N'sp_ssis_position_formate1', N'P') IS NOT NULL
drop  proc dbo.sp_ssis_position_formate1
go



--sp_ssis_position_formate1 'ds5ssassssdfssggggssas34dfs','endur','20080331','y'
create  proc [dbo].[sp_ssis_position_formate1]
@process_id varchar(150),
@source_system varchar(200)=NULL,
@pnl_as_of_date varchar(20)=NULL,
@adhoc_call char(1)=null

As 
declare @temptbl varchar(1000)
declare @user_login_id varchar(100)
declare @call_imp_engine varchar(1000)
declare @tblname varchar(1000)
declare @sql varchar(5000)
--drop table #temp1
create table #temp1(
table_name varchar(200) COLLATE DATABASE_DEFAULT)

insert #temp1
exec spa_import_temp_table '4022' --new 5 columns added format
declare @tName varchar(500),@staging_table_name varchar(100)
select @tName=table_name from #temp1

if @adhoc_call is null
	set @staging_table_name='ssis_position_formate1'	
else
	set @staging_table_name='ssis_position_formate1_error_log'	

declare @source_system_id varchar(10)
select @source_system_id=source_system_id from source_system_description where source_system_Name=@source_system
if @source_system_id is null
set @source_system_id=''


--insert from table format1 to temporary table
set @sql='insert '+@tName+'(deal_id,source_system_id,term_start,term_end,leg,contract_expiration_date,fixed_float_leg,
buy_sell_flag,curve_id,
fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,
deal_detail_description,formula_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
source_deal_type_id,source_deal_sub_type_id,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,
source_system_book_id3,source_system_book_id4,description1,description2,description3,deal_category_value_id,trader_id,
header_buy_sell_flag,broker_id,contract_id,legal_entity,
internal_portfolio_id,reference,commodity_id,internal_desk_id,table_code)
select deal_num,'+ 
	case when @adhoc_call is not null then ' t.source_system_id  ' 
		else '' + @source_system_id   + ''  end +' 
source_system_id,
cast(''01-''+time_bucket as datetime),
cast(dbo.FNALastDayInMonth(''01-''+ time_bucket) as varchar) +''-''+ time_bucket,1 leg,
cast(dbo.FNALastDayInMonth(''01-''+ time_bucket) as varchar) +''-''+ time_bucket,
''f'' fixed_float_leg,''b'' buy_sell_flag ,position_A,null fixed_price,currency_B,
null option_strike_price,1 deal_volume,''m'' deal_volume_frequency,''FX'' deal_volume_uom_id,
NULL block_description,null,NULL formula_id,trade_date,null ext_deal_id,''f'' physical_financial_flag ,
null structured_deal_id,counterparty,type,null source_deal_sub_type_id,''n'' option_flag,
null option_type,null option_exercise_type,
isNull(nullif(position_B,''''),''-1'') source_system_book_id1,
isNull(nullif(internal_portfolio,''''),''-2'') source_system_book_id2,
''Fx'' source_system_book_id3,
isNull(nullif(trade_time,''''),''-4'') source_system_book_id4,null  description1,
null  description2,null  description3,476,trader,''b'' header_buy_sell_flag,null broker_id,null contract_id,legal_entity ,
internal_portfolio,
reference,commodity,desk,
4005 table_code
from '+ @staging_table_name +' t 
where cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate(''01-''+time_bucket) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime) > 
cast(dbo.FNALastDayInDate('''+ @pnl_as_of_date +''') as datetime) 
'
EXEC spa_print @sql
exec(@sql)

if @adhoc_call is null
begin
-- Insert Trader if not found
	insert source_traders(source_system_id,trader_id,trader_name,trader_desc)
	select distinct @source_system_id, trader,trader,trader from ssis_position_formate1 t left outer join source_traders st
	on st.trader_id=t.trader and st.source_system_id=@source_system_id
	where st.trader_id is null

	insert source_internal_desk(source_system_id,internal_desk_id,internal_desk_name,internal_desk_desc)
	select distinct @source_system_id, desk,desk,desk from ssis_position_formate1 t 
	left outer join source_internal_desk st
	on st.internal_desk_id=t.desk and st.source_system_id=@source_system_id
	where st.internal_desk_id is null

	insert source_internal_portfolio(source_system_id,internal_portfolio_id,internal_portfolio_name,internal_portfolio_desc)
	select distinct @source_system_id, internal_portfolio,internal_portfolio,internal_portfolio from ssis_position_formate1 t left outer join 
	source_internal_portfolio st
	on st.internal_portfolio_id=t.internal_portfolio and st.source_system_id=@source_system_id
	where st.internal_portfolio_id is null

	insert source_commodity(source_system_id,commodity_id,commodity_name,commodity_desc)
	select distinct @source_system_id, commodity,commodity,commodity from ssis_position_formate1 t 
	left outer join source_commodity st
	on st.commodity_id=t.commodity and st.source_system_id=@source_system_id
	where st.commodity_id is null
	EXEC spa_print 'insert source_commodity '--+ convert(varchar,getdate(),109)


end

declare @is_schedule varchar(1)
if @adhoc_call is NULL
	set @is_schedule='y'
else
	set @is_schedule='n'

set @user_login_id=dbo.FNADBUser()
set @call_imp_engine='exec spa_import_data_job '''+@tName +''',4005,
''Interface_Position_Fx'','''+@process_id+''','''+ @user_login_id+''','''+ @is_schedule +''',1,''formate1'','''+ @pnl_as_of_date +''''
exec(@call_imp_engine)
--print @call_imp_engine
--delete ssis_position_formate1
--return
declare @error_count int

select @error_count=count(*) from source_system_data_import_status 
where process_id=@process_id and code='Error'

If @error_count = 0
		Exec spa_ErrorHandler 0, 'Interface_Position_Fx', 
		'Interface_Position_Fx', 'Success', 
		'Import Successful.', ''
	else
		Exec spa_ErrorHandler -1, 'Interface_Position_Fx', 
		'Interface_Position_Fx', 'Error', 
		'Import Failed.', ''







