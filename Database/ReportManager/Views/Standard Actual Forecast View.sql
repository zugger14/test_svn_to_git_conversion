BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Standard Actual Forecast View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'AFV', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'declare @_locatin_ids varchar(1000)=null
	,@_meter_ids varchar(1000)=null
	,@_profile_ids varchar(1000)=null
	,@_term_start datetime=null
	,@_term_end datetime=null


if ''@locatin_ids'' <> ''NULL''
 set @_locatin_ids = ''@locatin_ids''

if ''@meter_ids'' <> ''NULL''
 set @_meter_ids = ''@meter_ids''
 
 if ''@profile_ids'' <> ''NULL''
 set @_profile_ids = ''@profile_ids''
 
 if ''@term_start'' <> ''NULL''
 set @_term_start = ''@term_start''
 
 if ''@term_end'' <> ''NULL''
 set @_term_end = ''@term_end''
 



create table #profile_data
(
profile_id int,[Sub Book] varchar (500),Book varchar (500),Strategy varchar (500),Subsidiary varchar (500)
)
create table #meter_data(meter_data_id int,channel int,term_start datetime,term_end datetime,volume float,location_id int,granularity int
,[Sub Book] varchar (500),Book varchar (500),Strategy varchar (500),Subsidiary varchar (500))

declare @_st varchar(max)

