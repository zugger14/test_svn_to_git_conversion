IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_power_balance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_power_balance]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**
	Calculate RAMP and power balance.

	Parameters 

	@calc_type : Calculation Type
				- r - RAMP
				- a - Auction
				- b - Auto balance
	@as_of_date : As of Date
	@sub : Subsidiary IDs filter for process
	@str : Strategy IDs filter for process
	@book : Book IDs filter for process
	@sub_book : Sub Book IDs filter for process
	@source_deal_header_ids : Deal header IDs filter for process
	@location_ids : Location IDs filter for process
	@term_start : Term Start filter for process
	@term_end : Term End filter for process
	@counterparty_ids : Counterparty IDs filter for process
	@round : Round the position
	@template_id : Template IDs filter for process
	@ramp_deal : RAMP Deal ID
	@deal_type : Deal type IDs filter for process
	@commodity : Commodity IDs filter for process
	@physical_financial : Physical or Financial  filter for process
					- p - Physical
					- f - Financial
	@auction_location_id : Auction location ID
	@balance_location_id : Auction location ID
	@trans_deal_type_id : Transport deal type ID
	@power_plant_deal_header_id : Power Plant deal header ID
	@Opt_Power_Book_Balancing_deal : Opt_Power_Book_Balancing_deal
*/


create proc [dbo].[spa_calc_power_balance] 
	@calc_type varchar(1)=null,   -- r:RAMP, a:Auction ,b: auto balance
	@as_of_date DATETIME = null,
	@sub VARCHAR(1000) = null,
	@str VARCHAR(1000) = null,
	@book VARCHAR(1000) =null,--'211,217' ,--'162', --'162,164,166,206'
	@sub_book VARCHAR(1000) =null,--'211,217' ,--'162', --'162,164,166,206'
	@source_deal_header_ids  VARCHAR(1000) = null,
	@location_ids VARCHAR(1000) = null,
	@term_start VARCHAR(1000) = null,
	@term_end VARCHAR(1000) = null,
	@counterparty_ids VARCHAR(1000) = null,
	@round  INT = 10,
	@template_id  VARCHAR(1000) = NULL,
	@ramp_deal VARCHAR(1000) = 'RAMPS',  ---RAMP Deal ID
	@deal_type VARCHAR(1000) = NULL,
	@commodity VARCHAR(1000) = 123,  --Power
	@physical_financial VARCHAR(1000) = 'p',  
	@auction_location_id int=null,
	@balance_location_id int=null,
	@trans_deal_type_id int=null,
	@power_plant_deal_header_id  VARCHAR(1000)=null,
	@Opt_Power_Book_Balancing_deal VARCHAR(1000) =null
as

/*
--select * from source_deal_type
  
DECLARE 
		@calc_type varchar(1)='b',   -- r:RAMP, a:Auction ,b: auto balance,w: book balance
		@as_of_date DATETIME = '2020-07-17',
        @sub VARCHAR(1000) =null,-- 118,
        @str VARCHAR(1000) = null,--119,
        @book VARCHAR(1000) =null,--120,--'211,217' ,--'162', --'162,164,166,206'
		@sub_book VARCHAR(1000) =NULL,--'16',--'211,217' ,--'162', --'162,164,166,206'
        @source_deal_header_ids  VARCHAR(1000) = null,
        @location_ids VARCHAR(1000) ='2855,2849,2848,2856',
        @term_start VARCHAR(1000) = '2020-07-18',
        @term_end VARCHAR(1000) = '2020-07-18',
        @counterparty_ids VARCHAR(1000) = null,
        @round  tinyint = 10,
		@template_id  VARCHAR(1000) = NULL,
		@ramp_deal VARCHAR(1000) = 'RAMPS',  ---RAMP Deal ID
		@deal_type VARCHAR(1000) = NULL,
		@summary_option VARCHAR(1000) = 'x', --15 Minutes
		@commodity VARCHAR(1000) = 123,  --Power
		@physical_financial VARCHAR(1000) = 'p',  
		@auction_location_id int=2855,
  		@balance_location_id int=2855,
		@trans_deal_type_id int=1185,
		@power_plant_deal_header_id VARCHAR(1000)='DA_Power_Plant_autobalancing',
		@Opt_Power_Book_Balancing_deal VARCHAR(1000) = 'Opt_Power_Book_Balancing_deal'


--select * from source_minor_location where source_minor_location_id in (2855,2849,2848)
-- select * from source_system_book_map where logical_name='Spec-Power'





DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
 
--exec spa_drop_all_temp_table  
       
--*/


