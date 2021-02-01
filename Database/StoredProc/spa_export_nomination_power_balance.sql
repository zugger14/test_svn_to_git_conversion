IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_export_nomination_power_balance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_export_nomination_power_balance]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**
	Export and calculate nomination power balance.

	Parameters 
	@as_of_date : As of Date
	@sub : Subsidiary IDs filter for process
	@str : Strategy IDs filter for process
	@book : Book IDs filter for process
	@sub_book : Sub Book IDs filter for process
	@location_ids : Location IDs filter for process
	@term_start : Term Start filter for process
	@term_end : Term End filter for process
	@round : Round the position
	@commodity : Commodity IDs filter for process
	@physical_financial : Physical or Financial  filter for process
					- p - Physical
					- f - Financial
	@balance_location_id : Auction location ID
	@trans_deal_type_id : Transport deal type ID
	@power_plant_deal_header_id : Power Plant deal header ID
	@process_id : Process ID
*/


create proc [dbo].[spa_export_nomination_power_balance] 
		@as_of_date VARCHAR(10) = null,
        @sub VARCHAR(1000) =null,
        @str VARCHAR(1000) =null,
        @book VARCHAR(1000) =null,
		@sub_book VARCHAR(1000) =null,--'16',--'211,217' ,--'162', --'162,164,166,206'
        @location_ids VARCHAR(1000) =null,
        @term_start VARCHAR(10) = null,
        @term_end VARCHAR(10) = null,
        @round  varchar(10) = 2,
		@commodity VARCHAR(1000) = 123,  --Power
		@physical_financial VARCHAR(1000) = 'p',  
  		@balance_location_id int=NULL,
		@trans_deal_type_id int=1185,
		@power_plant_deal_header_id VARCHAR(1000)=NULL,--'DA_Power_Plant_autobalancing',
		@process_id varchar(150)
as

/*

DECLARE 
		@as_of_date VARCHAR(10) = null,
        @sub VARCHAR(1000) =null,
        @str VARCHAR(1000) =null,
        @book VARCHAR(1000) =null,
		@sub_book VARCHAR(1000) =null,--'16',--'211,217' ,--'162', --'162,164,166,206'
        @location_ids VARCHAR(1000) =null,
        @term_start VARCHAR(10) = null,
        @term_end VARCHAR(10) = null,
        @round  tinyint = 10,
		@commodity VARCHAR(1000) = 123,  --Power
		@physical_financial VARCHAR(1000) = 'p',  
  		@balance_location_id int=NULL,
		@trans_deal_type_id int=1185,
		@power_plant_deal_header_id VARCHAR(1000)=NULL,  --'DA_Power_Plant_autobalancing',
		@process_id varchar(150)

--select * from source_minor_location where source_minor_location_id in (2855,2849,2848)
-- select * from source_system_book_map where logical_name='Spec-Power'



DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
 
--exec spa_drop_all_temp_table  
       
--*/


--------------------------------------------------------------------------------------


/*
exec [dbo].[spa_export_nomination_power_balance] 
		@as_of_date = null,
        @sub =null,
        @str =null,
        @book =null,
		@sub_book =null,--'16',--'211,217' ,--'162', --'162,164,166,206'
        @location_ids  =null,
        @term_start = null,
        @term_end  = null,
        @round= 10,
		@commodity= 123,  --Power
		@physical_financial  = 'p',  
  		@balance_location_id =NULL,
		@trans_deal_type_id =1185,
		@power_plant_deal_header_id=NULL,--'DA_Power_Plant_autobalancing',
		@process_id=null

*/



--SET @user_login_id = dbo.FNADBUser() 

--Start tracking time for Elapse time

DECLARE @current_datetime DATETIME = GETDATE()

DECLARE @_system_timezone_id int
,@_convert_timezone_id int
select @_system_timezone_id= var_value  from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
set @_convert_timezone_id=14 -- (GMT) Western Europe Time, London, Lisbon, Casablanca

select @balance_location_id  =source_minor_location_id from source_minor_location where location_id='Tennet'

