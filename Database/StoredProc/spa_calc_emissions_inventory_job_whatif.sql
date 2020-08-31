/****** Object:  StoredProcedure [dbo].[spa_calc_emissions_inventory_job_whatif]    Script Date: 11/17/2009 22:26:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_emissions_inventory_job_whatif]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_emissions_inventory_job_whatif]
/****** Object:  StoredProcedure [dbo].[spa_calc_emissions_inventory_job_whatif]    Script Date: 11/17/2009 22:26:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************
Created By: Anal Shrestha
Created On:Feb 2007
This SP calculates the Emissions based on the formulas defined
-- exec spa_calc_emissions_inventory_job NULL, '2009-01-01','2009-01-31',NULL,NULL,NULL,2681,NULL,'r',290519
select * from static_data_value where type_id=14300
select * from rec_generator

exec spa_calc_emissions_inventory_job_whatif NULL, '2009-01-01','2009-01-31',NULL,NULL,NULL,3209,NULL,'r',290519
***********************************************/
CREATE PROCEDURE [dbo].[spa_calc_emissions_inventory_job_whatif]
	@as_of_date varchar(100),
	@term_start varchar(100)=NULL,
	@term_end varchar(100)=NULL,
	@sub_entity_id varchar(100)=NULL,
	@strategy_entity_id varchar(100)=NULL,
	@book_entity_id varchar(100)=NULL,
	@generator_id varchar(1000)=NULL,
	@emission_reduction char(1)=NULL,-- 'e'->emission,'r'->reduction,'b'->both
	@current_forecast char(1)=NULL,
	@forecast_type int=null,
	@criteria_id INT=NULL,
	@job_name varchar(100)=NULL,
	@process_table varchar(100)=null,
	@user_name varchar(100)=null
AS

--******************** Uncomment these to test
--	DECLARE  @as_of_date varchar(20)            
--	DECLARE  @term_start varchar(20)            
--	DECLARE  @term_end varchar(20)            
--
--	DECLARE  @sub_entity_id varchar(100)             		
--	DECLARE  @strategy_entity_id varchar(100) 
--	DECLARE  @book_entity_id varchar(100)              
--	DECLARE  @generator_id int
--	DECLARE @job_name varchar(100)
--	DECLARE @emission_reduction char(1)
--	DECLARE @current_forecast char(1)
--
--	SET @as_of_date = '2007-10-01'
--	SET @term_start = '2008-01-01'
--	SET @term_end = '2008-12-31'
--	--SET @as_of_date_TO = '2006-12-31'
--	SET @sub_entity_id = 135
--	SET @book_entity_id = 157
--	SET @emission_reduction='e'
--	SET @current_forecast='f'
--
--	drop table #ssbm 
--	drop table #temp    
--	drop table #formula_value
--	drop table #calc_status
--****************************************
--EXEC spa_print 'start :'+convert(varchar(100),getdate(),113)
if @process_table=''
set @process_table=null
-- if as_of_date is null then 
if @as_of_date='NULL'
	set @as_of_date=NULL
--if @as_of_date is null 
--	set @as_of_date=cast(cast(year(@term_start) as varchar)+'-12-31' as varchar)

if @term_start is null
	select @term_start=min(term_start) from ems_gen_input where generator_id in(@generator_id)
if @term_end is null
	select @term_end=max(term_start) from ems_gen_input where generator_id in(@generator_id)

if @current_forecast is null
	set @current_forecast='r'


--DECLARE @user_name varchar(100)
DECLARE @process_id varchar(100)
DECLARE @desc varchar(500)
DECLARE @url varchar(500)
DECLARE @Sql_Select varchar(8000)
DECLARE @Sql_Where varchar(1000)
DECLARE @show_heat_content_value_id int
set @user_name=dbo.fnadbuser()

set @show_heat_content_value_id=1202
if @user_name is null
	set @user_name=dbo.FNADBUser()
SET @process_id = REPLACE(newid(),'-','_')


IF @term_start IS NOT NULL AND @term_end IS NULL            
 SET @term_end = @term_start            

If @sub_entity_id = ''
	SET @sub_entity_id = NULL
If @strategy_entity_id = ''
	SET @strategy_entity_id  = NULL
If @book_entity_id = ''
	SET @book_entity_id = NULL
If @generator_id=''
	SET @generator_id = NULL


SET @sql_Where = ''            
CREATE TABLE #ssbm(                      
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)            

CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  

----------------------------------            
SET @Sql_Select=            
'INSERT INTO #ssbm            
SELECT                      
  book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
FROM            
 portfolio_hierarchy book (nolock)             
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

create table #total_month(
	[id] int identity(1,1),
	term_month datetime
)
declare @count_dcr int
set @count_dcr=datediff(month,@term_start,@term_end)


if @process_table is null
begin
	while @count_dcr>=0
	begin
		insert into #total_month(term_month)
		select 	dateadd(month,@count_dcr,@term_start)
		set @count_dcr=@count_dcr-1
	end
end


CREATE TABLE #calc_status
	(
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(5000) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
	)
------------------------------------------------------------
create table #temp(
	term_start datetime,
	term_end datetime,
	gen_start_date datetime,
	gen_end_date datetime,
	generator_id int,
	technology int,
	fuel_value_id int,
	state int,
	curve_id int,
	ems_source_model_id int,
	formula varchar(1000) COLLATE DATABASE_DEFAULT,
	formula_reduction varchar(500) COLLATE DATABASE_DEFAULT,
	uom_id int,
	frequency int,
	current_forecast char(1) COLLATE DATABASE_DEFAULT,
	char1 int,
	char2 int,
	char3 int,
	char4 int,
	char5 int,
	char6 int,
	char7 int,
	char8 int,
	char9 int,
	char10 int,
 	input_value FLOAT,
	formula_id int,
	formula_id_reduction int,
	sequence_number int,
	reduction char(1) COLLATE DATABASE_DEFAULT,
	heatcontent_formula varchar(500) COLLATE DATABASE_DEFAULT,
	heatcontent_uom_id int,
	input_id int,
	ems_generator_id int,
	char1_val varchar(100) COLLATE DATABASE_DEFAULT,
	char2_val varchar(100) COLLATE DATABASE_DEFAULT,
	char3_val varchar(100) COLLATE DATABASE_DEFAULT,
	char4_val varchar(100) COLLATE DATABASE_DEFAULT,
	char5_val varchar(100) COLLATE DATABASE_DEFAULT,
	char6_val varchar(100) COLLATE DATABASE_DEFAULT,
	char7_val varchar(100) COLLATE DATABASE_DEFAULT,
	char8_val varchar(100) COLLATE DATABASE_DEFAULT,
	char9_val varchar(100) COLLATE DATABASE_DEFAULT,
	char10_val varchar(100) COLLATE DATABASE_DEFAULT,
	no_of_units int,
	forecast_type int,
	formula_id_detail int,
	formula_id_reduction_detail int,
	granularity int,
	value_id_for int,
	input_output_id int
)
------------------------------------------------------------

