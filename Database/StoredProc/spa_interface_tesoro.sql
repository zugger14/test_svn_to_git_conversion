
 IF OBJECT_ID('spa_interface_tesoro') IS NOT NULL
 DROP PROC spa_interface_tesoro 
  GO

  /**
	Used to generate report for Tesoro CSV Export.
	
	Parameters
	@flag : Not in use
	@as_of_date : As Of Date
	@sub : Subsidiary of book structure
	@str : Stratigy of book structure
	@book : Book Of book structure
	@term_start : Term Start
	@term_end : Term End
	@pipeline_id : Source Counterparty id from source_counterparty table.
	@location_id : Location Id from source_deal_detail table.
	@header_deal_id : Source Deal Header Id from source_deal_header table.
	@contract_id : Contract Id from source_deal_header table.
  */
  
 CREATE PROC [dbo].[spa_interface_tesoro]
	@flag varchar(1)='s' -- EDI export;
	,@as_of_date datetime=null 
	,@sub varchar(1000)=null 
	,@str varchar(1000)=null
	,@book 	varchar(1000) =null
	,@term_start datetime ='2015-09-01'
	,@term_end datetime	 ='2015-09-01'
	,@pipeline_id int	=	5197	--QPC_GAT
	,@location_id INT =NULL
	,@header_deal_id INT =NULL
	,@contract_id INT =NULL
	As

 /*

declare
@flag varchar(1)='s',  -- EDI export;
@as_of_date datetime=null 
	,@sub varchar(1000)=null 
	,@str varchar(1000)=null
	,@book 	varchar(1000) =null
	,@term_start datetime ='2016-03-11'
	,@term_end datetime	 ='2016-03-11'
	,@pipeline_id int	=	5197	--QPC_GAT
	,@location_id INT =null
	,@header_deal_id INT =null
	,@contract_id INT =NULL
	 
  --SELECT * FROM dbo.source_counterparty WHERE counterparty_id ='QPC_GAT'
 --*/

IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL DROP TABLE #tmp_deals
IF OBJECT_ID(N'tempdb..#books') IS NOT NULL DROP TABLE #books
IF OBJECT_ID(N'tempdb..#thread_deals') IS NOT NULL DROP TABLE #thread_deals
IF OBJECT_ID(N'tempdb..#unthread_deals') IS NOT NULL DROP TABLE #unthread_deals
IF OBJECT_ID(N'tempdb..#imb_deals') IS NOT NULL DROP TABLE #imb_deals
IF OBJECT_ID(N'tempdb..#imb_deals_sum') IS NOT NULL DROP TABLE #imb_deals_sum

IF OBJECT_ID(N'tempdb..#thead_info') IS NOT NULL DROP TABLE #thead_info
IF OBJECT_ID(N'tempdb..#unthead_info') IS NOT NULL DROP TABLE #unthead_info

declare @DUNS_shipper varchar(30) ,@DUNS_pipeline   varchar(30)


set @as_of_date=isnull(@as_of_date,getdate())

declare @threaded_book_id int, @threaded_received_book_id int , @threaded_delivered_book_id int,@st varchar(max) ,@column_list varchar(max)


DECLARE  @sdv_from_deal	INT,@sdv_priority INT,@sdv_to_deal int,@path_id int	 ,@deal_type_id int,@sdv_facilator int
select @deal_type_id=source_deal_type_id from source_deal_type where deal_type_id='Transportation'
		
SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

SELECT @sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'To Deal'

SELECT @sdv_priority=value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Priority'



declare @yymmdd	 varchar(6),
	@hhmm varchar(4),
	@ssmcs varchar(9),
	@yyyymmdd  varchar(8),
	@yyyymmddhhmm  varchar(12) ,
	@from_term varchar(8),
	@to_term varchar(8)

	
