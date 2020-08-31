

 IF OBJECT_ID('spa_interface_edi') IS NOT NULL
 DROP PROC spa_interface_edi 
GO
  
 CREATE PROC [dbo].[spa_interface_edi]
	@flag varchar(1)='s',  -- s=EDI export;c=edi schedule
	@as_of_date datetime=null 
	,@sub varchar(1000)=null 
	,@str varchar(1000)=null
	,@book 	varchar(1000) =null
	,@term_start datetime ='2016-02-01'
	,@term_end datetime	 ='2016-02-01'
	,@from_partner int=null
	,@to_partner int  =5197	--QPC_GAT
	,@location_id INT =NULL
	,@header_deal_ids varchar(1000) ='413729'
	,@contract_id VARCHAR(1000) =null
	, @process_id varchar(150)=null
	
As

 /*

--select * from contract_group
DECLARE
	@flag VARCHAR(1)
	 ,@as_of_date datetime=null 
	,@sub varchar(1000)=null 
	,@str varchar(1000)=null
	,@book 	varchar(1000) =null
	,@term_start datetime ='2016-02-11'
	,@term_end datetime	 ='2016-02-11'
  	,@from_partner int=5234 --
	,@to_partner int  =5198	--5198:QPC_TRAN    5197:QPC_GAT
	,@location_id INT =NULL
	,@header_deal_ids varchar(1000) = null--'413729' --'69693,69688'89996,92011
	,@contract_id VARCHAR(1000) =null --'3564'
,@process_id varchar(100)
	   drop table #delta_unthead_dw
	   drop table #delta_unthead_us
	   
	select @flag ='s',  -- s=EDI export;c=edi schedule
	@as_of_date =null 
	,@sub =null 
	,@str =null
	,@book =null
	,@term_start ='2016-05-04'
	,@term_end 	='2016-05-04'
	,@from_partner =5197
	,@to_partner   =5198	--QPC_GAT
	,@location_id  =NULL
	,@header_deal_ids  =null
	,@contract_id  =null
	,@process_id=null   
	   
	   
	




/*

select sum(cast(deal_volume as numeric)) as a,sum(cast(leg_2_deal_volume as numeric)) as b from #thead_info where udf_tran_type=01 and leg_2_tsp_location=245615
	select sum(cast(deal_volume as numeric)),us_dw from #unthead_info 
	where udf_tran_type=06 group by us_dw


	select sum(cast(deal_volume as numeric)), header_contract_id from #unthead_info where us_dw='us' group by header_contract_id
	select sum(cast(deal_volume as numeric)) , header_contract_id from #thead_info group by header_contract_id

	select sum(cast(deal_volume as numeric)), header_contract_id from #unthead_info where us_dw='dw' group by header_contract_id



	select * from #unthread_deals

select * from #thead_info ut right join 
 optimizer_detail ti on ti.transport_deal_id=ut.source_deal_header_id  where ut.udf_tran_type='01' and   up_down_stream='D'
	----select * from optimizer_detail
	*/
	-- ui1 join #unthead_info ui2
	--on cast(ui1.source_deal_header_id as numeric)=-cast(ui2.source_deal_header_id as numeric) and ui1.contract_steam=ui2.contract_steam
	--and ui1.contract_steam='DT' where ui1.deal_volume<>ui2.deal_volume
	

	
	   
	   
	 --UPDATE dbo.source_deal_header SET contract_id=5578 WHERE source_deal_header_id=92014
	-- select * from #unthead_info where header_contract_id=3563 and leg_2_tsp_location='245615'
	-- select * from source_counterparty where counterparty_id='ANR' header_Contract_id=3563 and unthread_tsp_location='245615' and unthread_type='D'

	--select * from #thead_info--  where leg_2_tsp_location='162382' and leg_1_loc_rank=130
	--select * from #unthead_info_pre where unthread_tsp_location='162382' and unthread_type='D' and unthread_location_rank=130

	
	--select sum(cast(deal_volume as float)) from #thead_info_pre  where leg_2_tsp_location='162382' and leg_1_loc_rank=130
	--select sum(cast(deal_volume as float)) from #unthead_info_pre where unthread_tsp_location='162382' and unthread_type='D' and unthread_location_rank=130

  --SELECT * FROM dbo.source_counterparty WHERE counterparty_name like '%questar%'
  --*/
set nocount on
BEGIN TRY
IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL DROP TABLE #tmp_deals
IF OBJECT_ID(N'tempdb..#books') IS NOT NULL DROP TABLE #books
IF OBJECT_ID(N'tempdb..#thread_deals') IS NOT NULL DROP TABLE #thread_deals
IF OBJECT_ID(N'tempdb..#unthread_deals') IS NOT NULL DROP TABLE #unthread_deals

IF OBJECT_ID(N'tempdb..#thead_info') IS NOT NULL DROP TABLE #thead_info
IF OBJECT_ID(N'tempdb..#unthead_info') IS NOT NULL DROP TABLE #unthead_info

IF OBJECT_ID(N'tempdb..#bcp_status') IS NOT NULL DROP TABLE #bcp_status
if object_id('tempdb..#list_contract') is not NULL DROP table #list_contract
IF OBJECT_ID(N'tempdb..#EDI_template_header') IS NOT NULL DROP TABLE #EDI_template_header
IF OBJECT_ID(N'tempdb..#gm_storage_rank') IS NOT NULL DROP TABLE #gm_storage_rank

IF OBJECT_ID(N'tempdb..#thead_info_pre') IS NOT NULL DROP TABLE #thead_info_pre
IF OBJECT_ID(N'tempdb..#unthead_info_pre') IS NOT NULL DROP TABLE #unthead_info_pre

IF OBJECT_ID(N'tempdb..#delta_unthead') IS NOT NULL DROP TABLE #delta_unthead

IF OBJECT_ID(N'tempdb..#dw_vol') IS NOT NULL DROP TABLE #dw_vol
IF OBJECT_ID(N'tempdb..#us_vol') IS NOT NULL DROP TABLE #us_vol

IF OBJECT_ID(N'tempdb..#delta_vol') IS NOT NULL DROP TABLE #delta_vol
IF OBJECT_ID(N'tempdb..#th_o6') IS NOT NULL DROP TABLE #th_o6

IF OBJECT_ID(N'tempdb..#unth_o6_dw') IS NOT NULL DROP TABLE #unth_o6_dw

IF OBJECT_ID(N'tempdb..#leg2_06') IS NOT NULL DROP TABLE #leg2_06




declare @DUNS_shipper varchar(30) ,@DUNS_pipeline   varchar(30),@edi_txt_table varchar(250)
,@db_user varchar(30),@ship_id varchar(30),@unique_id varchar(15)
, @unthread_info varchar(250)
, @unthread_info_pre varchar(250)
, @thread_info varchar(250)
, @thread_info_pre varchar(250)


--set @pkg_id=replace(replace(str(cast(RAND() as numeric(20,20)),20,20),'0.','')

set @db_user=dbo.FNADBUser()
set @process_id=isnull(@process_id,REPLACE(newid(),'-','_'))

select @unique_id=isnull(last_incremental_value,0) from dbo.EDI_template_header where EDI_template_header_id=1

set @edi_txt_table=dbo.FNAProcessTableName('edi_txt_table',@db_user,@process_id)

set @unthread_info=dbo.FNAProcessTableName('unthread_info',@db_user,@process_id) 
set @unthread_info_pre=dbo.FNAProcessTableName('unthread_info_pre',@db_user,@process_id) 
set @thread_info=dbo.FNAProcessTableName('thread_info',@db_user,@process_id) 
set @thread_info_pre=dbo.FNAProcessTableName('thread_info_pre',@db_user,@process_id)

   
   
CREATE TABLE #bcp_status (status_desc VARCHAR(5000) COLLATE DATABASE_DEFAULT )

set @as_of_date=isnull(@as_of_date,getdate())

declare @threaded_book_id int, @threaded_received_book_id int , @threaded_delivered_book_id int,@st varchar(max) ,@column_list varchar(max)


DECLARE  @sdv_from_deal	INT,@sdv_priority INT,@sdv_to_deal int,@path_id int	 ,@deal_type_id int,@sdv_facilator int,@server varchar(100)
	,@loss int, @upstream_counterparty INT, @upstream_contract INT
select @deal_type_id=source_deal_type_id from source_deal_type where deal_type_id='Transportation'

SET @server= @@SERVERNAME --   SERVERPROPERTY('ServerName')
		
SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

SELECT @sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'To Deal'

SELECT @sdv_priority=value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Priority'

SELECT @sdv_facilator=value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Tesoro Facility ID'

SELECT @upstream_counterparty=value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Upstream CPTY'

SELECT @upstream_contract=
 value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Upstream Contract'

SELECT @loss =value_id
	FROM static_data_value sdv
	WHERE code = 'Loss'	

declare @yymmdd	 varchar(6),
	@hhmm varchar(4),
	@ssmcs varchar(9),
	@yyyymmdd  varchar(8),
	@yyyymmddhhmm  varchar(12) ,
	@from_term varchar(8),
	@to_term varchar(8)
--SELECT * FROM dbo.generic_mapping_header

declare @mapping_table_id int
select   @mapping_table_id=mapping_table_id FROM dbo.generic_mapping_header WHERE mapping_name='Storage Rank'

SELECT gm.* INTO #gm_storage_rank FROM (
	SELECT clm2_value location_id,clm3_value storage_type,MAX(sdv.code) [priority],MAX(clm5_value) tsp
	FROM dbo.generic_mapping_values g
	LEFT  JOIN dbo.static_data_value sdv ON g.clm4_value=sdv.value_id
	
	WHERE mapping_table_id=@mapping_table_id
	  AND dbo.FNAGetSQLStandardDate(case when isdate(clm1_value) = 1 then clm1_value else '' end)<=@term_start
	GROUP BY clm2_value,clm3_value
) gm

	
select @yymmdd= right(cast(datepart(year, @as_of_date) as varchar),2)+right('0'+cast(datepart(month, @as_of_date) as varchar),2)+right('0'+cast(datepart(day, @as_of_date) as varchar),2) 
	,@hhmm=right('0'+cast(datepart(hour, @as_of_date) as varchar),2)+right('0'+cast(datepart(minute, @as_of_date) as varchar),2) 
	,@ssmcs=right('00000'+cast(datepart(second, @as_of_date) as varchar),6)+right('000'+cast(datepart(minute, @as_of_date) as varchar),3)  
	,@yyyymmdd=cast(datepart(year, @as_of_date) as varchar)+right('0'+cast(datepart(month, @as_of_date) as varchar),2)+right('0'+cast(datepart(day, @as_of_date) as varchar),2) 
	,@yyyymmddhhmm=cast(datepart(year, @as_of_date) as varchar)+right('0'+cast(datepart(month, @as_of_date) as varchar),2)+right('0'+cast(datepart(day, @as_of_date) as varchar),2) 
		+right('0'+cast(datepart(hour, @as_of_date) as varchar),2)+right('0'+cast(datepart(minute, @as_of_date) as varchar),2) 


--select @DUNS_shipper=sc.customer_duns_number  from fas_subsidiaries s inner join source_counterparty sc 
--	on   s.counterparty_id=sc.source_counterparty_id and s.fas_subsidiary_id=-1

select @DUNS_shipper=sc.customer_duns_number  from  source_counterparty sc where sc.source_counterparty_id=@from_partner

select @DUNS_pipeline=sc.customer_duns_number  from  source_counterparty sc where sc.source_counterparty_id=@to_partner

		  
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

----print(@st)		
EXEC(@st)

 --select @sdv_to_deal, @sdv_from_deal


-- select * from #unthead_info where EDI_text like '%#15#%'


 create table #tmp_deals 
 (
	source_deal_header_id int 
	,priority_code varchar(50) COLLATE DATABASE_DEFAULT 
	,contract_id int --,from_deal_id int,to_deal_id int
	,counterparty_id int 
	,source_deal_detail_id_leg1 int
	,source_deal_detail_id_leg2 int  
       ,fuel_loss float --,from_un_contract_id VARCHAR(100) COLLATE DATABASE_DEFAULT ,to_un_contract_id VARCHAR(100) COLLATE DATABASE_DEFAULT 
	,package_id VARCHAR(30) COLLATE DATABASE_DEFAULT 
	,SLN_id	VARCHAR(30) COLLATE DATABASE_DEFAULT 
	,location_id_leg1 int  
	,location_id_leg2 int  
	,deal_volume_leg1  numeric(28,10)
	,deal_volume_leg2  numeric(28,10),
 )