select distinct rg.generator_id,rg.name,max(epr.as_of_date) published_date 
into #generator_published
from rec_generator rg INNER JOIN #ssbm ON #ssbm.fas_book_id = rg.fas_book_id
		inner join ems_publish_report epr on epr.sub_id=#ssbm.sub_entity_id 
		and isnull(epr.strategy_entity_id,#ssbm.stra_book_id)=#ssbm.stra_book_id 
		and isnull(epr.book_entity_id,#ssbm.fas_book_id)=#ssbm.fas_book_id
group by rg.generator_id,rg.name


set @Sql_Select='
insert into #temp
SELECT  
 	distinct
 	case when isnull(esi.constant_value,''n'')=''n'' then '+case when @process_table is not null then ' pt.term_start ' else 'COALESCE(egi.term_start,tm.term_month,'''+@term_start+''')' end+' else '''+@term_start+''' end,
 	case when isnull(esi.constant_value,''n'')=''n'' then '+case when @process_table is not null then ' pt.term_end ' else ' dateadd(month,1,COALESCE(egi.term_start,tm.term_month,'''+@term_start+'''))-1' end +' else '''+@term_end+''' end,
	rg.reduc_start_date,
	rg.reduc_end_date,	
  	rg.generator_id,
	rg.technology,
	rg.fuel_value_id,
	rg.gen_state_value_id,
	esmd.curve_id,
	esmd.ems_source_model_id,
 	case when isnull(rg.reduction_type,-1)<>-1 then '''' else REPLACE(isnull(fe2.formula,fe.formula),'' '','''') end as formula,
 	case when isnull(rg.reduction_type,-1)<>-1 then REPLACE(COALESCE(fe3.formula,fe1.formula,fe2.formula,fe.formula),'' '','''') else '''' end as formula_reduction,
	esmd.uom_id,
 	case when egi.estimate_type=''r'' then esm.input_frequency else esm.forecast_input_frequency end as frequency,
  	egi.estimate_type,
	char1,
	char2,
	char3,
	char4,
	char5,
	char6,
	char7,
	char8,
	char9,
	char10,
	input_value,
	fe.formula_id  as formula_id,
	fe1.formula_id as formula_id_reduction,
	ISNULL(fn.sequence_order,fn1.sequence_order) sequence_number,
	rg.reduction,
	CASE WHEN ISNULL(fn.show_value_id,fn1.show_value_id)='+CAST(@show_heat_content_value_id AS VARCHAR)+' THEN 	REPLACE(isnull(fe2.formula,fe.formula),'' '','''') ELSE
--		case when ISNULL(esi.heatcontent_uom_id,'''')='''' then ''NULL'' 
--		else ''dbo.FNAINPUT(''+cast(esi.ems_source_input_id as varchar)+'')*dbo.FNAEMSConv(''+cast(esi.ems_source_input_id as varchar)+'',1182,''+cast(esi.uom_id as varchar)+'',''+cast(esi.heatcontent_uom_id as varchar)+'',NULL)'' end 
		''NULL''	
		END as heatcontent,
	CASE WHEN ISNULL(fn.show_value_id,fn1.show_value_id)='+CAST(@show_heat_content_value_id AS VARCHAR)+' THEN ISNULL(esi.heatcontent_uom_id,39) else '''' end ,
	esi.ems_source_input_id,
	egi.ems_generator_id,
	esdv1.code,	
	esdv2.code,	
	esdv3.code,	
	esdv4.code,	
	esdv5.code,	
	esdv6.code,	
	esdv7.code,	
	esdv8.code,	
	esdv9.code,	
	esdv10.code,
	isnull(rg.tot_units,1),
	esf.forecast_type,
	ISNULL(fe2.formula_id,fe.formula_id)  as formula_id_detail,
	case when isnull(rg.reduction_type,-1)<>-1 THEN ISNULL(fe3.formula_id,fe1.formula_id)
	ELSE ISNULL(fe3.formula_id,fe1.formula_id) END  as formula_id_reduction_detail,
	ISNULL(fn.granularity,fn1.granularity),
	ISNULL(fn.show_value_id,fn1.show_value_id),
	esi.input_output_id

from
	rec_generator rg INNER JOIN #ssbm ON #ssbm.fas_book_id = rg.fas_book_id
	inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
	inner join (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id from 
				ems_source_model_effective where isnull(effective_date,''1900-01-01'')<='''+@term_start+''' group by generator_id) ab
	on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
	inner join 
		ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
	inner join
	  	ems_source_model_detail esmd on esmd.ems_source_model_id=esm.ems_source_model_id
	left join		 
		ems_input_map eim on eim.source_model_id=esm.ems_source_model_id	
	left join
		ems_source_input esi on esi.ems_source_input_id=eim.input_id  
		--and esi.input_output_id=1050 
 	left join 
	ems_gen_input egi on   egi.ems_input_id=esi.ems_source_input_id and egi.generator_id=rg.generator_id
 	left join ems_input_characteristics eic on eic.ems_source_input_id=esi.ems_source_input_id 
 	left join ems_static_data_type esdt on esdt.type_id=eic.type_id
	left join ems_source_formula esf on esf.ems_source_model_detail_id=esmd.ems_source_model_detail_id
		 --and esf.curve_id=esmd.curve_id	
		 and esf.forecast_type='+cast(@forecast_type as varchar)+'
 	left join 
 		formula_editor fe on fe.formula_id=ISNULL(esf.formula_id,esmd.formula_reporting_period)
 	left join 
 		formula_nested fn on  fe.formula_id =fn.formula_group_id
 	left join 
 		formula_editor fe2 on fe2.formula_id=fn.formula_id
	left join 
		formula_editor fe1 on fe1.formula_id=ISNULL(esf.formula_reduction,esmd.formula_forcast_reporting)

	left join 
		formula_nested fn1 on  fe1.formula_id =fn1.formula_group_id
	left join 
		formula_editor fe3 on fe3.formula_id=fn1.formula_id
	left join ems_static_data_value esdv1 on esdv1.value_id=egi.char1
	left join ems_static_data_value  esdv2 on esdv2.value_id=egi.char2
	left join ems_static_data_value  esdv3 on esdv3.value_id=egi.char3
	left join ems_static_data_value  esdv4 on esdv4.value_id=egi.char4
	left join ems_static_data_value  esdv5 on esdv5.value_id=egi.char5
	left join ems_static_data_value  esdv6 on esdv6.value_id=egi.char6
	left join ems_static_data_value  esdv7 on esdv7.value_id=egi.char7
	left join ems_static_data_value  esdv8 on esdv8.value_id=egi.char8
	left join ems_static_data_value  esdv9 on esdv9.value_id=egi.char9
	left join ems_static_data_value  esdv10 on esdv10.value_id=egi.char10
	left join #total_month tm on 1=1
	'+
	case when @process_table is not null then ' inner join '+@process_table+' pt on pt.generator_id=rg.generator_id
	and(input_value is not null and pt.term_start=egi.term_start or(input_value is null ))
	' else '' end
	+' where 1=1 and generator_type=''e''  
	and (input_value is not null  or(ISNULL(rg.is_hypothetical,''n'')=''y''))
	--and ((input_value is null and egi.ems_generator_id is null) or (input_value is not null))
	 AND 
	(egi.term_start is null AND (CONVERT(DATETIME, ''' + @term_start + ''', 102)>=rg.reduc_start_date AND CONVERT(DATETIME, ''' + @term_end + ''', 102)<=ISNULL(rg.reduc_end_date,CONVERT(DATETIME, ''' + @term_end + ''', 102)))
	OR
	  ((isnull(esi.constant_value,'''')<>''y'' and 
	  (egi.term_start between CONVERT(DATETIME, ''' + @term_start + ''', 102) AND              
	  CONVERT(DATETIME, ''' + @term_end + ''', 102) OR egi.term_end between CONVERT(DATETIME, ''' + @term_start + ''', 102) AND              
	  CONVERT(DATETIME, ''' + @term_end + ''', 102)) 
	or (esi.constant_value=''y''  and egi.term_start between egi.term_start  and egi.term_end))' + 
	' AND (egi.term_start>=rg.reduc_start_date AND egi.term_end<=ISNULL(rg.reduc_end_date,CONVERT(DATETIME, ''9999-01-01'', 102)))	
	' +
	case when @forecast_type is not null then 
		' AND esf.forecast_type= case when isnull(esi.constant_value,'''')<>''y'' then '+cast(@forecast_type as varchar)+' else esf.forecast_type end' 
	else '' end+
	'))'
	
	+case when @generator_id is not null then ' AND rg.generator_id in('+@generator_id+')' else '' end
	+case when @as_of_date is not null then ' AND ISNULL(rg.reduc_end_date,''01/01/9999'')>='+cast(@as_of_date as varchar) else '' end
	+ case when @forecast_type is not null then ' And esf.forecast_type='+cast(@forecast_type as varchar) else '' end
	--+ ' AND isnull(fe2.formula,fe.formula)  like ''%''+cast(esi.ems_source_input_id as varchar)+''%'' '
	
---- REMOVE THIS
	--+ ' And esmd.curve_id=183'

EXEC spa_print @Sql_Select

exec(@Sql_Select)



--##### check for the Published list and log error

insert into #calc_status 
	select distinct @process_id,'Error','Emissions Inventory','Run Emissions Inventory','Results', 
	 'Report has already been published for: '+name+' as of: '+dbo.fnadateformat(gp.published_date),''
	from 
		#generator_published gp join #temp tmp on gp.generator_id=tmp.generator_id
		and tmp.term_start<=gp.published_date

delete tmp 	
	from 
		#generator_published gp join #temp tmp on gp.generator_id=tmp.generator_id
		and tmp.term_start<=gp.published_date

---#########################################
	

--############################# Check for Data Exceptions
	CREATE TABLE #temp_data_exceptions(OpCo VARCHAR(100) COLLATE DATABASE_DEFAULT,Source_name VARCHAR(100) COLLATE DATABASE_DEFAULT,facility_id VARCHAR(100) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(100) COLLATE DATABASE_DEFAULT,term DATETIME, input VARCHAR(100) COLLATE DATABASE_DEFAULT)
	
	INSERT INTO #temp_data_exceptions
	EXEC spa_ems_exceptions_report 'a',NULL,NULL,NULL,@generator_id,NULL,NULL,NULL,NULL,NULL,NULL,@term_start,@term_end


	
	insert into #calc_status 
	SELECT 
		@process_id,'Error',
		'Emissions Inventory',
		'Run Emissions Inventory',
		'Results','No inputs found for the Source '+source_name+' for the input '+input+' for term '+dbo.fnadateformat(term),''
	FROM
		#temp_data_exceptions


--EXEC spa_print 'Temproray Table Populated :'+convert(varchar(100),getdate(),113)



--drop table #temp_char
create table #temp_char(
	[ID] int identity,
	generator_id int,
	ems_source_model_id int,
	input_id int,
	type_char_id int,
	type_id int,
	type int,
	conversion_type int,
	sequence_id int,
	system_value int,
	system_value_desc varchar(100) COLLATE DATABASE_DEFAULT
)
insert
into
	#temp_char(generator_id,ems_source_model_id,input_id,type_char_id,type_id,type,conversion_type,sequence_id,system_value,system_value_desc)
select 
	distinct
	rg.generator_id,
	esm.ems_source_model_id,
	eim.input_id,
	eic.type_char_id,
	eic.type_id as type_id,
	esdt.static_data_type as [type],
	--ect.ems_conversion_type_value_id
	--NULL,
	NULL,
	eic.sequence_id,
	case when esdt.static_data_type is null then null 
		when esdt.static_data_type=10009 then rg.technology
		when esdt.static_data_type=10016 then rg.gen_state_value_id
		when esdt.static_data_type=10023 then rg.fuel_value_id
		when esdt.static_data_type=10010 then rg.classification_value_id
		when esdt.static_data_type=2000 then esct.control_type_id
	end as system_value,
	sd.code as system_value_desc

from
	rec_generator rg inner join #ssbm ssbm on ssbm.fas_book_id=rg.fas_book_id

	inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
	inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
				ems_source_model_effective where isnull(effective_date,'1900-01-01')<=@term_start group by generator_id) ab
	on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date

	inner join ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
	inner join ems_source_model_detail esmd on esmd.ems_source_model_id=esm.ems_source_model_id
	inner join ems_input_map eim on eim.source_model_id=esmd.ems_source_model_id
	left join ems_input_characteristics eic on eic.ems_source_input_id=eim.input_id
	left join ems_static_data_type esdt on esdt.type_id=eic.type_id
	left join ems_source_input esi on esi.ems_source_input_id=eim.input_id
	left join ems_conversion_type ect on ect.type_char_id=eic.type_char_id
	left join ems_source_control_type esct on esct.generator_id=rg.generator_id
	left join static_data_value sd on sd.value_id=case when esdt.static_data_type is null then null 
							when esdt.static_data_type=10009 then rg.technology
							when esdt.static_data_type=10016 then rg.gen_state_value_id
							when esdt.static_data_type=10023 then rg.fuel_value_id 
							when esdt.static_data_type=10010 then rg.classification_value_id
							when esdt.static_data_type=2000 then esct.control_type_id end
where rg.generator_id in(select generator_id from #temp)
	and esi.input_output_id=1050
order by 
 	eic.type_char_id



--drop table #temp_conv
create table #temp_conv(
	generator_id int,
	ems_source_model_id int,
	input_id int,
	conversion_type int,
	type_char_id int,
	type_id int,
	type int,
	sequence_id int
)
insert
into
	#temp_conv(generator_id,ems_source_model_id,input_id,conversion_type,type_char_id,type_id,type,sequence_id)
select 
	distinct
	rg.generator_id,
	esm.ems_source_model_id,
	eim.input_id,
	esc.ems_conversion_type_id,
	ect.type_char_id,
	eic.type_id ,
	esdt.static_data_type,
	eic.sequence_id
--select esc.*
from
	rec_generator rg inner join #ssbm ssbm on ssbm.fas_book_id=rg.fas_book_id
	
	inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
	inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
				ems_source_model_effective where isnull(effective_date,'1900-01-01')<=@term_start group by generator_id) ab
	on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date

	inner join ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
	inner join ems_source_model_detail esmd on esmd.ems_source_model_id=esm.ems_source_model_id
 	inner join ems_input_map eim on eim.source_model_id=esmd.ems_source_model_id
 	inner join ems_source_conversion esc on esc.ems_source_input_id=eim.input_id
 	inner join ems_input_characteristics eic on eic.ems_source_input_id=eim.input_id
 	inner join  ems_conversion_type ect on ect.ems_source_input_id=eim.input_id
 	AND ect.ems_conversion_type_value_id=esc.ems_conversion_type_id and ect.type_char_id=eic.type_char_id
	inner join ems_static_data_type esdt on esdt.type_id=eic.type_id
 
where 1=1
	and rg.generator_id in(select generator_id from #temp)
	--and input_id=25
	UNION
select 
	distinct
	rg.generator_id,
	esm.ems_source_model_id,
	eim.input_id,
	esc.ems_conversion_type_id,
	ect.type_char_id,
	eic.type_id ,
	esdt.static_data_type,
	eic.sequence_id
--select esc.*
from
	rec_generator rg inner join #ssbm ssbm on ssbm.fas_book_id=rg.fas_book_id

	inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
	inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
				ems_source_model_effective where isnull(effective_date,'1900-01-01')<=@term_start group by generator_id) ab
	on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date

	inner join ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
	inner join ems_source_model_detail esmd on esmd.ems_source_model_id=esm.ems_source_model_id
 	inner join ems_input_map eim on eim.source_model_id=esmd.ems_source_model_id
 	left join ems_source_conversion esc on esc.ems_source_input_id=eim.input_id
 	left join ems_input_characteristics eic on eic.ems_source_input_id=eim.input_id
 	left join  ems_conversion_type ect on ect.ems_source_input_id=eim.input_id
 	AND ect.ems_conversion_type_value_id=esc.ems_conversion_type_id and ect.type_char_id=eic.type_char_id
	left join ems_static_data_type esdt on esdt.type_id=eic.type_id
 
where 1=1
	and rg.generator_id in(select generator_id from #temp)
	and ((eic.sequence_id is null) OR (esc.ems_conversion_type_id=1182))
--return
-------------------

update a set a.char1_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char1_val) end,  a.char1=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char1) end from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id   left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=1
update a set a.char2_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char2_val) end,  a.char2=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char2) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar) 	where  b.sequence_id=2
update a set a.char3_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char3_val) end,  a.char3=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char3) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=3
update a set a.char4_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char4_val) end,  a.char4=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char4) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=4
update a set a.char5_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char5_val) end,  a.char5=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char5) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=5
update a set a.char6_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char6_val) end,  a.char6=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char6) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=6
update a set a.char7_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char7_val) end,  a.char7=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char7) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=7
update a set a.char8_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char8_val) end,  a.char8=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char8) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=8
update a set a.char9_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char9_val) end,  a.char9=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char9) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar)	where  b.sequence_id=9
update a set a.char10_val=case when b.type=14200 then sd.code else ISNULL(b.system_value_desc,a.char10_val) end,  a.char10=case when b.type=14200 then sd.value_id else ISNULL(b.system_value,a.char10) end  from #temp a join #temp_char b on a.generator_id=b.generator_id and a.input_id=b.input_id  left join static_data_value sd on sd.code=cast(year(@term_start)-year(a.gen_start_date)+1 as varchar) where  b.sequence_id=10
 


