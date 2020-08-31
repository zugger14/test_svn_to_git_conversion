
IF OBJECT_ID('[dbo].[spa_generator_exception_input]','p') IS NOT NULL
DROP proc [dbo].[spa_generator_exception_input] 
GO 

CREATE proc [dbo].[spa_generator_exception_input] 
	@term_start varchar(20),
	@frequency int, 
	@report_period char(1),
	@generator_id varchar(100)=NULL,
	@ems_book_id varchar(100)=null,
	@fas_book_id varchar(100)=null,
	@fas_strategy_id varchar(100)=null,
	@fas_sub_id varchar(100)=null,
	@term_end datetime=null,
	@series_type int=null
as

-- declare @generator_id varchar(100),@term_start varchar(20),@frequency int, @ems_book_id varchar(100),
-- @fas_book_id varchar(100),@report_period char(1),@fas_strategy_id char(100),@fas_sub_id varchar(100)
-- 
-- set @generator_id=276
-- set @term_start='2006-01-01'
-- set @frequency=706
-- set @report_period='r'
-- --set @ems_book_id=29
-- --set @fas_book_id=157
-- 
-- drop table #temp_input
-- create temp table with list of dates
create table #temp_date([id] int identity,term_start datetime,term_end datetime)
declare @count int
declare @terms_start_new datetime
declare @terms_end_new datetime


if @frequency=703
BEGIN
set @terms_start_new=dateadd(month,-1,@term_start)
while dbo.FNAGETCONTRACTMONTH(@terms_start_new)<=dbo.FNAGETCONTRACTMONTH(dateadd(month,-1,@term_end))
BEGIN

	set @terms_start_new=dateadd(month,1,@terms_start_new)
	set @terms_end_new=dateadd(month,1,@terms_start_new)-1

	insert into #temp_date(term_start,term_end)
	 select dbo.FNAGETCONTRACTMONTH(@terms_start_new),@terms_end_new
	
END
END
else if @frequency=706
BEGIN
set @terms_start_new=dateadd(month,-12,@term_start)
while dbo.FNAGETCONTRACTMONTH(@terms_start_new)<=dbo.FNAGETCONTRACTMONTH(dateadd(month,-12,@term_end))
BEGIN

	set @terms_start_new=dateadd(month,12,@terms_start_new)
	set @terms_end_new=dateadd(month,12,@terms_start_new)-1

	insert into #temp_date(term_start,term_end)
	 select dbo.FNAGETCONTRACTMONTH(@terms_start_new),@terms_end_new
	
END
END