set @st='
insert into  #tmp_deals 
 (
	source_deal_header_id 
	,source_deal_detail_id_leg1 
	,source_deal_detail_id_leg2
	,priority_code
	,contract_id 
	,counterparty_id
	,fuel_loss
	,package_id,SLN_id,location_id_leg1 ,location_id_leg2 
	,deal_volume_leg1,deal_volume_leg2	 
 ) 
SELECT sdh.source_deal_header_id ,sdd.source_deal_detail_id_leg1,sdd.source_deal_detail_id_leg2
	,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end priority_code
	,sdh.contract_id
	,sdh.counterparty_id
	,loss.fuel_loss
	,oh.package_id,oh.SLN_id 
	,sdd.location_id_leg1,sdd.location_id_leg2
	--,dbo.FNAPipelineRound(1,oh.rec_nom_volume,0) deal_volume_leg1,dbo.FNAPipelineRound(1,oh.del_nom_volume,0) deal_volume_leg2
	,oh.rec_nom_volume deal_volume_leg1,oh.del_nom_volume deal_volume_leg2
FROM  #books sbmp	  
inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
		AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
		AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
		AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
		and sdh.counterparty_id='+cast(@to_partner as varchar) +'
		and sdh.source_deal_type_id='+cast(@deal_type_id as varchar)+'
inner join optimizer_header oh on sdh.source_deal_header_id=oh.transport_deal_id 
'+case when @location_id is null then '' else ' and oh.location_id='+cast(@location_id as varchar)	end +
' 
cross apply 
(
	 SELECT  
		max(case when leg=1  then source_deal_detail_id else null end) source_deal_detail_id_leg1
		,max(case when leg=2  then source_deal_detail_id else null end) source_deal_detail_id_leg2 
		,max(case when leg=1  then location_id else null end) location_id_leg1
		,max(case when leg=2  then location_id else null end) location_id_leg2
		,max(case when leg=1  then deal_volume else null end) deal_volume_leg1
		,max(case when leg=2  then deal_volume else null end) deal_volume_leg2
	 FROM dbo.source_deal_detail  
	 where   source_deal_header_id=sdh.source_deal_header_id
 )	sdd 
outer apply
( 
	select  u3.udf_value fuel_loss
   	from  [user_defined_deal_fields] u3 
		inner JOIN [dbo].[user_defined_deal_fields_template] uddft3 ON  isnumeric(u3.udf_value)=1 
			and	 u3.source_deal_header_id=sdh.source_deal_header_id and uddft3.field_id ='+cast(@loss  as varchar )+'
			AND uddft3.udf_template_id = u3.udf_template_id 
) loss
WHERE  1=1'
+case when @header_deal_ids IS NULL then '' else ' and sdh.source_deal_header_id in ('+@header_deal_ids+' )  ' end
+case when @contract_id IS NULL then '' else ' and sdh.contract_id IN(' +cast(@contract_id as varchar) + ')' end

 --print @st
 exec(@st)
--select * from #tmp_deals  where source_deal_header_id iN(332650,332715)
--return
 --select * from #tmp_deals where    source_deal_header_id=34551
 --return

--select source_deal_header_id,source_deal_detail_id_leg1,'R' unthread_type,from_deal_id unthread_deal_id,contract_id,counterparty_id into #unthread_deals from #tmp_deals
--union all
--select source_deal_header_id,source_deal_detail_id_leg1,'D' unthread_type,to_deal_id unthread_deal_id,contract_id,counterparty_id from #tmp_deals
--select * from #unthread_deals
 select td.source_deal_header_id,od.source_deal_detail_id,case when od.up_down_stream='U' then 'R' else 'D' end unthread_type
  ,od.source_deal_header_id unthread_deal_id
   ,up.transport_deal_id unthread_deal_id1
	,td.contract_id-- isnull(sc.contract_id,sdh.contract_id) contract_id --, isnull(nullif(udddf_cpty.udf_value,''),sdh.counterparty_id)	counterparty_id
	,scp.source_counterparty_id counterparty_id,sdd.location_id
	,sdd.deal_volume,od.volume_used
	,up.volume_used volume_used1
	,od.flow_date term_start ,od.optimizer_detail_id sln_id,td.fuel_loss
into #unthread_deals --   select * from  #unthread_deals

from #tmp_deals td inner join dbo.optimizer_header oh on td.source_deal_header_id=oh.transport_deal_id
	inner join dbo.optimizer_detail od on oh.optimizer_header_id=od.optimizer_header_id
	inner join source_deal_header sdh on sdh.source_deal_header_id=od.source_deal_header_id
	inner join source_deal_detail sdd on od.source_deal_detail_id=sdd.source_deal_detail_id
			and sdd.term_start=@term_start
	outer apply
	(
		select b.* from optimizer_header a 
			inner join optimizer_detail b on a.transport_deal_id=b.source_deal_header_id and b.up_down_stream='u' 
		where a.transport_deal_id= td.source_deal_header_id and od.up_down_stream='d' 
	
	) up

	LEFT JOIN user_defined_deal_fields_template uddft_ups_contract
		ON  uddft_ups_contract.field_name =@upstream_contract	
		AND uddft_ups_contract.template_id = sdh.template_id
		and uddft_ups_contract.udf_type = 'd'
		--AND uddft_ups_contract.leg = sdd.leg
	LEFT JOIN user_defined_deal_detail_fields udddf_cnt
		ON  udddf_cnt.source_deal_detail_id = sdd.source_deal_detail_id
		AND uddft_ups_contract.udf_template_id = udddf_cnt.udf_template_id	
	left join contract_group sc on sc.source_contract_id=udddf_cnt.udf_value
	LEFT JOIN user_defined_deal_fields_template uddft_ups_cpty
		ON  uddft_ups_cpty.field_name = @upstream_counterparty	
		AND uddft_ups_cpty.template_id = sdh.template_id
		and uddft_ups_cpty.udf_type = 'd'
		--AND uddft_ups_cpty.leg = sdd.leg
	LEFT JOIN user_defined_deal_detail_fields udddf_cpty
		ON  udddf_cpty.source_deal_detail_id = sdd.source_deal_detail_id
		AND uddft_ups_cpty.udf_template_id = udddf_cpty.udf_template_id	
	left join source_counterparty scp on scp.source_counterparty_id=isnull(nullif(udddf_cpty.udf_value,''),sdh.counterparty_id)


declare @EDI_template_value_position_id int,@value_column_name	varchar(100),@edi_body_txt varchar(max) 


create table 	#list_contract(contract_id varchar(100) COLLATE DATABASE_DEFAULT )

	
select 	
	cnt.counterparty_id
	,cnt.term_start	  ,
 	tmp.EDI_template_header_id ,
	tmp.EDI_text,tmp.footer_EDI_text
	,isnull(tmp.no_of_lines_header_text,0) no_of_lines_header_text
	, isnull(tmp.no_of_lines_footer_text,0) no_of_lines_footer_text 
	--,c.contract_id 
	,row_id=identity(int ,1,1)
into #EDI_template_header --select * from #EDI_template_header
from   
(
	select distinct td.counterparty_id,sdd.term_start
	 from  #tmp_deals td inner join source_deal_detail sdd on    sdd.source_deal_header_id = td.source_deal_header_id
				and sdd.term_start=@term_start -- between @term_start and @term_end
)  cnt
cross apply
( 
	select top(1) * from dbo.EDI_template_header 
	where 		effective_date<=cnt.term_start and	counterparty_id =cnt.counterparty_id
	order by  effective_date desc
) tmp
 --cross join #list_contract c

-- select * from #unthead_info_pre where header_contract_id=5573
--select * from #unthead_info where header_contract_id=5573
--select * from contract_group where source_contract_id ='935'
--select * from #tmp_deals
--select sum(cast(deal_volume_leg1 as float)) from #tmp_deals --where contract_id=5573
--select sum(cast(deal_volume as float)),contract_steam,udf_tran_type from #unthead_info group by contract_steam,udf_tran_type

 --select sum(cast(deal_volume as float)),contract_steam,udf_tran_type from #unthead_info_pre group by contract_steam,udf_tran_type

select
	cast(td.source_deal_header_id as varchar) source_deal_header_id ,sdh.contract_id header_contract_id   ,
	cast(sdh.counterparty_id as varchar(30)) counterparty_id,
	@term_start term_start,
	isnull(cast(cg.source_contract_id	as varchar(30)),'N/A') contract_id,
	case when sjl.location_name='Storage' then '07'
		when sjl2.location_name='Storage' then '06'
	else '01' end udf_tran_type	 ,
	isnull(CASE when sjl.location_name='Storage' THEN gsr.[priority] ELSE isnull(sdv.code,priority_code) END,'N/A') leg_1_loc_rank,
	coalesce(case when isnumeric(sdh.description3)=1 then sdh.description3 else null end ,rnk.[rank], sdv2.code,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end	
	,CASE when sjl.location_name='Storage' THEN gsr.[priority] ELSE isnull(sdv.code,priority_code) END,  'N/A') leg_2_loc_rank

	,isnull(tsp_leg1.tsp_location,'N/A') leg_1_tsp_location
	,isnull(tsp_leg2.tsp_location,'N/A') leg_2_tsp_location
 	,from_term=cast(datepart(year, @term_start) as varchar)+right('0'+cast(datepart(month, @term_start) as varchar),2)+right('0'+cast(datepart(day,@term_start) as varchar),2)
	,to_term=cast(datepart(year, @term_start) as varchar)+right('0'+cast(datepart(month, @term_start) as varchar),2)+right('0'+cast(datepart(day, @term_start) as varchar),2)
	,edi.EDI_text,edi.EDI_head_text,edi.EDI_template_header_id ,edi.EDI_template_detail_id
	,isnull(edi.no_of_lines_header_text,0) no_of_lines_header_text
	,isnull(edi.no_of_lines_footer_text,0) no_of_lines_footer_text
	,isnull(edi.no_of_lines_body_text,0)  no_of_lines_body_text

	,td.location_id_leg1 leg_1_location_id 
	,td.location_id_leg2 leg_2_location_id 
	,td.deal_volume_leg1 deal_volume
	,td.deal_volume_leg2 leg_2_deal_volume
	,td.fuel_loss
	,cast(td.source_deal_detail_id_leg1 as varchar) source_deal_detail_id
	,td.source_deal_detail_id_leg2
into #thead_info_pre --select * from #thead_info_pre
from  #tmp_deals td
inner join dbo.source_deal_header sdh on td.source_deal_header_id=sdh.source_deal_header_id
cross apply
(
select top(1) source_deal_header_id from   source_deal_detail  where sdh.source_deal_header_id=source_deal_header_id and term_start=@term_start
) sdd
left JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
	AND uddft.leg = 1 and uddft.udf_type = 'd' and uddft.field_id= @sdv_priority
left join static_data_value sdv on sdv.value_id=uddft.default_value
left JOIN user_defined_deal_fields_template uddft2 ON uddft2.template_id = sdh.template_id
	AND uddft2.leg = 2 and uddft2.udf_type = 'd' and uddft2.field_id= @sdv_priority
