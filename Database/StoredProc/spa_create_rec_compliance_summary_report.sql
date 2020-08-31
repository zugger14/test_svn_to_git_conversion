

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_compliance_summary_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_compliance_summary_report]
GO
/****** Object:  StoredProcedure [dbo].[spa_create_rec_compliance_summary_report]    Script Date: 05/28/2009 14:08:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_create_rec_compliance_summary_report]   
@sub_entity_id varchar(100),   
@strategy_entity_id varchar(100) = NULL,   
@book_entity_id varchar(100) = NULL,   
@jurisdiction_id int = null,   
@compliance_year int=null,   
@compliance_type int,   
@uom_id int=null,         
@batch_process_id varchar(50)=NULL,  
@batch_report_param varchar(500)=NULL   
AS 
SET NOCOUNT ON   
  
-- DECLARE @compliance_year int   
-- DECLARE @compliance_type int   
-- DECLARE @jurisdiction_id int   
-- DECLARE @sub_entity_id varchar(100)   
-- DECLARE @strategy_entity_id varchar(100)   
-- DECLARE @book_entity_id varchar(100)   
-- set @jurisdiction_id = 5080   
-- SET @sub_entity_id = '138,137,136,135'   
-- set @compliance_type=5173   
-- set @compliance_year=2006   
-- DROP TABLE #ssbm   
-- DROP TABLE #transfer   
-- DROP TABLE #target   
-- drop table #temp_year   
-- drop table #temp   
-- drop table #temp_final   
--   
-- select * from adiha_process.dbo.temp_prod   
-- select * from #ssbm   
-- select * from static_data_value where type_id = 409   
  
-- DECLARE @compliance_type INT   
-- set @compliance_type = 5146   
-- @generator_id int = null,   
-- @technology int = null,   
-- @buy_sell_flag varchar(1) = null,   
-- @generation_state int=null,   
-- @reporting_year int= null,   
-- @assigned_year int=null,   
-- @table_name varchar(100)=null   
--   
DECLARE @Sql_Where varchar(5000)   
DECLARE @Sql_Select VARCHAR(8000)   
  
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
SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN ( ' + @sub_entity_id + ') '   
IF @strategy_entity_id IS NOT NULL   
SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'   
IF @book_entity_id IS NOT NULL   
SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '   
SET @Sql_Select=@Sql_Select+@Sql_Where   
EXEC (@Sql_Select)   
--------------------------------------------------------------   
CREATE INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])   
CREATE INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])   
CREATE INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])   
CREATE INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])   
CREATE INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])   
CREATE INDEX [IX_PH6] ON [#ssbm]([fas_book_id])   
CREATE INDEX [IX_PH7] ON [#ssbm]([stra_book_id])   
CREATE INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])   
  
--GET SOLD/TRANSFER   
-- select * from #ssbm   
  
  
-- select * from #ssbm where fas_deal_type_value_id = 405   
-- select * from static_data_value where type_id = 409   
  
select year(sdd.term_start) [year], sum(sdd.deal_volume) volume   
into #target   
from   
source_deal_header sdh inner join   
source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id inner join   
#ssbm s on s.source_system_book_id1 = sdh.source_system_book_id1 and   
s.source_system_book_id2 = sdh.source_system_book_id2 and   
s.source_system_book_id3 = sdh.source_system_book_id3 and   
s.source_system_book_id4 = sdh.source_system_book_id4 and   
s.fas_deal_type_value_id = 405   
group by year(sdd.term_start)   
  
  
  
select year(sdd.term_start) [year], sum(sdd.deal_volume) volume,   
sum(sdd.deal_volume * coalesce(spb.bonus_per, spb2.bonus_per, 0)) bonus   
into #transfer   
from rec_generator rg inner join   
source_deal_header sdh on sdh.generator_id = rg.generator_id inner join   
source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id inner join   
#ssbm s on s.source_system_book_id1 = sdh.source_system_book_id1 and   
s.source_system_book_id2 = sdh.source_system_book_id2 and   
s.source_system_book_id3 = sdh.source_system_book_id3 and   
s.source_system_book_id4 = sdh.source_system_book_id4   
left outer join   
state_properties_bonus spb on spb.state_value_id = @jurisdiction_id and   
spb.technology = rg.technology and   
sdd.term_start between spb.from_date and spb.to_date and   
spb.assignment_type_value_id = @compliance_type and   
spb.gen_code_value = rg.gen_state_value_id   
left outer join   
state_properties_bonus spb2 on spb2.state_value_id  = @jurisdiction_id and   
spb2.technology = rg.technology and   
sdd.term_start between spb2.from_date and spb2.to_date and   
spb2.assignment_type_value_id = @compliance_type and   
spb2.gen_code_value IS NULL   
  
where (sdd.buy_sell_flag = 's' and isnull(sdh.assignment_type_value_id, 5173) = 5173)   
group by year(sdd.term_start)   
  
---### populate data from production_reprt   
DECLARE @table_name varchar(128)   
DECLARE @Process_id varchar(100)   
DECLARE @user_id varchar(100)   
  
set @process_id=REPLACE(newid(),'-','')   
set @user_id=dbo.FNADBUser()   
  
set @table_name=dbo.FNAProcessTableName('production_table',@user_id,@process_id)   
  
--exec spa_rec_production_report @sub_entity_id, @strategy_entity_id, @book_entity_id, @compliance_type, @jurisdiction_id, NULL, NULL, NULL, NULL, @compliance_year, NULL,@table_name   
exec spa_rec_production_report @sub_entity_id, @strategy_entity_id, @book_entity_id, NULL, @jurisdiction_id, NULL, NULL, NULL, NULL, @compliance_year, NULL,@table_name   
  
  
--########################   
declare @count int   
  
set @count=0   
create table #temp_year([year] varchar(10) COLLATE DATABASE_DEFAULT )   
  
while @count<5   
BEGIN   
  
insert into #temp_year   
select cast(@compliance_year-@count as varchar)   
set @count=@count+1   
END   
  
set @count=1   
  
while @count<=10   
BEGIN   
  
insert into #temp_year   
select cast(@compliance_year+@count as varchar)+'F'   
set @count=@count+1   
END   
--#######################   
  
create table #temp([year] varchar(100) COLLATE DATABASE_DEFAULT ,[Retail Sales Projection] float,[RPS] Varchar(100) COLLATE DATABASE_DEFAULT ,[RPS Obligation] FLoat,[Transferred/Sold] float,   
Wind float,Hydro float,SOlar float,Other Float,[Total Yearly Generation] float,Bonus FLoat,[Carry Over] FLoat,Balance FLoat,Year_int int)   

create table #temp_final([id] int identity,[year] varchar(100) COLLATE DATABASE_DEFAULT ,[Retail Sales Projection] float,[RPS] Varchar(100) COLLATE DATABASE_DEFAULT ,[RPS Obligation] FLoat,[Transferred/Sold] float,   
Wind float,Hydro float,SOlar float,Other Float,[Total Yearly Generation] float,Bonus FLoat,[Carry Over] FLoat,Balance FLoat)   
  
-- cast(term_start as varchar) + case when (target_actual = 'Forecast') then 'F' else '' end as   
set @Sql_Select=   
'   
insert into #temp   
select cast(x.[Year] as varchar) + case when (target_actual = ''Forecast'') then ''F'' else '''' end as Year,   
max(isnull(srrd.total_retail_sales, 0)) [Retail Sales Projection] ,   
cast((max(isnull(per_profit_give_back, 0)) * 100) as varchar) + ''%'' RPS,   
isnull(max(tg.volume), max(isnull(srrd.total_retail_sales, 0)) * max(isnull(per_profit_give_back, 0))) [RPS Obligation],   
sum(case when (target_actual = ''Forecast'' or target_actual = '''') then isnull(f_sales.volume, 0) else isnull(tr.volume, 0) end) as [Transferred/Sold],   
sum(x.Wind) Wind, sum(x.Hydro) Hydro, sum(x.Solar) Solar, sum(x.Other) Other,   
(sum(x.Wind) + sum(x.Hydro) + sum(x.Solar) + sum(x.Other)) as [Total Yearly Generation],   

case when (target_actual = ''Forecast'' or target_actual = '''') then   
--sum((x.Wind + x.Hydro + x.Solar + x.Other - isnull(f_sales.volume, 0)) * isnull(bonus_per, 0))
isnull(max(tg.volume), max(isnull(srrd.total_retail_sales, 0)) * max(isnull(per_profit_give_back, 0)))* isnull(max(bonus_per), 0)
else sum((x.Wind_bon + x.Hydro_bon + x.Solar_bon + x.Other_bon - isnull(tr.bonus, 0))) end Bonus, -- nees to minus sold/xfer   

(sum(x.Wind) + sum(x.Hydro) + sum(x.Solar) + sum(x.Other)) -   
sum(case when (target_actual = ''Forecast'' or target_actual = '''') then isnull(f_sales.volume, 0) else isnull(tr.volume, 0) end) +   
case when (target_actual = ''Forecast'' or target_actual = '''') then   
--(x.Wind + x.Hydro + x.Solar + x.Other - isnull(f_sales.volume, 0)) * isnull(bonus_per, 0)   
isnull(max(tg.volume), max(isnull(srrd.total_retail_sales, 0)) * max(isnull(per_profit_give_back, 0)))* isnull(max(bonus_per), 0)
else sum((x.Wind_bon + x.Hydro_bon + x.Solar_bon + x.Other_bon - isnull(tr.bonus, 0))) end-   
isnull(max(tg.volume), max(isnull(srrd.total_retail_sales, 0)) * max(isnull(per_profit_give_back, 0)))   
[Carry Over],   
NULL as Balance,   
x.[Year]   
  
-- (sum(x.Wind_bon) + sum(x.Hydro_bon) + sum(x.Solar_bon) + sum(x.Other_bon) - sum(isnull(tr.bonus, 0))) Bonus -- nees to minus sold/xfer   
--Carry Over [Total Yearly Generation] + [Bonus] - [Transferred/Sold]   
--Balance This year''s Carry Over + last Years Balance   
  
  
from   
  
(select   
  
ISNULL(t.term_start,left(b.[year],4)) [Year],   
ISNULL(t.state,'+cast(@jurisdiction_id as varchar)+') state,   
isnull(t.target_actual,'''')target_actual,   
t.technology_id,   
case when(t.technology = ''Wind'') then sum(t.volume) else 0 end [Wind],   
case when(t.technology = ''Hydro'') then sum(t.volume) else 0 end [Hydro],   
case when(t.technology = ''Solar'') then sum(t.volume) else 0 end [Solar],   
case when(t.technology not in (''Wind'', ''Hydro'', ''Solar'')) then sum(t.volume) else 0 end [Other],   
  
case when(t.technology = ''Wind'') then sum(t.volume * coalesce(spb.bonus_per, spb2.bonus_per, 0)) else 0 end [Wind_bon],   
case when(t.technology = ''Hydro'') then sum(t.volume * coalesce(spb.bonus_per, spb2.bonus_per, 0)) else 0 end [Hydro_bon],   
case when(t.technology = ''Solar'') then sum(t.volume * coalesce(spb.bonus_per, spb2.bonus_per, 0)) else 0 end [Solar_bon],   
case when(t.technology not in (''Wind'', ''Hydro'', ''Solar'')) then sum(t.volume * coalesce(spb.bonus_per, spb2.bonus_per, 0)) else 0 end [Other_bon]   
  
--need sold deals that need bonus on them...   
  
-- coalesce(spb.bonus_per, spb2.bonus_per, 0) bonus_per   
  
from '+@table_name+' t   
LEFT outer join   
state_properties_bonus spb on spb.state_value_id  = t.state and   
spb.technology = t.technology_id and   
t.term_start between year(spb.from_date) and year(spb.to_date) and   
spb.assignment_type_value_id ='+cast(@compliance_type as varchar)+' and   
spb.gen_code_value = t.state   
left outer join   
state_properties_bonus spb2 on spb2.state_value_id  = t.state and   
spb2.technology = t.technology_id and   
t.term_start between year(spb2.from_date) and year(spb2.to_date) and   
spb2.assignment_type_value_id = '+cast(@compliance_type as varchar)+' and   
spb.gen_code_value IS NULL   
--LEFT #temp_year tmp_yr on tmp_yr.year=t.term_start   
RIGHT JOIN #temp_year b on t.[term_start]=cast(left(b.[year],4) as int)   
where (t.target_actual in (''Actual'', ''Forecast'') or t.target_actual is null)   
group by t.technology, t.technology_id, t.state, t.term_start,   
t.target_actual,left(b.[year],4) --, coalesce(spb.bonus_per, spb2.bonus_per, 0)   
  
) x   
left outer join state_rec_requirement_data srrd ON srrd.state_value_id = x.state and srrd.compliance_year = x.[Year]   
left outer join #transfer tr on tr.[year] = x.[Year]   
left outer join (select year(as_of_date) [year], curve_value bonus_per   
from source_price_curve   
where source_curve_def_id =   
(select source_curve_def_id from source_price_curve_def where curve_name =   
(select code from static_data_value where value_id = '+cast(@jurisdiction_id as varchar)+') + ''_Forecasted_Bonus_%'') and   
assessment_curve_type_value_id = 78 and --all monthly for now   
curve_source_value_id = 4500) f_bonus_per on f_bonus_per.[year] = x.[Year]   
left outer join (select year(as_of_date) [year], curve_value volume   
from source_price_curve   
where source_curve_def_id =   
(select source_curve_def_id from source_price_curve_def where curve_name =   
(select code from static_data_value where value_id ='+cast(@jurisdiction_id as varchar)+') + ''_Forecasted_Xfer_Sold'') and   
assessment_curve_type_value_id = 78 and --all monthly for now   
curve_source_value_id = 4500) f_sales on f_sales.[year] = x.[Year]   
left outer join #target tg on tg.[year] = x.[Year]   
group by cast(x.[Year] as varchar) + case when (target_actual = ''Forecast'') then ''F'' else '''' end,x.[Year], 
target_actual  
order by x.[Year]'   
  
--print @Sql_Select   
exec(@Sql_Select)   
  
insert into #temp_final   
--([year] ,[Retail Sales Projection],[RPS],[RPS Obligation],[Transferred/Sold],   
--Wind,Hydro,Solar,Other,[Total Yearly Generation],Bonus,[Carry Over],Balance)   
select   
ISNULL(b.[year],a.year) [Year],   
case when left(b.[year],4)=a.[year] then a.[Retail Sales Projection] else 0 end as [Retail Sales Projection],   
case when left(b.[year],4)=a.[year] then a.[RPS] else '' end as [RPS],   
case when left(b.[year],4)=a.[year] then a.[RPS Obligation] else '' end as [RPS Obligation],   
case when left(b.[year],4)=a.[year] then a.[Transferred/Sold] else '' end as [Transferred/Sold],   
case when left(b.[year],4)=a.[year] then a.[Wind] else '' end as [Wind],   
case when left(b.[year],4)=a.[year] then a.[Hydro] else '' end as [Hydro],   
case when left(b.[year],4)=a.[year] then a.[Solar] else '' end as [Solar],   
case when left(b.[year],4)=a.[year] then a.[Other] else '' end as [Other],   
case when left(b.[year],4)=a.[year] then a.[Total Yearly Generation] else '' end as [Total Yearly Generation],   
case when left(b.[year],4)=a.[year] then a.[Bonus] else '' end as [Bonus],   
case when left(b.[year],4)=a.[year] then a.[Carry Over] else '' end as [Carry Over],   
NULL as Balance   
from   
#temp a right join #temp_year b on left(b.[year],4)=a.[year]   
order by   
b.[year]


--## for batch process
DECLARE @str_batch_table varchar(max)        
SET @str_batch_table = ''        
IF @batch_process_id IS NOT NULL        
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id ,@batch_report_param, NULL, NULL, NULL)

SET @Sql_Select = ' 
SELECT [year], [Retail Sales Projection], [RPS], [RPS Obligation], [Transferred/Sold],   
Wind, Hydro, Solar, Other, [Total Yearly Generation], Bonus,[Carry Over],    
(SELECT SUM([Carry Over]) FROM #temp_final WHERE [id] <= a.[id]) Balance   
' + @str_batch_table + '
FROM   
#temp_final a'
--PRINT @Sql_Select
EXEC(@Sql_Select)
 
--*****************FOR BATCH PROCESSING**********************************            
 
IF  @batch_process_id IS NOT NULL        
BEGIN        
 SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
 EXEC(@str_batch_table)        
 
 DECLARE @report_name varchar(100)
 SET @report_name = 'Compliance Report'        
        
 SELECT @str_batch_table=dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_rec_compliance_summary_report', @report_name)         
 EXEC(@str_batch_table)        
 
END
   
--********************************************************************  


GO
