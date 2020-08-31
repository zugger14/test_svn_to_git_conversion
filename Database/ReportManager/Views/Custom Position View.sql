BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Custom Position View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'CPV', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE
 @_as_of_date varchar(20)=null,
 @_period_from varchar(6)=null,
 @_period_to varchar(6)=null,
 @_commodity_id varchar(8)=null,
 @_physical_financial_flag varchar(6)=null,
 @_term_start varchar(20)=null,
 @_term_end varchar(20)=null,
 @_source_deal_header_id VARCHAR(MAX)=null,
 @_dst_column VARCHAR(MAX),
 @_vol_multiplier VARCHAR(MAX),
 @_rhpb VARCHAR(MAX),
 @_rhpb1 VARCHAR(MAX) ,
 @_rhpb2 VARCHAR(MAX),
 @_sqry varchar(MAX) ,
 @_sqry1  VARCHAR(MAX),
 @_remain_month VARCHAR(MAX),
 @_baseload_block_type VARCHAR(10),
 @_baseload_block_define_id VARCHAR(10)



set @_as_of_date = nullif(  isnull(@_as_of_date,nullif(''@as_of_date'', replace(''@_as_of_date'',''@_'',''@''))),''null'')
set @_period_from = nullif(  isnull(@_period_from,nullif(''@period_from'', replace(''@_period_from'',''@_'',''@''))),''null'')
set @_period_to = nullif(  isnull(@_period_to,nullif(''@period_to'', replace(''@_period_to'',''@_'',''@''))),''null'')
set @_commodity_id = nullif(  isnull(@_commodity_id,nullif(''@commodity_id'', replace(''@_commodity_id'',''@_'',''@''))),''null'')
set @_physical_financial_flag = nullif(  isnull(@_physical_financial_flag,nullif(''@physical_financial_flag'', replace(''@_physical_financial_flag'',''@_'',''@''))),''null'')
set @_term_start = nullif(  isnull(@_term_start,nullif(''@term_start'', replace(''@_term_start'',''@_'',''@''))),''null'')
set @_term_end = nullif(  isnull(@_term_end,nullif(''@term_end'', replace(''@_term_end'',''@_'',''@''))),''null'')
set @_source_deal_header_id = nullif(  isnull(@_source_deal_header_id,nullif(''@source_deal_header_id'', replace(''@_source_deal_header_id'',''@_'',''@''))),''null'')



if object_id(''tempdb..#term_date'') is not null drop table #term_date
if object_id(''tempdb..#books'') is not null drop table #books

--SET @_as_of_date =''1900''
--SET @_period_from =''1900''
--SET @_period_to =''1900''
--SET @_commodity_id =''1900''
--SET @_term_start =''1900''
--SET @_term_end =''1900''
--SET @_physical_financial_flag =''1900''
--SET @_source_deal_header_id =''1900''

--SET @_source_deal_header_id = ''4''

DECLARE @_term_start_temp datetime,@_term_END_temp datetime  


IF nullif(@_period_from,''1900'') IS NOT NULL  
BEGIN   
	SET  @_term_start_temp= dbo.FNAGetTermStartDate(''m'', convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01'', cast(@_period_from as int))
END  


IF nullif(@_period_to,''1900'') IS NOT NULL  
BEGIN  

	SET  @_term_END_temp = dbo.FNAGetTermStartDate(''m'',convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01'', cast(@_period_to as int)+1)
	set @_term_END_temp=dateadd(DAY,-1,@_term_END_temp)
	
END  


SET @_term_start=convert(varchar(20),isnull(@_term_start_temp ,@_term_start),120)
SET @_term_end=convert(varchar(20),isnull(@_term_END_temp ,@_term_end),120)


IF @_term_start IS NOT NULL AND @_term_END IS NULL              
	SET @_term_END = @_term_start   
	           
IF @_term_start IS NULL AND @_term_END IS NOT NULL              
	SET @_term_start = @_term_END       	  


SELECT sub.[entity_id] sub_id,
       stra.[entity_id] stra_id,
       book.[entity_id] book_id,
       sub.[entity_name] sub_name,
       stra.[entity_name] stra_name,
       book.[entity_name] book_name,
       ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4,
       ssbm.logical_name,
       ssbm.fas_deal_type_value_id,
       ssbm.book_deal_type_map_id [sub_book_id],
	   ssbm.sub_book_group1,
	   ssbm.sub_book_group2,
	   ssbm.sub_book_group3,
	   ssbm.sub_book_group4
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub(NOLOCK) ON  stra.parent_entity_id = sub.[entity_id]
INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.[entity_id]
AND (''@sub_id'' = ''NULL'' OR sub.[entity_id] IN (@sub_id)) 
AND (''@stra_id'' = ''NULL'' OR stra.[entity_id] IN (@stra_id)) 
AND (''@book_id'' = ''NULL'' OR book.[entity_id] IN (@book_id))
AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))	
    