set @_st=''
	insert into #profile_data(profile_id,[Sub Book],Book,Strategy,Subsidiary) select 
	distinct
	fp.profile_id
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''ssbm.logical_name'' else ''null'' end + '' [Sub Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''book.entity_name'' else ''null'' end + '' [Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''stra.entity_name'' else ''null'' end + '' [Strategy]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''sub.entity_name'' else ''null'' end + '' [Subsidiary]
	 from forecast_profile fp
	inner join source_minor_location sml on fp.profile_id=sml.profile_id''
	+case when @_locatin_ids is null then '''' else '' and sml.source_minor_location_id in (''+@_locatin_ids+'')''  end 
	+case when @_profile_ids is null then '''' else '' and fp.profile_id in (''+@_profile_ids+'')''  end
	 
+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' and ''@book_id'' <> ''NULL'' and ''@sub_book_id'' <> ''NULL''  then 
 ''
		left join source_deal_detail sdd on sdd.location_id=sml.source_minor_location_id
		left join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join source_system_book_map ssbm
			ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		left JOIN Portfolio_hierarchy book(NOLOCK)
			ON  ssbm.fas_book_id = book.entity_id
		left JOIN Portfolio_hierarchy stra(NOLOCK)
			ON  book.parent_entity_id = stra.entity_id
		left JOIN Portfolio_hierarchy sub(NOLOCK)
			ON  stra.parent_entity_id = sub.entity_id
		where 1=1'' 
		+case when ''@sub_id'' = ''NULL''  then '''' else  '' AND stra.parent_entity_id IN (@sub_id)'' end
		+case when ''@stra_id'' = ''NULL'' then '''' else '' AND stra.entity_id IN (@stra_id)''  end
		+case when ''@book_id'' = ''NULL'' then '''' else '' AND book.entity_id IN (@book_id)'' end
		+case when ''@sub_book_id'' = ''NULL'' then '''' else '' AND ssbm.book_deal_type_map_id IN (@sub_book_id)'' end
else '''' end



--print @_st
exec(@_st)


set @_st=''
	insert into #meter_data(meter_data_id ,channel,term_start ,term_end ,volume,granularity,location_id,[Sub Book],Book,Strategy,Subsidiary)
	select mv.meter_data_id,mv.channel,mv.from_date,mv.to_date,mv.volume,mi.granularity,smlm.source_minor_location_id 
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''ssbm.logical_name'' else ''null'' end + '' [Sub Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''book.entity_name'' else ''null'' end + '' [Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''stra.entity_name'' else ''null'' end + '' [Strategy]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''sub.entity_name'' else ''null'' end + '' [Subsidiary]
	from meter_id mi 
	inner join mv90_data mv on mv.meter_id=mi.meter_id
	inner join source_minor_location_meter smlm on smlm.meter_id=mv.meter_id
	''
	+case when @_term_start is null then '''' else '' and mv.from_date between ''''''+convert(varchar(10),@_term_start,120) +'''''' and ''''''+convert(varchar(10),isnull(@_term_end,@_term_start),120) +''''''''  end 
	+case when @_meter_ids is null then '''' else '' and mv.meter_id in (''+@_meter_ids+'')''  end 
	+case when @_locatin_ids is null then '''' else '' and smlm.source_minor_location_id in (''+@_locatin_ids+'')''  end 
	+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' and ''@book_id'' <> ''NULL'' and ''@sub_book_id'' <> ''NULL''  then 
 '' 
	left join source_deal_detail sdd on sdd.location_id=smlm.source_minor_location_id
		left join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join source_system_book_map ssbm
			ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		left JOIN Portfolio_hierarchy book(NOLOCK)
			ON  ssbm.fas_book_id = book.entity_id
		left JOIN Portfolio_hierarchy stra(NOLOCK)
			ON  book.parent_entity_id = stra.entity_id
		left JOIN Portfolio_hierarchy sub(NOLOCK)
			ON  stra.parent_entity_id = sub.entity_id
		where 1=1'' 
		+case when ''@sub_id'' = ''NULL''  then '''' else  '' AND stra.parent_entity_id IN (@sub_id)'' end
		+case when ''@stra_id'' = ''NULL'' then '''' else '' AND stra.entity_id IN (@stra_id)''  end
		+case when ''@book_id'' = ''NULL'' then '''' else '' AND book.entity_id IN (@book_id)'' end
		+case when ''@sub_book_id'' = ''NULL'' then '''' else '' AND ssbm.book_deal_type_map_id IN (@sub_book_id)'' end
else '''' end

--print @_st
exec(@_st)

--return

SELECT ddh.term_date,fp.profile_id,[Sub Book],Book,Strategy,Subsidiary
	,ddh.[Hr1]  ,ddh.[Hr2]  ,ddh.[Hr3]  ,ddh.[Hr4]  ,ddh.[Hr5]  ,ddh.[Hr6]  ,ddh.[Hr7]  ,ddh.[Hr8]  
	,ddh.[Hr9]  ,ddh.[Hr10]  ,ddh.[Hr11]  ,ddh.[Hr12]  ,ddh.[Hr13]  ,ddh.[Hr14]  ,ddh.[Hr15]  ,ddh.[Hr16]  
	,ddh.[Hr17]  ,ddh.[Hr18]  ,ddh.[Hr19]  ,ddh.[Hr20]  ,ddh.[Hr21]  ,ddh.[Hr22]  ,ddh.[Hr23]  ,ddh.[Hr24]  ,ddh.[Hr25]
into #profile_data_value
from #profile_data pd 
inner join forecast_profile fp on fp.profile_id=pd.profile_id
inner join deal_detail_hour ddh on ddh.profile_id=fp.profile_id

SELECT mvh.prod_date,0 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_15] hr1  ,mvh.[Hr2_15] hr2 ,mvh.[Hr3_15] hr3 ,mvh.[Hr4_15] hr4 ,mvh.[Hr5_15] hr5 ,mvh.[Hr6_15]  hr6,mvh.[Hr7_15] hr7 ,mvh.[Hr8_15] hr8 
	,mvh.[Hr9_15] hr9,mvh.[Hr10_15]  hr10,mvh.[Hr11_15] hr11 ,mvh.[Hr12_15] hr12 ,mvh.[Hr13_15] hr13 ,mvh.[Hr14_15] Hr14 ,mvh.[Hr15_15] Hr15 ,mvh.[Hr16_15]  Hr16
	,mvh.[Hr17_15] Hr17,mvh.[Hr18_15] Hr18 ,mvh.[Hr19_15]  Hr19,mvh.[Hr20_15] Hr20,mvh.[Hr21_15] Hr21,mvh.[Hr22_15] Hr22,mvh.[Hr23_15] Hr23,mvh.[Hr24_15] Hr24,mvh.[Hr25_15] Hr25
INTO #mv_data
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,15 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_30]  ,mvh.[Hr2_30]  ,mvh.[Hr3_30]  ,mvh.[Hr4_30]  ,mvh.[Hr5_30]  ,mvh.[Hr6_30]  ,mvh.[Hr7_30]  ,mvh.[Hr8_30]  
	,mvh.[Hr9_30]  ,mvh.[Hr10_30]  ,mvh.[Hr11_30]  ,mvh.[Hr12_30]  ,mvh.[Hr13_30]  ,mvh.[Hr14_30]  ,mvh.[Hr15_30]  ,mvh.[Hr16_30]  
	,mvh.[Hr17_30]  ,mvh.[Hr18_30]  ,mvh.[Hr19_30]  ,mvh.[Hr20_30]  ,mvh.[Hr21_30]  ,mvh.[Hr22_30]  ,mvh.[Hr23_30]  ,mvh.[Hr24_30]  ,mvh.[Hr25_30]
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,30 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_45]  ,mvh.[Hr2_45]  ,mvh.[Hr3_45]  ,mvh.[Hr4_45]  ,mvh.[Hr5_45]  ,mvh.[Hr6_45]  ,mvh.[Hr7_45]  ,mvh.[Hr8_45]  
	,mvh.[Hr9_45]  ,mvh.[Hr10_45]  ,mvh.[Hr11_45]  ,mvh.[Hr12_45]  ,mvh.[Hr13_45]  ,mvh.[Hr14_45]  ,mvh.[Hr15_45]  ,mvh.[Hr16_45]  
	,mvh.[Hr17_45]  ,mvh.[Hr18_45]  ,mvh.[Hr19_45]  ,mvh.[Hr20_45]  ,mvh.[Hr21_45]  ,mvh.[Hr22_45]  ,mvh.[Hr23_45]  ,mvh.[Hr24_45]  ,mvh.[Hr25_45]
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,45 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_60]  ,mvh.[Hr2_60]  ,mvh.[Hr3_60]  ,mvh.[Hr4_60]  ,mvh.[Hr5_60]  ,mvh.[Hr6_60]  ,mvh.[Hr7_60]  ,mvh.[Hr8_60]  
	,mvh.[Hr9_60]  ,mvh.[Hr10_60]  ,mvh.[Hr11_60]  ,mvh.[Hr12_60]  ,mvh.[Hr13_60]  ,mvh.[Hr14_60]  ,mvh.[Hr15_60]  ,mvh.[Hr16_60]  
	,mvh.[Hr17_60]  ,mvh.[Hr18_60]  ,mvh.[Hr19_60]  ,mvh.[Hr20_60]  ,mvh.[Hr21_60]  ,mvh.[Hr22_60]  ,mvh.[Hr23_60]  ,mvh.[Hr24_60]  ,mvh.[Hr25_60]
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,0 period,982 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1]  ,mvh.[Hr2]  ,mvh.[Hr3]  ,mvh.[Hr4]  ,mvh.[Hr5]  ,mvh.[Hr6]  ,mvh.[Hr7]  ,mvh.[Hr8]  
	,mvh.[Hr9]  ,mvh.[Hr10]  ,mvh.[Hr11]  ,mvh.[Hr12]  ,mvh.[Hr13]  ,mvh.[Hr14]  ,mvh.[Hr15]  ,mvh.[Hr16]  
	,mvh.[Hr17]  ,mvh.[Hr18]  ,mvh.[Hr19]  ,mvh.[Hr20]  ,mvh.[Hr21]  ,mvh.[Hr22]  ,mvh.[Hr23]  ,mvh.[Hr24]  ,mvh.[Hr25]