DECLARE @st1                       VARCHAR(MAX),
		@hr_columns varchar(1000),
		@group_by_columns varchar(1000),
		@dst_group_value_id VARCHAR(30)
DECLARE @user_login_id VARCHAR(100) = dbo.FNADBUser() 
DECLARE @new_job_name VARCHAR(100)



SET @process_id =isnull(@process_id, REPLACE(newid(),'-','_'))

SET @as_of_date = ISNULL(@as_of_date, CONVERT(VARCHAR(10), @current_datetime, 120))
SET @term_start = ISNULL(@term_start, @as_of_date)
SET @term_end = ISNULL(@term_end, CASE WHEN CAST(@current_datetime AS TIME) >= '23:38' THEN CONVERT(VARCHAR(10), DATEADD(DAY, 1, @current_datetime), 120) ELSE @as_of_date END)

set @round=isnull(@round,10)

--select @as_of_date,@term_start,@term_end

if @location_ids is null
begin
	select @location_ids=isnull(@location_ids+',','')+cast(source_minor_location_id as varchar) from source_minor_location 
	where location_name in ('Tennet','50Hertz','Amprion','Transnet')
end

if @sub_book is null
begin
	select @sub_book=isnull(@sub_book+',','')+cast(book_deal_type_map_id as varchar) from source_system_book_map 
	where logical_name in ('Opt-Power','Spec-Power','R2M-NGR','R2M-Other','Power-NOM','ConvGen','RenewGen','Sales-Power-B2B','Sales-Power-B2C','Sales-Power-Spot')
end

--SET @begin_time = GETDATE()

--SET @process_id = REPLACE(newid(),'-','_')

if object_id('tempdb..#temp_deals_pos') is not null drop table #temp_deals_pos
if object_id('tempdb..#shaped_volume_update_deal_detail_id') is not null drop table #shaped_volume_update_deal_detail_id
if object_id('tempdb..#total_position_shaped') is not null drop table #total_position_shaped
if object_id('tempdb..#auto_balancing_deals') is not null drop table #auto_balancing_deals
if object_id('tempdb..#unpv_pos_shaped') is not null drop table #unpv_pos_shaped
if object_id('tempdb..#auto_balancing_location') is not null drop table #auto_balancing_location
if object_id('tempdb..#auto_balancing_location_deals') is not null drop table #auto_balancing_location_deals


create table #shaped_volume_update_deal_detail_id (
	source_deal_detail_id int,
	term_date date,
	hr varchar(10),
	is_dst bit,
	volume numeric(38,20)   ,
	granularity int,
	[period] int
)

CREATE TABLE #temp_deals_pos (source_deal_detail_id INT,external_id varchar(100),buy_sell_flag varchar(1))

create table #unpv_pos_shaped
(
	location_id int
	,[external_id] varchar(30)
	,term_start date
	,hr int
	,[period] tinyint
	,is_dst bit
	,volume numeric(30,8)
)

create table #auto_balancing_location(location_id int)


set	@power_plant_deal_header_id ='Autobalancing_deal'

IF OBJECT_ID('tempdb..#tmp_result') IS NULL
	CREATE TABLE #tmp_result (
		 ErrorCode VARCHAR(200) COLLATE DATABASE_DEFAULT
		,Module VARCHAR(200) COLLATE DATABASE_DEFAULT
		,Area VARCHAR(200) COLLATE DATABASE_DEFAULT
		,STATUS VARCHAR(200) COLLATE DATABASE_DEFAULT
		,Message VARCHAR(1000) COLLATE DATABASE_DEFAULT
		,Recommendation VARCHAR(200) COLLATE DATABASE_DEFAULT
	)

--BEGIN TRY