create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)



SET @_sqry =''
insert into #term_date(block_define_id  ,term_date,term_start,term_end,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
		select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
			hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
			,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
			,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
		FROM (
				select distinct isnull(spcd.block_define_id,nullif(''''''+@_baseload_block_define_id+'''''',''''NULL'''')) block_define_id,s.term_start,s.term_end 
				from report_hourly_position_breakdown s  (nolock)  INNER JOIN #books bk ON 
		 			 bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
		 			AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
					'' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' and s.source_deal_header_id IN ('' +CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END +''
		 				left JOIN source_price_curve_def spcd with (nolock) 
		 				ON spcd.source_curve_def_id=s.curve_id 
				WHERE 1=1 ''
				+CASE WHEN @_term_start IS NOT NULL THEN '' AND s.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND s.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  +
				+CASE WHEN @_as_of_date IS NOT NULL THEN '' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  +''
				) a
				outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
				and term_date between a.term_start  and a.term_end --and term_date>@_as_of_date
		) hb

''

EXEC(@_sqry)

	create index indxterm_dat on #term_date(block_define_id  ,term_start,term_end)


	SET @_baseload_block_type = ''12000''	-- Internal Static Data
	SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE ''Base Load'' -- External Static Data

	
IF @_baseload_block_define_id IS NULL 
	SET @_baseload_block_define_id = ''NULL''
	

	SET @_dst_column = ''cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))''  
	SET @_remain_month =''*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''''+@_as_of_date+'''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''''+@_as_of_date+'''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)''
		
	SET @_vol_multiplier=''/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))''
		

	SET @_rhpb=''select ''''''+isnull(@_as_of_date,'''')+'''''' as_of_date,#books.sub_id sub_id,#books.stra_id stra_id,#books.book_id book_id,#books.sub_book_id sub_book_id,#books.sub_name sub,#books.stra_name strategy,#books.book_name book,#books.logical_name sub_book,
		CASE WHEN s.physical_financial_flag = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial'''' END physical_financial_flag,s.commodity_id,sc.commodity_name commodity,''+isnull(@_period_from,''null'') +'' period_from,''+isnull(@_period_to,''null'')+'' period_to,
		s.term_start term_start,s.term_start term_end,s.source_deal_header_id
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr1
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr2
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr3
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr4
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr5
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr6
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr7
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr8
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr9
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr10
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr11
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr12
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr13''
		
	SET @_rhpb1= '',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr14
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr15
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr16
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr17
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr18
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr19
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr20
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr21
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr22
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr23
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr24''
		
	SET @_rhpb2= ''
			FROM 
			report_hourly_position_breakdown s 			 
			INNER JOIN #books ON s.source_system_book_id1 = #books.source_system_book_id1
					AND s.source_system_book_id2 = #books.source_system_book_id2
					AND s.source_system_book_id3 = #books.source_system_book_id3
					AND s.source_system_book_id4 = #books.source_system_book_id4
			'' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' and s.source_deal_header_id IN ('' +CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END +
			'' INNER JOIN source_commodity sc ON sc.source_commodity_id=s.commodity_id 
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'')	and  hbt.block_type=COALESCE(spcd.block_type,''+@_baseload_block_type+'') and hbt.term_date between s.term_start  and s.term_END ) term_hrs
			outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
			where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'')	and  hbt.block_type=COALESCE(spcd.block_type,''+@_baseload_block_type+'') and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
			left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,''+@_baseload_block_define_id+'') and hb.term_start = s.term_start
			and hb.term_end=s.term_end  --and hb.term_date>'''''' + @_as_of_date +''''''
			outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
			outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>''''''+@_as_of_date+'''''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  ''
		   +'' where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>''''''+@_as_of_date+'''''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		    AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 )) ''	
				+CASE WHEN @_term_start IS NOT NULL THEN '' AND s.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND s.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  
				+CASE WHEN @_commodity_id IS NOT NULL THEN '' AND s.commodity_id IN(''+@_commodity_id+'')'' ELSE '''' END
				+CASE WHEN @_as_of_date IS NOT NULL THEN '' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  
				+CASE WHEN @_physical_financial_flag <>''b'' THEN '' AND s.physical_financial_flag=''''''+@_physical_financial_flag+'''''''' ELSE '''' END 
				+CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' AND s.source_deal_header_id=''''''+@_source_deal_header_id+'''''''' ELSE '''' END 
	           