--return
create table #temp_input(
input_id int,
input_name varchar(100) COLLATE DATABASE_DEFAULT,
InputOutput varchar(100) COLLATE DATABASE_DEFAULT,
generator_id int,
ems_generator_id int,
uom_id int,
constant_value char(1) COLLATE DATABASE_DEFAULT,
forecast_type int,
term_start datetime,
term_end datetime
)
declare @sql_stmt varchar(5000)
	set @sql_stmt='
	insert #temp_input(input_id,input_name,InputOutput,generator_id,ems_generator_id,uom_id,constant_value,forecast_type,term_start,term_end)
	select input_id,input_name,InputOutput,generator_id,max(isNull(ems_generator_id,-1)) ems_generator_id,uom_id,constant_value,ISNULL(forecast_type,-1),term_start,term_end from(
	select input_id ,input_name ,sdv.code InputOutput,rg.generator_id,null ems_generator_id,ems.uom_id,constant_value, 
	forecast.value_id as forecast_type,td.term_start as term_start,td.term_end as term_end
	from ems_input_map eim 
	join ems_source_input ems on eim.Input_id=ems.ems_source_input_id  
	inner join ems_source_model_effective esme on eim.source_model_id=esme.ems_source_model_id
	inner join (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id from 
				ems_source_model_effective where isnull(effective_date,''1900-01-01'')<='''+@term_start +''' group by generator_id) ab
	on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
	inner join 
		ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
	left join rec_generator rg on rg.generator_id=esme.generator_id
	join static_data_value sdv on sdv.value_id=ems.input_output_id
	join portfolio_hierarchy b  on b.entity_id=rg.fas_book_id
	join portfolio_hierarchy strat on b.parent_entity_id=strat.entity_id 
	join portfolio_hierarchy sub on strat.parent_entity_id=sub.entity_id
	left join #temp_date td on 1=1
	LEFT join (select value_id from static_data_value where type_Id=14300 UNION select -1 as value_id) forecast on 1=1
	where 1=1 '
	if @generator_id is not null
		 set @sql_stmt=@sql_stmt+ ' and rg.generator_id in('+ @generator_id +')' 
	if @ems_book_id is not null
		 set @sql_stmt=@sql_stmt+ ' and rg.generator_id in (select generator_id from rec_generator where 
		ems_book_id in ('+ @ems_book_id  +'))'
	if @fas_book_id is not null
		 set @sql_stmt=@sql_stmt+ ' and rg.generator_id in (select generator_id from rec_generator where 
		fas_book_id in ('+ @fas_book_id  +'))'
	if @fas_strategy_id is not null
		 set @sql_stmt=@sql_stmt+ ' and strat.entity_id in ('+ @fas_strategy_id  +')'
	if @fas_sub_id is not null
		 set @sql_stmt=@sql_stmt+ ' and sub.entity_id in ('+ @fas_sub_id  +')'
	if @series_type is not null
		 set @sql_stmt=@sql_stmt+ ' and forecast.value_id  ='+cast(@series_type as varchar)
	
	 set @sql_stmt=@sql_stmt+ '
	union all
	select ems.ems_source_input_id,input_name,sdv.code,rg.generator_id ,null ems_generator_id,ems.uom_id,constant_value,
	forecast.value_id,td.term_start as term_start,td.term_end as term_end
	from ems_source_input ems join level_input_map lim
	on ems.ems_source_input_id=lim.ems_source_input_id 
	join rec_generator rg on rg.ems_book_id=lim.group_level_id
	join static_data_value sdv on sdv.value_id=ems.input_output_id
	join portfolio_hierarchy b  on b.entity_id=rg.fas_book_id
	join portfolio_hierarchy strat on b.parent_entity_id=strat.entity_id 
	join portfolio_hierarchy sub on strat.parent_entity_id=sub.entity_id
	left join #temp_date td on 1=1
	LEFT join (select value_id from static_data_value where type_Id=14300 UNION select -1 as value_id) forecast on 1=1
	where 1=1 '
	if @generator_id is not null
		 set @sql_stmt=@sql_stmt+ ' and rg.generator_id in('+ @generator_id +')' 
	if @ems_book_id is not null
		 set @sql_stmt=@sql_stmt+ ' and rg.generator_id in (select generator_id from rec_generator where 
		ems_book_id in ('+ @ems_book_id  +'))'
	if @fas_book_id is not null
		 set @sql_stmt=@sql_stmt+ ' and rg.generator_id in (select generator_id from rec_generator where 
		fas_book_id in ('+ @fas_book_id  +'))'
	if @fas_strategy_id is not null
		 set @sql_stmt=@sql_stmt+ ' and strat.entity_id in ('+ @fas_strategy_id  +')'
	if @fas_sub_id is not null
		 set @sql_stmt=@sql_stmt+ ' and sub.entity_id in ('+ @fas_sub_id  +')'
	if @series_type is not null
		 set @sql_stmt=@sql_stmt+ ' and forecast.value_id  ='+cast(@series_type as varchar)

	set @sql_stmt=@sql_stmt+ '
	union all 
	select ems_input_id,input_name,sdv.code,g.generator_id,ems_generator_id,ems.uom_id,constant_value,g.forecast_type,
	g.term_start,g.term_end
	from ems_gen_input g join ems_source_input ems 
	on g.ems_input_id=ems.ems_source_input_id
	join static_data_value sdv on sdv.value_id=ems.input_output_id
	join rec_generator rg on rg.generator_id=g.generator_id
	join portfolio_hierarchy b  on b.entity_id=rg.fas_book_id
	join portfolio_hierarchy strat on b.parent_entity_id=strat.entity_id 
	join portfolio_hierarchy sub on strat.parent_entity_id=sub.entity_id
	join #temp_date td on td.term_start=g.term_start and td.term_end=g.term_end
	where 1=1
	and frequency='+ cast(@frequency as varchar) 
	if @generator_id is not null
		 set @sql_stmt=@sql_stmt+ ' and g.generator_id in('+ @generator_id +')' 
	if @ems_book_id is not null
		 set @sql_stmt=@sql_stmt+ ' and g.generator_id in (select generator_id from rec_generator where 
		ems_book_id in ('+ @ems_book_id  +'))'
	if @fas_book_id is not null
		 set @sql_stmt=@sql_stmt+ ' and g.generator_id in (select generator_id from rec_generator where 
		fas_book_id in ('+ @fas_book_id  +'))'
	if @fas_strategy_id is not null
		 set @sql_stmt=@sql_stmt+ ' and strat.entity_id in ('+ @fas_strategy_id  +')'
	if @fas_sub_id is not null
		 set @sql_stmt=@sql_stmt+ ' and sub.entity_id in ('+ @fas_sub_id  +')'
	if @series_type is not null
		 set @sql_stmt=@sql_stmt+ ' and g.forecast_type  ='+cast(@series_type as varchar)

	 set @sql_stmt=@sql_stmt+ '  or (ems.constant_value=''y'' and g.generator_id in('+ @generator_id +'))) 
