

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_generator_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_generator_report]
GO 
CREATE PROC [dbo].[spa_rec_generator_report]                   
 @sub_entity_id varchar(100),             		
 @strategy_entity_id varchar(100) = NULL,             
 @book_entity_id varchar(100) = NULL,  
 @generator_id int = null,            
 @technology int = null,             
 @generation_state int=null,
 @jurisdiction int=null,
 @gen_date_from datetime=null,
 @gen_date_to datetime=null,
 @generator_group varchar(100)=null	

AS
SET NOCOUNT ON             
BEGIN

DECLARE @sql_Where varchar(8000)
DECLARE @Sql_Select varchar(8000)
DECLARE @Sql_Select1 varchar(8000)

IF @gen_date_from IS NOT NULL AND @gen_date_to IS NULL            
 SET @gen_date_to = @gen_date_from            
IF @gen_date_from IS NULL AND @gen_date_to IS NOT NULL            
 SET @gen_date_from = @gen_date_to            


	--========Asset            
--******************************************************            
--CREATE source book map table and build index            
--*********************************************************            
SET @sql_Where = ''            
CREATE TABLE #ssbm(            
 source_system_book_id1 int,            
 source_system_book_id2 int,            
 source_system_book_id3 int,            
 source_system_book_id4 int,            
 fas_deal_type_value_id int,            
 book_deal_type_map_id int,            
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)            
----------------------------------            
SET @Sql_Select=            
'INSERT INTO #ssbm            
SELECT            
 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
FROM            
 source_system_book_map ssbm             
INNER JOIN            
 portfolio_hierarchy book (nolock)             
ON             
  ssbm.fas_book_id = book.entity_id             
INNER JOIN            
 Portfolio_hierarchy stra (nolock)            
 ON            
  book.parent_entity_id = stra.entity_id             
            
WHERE 1=1 '            
IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'            
 IF @book_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            
EXEC (@Sql_Select)            
--------------------------------------------------------------            
CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])                  
CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])                  
CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])                  
CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])                  
CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])                  
CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
            
--******************************************************            
--End of source book map table and build index            
--*********************************************************      

create table #temp(
	generator_id int,
	volume float
)


