

/****** Object:  StoredProcedure [dbo].[spa_rec_production_report]    Script Date: 09/01/2009 01:15:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_production_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_production_report]
/****** Object:  StoredProcedure [dbo].[spa_rec_production_report]    Script Date: 09/01/2009 01:15:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_rec_production_report]                   
 @sub_entity_id varchar(100),             		
 @strategy_entity_id varchar(100) = NULL,             
 @book_entity_id varchar(100) = NULL,  
 @assignment_type int,           
 @assigned_state int = null,            
 @generator_id int = null,            
 @technology int = null,             
 @buy_sell_flag varchar(1) = null,             
 @generation_state int=null,
 @reporting_year int= null,
 @assigned_year int=null,
 @table_name varchar(100)=null

 AS            




BEGIN            
SET NOCOUNT ON            
----===================================================
/*
DECLARE @sub_entity_id varchar(100)             		
DECLARE @strategy_entity_id varchar(100) 
DECLARE @book_entity_id varchar(100) 
DECLARE @assignment_type int           
DECLARE @assigned_state int 
DECLARE @generator_id int 
DECLARE @technology int 
DECLARE @buy_sell_flag varchar(1) 
DECLARE @generation_state int
DECLARE @reporting_year int
DECLARE @assigned_year int


SET @sub_entity_id = 137
SET @strategy_entity_id  = NULL
SET @book_entity_id = NULL
SET @assignment_type = NULL
SET @assigned_state = NULL
SET @generator_id = null           
SET @technology = null            
SET @buy_sell_flag = null
SET @generation_state =null
SET @reporting_year = 2006
SET @assigned_year =null


drop table #ssbm
drop table #temp

*/

---====================================================

         
     
--***********************************************      

            
Declare @Sql_Select varchar(8000)            
Declare @Sql_Select3 varchar(8000)            
Declare @Sql_Select1 varchar(8000)            
Declare @Sql_Select2 varchar(8000)            
Declare @Sql_SelectS varchar(8000)            
Declare @Sql_SelectD varchar(8000)            
DECLARE @Sql_expiration_date VARCHAR(2000)            
            
DECLARE @Sql_expiration VARCHAR(8000)            
DECLARE @Sql_assignment VARCHAR(8000)            
DECLARE @Sql_activity VARCHAR(8000)            
DECLARE @Sql_assignment_target VARCHAR(8000)            
DECLARE @Sql_compliance VARCHAR(8000)            
Declare @Sql_Where varchar(8000)            
declare @ph_tbl varchar(8000)            
declare @process_id_dn varchar(50)            
declare @conv_tbl varchar(8000)            
            
Declare @term_where_clause varchar(8000)            

DECLARE @convert_uom_id int             
DECLARE @report_type int 



set @report_type=@assignment_type
set @convert_uom_id = 24      
            
--declare @report_identifier int            
--*****************For batch processing********************************        
        
-- DECLARE @str_batch_table varchar(1000)        
-- SET @str_batch_table=''        
-- IF @batch_process_id is not null        
--  SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         

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
            
SET @Sql_Select=            
'SELECT 
 --distinct  
 ssbm.fas_book_id,        
 sdh.source_deal_header_id,             
'                
         
SET @Sql_Select=@Sql_Select+'
            
  state.value_id State,            
 rg.code Generator,            
 tech.code Technology,            
 case  when (ssbm.fas_deal_type_value_id = 406) then ''Forecast''             
 when (ssbm.fas_deal_type_value_id = 405) then ''Target''             
 else ''Actual'' end target_actual,      
 sdh.term_start term_start,
 case when buy_sell_flag = ''s'' and sdh.status_value_id=5180 then -1 else 1 end * sdh.total_volume as total_volume,
 rg.tot_units as Units,
 rg.nameplate_capacity as net_capacity,
 rg.name as generator_name,
 rg.technology technology_id