--select 
--	generator_id,input_id,conversion_type,
--	sum(case when sequence_id=1  and conversion_type<>1182 then 1 else NULL end) as char1,
--	sum(case when sequence_id=2  and conversion_type<>1182 then 1 else NULL end) as char2,
--	sum(case when sequence_id=3  and conversion_type<>1182 then 1 else NULL end) as char3,
--	sum(case when sequence_id=4  and conversion_type<>1182 then 1 else NULL end) as char4,
--	sum(case when sequence_id=5  and conversion_type<>1182 then 1 else NULL end) as char5,
--	sum(case when sequence_id=6  and conversion_type<>1182 then 1 else NULL end) as char6,
--	sum(case when sequence_id=7  and conversion_type<>1182 then 1 else NULL end) as char7,
--	sum(case when sequence_id=8  and conversion_type<>1182 then 1 else NULL end) as char8,
--	sum(case when sequence_id=9  and conversion_type<>1182 then 1 else NULL end) as char9,
--	sum(case when sequence_id=10  and conversion_type<>1182 then 1 else NULL end) as char10

select 
	generator_id,input_id,conversion_type,
	sum(case when sequence_id=1   then 1 else NULL end) as char1,
	sum(case when sequence_id=2   then 1 else NULL end) as char2,
	sum(case when sequence_id=3   then 1 else NULL end) as char3,
	sum(case when sequence_id=4   then 1 else NULL end) as char4,
	sum(case when sequence_id=5   then 1 else NULL end) as char5,
	sum(case when sequence_id=6   then 1 else NULL end) as char6,
	sum(case when sequence_id=7   then 1 else NULL end) as char7,
	sum(case when sequence_id=8   then 1 else NULL end) as char8,
	sum(case when sequence_id=9   then 1 else NULL end) as char9,
	sum(case when sequence_id=10   then 1 else NULL end) as char10

into #temp_char_sequence 
from 
	#temp_conv
group by generator_id,input_id,conversion_type



update #temp
set 
	char1=null,char2=null,char3=null ,char4=null ,char5=null ,char6=null ,char7=null ,char8=null ,char9=null ,char10=null,  
	input_id=null,ems_generator_id=null,input_value=null
where
	(
	charindex('dbo.FNAInput(',formula)=0 and 
	charindex('dbo.FNAEMSConv(',formula)=0 and 
	charindex('dbo.FNAEMSCoeff(',formula)=0 and 
	charindex('dbo.FNAInput(',formula_reduction)=0 and 
	charindex('dbo.FNAEMSConv(',formula_reduction)=0 and 
	charindex('dbo.FNAEMSCoeff(',formula_reduction)=0 and
	charindex('dbo.FNARow(',formula)=0 and 
	charindex('dbo.FNARow(',formula_reduction)=0

)



select 
	* into #temp_final from #temp
where
	(
	charindex('dbo.FNAInput('+cast(input_id as varchar),formula)>0 or 
	charindex('dbo.FNAEMSConv('+cast(input_id as varchar),formula)>0 or 
	charindex('dbo.FNAEMSCoeff('+cast(input_id as varchar),formula)>0 or
-- 	and
 	charindex('dbo.FNAInput('+cast(input_id as varchar),formula_reduction)>0 or 
 	charindex('dbo.FNAEMSConv('+cast(input_id as varchar),formula_reduction)>0 or 
 	charindex('dbo.FNAEMSCoeff('+cast(input_id as varchar),formula_reduction)>0 
	) --AND input_id is not null
UNION
select distinct
	* from #temp
where
	(
	charindex('dbo.FNAInput(',isnull(formula,''))=0 and 
	charindex('dbo.FNAEMSConv(',isnull(formula,''))=0 and 
	charindex('dbo.FNAEMSCoeff(',isnull(formula,''))=0 and
-- 	or
 	charindex('dbo.FNAInput(',isnull(formula_reduction,''))=0 and
 	charindex('dbo.FNAEMSConv(',isnull(formula_reduction,''))=0 and 
	charindex('dbo.FNAEMSCoeff(',isnull(formula_reduction,''))=0
) --AND input_id is not null
UNION
select distinct
	* from #temp
where
	(
	charindex('dbo.FNAInput('+cast(input_id as varchar),formula)<=0 or
-- 	and
 	charindex('dbo.FNAInput('+cast(input_id as varchar),formula_reduction)<=0
) 



/*
select distinct
	a.[ID],a.generator_id,a.ems_source_model_id,a.input_id,b.conversion_type,
	case when b.type_char_id is not null then a.type else NULL end
	,c.char1,c.char2,c.char3,c.char4,
	case when case when b.type_char_id is not null then a.type else NULL end=10009 and a.[ID]=2 then rg.technology else NULL end as char5

from
	#temp_char a inner join  #temp_conv b on a.input_id=b.input_id
	inner join #temp c on a.generator_id=c.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id

return
*/

create table #temp_f([ID] int,generator_id int,ems_source_model_id int,input_id int,conversion_type int,type int,characteristics varchar(5000) COLLATE DATABASE_DEFAULT,ems_generator_id int,term_start datetime,forecast_type int)

insert into #temp_f(generator_id,ems_source_model_id,input_id,conversion_type,ems_generator_id,characteristics,term_start,forecast_type)
select distinct
	a.generator_id,a.ems_source_model_id,a.input_id,b.conversion_type,ems_generator_id,
	ISNULL(cast(a.char1*b.char1 as varchar),'NULL')+','+
	ISNULL(cast(a.char2*b.char2 as varchar),'NULL')+','+
	ISNULL(cast(a.char3*b.char3 as varchar),'NULL')+','+
	ISNULL(cast(a.char4*b.char4 as varchar),'NULL')+','+
	ISNULL(cast(a.char5*b.char5 as varchar),'NULL')+','+
	ISNULL(cast(a.char6*b.char6 as varchar),'NULL')+','+
	ISNULL(cast(a.char7*b.char7 as varchar),'NULL')+','+
	ISNULL(cast(a.char8*b.char8 as varchar),'NULL')+','+
	ISNULL(cast(a.char9*b.char9 as varchar),'NULL')+','+
	ISNULL(cast(a.char10*b.char10 as varchar),'NULL'),
	a.term_start,
	forecast_type
from
	#temp a inner join #temp_char_sequence b 
	on a.generator_id=b.generator_id and a.input_id=b.input_id
	--LEFT OUTER JOIN (select value_id from static_data_value where type_id=5006) sd on 
	--left join static_data_value sd on cast(sd.value_id as varchar)=dbo.FNAGetConversionID(a.formula,a.input_id)

-- insert into #temp_f(generator_id,ems_source_model_id,input_id,conversion_type,ems_generator_id,characteristics)
-- select distinct generator_id,ems_source_model_id,input_id,1182,ems_generator_id,'NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL'
-- from #temp_f
-- where conversion_type not in(1182)



declare @ems_source_model_id1 int,@input_id1 int,@ems_generator_id1 int,@term_start1 datetime

create table #temp_convalue(value_id int,generator_id int)

--insert into #temp_convalue(generator_id) select distinct generator_id from #temp_f where generator_id is not null


select distinct generator_id,ems_source_model_id,input_id,ems_generator_id,term_start into #temp_dis from #temp_f

insert into #temp_convalue(value_id,generator_id) select value_id,generator_id
	 from static_data_value,(select distinct generator_id from #temp_f) t where type_id=5006 
		and cast(value_id as varchar)+cast(generator_id as varchar) not in(select cast(ISNULL(conversion_type,'') as varchar)+cast(generator_id as varchar) from #temp_f)


declare  cur1 cursor for select generator_id,ems_source_model_id,input_id,ems_generator_id,term_start from #temp_dis
open cur1
fetch next from cur1 into @generator_id,@ems_source_model_id1,@input_id1,@ems_generator_id1,@term_start1
while @@fetch_status=0
begin
	insert into #temp_f(generator_id,ems_source_model_id,input_id,ems_generator_id,term_start,conversion_type,type,characteristics)
	select b.*,a.value_id,NULL,'NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL'
	from #temp_convalue a ,(select * from #temp_dis where generator_id=@generator_id and ems_source_model_id=@ems_source_model_id1 and 
		input_id=@input_id1 and ems_generator_id=@ems_generator_id1 and term_start=@term_start1) b
		where a.generator_id=b.generator_id
fetch next from cur1 into @generator_id,@ems_source_model_id1,@input_id1,@ems_generator_id1,@term_start1
end

close cur1





--
--EXEC spa_print 'Characteristics Populated :'+convert(varchar(100),getdate(),113)
---
select distinct ems_generator_id 
into 
	#tempe_ms_generator
from 
	#temp_final a
	inner join (select input_id,generator_id,term_start,sequence_number,curve_id
				from #temp_final group by input_id,generator_id,term_start,sequence_number,curve_id
			having count(*)>1) b
	on a.generator_id=b.generator_id and a.term_start=b.term_start and a.input_id=b.input_id 
	and a.sequence_number=b.sequence_number


create table #formula_value(
	[id] int,
	as_of_date datetime,
	term_start datetime,
	term_end datetime,
	generator_id int,
	curve_id int,
	formula_value float,
	volume float,
	uom_id int,
	frequency int,
	current_forecast char(1) COLLATE DATABASE_DEFAULT,
	sequence_number int,
	formula_id int,
	formula_str varchar(5000) COLLATE DATABASE_DEFAULT,
	formula_value_reduction	 float,
	formula_id_reduction int,
	reduction char(1) COLLATE DATABASE_DEFAULT,
	input_id int,
	output_id int,
	output_value float,
	output_uom_id int,
	heatcontent_value float,
	heatcontent_uom_id int,
	formula_str_reduction varchar(5000) COLLATE DATABASE_DEFAULT,
	formula_eval varchar(5000) COLLATE DATABASE_DEFAULT,
	formula_eval_reduction varchar(5000) COLLATE DATABASE_DEFAULT,
	char1 varchar(100) COLLATE DATABASE_DEFAULT,
	char2 varchar(100) COLLATE DATABASE_DEFAULT,
	char3 varchar(100) COLLATE DATABASE_DEFAULT,
	char4 varchar(100) COLLATE DATABASE_DEFAULT,
	char5 varchar(100) COLLATE DATABASE_DEFAULT,
	char6 varchar(100) COLLATE DATABASE_DEFAULT,
	char7 varchar(100) COLLATE DATABASE_DEFAULT,
	char8 varchar(100) COLLATE DATABASE_DEFAULT,
	char9 varchar(100) COLLATE DATABASE_DEFAULT,
	char10 varchar(100) COLLATE DATABASE_DEFAULT,
	base_year_volume float,
	no_of_units int,
	forecast_type int,
	formula_id_detail int,
	formula_id_reduction_detail	int,
	hour int,
	EF varchar(100) COLLATE DATABASE_DEFAULT,
	ems_generator_id int,
	input_output_id int
)
select * into #formula_value_EDR from #formula_value
create table #temp_form(formula varchar(2000) COLLATE DATABASE_DEFAULT)



create table #formula_str(
	[id] int,
	formula_str varchar(2000) COLLATE DATABASE_DEFAULT,
	formula_str_reduction varchar(1000) COLLATE DATABASE_DEFAULT,
	generator_id int,
	term_start datetime,
	formula_id int,
	ems_generator_id int
)



--select * from #temp_final where CHARINDEX(''+CAST(input_id AS VARCHAR)+'',formula)>0
DELETE FROM #temp_final where CHARINDEX(''+CAST(input_id AS VARCHAR)+'',formula)<=0 and CHARINDEX('FNAInput',formula)>0
--select * from #temp_final
-----######################################################################
--delete from #temp_final where curve_id<>127

-----######################################################################
DECLARE @processed_1 char(1),@processed_2 char(1),@processed_3 char(1),@processed_4 char(1),@processed_5 char(1),@processed_6 char(1),
@processed_7 char(1),@processed_8 char(1),@processed_9 char(1),@processed_10 char(1),@processed_11 char(1),@processed_12 char(1),@processed_13 char(1)
set @processed_1='n'	
set @processed_2='n'	
set @processed_3='n'	
set @processed_4='n'	
set @processed_5='n'	
set @processed_6='n'	
set @processed_7='n'	
set @processed_8='n'	
set @processed_9='n'	
set @processed_10='n'	
set @processed_11='n'	
set @processed_12='n'	
set @processed_13='n'	

-------------
--EXEC spa_print 'Start Calculation :'+convert(varchar(100),getdate(),113)
--------------
declare @index int
declare @index_next int
declare @index_next_1 int