FROM #meter_data md 
	LEFT JOIN  mv90_data_hour mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=982
union all
SELECT md.term_start,0 period,982 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,md.volume [Hr1]  ,null [Hr2]  ,null [Hr3]  ,null [Hr4]  ,null [Hr5]  ,null [Hr6]  ,null [Hr7]  ,null [Hr8]  
	,null [Hr9]  ,null [Hr10]  ,null [Hr11]  ,null [Hr12]  ,null [Hr13]  ,null [Hr14]  ,null [Hr15]  ,null [Hr16]  
	,null [Hr17]  ,null [Hr18]  ,null [Hr19]  ,null [Hr20]  ,null [Hr21]  ,null [Hr22]  ,null [Hr23]  ,null [Hr24]  ,null [Hr25]
FROM #meter_data md 
WHERE md.granularity=980


SELECT  term_date,profile_id, hr,0 period ,Volume ,[Sub Book],Book,Strategy,Subsidiary
	into #profile_data_value_unpivot
FROM 
( 
	SELECT  term_date,profile_id,[Sub Book],Book,Strategy,Subsidiary,
	hr25 [25],hr1 [1],hr2 [2],hr3 [3],hr4 [4],hr5 [5],hr6 [6],hr7 [7],hr8 [8],hr9 [9],hr10 [10],hr11 [11],hr12 [12],hr13 [13]
	,hr14 [14],hr15 [15],hr16 [16],hr17 [17],hr18 [18],hr19 [19],hr20 [20],hr21 [21],hr22 [22],hr23 [23],hr24 [24],hr25 [dst_25]
	from #profile_data_value
) Main
UNPIVOT 
( 
	Volume FOR hr IN ([25],[1],[2] ,[3] ,[4] ,[5] ,[6] ,[7] ,[8] ,[9] ,[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24]) 
) v 
		

SELECT prod_date,period,pos_granularity,meter_data_id,channel,hr,volume,[Sub Book],Book,Strategy,Subsidiary
	into #mv_data_unpivot