set @Sql_Select='
insert into #temp
 select 
	sdh.generator_id,             
	sum(case when sdd.buy_sell_flag=''s'' and sdh.status_value_id=5180 then -1 else 1 end * sdd.deal_volume) total_volume      
	from                
	source_deal_header sdh inner join source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id        
	INNER JOIN #ssbm ssbm   ON sdh.source_system_book_id1=ssbm.source_system_book_id1        
	WHERE 1=1 and (sdd.buy_sell_flag=''b'' or (sdd.buy_sell_flag=''s'' and sdh.status_value_id=5180))'+          
  case when  @gen_date_from IS NOT NULL then             
	  ' AND (sdd.term_start between CONVERT(DATETIME, ''' + cast(@gen_date_from as varchar)+ ''', 102) AND              
	    CONVERT(DATETIME, ''' + cast(@gen_date_to  as varchar)+ ''', 102)) '  else '' end +

' group by sdh.generator_id '
--print @Sql_Select

exec(@Sql_Select)

--###########################################
DECLARE @gen_id int,@meter_id INT,@recorderid varchar(1000)

create table #temp_meterid(
	generator_id int,
	meter_id varchar(500) COLLATE DATABASE_DEFAULT 
)

--set @meter_id=''
DECLARE cur1 cursor for 
select generator_id,meter_id from recorder_generator_map
open cur1
fetch next from cur1 into @gen_id,@meter_id	
	while @@FETCH_STATUS=0
		BEGIN

			select
			-- @meter_id='('+rgm.recorderid+ISNULL(' - '+mi.meter_serial_number,'')+ISNULL(' - '+dbo.FNADateformat(mi.meter_Certification),'')+')'
			@recorderid='('+mi.recorderid+')'
			 from recorder_generator_map rgm inner join meter_id mi on rgm.meter_id=mi.meter_id
	   		 where generator_id=@gen_id and rgm.meter_id=@meter_id
			
			if exists(select * from #temp_meterid where generator_id=@gen_id)
				update #temp_meterid set meter_id=meter_id+','+@recorderid where generator_id=@gen_id
			else
			 	insert into #temp_meterid values(@gen_id,@recorderid)

		fetch next from cur1 into @gen_id,@meter_id		
	END
CLOSE cur1
DEALLOCATE cur1



DECLARE @fromformat varchar(100)
DECLARE @toformat varchar(100)

	

if @gen_date_from is null 
   set @fromformat=''
else
	set @fromformat=left(datename(month,@gen_date_from),3)+' '+cast(day(@gen_date_from) as varchar)+' '+cast(right(year(@gen_date_from),2) as varchar)

if @gen_date_to is null 
   set @toformat=''
else
	set @toformat='-'+left(datename(month,@gen_date_to),3)+' '+cast(day(@gen_date_to) as varchar)+' '+cast(right(year(@gen_date_to),2) as varchar)

set @Sql_Select='
select 
	dbo.FNAEmissionHyperlink(2,12101710, rg.name,rg.generator_id,NULL) [Generator Name],       
	rg.generator_id as [Generator ID No.],
	rg.f_county as [Location],	
	sd.code as [Gen State],
	sd1.code as [Fuel or Energy Source],
	sd2.code as [Technology Type],
	left(datename(month,rg.first_gen_date),3)+''-''+right(year(rg.first_gen_date),4) as [Vintage (month/year)],
	rg.tot_units as [Units],
	rg.nameplate_capacity as [Nameplate Capacity (MW)],
	NULL as [Accredited Capacity],
	sc.counterparty_name as [Owned or PPA (List Counterparty)],
	ISNULL(sdd.volume,0) as [Generation '+@fromformat+ @toformat+'],
	assignment.other_assignment as [Assignment to Other Renewable],
	meter.meter_id +''&nbsp;'' [Recorder ID]	
from 
	rec_generator rg
	inner join (select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
	inner join static_data_value sd on sd.value_id=rg.gen_state_value_id
	inner join static_data_value sd2 on sd2.value_id=rg.technology
	left join static_data_value sd1 on sd1.value_id=rg.fuel_value_id
	left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id
	left join (select rg.generator_id,cast(sum(rge.percentage_allocation)*100 as varchar)+ 
	case when count(distinct rg.generator_id)>1 then  ''% to other jurisdictions''
	     else '' % to '' end+ max(sd.code) as other_assignment from
	rec_generator rg 
	inner join state_properties sp on sp.state_value_id=rg.state_value_id	
	inner join rec_gen_eligibility rge on rge.state_value_id=sp.state_value_id
	inner join static_data_Value sd on sd.value_id=rge.state_value_id
	group by rg.generator_id) assignment on assignment.generator_id=rg.generator_id	
	left join #temp_meterid meter on meter.generator_id=rg.generator_id
	left join #temp sdd on sdd.generator_id=rg.generator_Id
	where 1=1 
	--and isnull(generator_type,'''')<>''e''
	'
	+ case when @generator_id is not null then ' and rg.generator_id='+cast(@generator_id as varchar) else '' end
	+ case when @technology is not null then ' and rg.technology='+cast(@technology as varchar) else '' end
	+ case when @generation_state is not null then ' and rg.gen_state_value_id='+cast(@generation_state as varchar) else '' end
	+ case when @jurisdiction is not null then ' and rg.state_value_id='+cast(@jurisdiction as varchar) else '' end	 +
	+ case when @generator_group is not null then ' and rg.generator_group_name='''+@generator_group+'''' else '' end +
' order by rg.name '
--print @Sql_Select

	
exec(@Sql_Select)
END 