DECLARE  @curve_id int,@formula varchar(2000),@uom_id int,@formula_stmt varchar(5000),@volume float,@ems_source_model_id int,
@char1 varchar(100),@char2 varchar(100),@char3 varchar(100),@char4 varchar(100),@char5 varchar(100),@char6 varchar(100),@char7 varchar(100),@char8 varchar(100),@char9 varchar(100),@char10 varchar(100),@input_value int,@frequency int,
@sequence_number int,@formula_id int,@technology int,@fuel_value_id int,@state int,@type_id int,@type int
,@count int,@char_str varchar(5000),@char_str_new varchar(5000),@ID int,@input_id int,@conversion_type int,@characteristics varchar(500),
@formula_reduction varchar(500),@formula_id_reduction int,@reduction char(1),@term_start_new datetime,@term_end_new datetime,@heatcontent_formula varchar(500),
@heatcontent_uom_id int,@ems_generator_id int,@gen_term_start datetime,@no_of_units int,@ems_generator_id_1 int,@formula_id_detail int,@formula_id_reduction_detail int,
@granularity int,@no_of_days_in_month int,@hour int,@value_id_for int,@ef_formula varchar(200),@input_output_id int
set @count=1
DECLARE formula_cursor CURSOR FOR
	select generator_id,curve_id,formula,uom_id,ems_source_model_id,MAX(input_value) input_value,
		char1_val,char2_val,char3_val,char4_val,char5_val,char6_val,char7_val,char8_val,char9_val,char10_val,
		frequency,term_start,term_end,sequence_number,formula_id,technology,fuel_value_id,state,
		formula_reduction,formula_id_reduction,reduction,heatcontent_formula,
		heatcontent_uom_id,MAX(ems_generator_id) ems_generator_id,gen_start_date,no_of_units,isnull(current_forecast,@current_forecast),
		forecast_type,formula_id_detail,formula_id_reduction_detail,
		granularity,value_id_for,input_output_id
	from #temp_final 
	where 1=1
	GROUP BY 
		generator_id,curve_id,formula,uom_id,ems_source_model_id,char1_val,char2_val,char3_val,char4_val,char5_val,char6_val,char7_val,char8_val,char9_val,char10_val,
		frequency,term_start,term_end,sequence_number,formula_id,technology,fuel_value_id,state,
		formula_reduction,formula_id_reduction,reduction,heatcontent_formula,
		heatcontent_uom_id,gen_start_date,no_of_units,isnull(current_forecast,@current_forecast),forecast_type,formula_id_detail,formula_id_reduction_detail,
		granularity,value_id_for,input_output_id

			
				--AND ems_generator_id is not null 
				order by sequence_number
open formula_cursor
	fetch next from formula_Cursor into @generator_id,@curve_id,@formula,@uom_id,@ems_source_model_id,@input_value,
		@char1,@char2,@char3,@char4,@char5,@char6,@char7,@char8,@char9,@char10,
		@frequency,@term_start_new,@term_end_new,@sequence_number,@formula_id,@technology,@fuel_value_id,@state,
		@formula_reduction,@formula_id_reduction,@reduction,@heatcontent_formula,@heatcontent_uom_id,@ems_generator_id,
		@gen_term_start,@no_of_units,@current_forecast,@forecast_type,@formula_id_detail,@formula_id_reduction_detail,
		@granularity,@value_id_for,@input_output_id
	While @@fetch_status=0
	BEGIN
	
 		--print @formula_reduction
		
		
		declare cur2 cursor for
 		select a.input_id,a.conversion_type,a.characteristics from #temp_f a
		where a.generator_id=@generator_id and a.ems_source_model_id=@ems_source_model_id  
		and a.term_start=ISNULL(@term_start_new,@term_start) and forecast_type=@forecast_type
		and ISNULL(ems_generator_id,'')=ISNULL(@ems_generator_id,'')
		open cur2
		fetch next from cur2 into @input_id,@conversion_type,@characteristics
		while @@fetch_status=0
		begin
		
		if  @conversion_type is not null --and @characteristics is not null
			begin