FROM 
( 
	SELECT  prod_date,period,pos_granularity,meter_data_id,channel,[Sub Book],Book,Strategy,Subsidiary,
	hr25 [25],hr1 [1],hr2 [2],hr3 [3],hr4 [4],hr5 [5],hr6 [6],hr7 [7],hr8 [8],hr9 [9],hr10 [10],hr11 [11],hr12 [12],hr13 [13]
	,hr14 [14],hr15 [15],hr16 [16],hr17 [17],hr18 [18],hr19 [19],hr20 [20],hr21 [21],hr22 [22],hr23 [23],hr24 [24],hr25 [dst_25]
	from #mv_data
) Main
UNPIVOT 
( 
	Volume FOR hr IN ([25],[1],[2] ,[3] ,[4] ,[5] ,[6] ,[7] ,[8] ,[9] ,[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24]) 
) v 
	

select sml.location_name, fp.profile_name, mi.recorderid,sc.counterparty_name,sc.type_of_entity,sml.source_major_location_ID,sdv3.code zone,sdv4.code region
	,sdv5.code country,dt.term,cast(dt.hr as int) hr,dt.period mins,dt.channel,sum(dt.[Meter Volume]) [Meter Volume],	sum(dt.[Profile Volume]) [Profile Volume]
	, @_locatin_ids locatin_ids
	, @_meter_ids meter_ids
	, @_profile_ids profile_ids
	, @_term_start term_start
	, @_term_end term_end
	,1 sub_id
	,1 stra_id
	,1 book_id
	,1 sub_book_id
	,dt.[Sub Book],dt.Book,dt.Strategy,dt.Subsidiary

--[__batch_report__]
from (	

	select sml.source_minor_location_id , p.profile_id,md.meter_data_id,p.term_date Term, p.hr, period,md.channel ,0 [Meter Volume], p.Volume [Profile Volume]
	,p.[Sub Book],p.Book,p.Strategy,p.Subsidiary from	#profile_data_value_unpivot  p 
		left join source_minor_location sml on sml.profile_id=p.profile_id
		left join source_minor_location_meter smlm on smlm.source_minor_location_id=sml.source_minor_location_id
		left join mv90_data md on smlm.meter_id=md.meter_id and p.term_date between md.from_date and md.to_date
	union all	
	select sml.source_minor_location_id ,sml.profile_id,p.meter_data_id, p.prod_date,p.hr,p.period,p.channel,p.volume [Meter Volume],0 [Profile Volume] 
	,p.[Sub Book],p.Book,p.Strategy,p.Subsidiary
	from  #mv_data_unpivot p
	left join mv90_data md on p.meter_data_id=md.meter_data_id
	left join source_minor_location_meter smlm on smlm.meter_id=md.meter_id	
	left join source_minor_location sml on sml.source_minor_location_id=smlm.source_minor_location_id

) dt
left join source_minor_location sml on dt.source_minor_location_id=sml.source_minor_location_id
left join mv90_data md on dt.meter_data_id=md.meter_data_id
left join meter_id mi on mi.meter_id=md.meter_id
left join forecast_profile fp on fp.profile_id=dt.profile_id
left join source_counterparty sc on sc.source_counterparty_id=mi.counterparty_id
left join  static_data_value sdv3 on sdv3.value_id=sml.province
left join  static_data_value sdv4 on sdv4.value_id=sml.region
left join  static_data_value sdv5 on sdv5.value_id=sml.country

where term between @_term_start and @_term_end
	and hr<>25
group by 
	sml.location_name, fp.profile_name, mi.recorderid,sc.counterparty_name
	,sc.type_of_entity,sml.source_major_location_ID,sdv3.code,sdv4.code
	,sdv5.code,dt.term,dt.hr,dt.period,dt.channel
	,dt.[Sub Book],dt.Book,dt.Strategy,dt.Subsidiary', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Standard Actual Forecast View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Standard Actual Forecast View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Standard Actual Forecast View' AS [name], 'AFV' AS ALIAS, '' AS [description],'declare @_locatin_ids varchar(1000)=null
	,@_meter_ids varchar(1000)=null
	,@_profile_ids varchar(1000)=null
	,@_term_start datetime=null
	,@_term_end datetime=null


if ''@locatin_ids'' <> ''NULL''
 set @_locatin_ids = ''@locatin_ids''

if ''@meter_ids'' <> ''NULL''
 set @_meter_ids = ''@meter_ids''
 
 if ''@profile_ids'' <> ''NULL''
 set @_profile_ids = ''@profile_ids''
 
 if ''@term_start'' <> ''NULL''
 set @_term_start = ''@term_start''
 
 if ''@term_end'' <> ''NULL''
 set @_term_end = ''@term_end''
 



create table #profile_data
(
profile_id int,[Sub Book] varchar (500),Book varchar (500),Strategy varchar (500),Subsidiary varchar (500)
)
create table #meter_data(meter_data_id int,channel int,term_start datetime,term_end datetime,volume float,location_id int,granularity int
,[Sub Book] varchar (500),Book varchar (500),Strategy varchar (500),Subsidiary varchar (500))