select @yymmdd= right(cast(datepart(year, @as_of_date) as varchar),2)+right('0'+cast(datepart(month, @as_of_date) as varchar),2)+right('0'+cast(datepart(day, @as_of_date) as varchar),2) 
	,@hhmm=right('0'+cast(datepart(hour, @as_of_date) as varchar),2)+right('0'+cast(datepart(minute, @as_of_date) as varchar),2) 
	,@ssmcs=right('00000'+cast(datepart(second, @as_of_date) as varchar),6)+right('000'+cast(datepart(minute, @as_of_date) as varchar),3)  
	,@yyyymmdd=cast(datepart(year, @as_of_date) as varchar)+right('0'+cast(datepart(month, @as_of_date) as varchar),2)+right('0'+cast(datepart(day, @as_of_date) as varchar),2) 
	,@yyyymmddhhmm=cast(datepart(year, @as_of_date) as varchar)+right('0'+cast(datepart(month, @as_of_date) as varchar),2)+right('0'+cast(datepart(day, @as_of_date) as varchar),2) 
		+right('0'+cast(datepart(hour, @as_of_date) as varchar),2)+right('0'+cast(datepart(minute, @as_of_date) as varchar),2) 


select @DUNS_shipper=sc.customer_duns_number  from fas_subsidiaries s inner join source_counterparty sc 
	on   s.counterparty_id=sc.source_counterparty_id and s.fas_subsidiary_id=-1

select @DUNS_pipeline=sc.customer_duns_number  from  source_counterparty sc where sc.source_counterparty_id=@pipeline_id


create table #books
( 
	sub_book_id  int,source_system_book_id1 int,source_system_book_id2 int,source_system_book_id3 int,source_system_book_id4  int
)

SET @st='
insert into #books
 ( 
	sub_book_id ,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4  
)
SELECT  book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
FROM source_system_book_map sbm            
	INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
	INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id
WHERE 1=1 '
	+CASE WHEN  @sub IS NULL THEN '' ELSE ' AND stra.parent_entity_id in ('+@sub+')' END
	+CASE WHEN  @str IS NULL THEN '' ELSE ' AND stra.entity_id in ('+@str+')' END
	+CASE WHEN  @book IS NULL THEN '' ELSE ' AND book.entity_id in ('+@book+')' END	

--print(@st)		
EXEC(@st)


IF OBJECT_ID(N'tempdb..#Tesoro_dn_pool') IS NOT NULL DROP TABLE #Tesoro_dn_pool
CREATE TABLE #Tesoro_dn_pool (location_id varchar(100) COLLATE DATABASE_DEFAULT, [source_contract_id] varchar(100) COLLATE DATABASE_DEFAULT, [rec_del] varchar(1) COLLATE DATABASE_DEFAULT, [pool] varchar(100) COLLATE DATABASE_DEFAULT)

insert into #Tesoro_dn_pool(location_id, [source_contract_id], [rec_del],[pool])
select v.clm1_value, v.clm2_value, v.clm3_value, v.clm4_value
from generic_mapping_values v 
inner join generic_mapping_header h on h.mapping_table_id = v.mapping_table_id
where h.mapping_name = 'Tesoro Mapping'
/*
select '293', '163','D', 'K163 VERM'
union all
select '293', '2051','D', 'K2051 CAN CR'
union all
select '72', '163','D', 'K163 PINE'
union all
select '72', '2091','D', 'K2091 PINE'
union all
select '72', '4485','D', 'K4485 CH BUT'
union all
select '247', '163','D', 'K163 MOXA'
union all
select '247', '2091','D', 'K2091 PINE'
union all
select '247', '683','D', 'K683 BIRCH'
union all
select '306', '163','D', 'K163 PINE'
union all
select '306', '2091','D', 'K2091 PINE'
union all
select '306', '2091','R', 'K2091 PINE'
*/

--Two maps have hard-coded contracts. Change here if contract change in the future. Enter NULL if current logic as for other locations to be used.
DECLARE @MAP_2008_CONTRACT VARCHAR(10)
DECLARE @MAP_3089_CONTRACT VARCHAR(10)
DECLARE @MAP_0267_CONTRACT VARCHAR(10)

set @MAP_2008_CONTRACT = 'EQUITY'
set @MAP_0267_CONTRACT = 'EQUITY'
set @MAP_3089_CONTRACT = '274'

create table  #tmp_deals
(
 source_deal_header_id int ,priority_code varchar(10) COLLATE DATABASE_DEFAULT,
 contract_id int ,counterparty_id int,to_deal_id int, from_Deal_id int
)

--select * from #uddf_value where source_Deal_header_id=407607	   --
IF OBJECT_ID(N'tempdb..#uddf_value') IS NOT NULL
	 DROP TABLE #uddf_value