SELECT  @dst_group_value_id = tz.dst_group_value_id
FROM
	(
		SELECT var_value default_timezone_id 
		FROM dbo.adiha_default_codes_values (NOLOCK) 
		WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
inner join dbo.time_zones tz (NOLOCK) ON tz.timezone_id = df.default_timezone_id



SET @st1='insert into #temp_deals_pos (source_deal_detail_id,external_id,buy_sell_flag)		
select distinct sdd.source_deal_detail_id,scmd1.external_id,sdd.buy_sell_flag
from source_deal_header sdh
	inner join source_system_book_map sbm  ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		sdh.source_system_book_id2 = sbm.source_system_book_id2 AND sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		sdh.source_system_book_id4 = sbm.source_system_book_id4  AND sdh.deal_date<='''+convert(varchar(10),@as_of_date,120) +''''
	--+isnull(' and sdh.source_deal_header_id in ('+@source_deal_header_ids+')','')       
	--+ case when @calc_type='r' then ' and sdh.deal_id not like '''+@ramp_deal+'%''' else '' end +
	--+ case when @calc_type='b' then isnull(' and sdh.source_deal_type_id<>'+cast(@trans_deal_type_id as varchar),'') + isnull(' and sdh.deal_id<>'''+@power_plant_deal_header_id+'''','') else '' end +
	+'
	INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
	INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
	inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
	inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
	left join shipper_code_mapping_detail scmd1 on scmd1.shipper_code_mapping_detail_id=sdd.shipper_code2
WHERE 1=1  '
	+isnull(' and stra.parent_entity_id in ('+@sub+')','')
	+isnull(' and stra.entity_id in ('+@str+')','')
	+isnull(' and book.entity_id in ('+@book+')','')
	+isnull(' and sdd.location_id in ('+@location_ids+')','')
	+isnull(' and isnull(spcd.commodity_id,sdh.commodity_id) in ('+@commodity+')','')
	+isnull(' and sdd.physical_financial_flag='''+@physical_financial+'''','')
	+isnull(' and sbm.book_deal_type_map_id in ('+@sub_book+')','') 
		
exec spa_print @st1		
exec(@st1)
--select sdd.source_deal_detail_id,sdd.formula_curve_id,sdd.profile_id,scmd1.shipper_code1,scmd1.shipper_code shipper_code2
--	,sdd.shipper_code1 shipper_code_id1,sdd.shipper_code2 shipper_code_id2,scmd1.external_id external_id1
--into #sdd_shipper_code
--from source_deal_detail sdd
--	inner join #temp_deals_pos td on td.source_deal_header_id=sdd.source_deal_header_id
		


--	inner join	#sdd_shipper_code ssc on ssc.source_deal_detail_id=vw.source_deal_detail_id



set @group_by_columns='e.location_id,t.external_id,e.term_start,e.period '

set @hr_columns=',sum(e.hr1) [1],sum(e.hr2-case when dst.[hour]=2 then isnull(e.hr25,0) else 0 end ) [2]
	,sum(e.hr3-case when dst.[hour]=3 then isnull(e.hr25,0) else 0 end ) [3],sum(e.hr4) [4],sum(e.hr5) [5],sum(e.hr6) [6],sum(e.hr7) [7],sum(e.hr8) [8]
	,sum(e.hr9) [9],sum(e.hr10) [10],sum(e.hr11) [11],sum(e.hr12) [12],sum(e.hr13) [13],sum(e.hr14) [14],sum(e.hr15) [15],sum(e.hr16) [16]
	,sum(e.hr17) [17],sum(e.hr18) [18],sum(e.hr19) [19],sum(e.hr20) [20],sum(e.hr21) [21],sum(e.hr22) [22],sum(e.hr23) [23],sum(e.hr24) [24],sum(e.hr25) [25]'

set @st1='
	select '+@group_by_columns+ @hr_columns +'
	into #temp_position_detail
	FROM [dbo].[report_hourly_position_profile] e
			inner join #temp_deals_pos t on e.term_start >='''+CONVERT(VARCHAR(10),@term_start,120) +''''
			+case when @term_end is not null then ' and e.term_start <='''+CONVERT(VARCHAR(10),@term_end,120) +'''' else '' end+' 
			and e.[source_deal_detail_id]=t.source_deal_detail_id 
			and e.expiration_date>='''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND e.[term_start]>='''+CONVERT(VARCHAR(10),@as_of_date,120) +'''
			and e.commodity_id=123
			and e.period IS NOT NULL
			and e.granularity=987
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = e.deal_status_id 
		left join mv90_dst dst on dst.[date] = e.term_start and dst.dst_group_value_id ='+@dst_group_value_id+' and dst.insert_delete=''i''
	group by '+@group_by_columns+'
	UNION ALL
	select '+@group_by_columns+ @hr_columns +'
	FROM [dbo].[report_hourly_position_deal] e inner join #temp_deals_pos t on e.term_start >='''+CONVERT(VARCHAR(10),@term_start,120) +'''' 
			+case when @term_end is not null then ' and e.term_start <='''+CONVERT(VARCHAR(10),@term_end,120) +'''' else '' end+'
			and  e.[source_deal_detail_id]=t.source_deal_detail_id 
			and e.expiration_date>='''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND e.[term_start]>='''+CONVERT(VARCHAR(10),@as_of_date,120) +'''
			and e.commodity_id=123 and e.period IS NOT NULL
			and e.granularity=987
		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = e.deal_status_id 
		left join mv90_dst dst on dst.[date] = e.term_start and dst.dst_group_value_id ='+@dst_group_value_id+' and dst.insert_delete=''i''
	group by '+@group_by_columns+';

	insert into #unpv_pos_shaped
	(
		[external_id],[location_id], term_start,hr,[period],is_dst,volume
	)
	select u.[external_id],u.[location_id],u.term_start
		--	,case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 3 else u.[Hr] end hr

		,case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 3 else u.[Hr] end hr
		,u.[period]
		,case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 1 else 0 end is_dst
		,sum(u.volume)
	FROM #temp_position_detail p
	UNPIVOT
		(Volume for Hr IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
	)AS u 
		left join mv90_dst dst on dst.[date] = u.term_start and dst.dst_group_value_id ='+@dst_group_value_id+' 
	where 	(isnull(dst.insert_delete,''n'')<>''d'' or (isnull(dst.insert_delete,''n'')=''d'' and isnull(dst.[hour],0)<>u.[hr]))
		and case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 3 else u.[Hr] end<25
	group by u.[external_id],u.[location_id],u.term_start
		,case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 3 else u.[Hr] end 
		,u.[period], case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 1 else 0 end;

insert into #auto_balancing_location(location_id) select distinct location_id  from #temp_position_detail where location_id<>'+cast(@balance_location_id as varchar)

exec spa_print @st1		
exec(@st1)





--select distinct hr from #unpv_pos_shaped
-- Power plant deals

select term_start,hr,[period],is_dst,sum(volume) total_volume 
into #total_position_shaped 
from #unpv_pos_shaped 
group by term_start,hr,[period],is_dst


delete sddh   
	from  dbo.source_deal_detail_hour sddh
	inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=sddh.source_deal_detail_id
	inner join dbo.source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
		and sdh.deal_id =@power_plant_deal_header_id
	inner join (select distinct term_start from #total_position_shaped ) rps  on rps.term_start=sddh.term_date
	

insert into dbo.source_deal_detail_hour(
	source_deal_detail_id,
	term_date,
	hr,
	is_dst,
	volume,
	granularity,
	period
)
	output inserted.source_deal_detail_id,
		inserted.term_date,
		inserted.hr,
		inserted.is_dst,
		inserted.volume,
		inserted.granularity,
		inserted.period
	into #shaped_volume_update_deal_detail_id (
		source_deal_detail_id,
		term_date,
		hr,
		is_dst,
		volume,
		granularity,
		period
	)
	-- select * from #shaped_volume_update_deal_detail_id
select 
	sdd.source_deal_detail_id,
	rps.term_start,
	right('0'+cast(rps.hr as varchar(2)),2)+':'+right('0'+cast(rps.[period] as varchar(2)),2) hr,
	rps.is_dst,
	round(rps.total_volume*-1*4,@round) volume,
	987 granularity,
	right('0'+cast(rps.[period] as varchar(2)),2) period
from  dbo.source_deal_detail sdd
	inner join #total_position_shaped rps on rps.term_start between sdd.term_start and  sdd.term_end
	inner join dbo.source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
		and sdh.deal_id =@power_plant_deal_header_id
			

select sdh.source_deal_header_id
		,max(case when sdd.leg=1 then location_id else null end) leg1_location
		,max(case when sdd.leg=2 then location_id else null end) leg2_location
	into #auto_balancing_location_deals
from source_deal_header sdh
		inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
		and sdh.source_deal_type_id=@trans_deal_type_id
group by sdh.source_deal_header_id

;WITH auto_balancing_deals (source_deal_header_id,leg1_location,leg2_location,main_location_id,lvl)
	AS
	(
		select source_deal_header_id,leg1_location,leg2_location, b.location_id main_location_id,0 lvl from #auto_balancing_location_deals a
			inner join #auto_balancing_location b on a.leg2_location=b.location_id
	   UNION ALL
	   select a.source_deal_header_id,a.leg1_location,a.leg2_location,c.main_location_id,c.lvl+1 lvl from #auto_balancing_location_deals a
		   inner join auto_balancing_deals c on a.leg2_location=c.leg1_location
				and c.leg1_location<>@balance_location_id
	)
	SELECT * into #auto_balancing_deals FROM auto_balancing_deals option (maxrecursion 0);



-- Trans Deals

	delete sddh   
		from  dbo.source_deal_detail_hour sddh
		inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=sddh.source_deal_detail_id
		--inner join dbo.source_deal_header a on a.source_deal_header_id=sdd.source_deal_header_id 
		--	and a.deal_id =@power_plant_deal_header_id
		inner join #auto_balancing_deals sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
		inner join #unpv_pos_shaped rps
			on rps.term_start=sddh.term_date
			and rps.location_id=sdh.main_location_id


	insert into dbo.source_deal_detail_hour(
			source_deal_detail_id,
			term_date,
			hr,
			is_dst,
			volume,
			granularity,
			period
		)
		output inserted.source_deal_detail_id,
			inserted.term_date,
			inserted.hr,
			inserted.is_dst,
			inserted.volume,
			inserted.granularity,
			inserted.period
		into #shaped_volume_update_deal_detail_id (
			source_deal_detail_id,
			term_date,
			hr,
			is_dst,
			volume,
			granularity,
			period
		)
		-- select * from #shaped_volume_update_deal_detail_id
	select 
		sdd.source_deal_detail_id,
		rps.term_start,
		right('0'+cast(rps.hr as varchar(2)),2)+':'+right('0'+cast(rps.[period] as varchar(2)),2) hr,
		rps.is_dst,
		round(rps.volume*4,@round) volume,
		987 granularity,
		right('0'+cast(rps.[period] as varchar(2)),2) period
	from  dbo.source_deal_detail sdd
		inner join #auto_balancing_deals sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
		cross apply
		( select term_start,hr,is_dst,[period], sum(volume) volume from #unpv_pos_shaped 
			where term_start between sdd.term_start and  sdd.term_end
			and location_id=sdh.main_location_id
			group by term_start,hr,is_dst,[period]
		) rps 
		




	update sdd set deal_volume= tmp.volume
	from dbo.source_deal_detail sdd 
		cross apply
		(	select avg(volume) volume from #shaped_volume_update_deal_detail_id 
			 where source_deal_detail_id=sdd.source_deal_detail_id
		 ) tmp
	where tmp.volume is not null

	select @st1=cast(source_deal_header_id as varchar) from dbo.source_deal_header where deal_id =@power_plant_deal_header_id

	select 	@st1=isnull(@st1+',','')+cast(source_deal_header_id as varchar(30)) from #auto_balancing_location_deals
	--exec dbo.spa_calc_deal_position_breakdown @st1
	
	IF NULLIF(@st1,'') IS NOT NULL
	BEGIN
		
		--EXEC [dbo].[spa_deal_position_breakdown] 'i', @st1, @user_login_id, NULL
	
		SET @st1 = ' spa_update_deal_total_volume @source_deal_header_ids = ''' + @st1 + ''', @process_id = NULL, @insert_type = 0, @partition_no = 1, @user_login_id = ''' + @user_login_id + ''', @insert_process_table = ''n'', @call_from = 1 , @process_id_alert = ''' + @process_id + ''''
		SET @new_job_name = 'spa_update_deal_total_volume_' + dbo.FNAGetNewID()
		EXEC spa_run_sp_as_job @new_job_name,  @st1, 'spa_update_deal_total_volume', @user_login_id
	END
	
	DECLARE @out_msg NVARCHAR(500), @export_web_services_id INT, @sql NVARCHAR(MAX), @batch_process_table NVARCHAR(200), @final_process_table NVARCHAR(200)
	
	SET @final_process_table = dbo.FNAProcessTableName('final', NULL, @process_id)

	EXEC ('CREATE TABLE ' + @final_process_table + '([Time series id] INT, startDate DATETIME, endDate DATETIME, Position NUMERIC(38,18), UOM NVARCHAR(10))')
	
	SET @sql = ('INSERT INTO ' + @final_process_table + '
	select 
	pos.[external_id]

	,dateadd(minute,pos.[Period],to_dt.to_dt) actual_term_to_start
	,dateadd(minute,15,dateadd(minute,pos.[Period],to_dt.to_dt)) actual_term_to_end
	,round(pos.volume,' +isnull(@round,'2')+') position
	,''MW'' UOM

	from (
		select [external_id],term_start term_date,hr,[period],is_dst,4*sum(volume) volume from #unpv_pos_shaped
			where isnull(external_id,'''')<>''''
			group by [external_id],term_start,hr,[period],is_dst
		union all
		select scmd1.external_id,sv.term_date,left(sv.hr,2) hr,sv.[period],sv.is_dst,sum(case when sdd.buy_sell_flag=''s'' then -1 else 1 end *volume) volume 
		from #shaped_volume_update_deal_detail_id sv
		inner join source_deal_detail sdd on sdd.source_deal_detail_id=sv.source_deal_detail_id
			left join shipper_code_mapping_detail scmd1 on scmd1.shipper_code_mapping_detail_id=sdd.shipper_code2

		--	inner join #temp_deals_pos t on t.source_deal_detail_id=sv.source_deal_detail_id
		where  isnull(scmd1.external_id,'''')<>''''
		group by scmd1.external_id,sv.term_date,sv.hr,sv.[period],sv.is_dst
	) pos
	inner join time_zones from_tz on from_tz.TIMEZONE_ID=15--@_system_timezone_id
	inner JOIN time_zones to_tz on to_tz.TIMEZONE_ID=14 --@_convert_timezone_id 
	OUTER APPLY 
	(
		SELECT
			max(case when insert_delete=''d'' THEN  DATEADD(hour,[hour]-1,[date]) ELSE NULL END)  from_dst,
			max(case when insert_delete=''i'' THEN  DATEADD(hour,[hour]-1,[date]) ELSE NULL END)  to_dst
		from mv90_DST WHERE  [YEAR]=year(pos.term_date) AND dst_group_value_id = COALESCE(from_tz.dst_group_value_id,to_tz.dst_group_value_id)
	) dst 

	CROSS APPLY
	(
		SELECT	convert(NVARCHAR(10),term_date,120) +'' '' +right(''0''+cast(hr-1  AS NVARCHAR),2)+'':00:00'' org_term_from
	) org_term_from
	
	
	CROSS APPLY
	(
		select DATEADD(hour,case when (org_term_from.org_term_from=to_dst and is_dst=1)  then -1
		when  org_term_from.org_term_from=dateadd(hour,-1,from_dst) then 1
		else 0 end, org_term_from.org_term_from) tmp_term_from
	) tmp_term_from  --- dst applied


	CROSS APPLY
	(
		SELECT	(to_tz.offset_hr-from_tz.offset_hr)
		  +
			CASE WHEN  cast(convert(VARCHAR(10),term_date,120) +'' '' +right(''0''+cast(hr-1 AS VARCHAR),2)+'':00:00'' AS DATETIME) BETWEEN from_dst AND to_dst AND is_dst=1 THEN --dst start
				-1   --CASE WHEN to_tz.offset_hr-from_tz.offset_hr<0 THEN -1 ELSE 1 END
			ELSE 0 END  offset
	) offset
	CROSS APPLY
	(
		select DATEADD(hour,offset.offset,org_term_from.org_term_from) to_dt
	) to_dt --actual date
	CROSS APPLY
	(
		select DATEADD(hour, CASE WHEN to_dt.to_dt BETWEEN dateadd(hour,-1,from_dst)  AND dateadd(hour,-2 ,to_dst) THEN 1 ELSE 0 end
		   , to_dt.to_dt) term_to
	) term_to  --- dst applied for to term
	')
	EXEC(@sql)
	
	SELECT @batch_process_table = dbo.FNAProcessTableName('batch_report', NULL, @process_id)
	SET @sql = 'SELECT * INTO ' + @batch_process_table + ' FROM ' + @final_process_table

	SELECT @export_web_services_id = id FROM export_web_service WHERE handler_class_name = 'EznergyTDSExporter'
	--return
	EXEC spa_post_data_to_web_service @export_web_services_id, @sql, '', @process_id, @out_msg OUTPUT
	--SELECT @out_msg

	EXEC('SELECT * FROM ' + @final_process_table)
--IF OBJECT_ID('tempdb..#tmp_result') IS NOT NULL
--	DROP TABLE #tmp_result
 
--CREATE TABLE #tmp_result (
--	 ErrorCode VARCHAR(200) COLLATE DATABASE_DEFAULT
--	,Module VARCHAR(200) COLLATE DATABASE_DEFAULT
--	,Area VARCHAR(200) COLLATE DATABASE_DEFAULT
--	,STATUS VARCHAR(200) COLLATE DATABASE_DEFAULT
--	,Message VARCHAR(1000) COLLATE DATABASE_DEFAULT
--	,Recommendation VARCHAR(200) COLLATE DATABASE_DEFAULT
--)


--	INSERT INTO #tmp_result (ErrorCode, Module, Area, Status, Message, Recommendation)   
--	SELECT 0, 'spa_calc_power_balance', 'spa_calc_power_balance', 'Success', 'Power Balancing Calculation Completed', NULL

--	EXEC spa_ErrorHandler 0
--			, 'spa_calc_power_balance' -- Name the tables used in the query.
--			, 'spa_calc_power_balance' -- Name the stored proc.
--			, 'Success' -- Operations status.
--			, 'Success' -- Success message.
--			,  NULL -- The reference of the data deleted.	



--END TRY
--BEGIN CATCH
--	declare @desc varchar(max)
--	SET @desc =  'Error Found in Catch: ' + ERROR_MESSAGE()
--	EXEC spa_print  '================================ERROR======================================='
--	EXEC spa_print  @desc

--	INSERT INTO #tmp_result (ErrorCode, Module, Area, Status, Message, Recommendation)   
--	SELECT -1, 'spa_calc_power_balance', 'spa_calc_power_balance', 'Error', @desc, NULL

--	EXEC spa_ErrorHandler -1
--		, 'spa_calc_power_balance' -- Name the tables used in the query.
--		, 'spa_calc_power_balance' -- Name the stored proc.
--		, 'Error' -- Operations status.
--		, @desc -- Success message.
--		,  NULL -- The reference of the data deleted.	
--END CATCH


/*
select * from #total_position_shaped
select * from #avg_position_shaped
select * from #RAMPS_position_shaped
select * from #shaped_volume_update_deal_detail_id

select * from #auto_balancing_deals
select * from #unpv_pos_shaped


*/