declare @_st varchar(max)

set @_st=''
	insert into #profile_data(profile_id,[Sub Book],Book,Strategy,Subsidiary) select 
	distinct
	fp.profile_id
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''ssbm.logical_name'' else ''null'' end + '' [Sub Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''book.entity_name'' else ''null'' end + '' [Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''stra.entity_name'' else ''null'' end + '' [Strategy]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''sub.entity_name'' else ''null'' end + '' [Subsidiary]
	 from forecast_profile fp
	inner join source_minor_location sml on fp.profile_id=sml.profile_id''
	+case when @_locatin_ids is null then '''' else '' and sml.source_minor_location_id in (''+@_locatin_ids+'')''  end 
	+case when @_profile_ids is null then '''' else '' and fp.profile_id in (''+@_profile_ids+'')''  end
	 
+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' and ''@book_id'' <> ''NULL'' and ''@sub_book_id'' <> ''NULL''  then 
 ''
		left join source_deal_detail sdd on sdd.location_id=sml.source_minor_location_id
		left join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join source_system_book_map ssbm
			ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		left JOIN Portfolio_hierarchy book(NOLOCK)
			ON  ssbm.fas_book_id = book.entity_id
		left JOIN Portfolio_hierarchy stra(NOLOCK)
			ON  book.parent_entity_id = stra.entity_id
		left JOIN Portfolio_hierarchy sub(NOLOCK)
			ON  stra.parent_entity_id = sub.entity_id
		where 1=1'' 
		+case when ''@sub_id'' = ''NULL''  then '''' else  '' AND stra.parent_entity_id IN (@sub_id)'' end
		+case when ''@stra_id'' = ''NULL'' then '''' else '' AND stra.entity_id IN (@stra_id)''  end
		+case when ''@book_id'' = ''NULL'' then '''' else '' AND book.entity_id IN (@book_id)'' end
		+case when ''@sub_book_id'' = ''NULL'' then '''' else '' AND ssbm.book_deal_type_map_id IN (@sub_book_id)'' end
else '''' end



--print @_st
exec(@_st)


set @_st=''
	insert into #meter_data(meter_data_id ,channel,term_start ,term_end ,volume,granularity,location_id,[Sub Book],Book,Strategy,Subsidiary)
	select mv.meter_data_id,mv.channel,mv.from_date,mv.to_date,mv.volume,mi.granularity,smlm.source_minor_location_id 
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''ssbm.logical_name'' else ''null'' end + '' [Sub Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''book.entity_name'' else ''null'' end + '' [Book]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''stra.entity_name'' else ''null'' end + '' [Strategy]
	,''+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' or ''@book_id'' <> ''NULL'' or ''@sub_book_id'' <> ''NULL'' then ''sub.entity_name'' else ''null'' end + '' [Subsidiary]
	from meter_id mi 
	inner join mv90_data mv on mv.meter_id=mi.meter_id
	inner join source_minor_location_meter smlm on smlm.meter_id=mv.meter_id
	''
	+case when @_term_start is null then '''' else '' and mv.from_date between ''''''+convert(varchar(10),@_term_start,120) +'''''' and ''''''+convert(varchar(10),isnull(@_term_end,@_term_start),120) +''''''''  end 
	+case when @_meter_ids is null then '''' else '' and mv.meter_id in (''+@_meter_ids+'')''  end 
	+case when @_locatin_ids is null then '''' else '' and smlm.source_minor_location_id in (''+@_locatin_ids+'')''  end 
	+case when ''@sub_id'' <> ''NULL'' or ''@stra_id'' <> ''NULL'' and ''@book_id'' <> ''NULL'' and ''@sub_book_id'' <> ''NULL''  then 
 '' 
	left join source_deal_detail sdd on sdd.location_id=smlm.source_minor_location_id
		left join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join source_system_book_map ssbm
			ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		left JOIN Portfolio_hierarchy book(NOLOCK)
			ON  ssbm.fas_book_id = book.entity_id
		left JOIN Portfolio_hierarchy stra(NOLOCK)
			ON  book.parent_entity_id = stra.entity_id
		left JOIN Portfolio_hierarchy sub(NOLOCK)
			ON  stra.parent_entity_id = sub.entity_id
		where 1=1'' 
		+case when ''@sub_id'' = ''NULL''  then '''' else  '' AND stra.parent_entity_id IN (@sub_id)'' end
		+case when ''@stra_id'' = ''NULL'' then '''' else '' AND stra.entity_id IN (@stra_id)''  end
		+case when ''@book_id'' = ''NULL'' then '''' else '' AND book.entity_id IN (@book_id)'' end
		+case when ''@sub_book_id'' = ''NULL'' then '''' else '' AND ssbm.book_deal_type_map_id IN (@sub_book_id)'' end
else '''' end

--print @_st
exec(@_st)

--return

SELECT ddh.term_date,fp.profile_id,[Sub Book],Book,Strategy,Subsidiary
	,ddh.[Hr1]  ,ddh.[Hr2]  ,ddh.[Hr3]  ,ddh.[Hr4]  ,ddh.[Hr5]  ,ddh.[Hr6]  ,ddh.[Hr7]  ,ddh.[Hr8]  
	,ddh.[Hr9]  ,ddh.[Hr10]  ,ddh.[Hr11]  ,ddh.[Hr12]  ,ddh.[Hr13]  ,ddh.[Hr14]  ,ddh.[Hr15]  ,ddh.[Hr16]  
	,ddh.[Hr17]  ,ddh.[Hr18]  ,ddh.[Hr19]  ,ddh.[Hr20]  ,ddh.[Hr21]  ,ddh.[Hr22]  ,ddh.[Hr23]  ,ddh.[Hr24]  ,ddh.[Hr25]
into #profile_data_value
from #profile_data pd 
inner join forecast_profile fp on fp.profile_id=pd.profile_id
inner join deal_detail_hour ddh on ddh.profile_id=fp.profile_id

SELECT mvh.prod_date,0 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_15] hr1  ,mvh.[Hr2_15] hr2 ,mvh.[Hr3_15] hr3 ,mvh.[Hr4_15] hr4 ,mvh.[Hr5_15] hr5 ,mvh.[Hr6_15]  hr6,mvh.[Hr7_15] hr7 ,mvh.[Hr8_15] hr8 
	,mvh.[Hr9_15] hr9,mvh.[Hr10_15]  hr10,mvh.[Hr11_15] hr11 ,mvh.[Hr12_15] hr12 ,mvh.[Hr13_15] hr13 ,mvh.[Hr14_15] Hr14 ,mvh.[Hr15_15] Hr15 ,mvh.[Hr16_15]  Hr16
	,mvh.[Hr17_15] Hr17,mvh.[Hr18_15] Hr18 ,mvh.[Hr19_15]  Hr19,mvh.[Hr20_15] Hr20,mvh.[Hr21_15] Hr21,mvh.[Hr22_15] Hr22,mvh.[Hr23_15] Hr23,mvh.[Hr24_15] Hr24,mvh.[Hr25_15] Hr25
INTO #mv_data
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,15 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_30]  ,mvh.[Hr2_30]  ,mvh.[Hr3_30]  ,mvh.[Hr4_30]  ,mvh.[Hr5_30]  ,mvh.[Hr6_30]  ,mvh.[Hr7_30]  ,mvh.[Hr8_30]  
	,mvh.[Hr9_30]  ,mvh.[Hr10_30]  ,mvh.[Hr11_30]  ,mvh.[Hr12_30]  ,mvh.[Hr13_30]  ,mvh.[Hr14_30]  ,mvh.[Hr15_30]  ,mvh.[Hr16_30]  
	,mvh.[Hr17_30]  ,mvh.[Hr18_30]  ,mvh.[Hr19_30]  ,mvh.[Hr20_30]  ,mvh.[Hr21_30]  ,mvh.[Hr22_30]  ,mvh.[Hr23_30]  ,mvh.[Hr24_30]  ,mvh.[Hr25_30]
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,30 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_45]  ,mvh.[Hr2_45]  ,mvh.[Hr3_45]  ,mvh.[Hr4_45]  ,mvh.[Hr5_45]  ,mvh.[Hr6_45]  ,mvh.[Hr7_45]  ,mvh.[Hr8_45]  
	,mvh.[Hr9_45]  ,mvh.[Hr10_45]  ,mvh.[Hr11_45]  ,mvh.[Hr12_45]  ,mvh.[Hr13_45]  ,mvh.[Hr14_45]  ,mvh.[Hr15_45]  ,mvh.[Hr16_45]  
	,mvh.[Hr17_45]  ,mvh.[Hr18_45]  ,mvh.[Hr19_45]  ,mvh.[Hr20_45]  ,mvh.[Hr21_45]  ,mvh.[Hr22_45]  ,mvh.[Hr23_45]  ,mvh.[Hr24_45]  ,mvh.[Hr25_45]
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,45 period,987 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1_60]  ,mvh.[Hr2_60]  ,mvh.[Hr3_60]  ,mvh.[Hr4_60]  ,mvh.[Hr5_60]  ,mvh.[Hr6_60]  ,mvh.[Hr7_60]  ,mvh.[Hr8_60]  
	,mvh.[Hr9_60]  ,mvh.[Hr10_60]  ,mvh.[Hr11_60]  ,mvh.[Hr12_60]  ,mvh.[Hr13_60]  ,mvh.[Hr14_60]  ,mvh.[Hr15_60]  ,mvh.[Hr16_60]  
	,mvh.[Hr17_60]  ,mvh.[Hr18_60]  ,mvh.[Hr19_60]  ,mvh.[Hr20_60]  ,mvh.[Hr21_60]  ,mvh.[Hr22_60]  ,mvh.[Hr23_60]  ,mvh.[Hr24_60]  ,mvh.[Hr25_60]
