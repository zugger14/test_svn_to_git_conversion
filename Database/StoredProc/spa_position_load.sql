
IF OBJECT_ID('spa_position_load') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_position_load]
GO

CREATE PROCEDURE [dbo].[spa_position_load]
	@process_id						varchar(200),
	@source_system					varchar(200) = NULL,
	@as_of_date						varchar(20) = NULL,
	@adhoc_call						char(1) = NULL,
	@import_status_temp_table_name	varchar(50) = NULL
AS

--
----
-------- TEST Script
--drop table #import_status
--drop table #Temp_POS_Leg
--drop table #Temp_Position
--drop table #MTM_detail
--drop table #temp_del_pos
--declare @process_id varchar(200),
--@source_system varchar(200),
--@as_of_date varchar(20),
--@adhoc_call char(1)
--set @process_id='2231' 
--set @source_system='Endur'
--set @as_of_date='2008-05-30'
--
-----END Test
if @source_system='user' or @source_system='cdo' or @source_system='endur' 
	set @source_system='Endur'
else
	set @source_system='SoftMAR'
BEGIN TRY
declare @sql varchar(2000)
declare @errorcode varchar(200)
declare @url varchar(200)
declare @desc varchar(200),@staging_table_name varchar(150),@default_uom varchar(20)
declare @user_login_id varchar(100)
DECLARE @start_ts	datetime
DECLARE @sqlWhere	varchar(1000),@source_deal_pnl VARCHAR(180)

set @user_login_id=dbo.FNADBUser()
--set @user_login_id='farrms_admin'
set @default_uom='-1'
SET @sqlWhere = ''

if @adhoc_call is NULL
begin
	set @staging_table_name='ssis_position_formate2'	
end
else
begin
	set @staging_table_name='ssis_position_formate2_error_log'
	SET @sqlWhere = ' AND t.error_type_code IN (''MISSING_DEAL'', ''MISSING_STATIC_DATA'')'
end