left join static_data_value sdv2 on sdv2.value_id=uddft2.default_value
outer apply
(
	select DISTINCT d.* from EDI_template_detail d inner join #EDI_template_header h on h.EDI_template_header_id =d.EDI_template_header_id
			and  d.EDI_template_desc='Threaded' and  h.counterparty_id=sdh.counterparty_id 
) edi
left join contract_group cg on cg.contract_id=sdh.contract_id
outer apply
(
     SELECT a.static_data_udf_values tsp_location FROM  application_ui_template_fields atf 
	 INNER JOIN application_ui_template_definition atd ON atd.application_ui_field_id = atf.application_ui_field_id
	 INNER JOIN maintain_udf_static_data_detail_values a ON a.application_field_id = atf.application_field_id
				and  a.primary_field_object_id=td.location_id_leg1 
	 INNER JOIN user_defined_fields_template udft ON udft.Field_label =  atd.default_label
	WHERE  udft.Field_id = -5682		--'%TSP Location%'
)  tsp_leg1
outer apply
(
     SELECT a.static_data_udf_values tsp_location FROM  application_ui_template_fields atf 
	 INNER JOIN application_ui_template_definition atd ON atd.application_ui_field_id = atf.application_ui_field_id
	 INNER JOIN maintain_udf_static_data_detail_values a ON a.application_field_id = atf.application_field_id
				and  a.primary_field_object_id=td.location_id_leg2
	 INNER JOIN user_defined_fields_template udft ON udft.Field_label =  atd.default_label
	WHERE  udft.Field_id = -5682		--'%TSP Location%'
)  tsp_leg2
left join source_minor_location sml on sml.source_minor_location_id= td.location_id_leg1 
left join source_major_location sjl on sjl.source_major_location_id= sml.source_major_location_id 
left join source_minor_location sml2 on sml2.source_minor_location_id= td.location_id_leg2 
left join source_major_location sjl2 on sjl2.source_major_location_id= sml2.source_major_location_id 
LEFT JOIN  #gm_storage_rank gsr ON gsr.location_id=td.location_id_leg1 AND gsr.storage_type='w'
outer APPLY
(
	SELECT TOP(1) 
	--lr.location_id,
	 s.code [rank] 
	FROM dbo.location_rank lr INNER JOIN dbo.static_data_value s   ON lr.location_id= td.location_id_leg2 AND
		lr.rank_value_id=s.value_id AND lr.effective_date<=@as_of_date
	ORDER BY lr.effective_date DESC
 ) rnk
 

 --DELETE dbo.location_rank WHERE location_id in ( 27065,27386)

select
	cast(td.source_deal_header_id as varchar) source_deal_header_id,COALESCE(td.counterparty_id,sdh.counterparty_id) counterparty_id,i.term_start,@DUNS_shipper DUNS_shipper,
	from_term=cast(datepart(year, td.term_start) as varchar)+right('0'+cast(datepart(month, td.term_start) as varchar),2)+right('0'+cast(datepart(day, td.term_start) as varchar),2) ,
	to_term=cast(datepart(year, td.term_start) as varchar)+right('0'+cast(datepart(month, td.term_start) as varchar),2)+right('0'+cast(datepart(day, td.term_start) as varchar),2)	,
	 isnull(td.contract_id,sdh.contract_id)	header_contract_id		,
	case when tran_type.udf_tran_type='01' then cast( isnull( td.volume_used1, td.volume_used) as numeric(28,8))  else cast(td.volume_used  as numeric(28,8))  end deal_volume,
	case when td.unthread_type='R' then i.leg_1_tsp_location else i.leg_2_tsp_location end unthread_tsp_location	 ,
	case when td.unthread_type='R' then 'UP' else 'DT' end contract_steam	   ,
	case when td.unthread_type='R' then 'R1' else 'R4' end deal_orientation	   ,
	case when td.unthread_type='R' then 'M2' else 'MQ' end location_group	   ,
	case when td.unthread_type='R' then 'US' else 'DW' end US_DW,
	cast(case when tran_type.udf_tran_type='01' then isnull(td.unthread_deal_id1,td.unthread_deal_id) else td.unthread_deal_id end as varchar) unthread_deal_id
	--isnull(cast(isnull(cg1.source_contract_id,cg.source_contract_id) as varchar(30)),'N/A') unthread_contract_id
	--,case when sjl.location_name='Storage' or sjl2.location_name='Storage' then isnull(cast (cg.source_contract_id as varchar(50)),'N/A')
	,case when sjl.location_name='Storage' then isnull(cast (cg.source_contract_id as varchar(50)),'N/A')
		when sjl2.location_name='Storage' then COALESCE(udddf_contract.udf_value, cast(cg.source_contract_id as varchar(50)),'N/A')
	else 
	 COALESCE(udddf_contract.udf_value, cast(cg.source_contract_id as varchar(50)),'N/A') end unthread_contract_id 
	,COALESCE(udddf_contract.udf_value,cast(sdh.contract_id as varchar(50))) unthread_contract_id1 

	,td.unthread_type	,
	tran_type.udf_tran_type	 
	,coalesce(
	case when td.unthread_type='R' then 
		case when sjl.location_name='Storage' THEN gsr.[priority]  ELSE  
			isnull(sdv.code,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end) 
		END 
	else
	 	 coalesce(case when isnumeric(sdh.description3)=1 then sdh.description3 else null end ,rnk.[rank], sdv.code,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end)
	end	,case when sjl.location_name='Storage' THEN gsr.[priority]  ELSE  
			isnull(sdv.code,case when isnumeric(sdh.description2)=1 then sdh.description2 else null end) 
		END ,'N/A') unthread_location_rank
	,edi.EDI_text,edi.EDI_head_text,edi.EDI_template_header_id ,edi.EDI_template_detail_id
	,isnull(edi.no_of_lines_header_text,0) no_of_lines_header_text
	,isnull(edi.no_of_lines_footer_text,0) no_of_lines_footer_text
	,isnull(edi.no_of_lines_body_text,0)  no_of_lines_body_text
	--,cast(td.source_deal_detail_id as varchar) source_deal_detail_id
	--????????????
	,cast(td.sln_id as varchar) source_deal_detail_id --after grouping deal create logic, optimizer_detail.optimizer_detail_id is uesed as sln_id through the column source_deal_detail_id , hence no more use source_deal_detail_id below as source_deal_detail.source_deal_detail_id
	,COALESCE(ups_cpty.customer_duns_number, sc.customer_duns_number,'N/A') customer_duns_number
	,td.unthread_deal_id1
	,td.fuel_loss
into #unthead_info_pre --select * from #unthead_info

--select COALESCE(udddf_contract.udf_value, cast(cg.source_contract_id as varchar(50)),'N/A') 
from #unthread_deals td 

inner join #thead_info_pre i on td.source_deal_header_id=i.source_deal_header_id
inner join  source_deal_detail sdd on sdd.source_deal_detail_id=td.source_deal_detail_id

outer apply
(
	select DISTINCT d.* from EDI_template_detail d inner join #EDI_template_header h on h.EDI_template_header_id =d.EDI_template_header_id
			and  d.EDI_template_desc='Unthreaded' --and  h.counterparty_id=td.counterparty_id 
			and h.term_start=i.term_start
) edi

left join source_minor_location sml on sml.source_minor_location_id= i.leg_1_location_id 
left join source_major_location sjl on sjl.source_major_location_id= sml.source_major_location_id 
left join source_minor_location sml2 on sml2.source_minor_location_id= i.leg_2_location_id 
left join source_major_location sjl2 on sjl2.source_major_location_id= sml2.source_major_location_id 

outer apply
( select case when sjl.location_name='Storage' then '07'
		when sjl2.location_name='Storage' then '06'
		else '01' end udf_tran_type	
) tran_type
left join dbo.source_deal_header sdh on sdh.source_deal_header_id=case when tran_type.udf_tran_type='01' then isnull(td.unthread_deal_id1,td.unthread_deal_id) else td.unthread_deal_id end
left join source_counterparty sc on sc.source_counterparty_id=COALESCE(td.counterparty_id,sdh.counterparty_id)
left JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
	--AND uddft.leg = sdd.leg 
	and uddft.udf_type = 'd' 
	and uddft.field_id=@sdv_priority
left join static_data_value sdv on sdv.value_id=uddft.default_value
left join contract_group cg on cg.contract_id=sdh.contract_id
left join contract_group cg1 on cg1.contract_id=td.contract_id
LEFT JOIN  #gm_storage_rank gsr ON gsr.location_id= i.leg_1_location_id  AND gsr.storage_type='w'

outer APPLY
(
	SELECT TOP(1) s.code [rank] FROM dbo.location_rank lr INNER JOIN dbo.static_data_value s   ON lr.location_id= i.leg_2_location_id
	AND lr.rank_value_id=s.value_id AND lr.effective_date<=i.term_start
	ORDER BY lr.effective_date DESC
 ) rnk
LEFT JOIN user_defined_deal_fields_template uddft_ups_cpty
    ON  uddft_ups_cpty.field_name = @upstream_counterparty	
	AND uddft_ups_cpty.template_id = sdh.template_id
	and uddft_ups_cpty.udf_type = 'd'
	--AND uddft_ups_cpty.leg = sdd.leg	
LEFT JOIN user_defined_deal_detail_fields udddf_cpty
    ON  udddf_cpty.source_deal_detail_id = sdd.source_deal_detail_id
    AND uddft_ups_cpty.udf_template_id = udddf_cpty.udf_template_id	 and isnumeric(udddf_cpty.udf_value)=1
LEFT JOIN source_counterparty ups_cpty ON ups_cpty.source_counterparty_id = udddf_cpty.udf_value 
LEFT JOIN user_defined_deal_fields_template uddft_ups_contract
    ON  uddft_ups_contract.field_name = @upstream_contract
	AND uddft_ups_contract.template_id = sdh.template_id
	and uddft_ups_contract.udf_type = 'd'
	--AND uddft_ups_contract.leg = sdd.leg	
LEFT JOIN user_defined_deal_detail_fields udddf_contract
    ON  udddf_contract.source_deal_detail_id = sdd.source_deal_detail_id --and isnumeric(udddf_contract.udf_value)=1
		AND uddft_ups_contract.udf_template_id = udddf_contract.udf_template_id
---left join contract_group udf_cg on udf_cg.contract_id=udddf_contract.udf_value
order by deal_orientation


--select *	FROM #unthead_info_pre
--						#unthead_info_pre where customer_duns_number='N/A'

--SELECT sum(cast(deal_volume as numeric(20,0))),sum(cast(leg_2_deal_volume as numeric(20,0))) FROM #thead_info --where udf_tran_type='01'
--SELECT * FROM #unthread_deals
--select *	FROM #unthead_info_pre
--RETURN


 --if  @contract_id  is null 
	insert into #list_contract(contract_id )  
	SELECT distinct contract_id  FROM 
	(
		SELECT distinct cast(contract_id as varchar(100)) contract_id FROM  #tmp_deals WHERE contract_id IS NOT null	  --#thead_info
		UNION ALL 
		SELECT distinct unthread_contract_id1  from #unthead_info_pre
	) a WHERE contract_id IS NOT null
	

--else
--	insert into #list_contract(contract_id ) select cast(i.item as int) contract_id  from dbo.SplitCommaSeperatedValues(@contract_id)  i


 ------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------