FROM #meter_data md 
	LEFT JOIN  mv90_data_mins mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=987
union all
SELECT mvh.prod_date,0 period,982 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,mvh.[Hr1]  ,mvh.[Hr2]  ,mvh.[Hr3]  ,mvh.[Hr4]  ,mvh.[Hr5]  ,mvh.[Hr6]  ,mvh.[Hr7]  ,mvh.[Hr8]  
	,mvh.[Hr9]  ,mvh.[Hr10]  ,mvh.[Hr11]  ,mvh.[Hr12]  ,mvh.[Hr13]  ,mvh.[Hr14]  ,mvh.[Hr15]  ,mvh.[Hr16]  
	,mvh.[Hr17]  ,mvh.[Hr18]  ,mvh.[Hr19]  ,mvh.[Hr20]  ,mvh.[Hr21]  ,mvh.[Hr22]  ,mvh.[Hr23]  ,mvh.[Hr24]  ,mvh.[Hr25]
FROM #meter_data md 
	LEFT JOIN  mv90_data_hour mvh ON md.meter_data_id=mvh.meter_data_id
	and 	mvh.prod_date between md.term_start and md.term_end		
WHERE md.granularity=982
union all
SELECT md.term_start,0 period,982 pos_granularity,md.meter_data_id,md.channel,md.[Sub Book],md.Book,md.Strategy,md.Subsidiary
	,md.volume [Hr1]  ,null [Hr2]  ,null [Hr3]  ,null [Hr4]  ,null [Hr5]  ,null [Hr6]  ,null [Hr7]  ,null [Hr8]  
	,null [Hr9]  ,null [Hr10]  ,null [Hr11]  ,null [Hr12]  ,null [Hr13]  ,null [Hr14]  ,null [Hr15]  ,null [Hr16]  
	,null [Hr17]  ,null [Hr18]  ,null [Hr19]  ,null [Hr20]  ,null [Hr21]  ,null [Hr22]  ,null [Hr23]  ,null [Hr24]  ,null [Hr25]
