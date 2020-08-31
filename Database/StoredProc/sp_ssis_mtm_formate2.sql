
	IF OBJECT_ID('sp_ssis_mtm_formate2') IS NOT NULL
	DROP  PROCEDURE dbo.sp_ssis_mtm_formate2
GO

CREATE PROC [dbo].[sp_ssis_mtm_formate2]
@process_id varchar(150),
@source_system varchar(200)=NULL,
@pnl_as_of_date varchar(20)=NULL,
@adhoc_call char(1)=null,
@import_status_temp_table_name varchar(50) = NULL
As 
declare @temptbl varchar(1000)
declare @user_login_id varchar(100)
declare @call_imp_engine varchar(1000)
declare @tblname varchar(1000)
declare @sql varchar(5000)
DECLARE @start_ts datetime
DECLARE @error_type_id	int
DECLARE @sqlWhere	varchar(1000)
--drop table #temp1
create table #temp1(table_name varchar(200) COLLATE DATABASE_DEFAULT)

if @source_system='user' or @source_system='cdo' or @source_system='endur' 
	set @source_system='Endur'
else
	set @source_system='SoftMAR'

insert #temp1
exec spa_import_temp_table '4006'
declare @tName varchar(500),@staging_table_name_pnl varchar(200)
select @tName=table_name from #temp1
EXEC spa_print @tName

SET @sqlWhere = ''
if @adhoc_call is null
begin
	SET @staging_table_name_pnl = 'ssis_mtm_formate2'
end
else
begin
	set @staging_table_name_pnl = 'ssis_mtm_formate2_error_log' 
	delete ssis_mtm_formate2

	insert ssis_mtm_formate2(tran_num, deal_num, reference, ins_type, input_date, toolset, portfolio, internal_desk, counterparty, buy_sell, trader, trade_date, deal_side, price_region, profile_leg, unit_of_measure, commodity, side_currency, settlement_type, zone, location, region, product, settlement_currency, mtm_undisc, mtm_undisc_eur, mtm_disc, mtm_disc_eur, value_type, period_end_date, location1, zone1, time_bucket, location_pair, deal_start_date, deal_end_date, settlement_date, ias39_scope, ias39_book, hedging_strategy, hedging_side, contract_value, period_start_date, commodity_balance, external_commodity_balance, ins_sub_type, fx_flt, country, pipeline, legal_entity, TaggingYear)
	select tran_num, deal_num, reference, ins_type, input_date, toolset, portfolio, internal_desk, counterparty, buy_sell, trader, trade_date, deal_side, price_region, profile_leg, unit_of_measure, commodity, side_currency, settlement_type, zone, location, region, product, settlement_currency, mtm_undisc, mtm_undisc_eur, mtm_disc, mtm_disc_eur, value_type, period_end_date, location1, zone1, time_bucket, location_pair, deal_start_date, deal_end_date, settlement_date, ias39_scope, ias39_book, hedging_strategy, hedging_side, contract_value, period_start_date, commodity_balance, external_commodity_balance, ins_sub_type, fx_flt, country, pipeline, legal_entity, TaggingYear 
	from ssis_mtm_formate2_error_log

	select @pnl_as_of_date=max(as_of_date) from ssis_mtm_formate2_error_log
	SET @sqlWhere = ' AND t.error_type_code IN (''MISSING_DEAL'', ''MISSING_STATIC_DATA'')'
end

declare @source_system_id int
select @source_system_id=source_system_id from source_system_description 
where source_system_Name=@source_system

exec spa_print 'Source System: ', @source_system_id

--delete previous error logs for only those deals which are being loaded now, but delete only Missing Static Data or Missing Deal (in case of pnl:4006)
--when loading from staging table, as those are the only errors that gonna be fixed while loading from staging table
exec spa_print 'Deleting previous MTM error logs'
exec spa_print 'PNL AS OF Date: ', @pnl_as_of_date
SET @sql = 'DELETE source_deal_error_log
			FROM source_deal_error_log l
			INNER JOIN source_deal_error_types t ON l.error_type_id = t.error_type_id
			INNER JOIN (SELECT DISTINCT deal_num FROM ' + @staging_table_name_pnl + ') m ON l.deal_id = m.deal_num
			WHERE as_of_date = CAST(''' + @pnl_as_of_date + ''' AS datetime) AND source IN (''DEAL'', ''PNL'')
			' + @sqlWhere

exec spa_print @sql
EXEC (@sql)

SELECT @error_type_id = error_type_id FROM source_deal_error_types WHERE error_type_code = 'EXPIRED_TENURE'