INSERT into  #thead_info_pre(
		source_deal_header_id 	 
		,header_contract_id   ,
		counterparty_id,
		term_start,
		contract_id,
		udf_tran_type	 ,
		leg_1_loc_rank,
		leg_2_loc_rank,
		leg_1_tsp_location ,
		deal_volume	,
		leg_2_tsp_location,
		from_term
		,to_term
		,EDI_text,EDI_head_text,EDI_template_header_id ,EDI_template_detail_id
		,no_of_lines_header_text
		,no_of_lines_footer_text
		,no_of_lines_body_text
		,source_deal_detail_id
		, leg_1_location_id , leg_2_location_id  ,leg_2_deal_volume
		,fuel_loss
		--,from_un_contract_id
		--,to_un_contract_id
	)
 select 
	'-'+source_deal_header_id ,
	header_contract_id   ,
	counterparty_id,
	term_start,
	contract_id,
	udf_tran_type	 ,
	leg_1_loc_rank,
	leg_2_loc_rank,
	leg_1_tsp_location ,
	deal_volume	,
	leg_2_tsp_location,
	from_term
	,to_term
	,EDI_text,EDI_head_text,EDI_template_header_id ,EDI_template_detail_id
	,no_of_lines_header_text
	,no_of_lines_footer_text
	,no_of_lines_body_text
	,source_deal_detail_id
	, leg_1_location_id , leg_2_location_id  ,leg_2_deal_volume
	,fuel_loss
	--,from_un_contract_id
	--,to_un_contract_id
 from  #thead_info_pre WHERE udf_tran_type<>'01'

 insert into  #unthead_info_pre(
	source_deal_header_id,counterparty_id ,term_start,DUNS_shipper,
	from_term,
	to_term,
	header_contract_id		,
	deal_volume,
	unthread_tsp_location	 ,
	contract_steam	   ,
	deal_orientation	   ,
	location_group	   ,
	US_DW,
	unthread_deal_id,
	unthread_contract_id ,unthread_type	,
	udf_tran_type	 
	, unthread_location_rank
	,EDI_text,EDI_head_text,EDI_template_header_id ,EDI_template_detail_id
	,no_of_lines_header_text
	,no_of_lines_footer_text
	,no_of_lines_body_text
	,source_deal_detail_id
	,customer_duns_number,unthread_deal_id1
	,fuel_loss
)
 select 
	'-'+source_deal_header_id,counterparty_id ,term_start,DUNS_shipper,
	from_term,
	to_term,
	header_contract_id		,
	deal_volume,
	unthread_tsp_location	 ,
	contract_steam	   ,
	deal_orientation	   ,
	location_group	   ,
	US_DW,
	unthread_deal_id,
	unthread_contract_id ,unthread_type	,
	udf_tran_type	 
	, unthread_location_rank
	,EDI_text,EDI_head_text,EDI_template_header_id ,EDI_template_detail_id
	,no_of_lines_header_text
	,no_of_lines_footer_text
	,no_of_lines_body_text
	,'-'+source_deal_detail_id
	,customer_duns_number,unthread_deal_id1 ,fuel_loss
 from  #unthead_info_pre  WHERE udf_tran_type<>'01'


UPDATE #thead_info_pre SET contract_id=u.unthread_contract_id FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
	AND CAST(t.source_deal_header_id AS INT)>0 AND  u.unthread_type=CASE  t.udf_tran_type WHEN '07' THEN 'R' WHEN '06' THEN 'D' ELSE u.unthread_type end
  WHERE  t.udf_tran_type='07'

UPDATE #thead_info_pre SET contract_id=u.unthread_contract_id FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type=CASE  t.udf_tran_type WHEN '07' THEN 'R' WHEN '06' THEN 'D' ELSE u.unthread_type end
  WHERE  t.udf_tran_type='06'

UPDATE #thead_info_pre SET leg_2_tsp_location=gsr.tsp FROM #thead_info_pre t 
 INNER  JOIN  #gm_storage_rank gsr ON gsr.location_id=CASE  t.udf_tran_type WHEN '07' THEN t.leg_1_location_id  WHEN '06' THEN t.leg_2_location_id ELSE NULL END  
 AND CAST(t.source_deal_header_id AS INT)>0 AND gsr.storage_type= 'w'  
    WHERE  t.udf_tran_type='07'
 
UPDATE #thead_info_pre SET leg_2_tsp_location=gsr.tsp FROM #thead_info_pre t 
 INNER  JOIN  #gm_storage_rank gsr ON gsr.location_id=CASE  t.udf_tran_type WHEN '07' THEN t.leg_1_location_id  WHEN '06' THEN t.leg_2_location_id ELSE NULL END  
 AND CAST(t.source_deal_header_id AS INT)>0
	AND gsr.storage_type= 'i' 
    WHERE  t.udf_tran_type='06'

UPDATE u SET leg_1_tsp_location=t.leg_2_tsp_location
  FROM #thead_info_pre t INNER JOIN #thead_info_pre u ON t.source_deal_header_id=ABS(u.source_deal_header_id)
			 AND CAST(t.source_deal_header_id AS INT)>0  AND CAST(u.source_deal_header_id AS INT)<0 
  WHERE  t.udf_tran_type='06'

--UPDATE #thead_info_pre SET deal_volume=u.deal_volume FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON ABS(t.source_deal_header_id)=u.source_deal_header_id 
--	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D'
--  WHERE  t.udf_tran_type='06'

--select * from #thead_info_pre





--UPDATE t SET deal_volume=u.deal_volume FROM #unthead_info_pre t 
--  INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
--	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D' AND  t.unthread_type='R'
--  WHERE  t.udf_tran_type='06'

  
UPDATE #unthead_info_pre SET unthread_contract_id=t.contract_id FROM  #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=ABS(u.source_deal_header_id) 
  AND  u.unthread_type='R' AND CAST(u.source_deal_header_id AS INT)<0
  AND CAST(t.source_deal_header_id AS INT)>0
  WHERE  t.udf_tran_type='06'


UPDATE #unthead_info_pre SET unthread_tsp_location=t.leg_2_tsp_location FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
	AND CAST(t.source_deal_header_id AS INT)>0 AND  u.unthread_type='D'
  WHERE  t.udf_tran_type='06'

UPDATE #unthead_info_pre SET unthread_tsp_location=t.leg_2_tsp_location FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=ABS(u.source_deal_header_id )
	AND CAST(t.source_deal_header_id AS INT)>0 AND  u.unthread_type='R' AND CAST(u.source_deal_header_id AS INT)<0 
  WHERE  t.udf_tran_type='06'


UPDATE #unthead_info_pre SET customer_duns_number=DUNS_shipper FROM #unthead_info_pre u 
  WHERE unthread_type='R'  AND CAST(u.source_deal_header_id AS INT)<0 AND  u.udf_tran_type='06'

UPDATE u SET leg_1_tsp_location=t.leg_2_tsp_location
  FROM #thead_info_pre t INNER JOIN #thead_info_pre u ON t.source_deal_header_id=ABS(u.source_deal_header_id)
			 AND CAST(t.source_deal_header_id AS INT)>0  AND CAST(u.source_deal_header_id AS INT)<0 
  WHERE  t.udf_tran_type='07'

UPDATE u SET deal_volume=t.deal_volume FROM #unthead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
	AND CAST(t.source_deal_header_id AS INT)>0 AND  u.unthread_type='D' and t.unthread_type='R'
  WHERE  t.udf_tran_type='07'


UPDATE #unthead_info_pre SET unthread_tsp_location=t.leg_2_tsp_location FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
	AND CAST(t.source_deal_header_id AS INT)>0 AND  u.unthread_type='D'
  WHERE  t.udf_tran_type='07'

UPDATE #unthead_info_pre SET unthread_tsp_location=t.leg_2_tsp_location FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 
	AND CAST(t.source_deal_header_id AS INT)>0 AND  u.unthread_type='D'
  WHERE  t.udf_tran_type='07'

UPDATE #unthead_info_pre SET unthread_tsp_location=t.leg_2_tsp_location FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=ABS(u.source_deal_header_id)
			 AND CAST(t.source_deal_header_id AS INT)>0  AND CAST(u.source_deal_header_id AS INT)<0 AND  u.unthread_type='R'
  WHERE  t.udf_tran_type='07'

UPDATE #unthead_info_pre SET customer_duns_number=DUNS_shipper FROM #unthead_info_pre u 
  WHERE unthread_type='D'






--UPDATE td set td.to_un_contract_id = '9888888'  FROM #unthead_info_pre u INNER JOIN #thead_info_pre td ON td.source_deal_header_id = (u.source_deal_header_id)
--	WHERE unthread_type='D' AND CAST(u.source_deal_header_id AS INT)<0 AND unthread_deal_id=ABS(u.source_deal_header_id)

--UPDATE td set td.to_un_contract_id = '9888888'  FROM #unthead_info_pre u INNER JOIN #thead_info_pre td ON td.source_deal_header_id = (u.source_deal_header_id)
--	WHERE unthread_type='D'   AND unthread_deal_id=ABS(u.source_deal_header_id)
--	  AND u.udf_tran_type='01'


UPDATE #thead_info_pre SET udf_tran_type='01' FROM #thead_info_pre t WHERE   CAST(t.source_deal_header_id AS INT)<0 AND udf_tran_type='07'

UPDATE #unthead_info_pre SET udf_tran_type='01' FROM #unthead_info_pre t WHERE   CAST(t.source_deal_header_id AS INT)<0  AND udf_tran_type='07'

UPDATE #thead_info_pre SET udf_tran_type='01' FROM #thead_info_pre t WHERE   CAST(t.source_deal_header_id AS INT)>0 AND udf_tran_type='06'

UPDATE #unthead_info_pre SET udf_tran_type='01' FROM #unthead_info_pre t WHERE   CAST(t.source_deal_header_id AS INT)>0  AND udf_tran_type='06'

UPDATE u SET unthread_location_rank=CASE WHEN unthread_type='D' THEN t.leg_2_loc_rank ELSE  t.leg_1_loc_rank END 
	FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id


UPDATE i SET header_contract_id=cg.contract_id from #thead_info_pre i INNER JOIN dbo.contract_group cg ON i.contract_id =cg.source_contract_id
  
 -- sELECT us_dw,unthread_tsp_location,sum(cast(deal_volume as numeric(20,0))) FROM #unthead_info group by us_dw,unthread_tsp_location o
 --SELECT * FROM #unthead_info
 -- SELECT unthread_deal_id, count(1) FROM #unthead_info group by unthread_deal_id having count(1)>1

UPDATE #unthead_info_pre SET header_contract_id=t.header_contract_id FROM #thead_info_pre t INNER JOIN #unthead_info_pre u ON t.source_deal_header_id=u.source_deal_header_id 


	 


 --UPDATE #unthead_info_pre SET  unthread_deal_id= od.unthread_deal_id1 FROM #unthead_info_pre u 
	--inner join #unthread_deals od on od.source_deal_header_id=ABS(u.source_deal_header_id) and u.US_DW='DW'
	--and od.unthread_type='D'  AND u.unthread_deal_id=ABS(u.source_deal_header_id)
	--AND u.udf_tran_type='01'
 --and od.unthread_deal_id=u.unthread_deal_id
 --   and od.unthread_deal_id1 is not null 
----UPDATE #unthead_info_pre SET unthread_contract_id=
--select u.* FROM #unthead_info_pre u 
--	left join optimizer_detail od on od.source_deal_header_id=ABS(u.source_deal_header_id) and od.up_down_stream='u' and u.unthread_type='D'
--	left join source_deal_header sdh on sdh.source_deal_header_id=od.transport_deal_id
--	left join contract_group cg on cg.contract_id=sdh.contract_id
--WHERE unthread_type='D'   --AND unthread_deal_id=ABS(u.source_deal_header_id)
--  AND u.udf_tran_type='01'

--return

--UPDATE #unthead_info_pre SET unthread_contract_id='9888888' FROM #unthead_info_pre u 
--  WHERE unthread_type='D' AND CAST(u.source_deal_header_id AS INT)<0 AND unthread_deal_id=ABS(u.source_deal_header_id)




delete #unthead_info_pre
from 
( 
	select source_deal_header_id, unthread_deal_id,unthread_type,udf_tran_type,max(unthread_deal_id1) unthread_deal_id1
	 from #unthead_info_pre 
	
	where  unthread_type='D' and udf_tran_type='07' and unthread_deal_id1 is not null
	group by source_deal_header_id,unthread_deal_id ,unthread_type,udf_tran_type
) a
inner join #unthead_info_pre b on b.source_deal_header_id=a.source_deal_header_id
	and b.unthread_deal_id=a.unthread_deal_id and  b.unthread_type=a.unthread_type and b.udf_tran_type=a.udf_tran_type
	and b.unthread_deal_id1<>a.unthread_deal_id1
	and b.source_deal_header_id>0


UPDATE #unthead_info_pre SET unthread_contract_id=isnull(cg.source_contract_id,'9888888')
	, unthread_deal_id=isnull(od.unthread_deal_id1,u.unthread_deal_id)
	,deal_volume=isnull(od.volume_used1,u.deal_volume)
FROM #unthead_info_pre u 
left join #unthread_deals od on od.source_deal_header_id=abs(u.source_deal_header_id) and od.unthread_type='D'
	and u.unthread_deal_id1= od.unthread_deal_id1