FROM #meter_data md 
WHERE md.granularity=980


SELECT  term_date,profile_id, hr,0 period ,Volume ,[Sub Book],Book,Strategy,Subsidiary
	into #profile_data_value_unpivot
FROM 
( 
	SELECT  term_date,profile_id,[Sub Book],Book,Strategy,Subsidiary,
	hr25 [25],hr1 [1],hr2 [2],hr3 [3],hr4 [4],hr5 [5],hr6 [6],hr7 [7],hr8 [8],hr9 [9],hr10 [10],hr11 [11],hr12 [12],hr13 [13]
	,hr14 [14],hr15 [15],hr16 [16],hr17 [17],hr18 [18],hr19 [19],hr20 [20],hr21 [21],hr22 [22],hr23 [23],hr24 [24],hr25 [dst_25]
	from #profile_data_value
) Main
UNPIVOT 
( 
	Volume FOR hr IN ([25],[1],[2] ,[3] ,[4] ,[5] ,[6] ,[7] ,[8] ,[9] ,[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24]) 
) v 
		

SELECT prod_date,period,pos_granularity,meter_data_id,channel,hr,volume,[Sub Book],Book,Strategy,Subsidiary
	into #mv_data_unpivot
FROM 
( 
	SELECT  prod_date,period,pos_granularity,meter_data_id,channel,[Sub Book],Book,Strategy,Subsidiary,
	hr25 [25],hr1 [1],hr2 [2],hr3 [3],hr4 [4],hr5 [5],hr6 [6],hr7 [7],hr8 [8],hr9 [9],hr10 [10],hr11 [11],hr12 [12],hr13 [13]
	,hr14 [14],hr15 [15],hr16 [16],hr17 [17],hr18 [18],hr19 [19],hr20 [20],hr21 [21],hr22 [22],hr23 [23],hr24 [24],hr25 [dst_25]
	from #mv_data
) Main
UNPIVOT 
( 
	Volume FOR hr IN ([25],[1],[2] ,[3] ,[4] ,[5] ,[6] ,[7] ,[8] ,[9] ,[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24]) 
) v 
	