--------------------------------------------------------------------------------------

--SET @user_login_id = dbo.FNADBUser() 

--Start tracking time for Elapse time


set @round=isnull(@round,10)

--SET @begin_time = GETDATE()

--SET @process_id = REPLACE(newid(),'-','_')

DECLARE @st1                       VARCHAR(MAX),
		@hr_columns varchar(1000),
		@group_by_columns varchar(1000),
		@dst_group_value_id VARCHAR(30)
DECLARE @user_login_id VARCHAR(100) = dbo.FNADBUser() 

if object_id('tempdb..#temp_deals_pos') is not null drop table #temp_deals_pos
if object_id('tempdb..#shaped_volume_update_deal_detail_id') is not null drop table #shaped_volume_update_deal_detail_id
if object_id('tempdb..#total_position_shaped') is not null drop table #total_position_shaped
if object_id('tempdb..#avg_position_shaped') is not null drop table #avg_position_shaped
if object_id('tempdb..#RAMPS_position_shaped') is not null drop table #RAMPS_position_shaped
if object_id('tempdb..#auto_balancing_deals') is not null drop table #auto_balancing_deals
if object_id('tempdb..#unpv_pos_shaped') is not null drop table #unpv_pos_shaped
if object_id('tempdb..#Opt_Power_Book_Balancing_deal') is not null drop table #Opt_Power_Book_Balancing_deal
if object_id('tempdb..#auto_balancing_location') is not null drop table #auto_balancing_location
if object_id('tempdb..#auto_balancing_location_deals') is not null drop table #auto_balancing_location_deals


set	@power_plant_deal_header_id ='DA_Power_Plant_autobalancing'

BEGIN TRY