IF OBJECT_ID(N'tempdb..#uddf_value_from') IS NOT NULL
	 DROP TABLE #uddf_value_from
IF OBJECT_ID(N'tempdb..#uddf_value_temp') IS NOT NULL
	 DROP TABLE #uddf_value_temp
IF OBJECT_ID(N'tempdb..#uddf_value_from_temp') IS NOT NULL
	 DROP TABLE #uddf_value_from_temp

SELECT DISTINCT source_deal_header_id source_deal_header_id_to ,udf_value  as source_deal_header_id
INTO #uddf_value_temp  
FROM user_defined_deal_fields uddf INNER JOIN [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id
AND uddft.field_id =@sdv_from_deal --293418
WHERE udf_value IN(SELECT CAST(source_deal_header_id AS VARCHAR) FROm source_deal_header)

SELECT source_deal_header_id_to, CAST(source_deal_header_id AS INT) source_deal_header_id INTO #uddf_value FROM #uddf_value_temp

SELECT DISTINCT source_deal_header_id source_deal_header_id ,udf_value  as source_deal_header_id_FROM
INTO #uddf_value_from_temp 
FROM user_defined_deal_fields uddf INNER JOIN [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id
AND uddft.field_id =@sdv_from_deal --293419

SELECT source_deal_header_id, CAST(source_deal_header_id_from AS INT) source_deal_header_id_from INTO #uddf_value_from FROM #uddf_value_from_temp
--select * from #uddf_value_from where source_Deal_header_id = 407672
--select * from #uddf_value where source_Deal_header_id = 407672


CREATE INDEX IX_1 ON #uddf_value(source_deal_header_id_to,source_deal_header_id)
CREATE INDEX IX_1 ON #uddf_value_from(source_deal_header_id,source_deal_header_id_from)

--select * from #imb_deals where ideal = 412552
--uday
select sdd.leg, od.source_deal_header_id [ideal], od.transport_deal_id, od.source_deal_detail_id,
	sum(CASE WHEN sdd.leg=2 then -1 else 1 end *volume_used) [IMB_Vol] 
INTO #imb_deals
from source_deal_header sdh inner join source_deal_detail  sdd on 
	sdh.source_deal_header_id  = sdd.source_deal_header_id  
	inner join source_minor_location sml on sml.source_minor_location_id=sdd.location_id
	inner join optimizer_detail  od  on od.transport_deal_id=sdh.source_Deal_header_id and od.up_down_stream='u' --case when sdd.leg=2 then 'u' else 'd' end
where  source_deal_type_id=57 and sml.source_major_location_id=13 and sdd.term_start=@term_start
group by od.source_deal_header_id, od.transport_deal_id, od.source_deal_detail_id, sdd.leg


--select source_deal_detail_id, apply_transport_deal_id, sum(IMB_Vol) IMB_Vol
--into #imb_deals_sum 
--from #imb_deals group by source_deal_detail_id, apply_transport_deal_id
----end uday


--select * from #imb_deals_sum

 --select @sdv_to_deal, @sdv_from_deal
SET @st='
insert into  #tmp_deals
(
 source_deal_header_id  ,priority_code ,
 contract_id  ,counterparty_id ,to_deal_id, from_deal_id 
)
SELECT DISTINCT sdh.source_deal_header_id,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end priority_code,
 sdh.contract_id ,sdh.counterparty_id ,to_deal.to_deal_id, from_deal.from_deal_id	  

FROM  #books sbmp   
inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
  AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
  AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
  AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
  AND  sdh.counterparty_id='+cast(@pipeline_id as varchar)+'
  and sdh.source_deal_type_id='+cast( @deal_type_id as varchar)+'
 INNER JOIN 
 (
	 SELECT DISTINCT source_deal_header_id from dbo.source_deal_detail ' 
	 
	 +case when @location_id is null then '' else ' WHERE  location_id=' + cast(@location_id as varchar) end +
	 '
) sdd   ON sdh.source_deal_header_id=sdd.source_deal_header_id
inner join contract_group cg on cg.contract_id =sdh.contract_id  and cg.is_active = ''y'' 
	 and   cg.pipeline ='+case when @contract_id is null then  '5197'  else ' cg.pipeline' end+'
outer apply
( 
	 select top(1) uv.source_deal_header_id_to  to_deal_id    
	 FROM #uddf_value uv
	 WHERE source_deal_header_id = sdh.source_deal_header_id

) to_deal
outer apply
( 
	 select top(1) uvf.source_deal_header_id_from  from_deal_id    
	 FROM #uddf_value_from uvf
	 WHERE source_deal_header_id = sdh.source_deal_header_id

) from_deal
WHERE 1=1  
 '+case when @header_deal_id is null then '' else ' and  sdh.source_deal_header_id='+cast(@header_deal_id as varchar) end +'
 '+case when  @contract_id is null then '' else ' and  sdh.contract_id='+cast( @contract_id as varchar) end

 --print @st
 exec(@st)
 
--select * from #uddf_value_from where source_Deal_header_id = 407672

 insert into  #tmp_deals
(
 source_deal_header_id  ,priority_code ,
 contract_id  ,counterparty_id ,to_deal_id, from_deal_id 
)
SELECT sdh.source_deal_header_id,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end priority_code,
 sdh.contract_id ,sdh.counterparty_id ,to_deal.to_deal_id, from_deal.from_deal_id	  

FROM  #books sbmp   
inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
  AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
  AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
  AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
  AND  sdh.counterparty_id=5197
  and sdh.source_deal_type_id=57
 INNER JOIN 
 (
	 SELECT DISTINCT source_deal_header_id from dbo.source_deal_detail 
) sdd   ON sdh.source_deal_header_id=sdd.source_deal_header_id
inner join contract_group cg on cg.contract_id =sdh.contract_id  and cg.is_active = 'y' 
	 and   cg.pipeline =5197
outer apply
( 
	 select top(1) uv.source_deal_header_id_to  to_deal_id    
	 FROM #uddf_value uv
	 WHERE source_deal_header_id = sdh.source_deal_header_id

) to_deal
outer apply
( 
	 select top(1) uvf.source_deal_header_id_from  from_deal_id    
	 FROM #uddf_value_from uvf
	 WHERE source_deal_header_id = sdh.source_deal_header_id

) from_deal
WHERE 1=1  and sdh.contract_id = isnull(@contract_id, sdh.contract_id) and sdh.source_deal_header_id = isnull(@header_deal_id, sdh.source_deal_header_id) 

 --return

 --select * from contract_group 

--select * from #tmp_deals where source_deal_header_id = 407672
--return
	--select * from source_minor_location where location_name like '%mesa mm%'
	--select * from #tmp_final_data where source_deal_header_id = 412552
	--select * from source_major_location

--update contract_group set source_contract_id = '163' where contract_id = 2559

if OBJECT_ID('tempdb..#tmp_final_data') is not null
	drop table #tmp_final_data
	
select  DISTINCT 
	--sdh2.counterparty_id,
	--od.transport_deal_id,sdh1.source_deal_header_id cg1x, sdh2.source_deal_header_id cg2x,
	--sdh3.source_deal_header_id,
	--cg3.source_contract_id,
	od.source_deal_header_id, 
	od.transport_deal_id,
	sdd.source_deal_detail_id, 
	sdd.term_start BEGIN_DATE,
	sdd.term_start END_DATE,
	CASE WHEN sdd.Leg=1 THEN 'R' ELSE 'D' END  REC_DEL,
	f.facilator FACILITY,
	CASE WHEN ISNUMERIC(cg.source_contract_id)=1 then ISNULL('GTH'+RIGHT('00000'+cg.source_contract_id,5),'N/A') ELSE cg.source_contract_id END  [CONTRACT],	
	CASE WHEN (sdd.Leg=1 AND sml_1.source_major_location_id=8) THEN  ISNULL(tes_del.tesoro_del, te1.tsp_location)  
		 WHEN (sdd.Leg=2 AND sml.source_major_location_id=8) THEN  te1.tsp_location  
		 WHEN (sdd.Leg=1) THEN  te1.tsp_location 
			ELSE CASE WHEN ISNUMERIC(sml.location_id)=1 THEN 'MAP_'+RIGHT('0000'+sml.location_id,4) ELSE sml.location_id END END  STATION,	
	--te1.tsp_location STATION,	
	--uday
	--cast(sdd.deal_volume AS NUMERIC(15,0))  VOL, 
	isnull(cast(od.volume_used AS NUMERIC(15,0)),cast(sdd.deal_volume as numeric(15,0))) --+ isnull(imbds.IMB_VOL, 0) 
	VOL,
	--end uday
	CASE WHEN sdd.Leg=1 AND sml_1.source_major_location_id <> 8 THEN 'Equity' else coalesce(cg1.source_contract_id,cg2.source_contract_id,cg3.source_contract_id) end UP_DN_CONTRACT,
	'MFS' UP_DN_PARTY,
	t.priority_code [PRIORITY],
	ISNULL(@DUNS_shipper,'7939069') PRODUCER,
	coalesce(tdp.[pool],te.tesoro)  [POOL],
	t.source_deal_header_id PACKAGE_ID ,t.contract_id,
	case when sdd.leg = 1 then sml_1.location_id else sml.location_id end [location_id],
	case when sdd.leg = 1 then sml_1.Location_Name else sml.location_name end [location_name],
	--uday
	case when sdd.leg = 1 then sml_1.source_major_location_id else sml.source_major_location_id end [location_type_id],
	case	when (case when sdd.leg = 1 then sml_1.source_major_location_id else sml.source_major_location_id end) = 4
			and isnull(sdh2.counterparty_id, -1) = 5197 then 1 else 0 end remove_duplicate
	--end uday
	into #tmp_final_data
FROM (SELECT DISTINCT * FROM #tmp_deals) t inner join source_deal_detail sdd  
	on t.source_deal_header_id=sdd.source_deal_header_id and sdd.term_start BETWEEN @term_start AND @term_end
left join contract_group cg on cg.contract_id=t.contract_id
outer apply
(	
	select top(1) mi.recorderid FROM source_minor_location_meter smlm 
	INNER JOIN dbo.meter_id	mi ON mi.meter_id=smlm.meter_id
		AND smlm.meter_type= 38602 	   --38603		Delivery; 38602		Receipt
		and smlm.effective_date<=sdd.term_start 	
		AND smlm.source_minor_location_id=sdd.location_id AND sdd.Leg=1
	order by  smlm.effective_date desc
) mtr
LEFT JOIN source_minor_location sml	ON sml.source_minor_location_id=sdd.location_id	AND sdd.Leg=2
LEFT JOIN source_minor_location sml_1 ON sml_1.source_minor_location_id=sdd.location_id AND sdd.Leg=1		  
outer apply
(
     SELECT a.static_data_udf_values facilator FROM  application_ui_template_fields atf 
	 INNER JOIN application_ui_template_definition atd ON atd.application_ui_field_id = atf.application_ui_field_id
	 INNER JOIN maintain_udf_static_data_detail_values a ON a.application_field_id = atf.application_field_id
				and  a.primary_field_object_id=sdd.location_id
	 INNER JOIN user_defined_fields_template udft ON udft.Field_label =  atd.default_label
	WHERE  udft.Field_id = -5683 --'Tesoro Facility ID'
)  f
outer apply
(
     SELECT a.static_data_udf_values tesoro FROM  application_ui_template_fields atf 
	 INNER JOIN application_ui_template_definition atd ON atd.application_ui_field_id = atf.application_ui_field_id
	 INNER JOIN maintain_udf_static_data_detail_values a ON a.application_field_id = atf.application_field_id
				and  a.primary_field_object_id=sdd.location_id
	 INNER JOIN user_defined_fields_template udft ON udft.Field_label =  atd.default_label
	WHERE  udft.Field_id = -5684		--'Tesoro GSI Group'
)  te
left join #Tesoro_dn_pool tdp on tdp.location_id =case when sdd.leg =1  then  sml_1.location_id else sml.location_id end and tdp.[source_contract_id] = cg.[contract_name]
	and tdp.rec_del=case when sdd.leg =1  then 'R' else 'D' end
outer apply
(
     SELECT a.static_data_udf_values tsp_location FROM  application_ui_template_fields atf 
	 INNER JOIN application_ui_template_definition atd ON atd.application_ui_field_id = atf.application_ui_field_id
	 INNER JOIN maintain_udf_static_data_detail_values a ON a.application_field_id = atf.application_field_id
				and  a.primary_field_object_id=sdd.location_id 
	 INNER JOIN user_defined_fields_template udft ON udft.Field_label =  atd.default_label
	WHERE  udft.Field_id = -5682		--'%TSP Location%'
)  te1

outer apply
(
     SELECT a.static_data_udf_values tesoro_del FROM  application_ui_template_fields atf 
	 INNER JOIN application_ui_template_definition atd ON atd.application_ui_field_id = atf.application_ui_field_id
	 INNER JOIN maintain_udf_static_data_detail_values a ON a.application_field_id = atf.application_field_id
				and  a.primary_field_object_id=  sdd.location_id 
	 INNER JOIN user_defined_fields_template udft ON udft.Field_label =  atd.default_label
	WHERE  udft.Field_id = -5689		--'%Facility%'
)  tes_del
LEFT JOIN dbo.source_deal_header sdh1 ON sdh1.source_deal_header_id=t.to_deal_id
left join contract_group cg1 on cg1.contract_id=sdh1.contract_id
left join optimizer_detail od on od.source_deal_detail_id=sdd.source_deal_detail_id and od.flow_date=@term_start
LEFT JOIN dbo.source_deal_header sdh2 ON sdh2.source_deal_header_id=od.transport_deal_id
left join contract_group cg2 on cg2.contract_id=sdh2.contract_id

--uday
LEFT JOIN dbo.source_deal_header sdh3 ON sdh3.source_deal_header_id=t.from_deal_id
left join contract_group cg3 on cg3.contract_id=sdh3.contract_id
--left join #imb_deals imbd ON imbd.source_deal_detail_id = sdd.source_deal_detail_id
--left join #imb_deals_sum imbds ON imbds.source_deal_detail_id = sdd.source_deal_detail_id 
--		--AND imbds.apply_transport_deal_id = od.transport_deal_id
WHERE sdd.source_deal_detail_id not in 
	(select d.source_deal_detail_id from source_deal_detail d inner join 
		#imb_deals i on i.transport_deal_id = d.source_deal_header_id and d.leg=1 and i.leg=2) 
	
--end uday

--select * from optimizer_detail where flow_date = '2016-02-02'
--select * from #tmp_final_data
--select * from #imb_deals
----return

--select * from #tmp_final_data where source_ed

 --select * from #tmp_deals where source_deal_header_Id=407672
--return
--GTH02051
--GTH04485
--GTH02091
--GTH00163
--GTH00683
 
   --select * from #tmp_final_data where vol<0
--   select * from #tmp_final_data where station='MAP_3089'
--/*
--DECLARE @MAP_2008_CONTRACT VARCHAR(10)
--DECLARE @MAP_3089_CONTRACT VARCHAR(10)

--set @MAP_2008_CONTRACT = 'EQUITY' 
--set @MAP_3089_CONTRACT = '274'

 SELECT		Begin_date,end_date,rec_del,f.facility, f.CONTRACT
			, case	WHEN (f.location_type_id = 13) and rec_del= 'd' THEN 'MAP_9998'
				when (f.location_type_id = 13) and rec_del = 'r' THEN '099998'
					when ISNUMERIC(f.STATION) = 1 and LEN(f.STATION) < 6 then RIGHT('000000' + CAST(f.STATION AS varchar(5)), 6)
					else f.STATION
			  end STATION
			--, f.STATION
			, sum(f.VOL) VOL,
			CASE	WHEN (f.location_type_id = 13) THEN 'PAYBACK'
					WHEN (f.STATION = 'MAP_2008') THEN isnull(@MAP_2008_CONTRACT , UP_DN_CONTRACT) 
					WHEN (f.STATION = 'MAP_3089') THEN isnull(@MAP_3089_CONTRACT , UP_DN_CONTRACT)
					WHEN (f.STATION = 'MAP_0267') THEN isnull(@MAP_0267_CONTRACT , UP_DN_CONTRACT)
			ELSE UP_DN_CONTRACT END	UP_DN_CONTRACT,
			UP_DN_PARTY,
			Max(PRIORITY) PRIORITY,Producer,POOL
			--,max(PACKAGE_ID) PACKAGE--we need one column with zero afer pool
			,0 PACKAGE--we need one column with zero afer pool
			, f.contract_id

 from #tmp_final_data f --where contract='GTH02051'
 where f.remove_duplicate <> 1
 group by Begin_date,end_date,rec_del,f.STATION ,f.CONTRACT,f.contract_id,f.FACILITY,UP_DN_CONTRACT,UP_DN_PARTY,POOL,REC_DEL,PRODUCER, f.location_type_id
 --*/

 