select sml.location_name, fp.profile_name, mi.recorderid,sc.counterparty_name,sc.type_of_entity,sml.source_major_location_ID,sdv3.code zone,sdv4.code region
	,sdv5.code country,dt.term,cast(dt.hr as int) hr,dt.period mins,dt.channel,sum(dt.[Meter Volume]) [Meter Volume],	sum(dt.[Profile Volume]) [Profile Volume]
	, @_locatin_ids locatin_ids
	, @_meter_ids meter_ids
	, @_profile_ids profile_ids
	, @_term_start term_start
	, @_term_end term_end
	,1 sub_id
	,1 stra_id
	,1 book_id
	,1 sub_book_id
	,dt.[Sub Book],dt.Book,dt.Strategy,dt.Subsidiary

--[__batch_report__]
from (	

	select sml.source_minor_location_id , p.profile_id,md.meter_data_id,p.term_date Term, p.hr, period,md.channel ,0 [Meter Volume], p.Volume [Profile Volume]
	,p.[Sub Book],p.Book,p.Strategy,p.Subsidiary from	#profile_data_value_unpivot  p 
		left join source_minor_location sml on sml.profile_id=p.profile_id
		left join source_minor_location_meter smlm on smlm.source_minor_location_id=sml.source_minor_location_id
		left join mv90_data md on smlm.meter_id=md.meter_id and p.term_date between md.from_date and md.to_date
	union all	
	select sml.source_minor_location_id ,sml.profile_id,p.meter_data_id, p.prod_date,p.hr,p.period,p.channel,p.volume [Meter Volume],0 [Profile Volume] 
	,p.[Sub Book],p.Book,p.Strategy,p.Subsidiary
	from  #mv_data_unpivot p
	left join mv90_data md on p.meter_data_id=md.meter_data_id
	left join source_minor_location_meter smlm on smlm.meter_id=md.meter_id	
	left join source_minor_location sml on sml.source_minor_location_id=smlm.source_minor_location_id

) dt
left join source_minor_location sml on dt.source_minor_location_id=sml.source_minor_location_id
left join mv90_data md on dt.meter_data_id=md.meter_data_id
left join meter_id mi on mi.meter_id=md.meter_id
left join forecast_profile fp on fp.profile_id=dt.profile_id
left join source_counterparty sc on sc.source_counterparty_id=mi.counterparty_id
left join  static_data_value sdv3 on sdv3.value_id=sml.province
left join  static_data_value sdv4 on sdv4.value_id=sml.region
left join  static_data_value sdv5 on sdv5.value_id=sml.country

where term between @_term_start and @_term_end
	and hr<>25
group by 
	sml.location_name, fp.profile_name, mi.recorderid,sc.counterparty_name
	,sc.type_of_entity,sml.source_major_location_ID,sdv3.code,sdv4.code
	,sdv5.code,dt.term,dt.hr,dt.period,dt.channel
	,dt.[Sub Book],dt.Book,dt.Strategy,dt.Subsidiary' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'Book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'Book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'channel'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Channel'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'channel'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'channel' AS [name], 'Channel' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'hr'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hr'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'hr'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hr' AS [name], 'Hr' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'locatin_ids'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Locatin ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'locatin_ids'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'locatin_ids' AS [name], 'Locatin ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'location_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'location_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_name' AS [name], 'Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'Meter Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Meter Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'Meter Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Meter Volume' AS [name], 'Meter Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'meter_ids'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Meter ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'meter_ids'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'meter_ids' AS [name], 'Meter ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'mins'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Mins'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'mins'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'mins' AS [name], 'Mins' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'Profile Volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Profile Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'Profile Volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Profile Volume' AS [name], 'Profile Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'profile_ids'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Profile ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'profile_ids'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'profile_ids' AS [name], 'Profile ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'profile_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Profile'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'profile_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'profile_name' AS [name], 'Profile' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'recorderid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Meter'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'recorderid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'recorderid' AS [name], 'Meter' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'source_major_location_ID'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Major Location Id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'source_major_location_ID'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_major_location_ID' AS [name], 'Major Location Id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'Strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'Strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'Sub Book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'Sub Book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Sub Book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'Subsidiary'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'Subsidiary'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Subsidiary' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'term'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'term'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term' AS [name], 'Term' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'type_of_entity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Type Of Entity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'type_of_entity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'type_of_entity' AS [name], 'Type Of Entity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Standard Actual Forecast View'
	            AND dsc.name =  'zone'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Zone'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Standard Actual Forecast View'
			AND dsc.name =  'zone'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'zone' AS [name], 'Zone' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Standard Actual Forecast View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Standard Actual Forecast View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	
COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	