--delete previous error logs for only those deals which are being loaded now, but delete only Missing Static Data
--when loading from staging table, as those errors won't gonna fix while loading from staging table and so needed to be shown in report
exec spa_print 'Deleting previous Position error logs'
exec spa_print 'AS OF Date: ', @as_of_date
SET @sql = 'DELETE source_deal_error_log
			FROM source_deal_error_log l
			INNER JOIN source_deal_error_types t ON l.error_type_id = t.error_type_id
			INNER JOIN (SELECT DISTINCT deal_num FROM ' + @staging_table_name + ') p ON l.deal_id = p.deal_num
			WHERE as_of_date = CAST(''' + @as_of_date + ''' AS datetime) AND source = ''Position''' + @sqlWhere
exec spa_print @sql
EXEC(@sql)

declare @source_system_id varchar(20)
select @source_system_id=source_system_id from source_system_description where source_system_Name=@source_system
if @source_system_id is null
	set @source_system_id='-1'

if @adhoc_call is null
begin
	insert source_uom(source_system_id,uom_id,uom_name,uom_desc)
	select distinct @source_system_id, unit_of_measure,unit_of_measure,unit_of_measure 
	from ssis_position_formate2 t left outer join source_uom st
	on st.uom_id=t.unit_of_measure and st.source_system_id=@source_system_id
	where st.uom_id is null
end

CREATE TABLE #import_status
	(
	temp_id int,
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(1000) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT,
	type_error varchar(500) COLLATE DATABASE_DEFAULT,
	external_type_id varchar(100) COLLATE DATABASE_DEFAULT
	)

CREATE TABLE #tmp_erroneous_deal_pos 
	(
		deal_id				varchar(200) COLLATE DATABASE_DEFAULT NOT NULL,
		error_type_code		varchar(100) COLLATE DATABASE_DEFAULT NOT NULL,
		error_description	varchar(500) COLLATE DATABASE_DEFAULT
	)

declare @count int,@count_source int

exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
OUTPUT INSERTED.external_type_id, ''MISSING_DEAL'', INSERTED.type_error INTO #tmp_erroneous_deal_pos
select a.tran_num,'''+ @process_id+''',''Error'',''Import Data'',''Position'',''Data Error'',
		''Data error for deal_id :''+ isnull(a.deal_num,''NULL'')+''
		Time Bucket:''+isnull(a.time_bucket,''NULL'') +'' Price region '' + isNull([price_region], ''NULL'') + ''
		 (Deal ID ''+ISNULL(a.deal_num,''NULL'')+'' not found)'',
		''Please check your data'',''Deal ID not found  ''+ isnull(a.deal_num,''NULL'') + '' is invalid'',a.deal_num
		from ' +@staging_table_name +' a left join source_deal_header h on 
		a.deal_num=h.deal_id
		where h.deal_id is null')

--CREATE TABLE #Temp_POS_Leg(
--	temp_id int identity(1,1),
--	[deal_num] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
--	[time_bucket] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
--	[deal_side] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
--	[fx_flt] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
--	[price_region] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
--	[Position] [money] NULL,
--	[unit_of_measure] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
--	[settlement_type] [varchar](255) COLLATE DATABASE_DEFAULT  NULL
--) ON [PRIMARY]
--Print '1 ########'
--print convert(varchar,getdate(),109)
--
--
-----------------
----select @as_of_date,@source_system_id,@default_uom,@default_deal_id,@adhoc_call,@staging_table_name
--set @sql='
--insert #Temp_POS_Leg([deal_num],[time_bucket],[deal_side]
--      ,[fx_flt] ,[price_region] 
--      ,[Position],[unit_of_measure],[settlement_type]
--)
--select deal_num,time_bucket,1 deal_side,NULL,price_region,
--sum(cast(position as float)) Position,
--isNull(max(case when unit_of_measure='''' then NULL 
--else unit_of_measure end),'''+ @default_uom +''') unit_of_measure,settlement_type
--from ' +@staging_table_name +' t 
--where (delivery_accounting <>(''Delivery'') or delivery_accounting is null) and time_bucket <> '''' 
--and cast(case when isDate(time_bucket)=0 then dbo.FNALastDayInDate(''01-''+time_bucket) 
--	 else DBO.FNALastDayInDate(time_bucket) end as datetime) > 
--cast(dbo.FNALastDayInDate('''+ @as_of_date +''') as datetime) 
--group by deal_num,time_bucket,price_region,settlement_type
--order by deal_num,time_bucket,settlement_type desc'
--
--print(@sql);
--exec(@sql);

EXEC spa_print 'End ########'
--EXEC spa_print convert(varchar,getdate(),109)

-- Adjusting Leg for Deal
CREATE TABLE #Temp_Position(
	temp_id int identity(1,1),
	[deal_num] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[time_bucket] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[deal_side] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[fx_flt] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[price_region] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[Position] [money] NULL,
	[unit_of_measure] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[settlement_type] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	source_curve_def_id int,
	[child_price_region] [varchar](255) COLLATE DATABASE_DEFAULT
) ON [PRIMARY] 

--insert #Temp_Position([deal_num],[time_bucket],[deal_side]
--      ,[fx_flt] ,[price_region] 
--      ,[Position],[unit_of_measure] 
--     
--)
--select [deal_num],[time_bucket],(select count(*) from 
--#Temp_POS_Leg where deal_num=g.deal_num and time_bucket=g.time_bucket and temp_id<=g.temp_id
--) [deal_side],[fx_flt] ,[price_region]  ,[Position],[unit_of_measure] 
--from #Temp_POS_Leg g 
--order by deal_num,time_bucket 

set @sql='
insert #Temp_Position([deal_num],[time_bucket],[deal_side]
      ,[fx_flt] ,[price_region] 
      ,[Position],[unit_of_measure],[settlement_type],source_curve_def_id
)
select deal_num,time_bucket, t.deal_side deal_side,
case when fx_flt=''fixed'' then ''f'' else ''t'' end ,sde.price_region,
sum(cast(position as float)) Position,
isNull(max(case when unit_of_measure='''' then NULL 
else unit_of_measure end),'''+ @default_uom +''') unit_of_measure,t.settlement_type,spcd.source_curve_def_id
from ' +@staging_table_name +' t left outer join source_deal_external sde 
on t.deal_num=sde.deal_id and t.deal_side=sde.deal_side and 
t.settlement_type=sde.settlement_type and sde.fixed_float=t.fx_flt left outer join source_price_curve_def spcd
on sde.price_region=spcd.curve_id
where (delivery_accounting <>(''Delivery'') or delivery_accounting is null) 
and time_bucket <> '''' 
group by deal_num,time_bucket,spcd.source_curve_def_id,sde.price_region,t.deal_side,t.settlement_type,fx_flt
order by deal_num,time_bucket,t.settlement_type desc'

exec spa_print 'Saving data in #Temp_Position STARTED.'
exec spa_print @sql;
SET @start_ts = GETDATE()

exec(@sql);
exec spa_print 'Saved data in #Temp_Position FINISHED. Process took ' -- + dbo.FNACalculateTimestamp(@start_ts)

set @sql='
update source_deal_detail
set deal_volume=abs(p.position),
buy_sell_flag=case when p.position < 0 then ''s'' else ''b'' end,
deal_volume_uom_id=isNull(u.source_uom_id,-1),
update_user='''+ @user_login_id +''',
update_ts=getdate()
from source_deal_detail sdd, source_deal_header sdh, 
(select deal_num,source_curve_def_id,settlement_type,unit_of_measure,time_bucket,fx_flt,
sum(position) position
 from #Temp_Position
group by deal_num,source_curve_def_id,settlement_type,unit_of_measure,time_bucket,fx_flt
) p,
source_uom u
where p.deal_num=sdh.deal_id and 
sdd.source_deal_header_id=sdh.source_deal_header_id 
and sdd.curve_id=p.source_curve_def_id
and sdd.block_description=p.settlement_type
and sdd.fixed_float_leg=p.fx_flt
and p.unit_of_measure=u.uom_id and 
sdd.term_start=cast(''01-''+ p.time_bucket as datetime) and
sdd.term_end > cast(dbo.FNALastDayInDate('''+ @as_of_date +''') as datetime) '

SET @start_ts = GETDATE()
exec spa_print 'Updating source_deal_detail STARTED.'
EXEC spa_print @sql
exec(@sql)
set @count_source=@@rowcount
exec spa_print 'Updating source_deal_detail FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

SET @start_ts = GETDATE()
exec spa_print 'Updating source_deal_pnl STARTED.'
SET @source_deal_pnl=dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl')
set @sql='
update '+@source_deal_pnl+'
set deal_volume=abs(sdd.deal_volume)
from '+@source_deal_pnl+' pnl join source_deal_header sdh 
on pnl.source_deal_header_id=sdh.source_deal_header_id join
(select deal_num from #Temp_Position
group by deal_num ) p
on p.deal_num=sdh.deal_id join source_deal_detail sdd
on sdd.source_deal_header_id=sdh.source_deal_header_id
and pnl.term_start=sdd.term_start 
and sdd.leg=1
where pnl_as_of_date=''' +@as_of_date +''''

exec spa_print 'Updating source_deal_pnl FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)


--- FIND the STATUS of Update
declare @total_deals int,@total_deal_found int
	CREATE TABLE #MTM_detail(total_mtm float)

exec('
INSERT INTO #MTM_detail (total_mtm)
select count(*) from (
select count(*) deal from ' +@staging_table_name +'
group by deal_num,time_bucket,price_region,settlement_type) l ')

select @count=isNull(total_mtm,0) from #MTM_detail
	if @count is null
			set @count=0

delete #MTM_detail

select sdh.deal_id into #temp_del_pos
from source_deal_detail sdd, source_deal_header sdh, #Temp_Position p
where p.deal_num=sdh.deal_id and 
sdd.source_deal_header_id=sdh.source_deal_header_id 
and sdd.curve_id=p.source_curve_def_id
and sdd.block_description=p.settlement_type
and sdd.term_start=cast('01-'+ p.time_bucket as datetime)
group by sdh.deal_id

INSERT INTO #MTM_detail (total_mtm)
select count(*) from #temp_del_pos t

select @total_deal_found=isNull(total_mtm,0) from #MTM_detail
if @total_deal_found is null
	set @total_deal_found=0

delete #MTM_detail
exec('
INSERT INTO #MTM_detail (total_mtm)
select count(*) from (
select p.deal_num
from ' +@staging_table_name +' p
group by p.deal_num) t ') 


select @total_deals=isNull(total_mtm,0) from #MTM_detail
if @total_deals is null
	set @total_deals=0
	
--	if @adhoc_call is null
--		delete ssis_position_formate2_error_log where 
--		deal_num in (select external_type_id from #import_status)
--		

SET @start_ts = GETDATE()
exec spa_print 'Deleting error free position deals from ssis_position_formate2_error_log STARTED'

delete ssis_position_formate2_error_log FROM ssis_position_formate2_error_log s INNER JOIN #temp_del_pos t ON s.deal_num=t.deal_id
exec spa_print 'Deleting error free position deals from ssis_position_formate2_error_log FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

--	delete ssis_position_formate2_error_log where 
--		deal_num in (select deal_id from #temp_del_pos)

/*this check (@adhoc is null) is added as we don't need to re-insert erroneous deal in ssis_position_formate2_error_log
when loading from staging table as whichever deal have error, its already in that error log table.
So re-inserting same erroneous deal is not necessary. And actually the approach used to insert in error_log
(Delete first and insert) is not valid while loading from staging table. Example, if another batch(POS) is loaded
for same as_of_date, then ssis_position_formate2 contains different set of data. Now if data is loaded from 
staging table and if some deals have errors, then following code tries to insert such deals from ssis_position_formate2.
But since ssis_position_formate2 has different set of deals, it may not contain that erroneous deals and hence such
deals will be deleted, but not inserted so that they are lost
*/
IF @adhoc_call IS NULL
BEGIN
	SET @start_ts = GETDATE()
	
	CREATE TABLE #tmp_deleted_deals ( deal_id	varchar(250) COLLATE DATABASE_DEFAULT)

	/* we need to store only deals having Deal ID Not Found error and same deals having Missing Satic Data. Other errors like Timebucket, Deal Detail Mismatched won't gonna
	   get fixed from staging table. Deal ID Not Found will get solved if that deal is not loaded in MTM (4005) due to Missing Static Data.
	   So we need to save Deal ID Not Found errors if that deal is present in source_deal_error_log with error type MISSING_STATIC_DATA
	*/
	INSERT INTO #tmp_deleted_deals (deal_id)
	SELECT DISTINCT external_type_id --distinct is mandatory here, to avoid insertion of muliple deals later
	FROM #import_status s
	INNER JOIN source_deal_error_log e ON e.deal_id = s.external_type_id
	INNER JOIN source_deal_error_types t ON e.error_type_id = t.error_type_id
	WHERE e.as_of_date = CAST(@as_of_date AS datetime)
		AND e.source IN ('DEAL') AND t.error_type_code = 'MISSING_STATIC_DATA'
	exec spa_print 'Inserted position error deals in #tmp_deleted_deals. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

	SET @start_ts = GETDATE()
	exec spa_print 'Deleting error position deals before inserting from ssis_position_formate2_error_log STARTED'
	--we need to insert only those deals which are present in #import_status but not in ssis_position_formate2_error_log
	DELETE ssis_position_formate2_error_log 
	FROM ssis_position_formate2_error_log err
	INNER JOIN #tmp_deleted_deals st ON err.deal_num = st.deal_id
	exec spa_print 'Deleted error position deals before inserting from ssis_position_formate2_error_log FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

	SET @start_ts = GETDATE()
	exec spa_print 'Inserting position deals to ssis_position_formate2_error_log STARTED'
	
	insert ssis_position_formate2_error_log([tran_num],[deal_num]  ,[reference] ,[ins_type] ,[input_date]
	  ,[portfolio] ,[internal_desk] ,[counterparty]  ,[buy_sell]
	  ,[trader]   ,[trade_date]  ,[deal_side]  ,[price_region],[profile_leg]  ,[commodity],[side_currency]
	  ,[settlement_type] ,[zone] ,[pipeline] ,[location] ,[region],[product]
	  ,[settlement_currency]  ,[period_end_date] ,[position]
	  ,[time_bucket] ,[unit_of_measure]  ,[commodity_balance]  ,[external_commodity_balance]
	  ,[ias39_scope]   ,[ias39_book] ,[hedging_strategy]
	  ,[hedging_side]   ,[toolset]  ,[deal_start_date] ,[deal_end_date]
	  ,[period_start_date]  ,[settlement_date] ,[fx_flt]
	  ,[ins_sub_type]   ,[country]  ,[legal_entity] ,[taggingyear_complianceyear] ,
		[delivery_accounting],create_ts,process_id,source_system_id,pnl_as_of_date)
	select s.[tran_num],s.[deal_num]  ,s.[reference] ,s.[ins_type] ,s.[input_date]
	  ,s.[portfolio] ,s.[internal_desk] ,s.[counterparty]  ,s.[buy_sell]
	  ,s.[trader]   ,s.[trade_date]  ,s.[deal_side]  ,s.[price_region],s.[profile_leg]  ,s.[commodity],s.[side_currency]
	  ,s.[settlement_type] ,s.[zone] ,s.[pipeline] ,s.[location] ,s.[region],s.[product]
	  ,s.[settlement_currency]  ,s.[period_end_date] ,s.[position]
	  ,s.[time_bucket] ,s.[unit_of_measure]  ,s.[commodity_balance]  ,s.[external_commodity_balance]
	  ,s.[ias39_scope]   ,s.[ias39_book] ,s.[hedging_strategy]
	  ,s.[hedging_side]   ,s.[toolset]  ,s.[deal_start_date] ,s.[deal_end_date]
	  ,s.[period_start_date]  ,s.[settlement_date] ,s.[fx_flt]
	  ,s.[ins_sub_type]   ,s.[country]  ,s.[legal_entity] ,s.[taggingyear_complianceyear] ,s.[delivery_accounting]
	  ,GETDATE(),@process_id,@source_system_id,@as_of_date
	FROM ssis_position_formate2 s
	INNER JOIN #tmp_deleted_deals d ON s.deal_num = d.deal_id

	-- previous logic before optimization
	--insert ssis_position_formate2_error_log([tran_num],[deal_num]  ,[reference] ,[ins_type] ,[input_date]
	--  ,[portfolio] ,[internal_desk] ,[counterparty]  ,[buy_sell]
	--  ,[trader]   ,[trade_date]  ,[deal_side]  ,[price_region],[profile_leg]  ,[commodity],[side_currency]
	--  ,[settlement_type] ,[zone] ,[pipeline] ,[location] ,[region],[product]
	--  ,[settlement_currency]  ,[period_end_date] ,[position]
	--  ,[time_bucket] ,[unit_of_measure]  ,[commodity_balance]  ,[external_commodity_balance]
	--  ,[ias39_scope]   ,[ias39_book] ,[hedging_strategy]
	--  ,[hedging_side]   ,[toolset]  ,[deal_start_date] ,[deal_end_date]
	--  ,[period_start_date]  ,[settlement_date] ,[fx_flt]
	--  ,[ins_sub_type]   ,[country]  ,[legal_entity] ,[taggingyear_complianceyear] ,
	--	[delivery_accounting],create_ts,process_id,source_system_id,pnl_as_of_date)
	--select s.[tran_num],s.[deal_num]  ,s.[reference] ,s.[ins_type] ,s.[input_date]
	--  ,s.[portfolio] ,s.[internal_desk] ,s.[counterparty]  ,s.[buy_sell]
	--  ,s.[trader]   ,s.[trade_date]  ,s.[deal_side]  ,s.[price_region],s.[profile_leg]  ,s.[commodity],s.[side_currency]
	--  ,s.[settlement_type] ,s.[zone] ,s.[pipeline] ,s.[location] ,s.[region],s.[product]
	--  ,s.[settlement_currency]  ,s.[period_end_date] ,s.[position]
	--  ,s.[time_bucket] ,s.[unit_of_measure]  ,s.[commodity_balance]  ,s.[external_commodity_balance]
	--  ,s.[ias39_scope]   ,s.[ias39_book] ,s.[hedging_strategy]
	--  ,s.[hedging_side]   ,s.[toolset]  ,s.[deal_start_date] ,s.[deal_end_date]
	--  ,s.[period_start_date]  ,s.[settlement_date] ,s.[fx_flt]
	--  ,s.[ins_sub_type]   ,s.[country]  ,s.[legal_entity] ,s.[taggingyear_complianceyear] ,s.[delivery_accounting]
	--	,getdate(),@process_id,@source_system_id,@as_of_date
	--from ssis_position_formate2 s INNER JOIN #import_status t ON s.deal_num = t.external_type_id
	--LEFT JOIN ssis_position_formate2_error_log e ON s.deal_num = e.deal_num WHERE e.deal_num IS null

	--where deal_num in (select external_type_id from #import_status)
	--		and deal_num not in (select deal_num from ssis_position_formate2_error_log)
	exec spa_print 'Inserting position deals to ssis_position_formate2_error_log FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)
END


if @count-@count_source=0
begin
	set @errorcode='s'
end
else
begin
	set @errorcode='e'
end

insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
select @process_id,source,type,[description],type_error  from #import_status

insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
select @process_id,case when @count-@count_source>0 then 
	case when @total_deal_found=@total_deals and @total_deals <> 0 then 'Warning' else 'Error' end else 'Success' end,
'Import Data','Position',case when @count-@count_source>0 then 'Data Error' else 'Import Success' end,
'After aggregation, '+ cast(@count_source as varchar)+ ' deal detail records updated successfully out of '+cast(@count as varchar)+'
deal detail records.(Deals '+ cast(@total_deal_found as varchar)+' out of '+ cast(@total_deals as varchar) +'  successfully updated)',
case when @count-@count_source>0 then 'Please Check your data' else 'N/A' end 


delete #import_status
EXEC spa_print 'Deal Detail not matched'
exec('INSERT INTO #import_status(temp_id, process_id, ErrorCode, Module, Source, type, [description], nextstep,
		type_error, external_type_id) 
	OUTPUT INSERTED.external_type_id, ''MISMATCHED_DEAL'', INSERTED.type_error INTO #tmp_erroneous_deal_pos
	SELECT p.temp_id, ''' + @process_id + ''', ''Warning'', ''Import Data'', ''Position'', ''Static_Data'',
			''Data error for deal_id :'' + ISNULL(p.deal_num, ''NULL'') + '' 
			Time Bucket:'' + ISNULL(p.time_bucket, ''NULL'') + '' 
			Deal Side '' + ISNULL(p.deal_side, ''NULL'') + ''
			Volume:''+ ISNULL(LTRIM(STR(p.position, 100, 2)), ''NULL'')  ,	
			''Please check your data'', ''Deal Detail not matched'',
			p.deal_num			
--		from source_deal_detail sdd join source_deal_header sdh
--		on sdd.source_deal_header_id=sdh.source_deal_header_id 
--		right outer join #Temp_Position p on 
--		p.deal_num=sdh.deal_id
--		and sdd.curve_id=p.source_curve_def_id
--		and sdd.block_description=p.settlement_type
--		and sdd.term_start=cast(''01-''+ p.time_bucket  as datetime) 
		FROM #Temp_Position p
		INNER JOIN source_deal_header sdh ON p.deal_num = sdh.deal_id --inner join avoids missing deals here
		LEFT JOIN source_deal_detail sdd ON sdd.curve_id = p.source_curve_def_id
			AND sdd.block_description = p.settlement_type
			AND sdd.term_start = CAST(''01-'' + p.time_bucket AS datetime) 
		WHERE sdd.source_deal_detail_id IS NULL')

if exists (select 	source from #import_status) 
begin
	insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
	select @process_id,source,type,[description],type_error  from #import_status

	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
	select @process_id,'Warning',
	'Import Data','Static_Data','Static_Data',
	'Deal Detail not matched',
	 'Please review position and MTM files for differences (row effected '+ cast(count(*)  as varchar) +').'
	from source_deal_detail sdd join source_deal_header sdh
		on sdd.source_deal_header_id=sdh.source_deal_header_id 
		right outer join #Temp_Position p on 
		p.deal_num=sdh.deal_id
		and sdd.curve_id=p.source_curve_def_id
		and sdd.block_description=p.settlement_type
		and sdd.term_start=cast('01-'+ p.time_bucket  as datetime) 
		where sdd.source_deal_detail_id is null

	/*************************************SAVE POSITIONS FOR SOME ERRORS FOR DEBUGGING STARTED*******************************/
	DECLARE @pos_debug_table_name			varchar(200)
	DECLARE @pos_debug_table_name_suffix	varchar(100)
	SET @pos_debug_table_name_suffix = 'source_deal_position_debug'
	SET @pos_debug_table_name = dbo.FNAProcessTableName(@pos_debug_table_name_suffix, 'farrms', @process_id)

	EXEC('SELECT DISTINCT t.temp_id, t.deal_num, t.time_bucket, t.deal_side, t.fx_flt, t.price_region, t.Position, t.unit_of_measure, t.settlement_type, t.source_curve_def_id, t.child_price_region
			INTO ' + @pos_debug_table_name + '
			FROM #Temp_Position t
			INNER JOIN #import_status s ON t.deal_num = s.external_type_id
			WHERE type_error IN (''Deal Detail not matched'')
	')
	/*************************************SAVE POSITIONS FOR SOME ERRORS FOR DEBUGGING FINISHED******************************/
end 

delete #import_status
EXEC spa_print 'Time Bucket Issue'

	exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
	OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deal_pos
	select a.tran_num,'''+ @process_id+''',''Error'',''Import Data'',''Static_Data'',''Data Error'',
			''Data error for deal_id :''+ isnull(a.deal_num,''NULL'')+''
			Time Bucket:''+isnull(a.time_bucket,''NULL'') +'' Deal Side'' + isNull(deal_side,''NULL'') + ''
			 (Invalid Time Bucket)'',
			''Please check your data'',''Time Bucket is Blank/Invalid'',a.deal_num
			--from ssis_position_formate2 a 
			from ' + @staging_table_name + ' a 
			where isDate(''01-''+ a.time_bucket)=0')

if exists (select source from #import_status) 
begin
	insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
	select @process_id,source,type,[description],type_error  from #import_status

	EXEC('INSERT INTO source_system_data_import_status(process_id, code, module, source, type, [description], recommendation) 
		 SELECT ''' + @process_id + ''', ''Warning'',
		 ''Import Data'', ''Static_Data'', ''Time Bucket'',
		 ''Time Bucket is Blank/Invalid'',
		 ''Please Check your data (row effected '' + CAST(COUNT(*) AS varchar) + '')''
		  --from ssis_position_formate2 a 
		  FROM ' + @staging_table_name + ' a 
		  WHERE ISDATE(''01-'' + a.time_bucket) = 0')

--	select @process_id,'Warning',
--	'Import Data','Static_Data','Time Bucket',
--	'Time Bucket is Blank/Invalid',
--	 'Please Check your data (row effected '+ cast(count(*)  as varchar) +')'
--	    from ssis_position_formate2 a 
--		where isDate('1-'+ a.time_bucket)=0
end 


delete #import_status
EXEC spa_print 'Future Time Bucket'

	exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
	OUTPUT INSERTED.external_type_id, ''EXPIRED_TENURE'', INSERTED.type_error INTO #tmp_erroneous_deal_pos
	select a.temp_id,'''+ @process_id+''',''Warning'',''Import Data'',''Static_Data'',''Data Error'',
			''Data error for deal_id :''+ isnull(a.deal_num,''NULL'')+''
			Time Bucket:''+isnull(a.time_bucket,''NULL'') +'' Volume'' + isNull(cast(position as varchar),''NULL'') + ''
			 (Time Bucket must be future value)'',
			''Please check your data'',''Time Bucket less than current month'',a.deal_num
			from #temp_position a 
			where cast(case when isDate(time_bucket)=0 then CAST(''01-''+time_bucket AS DATETIME) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime) <=
cast(dbo.FNALastDayInDate('''+  @as_of_date +''') as datetime) ')

if exists (select source from #import_status) 
begin
	insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
	select @process_id,source,type,[description],type_error  from #import_status

	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
	select @process_id,'Warning',
	'Import Data','Static_Data','Time Bucket',
	'Time Bucket less than current month',
	 'Time Bucket must be future value (row effected '+ cast(count(*)  as varchar) +')'
	    from #temp_position a 
		where cast(case when isDate(time_bucket)=0 then CAST('01-'+time_bucket AS DATETIME) 
	 else DBO.FNALastDayInDate(time_bucket) end as datetime) <=
cast(dbo.FNALastDayInDate(@as_of_date) as datetime) 
end 

--save all erroneous deals
exec spa_print 'Saving erroneous deals (POS) to table for process_id:', @process_id, ' STARTED.'
DECLARE @default_error_type_id	int

SET @start_ts = GETDATE()

SELECT @default_error_type_id = error_type_id FROM source_deal_error_types WHERE error_type_code = 'MISC'
	
INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)
SELECT @as_of_date, deal_id, 'Position', ISNULL(e.error_type_id, @default_error_type_id), MAX(error_description)
FROM #tmp_erroneous_deal_pos d
LEFT JOIN source_deal_error_types e ON d.error_type_code = e.error_type_code
GROUP BY deal_id, e.error_type_id

exec spa_print 'Saving erroneous deals (POS) to table for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

--delete ssis_agreement

--SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
--		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
--
--	select @desc = '<a target="_blank" href="' + @url + '">' + 
--				'Update process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 			
--			'.</a>'
--	EXEC  spa_message_board 'i', @user_login_id,
--				NULL, 'Import.Data',
--				@desc, '', '', @errorcode, null,null,@process_id

declare @error_count int

select @error_count=count(*) from source_system_data_import_status 
where process_id=@process_id 

If @errorcode ='e'
begin
	if @total_deal_found=@total_deals and @total_deals <> 0
		set @errorcode='w' 
end
	
	if @adhoc_call is not null
	begin
 		update import_data_files_audit
			set	status=@errorcode,
			elapsed_time=datediff(ss,create_ts,getdate())
			where process_id=@process_id
	end

IF @errorcode = 'e'
BEGIN
	DECLARE @status_sql varchar(500)

	IF @total_deal_found = @total_deals 
		SET @status_sql = 'SELECT ''Warning'' ErrorCode,''Interface_Position'' Module, 
			''Interface_Position'' Area, ''Not updated'' [Status], 
			''No rows updated.'' Message, '''' Recommendation'
	ELSE
		SET @status_sql = 'EXEC spa_ErrorHandler -1, ''Interface_Position'', 
			''Interface_Position'', ''Interface_Position'', 
			''Interface_Position.'', '''''
END
ELSE
	SET @status_sql = 'EXEC spa_ErrorHandler 0, ''Interface_Position'', 
		''Interface_Position'', ''Updated'', 
		''Update Successful.'', '''''

IF @import_status_temp_table_name IS NOT NULL
	EXEC('INSERT INTO ' + @import_status_temp_table_name + ' ' + @status_sql)
ELSE
	EXEC(@status_sql)		

END TRY
BEGIN CATCH
	set @desc = 'SQL Error found: ''(' + ERROR_MESSAGE() + ')'
	exec spa_print @desc
	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
	select @process_id,'Error',	'Import Data','Position','Data Error',
	@desc,
	'Technical Error'

	update import_data_files_audit
		set	status='e',
			elapsed_time=datediff(ss,create_ts,getdate())
		where process_id=@process_id


	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Import.Data',
				@desc, '', '', 'e', null,null,@process_id

END CATCH;

























GO
