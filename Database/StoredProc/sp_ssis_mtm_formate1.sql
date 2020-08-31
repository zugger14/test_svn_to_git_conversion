
IF OBJECT_ID(N'sp_ssis_mtm_formate1', N'P') IS NOT NULL
drop  proc dbo.sp_ssis_mtm_formate1
go


-- use fastracker

-- 5-06-2008
--select commodity from SSIS_Position_Formate1
--sp_ssis_mtm_formate1 '123','Endur','20080331','y'
--sp_ssis_mtm_formate1 '1222asyysDsssSssssssdf66dd',NULL,NULL,'y'
create proc [dbo].[sp_ssis_mtm_formate1]
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

if @source_system='user' or @source_system='cdo' or @source_system='endur' 
	set @source_system='Endur'
else
	set @source_system='SoftMAR'


create table #temp1(
table_name varchar(200) COLLATE DATABASE_DEFAULT)
--drop table #temp1
insert #temp1
exec spa_import_temp_table '4006'
declare @tName varchar(500),@staging_table_name varchar(150)
select @tName=table_name from #temp1

if @adhoc_call is null
	set @staging_table_name='ssis_mtm_formate1'	
else
	set @staging_table_name='ssis_mtm_formate1_error_log'	


declare @source_system_id int
select @source_system_id=source_system_id 
from source_system_description where source_system_Name=@source_system


		delete ssis_position_formate1
		EXEC spa_print 'Insert into ssis_position_formate1 '--+convert(varchar,getdate(),109)	
	if @adhoc_call is null	
		insert ssis_position_formate1(date,deal_num,currency_A,currency_B,trade_date,
		counterparty,internal_portfolio,trader ,legal_entity,time_bucket,type,
		position_A,trade_time,position_B,Desk,
		reference,commodity)
		select date,deal_num,currency_A,currency_B,trade_date,
		counterparty,internal_portfolio,trader ,replace(legal_entity,'"',''),
		right(convert(varchar,date,105),8),type,price_region,ias39_scope,
		ias39_book,Desk,reference,commodity
		from ssis_mtm_formate1  where date <> '' 
		group by date,deal_num,currency_A,currency_B,trade_date,
		counterparty,internal_portfolio,trader ,replace(legal_entity,'"',''),
		right(convert(varchar,date,105),8),type,price_region,ias39_scope,ias39_book,
		Desk,reference,commodity

	else
	begin
		delete ssis_mtm_formate1
		insert ssis_position_formate1(date,deal_num,currency_A,currency_B,trade_date,
		counterparty,internal_portfolio,trader ,legal_entity,time_bucket,type,position_A,
		trade_time,position_B,Desk,reference,commodity)
		select date,deal_num,currency_A,currency_B,trade_date,
		counterparty,internal_portfolio,trader ,replace(legal_entity,'"',''),
		right(convert(varchar,date,105),8),type,price_region,ias39_scope,
		ias39_book,Desk,reference,commodity
		from ssis_mtm_formate1_error_log  where date <> '' 
		group by date,deal_num,currency_A,currency_B,trade_date,
		counterparty,internal_portfolio,trader ,replace(legal_entity,'"',''),
		right(convert(varchar,date,105),8),type,
		price_region,ias39_scope,ias39_book,Desk,reference,commodity

		select @pnl_as_of_date=max(as_of_date) from ssis_mtm_formate1_error_log
	end

		EXEC spa_print 'Calling position formate1  SPS: '--+convert(varchar,getdate(),109)	
		exec sp_ssis_position_formate1 @process_id,@source_system,@pnl_as_of_date 
		EXEC spa_print 'position formate1 Completed: '--+convert(varchar,getdate(),109)	


--select * from  ssis_deal_import_format2
set @sql='insert '+@tName+'(source_deal_header_id,source_system_id,term_start,term_end,leg,
pnl_as_of_date,und_pnl,und_intrinsic_pnl,
und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,
dis_extrinisic_pnl,pnl_source_value_id,pnl_currency_id,
pnl_conversion_factor,pnl_adjustment_value,deal_volume,table_code)
select deal_num,' + 
	case when @adhoc_call is not null then ' max(pnl.source_system_id)  ' 
		else '' + cast(@source_system_id as varchar)   + ''  end +',
cast(DBO.FNAGetContractMonth(date)as datetime),
cast(dbo.FNALastDayInDate(date) as datetime),1 leg,' + 
	case when @adhoc_call is not null then ' max(pnl.as_of_date)  ' 
		else 'cast(''' + @pnl_as_of_date   + ''' as datetime) '  end +'
,sum(cast(mtm_disc as float)),sum(cast(mtm_disc as float))
,0,sum(cast(contract_value as float)),0,
0,775 pnl_source_value_id,''EUR'',
1,0,isNull(max(sd.deal_volume),0),4006 from '+@staging_table_name+' 
pnl left outer join (
	select deal_id,term_start,term_end,deal_volume from source_deal_header sdh join source_deal_detail sdd
	on sdh.source_deal_header_id=sdd.source_deal_header_id
	where sdd.leg=1
	) sd on
pnl.deal_num=sd.deal_id and cast(DBO.FNAGetContractMonth(date) as datetime)=sd.term_start and
cast(dbo.FNALastDayInDate(date) as datetime)=sd.term_end
where cast(dbo.FNALastDayInDate(date) as datetime) > 
cast(dbo.FNALastDayInDate(' + 
	case when @adhoc_call is not null then ' pnl.as_of_date  ' 
		else 'cast(''' + @pnl_as_of_date   + ''' as datetime) '  end +') as datetime) 
group by deal_num,cast(DBO.FNAGetContractMonth(date)as datetime),
cast(dbo.FNALastDayInDate(date)as datetime)
'

exec(@sql)


set @user_login_id=dbo.FNADBUser()
declare @is_schedule varchar(1)
if @adhoc_call is NULL
	set @is_schedule='y'
else
	set @is_schedule='n'

set @call_imp_engine='exec spa_import_data_job'''+@tName +''',4006,''Interface_MTM_Fx'',
'''+@process_id+''','''+ @user_login_id+''','''+ @is_schedule +''',1,''formate1'','''+ @pnl_as_of_date +''''

exec(@call_imp_engine)


if @adhoc_call is not null
	--delete ssis_mtm_formate1

declare @error_count int

select @error_count=count(*) from source_system_data_import_status 
where process_id=@process_id and code='Error'

If @error_count = 0
		Exec spa_ErrorHandler 0, 'Interface_MTM_Fx', 
		'Interface_MTM', 'Success', 
		'Import Successful.', ''
else
begin
		Exec spa_ErrorHandler -1, 'Interface_MTM_Fx', 
				'Interface_MTM', 'Error', 
				'Import Failed.', ''
end	
	
--------------------------------------------------------------------------------------------------------------------