left join source_deal_header sdh on sdh.source_deal_header_id=od.unthread_deal_id1
left join contract_group cg on cg.contract_id=sdh.contract_id
	and abs(u.unthread_deal_id)<>abs(u.source_deal_header_id)
WHERE u.unthread_type='D' AND CAST(u.source_deal_header_id AS INT)<0 --AND unthread_deal_id=ABS(u.source_deal_header_id)

--UPDATE #unthead_info_pre SET unthread_contract_id=isnull(cg.source_contract_id,'9888888')
--, unthread_deal_id=isnull(od.unthread_deal_id1,u.unthread_deal_id)
--,deal_volume=isnull(od.volume_used1,u.deal_volume)
-- FROM #unthead_info_pre u 
--left join #unthread_deals od on od.source_deal_header_id=abs(u.source_deal_header_id) and od.unthread_type='D'
--and isnull(u.unthread_deal_id1,u.unthread_deal_id)= isnull(od.unthread_deal_id1,od.unthread_deal_id)
--left join source_deal_header sdh on sdh.source_deal_header_id=isnull(od.unthread_deal_id1,od.unthread_deal_id)
--left join contract_group cg on cg.contract_id=sdh.contract_id
--and abs(u.unthread_deal_id)<>abs(u.source_deal_header_id)
-- WHERE u.unthread_type='D' AND CAST(u.source_deal_header_id AS INT)<0 --AND unthread_deal_id=ABS(u.source_deal_header_id)
--and u.udf_tran_type='06'


--UPDATE #unthead_info_pre SET unthread_contract_id=isnull(cg.source_contract_id,'9888888')
--, unthread_deal_id=isnull(od.unthread_deal_id1,u.unthread_deal_id)
--,deal_volume=isnull(od.volume_used1,u.deal_volume)
-- FROM #unthead_info_pre u 
--left join #unthread_deals od on od.source_deal_header_id=abs(u.source_deal_header_id) and od.unthread_type='D'
--and u.unthread_deal_id1= od.unthread_deal_id1
--left join source_deal_header sdh on sdh.source_deal_header_id=od.unthread_deal_id1
--left join contract_group cg on cg.contract_id=sdh.contract_id
--and abs(u.unthread_deal_id)<>abs(u.source_deal_header_id)
-- WHERE u.unthread_type='D' AND CAST(u.source_deal_header_id AS INT)<0 --AND unthread_deal_id=ABS(u.source_deal_header_id)
-- and u.udf_tran_type <>'06' --and u.udf_tran_type<>'01'

update #unthead_info_pre set unthread_contract_id=isnull(cg.source_contract_id,'9888888')
FROM #unthead_info_pre u
	left join source_deal_header sdh on sdh.source_deal_header_id=u.unthread_deal_id
	left join contract_group cg on cg.contract_id=sdh.contract_id
where u.udf_tran_type ='06' and u.unthread_type='D' 
 
UPDATE #unthead_info_pre SET unthread_contract_id=isnull(cg.source_contract_id,'9888888') 
FROM #unthead_info_pre u 
	--left join optimizer_detail od on od.source_deal_header_id=ABS(u.source_deal_header_id) and od.up_down_stream='u'
	left join source_deal_header sdh on sdh.source_deal_header_id=u.unthread_deal_id
	left join contract_group cg on cg.contract_id=sdh.contract_id
	and abs(u.unthread_deal_id)<>abs(u.source_deal_header_id)
WHERE u.unthread_type='D'   --AND unthread_deal_id=ABS(u.source_deal_header_id)
  AND u.udf_tran_type='01'


--SELECT * FROM #unthread_deals
--select *	FROM #unthead_info_pre
--RETURN
  
--return

--  select * from #unthread_deals
--  select * from #unthead_info_pre


select 
	max(source_deal_header_id) source_deal_header_id 	 
	,header_contract_id   ,
	max(counterparty_id) counterparty_id,
	max(term_start) term_start,
	max(contract_id) contract_id,
	udf_tran_type	 ,
	leg_1_loc_rank,
	leg_2_loc_rank,
	leg_1_tsp_location ,
	isnull(ltrim(str(dbo.FNAPipelineRound(1,sum(deal_volume),0) ,12,0)),'N/A') deal_volume	,
	leg_2_tsp_location,
	max(from_term )	 from_term
	,max(to_term )	 to_term
	,max(EDI_text) EDI_text,max(EDI_head_text) EDI_head_text,max(EDI_template_header_id) EDI_template_header_id,max(EDI_template_detail_id	) EDI_template_detail_id
	,max(no_of_lines_header_text )	 no_of_lines_header_text
	,max(no_of_lines_footer_text)	no_of_lines_footer_text
	,max(no_of_lines_body_text ) no_of_lines_body_text
	,max(source_deal_detail_id)	 source_deal_detail_id
	, max(leg_1_location_id) leg_1_location_id, max(leg_2_location_id) leg_2_location_id 
	 --,dbo.FNAPipelineRound(1,sum(leg_2_deal_volume),0)  leg_2_deal_volume
    ,isnull(ltrim(str(dbo.FNAPipelineRound(1,dbo.FNAPipelineRound(1,sum(deal_volume),0) *(1-max(fuel_loss)),0) ,12,0)),'N/A') leg_2_deal_volume    
	,max(fuel_loss )   fuel_loss
	--from_un_contract_id,
	--to_un_contract_id
into  #thead_info --   select * from #thead_info 
from 
	#thead_info_pre
group by header_contract_id,leg_2_tsp_location, leg_1_tsp_location,udf_tran_type, leg_1_loc_rank ,	  leg_2_loc_rank
	-- ,from_un_contract_id, to_un_contract_id 

--select * from #unthead_info_pre
--select * from #thead_info
  --select * from #thead_info where header_contract_id=3563 AND leg_1_tsp_location=1255953 AND leg_1_loc_rank=168
  --select * from #unthead_info_pre where header_contract_id=3563 AND unthread_tsp_location=1255953 AND unthread_location_rank=168

	
select 
	max(#unthead_info_pre.source_deal_header_id) source_deal_header_id,max(#unthead_info_pre.counterparty_id) counterparty_id 
	,max(#unthead_info_pre.term_start) term_start,DUNS_shipper,
	max(#unthead_info_pre.from_term) from_term,
	max(#unthead_info_pre.to_term) to_term,
	#unthead_info_pre.header_contract_id,		
       isnull(ltrim(str(dbo.FNAPipelineRound(1,sum(deal_volume),0),12,0)),'N/A') deal_volume,
	--case when #unthead_info_pre.unthread_type ='D' and #unthead_info_pre.udf_tran_type='01'
	--	 then isnull(ltrim(str(dbo.FNAPipelineRound(1,max(agg.leg2_Deal_volume),0),12,0)),'N/A')  
	--	 else
--                     case when #unthead_info_pre.unthread_type ='D' and #unthead_info_pre.udf_tran_type='01'
--                     then
--                     --round(cast(isnull(ltrim(str(dbo.FNAPipelineRound(1,sum(cast((deal_volume/(1-0.0186)) as numeric(28,10))),0),12,0)),'N/A')*(1-0.0186) 
--                      --as numeric(28,10)),0)
--ltrim(str(dbo.FNAPipelineRound(1,CAST(isnull(ltrim(str(dbo.FNAPipelineRound(1,SUM(cast((deal_volume/(1-0.0186)) as numeric(28,10))),0),12,0)),'N/A') AS numeric(28,10))*(1-0.0186),0)))
--else                 
--isnull(ltrim(str(dbo.FNAPipelineRound(1,sum(cast(deal_volume as numeric(28,10))),0),12,0)),'N/A') end
--                        deal_volume,
	unthread_tsp_location	 ,
	contract_steam	   ,
	deal_orientation	   ,
	max(location_group)	 location_group  ,
	US_DW,
	max(unthread_deal_id) unthread_deal_id,
	unthread_contract_id ,#unthead_info_pre.unthread_type	,
	udf_tran_type	 
	, unthread_location_rank
	,max(EDI_text) EDI_text,max(EDI_head_text) EDI_head_text,max(EDI_template_header_id) EDI_template_header_id ,max(EDI_template_detail_id	) EDI_template_detail_id
	,max(no_of_lines_header_text) no_of_lines_header_text
	,max(no_of_lines_footer_text) no_of_lines_footer_text
	,max(no_of_lines_body_text) no_of_lines_body_text
	,max(source_deal_detail_id ) source_deal_detail_id
	,customer_duns_number
	,sum(deal_volume) deal_volume1,max(fuel_loss) fuel_loss
into 
	 #unthead_info --   select * from #unthead_info
from   #unthead_info_pre 
--left join (
--	select  header_contract_id,counterparty_id, from_term, to_term,leg_2_tsp_location,leg_2_loc_rank, 'D' as unthread_type, SUM(leg_2_deal_volume) leg2_Deal_volume 
--	--,to_un_contract_idheader_contract_id
--	 	from  #thead_info --where leg_2_tsp_location='162382'
---- where  unthread_type  ='D'
--group by  header_contract_id,counterparty_id, from_term, to_term,leg_2_tsp_location,leg_2_loc_rank --,to_un_contract_id
--) agg on
--	--agg.to_un_contract_id=#unthead_info_pre.unthread_contract_id and
--	agg.header_contract_id=#unthead_info_pre.header_contract_id and
--	agg.counterparty_id=#unthead_info_pre.counterparty_id and
--	agg.from_term=#unthead_info_pre.from_term and
--	agg.to_term=#unthead_info_pre.to_term and
--	agg.leg_2_tsp_location=#unthead_info_pre.unthread_tsp_location and
--	agg.leg_2_loc_rank=#unthead_info_pre.unthread_location_rank 
--	and agg.unthread_type=#unthead_info_pre.unthread_type 
group by DUNS_shipper ,#unthead_info_pre.header_contract_id,unthread_tsp_location,	contract_steam	   ,
	deal_orientation  ,US_DW
	,unthread_contract_id 
	,#unthead_info_pre.unthread_type	,
	udf_tran_type	, unthread_location_rank  ,customer_duns_number

--select * from #unthead_info where udf_tran_type='07' --source_deal_header_id=-335414
--select * from #thead_info where  udf_tran_type='07'  --source_deal_header_id=-335414
----return

--UPDATE #thead_info SET deal_volume=u.deal_volume FROM #thead_info t INNER JOIN #unthead_info u ON ABS(t.source_deal_header_id)=u.source_deal_header_id 
--	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D'
--  WHERE  t.udf_tran_type='06'

UPDATE #thead_info SET deal_volume=leg_2_deal_volume  where 
	 CAST(source_deal_header_id AS INT)<0 AND   udf_tran_type='06'


--return

  --  select sum(cast(deal_volume as numeric(28,10))) deal_volue, contract_steam from #unthead_info_pre where header_contract_id=3563 group by contract_steam

--select sum(cast(deal_volume as numeric(28,10))) deal_volue,sum(cast(dbo.FNAPipelineRound(1,leg_2_deal_volume,0) as numeric(28,10))) deal_volue2 from #thead_info where contract_id=241



 -- select 
 --  u.deal_volume    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)
 --FROM #unthead_info t 
 -- INNER JOIN #unthead_info u ON cast(t.source_deal_header_id as int)=-1*cast(u.source_deal_header_id as int) 
	--AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D' AND  t.unthread_type='D'
 -- WHERE  t.udf_tran_type='06'
  
	
	
--select * from #unthead_info_pre t where CAST(t.source_deal_header_id AS INT)>0  and us_dw='dw'  and unthread_tsp_location='245615'

--	 select 
--   t.deal_volume,*    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)
-- FROM #unthead_info t 
--  --INNER JOIN #unthead_info u --ON cast(t.source_deal_header_id as int)=-1*cast(u.source_deal_header_id as int) 
--	where CAST(t.source_deal_header_id AS INT)>0 AND  t.unthread_type='D' -- AND  t.unthread_type='D'
--  and unthread_tsp_location=245615 


--UPDATE #unthead_info SET deal_volume=t.deal_volume FROM #thead_info t INNER JOIN #unthead_info u ON t.source_deal_header_id=u.source_deal_header_id 
--	AND CAST(t.source_deal_header_id AS INT)>0 --AND  u.unthread_type='D'
--  WHERE  t.udf_tran_type='07'



UPDATE #unthead_info SET deal_volume= dbo.FNAPipelineRound(1,deal_volume,0)    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)



   
   
UPDATE t SET deal_volume= u.deal_volume    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)
 FROM #unthead_info t 
  INNER JOIN #unthead_info u ON cast(t.source_deal_header_id as int)=-1*cast(u.source_deal_header_id as int) 
	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D' --AND  t.unthread_type='R'
  WHERE  t.udf_tran_type='06'  

  
UPDATE t SET deal_volume1= u.deal_volume1    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)
 FROM #unthead_info t 
  INNER JOIN #unthead_info u ON cast(t.source_deal_header_id as int)=-1*cast(u.source_deal_header_id as int) 
	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D' --AND  t.unthread_type='R'
  WHERE  t.udf_tran_type='06' 