EXEC('INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)
		SELECT ''' + @pnl_as_of_date + ''', deal_num, ''DEAL'', ' + @error_type_id + ', ''All months expired''
		FROM ' + @staging_table_name_pnl + ' p
		LEFT JOIN source_deal_error_log n ON p.deal_num = n.deal_id
			AND n.as_of_date = CAST(''' + @pnl_as_of_date + ''' AS datetime)
		WHERE n.id IS NULL
		GROUP BY deal_num
		HAVING MAX(CAST(''01-'' + time_bucket AS datetime)) <= CAST(''' + @pnl_as_of_date + ''' AS datetime)')

/*
delete ssis_position_formate2
EXEC spa_print 'Insert into position formate2 '+convert(varchar,getdate(),109)

if @adhoc_call is null	
		insert ssis_position_formate2(tran_num,deal_num,reference,ins_type,portfolio,
		counterparty,buy_sell,trade_date,deal_side,price_region,unit_of_measure,side_currency,settlement_type,
		settlement_currency,time_bucket,commodity_balance,ias39_scope,ias39_book,fx_flt,ins_sub_type,trader,legal_entity,position,
		internal_desk,product,commodity)
		select tran_num,deal_num,reference,ins_type,portfolio,
		counterparty,buy_sell,trade_date,deal_side,price_region,unit_of_measure,side_currency,settlement_type,
		settlement_currency,time_bucket,commodity_balance,ias39_scope,ias39_book,fx_flt,ins_sub_type,trader,legal_entity,1,
		internal_desk,product,commodity
		from ssis_mtm_formate2 	

else
begin
		delete ssis_mtm_formate2
		insert ssis_position_formate2(tran_num,deal_num,reference,ins_type,portfolio,
		counterparty,buy_sell,trade_date,deal_side,price_region,unit_of_measure,side_currency,settlement_type,
		settlement_currency,time_bucket,commodity_balance,ias39_scope,ias39_book,fx_flt,ins_sub_type,trader,legal_entity,position,
		internal_desk,product,commodity)
		select tran_num,deal_num,reference,ins_type,portfolio,
		counterparty,buy_sell,trade_date,deal_side,price_region,unit_of_measure,side_currency,settlement_type,
		settlement_currency,time_bucket,commodity_balance,ias39_scope,ias39_book,fx_flt,ins_sub_type,trader,legal_entity,1,
		internal_desk,product,commodity
		from ssis_mtm_formate2_error_log

		select @pnl_as_of_date=max(as_of_date) from ssis_mtm_formate2_error_log
end

EXEC spa_print @pnl_as_of_date
*/



EXEC spa_print 'Calling position formate2  SPS: '--+convert(varchar,getdate(),109)	
exec sp_ssis_position_formate2 @process_id,@source_system,@pnl_as_of_date, @adhoc_call
EXEC spa_print 'position formate2 Completed: '--+convert(varchar,getdate(),109)	


EXEC spa_print 'Transform MTM Start : '--+convert(varchar,getdate(),109)	
--insert from table format1 to temporary table
/*
* Update [2010-05-20 @ bbajracharya@pioneersolutionsglobal.com]:

* Make sure following holds true
* dis_pnl = und_pnl
* dis_intrinsic_pnl = und_intrinsic_pnl
* und_extrinisc_pnl = 0
* dis_extrinisic_pnl = contract_value (from RDB)
*/
set @sql='insert '+@tName+'(source_deal_header_id,source_system_id,term_start,term_end,leg,
pnl_as_of_date,
und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,
dis_pnl,dis_intrinsic_pnl,
dis_extrinisic_pnl,pnl_source_value_id,pnl_currency_id,
pnl_conversion_factor,pnl_adjustment_value,deal_volume,table_code)
select deal_num,' + 
	case when @adhoc_call is not null then ' max(pnl.source_system_id)  ' 
		else '' + cast(@source_system_id as varchar)   + ''  end +',
cast(case when isDate(time_bucket)=0 then ''01-''+time_bucket 
	else DBO.FNAGetContractMonth(time_bucket) end as datetime)