p group by generator_id,input_id,input_name,InputOutput,uom_id,constant_value,ISNULL(forecast_type,-1),term_start,term_end '

EXEC spa_print @sql_stmt

exec(@sql_stmt)



select dbo.FNAEmissionHyperlink(3,12101500, rg.Name , cast(t.generator_id as varchar),'"e"') [EMS Source],
dbo.FNAEmissionHyperlink(2,12101400, esm.ems_source_model_name , cast(esm.ems_source_model_id as varchar),NULL)
[Source Model], dbo.FNAEmissionHyperlink(2,12101300,cast(input_id as varchar) +') '+ input_name + case when t.constant_value='y' then ' (CONSTANT) ' else '' end,input_id,NULL) [Input Name],
InputOutput [Input Output],
ISNULL(forecast.code,'Default Inventory') as [Type],
dbo.FNADateFormat(t.term_start) [Term Start],
dbo.FNADateFormat(t.term_end) [Term End],
sdv.code Frequency,sum(g.input_value) [Input Value],su.uom_name UOM,
case when t.ems_generator_id=-1 then 
dbo.FNAHyperLinkInput('Outstanding',@frequency,input_name,@report_period,t.uom_id,input_id,t.generator_id,@term_start,ISNULL(t.forecast_type,-1)) else 'Ok' end
  Status
 from #temp_input t
left outer join ems_gen_input g on t.ems_generator_id=g.ems_generator_id
left outer join source_uom su on su.source_uom_id=g.uom_id
left outer join rec_generator rg on rg.generator_id=t.generator_id
left outer join ems_source_model esm on esm.ems_source_model_id=rg.ems_source_model_id
left outer join static_data_value sdv on sdv.value_id=@frequency
left outer join static_data_value forecast on forecast.value_id=t.forecast_type
group by t.generator_id,rg.Name,input_id,input_name,InputOutput,t.term_start,t.term_end,t.ems_generator_id,t.forecast_type,
forecast.code,t.uom_id,su.uom_name,esm.ems_source_model_name,esm.ems_source_model_id,sdv.code,constant_value
order by rg.Name , esm.ems_source_model_name,InputOutput,forecast.code,t.term_start