--			set @formula=REPLACE(@formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @formula=REPLACE(@formula,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)

		
		if CHARINDEX('dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula)>=1 and @processed_1<>'y'
				begin


					set @formula=REPLACE(@formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_1='y'	
					set @ef_formula=@formula
				end

		if CHARINDEX('dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula)>=1 and @processed_2<>'y'
				begin
					set @formula=REPLACE(@formula,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_2='y'	
				end

		if CHARINDEX('dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_3<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_3='y'	
				end

		if CHARINDEX('dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_4<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_4='y'	
				end

		if CHARINDEX('dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@heatcontent_formula)>=1 and @processed_5<>'y'
				begin
					set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_5='y'	
				end


			if CHARINDEX('dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),@formula)>=1 and @processed_6<>'y'
				begin
					set @formula=REPLACE(@formula,'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_6='y'	
				end
			if CHARINDEX('dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),@formula)>=1 and @processed_7<>'y'
				begin
					set @formula=REPLACE(@formula,'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_7='y'	
				end
			if CHARINDEX('dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_8<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_8='y'	
				end
			if CHARINDEX('dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_9<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_9='y'	
				end
			if CHARINDEX('dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),@heatcontent_formula)>=1 and @processed_10<>'y'
				begin
					set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_10='y'					
				end

			end
		--print @formula
		fetch next from cur2 into @input_id,@conversion_type,@characteristics
		end
		close cur2
		deallocate cur2

	declare cur12 cursor for
 		select a.input_id,a.conversion_type,a.characteristics from #temp_f a
		where a.generator_id=@generator_id and a.ems_source_model_id=@ems_source_model_id  
		and a.term_start=ISNULL(@term_start_new,@term_start) and forecast_type=@forecast_type
		--and ISNULL(ems_generator_id,'')=ISNULL(@ems_generator_id,'')
		open cur12
		fetch next from cur12 into @input_id,@conversion_type,@characteristics
		while @@fetch_status=0
		begin
		
		if  @conversion_type is not null --and @characteristics is not null
			begin
--			set @formula=REPLACE(@formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @formula=REPLACE(@formula,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
--			set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)

		
		if CHARINDEX('dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula)>=1 and @processed_1<>'y'
				begin


					set @formula=REPLACE(@formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_1='y'	
					set @ef_formula=@formula
				end

		if CHARINDEX('dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula)>=1 and @processed_2<>'y'
				begin
					set @formula=REPLACE(@formula,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_2='y'	
				end

		if CHARINDEX('dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_3<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_3='y'	
				end

		if CHARINDEX('dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_4<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSCoeff('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_4='y'	
				end

		if CHARINDEX('dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),@heatcontent_formula)>=1 and @processed_5<>'y'
				begin
					set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar),'dbo.FNAEMSConv('+cast(@input_id as varchar)+','+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_5='y'	
				end


			if CHARINDEX('dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),@formula)>=1 and @processed_6<>'y'
				begin
					set @formula=REPLACE(@formula,'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_6='y'	
				end
			if CHARINDEX('dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),@formula)>=1 and @processed_7<>'y'
				begin
					set @formula=REPLACE(@formula,'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_7='y'	
				end
			if CHARINDEX('dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_8<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_8='y'	
				end
			if CHARINDEX('dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),@formula_reduction)>=1 and @processed_9<>'y'
				begin
					set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSCoeff(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_9='y'	
				end
			if CHARINDEX('dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),@heatcontent_formula)>=1 and @processed_10<>'y'
				begin
					set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar),'dbo.FNAEMSConv(NULL,'+cast(@conversion_type as varchar)+','+@characteristics)
					set @processed_10='y'					
				end

			end
		--print @formula
		fetch next from cur12 into @input_id,@conversion_type,@characteristics
		end
		close cur12
		deallocate cur12


		set @processed_1='n'	
		set @processed_2='n'	
		set @processed_3='n'	
		set @processed_4='n'	
		set @processed_5='n'	
		set @processed_6='n'	
		set @processed_7='n'	
		set @processed_8='n'	
		set @processed_9='n'	
		set @processed_10='n'	
		
		
		
		declare cur3 cursor for
 		select distinct a.input_id,a.ems_generator_id from #temp_f a
		where a.generator_id=@generator_id and a.ems_source_model_id=@ems_source_model_id  
		and a.term_start=ISNULL(@term_start_new,@term_start)  and forecast_type=@forecast_type
		and ISNULL(ems_generator_id,'')=ISNULL(@ems_generator_id,'')
		
		open cur3
		fetch next from cur3 into @input_id,@ems_generator_id_1
		while @@fetch_status=0
		begin
			
	
				if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar),@formula)>=1 and isnull(@processed_11,'n')<>'y'
				begin
					if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@formula)<1
					   set @processed_11='y'	
					
					if @processed_11='n'
					   set @formula=REPLACE(@formula,'dbo.FNAInput('+cast(@input_id as varchar),'dbo.FNAInput('+cast(@input_id as varchar)+','+cast(@ems_generator_id_1 as varchar))
					
				end

				if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@formula_reduction)>=1 and isnull(@processed_12,'n')<>'y'
				begin
					
						if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@formula_reduction)<1
							set @processed_12='y'	

						if @processed_12='n'
							set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAInput('+cast(@input_id as varchar),'dbo.FNAInput('+cast(@input_id as varchar)+','+cast(@ems_generator_id_1 as varchar))	

				end
				if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar),@heatcontent_formula)>=1 and isnull(@processed_13,'n')<>'y'
				begin
					if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@heatcontent_formula)<1
					set @processed_13='y'	
					
					if @processed_13='n'
						set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAInput('+cast(@input_id as varchar),'dbo.FNAInput('+cast(@input_id as varchar)+','+cast(@ems_generator_id_1 as varchar))	

				end
		fetch next from cur3 into @input_id,@ems_generator_id_1
		end
		close cur3
		deallocate cur3
	--select  @formula
		

		set @processed_11='n'	
		set @processed_12='n'	
		set @processed_13='n'

	declare cur4 cursor for
 		select distinct a.input_id,a.ems_generator_id from #temp_f a
		where a.generator_id=@generator_id and a.ems_source_model_id=@ems_source_model_id  
		and a.term_start=ISNULL(@term_start_new,@term_start)  and forecast_type=@forecast_type
		--and ISNULL(ems_generator_id,'')=ISNULL(@ems_generator_id,'')
		open cur4
		fetch next from cur4 into @input_id,@ems_generator_id_1
		while @@fetch_status=0
		begin
				
				
				if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar),@formula)>=1 and isnull(@processed_11,'n')<>'y'
				begin
		
					if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@formula)<1
					   set @processed_11='y'	
					
					if @processed_11='n'
					   set @formula=REPLACE(@formula,'dbo.FNAInput('+cast(@input_id as varchar),'dbo.FNAInput('+cast(@input_id as varchar)+','+cast(@ems_generator_id_1 as varchar))
					
				end

				if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@formula_reduction)>=1 and isnull(@processed_12,'n')<>'y'
				begin
					
						if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@formula_reduction)<1
							set @processed_12='y'	

						if @processed_12='n'
							set @formula_reduction=REPLACE(@formula_reduction,'dbo.FNAInput('+cast(@input_id as varchar),'dbo.FNAInput('+cast(@input_id as varchar)+','+cast(@ems_generator_id_1 as varchar))	

				end
				if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar),@heatcontent_formula)>=1 and isnull(@processed_13,'n')<>'y'
				begin
					if CHARINDEX('dbo.FNAInput('+cast(@input_id as varchar)+')',@heatcontent_formula)<1
					set @processed_13='y'	
				
					if @processed_13='n'
					set @heatcontent_formula=REPLACE(@heatcontent_formula,'dbo.FNAInput('+cast(@input_id as varchar),'dbo.FNAInput('+cast(@input_id as varchar)+','+cast(@ems_generator_id_1 as varchar))	

				end
		fetch next from cur4 into @input_id,@ems_generator_id_1
		end
		close cur4
		deallocate cur4


		declare @tmp_test varchar(5000)

		set @processed_11='n'	
		set @processed_12='n'	
		set @processed_13='n'	

	-- if no input data found then 



--print 'start here'
--print @formula
--print 'end here'
--	
--	EXEC spa_print 'Heat COntent :'
--	EXEC spa_print @heatcontent_formula	
	if @granularity=982 -- for HOURLY LOGIC
	BEGIN
	-- LOOp For Each Hour
	set @no_of_days_in_month=dbo.FNALastDayInMonth(@term_start_new)-1
	
	while @no_of_days_in_month>=0
		BEGIN
			set @hour=23
			while @hour>=0
				BEGIN
					
					set @formula_stmt='insert into #formula_value_EDR([id],as_of_date,term_start,term_end,generator_id,curve_id,formula_value,volume,uom_id,frequency,current_forecast,sequence_number,formula_id,formula_str,formula_value_reduction,formula_id_reduction,reduction,formula_str_reduction,heatcontent_uom_id,heatcontent_value,input_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,no_of_units,forecast_type,formula_id_detail,formula_id_reduction_detail,hour)
					select 
						'+cast(@count as varchar)+','''+cast(ISNULL(@as_of_date,cast(year(@term_start_new) as varchar)+'-12-31') as varchar)+''','''+cast(dateadd(day,@no_of_days_in_month,@term_start_new) as varchar)+''','''+cast(@term_end_new as varchar)+''','''+cast(@generator_id as varchar)+''','''+cast(@curve_id as varchar)+''','
						+ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start)) as varchar),isnull(@input_value,0),isnull(@input_value,0),ISNULL(@formula,'NULL'),@generator_id,@ems_source_model_id,@curve_id,isnull(@input_value,0),isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),cast(@hour as int),CAST(@criteria_id AS VARCHAR)),'null')
						+',NULL,'+cast(@uom_id as varchar)+','+cast(@frequency as varchar)+','''+@current_forecast+''','+isnull(cast(@sequence_number as varchar),0)+','+isnull(cast(@formula_id as varchar),'null')+','''+
  						REPLACE(ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start)) as varchar),isnull(@input_value,0),isnull(@input_value,0),ISNULL(@formula,''),@generator_id,@ems_source_model_id,@curve_id,@input_value,isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),cast(@hour as int),CAST(@criteria_id AS VARCHAR)),'NULL'),'''','''''')+''','+
  						ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start)) as varchar),isnull(@input_value,0),isnull(@input_value,0),@formula_reduction,@generator_id,@ems_source_model_id,@curve_id,@input_value,@formula_id_reduction,isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),cast(@hour as int),CAST(@criteria_id AS VARCHAR)),'NULL')+','+ISNULL(cast(@formula_id_reduction as varchar),'NULL')+','''+ISNULL(@reduction,'NULL')+''','''+
  						REPLACE(ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start)) as varchar),isnull(@input_value,0),isnull(@input_value,0),@formula_reduction,@generator_id,@ems_source_model_id,@curve_id,@input_value,isnull(@formula_id_reduction,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),cast(@hour as int),CAST(@criteria_id AS VARCHAR)),'NULL'),'''','''''')+''','+ISNULL(cast(@heatcontent_uom_id as varchar),'NULL')+','+
  						ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start)) as varchar),isnull(@input_value,0),isnull(@input_value,0),@heatcontent_formula,@generator_id,@ems_source_model_id,@curve_id,@input_value,@heatcontent_uom_id,isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),cast(@hour as int),CAST(@criteria_id AS VARCHAR)),'NULL')+','+
						ISNULL(cast(@ems_generator_id as varchar),'null')
						+','''+ISNULL(@char1,'NULL')+''','''+ISNULL(@char2,'NULL')+''','''+ISNULL(@char3,'NULL')+''','''
						+ISNULL(@char4,'NULL')+''','''+ISNULL(@char5,'NULL')+''','''+ISNULL(@char6,'NULL')+''','''
						+ISNULL(@char7,'NULL')+''','''+ISNULL(@char8,'NULL')+''','''+ISNULL(@char9,'NULL')+''','''
						+ISNULL(@char10,'NULL')+''','''+ISNULL(cast(@no_of_units as varchar),'NULL')+''','''
						+ISNULL(cast(@forecast_type as varchar),NULL)+''','+isnull(cast(@formula_id_detail as varchar),0)+','+isnull(cast(@formula_id_reduction_detail as varchar),0)+','+cast(@hour as varchar)
					set @hour=@hour-1
					exec(@formula_stmt)
					--print @formula_stmt
					--EXEC spa_print 'Calculated Hour :'+cast(@hour as varchar)+' '+convert(varchar(100),getdate(),113)	
				END
			

			delete from calc_formula_value_hour
					where ISNULL(formula_id,'')=ISNULL(@formula_id,@formula_id_reduction) and seq_number=@sequence_number 
					and  prod_date=DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start))

			insert into calc_formula_value_hour(seq_number,value,formula_id,hour,formula_str,generator_id,prod_date)
			select sequence_number,formula_value,ISNULL(@formula_id,@formula_id_reduction),hour,formula_str,generator_id,DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start))
				from #formula_value_EDR
			where
				ISNULL(formula_id,'')=ISNULL(@formula_id,@formula_id_reduction) and sequence_number=@sequence_number 
					and  term_start=DateADD(day,@no_of_days_in_month,ISNULL(@term_start_new,@term_start))

			set @no_of_days_in_month=@no_of_days_in_month-1
		 
		END	

	insert into #formula_value([id],as_of_date,term_start,term_end,generator_id,curve_id,formula_value,volume,uom_id,frequency,current_forecast,sequence_number,formula_id,formula_str,formula_value_reduction,formula_id_reduction,reduction,formula_str_reduction,heatcontent_value,heatcontent_uom_id,input_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,no_of_units,forecast_type,formula_id_detail,formula_id_reduction_detail,hour,ems_generator_id)
	select	@count,as_of_date,ISNULL(@term_start_new,@term_start),term_end,generator_id,curve_id,sum(formula_value),sum(volume),
			uom_id,frequency,current_forecast,sequence_number,formula_id,max(formula_str),sum(formula_value_reduction),
			formula_id_reduction,reduction,max(formula_str_reduction),sum(heatcontent_value),
			heatcontent_uom_id,input_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,no_of_units,
			forecast_type,formula_id_detail,formula_id_reduction_detail,0,@ems_generator_id
			from #formula_value_EDR
		group by 
			as_of_date,term_end,generator_id,curve_id,uom_id,frequency,current_forecast,sequence_number,
			formula_id,formula_id_reduction,reduction,heatcontent_uom_id,
			input_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,no_of_units,forecast_type,formula_id_detail,formula_id_reduction_detail
		truncate table 	#formula_value_EDR
	END
	ELSE
	BEGIN


--		if @criteria_id IS NOT NULL AND 
--			BEGIN
--				SET @formula=REPLACE(REPLACE(@formula,'FNAEMSConv','FNAWhatIfEMSConv'),')',','+CAST(@criteria_id AS VARCHAR)+')')	
--				SET @formula=REPLACE(REPLACE(@formula,'FNAInput','FNAWhatIfInput'),')',','+CAST(@criteria_id AS VARCHAR)+')')	
--
--			END

			

		set @formula_stmt='insert into #formula_value([id],as_of_date,term_start,term_end,generator_id,curve_id,formula_value,volume,uom_id,frequency,current_forecast,sequence_number,formula_id,formula_str,formula_value_reduction,formula_id_reduction,reduction,formula_str_reduction,heatcontent_uom_id,heatcontent_value,input_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,no_of_units,forecast_type,formula_id_detail,formula_id_reduction_detail,hour,ems_generator_id,input_output_id,EF)
			select 
				'+cast(@count as varchar)+','''+cast(ISNULL(@as_of_date,cast(year(ISNULL(@term_start_new,@term_start)) as varchar)+'-12-31') as varchar)+''','''+cast(@term_start_new as varchar)+''','''+cast(@term_end_new as varchar)+''','''+cast(@generator_id as varchar)+''','''+cast(@curve_id as varchar)+''','
			--	EXEC spa_print @formula_stmt

		set @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),ISNULL(@formula,'NULL'),@generator_id,@ems_source_model_id,@curve_id,isnull(@input_value,0),isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1,isnull(@criteria_id,0)),'null')
				begin try
						EXEC('declare @tmp_valu1 numeric(16,4)
							select @tmp_valu1='+ @tmp_test)
					SET @formula_stmt=@formula_stmt+@tmp_test
				END TRY
				BEGIN CATCH
					SET @formula_stmt=@formula_stmt+'0'
				END CATCH

 --print @tmp_test
 				SET @formula_stmt=@formula_stmt+',NULL,'+cast(@uom_id as varchar)+','+cast(@frequency as varchar)+','''+@current_forecast+''','+isnull(cast(@sequence_number as varchar),0)+','+isnull(cast(@formula_id as varchar),'null')+','''
  				set @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),ISNULL(@formula,''),@generator_id,@ems_source_model_id,@curve_id,@input_value,isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1,isnull(@criteria_id,0)),'NULL')
				begin try
					EXEC('declare @tmp_valu2 numeric(16,4)
						select @tmp_valu2='+ @tmp_test)
					set @tmp_test=REPLACE(@tmp_test,'''','''''')
					SET @formula_stmt=@formula_stmt+@tmp_test
				END TRY
				BEGIN CATCH
					SET @formula_stmt=@formula_stmt+'0'
				END CATCH

EXEC spa_print  @tmp_test
				SET @formula_stmt=@formula_stmt+''','
  			
	SET @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),@formula_reduction,@generator_id,@ems_source_model_id,@curve_id,@input_value,@formula_id_reduction,isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1,isnull(@criteria_id,0)),'NULL')
				begin try
					EXEC('declare @tmp_valu3 numeric(16,4)
						select @tmp_valu3='+ @tmp_test)
					SET @formula_stmt=@formula_stmt+@tmp_test
				END TRY
				BEGIN CATCH
					SET @formula_stmt=@formula_stmt+'0'
				END CATCH
								
				SET @formula_stmt=@formula_stmt+','+ISNULL(cast(@formula_id_reduction as varchar),'NULL')+','''+ISNULL(@reduction,'NULL')+''','''
  				SET @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),@formula_reduction,@generator_id,@ems_source_model_id,@curve_id,@input_value,isnull(@formula_id_reduction,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1,isnull(@criteria_id,0)),'NULL')