FROM            
(select distinct sub_entity_id from #ssbm) ssbm2            
left outer join 
rec_generator rg on 
rg.legal_entity_value_id=ssbm2.sub_entity_id
LEFT OUTER JOIN
(            
 '

SET @Sql_Select1='                        
 select sdh.source_deal_header_id structured_deal_id,        
 max(sdd.source_deal_detail_id) source_deal_header_id,
 max(sdh.source_deal_header_id) source_deal_id,             
 max(sdd.buy_sell_flag) buy_sell_flag,             
 max(sdh.trader_id) trader_id, max(sdh.counterparty_id) counterparty_id,            
 max(sdh.source_deal_type_id) source_deal_type_id,            
 max(sdh.deal_date) deal_date,             
 max(sdh.generator_id) generator_id, sdh.assignment_type_value_id, sdh.status_value_id,              
 sdh.assigned_date, sdh.compliance_year, sdd.curve_id,  sdd.term_start,            
 max(sdd.deal_detail_description) deal_detail_description, max(sdd.fixed_price) fixed_price,            
 sum(case when  sdd.buy_sell_flag=''s'' and sdh.assignment_type_value_id is not null then sdd.deal_volume      
          else sdd.volume_left end ) deal_volume , NULL gis_cert_number, max(sdh.state_value_id) state_value_id,            
 NULL gis_value_id , max(sdd.deal_volume_uom_id) as deal_volume_uom_id,            
 max(sdh.source_system_book_id1) source_system_book_id1,            
 max(sdd.contract_expiration_date) contract_expiration_date,
 max(sdh.ext_deal_id) ext_deal_id,
 sum(sdd.deal_volume) total_volume,      
 max(sdh.option_flag) option_flag,
 max(sdh.option_type) option_type,
 max(sdh.option_excercise_type) option_excercise_type,
 max(sdd.option_strike_price) strike_price,       
 max(fixed_price_currency_id) as currency_id,                  
 max(sdd.leg) leg,       
 max(sdd.term_end) term_end       
  from                
 source_deal_header sdh inner join source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id             
WHERE 1=1 
 --and (case when  (sdd.buy_sell_flag=''s'' and sdh.assignment_type_value_id is not null) then sdd.deal_volume      
 --else sdd.volume_left end) <> 0
--AND (buy_sell_flag = ''b'' OR (buy_sell_flag = ''s'' AND ssbm.fas_deal_type_value_id = 406)
'            
         
              
 SET @sql_Select1 = @sql_Select1 + '               
      AND(sdh.status_value_id IS NULL or sdh.status_value_id not in(5170, 5179))              
    '               
              
              
--only for activity report            
              
 IF @buy_sell_flag IS NOT NULL              
  set @sql_Select1 = @sql_Select1 + ' AND (sdh.assignment_type_value_id is null and sdd.buy_sell_flag = ''' + @buy_sell_flag + ''')'              
            
             
--  IF @reporting_year IS NOT NULL              
--   set @sql_Select1 = @sql_Select1 + ' AND YEAR(sdd.term_start)<='+ cast(@reporting_year as varchar)             
IF @assigned_year IS NOT NULL              
  SET @sql_Select1 = @sql_Select1 + ' AND YEAR(sdh.assigned_date) = ' + CAST(@assigned_year as varchar)               

IF @assignment_type IS NOT NULL              
  SET @sql_Select1 = @sql_Select1 + ' AND sdh.assignment_type_value_id = ' + CAST(@assignment_type as varchar)               
        

set @sql_select1 =@sql_select1

set @sql_select3=
' group by sdh.source_deal_header_id, sdd.source_deal_detail_id, sdh.assignment_type_value_id,             
   sdh.status_value_id, sdh.assigned_date, sdh.compliance_year, sdd.curve_id, sdd.term_start          
)sdh            
'            
            
set @sql_select2 =            
'            
on rg.generator_id = sdh.generator_id 
LEFT OUTER JOIN #ssbm ssbm            
ON sdh.source_system_book_id1=ssbm.source_system_book_id1             
LEFT OUTER JOIN               
source_price_curve_def spcd ON sdh.curve_id = spcd.source_curve_def_id 
LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id                    
 left outer join static_data_value at on at.value_id = sdh.assignment_type_value_id              
 left outer join rec_gen_eligibility rge on 
 '+             
case WHEN @assigned_state IS NULL THEN 
' rge.state_value_id = ISNULL(sdh.state_value_id,rg.state_value_id)' else            
' rge.state_value_id = COALESCE(sdh.state_value_id,'+ CAST(@assigned_state as varchar)+ ',rg.state_value_id) ' END +            
' AND (rge.technology=rg.technology OR rge.technology IS NULL)
 AND rge.program_scope=spcd.program_scope_value_id
 AND (rge.tier_type=rg.tier_type OR rge.tier_type IS NULL)
left outer join state_properties sp on sp.state_value_id = ISNULL(rge.state_value_id,rg.state_value_id)              
left outer join static_data_value state on state.value_id = isnull(sdh.state_value_id, sp.state_value_id)              
left outer join static_data_value tech on tech.value_id = rg.technology                 
                    
left outer join source_traders st on st.source_trader_id = sdh.trader_id               
 left outer join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id               
 left outer join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id            

LEFT OUTER JOIN source_uom suom on suom.source_uom_id = sdh.deal_volume_uom_id
LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
 conv1.from_source_uom_id  = sdh.deal_volume_uom_id             
 AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv1.state_value_id = COALESCE(sp.state_value_id,sdh.state_value_id)
 AND conv1.assignment_type_value_id = isnull(at.value_id, 5149)
 AND conv1.curve_id = sdh.curve_id             

LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
 conv2.from_source_uom_id = sdh.deal_volume_uom_id             
 AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv2.state_value_id IS NULL
 AND conv2.assignment_type_value_id = isnull(at.value_id, 5149)
 AND conv2.curve_id = sdh.curve_id  

LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
conv3.from_source_uom_id =  sdh.deal_volume_uom_id             
 AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv3.state_value_id IS NULL
 AND conv3.assignment_type_value_id IS NULL
 AND conv3.curve_id = sdh.curve_id 
       
LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON            
 conv4.from_source_uom_id = sdh.deal_volume_uom_id
 AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv4.state_value_id IS NULL
 AND conv4.assignment_type_value_id IS NULL
 AND conv4.curve_id IS NULL

LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON            
 conv5.from_source_uom_id  = sdh.deal_volume_uom_id             
 AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv5.state_value_id = COALESCE(sp.state_value_id,sdh.state_value_id)
 AND conv5.assignment_type_value_id is null
 AND conv5.curve_id = sdh.curve_id 
 left outer join decaying_factor df on df.curve_id = sdh.curve_id 
 and df.gen_year=year(sdh.term_start)    
 left outer join gis_certificate gc on    
 gc.source_deal_header_id=sdh.source_deal_header_id    
 left outer join source_currency cur on cur.source_currency_id=sdh.currency_id  
Left outer join rec_generator_assignment rga on rg.generator_id=rga.generator_id
 and ((sdh.term_start between rga.term_start and rga.term_end) OR (sdh.term_end between rga.term_start and rga.term_end))	
WHERE 1=1 
--AND (ssbm.fas_deal_type_value_id <> 405)
AND (sdh.buy_sell_flag = ''b'' OR (buy_sell_flag = ''s'' 
AND ssbm.fas_deal_type_value_id = 406)  OR( buy_sell_flag = ''s'' and sdh.status_value_id=5180) OR buy_sell_flag is null)
'         

+ case when isnull(@assignment_type,5149)=5149 then ' AND (ISNULL(rga.exclude_inventory,rg.exclude_inventory) is null or ISNULL(rga.exclude_inventory,rg.exclude_inventory)=''n'') ' else '' end     
        
 IF @assigned_state IS NOT NULL              
  SET @sql_select2 = @sql_select2+' AND (state.value_id IN(' + cast(@assigned_state as varchar)+ ')) '              

  IF @generation_state IS NOT NULL              
   SET @sql_select2 = @sql_select2+' AND (rg.gen_state_value_id IN(' + cast(@generation_state as varchar)+ ')) '              

IF @generator_id IS NOT NULL              
  SET @sql_Select2 = @sql_Select2 + ' AND rg.generator_id = ' + CAST(@generator_id as varchar)               
  
            
       
set @Sql_Where=''            
 IF @technology IS NOT NULL              
  SET @Sql_Where =  ' AND rg.technology = ' + cast(@technology as varchar)              
    
           
             
SET @sql_select2=@sql_select2+@Sql_Where            
--print @sql_select2

--print (@sql_select+@sql_select1+@sql_select3+@sql_select2)

create table #temp (
fas_book_id int,
source_deal_header_id int,
term_start int,
generator_name varchar(100) COLLATE DATABASE_DEFAULT ,
units float,
net_capacity float,
state int,
technology varchar(100) COLLATE DATABASE_DEFAULT ,
target_actual varchar(100) COLLATE DATABASE_DEFAULT ,
Volume Float,
technology_id int
)
	


if @table_name is not null
begin
exec ('
	select fas_book_id,source_deal_header_id,year(term_start) term_start,generator_name,units,net_capacity,state,technology,target_actual,sum(total_volume)as volume, technology_id
	into '+@table_name+'
	 from('+
	@sql_select+@sql_select1+@sql_select3+@sql_select2+') a
	group by fas_book_id,source_deal_header_id,year(term_start),generator_name,units,net_capacity,state,technology,target_actual, technology_id
	' )

return
end

exec (' insert into #temp
	select fas_book_id,source_deal_header_id,year(term_start),generator_name,units,net_capacity,state,technology,target_actual,sum(total_volume)as volume, technology_id from('+
	@sql_select+@sql_select1+@sql_select3+@sql_select2+') a
	group by fas_book_id,source_deal_header_id,year(term_start),generator_name,units,net_capacity,state,technology,target_actual, technology_id
	' )



--select * into adiha_process.dbo.temp_prod from #temp

DECLARE @SQL VARCHAR(8000);

SET @SQL = 'SELECT T2.technology as Technology,ph.entity_name as [Acquisition Type],T2.generator_name as Generator,sd.description as Location,
		T2.units as Units,T2.net_capacity as [Net Capacity],';

SELECT 
	@SQL = @SQL + ' MAX(CASE WHEN T2.term_start = ' + CAST(@reporting_year-4 AS VARCHAR) 
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year-4 AS VARCHAR)+ '], 
			MAX(CASE WHEN T2.term_start = ' + CAST(@reporting_year-3 AS VARCHAR) 
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year-3 AS VARCHAR)+ '], 
			MAX(CASE WHEN T2.term_start = ' + CAST(@reporting_year-2 AS VARCHAR) 
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year-2 AS VARCHAR)+ '], 
			MAX(CASE WHEN T2.term_start = ' + CAST(@reporting_year-1 AS VARCHAR) 
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year-1 AS VARCHAR)+ '], 
			MAX(CASE WHEN T2.term_start = ' + CAST(@reporting_year AS VARCHAR) 
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year AS VARCHAR)+ '], 		
			MAX(CASE WHEN T2.target_actual=''Forecast'' and T2.term_start = ' + CAST(@reporting_year+1 AS VARCHAR)  
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year+1 AS VARCHAR)+'F'+ '], 		      	
			MAX(CASE WHEN T2.target_actual=''Forecast'' and T2.term_start = ' + CAST(@reporting_year+2 AS VARCHAR)  
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year+2 AS VARCHAR)+'F'+ '], 		      	
			MAX(CASE WHEN T2.target_actual=''Forecast'' and T2.term_start = ' + CAST(@reporting_year+3 AS VARCHAR)  

				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year+3 AS VARCHAR)+'F'+ '],
			MAX(CASE WHEN T2.target_actual=''Forecast'' and T2.term_start = ' + CAST(@reporting_year+4 AS VARCHAR)  
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year+4 AS VARCHAR)+'F'+ '],
			MAX(CASE WHEN T2.target_actual=''Forecast'' and T2.term_start = ' + CAST(@reporting_year+5 AS VARCHAR)  
				+ ' THEN T2.volume ELSE 0 END) AS [' + cast(@reporting_year+5 AS VARCHAR)+'F'+ ']'
 		      	
	
--FROM #temp group by term_start order by term_start

EXEC spa_print @SQL

SET @SQL = @SQL + '
FROM #temp GD
INNER JOIN (
	SELECT 
		fas_book_id, 
		technology,
		generator_name,
		units,
		net_capacity,
		state,
		target_actual,
		term_start, 
		SUM(volume) AS volume
	FROM #temp
	GROUP BY fas_book_id, 
		technology,
		generator_name,
		units,
		net_capacity,
		state,
		target_actual,
		term_start
) AS T2
ON ISNULL(GD.fas_book_id,'''') = ISNULL(T2.fas_book_id,'''') 
AND ISNULL(GD.term_start,'''') = ISNULL(T2.term_start,'''') and
GD.technology = T2.technology AND GD.state = T2.state and
GD.generator_name = T2.generator_name 
and ISNULL(GD.target_actual,'''') = ISNULL(T2.target_actual,'''')
left join static_data_value sd on sd.value_id=T2.state
left join portfolio_hierarchy ph on ph.entity_id=T2.fas_book_id
GROUP BY T2.technology,T2.generator_name,sd.description,ph.entity_name,T2.generator_name,T2.units,T2.net_capacity
order by T2.technology,ph.entity_name,T2.generator_name'

EXEC(@SQL);
END