period_start_date,
cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate(''01-''+time_bucket) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime) period_end_date,
1,' + 
	case when @adhoc_call is not null then ' max(pnl.as_of_date)  ' 
		else 'cast(''' + @pnl_as_of_date   + ''' as datetime) '  end +'
,SUM(CAST(mtm_disc_eur as float)), SUM(CAST(mtm_disc_eur as float)), 0,
SUM(CAST(mtm_disc_eur as float)), SUM(CAST(mtm_disc_eur as float)), SUM(ISNULL(CAST(contract_value as float), 0)),
775,''Eur'',
1,0,isNull(max(sd.deal_volume),1),4006
from '+@staging_table_name_pnl +' pnl left outer join (
	select deal_id,term_start,term_end,deal_volume, source_system_id from 
	source_deal_header sdh join source_deal_detail sdd
	on sdh.source_deal_header_id=sdd.source_deal_header_id
	where sdd.leg=1
	) sd on
pnl.deal_num=sd.deal_id and sd.source_system_id = ' + CAST(@source_system_id AS VARCHAR) + ' and cast(case when isDate(time_bucket)=0 then ''01-''+time_bucket 
	else DBO.FNAGetContractMonth(time_bucket) end as datetime)=sd.term_start and
cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate(''01-''+time_bucket) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime)=sd.term_end
where 
cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate(''01-''+time_bucket) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime) > 
cast(dbo.FNALastDayInDate('''+ @pnl_as_of_date +''') as datetime) 
group by deal_num,
cast(case when isDate(time_bucket)=0 then ''01-''+time_bucket 
	else DBO.FNAGetContractMonth(time_bucket) end as datetime),
cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate(''01-''+time_bucket) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime)
'
exec(@sql)
EXEC spa_print 'Transform MTM End : '--+convert(varchar,getdate(),109)	

--	insert interface_missing_deal_log(deal_num,counterparty,price_region,
--	source_system,as_of_date,process_id)
--	select distinct deal_num,counterparty,price_region,
--	@source_system,@pnl_as_of_date,@process_id
--	from ssis_mtm_formate2 s left outer join source_deal_header sdh
--	on s.deal_num=sdh.deal_id
--	where sdh.deal_id is null and cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate('01-'+time_bucket) 
--	 else DBO.FNALastDayInDate(time_bucket) end as datetime) > cast(dbo.FNALastDayInDate(@pnl_as_of_date) as datetime) 
--print 'interface_missing_deal_log End : '+convert(varchar,getdate(),109)	

--declare @miss_count int
--	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
--	select @process_id,'Error','Import Data','Deal_Not_Found','Data Error',
--	'Total Deal(s) ID '+cast(count(*) as varchar) + ' not found, and proceed for auto creating!! ',
--	'Please Check your data '  from interface_missing_deal_log 
--	where process_id=@process_id
--	having count(*) > 0
--	set @miss_count=@@rowcount
--
--	If @miss_count > 0
--	begin
		

--	end
--return

set @user_login_id=dbo.FNADBUser()
EXEC spa_print 'Complete Staging MTM insert Done: '--+convert(varchar,getdate(),109)	
if @process_id is null
	set @process_id = REPLACE(newid(),'-','_')

declare @is_schedule varchar(1)
if @adhoc_call is NULL
	set @is_schedule='y'
else
	set @is_schedule='n'

set @user_login_id=dbo.FNADBUser()
set @call_imp_engine='exec spa_import_data_job '''+@tName +''',4006,
''Interface_MTM'','''+@process_id+''','''+ @user_login_id+''','''+ @is_schedule +''',1,''formate2'','''+@pnl_as_of_date+''''
EXEC spa_print @call_imp_engine
exec (@call_imp_engine)

--return

-- Delete Archival PNL
EXEC spa_print 'Complete Staging MTM insert Done: '--+convert(varchar,getdate(),109)	

--delete ssis_mtm_formate2_archive
--from ssis_mtm_formate2_archive r, ssis_mtm_formate2 f
--where r.deal_num=f.deal_num and r.time_bucket=f.time_bucket
--and r.pnl_as_of_date= cast(@pnl_as_of_date as datetime)
--and r.deal_num in (select deal_num from (
--select deal_num,price_region from ssis_mtm_formate2
--group by deal_num,price_region ,settlement_type
--) l
--group by deal_num
--having count(*) > 2) 

SET @start_ts = GETDATE()
--deals having more than 2 legs
exec spa_print 'Reading deals having more than 2 legs STARTED.'
SELECT deal_num INTO #temp_arch_deal FROM (
	SELECT deal_num, price_region FROM ssis_mtm_formate2
	GROUP BY deal_num, price_region, settlement_type, fx_flt
) l
GROUP BY deal_num
HAVING COUNT(*) > 2
exec spa_print 'Reading deals having more than 2 legs COMPLETED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

SET @start_ts = GETDATE()
exec spa_print 'Reading deal with 2 legs and counterparty starting with ss STATED.'
INSERT #temp_arch_deal
SELECT deal_num FROM (
	SELECT deal_num, price_region FROM ssis_mtm_formate2
	WHERE counterparty LIKE 'ss %'
	GROUP BY deal_num, price_region, settlement_type, fx_flt
) l
GROUP BY deal_num
HAVING COUNT(*) = 2
exec spa_print 'Reading deal with 2 legs and counterparty starting with ss COMPLETED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

SET @start_ts = GETDATE()
exec spa_print 'Getting deals to be deleted from archive STARTED.'
SELECT sno INTO #temp_arch_deletion
FROM ssis_mtm_formate2_archive r 
INNER JOIN ssis_mtm_formate2 f ON r.deal_num = f.deal_num AND r.time_bucket = f.time_bucket
INNER JOIN #temp_arch_deal t ON r.deal_num = t.deal_num
WHERE r.pnl_as_of_date = CAST(@pnl_as_of_date AS DATETIME)
exec spa_print 'Getting deals to be deleted from archive COMPLETED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

SET @start_ts = GETDATE()
exec spa_print 'Creating index on temp table #temp_arch_deletion STARTED.'
CREATE INDEX IX_temp_arch_deletion_sno ON #temp_arch_deletion(sno)
exec spa_print 'Creating index on temp table #temp_arch_deletion COMPLETED.Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

SET @start_ts = GETDATE()
exec spa_print 'Deletion from ssis_mtm_formate2_archive STARTED.'
DELETE ssis_mtm_formate2_archive
FROM ssis_mtm_formate2_archive r 
INNER JOIN #temp_arch_deletion t ON r.sno = t.sno
exec spa_print 'Deletion from ssis_mtm_formate2_archive COMPLETED.Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

--delete ssis_mtm_formate2_archive
--from ssis_mtm_formate2_archive r join ssis_mtm_formate2 f
--on r.deal_num=f.deal_num and r.time_bucket=f.time_bucket
--where r.pnl_as_of_date= cast(@pnl_as_of_date as datetime)
--and r.deal_num  in  (select deal_num from 
--#temp_arch_deal)

--TODO: check for optimizations

SET @start_ts = GETDATE()
EXEC spa_print 'Complete Staging MTM insert Done: '--+convert(varchar,getdate(),109)	
exec spa_print 'Insertion into ssis_mtm_formate2_archive STARTED.'
insert ssis_mtm_formate2_archive(
	 [tran_num], [deal_num], [reference], [ins_type], [input_date]
   , [toolset], [portfolio], [internal_desk], [counterparty]
   , [buy_sell], [trader], [trade_date], [deal_side]
   , [price_region], [profile_leg], [unit_of_measure]
   , [commodity], [side_currency], [settlement_type]
   , [zone], [location], [region], [product]
   , [settlement_currency], [mtm_undisc], [mtm_undisc_eur]
   , [mtm_disc], [mtm_disc_eur], [value_type]
   , [period_end_date], [location1], [zone1]
   , [time_bucket], [location_pair], [deal_start_date]
   , [deal_end_date], [settlement_date], [ias39_scope]
   , [ias39_book], [hedging_strategy], [hedging_side]
   , [contract_value], [period_start_date], [commodity_balance]
   , [external_commodity_balance], [create_ts], pnl_as_of_date, fx_flt)

select s.[tran_num], s.[deal_num], s.[reference], s.[ins_type]
	 , s.[input_date], s.[toolset], s.[portfolio]
	 , s.[internal_desk], s.[counterparty], s.[buy_sell]
	 , s.[trader], s.[trade_date], s.[deal_side]
	 , s.[price_region], s.[profile_leg], s.[unit_of_measure]
	 , s.[commodity], s.[side_currency], s.[settlement_type]
	 , s.[zone], s.[location], s.[region], s.[product], s.[settlement_currency], s.[mtm_undisc]
	 , s.[mtm_undisc_eur], s.[mtm_disc], s.[mtm_disc_eur]
	 , s.[value_type], s.[period_end_date], s.[location1]
	 , s.[zone1], s.[time_bucket], s.[location_pair]
	 , s.[deal_start_date], s.[deal_end_date]
	 , s.[settlement_date], s.[ias39_scope], s.[ias39_book], s.[hedging_strategy]
	 , s.[hedging_side], s.[contract_value], s.[period_start_date]
	 , s.[commodity_balance], s.[external_commodity_balance]  
	 , getdate(), @pnl_as_of_date, s.fx_flt from ssis_mtm_formate2 s INNER JOIN #temp_arch_deal t ON s.deal_num=t.deal_num
--	where deal_num in (select deal_num from 
--#temp_arch_deal)
exec spa_print 'Insertion into ssis_mtm_formate2_archive COMPLETED.Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)


--print 'Complete Staging MTM insert Done: '+convert(varchar,getdate(),109)
--if @adhoc_call is not null
	-- delete ssis_mtm_formate2

DECLARE @status_sql varchar(250)

IF NOT EXISTS(SELECT status_id FROM source_system_data_import_status 
			WHERE process_id = @process_id AND code = 'Error')
	SET @status_sql = 'Exec spa_ErrorHandler 0, ''Interface_MTM'', 
		''Interface_MTM'', ''Success'', ''Imported Successful.'', '''''
ELSE
	SET @status_sql = 'Exec spa_ErrorHandler -1, ''Interface_MTM'', 
		''Interface_MTM'', ''Error'', ''Imported Failed.'', '''''

IF @import_status_temp_table_name IS NOT NULL
	EXEC('INSERT INTO ' + @import_status_temp_table_name + ' ' + @status_sql)
ELSE
	EXEC(@status_sql)















GO