SET @_sqry= ''
SELECT 
	as_of_date,
	sub_id,
	stra_id,
	book_id,
	sub_book_id,
	sub,
	strategy,
	book,
	sub_book,
	physical_financial_flag,
	commodity_id,
	commodity,
	period_from,
	period_to,
	term_start,
	term_end,
	source_deal_header_id,
	CAST(REPLACE(unpvt.Hours,''''HR'''','''''''') AS INT) [Hour],
	unpvt.volume
	--[__batch_report__]
	FROM 	
		(SELECT 
				''''''+isnull(@_as_of_date,'''')+'''''' as_of_date,
					#books.sub_id sub_id,
					#books.stra_id stra_id,
					#books.book_id book_id,
					#books.sub_book_id sub_book_id,
					#books.sub_name sub,
					#books.stra_name strategy,
					#books.book_name book,					
					#books.logical_name sub_book,
					CASE WHEN vw.physical_financial_flag = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial'''' END physical_financial_flag,
					vw.commodity_id,
					sc.commodity_name commodity,''
					+isnull(@_period_from,''null'') +'' period_from,''
					+isnull(@_period_to,''null'')+'' period_to,
					vw.term_start term_start,
					vw.term_start term_end,
					vw.source_deal_header_id,
					[HR1],[HR2],[HR3],[HR4],[HR5],[HR6],[HR7],[HR8],[HR9],[HR10],[HR11],[HR12],[HR13],[HR14],[HR15],[HR16],[HR17],[HR18],[HR19],[HR20],[HR21],[HR22],[HR23],[HR24]
			FROM 
				report_hourly_position_deal vw
				INNER JOIN #books ON vw.source_system_book_id1 = #books.source_system_book_id1
					AND vw.source_system_book_id2 = #books.source_system_book_id2
					AND vw.source_system_book_id3 = #books.source_system_book_id3
					AND vw.source_system_book_id4 = #books.source_system_book_id4
				INNER JOIN source_commodity sc ON sc.source_commodity_id=vw.commodity_id 
			WHERE 1=1 ''
				+CASE WHEN @_term_start IS NOT NULL THEN '' AND vw.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND vw.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  
				+CASE WHEN @_commodity_id IS NOT NULL THEN '' AND vw.commodity_id IN(''+@_commodity_id+'')'' ELSE '''' END
				+CASE WHEN @_as_of_date IS NOT NULL THEN '' AND vw.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  
				+CASE WHEN @_physical_financial_flag <>''b'' THEN '' AND vw.physical_financial_flag=''''''+@_physical_financial_flag+'''''''' ELSE '''' END +
				+CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' AND vw.source_deal_header_id=''''''+@_source_deal_header_id+'''''''' ELSE '''' END +''
			
			UNION ALL '' 
	
		
SET @_sqry1 = 
		  ''	)  p
			UNPIVOT
				(Volume for Hours IN
					([HR1],[HR2],[HR3],[HR4],[HR5],[HR6],[HR7],[HR8],[HR9],[HR10],[HR11],[HR12],[HR13],[HR14],[HR15],[HR16],[HR17],[HR18],[HR19],[HR20],[HR21],[HR22],[HR23],[HR24])
			) AS unpvt

WHERE 1=1 '' 



EXEC(@_sqry+@_rhpb+@_rhpb1+@_rhpb2+@_sqry1)



', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Custom Position View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Custom Position View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Custom Position View' AS [name], 'CPV' AS ALIAS, '' AS [description],'DECLARE
 @_as_of_date varchar(20)=null,
 @_period_from varchar(6)=null,
 @_period_to varchar(6)=null,
 @_commodity_id varchar(8)=null,
 @_physical_financial_flag varchar(6)=null,
 @_term_start varchar(20)=null,
 @_term_end varchar(20)=null,
 @_source_deal_header_id VARCHAR(MAX)=null,
 @_dst_column VARCHAR(MAX),
 @_vol_multiplier VARCHAR(MAX),
 @_rhpb VARCHAR(MAX),
 @_rhpb1 VARCHAR(MAX) ,
 @_rhpb2 VARCHAR(MAX),
 @_sqry varchar(MAX) ,
 @_sqry1  VARCHAR(MAX),
 @_remain_month VARCHAR(MAX),
 @_baseload_block_type VARCHAR(10),
 @_baseload_block_define_id VARCHAR(10)



set @_as_of_date = nullif(  isnull(@_as_of_date,nullif(''@as_of_date'', replace(''@_as_of_date'',''@_'',''@''))),''null'')
set @_period_from = nullif(  isnull(@_period_from,nullif(''@period_from'', replace(''@_period_from'',''@_'',''@''))),''null'')
set @_period_to = nullif(  isnull(@_period_to,nullif(''@period_to'', replace(''@_period_to'',''@_'',''@''))),''null'')
set @_commodity_id = nullif(  isnull(@_commodity_id,nullif(''@commodity_id'', replace(''@_commodity_id'',''@_'',''@''))),''null'')
set @_physical_financial_flag = nullif(  isnull(@_physical_financial_flag,nullif(''@physical_financial_flag'', replace(''@_physical_financial_flag'',''@_'',''@''))),''null'')
set @_term_start = nullif(  isnull(@_term_start,nullif(''@term_start'', replace(''@_term_start'',''@_'',''@''))),''null'')
set @_term_end = nullif(  isnull(@_term_end,nullif(''@term_end'', replace(''@_term_end'',''@_'',''@''))),''null'')
set @_source_deal_header_id = nullif(  isnull(@_source_deal_header_id,nullif(''@source_deal_header_id'', replace(''@_source_deal_header_id'',''@_'',''@''))),''null'')



if object_id(''tempdb..#term_date'') is not null drop table #term_date
if object_id(''tempdb..#books'') is not null drop table #books

--SET @_as_of_date =''1900''
--SET @_period_from =''1900''
--SET @_period_to =''1900''
--SET @_commodity_id =''1900''
--SET @_term_start =''1900''
--SET @_term_end =''1900''
--SET @_physical_financial_flag =''1900''
--SET @_source_deal_header_id =''1900''

--SET @_source_deal_header_id = ''4''

DECLARE @_term_start_temp datetime,@_term_END_temp datetime  


IF nullif(@_period_from,''1900'') IS NOT NULL  
BEGIN   
	SET  @_term_start_temp= dbo.FNAGetTermStartDate(''m'', convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01'', cast(@_period_from as int))
END  


IF nullif(@_period_to,''1900'') IS NOT NULL  
BEGIN  

	SET  @_term_END_temp = dbo.FNAGetTermStartDate(''m'',convert(varchar(8),isnull(@_term_start,@_as_of_date),120)+''01'', cast(@_period_to as int)+1)
	set @_term_END_temp=dateadd(DAY,-1,@_term_END_temp)
	
END  


SET @_term_start=convert(varchar(20),isnull(@_term_start_temp ,@_term_start),120)
SET @_term_end=convert(varchar(20),isnull(@_term_END_temp ,@_term_end),120)


IF @_term_start IS NOT NULL AND @_term_END IS NULL              
	SET @_term_END = @_term_start   
	           
IF @_term_start IS NULL AND @_term_END IS NOT NULL              
	SET @_term_start = @_term_END       	  


SELECT sub.[entity_id] sub_id,
       stra.[entity_id] stra_id,
       book.[entity_id] book_id,
       sub.[entity_name] sub_name,
       stra.[entity_name] stra_name,
       book.[entity_name] book_name,
       ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4,
       ssbm.logical_name,
       ssbm.fas_deal_type_value_id,
       ssbm.book_deal_type_map_id [sub_book_id],
	   ssbm.sub_book_group1,
	   ssbm.sub_book_group2,
	   ssbm.sub_book_group3,
	   ssbm.sub_book_group4
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub(NOLOCK) ON  stra.parent_entity_id = sub.[entity_id]
INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.[entity_id]
AND (''@sub_id'' = ''NULL'' OR sub.[entity_id] IN (@sub_id)) 
AND (''@stra_id'' = ''NULL'' OR stra.[entity_id] IN (@stra_id)) 
AND (''@book_id'' = ''NULL'' OR book.[entity_id] IN (@book_id))
AND (''@sub_book_id'' = ''NULL'' OR ssbm.book_deal_type_map_id IN (@sub_book_id))	
    


create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)



SET @_sqry =''
insert into #term_date(block_define_id  ,term_date,term_start,term_end,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
		select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
			hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
			,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
			,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
		FROM (
				select distinct isnull(spcd.block_define_id,nullif(''''''+@_baseload_block_define_id+'''''',''''NULL'''')) block_define_id,s.term_start,s.term_end 
				from report_hourly_position_breakdown s  (nolock)  INNER JOIN #books bk ON 
		 			 bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
		 			AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
					'' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' and s.source_deal_header_id IN ('' +CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END +''
		 				left JOIN source_price_curve_def spcd with (nolock) 
		 				ON spcd.source_curve_def_id=s.curve_id 
				WHERE 1=1 ''
				+CASE WHEN @_term_start IS NOT NULL THEN '' AND s.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND s.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  +
				+CASE WHEN @_as_of_date IS NOT NULL THEN '' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  +''
				) a
				outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
				and term_date between a.term_start  and a.term_end --and term_date>@_as_of_date
		) hb

''

EXEC(@_sqry)

	create index indxterm_dat on #term_date(block_define_id  ,term_start,term_end)


	SET @_baseload_block_type = ''12000''	-- Internal Static Data
	SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE ''Base Load'' -- External Static Data

	
IF @_baseload_block_define_id IS NULL 
	SET @_baseload_block_define_id = ''NULL''
	

	SET @_dst_column = ''cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))''  
	SET @_remain_month =''*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,''''''+@_as_of_date+'''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,''''''+@_as_of_date+'''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)''
		
	SET @_vol_multiplier=''/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))''
		

	SET @_rhpb=''select ''''''+isnull(@_as_of_date,'''')+'''''' as_of_date,#books.sub_id sub_id,#books.stra_id stra_id,#books.book_id book_id,#books.sub_book_id sub_book_id,#books.sub_name sub,#books.stra_name strategy,#books.book_name book,#books.logical_name sub_book,
		CASE WHEN s.physical_financial_flag = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial'''' END physical_financial_flag,s.commodity_id,sc.commodity_name commodity,''+isnull(@_period_from,''null'') +'' period_from,''+isnull(@_period_to,''null'')+'' period_to,
		s.term_start term_start,s.term_start term_end,s.source_deal_header_id
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr1
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr2
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr3
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr4
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr5
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr6
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr7
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr8
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr9
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr10
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr11
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr12
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr13''
		
	SET @_rhpb1= '',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr14
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr15
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr16
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr17
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr18
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr19
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr20
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr21
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr22
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr23
		,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))''+ @_vol_multiplier +@_remain_month+''  AS Hr24''
		
	SET @_rhpb2= ''
			FROM 
			report_hourly_position_breakdown s 			 
			INNER JOIN #books ON s.source_system_book_id1 = #books.source_system_book_id1
					AND s.source_system_book_id2 = #books.source_system_book_id2
					AND s.source_system_book_id3 = #books.source_system_book_id3
					AND s.source_system_book_id4 = #books.source_system_book_id4
			'' +CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' and s.source_deal_header_id IN ('' +CAST(@_source_deal_header_id AS VARCHAR) + '')'' ELSE '''' END +
			'' INNER JOIN source_commodity sc ON sc.source_commodity_id=s.commodity_id 
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'')	and  hbt.block_type=COALESCE(spcd.block_type,''+@_baseload_block_type+'') and hbt.term_date between s.term_start  and s.term_END ) term_hrs
			outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
			where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,''+@_baseload_block_define_id+'')	and  hbt.block_type=COALESCE(spcd.block_type,''+@_baseload_block_type+'') and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
			left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,''+@_baseload_block_define_id+'') and hb.term_start = s.term_start
			and hb.term_end=s.term_end  --and hb.term_date>'''''' + @_as_of_date +''''''
			outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
			outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>''''''+@_as_of_date+'''''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
					AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
					AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  ''
		   +'' where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>''''''+@_as_of_date+'''''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		    AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 )) ''	
				+CASE WHEN @_term_start IS NOT NULL THEN '' AND s.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND s.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  
				+CASE WHEN @_commodity_id IS NOT NULL THEN '' AND s.commodity_id IN(''+@_commodity_id+'')'' ELSE '''' END
				+CASE WHEN @_as_of_date IS NOT NULL THEN '' AND s.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  
				+CASE WHEN @_physical_financial_flag <>''b'' THEN '' AND s.physical_financial_flag=''''''+@_physical_financial_flag+'''''''' ELSE '''' END 
				+CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' AND s.source_deal_header_id=''''''+@_source_deal_header_id+'''''''' ELSE '''' END 
	           