--select * from #delta_unthead_dw
--select * from #tmp_deals where source_deal_header_id= 332641
--select * from #thead_info where header_contract_id=5573
--select * from #thead_info_pre where header_contract_id=5573
--select * from #unthead_info where header_contract_id=5573
--131325
--select * from #thead_info where header_contract_id = 3563 AND leg_1_tsp_location=1255953 AND udf_tran_type='01' AND leg_1_loc_rank=168
--select * from #unthead_info where header_contract_id = 3563 AND unthread_tsp_location=1255953 AND udf_tran_type='01' AND unthread_location_rank=168  


--select * from optimizer_header  where transport_deal_id in(332650,332715)

--select * from optimizer_detail where transport_deal_id in(332650,332715)
--Fixing round issue by updating volume unthread in max(deal_volume)
select 
	ui.header_contract_id,ui.unthread_tsp_location, ui.udf_tran_type, ui.unthread_location_rank,
	MAX(max_volume_us) max_volume_us,
	MAX(ui.deal_volume_us)-SUM(cast(nullif(t.deal_volume,'N/A') as numeric(28,10))) delta_rec_vol
	--,ui.deal_volume_us a,cast(nullif(t.deal_volume,'N/A') as numeric(28,10)) b
into #delta_unthead_us
from #thead_info t
cross apply
(
	select 
		u.header_contract_id,u.unthread_tsp_location, u.udf_tran_type, u.unthread_location_rank 
		,dbo.FNAPipelineRound(1,sum(cast(u.deal_volume as numeric)),0) deal_volume_us
		,max(cast(u.deal_volume as numeric)) max_volume_us
	from #unthead_info u
	where u.header_contract_id =t.header_contract_id
			and u.unthread_tsp_location =t.leg_1_tsp_location
			and t.udf_tran_type=u.udf_tran_type 
			and u.unthread_location_rank=t.leg_1_loc_rank 
			and u.US_DW='US' 
			and  u.udf_tran_type in ('06', '01')
	group by u.header_contract_id,u.unthread_tsp_location, u.udf_tran_type , u.unthread_location_rank 
) ui
GROUP BY ui.header_contract_id,ui.unthread_tsp_location, ui.udf_tran_type, ui.unthread_location_rank	
HAVING MAX(ui.deal_volume_us)<>SUM(cast(nullif(t.deal_volume,'N/A') as numeric(28,10)))



select 
	ui.header_contract_id,ui.unthread_tsp_location, ui.udf_tran_type, ui.unthread_location_rank,
	MAX(max_volume_dw) max_volume_dw
	, MAX(ui.deal_volume_dw)-SUM(cast(nullif(t.leg_2_deal_volume,'N/A') as numeric(28,10))) delta_del_vol
into #delta_unthead_dw --- select * from #delta_unthead_dw
from #thead_info t
cross apply
(
	select 
		u.header_contract_id,u.unthread_tsp_location, u.udf_tran_type, u.unthread_location_rank 
		,dbo.FNAPipelineRound(1,sum(cast(u.deal_volume as numeric)),0) deal_volume_dw
		,max(cast(u.deal_volume as numeric)) max_volume_dw	
	from #unthead_info u
	where u.header_contract_id =t.header_contract_id
			and u.unthread_tsp_location =t.leg_2_tsp_location 
			and t.udf_tran_type=u.udf_tran_type 
			and u.unthread_location_rank=t.leg_2_loc_rank
			and u.US_DW='DW' 
			and  u.udf_tran_type  in ('06', '01')
	group by u.header_contract_id,u.unthread_tsp_location, u.udf_tran_type , u.unthread_location_rank 
) ui




GROUP BY ui.header_contract_id,ui.unthread_tsp_location, ui.udf_tran_type, ui.unthread_location_rank
HAVING MAX(ui.deal_volume_dw)<>SUM(cast(nullif(t.leg_2_deal_volume,'N/A') as numeric(28,10)))

update #unthead_info set deal_volume=
 ltrim(str(cast(nullif(ui.deal_volume,'N/A') as numeric(28,10))-du.delta_rec_vol,12,0)) from  #delta_unthead_us du 
cross apply
(
	 select top(1) i.*  from #unthead_info i 
	 where i.header_contract_id=du.header_contract_id and i.unthread_tsp_location=du.unthread_tsp_location 
		and i.udf_tran_type=du.udf_tran_type and i.unthread_location_rank=du.unthread_location_rank 
		and i.US_DW='US' --and i.deal_volume=du.max_volume_us 
		and du.delta_rec_vol<>0
		order by abs(cast(i.deal_volume as numeric)) desc 

) flt 
inner join #unthead_info ui on ui.header_contract_id=flt.header_contract_id and ui.unthread_tsp_location=flt.unthread_tsp_location 
	and ui.udf_tran_type=flt.udf_tran_type and ui.unthread_location_rank=flt.unthread_location_rank 
	and ui.US_DW=flt.US_DW 
	and du.delta_rec_vol<>0
	and  ui.deal_orientation =flt.deal_orientation
    and ui.unthread_contract_id=flt.unthread_contract_id 
    and ui.unthread_type =flt.unthread_type



update ui set deal_volume=


 ltrim(str(cast(nullif(ui.deal_volume,'N/A') as numeric(28,10))-du.delta_del_vol,12,0)),deal_volume1=

 ltrim(str(cast(nullif(ui.deal_volume,'N/A') as numeric(28,10))-du.delta_del_vol,12,0))
-- ,ui.*
  from  #delta_unthead_dw du 
cross apply
(
	 select top(1) i.*  from #unthead_info i 
	 where i.header_contract_id=du.header_contract_id and i.unthread_tsp_location=du.unthread_tsp_location 
		and i.udf_tran_type=du.udf_tran_type and i.unthread_location_rank=du.unthread_location_rank 
		and i.US_DW='DW' --and i.deal_volume=du.max_volume_dw 
		and du.delta_del_vol<>0
		order by abs(cast(i.deal_volume as numeric)) desc 

) flt 
inner join #unthead_info ui on ui.header_contract_id=flt.header_contract_id and ui.unthread_tsp_location=flt.unthread_tsp_location 
	and ui.udf_tran_type=flt.udf_tran_type and ui.unthread_location_rank=flt.unthread_location_rank 
	and ui.US_DW=flt.US_DW and du.delta_del_vol<>0
	and  ui.deal_orientation =flt.deal_orientation
    and ui.unthread_contract_id=flt.unthread_contract_id 
    and ui.unthread_type =flt.unthread_type


/*
select source_deal_header_id,header_contract_id,leg_2_tsp_location,sum(cast(deal_volume as numeric)) as a,sum(cast(leg_2_deal_volume as numeric)) as b  from #thead_info
 where udf_tran_type=01 -- and leg_2_tsp_location=245615
 group by header_contract_id,udf_tran_type,leg_2_tsp_location,source_deal_header_id

select source_deal_header_id,header_contract_id,us_dw,sum(cast(deal_volume1 as numeric)) b from #unthead_info 
	where udf_tran_type=06 
	group by header_contract_id,us_dw,source_deal_header_id

select * from #thead_info
 where udf_tran_type=01 and leg_2_tsp_location=245615


select * from #unthead_info 
	where udf_tran_type=06  and us_dw='DW'
*/



	
--	group by us_dw


 
 --copied the update statement similar to above to match difference betweeen storage and injection.

 
   
--UPDATE t SET deal_volume= u.deal_volume    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)
-- FROM #unthead_info t 
--  INNER JOIN #unthead_info u ON cast(t.source_deal_header_id as int)=-1*cast(u.source_deal_header_id as int) 
--	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D' --AND  t.unthread_type='R'
--  WHERE  t.udf_tran_type='06'  

  
--UPDATE t SET deal_volume1= u.deal_volume1    --    dbo.FNAPipelineRound(1,t.deal_volume*(1-u.fuel_loss),0)
-- FROM #unthead_info t 
--  INNER JOIN #unthead_info u ON cast(t.source_deal_header_id as int)=-1*cast(u.source_deal_header_id as int) 
--	AND CAST(t.source_deal_header_id AS INT)<0 AND  u.unthread_type='D' --AND  t.unthread_type='R'
--  WHERE  t.udf_tran_type='06' 

	select header_contract_id, cg.contract_id ,unthread_contract_id,   us_dw,unthread_tsp_location,unthread_location_rank,sum(cast(deal_volume as numeric)) vol into #dw_vol 
	 from #unthead_info ti
	 inner join contract_group cg on ti.unthread_contract_id=cg.source_contract_id
	where udf_tran_type='01'
	 and us_dw='dw'
	  group by us_dw,unthread_tsp_location,unthread_location_rank, header_contract_id,unthread_contract_id,cg.contract_id

	select  header_contract_id,unthread_contract_id,us_dw,unthread_tsp_location,unthread_location_rank,sum(cast(deal_volume as numeric))  vol into #us_vol   from #unthead_info 
	where udf_tran_type='06'
	  and us_dw='us'
	  group by us_dw,unthread_tsp_location,unthread_location_rank, header_contract_id,unthread_contract_id



	select u.header_contract_id,u.unthread_tsp_location,u.unthread_location_rank,d.vol-u.vol delta_vol into #delta_vol from #dw_vol d inner join #us_vol u 
	on d.contract_id=u.header_contract_id and d.unthread_tsp_location=u.unthread_tsp_location 
	  and d.unthread_location_rank=u.unthread_location_rank
	  where d.vol<>u.vol


--	    select * from #us_vol

--	 --select * from  #delta_vol

	update #unthead_info set deal_volume=
	cast(deal_volume as numeric)+a.delta_vol  from #delta_vol a inner join  #unthead_info  b on
	a.header_contract_id=b.header_contract_id
	and a.unthread_tsp_location=b.unthread_tsp_location and a.unthread_location_rank=b.unthread_location_rank
	where b.udf_tran_type='06'
	 and  b.us_dw='us'


	
	update #us_vol set vol=vol+a.delta_vol  from #delta_vol a inner join  #us_vol  b on
	a.header_contract_id=b.header_contract_id
	and a.unthread_tsp_location=b.unthread_tsp_location and a.unthread_location_rank=b.unthread_location_rank
	--and  a.header_contract_id=b.header_contract_id-- and unthread_contract_id=unthread_contract_id


	select  ti.leg_1_tsp_location, ti.leg_1_loc_rank,sum(cast(deal_volume as numeric)) deal_volume,header_contract_id into #th_o6
	from #thead_info ti
	where ti.udf_tran_type='06' 
	group by ti.leg_1_tsp_location, ti.leg_1_loc_rank,header_contract_id