SELECT  @dst_group_value_id = tz.dst_group_value_id
FROM
	(
		SELECT var_value default_timezone_id 
		FROM dbo.adiha_default_codes_values (NOLOCK) 
		WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
inner join dbo.time_zones tz (NOLOCK) ON tz.timezone_id = df.default_timezone_id



CREATE TABLE #temp_deals_pos (source_deal_header_id INT)
create table #shaped_volume_update_deal_detail_id (source_deal_detail_id int ,volume numeric(30,8))
create table #unpv_pos_shaped
(
	[location_id] int
	,term_start date
	,hr int
	,[period] tinyint
	,is_dst bit
	,volume numeric(30,8)
)
create table #Opt_Power_Book_Balancing_deal (source_deal_header_id INT)

if @calc_type='w'
begin
	insert into #Opt_Power_Book_Balancing_deal (source_deal_header_id )
	select org.source_deal_header_id 
	from source_deal_header org where org.deal_id like @Opt_Power_Book_Balancing_deal+'%'
	union all 
	select ofst.source_deal_header_id  from source_deal_header org
	inner join source_deal_header ofst on ofst.close_reference_id=org.source_deal_header_id
		and org.deal_id like @Opt_Power_Book_Balancing_deal+'%'
		and ofst.deal_reference_type_id =12500
end

SET @st1='insert into #temp_deals_pos (source_deal_header_id)		
	select distinct sdh.source_deal_header_id
	from source_deal_header sdh
		inner join source_system_book_map sbm  ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		   sdh.source_system_book_id4 = sbm.source_system_book_id4  AND sdh.deal_date<='''+convert(varchar(10),@as_of_date,120) +''''
			+isnull(' and sdh.source_deal_header_id in ('+@source_deal_header_ids+')','')       
		+ case when @calc_type='r' then ' and sdh.deal_id not like '''+@ramp_deal+'%''' else '' end +
		+ case when @calc_type='b' then isnull(' and sdh.source_deal_type_id<>'+cast(@trans_deal_type_id as varchar),'') + isnull(' and sdh.deal_id<>'''+@power_plant_deal_header_id+'''','') else '' end +
		--+ case when @calc_type='w' then ' and sdh.deal_id not like'''+@Opt_Power_Book_Balancing_deal + '%''' else '' end +
		'
		INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
		inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
		left join #Opt_Power_Book_Balancing_deal opt on opt.source_deal_header_id=sdh.source_deal_header_id
	WHERE opt.source_deal_header_id is null  '
		+isnull(' and stra.parent_entity_id in ('+@sub+')','')
		+isnull(' and stra.entity_id in ('+@str+')','')
		+isnull(' and book.entity_id in ('+@book+')','')
		+isnull(' and sdd.location_id in ('+@location_ids+')','')
		+isnull(' and sdh.counterparty_id in ('+@counterparty_ids+')','')
		+isnull(' and sdh.template_id in ('+@template_id+')','')
		+isnull(' and sdh.source_deal_type_id in ('+@deal_type+')','')
		+isnull(' and isnull(spcd.commodity_id,sdh.commodity_id) in ('+@commodity+')','')
		+isnull(' and sdd.physical_financial_flag='''+@physical_financial+'''','')
		+isnull(' and sbm.book_deal_type_map_id in ('+@sub_book+')','') 
		

exec spa_print @st1		
exec(@st1)


set @group_by_columns='e.[location_id],e.term_start,e.period '

set @hr_columns=',sum(e.hr1) [1],sum(e.hr2-case when dst.[hour]=2 then isnull(e.hr25,0) else 0 end ) [2]
	,sum(e.hr3-case when dst.[hour]=3 then isnull(e.hr25,0) else 0 end ) [3],sum(e.hr4) [4],sum(e.hr5) [5],sum(e.hr6) [6],sum(e.hr7) [7],sum(e.hr8) [8]
	,sum(e.hr9) [9],sum(e.hr10) [10],sum(e.hr11) [11],sum(e.hr12) [12],sum(e.hr13) [13],sum(e.hr14) [14],sum(e.hr15) [15],sum(e.hr16) [16]
	,sum(e.hr17) [17],sum(e.hr18) [18],sum(e.hr19) [19],sum(e.hr20) [20],sum(e.hr21) [21],sum(e.hr22) [22],sum(e.hr23) [23],sum(e.hr24) [24],sum(e.hr25) [25]'

set @st1='
	insert into #unpv_pos_shaped
	(
		[location_id], term_start,hr,[period],is_dst,volume
	)
	select u.[location_id],u.term_start
		,case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 3 else u.[Hr] end 
		,u.[period]
		,case when isnull(dst.insert_delete,''n'')=''i'' and u.[Hr]=25 then 1 else 0 end 
		,u.volume
	FROM 
		(
			select '+@group_by_columns+ @hr_columns +'
			FROM [dbo].[report_hourly_position_profile] e
			 inner join #temp_deals_pos t on e.[source_deal_header_id]=t.source_deal_header_id 
			 '
			 +case when @term_start is not null then ' and e.term_start >='''+CONVERT(VARCHAR(10),@term_start,120) +'''' else '' end
			 +case when @term_end is not null then ' and e.term_start <='''+CONVERT(VARCHAR(10),@term_end,120) +'''' else '' end+'
				and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date,120) +'''
				and e.commodity_id=123
				and e.period IS NOT NULL
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = e.deal_status_id 
			left join mv90_dst dst on dst.[date] = e.term_start and dst.dst_group_value_id ='+@dst_group_value_id+' and dst.insert_delete=''i''
			group by '+@group_by_columns+'
			UNION ALL
			select '+@group_by_columns+ @hr_columns +'
			FROM [dbo].[report_hourly_position_deal] e inner join #temp_deals_pos t on e.[source_deal_header_id]=t.source_deal_header_id 
			'
			 +case when @term_start is not null then ' and e.term_start >='''+CONVERT(VARCHAR(10),@term_start,120) +'''' else '' end
			 +case when @term_end is not null then ' and e.term_start <='''+CONVERT(VARCHAR(10),@term_end,120) +'''' else '' end+'
				and e.expiration_date>'''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND e.[term_start]>'''+CONVERT(VARCHAR(10),@as_of_date,120) +'''
				and e.commodity_id=123
				and e.period IS NOT NULL
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = e.deal_status_id 
			left join mv90_dst dst on dst.[date] = e.term_start and dst.dst_group_value_id ='+@dst_group_value_id+' and dst.insert_delete=''i''
			group by '+@group_by_columns+'
		) p
			UNPIVOT
				(Volume for Hr IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
		)AS u 
		left join mv90_dst dst on dst.[date] = u.term_start and dst.dst_group_value_id ='+@dst_group_value_id+'
	where isnull(dst.insert_delete,''n'')<>''d'' or (isnull(dst.insert_delete,''n'')=''d'' and isnull(dst.[hour],0)<>u.[hr])
'
exec spa_print @st1		
exec(@st1)

select term_start,hr,[period],is_dst,sum(volume) total_volume into #total_position_shaped from #unpv_pos_shaped group by term_start,hr,[period],is_dst
select term_start,hr,is_dst,avg(total_volume) avg_volume into #avg_position_shaped from #total_position_shaped group by term_start,hr,is_dst

select t.term_start,t.hr,t.is_dst,t.[period],a.avg_volume-t.total_volume RAMPS_volume 
into #RAMPS_position_shaped -- select * from #RAMPS_position_shaped
from #total_position_shaped t 
	inner join #avg_position_shaped a on t.term_start=a.term_start and t.hr=a.hr and a.is_dst=t.is_dst
where a.hr<>25

if @calc_type='r' 
begin
	truncate table #shaped_volume_update_deal_detail_id
	--select * from #shaped_volume_update_deal_detail_id
	--select * from #RAMPS_position_shaped

	delete sddh from  dbo.source_deal_detail_hour sddh
		inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=sddh.source_deal_detail_id
		inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id and sdh.deal_id like 'RAMPS'+'%'
		inner join (select distinct term_start from #RAMPS_position_shaped ) rps on rps.term_start=sddh.term_date
		
--select * from #RAMPS_position_shaped

	insert into dbo.source_deal_detail_hour(
		source_deal_detail_id,
		term_date,
		hr,
		is_dst,
		volume,
		granularity,
		period
	)
		output inserted.source_deal_detail_id,inserted.volume
		into #shaped_volume_update_deal_detail_id (source_deal_detail_id ,volume)
		-- select * from #shaped_volume_update_deal_detail_id
	select 
		sdd.source_deal_detail_id,
		rps.term_start,
		right('0'+cast(rps.hr as varchar(2)),2)+':'+right('0'+cast(rps.[period] as varchar(2)),2) hr,
		rps.is_dst,
		round(abs(rps.RAMPS_volume)*4,@round) volume,
		987 granularity,
		right('0'+cast(rps.[period] as varchar(2)),2) period
	from  dbo.source_deal_detail sdd
		inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id and sdh.deal_id like @ramp_deal+'%'
		inner join #RAMPS_position_shaped rps on rps.term_start between sdd.term_start and  sdd.term_end
			--and sddh.hr=right('0'+cast(rps.hr as varchar(2)),2)+':'+right('0'+cast(rps.[period] as varchar(2)),2)
			--and rps.is_dst=sddh.is_dst
			and sdd.leg=case when rps.RAMPS_volume>0 then 1 else 2 end

	update sdd set deal_volume= tmp.volume
	from dbo.source_deal_detail sdd 
		cross apply
		(	select avg(volume) volume from #shaped_volume_update_deal_detail_id 
			 where source_deal_detail_id=sdd.source_deal_detail_id
		 ) tmp
	where tmp.volume is not null

		
	set @st1=null	
	select 	@st1=isnull(@st1+',','')+cast(source_deal_header_id as varchar(30)) from source_deal_header where deal_id like @ramp_deal+'%'

	exec dbo.spa_calc_deal_position_breakdown @st1
end
else if @calc_type='a' 
begin

	delete aop from dbo.auction_order_position aop 
		inner join #avg_position_shaped t on aop.[location_id]=@auction_location_id and aop.[term_start]=t.[term_start] 
		and aop.[hr]=t.[hr] and aop.is_dst=t.is_dst

	insert into dbo.auction_order_position(
		[location_id] ,[term_start],[hr],is_dst,volume
	)
	select @auction_location_id location_id,term_start,hr,is_dst, round(avg_volume*4,@round) avg_volume from #avg_position_shaped 

end

else if @calc_type='w' 
begin
	truncate table #shaped_volume_update_deal_detail_id

	delete sddh   
	from  dbo.source_deal_detail_hour sddh
		inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=sddh.source_deal_detail_id
		inner join #Opt_Power_Book_Balancing_deal opt on opt.source_deal_header_id=sdd.source_deal_header_id
		inner join (select distinct term_start from #total_position_shaped ) rps on rps.term_start=sddh.term_date

	insert into dbo.source_deal_detail_hour(
		source_deal_detail_id,
		term_date,
		hr,
		is_dst,
		volume,
		granularity,
		period
	)
	output inserted.source_deal_detail_id,inserted.volume
	into #shaped_volume_update_deal_detail_id (source_deal_detail_id ,volume)
		-- select * from #shaped_volume_update_deal_detail_id
	select 
		sdd.source_deal_detail_id,
		rps.term_start,
		right('0'+cast(rps.hr as varchar(2)),2)+':'+right('0'+cast(rps.[period] as varchar(2)),2) hr,
		rps.is_dst,
		rps.total_volume*4 volume,
		--round(rps.total_volume*4,@round) volume,
		987 granularity,
		right('0'+cast(rps.[period] as varchar(2)),2) period
	from  dbo.source_deal_detail sdd
		inner join #Opt_Power_Book_Balancing_deal opt on opt.source_deal_header_id=sdd.source_deal_header_id
		inner join #total_position_shaped rps on rps.term_start between sdd.term_start and  sdd.term_end

	set @st1=null	
	select 	@st1=isnull(@st1+',','')+cast(source_deal_header_id as varchar(30)) from #Opt_Power_Book_Balancing_deal
	--exec dbo.spa_calc_deal_position_breakdown @st1

	EXEC [dbo].[spa_deal_position_breakdown] 'i', @st1, @user_login_id, NULL
	
	SET @st1 = 'EXEC spa_update_deal_total_volume ''' + @st1 + ''', NULL, 0, 1, ''' + @user_login_id + ''', ''n'', 1 '
	EXEC(@st1)

end
else if @calc_type='b' 
begin
	truncate table #shaped_volume_update_deal_detail_id

	select distinct location_id into #auto_balancing_location from #unpv_pos_shaped where location_id<>@balance_location_id

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
	SELECT * into #auto_balancing_deals FROM auto_balancing_deals;


-- Power plant deals


	delete sddh   
		from  dbo.source_deal_detail_hour sddh
		inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=sddh.source_deal_detail_id
		inner join dbo.source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
			and sdh.deal_id =@power_plant_deal_header_id
		inner join (select distinct term_start from #total_position_shaped ) rps  on rps.term_start=sddh.term_date
	
	


--select * from #RAMPS_position_shaped

	insert into dbo.source_deal_detail_hour(
		source_deal_detail_id,
		term_date,
		hr,
		is_dst,
		volume,
		granularity,
		period
	)
		output inserted.source_deal_detail_id,inserted.volume
		into #shaped_volume_update_deal_detail_id (source_deal_detail_id ,volume)
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
			


-- Trans Deals

	delete sddh   
		from  dbo.source_deal_detail_hour sddh
		inner join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=sddh.source_deal_detail_id
		--inner join dbo.source_deal_header a on a.source_deal_header_id=sdd.source_deal_header_id 
		--	and a.deal_id =@power_plant_deal_header_id
		inner join #auto_balancing_deals sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
		inner join #unpv_pos_shaped rps on rps.term_start=sddh.term_date
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
		output inserted.source_deal_detail_id,inserted.volume
		into #shaped_volume_update_deal_detail_id (source_deal_detail_id ,volume)
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
		inner join #unpv_pos_shaped rps on rps.term_start between sdd.term_start and  sdd.term_end
			and rps.location_id=sdh.main_location_id

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

	EXEC [dbo].[spa_deal_position_breakdown] 'i', @st1, @user_login_id, NULL
	
	SET @st1 = 'EXEC spa_update_deal_total_volume ''' + @st1 + ''', NULL, 0, 1, ''' + @user_login_id + ''', ''n'', 1 '
	EXEC(@st1)

end

	EXEC spa_ErrorHandler 0
			, 'spa_calc_power_balance' -- Name the tables used in the query.
			, 'spa_calc_power_balance' -- Name the stored proc.
			, 'Success' -- Operations status.
			, 'Success' -- Success message.
			,  NULL -- The reference of the data deleted.	



END TRY
BEGIN CATCH
	declare @desc varchar(max)
	SET @desc =  'Error Found in Catch: ' + ERROR_MESSAGE()
	EXEC spa_print  '================================ERROR======================================='
	EXEC spa_print  @desc

	EXEC spa_ErrorHandler -1
		, 'spa_calc_power_balance' -- Name the tables used in the query.
		, 'spa_calc_power_balance' -- Name the stored proc.
		, 'Error' -- Operations status.
		, @desc -- Success message.
		,  NULL -- The reference of the data deleted.	
END CATCH


/*
select * from #total_position_shaped
select * from #avg_position_shaped
select * from #RAMPS_position_shaped
select * from #shaped_volume_update_deal_detail_id

select * from #auto_balancing_deals
select * from #unpv_pos_shaped


*/