SET @_sqry= ''
SELECT 
	as_of_date,
	sub_id,
	stra_id,
	book_id,
	sub_book_id,
	sub,
	strategy,
	book,
	sub_book,
	physical_financial_flag,
	commodity_id,
	commodity,
	period_from,
	period_to,
	term_start,
	term_end,
	source_deal_header_id,
	CAST(REPLACE(unpvt.Hours,''''HR'''','''''''') AS INT) [Hour],
	unpvt.volume
	--[__batch_report__]
	FROM 	
		(SELECT 
				''''''+isnull(@_as_of_date,'''')+'''''' as_of_date,
					#books.sub_id sub_id,
					#books.stra_id stra_id,
					#books.book_id book_id,
					#books.sub_book_id sub_book_id,
					#books.sub_name sub,
					#books.stra_name strategy,
					#books.book_name book,					
					#books.logical_name sub_book,
					CASE WHEN vw.physical_financial_flag = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial'''' END physical_financial_flag,
					vw.commodity_id,
					sc.commodity_name commodity,''
					+isnull(@_period_from,''null'') +'' period_from,''
					+isnull(@_period_to,''null'')+'' period_to,
					vw.term_start term_start,
					vw.term_start term_end,
					vw.source_deal_header_id,
					[HR1],[HR2],[HR3],[HR4],[HR5],[HR6],[HR7],[HR8],[HR9],[HR10],[HR11],[HR12],[HR13],[HR14],[HR15],[HR16],[HR17],[HR18],[HR19],[HR20],[HR21],[HR22],[HR23],[HR24]
			FROM 
				report_hourly_position_deal vw
				INNER JOIN #books ON vw.source_system_book_id1 = #books.source_system_book_id1
					AND vw.source_system_book_id2 = #books.source_system_book_id2
					AND vw.source_system_book_id3 = #books.source_system_book_id3
					AND vw.source_system_book_id4 = #books.source_system_book_id4
				INNER JOIN source_commodity sc ON sc.source_commodity_id=vw.commodity_id 
			WHERE 1=1 ''
				+CASE WHEN @_term_start IS NOT NULL THEN '' AND vw.term_start>=''''''+CAST(@_term_start AS VARCHAR)+'''''' AND vw.term_start<=''''''+CAST(@_term_END AS VARCHAR)+'''''''' ELSE '''' END  
				+CASE WHEN @_commodity_id IS NOT NULL THEN '' AND vw.commodity_id IN(''+@_commodity_id+'')'' ELSE '''' END
				+CASE WHEN @_as_of_date IS NOT NULL THEN '' AND vw.term_start>''''''+@_as_of_date+'''''''' ELSE '''' END  
				+CASE WHEN @_physical_financial_flag <>''b'' THEN '' AND vw.physical_financial_flag=''''''+@_physical_financial_flag+'''''''' ELSE '''' END +
				+CASE WHEN @_source_deal_header_id IS NOT NULL THEN '' AND vw.source_deal_header_id=''''''+@_source_deal_header_id+'''''''' ELSE '''' END +''
			
			UNION ALL '' 
	
		
SET @_sqry1 = 
		  ''	)  p
			UNPIVOT
				(Volume for Hours IN
					([HR1],[HR2],[HR3],[HR4],[HR5],[HR6],[HR7],[HR8],[HR9],[HR10],[HR11],[HR12],[HR13],[HR14],[HR15],[HR16],[HR17],[HR18],[HR19],[HR20],[HR21],[HR22],[HR23],[HR24])
			) AS unpvt

WHERE 1=1 '' 



EXEC(@_sqry+@_rhpb+@_rhpb1+@_rhpb2+@_sqry1)



' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'Hour'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hour'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'Hour'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Hour' AS [name], 'Hour' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'sub'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume' AS [name], 'Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'select sc.source_commodity_id value,sc.commodity_name label from source_commodity sc order by sc.commodity_name', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'select sc.source_commodity_id value,sc.commodity_name label from source_commodity sc order by sc.commodity_name' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period From'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'Period From' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period To'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'Period To' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical Financial'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''p'',''Physical''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'',''Financial''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical Financial' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''p'',''Physical''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'',''Financial''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
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
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Custom Position View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Custom Position View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Custom Position View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Custom Position View'
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
	