/*
	select  ti.contract_id,sum(cast(deal_volume as numeric)) deal_volume --into #th_o6
	from #thead_info ti
	where ti.udf_tran_type='06' 
	group by ti.contract_id
	order by 2


	select  US_DW,ti.unthread_contract_id,header_contract_id,sum(cast(deal_volume as numeric)) deal_volume --into #th_o6
	from #unthead_info ti
	where ti.udf_tran_type='06' 
	group by ti.unthread_contract_id,US_DW,header_contract_id

*/	


	update #thead_info set deal_volume= cast(ti.deal_volume as numeric)+(us.vol-t6.deal_volume) , leg_2_deal_volume=cast(ti.deal_volume as numeric)+(us.vol-t6.deal_volume)
	from #th_o6 t6
	cross  apply
	(
		select  sum(vol) vol  from  #us_vol 
			where t6.leg_1_tsp_location=unthread_tsp_location and t6.leg_1_loc_rank=unthread_location_rank and header_contract_id=t6.header_contract_id
	) us
	cross  apply
	(
		select max(source_deal_header_id) source_deal_header_id   from  #thead_info 
			where t6.leg_1_tsp_location=leg_1_tsp_location and t6.leg_1_loc_rank=leg_1_loc_rank and t6.header_contract_id=header_contract_id
	) t
	inner join #thead_info ti on t6.leg_1_tsp_location=ti.leg_1_tsp_location and t6.leg_1_loc_rank=ti.leg_1_loc_rank
		and ti.source_deal_header_id=t.source_deal_header_id
	and ti.udf_tran_type='06' 
	--group by unthread_location_rank,unthread_tsp_location
	--having count(1)>1


	select  unthread_tsp_location, unthread_location_rank,sum(cast(deal_volume as numeric)) deal_volume,unthread_contract_id,cg.contract_id into #unth_o6_dw
	from #unthead_info ui inner join contract_group cg on ui.unthread_contract_id=cg.source_contract_id
	where ui.udf_tran_type='06' --and ui.US_DW='DW' 
	group by  unthread_tsp_location, unthread_location_rank,unthread_contract_id,cg.contract_id


	select leg_2_tsp_location ,leg_2_loc_rank,header_contract_id,sum(cast(leg_2_deal_volume as numeric)) leg_2_deal_volume  
	into #leg2_06
	from  #thead_info where udf_tran_type='06' group by leg_2_tsp_location ,leg_2_loc_rank,header_contract_id
	

	 update #unthead_info set deal_volume=cast(ui.deal_volume as numeric)+(a.leg_2_deal_volume-b.deal_volume)
	 ,deal_volume1=cast(ui.deal_volume as numeric)+(a.leg_2_deal_volume-b.deal_volume)
	
--	select cast(ui.deal_volume as numeric),(a.leg_2_deal_volume-b.deal_volume)
	 from #leg2_06 a inner join #unth_o6_dw b
		on a.leg_2_tsp_location=b.unthread_tsp_location and a.leg_2_loc_rank=b.unthread_location_rank
		and a.header_contract_id=b.contract_id
	 cross apply
	 ( 
		select max(unthread_deal_id) unthread_deal_id from #unthead_info where  unthread_tsp_location=b.unthread_tsp_location and unthread_location_rank=b.unthread_location_rank
		and unthread_contract_id=b.unthread_contract_id

	 ) u
	inner join #unthead_info ui on u.unthread_deal_id=ui.unthread_deal_id and  ui.unthread_tsp_location=b.unthread_tsp_location and ui.unthread_location_rank=b.unthread_location_rank
	-- and	 ui.US_DW='DW' 
	 and ui.udf_tran_type='06' and ui.unthread_contract_id=b.unthread_contract_id
	 



--select sum(cast(deal_volume as numeric)) as a,sum(cast(leg_2_deal_volume as numeric)) as b from #thead_info where udf_tran_type=01 and leg_2_tsp_location=245615
	
--select sum(cast(deal_volume as numeric)),us_dw from #unthead_info 
--	where udf_tran_type=06 group by us_dw

--select * from #delta_unthead_dw
--select * from #delta_unthead_us
--select * from #unthead_info








if @flag='e' --call from edi schedule 
begin
	
	set @st='select * '+case when @thread_info_pre is null then '' else ' into '+@thread_info_pre end +'  from #thead_info_pre'
	--print @st
	exec(@st)

	set @st='select * '+case when @thread_info is null then '' else ' into '+@thread_info end +'  from #thead_info'
	--print @st
	exec(@st)
	
	
	set @st='select * '+case when @unthread_info_pre is null then '' else ' into '+@unthread_info_pre end +'  from #unthead_info_pre'
	--print @st
	exec(@st)

	set @st='select * '+case when @unthread_info is null then '' else ' into '+@unthread_info end +'  from #unthead_info'
	--print @st
	exec(@st)
	
	return
end

DECLARE  cur_source_value CURSOR LOCAL FOR
	select distinct k.EDI_template_value_position_id,k.value_column_name   from	 #EDI_template_header h 
	inner join  EDI_template_value_defination k on k.EDI_template_header_id=h.EDI_template_header_id  
OPEN cur_source_value
FETCH NEXT FROM cur_source_value INTO @EDI_template_value_position_id,@value_column_name  
WHILE @@FETCH_STATUS = 0   
BEGIN 
	----print '	----- start cursor----'
	----print '@EDI_template_value_position_id:'+cast(@EDI_template_value_position_id as varchar) +'  ,@value_column_name:'+@value_column_name
	----print'	-----__________________----'

   --select @unique_id=right('000000000000'+cast(isnull(last_incremental_value,0)+1 as varchar) ,9) from dbo.EDI_template_header where EDI_template_header_id=1

	if  @value_column_name in ('yymmdd','hhmm','ssmcs','yyyymmdd','yyyymmddhhmm','DUNS_shipper','DUNS_pipeline')
	begin
		update #EDI_template_header set EDI_text=replace(EDI_text,'#'+cast(@EDI_template_value_position_id as varchar(30))+'#'
			, case @value_column_name 
					when 'yymmdd' then @yymmdd
					when 'hhmm' then @hhmm
					when 'ssmcs' then right('000000000000'+cast(row_id+@unique_id as varchar) ,9)   --@ssmcs
					when 'yyyymmdd' then @yyyymmdd
					when 'yyyymmddhhmm' then @yyyymmddhhmm
					when 'DUNS_shipper' then isnull(@DUNS_shipper,'N/A')
					when 'DUNS_pipeline' then isnull(@DUNS_pipeline ,'N/A')
				end
		)
		,Footer_EDI_text=replace(Footer_EDI_text,'#'+cast(@EDI_template_value_position_id as varchar(30))+'#'
			, case @value_column_name 
					when 'yymmdd' then @yymmdd
					when 'hhmm' then @hhmm
					when 'ssmcs' then  right('000000000000'+cast(row_id+@unique_id as varchar) ,9) --@ssmcs
					when 'yyyymmdd' then @yyyymmdd
					when 'yyyymmddhhmm' then @yyyymmddhhmm
					when 'DUNS_shipper' then isnull(@DUNS_shipper,'N/A')
					when 'DUNS_pipeline' then isnull(@DUNS_pipeline ,'N/A')
				end
		)
	end
	--select * from #EDI_template_header
	
	if COL_LENGTH('tempdb..#thead_info', @value_column_name)  is not null
	begin
		set @st='
			update #thead_info set EDI_text=replace(EDI_text,''#'+cast(@EDI_template_value_position_id as varchar(30))+'#'',
				isnull('+@value_column_name+',''N/A'')) ,EDI_head_text=replace(EDI_head_text,''#'+cast(@EDI_template_value_position_id as varchar(30))+'#''
				,isnull('+@value_column_name+',''N/A'')) '

			--print @st
			exec(@st)
	end
	
		if COL_LENGTH('tempdb..#unthead_info', @value_column_name)  is not null
		begin
		set @st='
			update #unthead_info set EDI_text=replace(EDI_text,''#'+cast(@EDI_template_value_position_id as varchar(30))+'#'',
				isnull('+@value_column_name+',''N/A'')) ,EDI_head_text=replace(EDI_head_text,''#'+cast(@EDI_template_value_position_id as varchar(30))+'#''
				,isnull('+@value_column_name+',''N/A'')) '

		--print @st
		exec(@st)

	end
	----print'	----- end cursor----'
	----print '@EDI_template_value_position_id:'+cast(@EDI_template_value_position_id as varchar) +'  ,@value_column_name:'+@value_column_name
	----print'	-----__________________----'

	FETCH NEXT FROM cur_source_value INTO @EDI_template_value_position_id,@value_column_name
END

CLOSE cur_source_value
DEALLOCATE  cur_source_value
--print 'oooooooooo'
DECLARE @path VARCHAR(256) -- path for creating files  
DECLARE @file_name VARCHAR(256) -- filename to becreated
DECLARE @error_found CHAR(1)
SET @error_found = 'n'

SET @path = 'D:\EDI_output\'  

if object_id('tempdb..#file_output') is not null
drop table #file_output


create table #file_output (file_neme varchar(150) COLLATE DATABASE_DEFAULT ,file_content varchar(max) COLLATE DATABASE_DEFAULT , process_id VARCHAR(300) COLLATE DATABASE_DEFAULT ,[status] VARCHAR(20) COLLATE DATABASE_DEFAULT )

DECLARE @term DATETIME,@var_contract_id int	 ,@header_head_text VARCHAR(MAX)	,@header_footer_text VARCHAR(MAX)
	,@thread_header_text VARCHAR(MAX)	
	,@thread_text VARCHAR(MAX)
	,@unthread_header_text VARCHAR(MAX)	
	,@unthread_text VARCHAR(MAX)
	,@header_no_of_lines int
	,@total_detail_header_footer_line_no int
	,@detail_header_footer_line_no int
	,@no_of_lines_body_text	 int
	,@no_of_lines_text	 int   ,@row_id int, @client_contract_id varchar(1000)