--print  @tmp_test				
			begin try
					EXEC('declare @tmp_valu4 numeric(16,4)
						select @tmp_valu4='+ @tmp_test)
					set @tmp_test=REPLACE(@tmp_test,'''','''''')
					SET @formula_stmt=@formula_stmt+@tmp_test
				END TRY
				BEGIN CATCH
					SET @formula_stmt=@formula_stmt+'0'
				END CATCH

--select @tmp_test
   				SET @formula_stmt=@formula_stmt+''','+ISNULL(cast(@heatcontent_uom_id as varchar),'NULL')+','
  				
	-- check if the heat content is in the formula itself then insert that value in the table

--	if @value_id_for=@show_heat_content_value_id	
--		set @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),ISNULL(@formula,'NULL'),@generator_id,@ems_source_model_id,@curve_id,isnull(@input_value,0),isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1),'null')
--	else

		set @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),@heatcontent_formula,@generator_id,@ems_source_model_id,@curve_id,@input_value,isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1,isnull(@criteria_id,0)),'NULL')					
		
		begin try
					EXEC('declare @tmp_valu5 numeric(16,4)
						select @tmp_valu5='+ @tmp_test)
					
					SET @formula_stmt=@formula_stmt+@tmp_test
				END TRY
				BEGIN CATCH
					SET @formula_stmt=@formula_stmt+'0'
				END CATCH

		--print  @tmp_test		

  				SET @formula_stmt=@formula_stmt+','+ISNULL(cast(@ems_generator_id as varchar),'null')
				+','''+ISNULL(@char1,'NULL')+''','''+ISNULL(@char2,'NULL')+''','''+ISNULL(@char3,'NULL')+''','''
				+ISNULL(@char4,'NULL')+''','''+ISNULL(@char5,'NULL')+''','''+ISNULL(@char6,'NULL')+''','''
				+ISNULL(@char7,'NULL')+''','''+ISNULL(@char8,'NULL')+''','''+ISNULL(@char9,'NULL')+''','''
				+ISNULL(@char10,'NULL')+''','''+ISNULL(cast(@no_of_units as varchar),'NULL')+''','''
				+ISNULL(cast(@forecast_type as varchar),NULL)+''','+isnull(cast(@formula_id_detail as varchar),0)+','+isnull(cast(@formula_id_reduction_detail as varchar),0)+',NULL,'+cast(ISNULL(@ems_generator_id,'') as varchar)+','+cast(isnull(@input_output_id,'') as varchar)+','
		--print @ef_formula
		set @ef_formula=substring(substring(@ef_formula,charindex('dbo.FNAEMSConv(',@ef_formula),len(@ef_formula)),0,charindex(')',substring(@ef_formula,charindex('dbo.FNAEMSConv(',@ef_formula)-1,len(@ef_formula))))
		--print @ef_formula
		set @tmp_test=ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),@ef_formula,@generator_id,@ems_source_model_id,@curve_id,@input_value,@heatcontent_uom_id,isnull(@ems_generator_id,0),cast(@gen_term_start as varchar),-1,isnull(@criteria_id,0)),'NULL')					
		
		begin try
					EXEC('declare @tmp_valu6 numeric(16,4)
						select @tmp_valu6='+ @tmp_test)
					
					SET @formula_stmt=@formula_stmt+@tmp_test
				END TRY
				BEGIN CATCH
					SET @formula_stmt=@formula_stmt+'0'
				END CATCH
		--select ISNULL(dbo.FNAFormulaTextEMS_WhatIf(cast(ISNULL(@term_start_new,@term_start) as varchar),isnull(@input_value,0),isnull(@input_value,0),ISNULL(@formula,'NULL'),@generator_id,@ems_source_model_id,@curve_id,isnull(@input_value,0),isnull(@formula_id,0),isnull(@ems_generator_id,0),cast(@gen_term_start as varchar)),'null')
		--print('dbo.FNAFormulaTextEMS_WhatIf('''+cast(ISNULL(@term_start_new,@term_start) as varchar)+''','+cast(isnull(@input_value,0) as varchar)+','
		--	+cast(isnull(@input_value,0) as varchar)+','''+cast(ISNULL(@formula,'NULL') as varchar)+''','+cast(@generator_id as varchar)+','
		--	+cast(@ems_source_model_id as varchar)+','+cast(@curve_id as varchar)+','+cast(isnull(@input_value,0) as varchar)+','+cast(isnull(@formula_id,0) as varchar)
		--	+','+cast(isnull(@ems_generator_id,0) as varchar)+','+cast(@gen_term_start as varchar))+',null)'
		--print @formula_stmt
		EXEC(@formula_stmt)
	
		END

		
		select @formula=formula_str from #formula_value where [id]=@count and term_start=ISNULL(@term_start_new,@term_start) and generator_id=@generator_id

		--print @formula

		select @formula_reduction=formula_str_reduction from #formula_value where [id]=@count and term_start=ISNULL(@term_start_new,@term_start) and generator_id=@generator_id

		set @formula=replace(@formula,'','''')
		set @formula_reduction=replace(@formula_reduction,'','''')


	

		if @formula is not null
	 		insert into #temp_form(formula)
 			exec spa_drill_down_function_call @formula
		
		insert into #formula_str([id],formula_str,generator_id,term_start,formula_id,ems_generator_id)
                    select @count,ISNULL(formula,''),@generator_id,ISNULL(@term_start_new,@term_start),@formula_id,isnull(@ems_generator_id,'') from #temp_form
					--where ISNULL(NULLIF(formula,'0'),'')<>'' 

		delete from #temp_form		

 		--print 'formulal reduction:' + @formula
		if @formula_reduction is not null		
			insert into #temp_form(formula)
 			exec spa_drill_down_function_call @formula_reduction

-- 		
		update #formula_str set formula_str_reduction=(select formula from #temp_form)
			where id=@count and generator_id=@generator_id and 
			term_start=ISNULL(@term_start_new,@term_start) and
			isnull(ems_generator_id,'')=isnull(@ems_generator_id,'')
	-----------------------------------------------




	delete from calc_formula_value_whatif
	where ISNULL(formula_id,'')=ISNULL(@formula_id,@formula_id_reduction) and seq_number=@sequence_number 
	and prod_date=ISNULL(@term_start_new,@term_start)
	and generator_id=@generator_Id 
	and ((ems_generator_id in(select ems_generator_id from #tempe_ms_generator) and isnull(ems_generator_id,'')=isnull(@ems_generator_id,''))
		 or(ems_generator_id not in(select ems_generator_id from #tempe_ms_generator)))


	
	insert into calc_formula_value_whatif(seq_number,prod_date,value,formula_id,generator_id,ems_generator_id,formula_str)
 	select  
		MAX(sequence_number),term_start,MAX(ISNULL(NULLIF(formula_value,0),formula_value_reduction)),
		ISNULL(formula_id,formula_id_reduction),@generator_id,MAX(ems_generator_id),
	--formula_str
	((select  top 1 ISNULL(NULLIF(formula_str,'0'),formula_str_reduction) from #formula_str where 1=1
				and id=@count 
				--and formula_id=a.formula_id
				and  formula_str<>'NULL'  and generator_id=@generator_id 
				and term_start=ISNULL(@term_start_new,@term_start)
				and ISNULL(NULLIF(formula_str,'0'),NULLIF(formula_str_reduction,'0'))<>''
				
				and isnull(ems_generator_id,'')=isnull(@ems_generator_id,'')
				order by formula_str desc
			))	
	from #formula_value a where sequence_number=@sequence_number
		and term_start=ISNULL(@term_start_new,@term_start) and generator_id=@generator_id and forecast_type=@forecast_type
		and (formula_id=@formula_id or formula_id_reduction=@formula_id_reduction)
		and isnull(ems_generator_id,'')=isnull(@ems_generator_id,'')		
	GROUP BY sequence_number,term_start,ISNULL(formula_id,formula_id_reduction)
	


	set @count=@count+1
	fetch next from formula_Cursor into @generator_id,@curve_id,@formula,@uom_id,@ems_source_model_id,@input_value,
		@char1,@char2,@char3,@char4,@char5,@char6,@char7,@char8,@char9,@char10,
		@frequency,@term_start_new,@term_end_new,@sequence_number,@formula_id,@technology,@fuel_value_id,@state,
		@formula_reduction,@formula_id_reduction,@reduction,@heatcontent_formula,@heatcontent_uom_id,@ems_generator_id,@gen_term_start,@no_of_units,@current_forecast,@forecast_type,@formula_id_detail,@formula_id_reduction_detail,
		@granularity,@value_id_for,@input_output_id



	
END
close formula_cursor
deallocate formula_cursor


--EXEC spa_print 'Calculation Complete :'+convert(varchar(100),getdate(),113)	

--------------------------------------------------------
-------------------------------------------

select [id] as [ID],generator_id,curve_id,a.formula_id,term_start into #formula_temp
from #formula_value a
	 left join formula_editor b on a.formula_id_detail=b.formula_id
	 left join formula_editor c on ISNULL(a.formula_id_reduction_detail,a.formula_id_detail)=c.formula_id
where 1=1
	and (b.static_value_id is not null or c.static_value_id is not null)



select generator_id,curve_id,term_start,
	   input_id,sum(heatcontent_value) as heatcontent_value,max(heatcontent_uom_id) as heatcontent_uom_id,
		forecast_type
into #HEATCONTENT_TEMP
from(
SELECT 
		generator_id,curve_id,sequence_number,term_start,max(input_id) input_id,max(heatcontent_value) as heatcontent_value,
		max(heatcontent_uom_id) as heatcontent_uom_id,forecast_type as forecast_type
from #formula_value
	WHERE HEATCONTENT_VALUE is not null
group by 
		generator_id,curve_id,sequence_number,term_start,forecast_type
) a
group by 
	generator_id,curve_id,term_start,forecast_type,input_id



--	 left join formula_editor c on a.formula_id_reduction=c.formula_id
--	 and c.static_value_id is null
	
--	group by 
--	generator_id,curve_id,formula_id,term_start,forecast_type

delete from #formula_value where isnull([id],'')  not in(select isnull([ID],'') from #formula_temp)


update 
	#formula_value
set 
	formula_value=formula_value*no_of_units,
	formula_value_reduction=formula_value_reduction*no_of_units



----------------------------------------------------------	
update 
	a
	
set 
	a.formula_eval=b.formula_str,
	a.formula_eval_reduction=b.formula_str_reduction
from
	#formula_value a,
	#formula_str b
where
	a.id=b.id
	and b.formula_str <>'NULL'

-- uopdate the heatcontent values
update 
	a
set 
	a.heatcontent_value=b.heatcontent_value,
	a.heatcontent_uom_id=b.heatcontent_uom_id
from
	#formula_value a,
	#HEATCONTENT_TEMP b
where
	a.generator_id=b.generator_id
	and a.curve_id=b.curve_id
	and a.term_start=b.term_start
	and isnull(a.input_id,'')=isnull(b.input_id,'')
	and a.forecast_type=b.forecast_type
and
	a.formula_value<>0


-----------------------------------------------------------------
-- select * into  #formula_value1 from #formula_value where sequence_number<=0
-- 
-- -------------------------------------
-- insert into #formula_value1(as_of_date,generator_id,curve_id,formula_value,volume,uom_id,frequency,current_forecast,sequence_number)
-- select 
-- 	as_of_date,generator_id,curve_id,formula_value,volume,uom_id,frequency,current_forecast,sequence_number from 
-- 	
-- #formula_value where sequence_Number =(select max(sequence_Number) from #formula_value)  
-- and  sequence_number<>0
----------------------------------------------------------------
--drop table #formula_value1

select 
	max(id) id,as_of_date,term_start,term_end,generator_id,curve_id,sum(formula_value)formula_value,sum(volume)volume,uom_id,
	frequency,current_forecast,sequence_number,formula_id,max(formula_str)formula_str,sum(formula_value_reduction) formula_value_reduction,formula_id_reduction,reduction,
	max(input_id) input_id,output_id,output_value,output_uom_id,sum(heatcontent_value)heatcontent_value,heatcontent_uom_id,max(formula_str_reduction)formula_str_reduction,max(formula_eval)formula_eval,
	max(formula_eval_reduction)formula_eval_reduction,max(char1) char1,max(char2) char2,max(char3) char3,max(char4) char4,max(char5) char5,max(char6) char6,
	max(char7) char7,max(char8) char8,max(char9) char9,max(char10) char10,sum(base_year_volume) base_year_volume,no_of_units,
	forecast_type,formula_id_detail,formula_id_reduction_detail,hour,max(EF) EF,max(ems_generator_id)ems_generator_id,max(input_output_id) input_output_id

into  #formula_value1 from #formula_value where sequence_number<=0 and input_output_id=1050
	  and ems_generator_id in(select ems_generator_id from #tempe_ms_generator)
	group by 
		as_of_date,term_start,term_end,generator_id,curve_id,uom_id,
	frequency,current_forecast,sequence_number,formula_id,formula_id_reduction,reduction,
	output_id,output_value,output_uom_id,heatcontent_uom_id,
	no_of_units,
	forecast_type,formula_id_detail,formula_id_reduction_detail,hour
--
--

insert into #formula_value1
select 	max(id) id,as_of_date,term_start,term_end,generator_id,curve_id,sum(formula_value)formula_value,sum(volume)volume,uom_id,
	frequency,current_forecast,sequence_number,formula_id,max(formula_str)formula_str,sum(formula_value_reduction) formula_value_reduction,formula_id_reduction,reduction,
	max(input_id) input_id,output_id,output_value,output_uom_id,sum(heatcontent_value)heatcontent_value,heatcontent_uom_id,max(formula_str_reduction)formula_str_reduction,max(formula_eval) formula_eval,
	max(formula_eval_reduction) formula_eval_reduction,max(char1) char1,max(char2) char2,max(char3) char3,max(char4) char4,max(char5) char5,max(char6) char6,
	max(char7) char7,max(char8) char8,max(char9) char9,max(char10) char10,sum(base_year_volume) base_year_volume,no_of_units,
	forecast_type,formula_id_detail,formula_id_reduction_detail,hour,max(EF) EF,max(ems_generator_id)ems_generator_id,max(input_output_id) input_output_id
		from
#formula_value a
where
	  a.sequence_number<>0 and input_output_id=1050
	  and ems_generator_id in(select ems_generator_id from #tempe_ms_generator)	
group by 
		as_of_date,term_start,term_end,generator_id,curve_id,uom_id,
	frequency,current_forecast,sequence_number,formula_id,formula_id_reduction,reduction,
	output_id,output_value,output_uom_id,heatcontent_uom_id,
	no_of_units,
	forecast_type,formula_id_detail,formula_id_reduction_detail,hour
--##########################



insert into  #formula_value1 select * from #formula_value where sequence_number<=0
 --and input_output_id=1052
 and ems_generator_id not in(select ems_generator_id from #tempe_ms_generator)


insert into #formula_value1
select a.*
		from
	
#formula_value a
where
	a.sequence_number<>0 
	--and input_output_id=1052
	and ems_generator_id not in(select ems_generator_id from #tempe_ms_generator)



update a
set 
  a.output_id=b.ems_input_id,	
  a.output_value=b.input_value,
  a.output_uom_id=b.uom_id
from
    #formula_value1 a,
    ems_gen_input b
where
	a.generator_id=b.generator_id and 
	a.term_start=b.term_start and 	a.term_end=b.term_end
	--and a.forecast_type=b.forecast_type
	and b.ems_input_id in(select ems_source_input_id from ems_source_input where input_output_id<>1050)


--EXEC spa_print 'Temoprary Table Populated :'+convert(varchar(100),getdate(),113)	

--###############

	  	
--######Calculate reductions if there is no formula
--drop table #temp_reduction

DECLARE @tablename varchar(100)
DECLARE @base_year_from int
DECLARE @base_year_to int
Declare @report_year int


create table #temp_reduction(
	generator_id int,
	curve_id int,
	reportingvol float,
	basevol float,
	term_start datetime,
	term_end datetime,
	forecast_type int,
	fuel_type_value_id int
)


	declare @base_year_term_start datetime,@base_year_term_end datetime

--	declare cur3 cursor for
--	select distinct rg.generator_id,ISNULL(rg.base_year,fs.base_year_from),ISNULL(rg.base_year,fs.base_year_to),max(year(a.term_start)),rg.legal_entity_value_id		
--		 from #formula_value1 a 
--		inner join rec_generator rg on a.generator_id=rg.generator_id 
--		inner join (
--			select book.entity_id book_id,sub.entity_id sub_id from portfolio_hierarchy book
--			inner join portfolio_hierarchy strat on book.parent_entity_id=strat.entity_id
--			inner join portfolio_hierarchy sub on strat.parent_entity_id=sub.entity_id)b
--		on rg.fas_book_id=b.book_id
--		left join fas_subsidiaries fs on fs.fas_subsidiary_id=b.sub_id
--	where 1=1  --and formula_value_reduction is null
--	and rg.generator_id in(select generator_id from #formula_value1)
--	and year(a.term_start)<>fs.base_year_from
--	and ISNULL(rg.reduction_TYPE,-1)=-1
--	--and rg.reduction_sub_type is not null
--	group by rg.generator_id,ISNULL(rg.base_year,fs.base_year_from),ISNULL(rg.base_year,fs.base_year_to),rg.legal_entity_value_id,term_start,term_end
--	open cur3
--	fetch next from cur3 into @generator_id,@base_year_from,@base_year_to,@report_year,@sub_entity_id
--	while @@fetch_status=0
--	begin
--			set @base_year_term_start=cast(cast(@base_year_from as varchar)+'-01-01' as datetime)
--			set @base_year_term_end=cast(cast(@base_year_to as varchar)+'-12-31' as datetime)
--
--			SET @process_id = REPLACE(newid(),'-','_')
--			set @tablename=dbo.FNAProcessTableName('Emissions_Inventory',dbo.FNADBUser(),@process_id)
--			if @as_of_date is null
--				set @as_of_date=cast(cast(year(@term_start) as varchar)+'-12-31' as varchar)
--	
--	exec spa_emissions_tracking_report @as_of_date, @sub_entity_id, @strategy_entity_id,@report_year, NULl, NULL, 'a',@base_year_term_start,@base_year_term_end,@base_year_from,@base_year_to,@tablename,NULL,NULL,NULL,NULL,@generator_id,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Rerun',NULL,'y'
--		set @Sql_Select='
--			insert into #temp_reduction(generator_id,curve_id,reportingvol,basevol,forecast_type,fuel_type_value_id)
--				select
--					generator_id,curve_id,sum(ReportingYearVol)/12,sum(SumBaseYearsVol)/12,forecast_type,fuel_type_value_id
--				from '+@tablename+' 
--			group by generator_id,curve_id,forecast_type,fuel_type_value_id'
--			--print @Sql_Select
--			exec(@Sql_Select)
--
--	fetch next from cur3 into @generator_id,@base_year_from,@base_year_to,@report_year,@sub_entity_id
--	end
--	close cur3
--	deallocate cur3




update 
	a
set  	
	a.formula_value_reduction=
				(case when a.frequency=704 then b.basevol*3
					when a.frequency=705 then b.basevol*6
					when a.frequency=706 then b.basevol*12 
				 else  b.basevol end) - formula_value,
				--b.basevol-formula_value, 					  
				a.base_year_volume= b.basevol
--select a.*
from
	#formula_value1 a 
	left join formula_editor fe on fe.formula_id=a.formula_id_detail
	join #temp_reduction b on a.generator_id=b.generator_id 
	and a.curve_id=b.curve_id 
	and a.forecast_type=b.forecast_type and fe.static_value_id=b.fuel_type_value_id
	--and a.term_start=b.term_start and a.term_end=b.term_end
	left join rec_generator rg on rg.generator_id=b.generator_id
 
where 1=1
	--ISNULL(a.formula_value_reduction,'')=''

--############## breakdown the values to monthly according to frequency and save detail in a table

--drop table #temp_month
--drop table #formula_detail

create table #temp_month(
	month_id int
)

set @count=0
while @count<12
begin
	insert into #temp_month(month_id) values(@count)
	set @count=@count+1
end	


select 
	a.as_of_date,
	dateadd(month,month_id,a.term_start) term_start,
	dateadd(month,month_id+1,a.term_start)-1 term_end,a.generator_id,a.curve_id,
	case when a.frequency=704 then a.formula_value/3
	when a.frequency=705 then a.formula_value/6
	when a.frequency=706 then a.formula_value/12 else a.formula_value end  as formula_value,
	a.volume,
	a.uom_id,
	703 Frequency,
	a.current_forecast,a.formula_str,
	case when a.frequency=704 then a.formula_value_reduction/3
	when a.frequency=705 then a.formula_value_reduction/6
	when a.frequency=706 then a.formula_value_reduction/12 else a.formula_value_reduction end  as formula_value_reduction, 
	a.formula_id_reduction,a.reduction,
	a.formula_id,
	a.output_id,
	case when a.frequency=704 then a.output_value/3
	when a.frequency=705 then a.output_value/6
	when a.frequency=706 then a.output_value/12 else a.output_value end as output_value,
	output_uom_id,
	case when a.frequency=704 then a.heatcontent_value/3
	when a.frequency=705 then a.heatcontent_value/6
	when a.frequency=706 then a.heatcontent_value/12 else a.heatcontent_value end as heatcontent_value,
	heatcontent_uom_id,formula_str_reduction,formula_eval,formula_eval_reduction,input_id,
	char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,a.base_year_volume,
	a.forecast_type,
	a.formula_id_detail,
	a.formula_id_reduction_detail,
	a.EF
	
into
	#formula_detail
from
	#formula_value1 a,
	#temp_month b
where
	b.month_id<=case when a.frequency=703 then 0	
		    when a.frequency=704 then 2
		    when a.frequency=705 then 5
		    when a.frequency=706 then 11 end	



--and a.frequency<>703
---#### INSERT INTO INVENTORY TABLE
--EXEC spa_print 'Delete from emissions Inventory Started :'+convert(varchar(100),getdate(),113)	

delete a
from 	
	emissions_inventory_whatif a,
	#formula_detail b
where
	a.generator_id=b.generator_id 
	and a.curve_id=b.curve_id
	and a.term_start=b.term_start
	--and a.term_end=b.term_end
	and a.calculated='y'
	and a.forecast_type=b.forecast_type
	and a.as_of_date=b.as_of_date
	--and b.reduction='n' 
-- 	where generator_id=@generator_id 
-- 	and dbo.FNAGetContractMonth(as_of_date) >= dbo.FNAGetContractMonth(@as_of_date) 
	--and dbo.FNAGetContractMonth(@as_of_date)

-------------------------------------------------------------------------
--EXEC spa_print 'Delete from emissions Inventory Completed :'+convert(varchar(100),getdate(),113)	



Insert into emissions_inventory_whatif(
  	as_of_date,term_start,term_end,generator_id,frequency,curve_id,volume,uom_id,calculated,current_forecast,reduction_volume,base_year_volume,reduction_uom_id,forecast_type,fuel_type_value_id)
 select distinct
 	as_of_date,term_start,term_end,fd.generator_id,frequency,curve_id,
	MAX(ISNULL(formula_value,0)),uom_id,'y',current_forecast,
	case when MAX(formula_id_reduction_detail)<>0 and ISNULL(rg.reduction_TYPE,-1)<>-1 then MAX(ISNULL(formula_value_reduction,0)) 
		else round(MAX(base_year_volume)-SUM(ISNULL(formula_value,0)),2) end,
		MAX(base_year_volume),uom_id,forecast_type,ISNULL(fe1.static_value_id,fe.static_value_id)
 from
 	#formula_detail fd
	left join formula_editor fe on fe.formula_id=fd.formula_id_detail
	left join formula_editor fe1 on fe1.formula_id=fd.formula_id_reduction_detail
	left join rec_generator rg on rg.generator_id=fd.generator_id
 where 1=1 
	--AND formula_value IS NOT NULL
-- 	 and isnull(reduction,'n')<>'y' 

group by 
	term_start,term_end,fd.generator_id,frequency,curve_id,uom_id,current_forecast,forecast_type,ISNULL(fe1.static_value_id,fe.static_value_id),	
	as_of_date,rg.reduction_TYPE
--- ############# calculation for fugitive emissions based on direct Measurements

delete source
from 
	rec_generator rg
	inner join emissions_inventory_whatif sink on sink.generator_id=rg.generator_Id
	inner join emissions_inventory_whatif source on source.generator_id=rg.co2_captured_for_generator_id
	and sink.term_start=source.term_start and sink.term_end=source.term_end	
	and source.calculated='y' and source.curve_id=sink.curve_id	 
	inner join rec_generator rg1 on rg1.generator_id=source.generator_id and source.generator_id in(select generator_id from #formula_detail)
	
where	 
	  source.term_start between CONVERT(DATETIME,@term_start, 102) AND              
	  CONVERT(DATETIME,@term_end, 102) OR source.term_end between CONVERT(DATETIME,@term_start, 102) AND              
	  CONVERT(DATETIME,@term_end, 102)
	  and rg1.captured_co2_emission='y'
	  and source.forecast_type=sink.forecast_type



DECLARE @ems_fas_book_id int
set @ems_fas_book_id=-173
---------------------------------------------------------
Insert into emissions_inventory_whatif(
  	as_of_date,term_start,term_end,generator_id,frequency,curve_id,volume,uom_id,calculated,current_forecast,fas_book_id,forecast_type)
select 
	source.as_of_date,
	source.term_start,
	source.term_end,
	source.generator_id,
	source.frequency,
	source.curve_id,	
	source.volume-sink.reduction_volume as volume,
	source.uom_id,
	'y',
	source.current_forecast,
	@ems_fas_book_id,
	source.forecast_type
from
	rec_generator rg
	inner join emissions_inventory_whatif sink on sink.generator_id=rg.generator_Id
	inner join emissions_inventory_whatif source on source.generator_id=rg.co2_captured_for_generator_id
	and sink.term_start=source.term_start and sink.term_end=source.term_end	
	inner join rec_generator rg1 on rg1.generator_id=source.generator_id and source.generator_id in(select generator_id from #formula_detail)
where
	  source.term_start between CONVERT(DATETIME,@term_start, 102) AND              
	  CONVERT(DATETIME,@term_end, 102) OR source.term_end between CONVERT(DATETIME,@term_start, 102) AND              
	  CONVERT(DATETIME,@term_end, 102)
	  and rg1.captured_co2_emission='y'
	  and source.calculated='n'


--EXEC spa_print 'Inserted in emissions Inventory :'+convert(varchar(100),getdate(),113)	
--###########################################################
-- ## insert detail values

----------########################################################## REMOVE THIS ONE
select 
		a.generator_id,curve_id,(term_start) as term,avg(volume) as volume,forecast_type,fuel_type_value_id
into 
		#zzz_base_year_value
 from 
		emissions_inventory_whatif a inner join 
		rec_generator rg on a.generator_id=rg.generator_id 
where 
	a.generator_id in(SELECT generator_id FROM #formula_value1)
	AND year(term_start)=1995 and fuel_type_value_id is not null
	and ISNULL(rg.reduction_TYPE,-1)=-1
group by
	a.generator_id,curve_id,forecast_type,fuel_type_value_id,(term_start) order by volume


update a
	set a.base_year_volume=(b.volume),
		a.reduction_volume=(b.volume)-a.volume
from
	emissions_inventory_whatif a join
	#zzz_base_year_value b 
	on a.generator_id=b.generator_id 
	and a.forecast_type=b.forecast_type and isnull(a.fuel_type_value_id,'')=isnull(b.fuel_type_value_id,'')
	and MONTH(a.term_start)=MONTH(b.term)
where 1=1
	--a.generator_id=574
	and year(a.term_start)>1995
	and a.curve_id=b.curve_id
	--and a.curve_id=127

----------##########################################################



delete a
from 	
	ems_calc_detail_value_whatif a,
	#formula_detail b
where
	a.generator_id=b.generator_id 
	and a.curve_id=b.curve_id
	and a.term_start=b.term_start
	--and a.term_end=b.term_end
	and a.as_of_date=b.as_of_date
	and a.forecast_type=b.forecast_type
	--and calculated='y'


--EXEC spa_print 'Delete from Calc Detail Table :'+convert(varchar(100),getdate(),113)	

insert into ems_calc_detail_value_whatif(inventory_id,as_of_date,term_start,term_end,generator_id,curve_id,formula_value,volume,uom_id,frequency,
			current_forecast,formula_id,formula_str,formula_value_reduction,formula_id_reduction,reduction,output_value,output_uom_id,heatcontent_value,heatcontent_uom_id,output_id,formula_eval,formula_eval_reduction,formula_str_reduction,input_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,base_year_volume,forecast_type,fuel_type_value_id,formula_detail_id,emissions_factor)
select  b.emissions_inventory_id,a.as_of_date,a.term_start,a.term_end,a.generator_id,a.curve_id,
			max(ISNULL(a.formula_value,0)),max(a.volume),max(a.uom_id),max(a.frequency),
			a.current_forecast,a.formula_id,max(a.formula_str),max(ISNULL(a.formula_value_reduction,0)),a.formula_id_reduction,
			a.reduction,output_value,a.output_uom_id,max(a.heatcontent_value),max(a.heatcontent_uom_id),
			a.output_id,max(a.formula_eval),max(a.formula_eval_reduction),a.formula_str_reduction,
			NULL input_id,
			max(a.char1),max(a.char2),max(a.char3),max(a.char4),max(a.char5),max(a.char6),max(a.char7)
			,max(a.char8),max(a.char9),max(a.char10),a.base_year_volume,a.forecast_type,
			ISNULL(fe1.static_value_id,fe.static_value_id),formula_id_detail,max(a.EF)
	from 	#formula_detail a
			left join formula_editor fe on fe.formula_id=a.formula_id_detail
			left join formula_editor fe1 on fe1.formula_id=a.formula_id_reduction_detail
			inner join emissions_inventory_whatif b
			on 	a.generator_id=b.generator_id 
				and a.curve_id=b.curve_id
				and a.term_start=b.term_start
				and a.term_end=b.term_end
				and a.as_of_date=b.as_of_date
				and a.forecast_type=b.forecast_type
				and ISNULL(fe1.static_value_id,fe.static_value_id)=b.fuel_type_value_id
	WHERE 1=1
		 -- AND formula_value IS NOT NULL	
	group by 
			b.emissions_inventory_id,a.as_of_date,a.term_start,a.term_end,a.generator_id,a.curve_id,
			a.current_forecast,a.formula_id,a.formula_id_reduction,
			a.reduction,output_value,a.output_uom_id,
			a.output_id,a.formula_str_reduction,
			a.base_year_volume,a.forecast_type,
			ISNULL(fe1.static_value_id,fe.static_value_id),formula_id_detail,
			char1,char2,char3,char4,char5,char6,char7,char8,char9,char10
			

--EXEC spa_print 'Inserted in Calc Detail Table :'+convert(varchar(100),getdate(),113)	
---## insert into ems_emissions_input

--##### create deals from reductions

DECLARE @trader varchar(100)
DECLARE @user_login_id varchar(100)
DECLARE @counterparty int
set @user_login_id=dbo.FNADBUser()
set @trader='Xcelgen'
set @counterparty=201
--set @default_uom=24

set @tablename='adiha_process.dbo.reduction_deals_'+@process_id

set @Sql_Select='create table '+ @tablename+'( 
	 [Book] [varchar] (255)  NULL ,      
	 [Feeder_System_ID] [varchar] (255)  NULL ,      
	 [Gen_Date_From] [varchar] (50)  NULL ,      
	 [Gen_Date_To] [varchar] (50)  NULL ,      
	 [Volume] [varchar] (255)  NULL ,      
	 [UOM] [varchar] (50)  NULL ,      
	 [Price] [varchar] (255)  NULL ,      
	 [Formula] [varchar] (255)  NULL ,      
	 [Counterparty] [varchar] (50)  NULL ,      
	 [Generator] [varchar] (50)  NULL ,      
	 [Deal_Type] [varchar] (10)  NULL ,      
	 [Deal_Sub_Type] [varchar] (10)  NULL ,      
	 [Trader] [varchar] (100)  NULL ,      
	 [Broker] [varchar] (100)  NULL ,      
	 [Rec_Index] [varchar] (255)  NULL ,      
	 [Frequency] [varchar] (10)  NULL ,      
	 [Deal_Date] [varchar] (50)  NULL ,      
	 [Currency] [varchar] (255)  NULL ,      
	 [Category] [varchar] (20)  NULL ,      
	 [buy_sell_flag] [varchar] (10)  NULL,
	 [leg] [varchar] (20)  NULL ,
	 settlement_volume float,
	 settlement_uom int,
	 cert_number_from [varchar] (20)  NULL ,
	 cert_number_to [varchar] (20)  NULL 
)
			 
	'
	exec(@Sql_Select)

set @Sql_Select=
	'
	INSERT INTO '+@tablename+'
		(BOOK,
		[feeder_system_id],
		[Gen_Date_From],
		[Gen_Date_To],
		Volume,
		UOM,
		Price,
		Counterparty,
		Generator,
		[Deal_Type],
		Frequency,
		trader,
		[deal_date],
		currency,
		buy_sell_flag,
		leg,
		Rec_Index
		)
	SELECT 

		--ssbm.source_system_book_id1,
		sb.source_book_name,
		''emission_''+cast(tmp.generator_id as varchar)+''_''+dbo.FNAContractMonthFormat(tmp.term_start),
		dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth(tmp.term_start)),
		dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(tmp.term_start)),
		FLOOR(tmp.formula_value_reduction*COALESCE(conv1.conversion_factor,conv2.conversion_factor,conv3.conversion_factor)),
		esmd.credit_product_uom_id,
		NULL,
		ISNULL(rg.ppa_counterparty_id,'+cast(@counterparty as varchar)+'),
		tmp.generator_id,
		''CO2Eq'',
		''m'',
		'''+@trader+''',
		dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth(tmp.term_start)),
		''USD'',
		''b'',
		  1,
		 esmd.credit_env_product		
	from
		#formula_detail tmp inner join 	
		rec_generator rg on rg.generator_id=tmp.generator_id
		join source_system_book_map ssbm on ssbm.fas_book_id=rg.fas_book_id
		join source_book sb on sb.source_book_id=ssbm.source_system_book_id1

		inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
		inner join (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id from 
					ems_source_model_effective where isnull(effective_date,''1900-01-01'')<='''+@term_start+''' group by generator_id) ab
		on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
		inner join 
		ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
 		inner join ems_source_model_detail esmd on esmd.ems_source_model_id=esm.ems_source_model_id
		inner join source_price_curve_def spcd on spcd.source_curve_def_id = tmp.curve_id

		LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
		 conv1.from_source_uom_id  = spcd.uom_id
		 AND conv1.to_source_uom_id = esmd.credit_product_uom_id
		 And conv1.state_value_id = rg.gen_state_value_id
		 AND conv1.assignment_type_value_id is null
		 AND conv1.curve_id = tmp.curve_id 
	
		LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
		 conv2.from_source_uom_id = spcd.uom_id
		 AND conv2.to_source_uom_id = esmd.credit_product_uom_id
		 And conv2.state_value_id IS NULL
		 AND conv2.assignment_type_value_id IS NULL
		 AND conv2.curve_id = tmp.curve_id 
		       
		LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
		 conv3.from_source_uom_id = spcd.uom_id
		 AND conv3.to_source_uom_id = esmd.credit_product_uom_id
		 And conv3.state_value_id IS NULL
		 AND conv3.assignment_type_value_id IS NULL
		 AND conv3.curve_id IS NULL
	where rg.reduction=''y''
	'	
	--print @Sql_Select
	EXEC(@Sql_Select)


	exec spb_process_transactions @user_login_id,@tablename,'n','n'

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Emissions Calculation", 
		"spa_calc_emissions_inventory_job", "DB Error", 
		"Error creating Invoice.", ''
	else
		Exec spa_ErrorHandler 0, 'Emissions Calculation', 
		'spa_calc_emissions_inventory_job', 'Success', 
		'Success.',''
  
--
--
----exec(' select * from '+@tablename)
--
--
----------------------------------------------------------------------------------------------------------------

-- Log the Error when calculation factor is Not defined

	insert into #calc_status 
		select distinct @process_id,'Error','Emissions Inventory','Run Emissions Inventory','Results', 
		 'Missinsg Emissions factor found for source : '+rg.name+' for term: '+dbo.fnadateformat(tmp.term_start)+' formula:'+dbo.FNAFNACurveNames(fe.formula),''
		from 
			(SELECT distinct generator_id,term_start,curve_id,forecast_type,formula_id_detail from #temp) tmp

			INNER JOIN ems_calc_detail_value_whatif ecdv on ecdv.generator_id=tmp.generator_id
				AND ecdv.term_start=tmp.term_start 
				and ecdv.curve_id=tmp.curve_id
				and ecdv.forecast_type=tmp.forecast_type
				and ecdv.formula_detail_id=tmp.formula_id_detail
				--AND ISNULL(formula_value,0)<>0
			INNER JOIN rec_generator rg on rg.generator_id=tmp.generator_id
			LEFT JOIN formula_nested fn on fn.formula_group_id=ISNULL(ecdv.formula_id,ecdv.formula_id_reduction)
			LEFT JOIN formula_editor fe on fe.formula_id=COALESCE(fn.formula_id,ecdv.formula_id,ecdv.formula_id_reduction)
	
		WHERE 1=1 
					
			 		AND ((ecdv.formula_str like '%EMSConv%' AND (ISNULL(ecdv.formula_eval,'') like '%undef%' OR ecdv.emissions_factor IS NULL)) OR
					(ecdv.formula_str_reduction like '%EMSConv%' AND (ISNULL(ecdv.formula_eval_reduction,'') like '%undef%' OR ecdv.emissions_factor IS NULL)))


if not exists(select * from #calc_status where errorcode='error')
	insert into #calc_status 
	select distinct @process_id, 'Success','Emissions Inventory','Run Emissions Inventory','Results',
	'Emissions Inventory Calculated as of : '+ dbo.FNAUserDateFormat(getdate(), @user_name)+' for '+[name],''
	from rec_generator where generator_id in(select generator_id from #formula_detail)

	
--------------------------------------------------------------------------------
-- log all errors

if @process_id is NULL 
Begin

	select errorcode,module,source,type,[description],nextstep from #calc_status
	return
END
else
Begin
	insert into inventory_accounting_log(process_id,code,module,source,type,[description],nextsteps)  
	select * from #calc_status where process_id=@process_id
	
	

	SET @url = './dev/spa_html.php?__user_name__=' + @user_name + 
		'&spa=exec spa_get_inventory_accounting_log ''' + @process_id + ''''
	

	DECLARE @error_count int
	DECLARE @e_type char
	
	SELECT  @error_count =   COUNT(*) 
	FROM        inventory_accounting_log
	WHERE     process_id = @process_id AND code = 'Error'
	
	If @error_count > 0 
		SET @e_type = 'e'
	Else
		SET @e_type = 's'


	
	set @desc = 'Emissions Inventory Calculated as of ' + dbo.FNAUserDateFormat(getdate(), @user_name) 
		


		SET @desc = '<a target="_blank" href="' + @url + '">' + @desc + 
			case when (@e_type = 'e') then ' (ERRORS found)' else '' end +
			'.</b></a>'
		

		EXEC  spa_message_board 'i', @user_name,      
		   NULL, 'Emissions Inventory ',      
		   @desc, '', '', @e_type, @job_name      

END