DECLARE db_cursor CURSOR FOR  
	select DISTINCT h.term_start,h.edi_text,h.footer_edi_text,h.no_of_lines_header_text + h.no_of_lines_footer_text  header_no_of_lines,h.row_id,c.contract_id, replace(cg.source_contract_id,' ','_') source_contract_id 
	from #EDI_template_header h
	cross join 	#list_contract c
	cross apply (select top(1) * from #thead_info where cast(header_contract_id as varchar(100))= c.contract_id ) a
	left join contract_group cg on cast(cg.contract_id as varchar(100)) = c.contract_id
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @term,@header_head_text,@header_footer_text  ,@header_no_of_lines ,@row_id ,@var_contract_id, @client_contract_id

WHILE @@FETCH_STATUS = 0   
BEGIN   
		SELECT @thread_header_text=null	,@thread_text=null ,@unthread_header_text=null	,@unthread_text=NULL ,@total_detail_header_footer_line_no=0	,@no_of_lines_body_text=0
	
		sELECT @thread_text='' ,@unthread_text=''  ,@total_detail_header_footer_line_no=0,@detail_header_footer_line_no=0	,@no_of_lines_body_text=0

		select  @thread_header_text  =	edi_head_text
		from   #thead_info
		WHERE term_start=@term  AND header_contract_id=@var_contract_id
		select  @detail_header_footer_line_no  =isnull(@detail_header_footer_line_no,0)+	t.no_of_lines_header_text +t.no_of_lines_footer_text
		from ( select top(1) *  from #thead_info  
				WHERE term_start=@term  AND header_contract_id=@var_contract_id
				) t

			select  @unthread_header_text  =	SUBSTRING(t.edi_head_text,1,LEN(t.edi_head_text)-1)+'U'
		from   #thead_info	t
		WHERE term_start=@term  AND header_contract_id=@var_contract_id
	 
			select 	@detail_header_footer_line_no=@detail_header_footer_line_no +u.no_of_lines_header_text +u.no_of_lines_footer_text
			from ( select top(1) *  from #unthead_info  
				WHERE term_start=@term  AND header_contract_id=@var_contract_id
				) u

		set @thread_header_text=@thread_header_text+char(10)

		select @thread_header_text=ISNULL(@thread_header_text,'')+ edi_text 
				, @no_of_lines_body_text=@no_of_lines_body_text+no_of_lines_body_text
		from #thead_info
		WHERE term_start=@term  AND header_contract_id=@var_contract_id

		set @unthread_header_text=@unthread_header_text+char(10)
		
		select @unthread_header_text=ISNULL(@unthread_header_text,'')+ edi_text 
				, @no_of_lines_body_text=@no_of_lines_body_text+no_of_lines_body_text
		from #unthead_info 
		WHERE term_start=@term  AND header_contract_id=@var_contract_id
		order by deal_orientation

		select  @thread_text=@thread_text+@thread_header_text ,@unthread_text=@unthread_text+@unthread_header_text

		set @total_detail_header_footer_line_no	=@total_detail_header_footer_line_no  +@detail_header_footer_line_no

		SET @file_name =	ISNULL(@DUNS_pipeline,CAST(@to_partner AS VARCHAR))+'_'+ ISNULL(@DUNS_shipper+ '_','')+cast(@client_contract_id as varchar) +'_'+right('000000000000'+cast(@row_id+@unique_id as varchar) ,9)+'.txt'

		set @no_of_lines_text=@header_no_of_lines +@total_detail_header_footer_line_no+@no_of_lines_body_text
		--select @header_no_of_lines , @total_detail_header_footer_line_no, @no_of_lines_body_text

		--select @thread_header_text,@unthread_header_text,@thread_text,@unthread_text

		--select @no_of_lines_text-20
 		set @header_footer_text=replace(@header_footer_text,'#total_line_number#',right('000000000'+cast(@no_of_lines_text-10 as varchar),9))

		--select @header_head_text , @thread_text,@unthread_text,@header_footer_text	
				

		UPDATE dbo.EDI_template_header SET last_incremental_value=@row_id+@unique_id  where EDI_template_header_id=1

		DECLARE @thread_info_detail VARCHAR(300), 
				@unthread_info_detail VARCHAR(300),
				@thread_info_summary VARCHAR(300),
				@unthread_info_summary VARCHAR(300),
				@p_id VARCHAR(300)
		
		SET @p_id = dbo.FNAGETNewID()
		SET @thread_info_detail = dbo.FNAProcessTableName('thread_info_detail', 'system', @p_id)
		SET @unthread_info_detail = dbo.FNAProcessTableName('unthread_info_detail', 'system', @p_id)
		SET @thread_info_summary = dbo.FNAProcessTableName('thread_info_summary', 'system', @p_id)
		SET @unthread_info_summary = dbo.FNAProcessTableName('unthread_info_summary', 'system', @p_id)

		IF OBJECT_ID(@thread_info_detail) IS NOT NULL
			EXEC('DROP TABLE ' + @thread_info_detail)

		IF OBJECT_ID(@unthread_info_detail) IS NOT NULL
			EXEC('DROP TABLE ' + @unthread_info_detail)

		IF OBJECT_ID(@thread_info_summary) IS NOT NULL
			EXEC('DROP TABLE ' + @thread_info_summary)

		IF OBJECT_ID(@unthread_info_summary) IS NOT NULL
			EXEC('DROP TABLE ' + @unthread_info_summary)

		SET @st = 'SELECT * INTO ' + @thread_info_detail + ' FROM #thead_info_pre WHERE header_contract_id = ' + CAST(@var_contract_id AS VARCHAR(10)) + '
				   SELECT * INTO ' + @unthread_info_detail + ' FROM #unthead_info_pre WHERE header_contract_id = ' + CAST(@var_contract_id AS VARCHAR(10)) + '
				   SELECT * INTO ' + @thread_info_summary + ' FROM #thead_info WHERE header_contract_id = ' + CAST(@var_contract_id AS VARCHAR(10)) + '
				   SELECT * INTO ' + @unthread_info_summary + ' FROM #unthead_info WHERE header_contract_id = ' + CAST(@var_contract_id AS VARCHAR(10)) + '		  
				  '
		EXEC(@st)

	/* file writing
		
			if object_id('tempdb..#tmp_edi_file') is not null
				drop table #tmp_edi_file

			select  @header_head_text --+CHAR(10) --+CHAR(10)
					+ @thread_text  --+CHAR(10)			
					+@unthread_text --+CHAR(10)
					+@header_footer_text				
			as  edi_text into #tmp_edi_file 

			exec('select *  into '+@edi_txt_table+' from  #tmp_edi_file') 

			SET @st='INSERT INTO #bcp_status EXEC xp_cmdshell ''bcp "'+@edi_txt_table+'" out "'+@path + @file_name+'"  -c -U -T -S "'+@server+'"''' 

			----print @st
	   
			--select * from #tmp_edi_file
			TRUNCATE TABLE #bcp_status
		
			exec(@st)

			IF EXISTS(SELECT 1 FROM #bcp_status WHERE status_desc LIKE '%rows copied.')
				SELECT ' File:' +	@path + @file_name  +' is created successfully.' [Status]


		--   end  file writing  */

		select @unthread_header_text='',@thread_header_text =''

		--		FETCH NEXT FROM db_cursor1 INTO @thread_header_text,@unthread_header_text ,@detail_header_footer_line_no  
		--END   

		--CLOSE db_cursor1   
		--DEALLOCATE db_cursor1
		 
		--### Error Handling
				IF EXISTS(SELECT 'X' FROM #thead_info_pre WHERE 
						header_contract_id = @var_contract_id  
						AND (header_contract_id IS NULL 
						OR NULLIF(NULLIF(udf_tran_type,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_1_loc_rank,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_2_loc_rank,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_1_tsp_location,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_2_tsp_location,''),'N/A') IS NULL 
						--OR NULLIF(NULLIF(from_un_contract_id,''),'N/A') IS NULL 
						--OR NULLIF(NULLIF(to_un_contract_id,''),'N/A') IS NULL
						) 
					)
				SET @error_found = 'y'


				IF EXISTS(SELECT 'X' FROM #unthead_info_pre WHERE 
						header_contract_id = @var_contract_id  
						AND (NULLIF(NULLIF(DUNS_shipper,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(customer_duns_number,''),'N/A') IS NULL
						OR NULLIF(NULLIF(unthread_tsp_location,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(contract_steam,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(deal_orientation,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(unthread_contract_id,''),'N/A') IS NULL) 
					)		
	
				SET @error_found = 'y'

				IF @error_found = 'y'
				BEGIN
	
					INSERT INTO source_system_data_import_status(Process_id, code, module, source, type, description, recommendation, create_ts, create_user, rules_name) 
					SELECT @p_id
						, 'Error'
						, 'EDI'
						, 'EDI File'
						, 'Data Error'
						, '<a href="javascript: second_level_drill(''EXEC spa_get_import_process_status_detail^' + @p_id + '^,^EDI File^'')"></a>'
						,'<span style="cursor: pointer;" onclick="edi_summary_detail_report(''s'',''' + @p_id + ''')"><font color="#0000ff"><u>Summary</u></font></span> <span style="cursor: pointer;" onclick="edi_summary_detail_report(''d'',''' + @p_id + ''')"><font color="#0000ff"><u>Detail</u></font></span>'
						, getdate()
						, dbo.fnadbuser()
						, 'EDI File Generation (''File Creation'')'

					INSERT INTO source_system_data_import_status_detail(process_id,source,type,description,import_file_name,create_ts,create_user,type_error)
					SELECT	DISTINCT @p_id
							, 'EDI File'
							, 'Data Error for Deal: '+
							'('+'<span style="cursor: pointer;" onclick="parent.parent.parent.TRMHyperlink(10131010,'+CAST(source_deal_header_id AS VARCHAR)+',''n'',''NULL'')"><font color="#0000ff"><u>'+CAST(source_deal_header_id AS VARCHAR)+'</u></font></span>'+')' ,
							CASE WHEN header_contract_id IS NULL THEN 'Transportation Contract Cannot be blank'
								WHEN NULLIF(NULLIF(udf_tran_type,''),'N/A') IS NULL THEN 'TOS cannot be blank'
								WHEN NULLIF(NULLIF(leg_1_loc_rank,''),'N/A') IS NULL THEN 'Upstream Rank cannot be blank'
								WHEN NULLIF(NULLIF(leg_2_loc_rank,''),'N/A') IS NULL THEN 'Downstream Rank cannot be blank'
								WHEN NULLIF(NULLIF(leg_1_tsp_location,''),'N/A') IS NULL THEN 'Upstream Location DR cannot be blank'
								WHEN NULLIF(NULLIF(leg_2_tsp_location,''),'N/A') IS NULL THEN 'Downstream Location DR cannot be blank'
								--WHEN NULLIF(NULLIF(from_un_contract_id,''),'N/A') IS NULL  THEN 'Upstream Contract cannot be blank'
								--WHEN NULLIF(NULLIF(to_un_contract_id,''),'N/A') IS NULL THEN 'Downstream Contract cannot be blank'
							END [description]
							, NULL
							, getdate()
							, dbo.fnadbuser()
							, 'Data Error'
					FROM 
						#thead_info_pre
					WHERE
						header_contract_id = @var_contract_id  
						AND(header_contract_id IS NULL 
						OR NULLIF(NULLIF(udf_tran_type,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_1_loc_rank,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_2_loc_rank,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_1_tsp_location,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(leg_2_tsp_location,''),'N/A') IS NULL 
						--OR NULLIF(NULLIF(from_un_contract_id,''),'N/A') IS NULL 
						--OR NULLIF(NULLIF(to_un_contract_id,''),'N/A') IS NULL
						) 

					INSERT INTO source_system_data_import_status_detail(process_id,source,type,description,import_file_name,create_ts,create_user,type_error)
					SELECT	DISTINCT @p_id
							, 'EDI File'
							, 'Data Error for Deal: '+
							'('+'<span style="cursor: pointer;" onclick="parent.parent.parent.TRMHyperlink(10131010,'+CAST(source_deal_header_id AS VARCHAR)+',''n'',''NULL'')"><font color="#0000ff"><u>'+CAST(source_deal_header_id AS VARCHAR)+'</u></font></span>'+')' ,
							CASE WHEN NULLIF(NULLIF(DUNS_shipper,''),'N/A') IS NULL THEN 'Shipper DUNS cannot be blank'
								WHEN NULLIF(NULLIF(customer_duns_number,''),'N/A') IS NULL THEN 'Customer DUNS cannot be blank'
								WHEN NULLIF(NULLIF(unthread_tsp_location,''),'N/A') IS NULL THEN 'Upstream/Downstream Location DR cannot be blank'
								WHEN NULLIF(NULLIF(contract_steam,''),'N/A') IS NULL THEN 'Contract Stream cannot be blank'
								WHEN NULLIF(NULLIF(deal_orientation,''),'N/A') IS NULL THEN 'Deal Orientation cannot be blank'
								WHEN NULLIF(NULLIF(unthread_contract_id,''),'N/A') IS NULL THEN 'Upstream/Downstream Contract cannot be blank '
							END [description]
							, NULL
							, getdate()
							, dbo.fnadbuser()
							, 'Data Error'
					FROM 
						#unthead_info_pre
					WHERE
						header_contract_id = @var_contract_id  
						AND (NULLIF(NULLIF(DUNS_shipper,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(customer_duns_number,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(unthread_tsp_location,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(contract_steam,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(deal_orientation,''),'N/A') IS NULL 
						OR NULLIF(NULLIF(unthread_contract_id,''),'N/A') IS NULL) 
	
				END

				
			insert into #file_output (file_neme ,file_content, process_id,[status])
			values (
				@file_name
				, @header_head_text --+CHAR(10) --+CHAR(10)
				+ @thread_text  --+CHAR(10)			
				+@unthread_text --+CHAR(10)
				+@header_footer_text
				, @p_id	
				, CASE WHEN  @error_found = 'y' THEN 'dataerror' ELSE 'success' END	
			)

		
		SET @error_found = 'n'
       FETCH NEXT FROM db_cursor INTO @term,@header_head_text,@header_footer_text ,@header_no_of_lines,@row_id ,@var_contract_id,@client_contract_id    
END   

CLOSE db_cursor   
DEALLOCATE db_cursor



/*Error Handling*/
--select * from #thead_info_pre
--update #thead_info_pre set header_contract_id = null where source_deal_header_id=243192
--update #unthead_info_pre set DUNS_shipper = null where source_deal_header_id=243192



if exists(select top 1 1 from #file_output)
	select  [status], file_neme [file_name],dbo.FNAURLEncode(file_content) [file_content], process_id [process_id] from  #file_output
else select 'empty' [status]

end try
begin catch
	select 'error' [status]
end catch
