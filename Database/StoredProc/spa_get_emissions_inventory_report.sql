IF OBJECT_ID(N'[dbo].[spa_get_emissions_inventory_report]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_emissions_inventory_report]
 GO 
-- exec spa_get_emissions_inventory_report  NULL,'138,201,137,135,136',NULL,2007,'I.2.A.1',NULL,'a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
-- exec [spa_get_emissions_inventory_report] 
CREATE PROC [dbo].[spa_get_emissions_inventory_report]
		@as_of_date varchar(20),            
		@sub_entity_id varchar(100)=null,
		@strategy_entity_id varchar(100),
		@reporting_year INT,
		@report_section varchar(20), --use Schedule.Section.Part.Item format. For example., "I.2.A" for aggregated report
		@process_id varchar(50),
		@report_type varchar(1) = 'r', -- 'b' only show base period, 'r' only show reporting period, 'a' show both base and reporting
		@prod_month_from DATETIME = null,  --null
		@prod_month_to DATETIME  = null,  --null,
		@base_year_from int=null,
		@base_year_to int=null,
		@table_name varchar(100)=null,		
		@book_entity_id varchar(100)=null,	
		@forecast char(1)='r', 
		@curve_id INT =NULL,--gas
		@generator_group_id VARCHAR(50)=NULL, 
		@generator_id INT = NULL, 
		@source_sink_type INT = NULL, 
		@reduction_type int = NULL, 
		@reduction_sub_type int = NULL,
		@uom_id int=NULL,
		@technology_type int=null,
		@technology_sub_type int=null,
		@primary_fuel int=null,
		@fuel_type int=null,
		@udf_source_sink_group int=null,
		@udf_group1 int=null,
		@udf_group2 int=null,
		@udf_group3 int=null,
		@include_hypothetical char(1)=null,
		-- drill down
		@drill_down_level int=null,
		@report_year_level int=NULL,--1 year1, 2 year2, 3 year3,4 year4 5 base year 6 reporting year
		@source varchar(100)=NULL,
		@group1 varchar(100)=NULL,
		@group2 varchar(100)=NULL,
		@group3 varchar(100)=NULL,
		@gas varchar(100)=NULL,
		@generator varchar(100)=NULL,
		@year int=null,
		@term_start datetime=NULL,
		@emissions_reductions char(1)=null,
		@deminimis char(1)='n',
		@reporting_group_id int=5244,
		@program_scope varchar(100)=null,
		@use_process_id varchar(50)='RERUN',
		@form_type char(1)=null
				

AS
SET NOCOUNT ON 


---------------------------
-----------UNCOMMENT BELOW FOR TESTING

-- DECLARE @as_of_date varchar(20)            
-- DECLARE  @sub_entity_id int
-- DECLARE  @strategy_entity_id int
-- DECLARE  @reporting_year INT
-- DECLARE  @prod_month_from DATETIME  --null
-- DECLARE  @prod_month_to DATETIME    --null
-- DECLARE  @report_type varchar(1) -- 'b' only show base period, 'r' only show reporting period, 'a' show both base and reporting
-- 
-- 
-- SET @as_of_date = '2006-12-31'
-- SET @sub_entity_id = 136
-- SET @strategy_entity_id = NULL
-- SET @reporting_year = 2006
-- SET @report_type = 'a'
-- drop table #ssbm 
-- drop table #temp 
-- drop table #temp2 
-- drop table #temp    
-- drop table #temp2    
-----------UNCOMMENT ABOVE FOR TESTING
---------------------------

--set @forecast=null
--EXEC spa_print 'start :'+convert(varchar(100),getdate(),113)
--Always make as of date as last day of the year
set @as_of_date = cast(year(@as_of_date) as varchar) + '-12-31'

DECLARE @Sql_Select varchar(1000)
DECLARE @Sql_Where varchar(1000)
DECLARE  @convert_uom_id INT
--DECLARE  @reporting_group_id int
--DECLARE  @forecast varchar(1) -- 'y' means forecast only
DECLARE @SQL VARCHAR(8000)

DECLARE @base_yr1 int
DECLARE @base_yr2 int
DECLARE @base_yr3 int
DECLARE @base_yr4 int
DECLARE @base_yr_count int
DECLARE @base_yr_from int
DECLARE @base_yr_to int

DECLARE @new_process_id varchar(100)
--DECLARE @table_name varchar(100)
DECLARE @sql_stmt varchar(8000)
DECLARE @sql_stmt1 varchar(8000)

DECLARE @input_count_duplicate int
select @input_count_duplicate = 12


if @source='Indirect Emissions from Purchased Energy for Emissions Inventoy' set @source='Indirect Emissions'
if @source='Indirect Emissions from Purchased Energy for Calculation of Emission Reductions' set @source='Indirect Emissions'
if @source='Captured CO2 Sequestered in an Onsite Geologic Reservoir ' set @source='Direct Emissions'

set @base_yr1 = null
set @base_yr2 = null
set @base_yr3 = null
set @base_yr4 = null

-- DECLARE @reporting_year int
-- set @reporting_year = 2005
-- DECLARE  @strategy_entity_id int
-- set @strategy_entity_id = 139
if @process_id is null
	set @new_process_id=REPLACE(newid(),'-','_')
else
	set @new_process_id=@process_id

--Uday harcoding/changes
if isnull(@use_process_id, 'RERUN') NOT IN ('NEW', 'RERUN')
	set @new_process_id  = @use_process_id

if @table_name is null
	set @table_name='adiha_process.dbo.Emissions_Inventory_'+@new_process_id
	--set @table_name=dbo.FNAProcessTableName('Emissions_Inventory',dbo.FNADBUser(),@new_process_id)
create table #fas_id(fas_id int)

set @Sql_Select='
insert into #fas_id(fas_id)
select fas_subsidiary_id from
	fas_subsidiaries where fas_subsidiary_id in('+@sub_entity_id+')'

exec(@Sql_Select)
--EXEC spa_print 'start 1:'+convert(varchar(100),getdate(),113)

--SET @reporting_group_id = 5244 

--Uday hardcoding/changes  Just to corrent a problem in report
if @report_section = 'A8.D.1'
begin
	select NULL as [Name of Recipient], NULL as [Gas], NULL as [Units], NULL as [Amount]
	return
end
if @report_section = 'A1.B.1'
begin
	select NULL as [Item], NULL as [Description], NULL as [DI], NULL as [IE],  NULL as [OIE]
	return
end


set @base_yr_from=@base_year_from
set @base_yr_to=@base_year_to


if @base_year_from is null
BEGIN
	if @sub_entity_id is not null and (select count(*) from #fas_id)=1
		select 	@base_yr_from = base_year_from, @base_yr_to = 
			isnull(base_year_to, base_year_from) from fas_subsidiaries where fas_subsidiary_id in(select fas_id from #fas_id)
	else
		select 	@base_yr_from = base_year_from, @base_yr_to = 
			isnull(base_year_to, base_year_from) from fas_subsidiaries where fas_subsidiary_id=-1

-- 	else
-- 		select 	@base_yr_from = base_year_from, @base_yr_to = 
-- 			isnull(base_year_to, base_year_from) from fas_strategy where fas_strategy_id  = @strategy_entity_id
	
	END
else
begin
	set @base_yr_from=@base_year_from
	set @base_yr_to=@base_year_to
end



set @base_yr1 = @base_yr_from

set @base_yr_count = case when (@base_yr1 is not null) then 1 else null end

if (@base_yr1+1) <= @base_yr_to
BEGIN
	set @base_yr2 = @base_yr1+1
	set @base_yr_count = @base_yr_count + 1
END 
if (@base_yr1+2) <= @base_yr_to
BEGIN
	set @base_yr3 = @base_yr1+2
	set @base_yr_count = @base_yr_count + 1
END
if (@base_yr1+3) <= @base_yr_to
BEGIN
	set @base_yr4 = @base_yr1+3
	set @base_yr_count = @base_yr_count + 1
END

DECLARE @direct_emissions_id int
DECLARE @indirect_emissions_id int
DECLARE @carbon_flux_id int
DECLARE @other_indirect_emissions_id int
DECLARE @captured_co2_id int
DECLARE @stationary_combustion INT
DECLARE @mobile_sources INT
DECLARE @sector_specific INT
DECLARE @agriculture_sources INT
DECLARE @fugitive_emissions INT
DECLARE @catpured_co2_ems INT
DECLARE @forest_activities int
DECLARE @wood_products int
DECLARE @land_restoration int
DECLARE @natural_disturbance int
DECLARE @sus_managed_forest int
DECLARE @incidental_land int
DECLARE @other_terestrial_carbon_flux int
DECLARE @Electricity int
DECLARE @sustainable_forest int
DECLARE @system_input_id int
DECLARE @domestic_country_id int

set @direct_emissions_id = 2
set @indirect_emissions_id = 3
set @carbon_flux_id = 5
set @other_indirect_emissions_id = 4
set @captured_co2_id = 115

set @stationary_combustion = 6
set @mobile_sources = 7
set @sector_specific = 9
set @agriculture_sources = 8
set @fugitive_emissions = 116
set @catpured_co2_ems = 117
set @forest_activities=19
set @sustainable_forest=145
set @other_terestrial_carbon_flux=22
set @Electricity=124
set @wood_products=55
set @land_restoration=21
set @natural_disturbance=142

DECLARE @co2_gas_id int
DECLARE @ch4_gas_id int
DECLARE @n20_gas_id int
DECLARE @conv_to_gas varchar(50)
DECLARE @CO2Eq_deal_type_id int
DECLARE @monthly_frequency int
--DECLARE @program_scope int

DECLARE @emissions_intensity int
DECLARE @emissions_absolute int
DECLARE @emissions_carbon_storage int
DECLARE @emissions_avoided int
DECLARE @action_specific int
DECLARE @geo_seq_reduc int
DECLARE @ownCO2Sinks int
DECLARE @fossil_fuel int 

set @fossil_fuel=23
set @emissions_intensity=5251
set @emissions_absolute=5252
set @emissions_carbon_storage=5258
set @emissions_avoided=5259
set @action_specific=5260
set @geo_seq_reduc=5262
set @ownCO2Sinks=184

set @monthly_frequency=703
set @co2_gas_id = 127
set @ch4_gas_id = 182
set @n20_gas_id = 183
--set @program_scope=3100
set @CO2Eq_deal_type_id=59


DECLARE @tab_space varchar(50)
set @tab_space = ''

--SET @convert_uom_id = 29
select @convert_uom_id =  uom_id from source_price_curve_Def where source_curve_def_id = @co2_gas_id 
SET @conv_to_gas='CO2e'




SET @system_input_id=1051
SET @domestic_country_id=5270

SET @sql_Where = ''            



CREATE TABLE #tmp_program_scope(program_scope int)
if @program_scope IS NULL or @program_scope='NULL'
	insert into #tmp_program_scope(program_scope) select value_id from static_data_value where type_Id=3100
else
	begin
		SET @Sql_Select= 'insert into #tmp_program_scope(program_scope) select value_id from static_data_value where value_id in('+@program_scope+')'
		EXEC(@Sql_Select)
	end


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
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR) + ' ))'            
  IF @book_entity_id IS NOT NULL            
   SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            

--Uday hardcoding/changes
if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
	EXEC (@Sql_Select)            
--------------------------------------------------------------    

   
IF @prod_month_from IS NOT NULL OR @prod_month_to IS NOT NULL
begin
	IF @prod_month_from IS NOT NULL AND @prod_month_to IS NULL
		SET @prod_month_to = @prod_month_from
	IF @prod_month_from IS NULL AND @prod_month_to IS NOT NULL
		SET @prod_month_from = @prod_month_to
end

-- select * from source_price_curve_def
-- SELECT * from ems_technology_map 
-- select * from #ssbm
-- select * from source_uom
-- select * from rec_unit_conversion
-- select * from rec_volume_unit_conversion 
 
--set @reporting_year = isnull(@reporting_year, year(getdate()))

if @process_id is null
BEGIN
---###########First Bring REC DEALS
DECLARE @process_id1 varchar(100)
DECLARE @table_RECS varchar(128)
DECLARE @reporting_year1 int

SET @process_id1 = REPLACE(newid(),'-','_')
	select @table_RECS=dbo.FNAProcessTableName('Emissions_REC',dbo.FNADBUser(),@process_id1)

if @reporting_year is not null
	--set @reporting_year1=year(@as_of_date)
--else 
	set @reporting_year1=@reporting_year

if @as_of_date is null and @reporting_year is not null
	set @as_of_date='12/31/'+cast(@reporting_year as varchar)

-------##############
declare @max_base_year int

if @prod_month_from is not null 
	set @max_base_year=COALESCE(@base_yr4,@base_yr3,@base_yr2,@base_yr1)

--Uday hardcoding/changes
if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
	EXEC spa_get_co2_avoided_recs @sub_entity_id, @as_of_date, @reporting_year1,@max_base_year,@convert_uom_id,@table_RECS


---###
--EXEC spa_print 'Start Inventory Report 1 :'+convert(varchar(100),getdate(),113)

--Uday hardcoding/changes
if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
BEGIN

/*
create table #temp_fug(
	generator_id int,
	term_start datetime,
	volume float
)

insert into #temp_fug
SELECT     generator_id, term_start, SUM(volume)AS volume
FROM  emissions_inventory
WHERE     (fas_book_id < 0)
GROUP BY generator_id, term_start
*/




--select max(as_of_date) as_of_date,generator_id,curve_id,term_start,forecast_type,fuel_type_value_id
--into #temp_f1
--from emissions_inventory
--where year(term_start)<=ISNULL(year(term_start),@reporting_year)
--	group by term_start,generator_id,curve_id,forecast_type,fuel_type_value_id

--############## create a temporary invnetoyr_table
select 
	ei.emissions_inventory_id,ei.as_of_date,ei.term_start,ei.term_end,ei.generator_id,ei.frequency,ei.curve_id,ei.volume,
		ei.uom_id,ei.calculated,ei.current_forecast,ei.fas_book_id,ei.reduction_volume,ei.reduction_uom_id,
		ei.base_year_volume,edr.series_type forecast_type,
		ei.fuel_type_value_id
into 
	#emissions_inventory

from
	 emissions_inventory ei 
	LEFT JOIN ems_edr_include_inv edr on 
	 ei.generator_id=edr.generator_id and ei.curve_id=edr.curve_id
	 and ei.term_start  between edr.term_start and edr.term_end
	and ei.forecast_type=edr.series_type
where	1=1
	and edr.generator_id is not null
	
UNION

select ei.emissions_inventory_id,ei.as_of_date,ei.term_start,ei.term_end,ei.generator_id,ei.frequency,ei.curve_id,ei.volume,
		ei.uom_id,ei.calculated,ei.current_forecast,ei.fas_book_id,ei.reduction_volume,ei.reduction_uom_id,
		ei.base_year_volume,ei.forecast_type forecast_type,
		ei.fuel_type_value_id
from
	 emissions_inventory ei 
	LEFT JOIN ems_edr_include_inv edr on 
	 ei.generator_id=edr.generator_id and ei.curve_id=edr.curve_id
	 and ei.term_start  between edr.term_start and edr.term_end
	and ei.forecast_type=edr.series_type
where	1=1
	and edr.generator_id is null




CREATE TABLE [dbo].[#temp_inventory] (
	[as_of_date] [datetime] NOT NULL ,
	[Group1_ID] [int] NULL ,
	[Group2_ID] [int] NULL ,
	[Group3_ID] [int] NULL ,
	[Group1] [varchar] (300)  NULL ,
	[Group2] [varchar] (200)  NOT NULL ,
	[Group3] [varchar] (200)  NOT NULL ,
	[generator_id] [int] NOT NULL ,
	[code] [varchar] (250)   NULL ,
	[name] [varchar] (250)  NOT NULL ,
	[frequency] [int] NOT NULL ,
	[curve_id] [int] NOT NULL ,
	[curve_name] [varchar] (100)  NOT NULL ,
	[curve_des] [varchar] (250)  NULL ,
	[co2_curve_desc] [varchar] (250)  NULL ,
	[original_volume] [float] NULL ,
	[volume] [float] NULL ,
	[uom_id] [int] NOT NULL ,
	[to_uom_id] [int] NOT NULL ,
	[conversion_factor] [float] NULL ,
	[co2_conversion_factor] [float] NULL ,
	[uom_name] [varchar] (100)  NULL ,
	[co2_uom_name] [varchar] (100)  NULL ,
	[calculated] [varchar] (1)  NOT NULL ,
	[rating_value_id] [int] NULL ,
	[rating_weight] [varchar] (250)  NULL ,
	[rating_value] [float] NULL ,
	[reporting_year] [int] NULL ,
	[gas_sort_order] [int] NULL ,
	[estimation_method] [varchar] (250)  NULL ,
	[Item] [varchar] (31)  NULL ,
	[fuel_value_id] [int] NULL ,
	[sub] [varchar] (200)  NOT NULL ,
	[captured_co2_emission] [char] (1)  NULL ,
	[onsite_offsite] [char] (1)  NULL ,
	[technology] [varchar] (50)  NOT NULL ,
	[classification] [varchar] (50)  NULL ,
	[first_gen_date] [datetime] NULL ,
	[term_start] [datetime] NULL ,
	[term_end] [datetime] NULL ,
	[output_id] [int] NULL ,
	[output_value] [float] NULL ,
	[output_uom_id] [int] NULL ,
	[heatcontent_value] [float] NULL ,
	[heatcontent_uom_id] [int] NULL ,
	[current_forecast] [char] (1)  NULL ,
	[formula_str] [varchar] (8000)  NULL ,
	[formula_eval] [varchar] (1000)  NULL ,
	[reduction_volume] [float] NULL ,
	[reduction_uom_name] [varchar] (100)  NULL ,
	[source_deal_header_id] [int] NULL ,
	[source_deal_detail_id] [int] NULL ,
	[counterparty_id] [int] NULL ,
	[counterparty_name] [varchar] (100)  NULL ,
	[source_deal_type_id] [int] NULL ,
	[source_deal_type_name] [varchar] (30)  NULL ,
	[deal_sub_type_type_id] [int] NULL ,
	[deal_sub_type_name] [varchar] (30)  NULL ,
	[buy_sell_flag] [varchar] (30)  NULL ,
	[ext_deal] [int] NOT NULL ,
	[de_minimis_source] [varchar] (1)  NULL ,
	[co2_captured_for_generator_id] [int] NULL,
	forecast_type int NULL ,
	forecast_type_value varchar(100),
	fuel_type_value_id int,
	source_model_id	int,
	default_inventory int	
)

 
CREATE  INDEX [IX_tmp2] ON [#temp_inventory]([Group1_ID])  
CREATE  INDEX [IX_tmp3] ON [#temp_inventory]([Group2_ID])  
CREATE  INDEX [IX_tmp4] ON [#temp_inventory]([Group3_ID])  
CREATE  INDEX [IX_tmp5] ON [#temp_inventory]([generator_id])  
CREATE  INDEX [IX_tmp6] ON [#temp_inventory]([curve_id])  


--select * from #emissions_inventory
--EXEC spa_print 'Start Inventory Report 1 :'+convert(varchar(100),getdate(),113)

insert into #temp_inventory
 SELECT   distinct    
  	ei.as_of_date, 
	case when stra.entity_id =@ownCO2Sinks then @direct_emissions_id else sub.entity_id end Group1_ID,
	case when stra.entity_id =@ownCO2Sinks then @stationary_combustion else stra.entity_id end Group2_ID,
	case when stra.entity_id =@ownCO2Sinks then @fossil_fuel when (ei.fas_book_id < 0) then -1*ei.fas_book_id else book.entity_id end Group3_ID,
--	sub.entity_name Group1, 
	case 	when stra.entity_id =@ownCO2Sinks then 'CO2 (Carbon Dioxide)'
		when (sub.entity_id = @direct_emissions_id) then @tab_space + spcd.curve_des
		when (sub.entity_id = @indirect_emissions_id ) then 'Indirect Emissions from Purchased Energy'
		when (sub.entity_id = @carbon_flux_id ) then sub.entity_name
		when (sub.entity_id = @other_indirect_emissions_id  ) then @tab_space + spcd.curve_des
		when (sub.entity_id = @captured_co2_id) then sub.entity_name + ' for Sequestration in a Gelogic Reservoir'
	else 'Unknow Item' end Group1,
	case when stra.entity_id =@ownCO2Sinks then 'Stationary Combustion' else  stra.entity_name end Group2, 
	case when stra.entity_id =@ownCO2Sinks then 'Fossil Fuel Combustion' when (ei.fas_book_id < 0) then 'Fugitive Emissions During Transport and Processing'  else  book.entity_name end Group3, 
	rg.generator_id, 
	rg.code, 
	rg.[name], 
	ei.frequency, 
	ei.curve_id, 
	spcd.curve_name, 
	spcd.curve_des,
	case when (@convert_uom_id is null) then spcd.curve_des else
		COALESCE(conv1.curve_label,conv2.curve_label,conv3.curve_label,spcd.curve_des) 
	end co2_curve_desc,
	(ei.volume-case when (ei.fas_book_id < 0) then 0 else isnull(fug.volume,0) end)*ISNULL(1-ISNULL(ownership.ownership_per,0),1) original_volume,
	(case when stra.entity_id =@ownCO2Sinks then reduction_volume*-1 else ei.volume-case when (ei.fas_book_id < 0) then 0 else isnull(fug.volume,0) end end * Conv0.conversion_factor)*ISNULL(1-ISNULL(ownership.ownership_per,0),1) volume, 
	su.source_uom_id, 
	spcd.uom_id to_uom_id,
	Conv0.conversion_factor conversion_factor,
	COALESCE(conv1.conversion_factor,conv2.conversion_factor,conv3.conversion_factor) co2_conversion_factor,
	su.uom_name uom_name,	
	case when (@convert_uom_id is null) then su.uom_name else
		COALESCE(conv1.uom_label,conv2.uom_label,conv3.uom_label)	
	end co2_uom_name, 
	ei.calculated, 
	esmd.rating_value_id, 
	rating.xref_value as rating_weight,
	abs(case when stra.entity_id in(@ownCO2Sinks) or sub.entity_id in(@carbon_flux_id)then ei.reduction_volume else ei.volume-case when (ei.fas_book_id < 0) then 0 else isnull(fug.volume,0) end end * ISNULL(1-ISNULL(ownership.ownership_per,0),1) * Conv0.conversion_factor * rating.xref_value) rating_value,
	year(ei.term_start) reporting_year,
	spcd.sort_order gas_sort_order,
	em.description estimation_method,
	case    when stra.entity_id =@ownCO2Sinks then 'A1'	
		when (sub.entity_id = @direct_emissions_id) then 'A' + cast(isnull(spcd.sort_order, 0) as varchar) 
		when (sub.entity_id = @indirect_emissions_id and ei.curve_id = @co2_gas_id) then 'B'
		when (sub.entity_id = @indirect_emissions_id and ei.curve_id = @ch4_gas_id) then 'C'
		when (sub.entity_id = @indirect_emissions_id and ei.curve_id = @n20_gas_id) then 'D'
		when (sub.entity_id = @carbon_flux_id ) then 'E'
		when (sub.entity_id = @other_indirect_emissions_id  ) then 'F' + cast(isnull(spcd.sort_order, 0) as varchar) 
		when (sub.entity_id = @captured_co2_id) then 'G'
	else 'Unknow Item' end Item,
	rg.fuel_value_id,
	case when stra.entity_id =@ownCO2Sinks then 'Direct Emissions' else sub.entity_name end sub,
	captured_co2_emission,
	onsite_offsite,
	technology.code as technology,
	classification.code as classification,
	first_gen_date,
	ei.term_start,
	ei.term_end,
	ecdv.output_id,
	ecdv.output_value,
	ecdv.output_uom_id,
	ecdv.heatcontent_value,
	ecdv.heatcontent_uom_id,
	ei.current_forecast,
	case when fe.formula_type='n' then 'Nested Formula' else  dbo.FNAFormulaFormat(fe.formula,'r') end as formula_str,
	case when fe.formula_type='n' then '' else ecdv.formula_eval end as formula_eval,
	(ei.reduction_volume* Conv0.conversion_factor)*ISNULL(1-ISNULL(ownership.ownership_per,0),1) as reduction_volume,
	--ei.reduction_volume,
	su.uom_name as reduction_uom_name,
	NULL as source_deal_header_id,
	NULL as source_deal_detail_id,
	NULL as counterparty_id,
	NULL  as counterparty_name,
	NULL as source_deal_type_id,
	NULL as source_deal_type_name,
	NULL as deal_sub_type_type_id,
	NULL  as deal_sub_type_name ,
	NULL  as buy_sell_flag,
	0 as ext_deal,
	rg.de_minimis_source as de_minimis_source,
	rg.co2_captured_for_generator_id,
	ei.forecast_type,
	st_forecast.code,
	ei.fuel_type_value_id,
	esmd.ems_source_model_id,
	case when esf.default_inventory='y' then -1 else NULL end

FROM    
source_sink_type sst (NOLOCK) inner join 
ems_portfolio_hierarchy book (NOLOCK)              
ON
sst.source_sink_type_id=book.entity_id
INNER JOIN            
 ems_portfolio_hierarchy stra (NOLOCK)             
 ON            
  book.parent_entity_id = stra.entity_id             
INNER JOIN            
 ems_portfolio_hierarchy sub             
 ON            
  stra.parent_entity_id = sub.entity_id             
--LEFT OUTER JOIN
-- INNER JOIN
--   ems_technology_map etm on etm.ems_book_id = book.entity_id
INNER JOIN
  rec_generator rg on sst.generator_id = rg.generator_id

INNER JOIN #ssbm ON #ssbm.fas_book_id = rg.fas_book_id
INNER JOIN fas_strategy	fs ON fs.fas_strategy_id = #ssbm.stra_book_id
INNER JOIN #emissions_inventory ei on ei.generator_id = rg.generator_id
--INNER JOIN(select max(as_of_date) as_of_date,generator_id,curve_id,term_start,forecast_type from emissions_inventory
--			where year(term_start)<=ISNULL(year(term_start),@reporting_year)
--			group by term_start,generator_id,curve_id,forecast_type) x on
--INNER JOIN #temp_f1 x on
--ei.generator_id=x.generator_id and 	ei.as_of_date=x.as_of_date 
--and ei.curve_id=x.curve_id and ei.term_start=x.term_start and ISNULL(ei.forecast_type,'')=ISNULL(x.forecast_type,'')
--and ei.fuel_type_value_id=x.fuel_type_value_id
INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id = ei.curve_id
INNER JOIN source_uom su on su.source_uom_id = spcd.uom_id
--INNER JOIN ems_source_model esm on esm.ems_source_model_id = etm.ems_source_model_id
INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
INNER JOIN (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
				ems_source_model_effective where 1=1 group by generator_id) ab
on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date

INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id = esme.ems_source_model_id and
		esmd.curve_id = ei.curve_id
INNER JOIN static_data_value rating on rating.value_id = esmd.rating_value_id
INNER JOIN static_data_value em on em.value_id = esmd.estimation_type_value_id
INNER JOIN static_data_value technology on technology.value_id=rg.technology
LEFT JOIN ems_calc_detail_value ecdv on ecdv.generator_id=ei.generator_id and
	ecdv.term_start=ei.term_start and ecdv.term_end=ei.term_end and ecdv.curve_id=ei.curve_id 
	and ei.forecast_type=ecdv.forecast_type
	and ei.as_of_date=ecdv.as_of_date and ecdv.fuel_type_value_id=ei.fuel_type_value_id

LEFT JOIN static_data_value classification on classification.value_id=rg.classification_value_id
LEFT JOIN ems_source_formula esf on esf.ems_source_model_id=esme.ems_source_model_id and
		esf.curve_id = ei.curve_id and esf.forecast_type=ei.forecast_type
--LEFT JOIN #temp_fug fug
LEFT JOIN(SELECT     generator_id, term_start, SUM(volume)AS volume
FROM  #emissions_inventory
WHERE     
(fas_book_id < 0)
GROUP BY generator_id, term_start) fug
on fug.generator_id=rg.generator_id and ei.term_start=fug.term_start
LEFT JOIN rec_volume_unit_conversion Conv1 ON            
 conv1.from_source_uom_id  = spcd.uom_id
 AND conv1.to_source_uom_id = @convert_uom_id
 And conv1.state_value_id = rg.gen_state_value_id
 AND conv1.assignment_type_value_id is null
 AND conv1.curve_id = ei.curve_id 

LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
 conv2.from_source_uom_id = spcd.uom_id
 AND conv2.to_source_uom_id = @convert_uom_id
 And conv2.state_value_id IS NULL
 AND conv2.assignment_type_value_id IS NULL
 AND conv2.curve_id = ei.curve_id 
       
LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
 conv3.from_source_uom_id = spcd.uom_id
 AND conv3.to_source_uom_id = @convert_uom_id
 And conv3.state_value_id IS NULL
 AND conv3.assignment_type_value_id IS NULL
 AND conv3.curve_id IS NULL

LEFT OUTER JOIN rec_volume_unit_conversion Conv0 ON            
 Conv0.from_source_uom_id = ISNULL(ei.uom_id,ei.reduction_uom_id)
 AND Conv0.to_source_uom_id = spcd.uom_id
 And Conv0.state_value_id IS NULL
 AND Conv0.assignment_type_value_id IS NULL
 AND Conv0.curve_id IS NULL

LEFT JOIN formula_editor fe on fe.formula_id=ecdv.formula_id
--Equity Share
LEFT JOIN (select generator_id,sum(per_ownership) ownership_per from generator_ownership group by generator_id) ownership
	on rg.generator_id=ownership.generator_id
LEFT JOIN static_data_value st_forecast on st_forecast.value_id=ei.forecast_type

where 	1=1


and book.emission_group_id=@reporting_group_id
AND
	(( 
	(@reporting_year is not null and @report_type <> 'b' and year(ei.term_start) =@reporting_year) OR
	  (@reporting_year is null and @report_type <> 'b') OR
	  (year(ei.term_start)=111111111)) OR		 			
      	
	((year(ei.term_start) between @base_yr_from and @base_yr_to and @report_type<>'r') OR
	  (year(ei.term_start) = @reporting_year and @report_type='r' and @reporting_year is not null) OR
	  (@report_type='r' and @reporting_year is null))

	)

 	 AND
 	 ( ( (ei.term_start between @prod_month_from and  @prod_month_to and @prod_month_from is not null) 
		OR(@prod_month_from is null and ei.term_start=ei.term_start) OR(year(ei.term_start) between @base_yr_from and @base_yr_to)
		) OR 
		 ((ei.term_end between @prod_month_from and  @prod_month_to and @prod_month_from is not null)
		OR	(@prod_month_from is null and ei.term_end=ei.term_end) OR(year(ei.term_start) between @base_yr_from and @base_yr_to)
	) )
	AND

	((ei.current_forecast =@forecast and @forecast is not null) or @forecast is null)
	and esmd.program_scope_value_id in(select program_scope from #tmp_program_scope)
	

--order by   sub.entity_name, stra.entity_name, book.entity_name	

--UNION
--EXEC spa_print '2 Inserted in First Temp Table :'+convert(varchar(100),getdate(),113)


-- -------######### Bring Deals CO2Eq
/* -- COMMENTE FOr Temporary
insert into #temp_inventory
	(
	as_of_date,
	Group1_ID,
	Group2_ID,
	Group3_ID,
	Group1,
	Group2,
	Group3,
	generator_id,
	code,
	[name],
	frequency,
	curve_id,
	curve_name,
	curve_des,
	co2_curve_desc,
	original_volume,
	volume,
	uom_id,
	to_uom_id,
	conversion_factor,
	co2_conversion_factor,
	uom_name,
	co2_uom_name,
	calculated,
	rating_value_id,
	rating_weight,
	rating_value,
	reporting_year,
	gas_sort_order,
	estimation_method,
	Item,
	fuel_value_id,
	sub,
	captured_co2_emission,
	onsite_offsite,
	technology,
	classification,
	first_gen_date,
	term_start,
	term_end,
	output_id,
	output_value,
	output_uom_id,
	heatcontent_value,
	heatcontent_uom_id,
	current_forecast,
	formula_str,
	formula_eval,
	reduction_volume,
	reduction_uom_name,
	source_deal_header_id,
	source_deal_detail_id,
	counterparty_id,
	counterparty_name,
	source_deal_type_id,
	source_deal_type_name,
	deal_sub_type_type_id,
	deal_sub_type_name,
	buy_sell_flag,
	ext_deal,
	de_minimis_source,
	co2_captured_for_generator_id,
	forecast_type,
	forecast_type_value,
	fuel_type_value_id,
	source_model_id
)
select  
	sdh.deal_date,
	sub.entity_id Group1_ID,
	stra.entity_id Group2_ID,
	book.entity_id Group3_ID,
	case 	
		when (sub.entity_id = @direct_emissions_id) then @tab_space + spcd.curve_des
		when (sub.entity_id = @indirect_emissions_id) then 'Indirect Emissions from Purchased Energy'
		when (sub.entity_id = @carbon_flux_id ) then sub.entity_name
		when (sub.entity_id = @other_indirect_emissions_id  ) then @tab_space + spcd.curve_des
		when (sub.entity_id = @captured_co2_id) then sub.entity_name + ' for Sequestration in a Gelogic Reservoir'
	else 'Unknow Item' end Group1,
	stra.entity_name Group2, 
	book.entity_name Group3, 
	rg.generator_id, 
	rg.code, 
	rg.[name], 
	--sdh.deal_volume_frequency, 
	@monthly_frequency as frequency,
	sdh.curve_id, 
	spcd.curve_name, 
	spcd.curve_des,
	case when (@convert_uom_id is null) then spcd.curve_des else
		COALESCE(conv1.curve_label,conv2.curve_label,conv3.curve_label,spcd.curve_des) 
	end co2_curve_desc,
	sdh.deal_volume original_volume,
	NULL volume, 
	sdh.deal_volume_uom_id as uom_id, 
	spcd.uom_id to_uom_id,
	Conv0.conversion_factor conversion_factor,
	COALESCE(conv1.conversion_factor,conv2.conversion_factor,conv3.conversion_factor) co2_conversion_factor,
	su.uom_name uom_name,	
	case when (@convert_uom_id is null) then su.uom_name else
		COALESCE(conv1.uom_label,conv2.uom_label,conv3.uom_label)	
	end co2_uom_name, 
	'n' as calculated, 
	esmd.rating_value_id, 
	rating.xref_value as rating_weight,
	sdh.deal_volume * Conv0.conversion_factor * rating.xref_value rating_value,
	year(sdh.term_start) reporting_year,
	spcd.sort_order gas_sort_order,
	em.description estimation_method,
	case 	when (sub.entity_id = @direct_emissions_id ) then 'A' + cast(isnull(spcd.sort_order, 0) as varchar) 
		when (sub.entity_id = @indirect_emissions_id and sdh.curve_id = @co2_gas_id) then 'B'
		when (sub.entity_id = @indirect_emissions_id and sdh.curve_id = @ch4_gas_id) then 'C'
		when (sub.entity_id = @indirect_emissions_id and sdh.curve_id = @n20_gas_id) then 'D'
		when (sub.entity_id = @carbon_flux_id ) then 'E'
		when (sub.entity_id = @other_indirect_emissions_id  ) then 'F' + cast(isnull(spcd.sort_order, 0) as varchar) 
		when (sub.entity_id = @captured_co2_id) then 'G'
	else 'Unknow Item' end Item,
	rg.fuel_value_id,
	sub.entity_name sub,
	rg.captured_co2_emission,
	rg.onsite_offsite,
	technology.code as technology,
	classification.code as classification,
	rg.first_gen_date,
	sdh.term_start,
	sdh.term_end,
	NULL as output_id,
	NULL as output_value,
	NULL as output_uom_id,
	NULL as heatcontent_value,
	NULL as heatcontent_uom_id,
	'r' as current_forecast,
	NULL as formula_str,
	NULL as formula_eval,
	(case when buy_sell_flag='b' then 1 when buy_sell_flag='s' then -1 end) *sdh.deal_volume* Conv0.conversion_factor as reduction_volume,
	su.uom_name as reduction_uom_name,
	sdh.source_deal_header_id,
	sdh.source_deal_detail_id,
	sdh.counterparty_id,
	sc.counterparty_name,
	sdh.source_deal_type_id,
	sdt.source_deal_type_name,
	sdh.deal_sub_type_type_id,
	sdt1.source_deal_type_name as deal_sub_type_name,
	sdh.buy_sell_flag,
	0 as ext_deal,
	rg.de_minimis_source as de_minimis_source,
	rg.co2_captured_for_generator_id,
	-1 as forecast_type	,
	NULL as forecast_type_value,
	NULL as fuel_type_value_id,
	esmd.ems_source_model_id
from(		
select 
	 max(sdh.source_deal_header_id) source_deal_header_id,      
	 max(sdd.source_deal_detail_id) source_deal_detail_id,      
	 max(sdd.buy_sell_flag) buy_sell_flag,             
	 max(sdh.counterparty_id) counterparty_id,            
	 max(sdh.source_deal_type_id) source_deal_type_id,
	 max(sdh.deal_sub_type_type_id) deal_sub_type_type_id,            
	 max(sdh.deal_date) deal_date,             
	 max(sdh.generator_id) generator_id,
	 sdd.curve_id,
	 sum(sdd.deal_volume) as deal_volume,
	 max(sdd.deal_volume_uom_id) as deal_volume_uom_id,            
	 max(sdh.source_system_book_id1) source_system_book_id1,            
	 max(sdd.deal_volume_frequency) as deal_volume_frequency,
	 sdd.term_start,
	 max(sdd.term_end) term_end       

from                
	 source_deal_header sdh inner join source_deal_detail sdd 
	on sdd.source_deal_header_id = sdh.source_deal_header_id             
WHERE 
	1=1 and deal_id  not like '%emission%'
	and sdh.source_deal_type_id=@CO2Eq_deal_type_id AND
 
	year(term_start)=@reporting_year
	--sdh.deal_date<=@as_of_date

group by 
	sdd.curve_id, sdd.term_start,sdh.generator_id 

) sdh
INNER JOIN rec_generator rg (nolock)
	on rg.generator_id=sdh.generator_id
INNER JOIN #ssbm (nolock)
	ON #ssbm.fas_book_id = rg.fas_book_id
INNER JOIN fas_strategy	fs (nolock)
	ON fs.fas_strategy_id = #ssbm.stra_book_id
INNER JOIN ems_portfolio_hierarchy book (nolock)             
	ON book.entity_id=rg.ems_book_id
INNER JOIN ems_portfolio_hierarchy stra (nolock)            
	ON book.parent_entity_id = stra.entity_id             
INNER JOIN ems_portfolio_hierarchy sub (nolock)            
	ON stra.parent_entity_id = sub.entity_id             
LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdh.curve_id
LEFT JOIN source_uom su on su.source_uom_id = spcd.uom_id
INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
INNER JOIN (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
				ems_source_model_effective where 1=1 group by generator_id) ab
on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id = esme.ems_source_model_id and
esmd.curve_id = sdh.curve_id
LEFT JOIN static_data_value rating on rating.value_id = esmd.rating_value_id
LEFT JOIN static_data_value em on em.value_id = esmd.estimation_type_value_id
LEFT JOIN static_data_value technology on technology.value_id=rg.technology
LEFT JOIN static_data_value classification on classification.value_id=rg.classification_value_id

LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
 conv1.from_source_uom_id  = spcd.uom_id
 AND conv1.to_source_uom_id = @convert_uom_id
 And conv1.state_value_id = rg.gen_state_value_id
 AND conv1.assignment_type_value_id is null
 AND conv1.curve_id = sdh.curve_id 

LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
 conv2.from_source_uom_id = spcd.uom_id
 AND conv2.to_source_uom_id = @convert_uom_id
 And conv2.state_value_id IS NULL
 AND conv2.assignment_type_value_id IS NULL
 AND conv2.curve_id = sdh.curve_id 
       
LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
 conv3.from_source_uom_id = spcd.uom_id
 AND conv3.to_source_uom_id = @convert_uom_id
 And conv3.state_value_id IS NULL
 AND conv3.assignment_type_value_id IS NULL
 AND conv3.curve_id IS NULL

LEFT OUTER JOIN rec_volume_unit_conversion Conv0 ON            
     Conv0.from_source_uom_id = sdh.deal_volume_uom_id
 AND Conv0.to_source_uom_id = spcd.uom_id
 And Conv0.state_value_id IS NULL
 AND Conv0.assignment_type_value_id IS NULL
 AND Conv0.curve_id IS NULL

--LEFT JOIN formula_editor fe on fe.formula_id=ecdv.formula_id

LEFT JOIN source_counterparty sc 
	ON sc.source_counterparty_id=sdh.counterparty_id
LEFT join source_deal_type sdt 
	ON sdt.source_deal_type_id=sdh.source_deal_type_id
LEFT join source_deal_type sdt1 
	ON sdt.source_deal_type_id=sdh.deal_sub_type_type_id

where 
	1=1 
	 and sc.int_ext_flag='e'
	--and esmd.program_scope_value_id=@program_scope
-- 
-- ) a
-- 
*/
END
/*
EXEC spa_print '3 Inserted in Second Temp Table :'+convert(varchar(100),getdate(),113)

if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
	exec('insert into #temp_inventory select *,NULL,NULL,-1,NULL,NULL,NULL,NULL from '+@table_RECS+' where co2_conversion_factor is not null')

EXEC spa_print '4 :'+convert(varchar(100),getdate(),113)

*/

--select * from #temp_deals
--#########################-----------------------------------------------------
--declare @sql_where varchar(5000)


if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
set @sql_where=' case when Group1_ID='+cast(@carbon_flux_id as varchar)+' then sum(reduction_volume)
		 when Group2_ID='+cast(@OwnCO2Sinks as varchar)+' then sum(reduction_volume)*-1
		 else sum(volume) end else 0 end '

set @sql_stmt='
	select 	distinct
		--max(conv1.conversion_factor),
		Group1_ID,
		Group2_ID,
		Group3_ID,
		Group1, 
		Group2, 
		Group3, 
		curve_des Source1, 
		case when max(ext_deal)=1 then max(CO2_curve_desc) else curve_name end as Gas, 
		case when max(ext_deal)=1 then max(CO2_uom_name) else ISNULL(su2.uom_name,t.uom_name) end Units,
		as_of_date,
		term_start,
		term_end,
		t.curve_id,
		Item,
		estimation_method,
		case when (reporting_year ='+cast(isnull(@base_yr1, -1) as varchar)+') then '+@sql_where+'*ISNULL(max(conv1.conversion_factor),1) Yr1Vol,
		case when (reporting_year ='+cast(isnull(@base_yr2, -1) as varchar)+') then '+@sql_where+'*ISNULL(max(conv1.conversion_factor),1) Yr2Vol,
		case when (reporting_year ='+cast(isnull(@base_yr3, -1) as varchar)+') then '+@sql_where+'*ISNULL(max(conv1.conversion_factor),1) Yr3Vol,
		case when (reporting_year ='+cast(isnull(@base_yr4, -1) as varchar)+') then '+@sql_where+'*ISNULL(max(conv1.conversion_factor),1) Yr4Vol,
	
		case when (reporting_year ='+cast(isnull(@base_yr1, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr2, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr3, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr4, -1) as varchar)+') then '+@sql_where+'*ISNULL(max(conv1.conversion_factor),1) SumBaseYearsVol,
		case when ext_deal=1 then sum(reduction_volume) else
		case when (reporting_year = '+case when @reporting_year is null then  'year(term_start)' else cast(@reporting_year as varchar) end+') then '+@sql_where+' end*ISNULL(max(conv1.conversion_factor),1) as ReportingYearVol,
		abs(case when (reporting_year = '+case when @reporting_year is null then  'year(term_start)' else cast(@reporting_year as varchar) end+') then sum(rating_value) else 0 end) as  RatingValue,
		case when (reporting_year = '+case when @reporting_year is null then  'year(term_start)' else cast(@reporting_year-1 as varchar) end+') then '+@sql_where+'*ISNULL(max(conv1.conversion_factor),1) as Prior_ReportingYearVol,
		'''+@conv_to_gas+''' as co2_curve_desc,
		max(co2_conversion_factor)co2_conversion_factor,
		max(co2_uom_name) co2_uom_name, 		
		max(t.fuel_value_id) fuel_value_id,
		t.rating_value_id,
		t.rating_weight,
		t.sub,
		t.captured_co2_emission,
		t.onsite_offsite,
		t.generator_id,
		t.technology,
		t.classification,
		year(t.first_gen_date) as first_gen_date,
		t.output_id,
		sum(t.output_value) as output_value,
		t.output_uom_id,
		sum(heatcontent_value) as heatcontent_value,
		heatcontent_uom_id as heatcontent_uom_id,
		case when year(term_start) between '+cast(@base_yr_from as varchar)+' and '+cast(@base_yr_to as varchar)+' then 1 else 0 end as base_year,
		current_forecast,
		max(formula_str) as formula_str, 	
		max(formula_eval) as formula_eval,
		case when ext_deal=1 then 0 else sum(reduction_volume) end*ISNULL(max(conv1.conversion_factor),1) as reduction_volume,
		max(frequency) frequency,
		source_deal_header_id source_deal_header_id,
		max(source_deal_detail_id) source_deal_detail_id,
		max(counterparty_id) counterparty_id,
		max(counterparty_name) counterparty_name,
		max(source_deal_type_id) source_deal_type_id,
		max(source_deal_type_name) source_deal_type_name,
		max(deal_sub_type_type_id) deal_sub_type_type_id,
		max(deal_sub_type_name) deal_sub_type_name,
		max(buy_sell_flag) buy_sell_flag,
		ext_deal as ext_deal,
		case when (reporting_year ='+cast(isnull(@base_yr1, -1) as varchar)+') then sum(output_value) else 0 end*ISNULL(max(conv1.conversion_factor),1) Yr1Vol_Output,
		case when (reporting_year ='+cast(isnull(@base_yr2, -1) as varchar)+') then sum(output_value) else 0 end*ISNULL(max(conv1.conversion_factor),1) Yr2Vol_Output,
		case when (reporting_year ='+cast(isnull(@base_yr3, -1) as varchar)+') then sum(output_value) else 0 end*ISNULL(max(conv1.conversion_factor),1) Yr3Vol_Output,
		case when (reporting_year ='+cast(isnull(@base_yr4, -1) as varchar)+') then sum(output_value) else 0 end*ISNULL(max(conv1.conversion_factor),1) Yr4Vol_Output,

		case when (reporting_year ='+cast(isnull(@base_yr1, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr2, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr3, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr4, -1) as varchar)+') then sum(output_value) else 0 end*ISNULL(max(conv1.conversion_factor),1) SumBaseYearsVol_Output,
		case when (reporting_year = '+case when @reporting_year is null then  'year(term_start)' else cast(@reporting_year as varchar) end+') then sum(output_value) else 0 end*ISNULL(max(conv1.conversion_factor),1) ReportingYearVol_Output, 	 		 	
		case when (reporting_year = '+case when @reporting_year is null then  'year(term_start)' else cast(@reporting_year as varchar) end+') then sum(original_volume) else 0 end*ISNULL(max(conv1.conversion_factor),1) original_volume, 	 		 	
		case when (reporting_year ='+cast(isnull(@base_yr1, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr2, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr3, -1) as varchar)+' OR
			   reporting_year ='+cast(isnull(@base_yr4, -1) as varchar)+') then sum(original_volume) else 0 end*ISNULL(max(conv1.conversion_factor),1) SumBaseYearsVol_original,
		'+case when @uom_id is not null then cast(@uom_id as varchar) else ' max(t.uom_id)' end +'  uom_id,
		'+cast(@convert_uom_id as varchar)+' as CO2_uom_id,'+cast(@base_yr_count as varchar)+' as base_year_count,max(calculated) calculated,
		max(t.de_minimis_source) as de_minimis_source,
		max(t.co2_captured_for_generator_id) as co2_captured_for_generator_id,
		forecast_type,
		forecast_type_value,
		source_model_id	,
		default_inventory	
	into '+@table_name+'
	'
	set @sql_stmt1=' from #temp_inventory t left join rec_generator rg on t.generator_id=rg.generator_id 
	LEFT JOIN rec_volume_unit_conversion Conv1 ON            
	 conv1.from_source_uom_id  = t.uom_id
	 AND conv1.to_source_uom_id = '+case when @uom_id is not null then cast(@uom_id as varchar) else '-1' end +'
	 And conv1.state_value_id is null
	 AND conv1.assignment_type_value_id is null
	 AND conv1.curve_id is null
	 left join source_uom su2 on su2.source_uom_id='+case when @uom_id is not null then cast(@uom_id as varchar) else '-1' end+
	' left join user_defined_group_detail udfg on udfg.rec_generator_id=rg.generator_id '+
	' where 1=1 '
	+case when @curve_id is not null then ' And t.curve_id='+cast(@curve_id as varchar) else '' end
	+case when @generator_id is not null then ' And t.generator_id='+cast(@generator_id as varchar) else '' end
	+case when @generator_group_id is not null and @generator_group_id<>'null' then ' and isnull(rg.generator_group_name, '''') = ''' + @generator_group_id + '''' else '' end
	+case when @source_sink_type  is not null then 
			' and (isnull( t.Group1_ID, 1) = ' + CAST(@source_sink_type as varchar) +' OR isnull( t.Group2_ID, 1) = ' + CAST(@source_sink_type as varchar) +
			' OR isnull( t.Group3_ID, 1) = ' + CAST(@source_sink_type as varchar)+')' 	 else '' end
	+CASE WHEN @reduction_type IS NOT NULL THEN 	' and isnull(rg.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
	+CASE WHEN @reduction_sub_type IS NOT NULL THEN ' and isnull(rg.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
	+CASE WHEN @technology_type IS NOT NULL THEN ' and isnull(rg.technology, 1) = ' + cast(@technology_type as varchar)	ELSE '' END +
	+CASE WHEN @technology_sub_type IS NOT NULL THEN ' and isnull(rg.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
	+CASE WHEN @primary_fuel IS NOT NULL THEN ' and isnull(rg.fuel_value_id, 1) = ' + cast(@primary_fuel as varchar)	ELSE '' END +
	+CASE WHEN @fuel_type IS NOT NULL THEN ' and isnull(t.fuel_type_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
	+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
	+CASE WHEN @udf_group1 IS NOT NULL THEN ' and isnull(rg.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
	+CASE WHEN @udf_group2 IS NOT NULL THEN ' and isnull(rg.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
	+CASE WHEN @udf_group3 IS NOT NULL THEN ' and isnull(rg.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END +
	+CASE WHEN @include_hypothetical IS NOT NULL THEN ' and isnull(rg.is_hypothetical,''n'') = ''' +@include_hypothetical+'''' ELSE '' END +

	
	' group by Group1, curve_des, curve_name, ISNULL(su2.uom_name,t.uom_name), reporting_year, as_of_date,
	Group1_ID,Group2_ID, Group3_ID, Group1, Group2, Group3, t.curve_id, Item, estimation_method,rating_value_id,rating_weight,
	sub,t.captured_co2_emission,t.onsite_offsite,t.generator_id,t.technology,t.classification,year(t.first_gen_date),
	t.output_id,t.output_uom_id,t.heatcontent_uom_id,
	t.term_start,term_end,t.current_forecast,ext_deal,t.source_deal_header_id,t.forecast_type ,t.forecast_type_value,source_model_id,default_inventory		 	
	
'
--PRINT @sql_stmt+@sql_stmt1

if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
	exec(@sql_stmt+@sql_stmt1) 

END




--EXEC spa_print '4 :'+convert(varchar(100),getdate(),113)

if isnull(@use_process_id, 'RERUN') IN ('NEW')
begin
	select @new_process_id as use_process_id
	return
end

--######### DRILL DOWN

if @drill_down_level=1 and @report_section<>'I.3.A.1' and @report_section<>'I.3.B.1'
BEGIN
set @sql_stmt='	select 	
		dbo.FNAEmissionHyperlink(3,12101500,rg.name+case when ext_deal=1 then '' (REC)'' else '''' end,rg.generator_id,''''''e'''''') as [Generator],
		Group1 Source, 
		Gas, 
		Units,'+
		case when @report_section in('i.2.a.1','i.2.b.2.b') then 
		' round(sum(case when Group1_ID='+cast(@carbon_flux_id as varchar)+' then -1	
			else 1 end * '+ 
		case    
			when @report_year_level=1 then ' Yr1Vol ' when @report_year_level=2 then ' Yr2Vol ' 
			when @report_year_level=3 then ' Yr3Vol ' when @report_year_level=4 then ' Yr4Vol ' 
			when @report_year_level=5 then ' SumBaseYearsVol/'+cast(isnull(@base_yr_count,1) as varchar)
			when @report_year_level=6 then ' ReportingYearVol ' end+' ),0) as Inventory, '
		else
		' round(sum(case when ext_deal=1 then 0  
			when Group1_ID='+cast(@carbon_flux_id as varchar)+' then 0	
			else '+ 
		case    
			when @report_year_level=1 then ' Yr1Vol ' when @report_year_level=2 then ' Yr2Vol ' 
			when @report_year_level=3 then ' Yr3Vol ' when @report_year_level=4 then ' Yr4Vol ' 
			when @report_year_level=5 then ' SumBaseYearsVol/'+cast(isnull(@base_yr_count,1) as varchar)
			when @report_year_level=6 then ' ReportingYearVol ' end+' end),0) as Inventory, '
		end+		
	    case when @report_section in('i.2.a.1','i.2.b.2.b') then 'NULL' else '
		        round(sum(case when ext_deal=1 THEN ReportingYearVol else reduction_volume end),0)' end+' as [Reduction] 
	    
	 from '+@table_name+' a left join rec_generator rg on rg.generator_id=a.generator_id
	where 1=1 '
	+case when @deminimis = 'n' then ' and  isnull(rg.de_minimis_source,''n'')=''n''' else '' end +	
	+case when @source is not null then ' And sub='''+@source+'''' else '' end +	
	+case when @group1 is not null then ' And group1='''+@group1+'''' else '' end +	
	+case when @group2 is not null then ' And group2='''+@group2+'''' else '' end +	
	+case when @group3 is not null then ' And group3='''+@group3+'''' else '' end +	
	+case when @gas is not null then ' And gas='''+@gas+'''' else '' end +	
	+ case when @report_section='I.2.B.2.b' then ' and ext_deal=1 ' else '' end+
	+ case when @report_section='I.2.B.2.c' then ' and ext_deal<>1 ' else '' end+
	' 
	group by rg.name,sub,gas,units,group1,ext_deal,rg.generator_id
'
--PRINT @sql_stmt
exec(@sql_stmt)
RETURN
END
else If @drill_down_level=2
BEGIN

create table #temp_rec(source_deal_header_id int,generator_id int,term_start datetime,term_end datetime,source varchar(100) COLLATE DATABASE_DEFAULT,gas varchar(100) COLLATE DATABASE_DEFAULT, 
		     generator_name varchar(100) COLLATE DATABASE_DEFAULT,source_deal_type_name varchar(100) COLLATE DATABASE_DEFAULT,quantity float,uom_name varchar(100) COLLATE DATABASE_DEFAULT)

set @sql='insert into #temp_rec select source_deal_header_id,rg.generator_id,term_start,term_end,source1,gas,rg.[name],source_deal_type_name,
	ReportingYearVol,units from '+@table_name+' a
	inner join rec_generator rg on rg.generator_id=a.generator_id where ext_deal=1  '+
	case when @source is not null then ' and sub='''+@source+'''' else '' end+
	+' and gas='''+@gas+''' and year(term_start)='''+cast(@reporting_year as varchar)+''' and rg.[name] = '''+replace(@generator,'(REC)','')+''''

--print @sql
exec(@sql)


if exists(select * from #temp_rec)
set @sql_stmt='	select 	
		dbo.FNAEmissionHyperlink(2,10131010,cast(source_deal_header_id as varchar),source_deal_header_id,NULL) [Deal ID],
		generator_name [Generator],
		source_deal_type_name as [Deal Type],
		dbo.FNAGetContractMonth(term_start) [Term Start],
		dbo.FNAGetContractMonth(term_end) [Term End],
		gas as [Env Product],
		quantity as [Volume],
		uom_name as [Unit of Measures]
from #temp_rec
'	

else	
set @sql_stmt='	select 	
		case when ext_deal=1 then  cast(source_deal_header_id as varchar) else rg.name end as Generator,
		Group3 Source, 
		dbo.FNADateformat(as_of_date) [As of Date],
		dbo.FNADateformat(term_start) [Term Start],
		dbo.FNADateformat(term_end) [Term End],	
		ISNULL(forecast_type_value,''Actual'') [Type],
		Gas, 
		Units,sum('+ 
		case when @emissions_reductions='r' then ' reduction_volume '
		     when @report_year_level=1 then ' Yr1Vol ' when @report_year_level=2 then ' Yr2Vol ' 
		     when @report_year_level=3 then ' Yr3Vol ' when @report_year_level=4 then ' Yr4Vol ' 
		     when @report_year_level=5 then ' SumBaseYearsVol/'+cast(isnull(@base_yr_count,1) as varchar)
		     when @report_year_level=6 then ' ReportingYearVol ' end+') as Value
		--case when max(formula_str) =''Nested Formula'' then ''Nested Formula'' else max(formula_str)+''<br><em>''+max(formula_eval)+''</em>'' end as [Formula]
	 from '+@table_name+' a left join rec_generator rg on rg.generator_id=a.generator_id
	where 1=1 '+
	case when @deminimis = 'n' then ' and  isnull(rg.de_minimis_source,''n'')=''n''' else '' end +	
	case when @source is not null then ' And sub='''+@source+'''' else '' end +	
	case when @report_year_level=1 then ' And year(term_start)='+cast(@base_yr1 as varchar)
	     when @report_year_level=2 then ' And year(term_start)='+cast(@base_yr2 as varchar)
	     when @report_year_level=3 then ' And year(term_start)='+cast(@base_yr3 as varchar)
	     when @report_year_level=4 then ' And year(term_start)='+cast(@base_yr4 as varchar)
	     when @report_year_level=5 then ' And (year(term_start)=ISNULL('+cast(@base_yr1 as varchar)+',-1)
		  			      OR year(term_start)='+ case when @base_yr2 is null then '-1' else cast(@base_yr2 as varchar) end+'
					      OR year(term_start)='+ case when @base_yr3 is null then '-1' else cast(@base_yr3 as varchar) end+'
					      OR year(term_start)='+ case when @base_yr4 is null then '-1' else cast(@base_yr4 as varchar) end+')'
	     when @report_year_level=6 then ' And year(term_start)='+cast(@reporting_year as varchar) else '' end+
	+case when @generator is not null then ' And rg.name='''+@generator+'''' else '' end +				
	+case when @group1 is not null then ' And group1='''+@group1+'''' else '' end +	
	+case when @group2 is not null then ' And group2='''+@group2+'''' else '' end +	
	+case when @group3 is not null then ' And group3='''+@group3+'''' else '' end +	
	+case when @gas is not null then ' And gas='''+@gas+'''' else '' end +	
	' 
	group by rg.name,group3,gas,units ,term_start,term_end,ext_deal,source_deal_header_id,as_of_date,ISNULL(forecast_type_value,''Actual'')
	order by rg.name,group3,gas,units ,ISNULL(forecast_type_value,''Actual''),term_start
'

--print @base_yr4
--print @sql_stmt
exec(@sql_stmt)

return
END
--------######################################


--Schedule I.Section2.PART A.1 AGGREGATED EMISSIONS BY GAS 
If @report_section = 'I.2.A.1'

BEGIN

if @form_type='r'

set @sql_stmt='	select 	Item,
		sub [Group], 
		Group1 Source, 	
		Gas, 
		Units, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr1Vol),0) Yr1, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr2Vol),0) Yr2, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr3Vol),0) Yr3, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr4Vol),0) Yr4, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(ReportingYearVol),0) [Reporting Year Emissions or Carbon Flux],
		round(sum(ISNULL(RatingValue,0))/sum(abs(case when ReportingYearVol = 0 then null else ReportingYearVol end)),2) [Weighted Rating]
	from '+@table_name+' a 
	where isnull(de_minimis_source,''n'')=''n''
	group by Item, Group1,group1_ID, Gas, Units,sub'
else
set @sql_stmt='	select 	
--		sub [Group],
--		Group1 Source, 	
--		Gas, 
		detail.col1,
		detail.Col2 Source, 	
		detail.col3 Gas, 
		Units, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr1Vol),0) Yr1, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr2Vol),0) Yr2, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr3Vol),0) Yr3, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(Yr4Vol),0) Yr4, 
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(case when group1_ID='+cast(@carbon_flux_id as varchar)+' then -1 else 1 end * sum(ReportingYearVol),0) [Reporting Year Emissions or Carbon Flux],
		cast(round(sum(ISNULL(RatingValue,0))/sum(abs(case when ReportingYearVol = 0 then null else ReportingYearVol end)),2) as varchar) [Weighted Rating]
	from '+@table_name+' a 
	RIGHT OUTER JOIN
	ems_tmp_detail detail on a.Item=detail.col1
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where isnull(de_minimis_source,''n'')=''n''
	and head.[ID]=1
	group by Group1,group1_ID, Gas, Units,sub
	,detail.Col2,detail.Col3,detail.orderno,detail.col1
	order by detail.orderno
	'
--print @sql_stmt
exec(@sql_stmt)
RETURN
END

--Schedule I.Section2.PART B.1.a Inventory of Emissions and Carbon Flux/Enter Direct Emissions/Stationary Combustion
else If @report_section = 'I.2.B.1.a'
BEGIN

set @sql_stmt='	select 	
--		case when group3=''Fugitive Emissions During Transport and Processing'' then ''Fossil Fuel Combustion '' else Group3 end Source, 
--		Gas, 
--		case when group3=''Fugitive Emissions During Transport and Processing'' then ''NULL'' else detail.col1 end Source, 
		detail.col1 Source,
		detail.col2 Gas, 
		Units, 
		round(sum(Yr1Vol),0) Yr1, round(sum(Yr2Vol),0) Yr2, round(sum(Yr3Vol),0) Yr3, round(sum(Yr4Vol),0) Yr4, 
		round(sum(SumBaseYearsVol)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(ReportingYearVol),0) [Reporting Year Emissions],
		max(estimation_method) [Estimation Method],
		round(sum(RatingValue)/sum(abs(case when ReportingYearVol = 0 then null else ReportingYearVol end)),2) [Rating]
	from '+@table_name+' a
	RIGHT JOIN
	ems_tmp_detail detail on 
	
		--case  when group3=''Fugitive Emissions During Transport and Processing'' then ''Fossil Fuel Combustion'' else 
		ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) 
		and a.gas=detail.col2
	and Group2_ID ='+cast(@stationary_combustion as varchar)+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where  current_forecast=''r''
	and head.[ID]=2
	and isnull(de_minimis_source,''n'')=''n'' 
	group by Item, detail.col1, Gas, Units,
	detail.col2,detail.orderno
 	
	union

  	select ''Subtotal'',
	 	--'''+@conv_to_gas+''',
		''CO2e'',
		max(su.uom_name) units,
		round(SUM(Yr1Vol*Co2_conversion_factor),0) Yr1,
		round(SUM(Yr2Vol*Co2_conversion_factor),0) Yr2,
		round(SUM(Yr3Vol*Co2_conversion_factor),0) Yr3,
		round(SUM(Yr4Vol*Co2_conversion_factor),0) Yr4,
		round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(SUM(ReportingYearVol*Co2_conversion_factor),0) [Reporting Year Emissions],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+' and current_forecast=''r''
	and isnull(de_minimis_source,''n'')=''n''
	and  Group2_ID = '+cast(@stationary_combustion as varchar)

--print @sql_stmt
EXEC(@sql_stmt)
RETURN
END

--Schedule I.Section2.PARTB.1.b Inventory of Emissions and Carbon Flux/Enter Direct Emissions/Mobile Sources
else If @report_section = 'I.2.B.1.b'
BEGIN


set @sql_stmt='	select 	
		--Group3 Source, 
		--Gas, 
		detail.col1 Source,
		detail.col2 Gas,
		Units, 
		round(sum(Yr1Vol),0) Yr1, round(sum(Yr2Vol),0) Yr2,round(sum(Yr3Vol),0) Yr3,round(sum(Yr4Vol),0) Yr4, 
		round(sum(SumBaseYearsVol)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(ReportingYearVol),0) [Reporting Year Emissions],
		estimation_method [Estimation Method],
		round(sum(RatingValue)/sum(abs(case when ReportingYearVol = 0 then null else ReportingYearVol end)),2) [Rating]
	from '+@table_name+' a RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) and a.gas=detail.col2
	and Group2_ID = '+cast(@mobile_sources as varchar)+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 
	isnull(de_minimis_source,''n'')=''n'' and head.[ID]=3 
	group by Item, Group3, Gas, Units, estimation_method ,detail.col1,detail.col2,detail.orderno
	
	UNION
  	select ''Subtotal'',
	 	'''+@conv_to_gas+''',
		''Metric Tons'',
		round(SUM(Yr1Vol*Co2_conversion_factor),0) Yr1,
		round(SUM(Yr2Vol*Co2_conversion_factor),0) Yr2,
		round(SUM(Yr3Vol*Co2_conversion_factor),0) Yr3,
		round(SUM(Yr4Vol*Co2_conversion_factor),0) Yr4,
		round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(SUM(ReportingYearVol*Co2_conversion_factor),0) [Reporting Year Emissions],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+'
	where  1=1 and isnull(de_minimis_source,''n'')=''n''
	and  Group2_ID = '+cast(@mobile_sources as varchar)	
	--print 	@sql_stmt
	EXEC(@sql_stmt)

	RETURN
END

--Schedule I.Section2.PARTB.1.c Inventory of Emissions and Carbon Flux/Enter Direct Emissions/Sector specific Industrial process emissions
else If @report_section = 'I.2.B.1.c'
BEGIN
set @sql_stmt='	select 	
--		Group3 Source, 
--		Gas, 
		detail.col1 Source,
		detail.col2 Gas,
		Units, 
		sum(Yr1Vol) Yr1, sum(Yr2Vol) Yr2, sum(Yr3Vol) Yr3, sum(Yr4Vol) Yr4, 
		sum(SumBaseYearsVol)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
		sum(ReportingYearVol) [Reporting Year Emissions],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from '+@table_name+'  a RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) and a.gas=detail.col2
	and Group2_ID = '+cast(@sector_specific as varchar)+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where  isnull(de_minimis_source,''n'')=''n''
	and head.[ID]=4
	group by Item, Group3, Gas, Units, estimation_method,detail.col1,detail.col2

	UNION
  	select ''Subtotal'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) units,
		SUM(Yr1Vol*Co2_conversion_factor) Yr1,
		SUM(Yr2Vol*Co2_conversion_factor) Yr2,
		SUM(Yr3Vol*Co2_conversion_factor) Yr3,
		SUM(Yr4Vol*Co2_conversion_factor) Yr4,
		sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
		SUM(ReportingYearVol*Co2_conversion_factor) [Reporting Year Emissions],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+' 
	left join  source_uom su on 
	su.source_uom_id='+cast(@convert_uom_id as varchar)+' 
	where isnull(de_minimis_source,''n'')=''n''
	and  Group2_ID = '+cast(@sector_specific as varchar)	

	EXEC(@sql_stmt)

	RETURN
END

--Schedule I.Section2.PARTB.1.d Inventory of Emissions and Carbon Flux/Enter Direct Emissions/Agriculture Sources
else If @report_section = 'I.2.B.1.d'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group3 from '+@table_name+' where 1=1 
	 AND Group2_ID ='+cast(@agriculture_sources as varchar)
	+case when @source is not null then ' And group3='''+@source+'''' else '' end +
	' group by Item, Group3,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	 where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else
set @sql_stmt='	select 	
--		Group3 Source, 
--		Gas, 
		detail.col1 as Source,
		detail.col2 as Gas,
		Units, 
		sum(Yr1Vol) Yr1, sum(Yr2Vol) Yr2, sum(Yr3Vol) Yr3, sum(Yr4Vol) Yr4, 
		sum(SumBaseYearsVol)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
		sum(ReportingYearVol) [Reporting Year Emissions],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from '+@table_name+' a RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) and a.gas=detail.col2
	and Group2_ID ='+cast(@agriculture_sources as varchar)+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 1=1 and head.[ID]=10
	group by Item, Group3, Gas, Units, estimation_method,detail.col1,detail.col2 
	UNION
  	select ''Subtotal'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) units,
		SUM(Yr1Vol*Co2_conversion_factor) Yr1,
		SUM(Yr2Vol*Co2_conversion_factor) Yr2,
		SUM(Yr3Vol*Co2_conversion_factor) Yr3,
		SUM(Yr4Vol*Co2_conversion_factor) Yr4,
		sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
		SUM(ReportingYearVol*Co2_conversion_factor) [Reporting Year Emissions],
		NULL as [Estimation Method],
			NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and  Group2_ID = '+cast(@agriculture_sources as varchar)	
	
	EXEC(@sql_stmt)
	RETURN
END

--Schedule I.Section2.PARTB.1.e Inventory of Emissions and Carbon Flux/Enter Direct Emissions/Fugitive Emissions Associated with Geological Reservoirs
else If @report_section = 'I.2.B.1.e'
BEGIN
set @sql_stmt='	select 	
--		Group3 Source, 
--		Gas, 
		detail.col1 as Source,
		detail.col2 as Gas,
		Units, 
		round(sum(Yr1Vol),0) Yr1, round(sum(Yr2Vol),0) Yr2, round(sum(Yr3Vol),0) Yr3, round(sum(Yr4Vol),0) Yr4, 
		round(sum(SumBaseYearsVol)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(ReportingYearVol),0) [Reporting Year Emissions],
		estimation_method [Estimation Method],
		abs(round(sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end),2)) [Rating]
	from '+@table_name+'  a RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) and a.gas=detail.col2
		and Group3_ID=173
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 1=1 and head.[ID]=12

	--Group2_ID ='+ cast(@fugitive_emissions as varchar)+' and calculated=''y''
	group by Item, Group3, Gas, Units, estimation_method,detail.col1,detail.col2 '
	
	--print @sql_stmt
	EXEC(@sql_stmt)
	RETURN
END

-- select * from #temp
--  exec(' select *  from '+@table_name)
-- return
--Schedule I.Section2.PARTB.1.f Inventory of Emissions and Carbon Flux/Enter Direct Emissions/Captured Co2Emissions
else If @report_section = 'I.2.B.1.f'
BEGIN
set @sql_stmt='	select 
--		Group2 Source, 
--		gas as Gas,
		detail.col1 Source,
		detail.col2 Gas,
		max(su.uom_name) as [Unit of Measure],		
		abs(case when rg.ems_book_id in(186,188) then round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) else 0 end) as [Base Onsite],
		abs(case when rg.ems_book_id in(187,189) then round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) else 0 end)   as [Base Offsite],	
		abs(round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+',0)) as [Base Total],
		abs(case when rg.ems_book_id in(186,188) then round(sum(ReportingYearVol*Co2_conversion_factor),0) else 0 end)  as [Reporting Onsite],
		abs(case when rg.ems_book_id in(187,189) then round(sum(ReportingYearVol*Co2_conversion_factor),0) else 0 end)   as [Reporting Offsite],
		abs(round(abs(sum(ReportingYearVol*Co2_conversion_factor)),0)) as [Reporting Total]
	from '+@table_name+' a 
	left outer join rec_generator rg on a.generator_id=rg.generator_id
	left join source_uom su on su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group2))=ltrim(rtrim(detail.col1)) and a.gas=detail.col2
	and ISNULL(a.co2_captured_for_generator_id,'''')<>'''''+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 1=1 and head.[ID]=14
	 group by Group2,Group3_id,rg.ems_book_id,gas,detail.col1,detail.col2'

	--PRINT @sql_stmt
	EXEC(@sql_stmt)
	RETURN
END

--##############
--Schedule I.Section2.PART B.2 Indirect Emissions From Purchased Energy

--Schedule I.Section2.PART B.2.a Indirect Emissions From Purchased Energy/Physical Quantities Of Energy Purchased
--NEED TO FIX THIS LATER.. FOR NOW ASSUME 12 MONTHS DATA



else If @report_section = 'I.2.B.2.a'
BEGIN
set @sql_where=' esi.input_value else 0 end '
set @sql_stmt='	select 	
		--Group3 Source, 
		detail.col1 Source,
		max(su.uom_name) Units, 
		sum(case when (year(a.term_start) ='+cast(isnull(@base_yr1, -1) as varchar)+') then '+@sql_where+')/'+CAST(@input_count_duplicate AS VARCHAR)+' Yr1,
		sum(case when (year(a.term_start) ='+cast(isnull(@base_yr2, -1) as varchar)+') then '+@sql_where+')/'+CAST(@input_count_duplicate AS VARCHAR)+' Yr2,
		sum(case when (year(a.term_start) ='+cast(isnull(@base_yr3, -1) as varchar)+') then '+@sql_where+')/'+CAST(@input_count_duplicate AS VARCHAR)+' Yr3,
		sum(case when (year(a.term_start) ='+cast(isnull(@base_yr4, -1) as varchar)+') then '+@sql_where+')/'+CAST(@input_count_duplicate AS VARCHAR)+' Yr4,
		sum((case when (year(a.term_start) ='+cast(isnull(@base_yr1, -1) as varchar)+' OR
			   year(a.term_start) ='+cast(isnull(@base_yr2, -1) as varchar)+' OR
			   year(a.term_start) ='+cast(isnull(@base_yr3, -1) as varchar)+' OR
			   year(a.term_start) ='+cast(isnull(@base_yr4, -1) as varchar)+') then '+@sql_where+'))/'+cast(ISNULL(@base_yr_count,1) as varchar)+'/'+CAST(@input_count_duplicate AS VARCHAR)+' [Base Period Average],
		round(sum(case when year(a.term_start)='+cast(@reporting_year as varchar)+' then esi.input_value else 0 end),0)/'+CAST(@input_count_duplicate AS VARCHAR)+' [Reporting Year Consumption],
		max(technology) as  [System Type/Fuel Used For Generation]
	from '+@table_name+' a inner join ems_gen_input esi on esi.generator_id=a.generator_id
	and year(a.term_start)=year(esi.term_start) 
	inner join source_uom su on su.source_uom_id=esi.uom_id
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) 
	and group1_ID='+cast(@indirect_emissions_id as varchar)+'	
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where  isnull(de_minimis_source,''n'')=''n'' and head.[ID]=16
	group by  Group3,detail.col1,detail.orderno order by detail.orderno'

	--print @sql_stmt
	exec(@sql_stmt)
	RETURN
END

--Schedule I.Section2.PART B.2.b Indirect Emissions From Purchased Energy/Emissions fom Purchased Energy for Emissions Inventory
else If @report_section = 'I.2.B.2.b'
BEGIN
set @sql_stmt='	select 	
--		Group3 Source, 
--		Gas,
		detail.col1,
		detail.col2,
		Units, 
		round(sum(Yr1Vol),0) Yr1, 
		round(sum(Yr2Vol),0) Yr2, 
		round(sum(Yr3Vol),0) Yr3, 
		round(sum(Yr4Vol),0) Yr4, 
		round(sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(ReportingYearVol),0) [Reporting Year Emissions],
		max(estimation_method) [Estimation Method],
		cast(abs(round(sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else abs(ReportingYearVol) end),2)) as varchar) [Rating]
	from '+@table_name+' a left join source_uom su on
	su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) and  a.gas=detail.col2
	and group1_ID='+cast(@indirect_emissions_id as varchar)+'	and ext_deal=1		
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 1=1 and  head.[ID]=17
	group by Item, Group3,Gas, Units,detail.col1,detail.col2

	UNION
  		select ''Total'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) Units,
		round(SUM(Yr1Vol),0) Yr1,
		round(SUM(Yr2Vol),0) Yr2,
		round(SUM(Yr3Vol),0) Yr3,
		round(SUM(Yr4Vol),0) Yr4,
		round(sum(SumBaseYearsVol)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(SUM(ReportingYearVol),0) [Reporting Year Emissions],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and ext_deal=1
	and group1_ID='+cast(@indirect_emissions_id as varchar)

	exec(@sql_stmt)
	RETURN
END

--Schedule I.Section2.PART B.2.c Indirect Emissions From Purchased Energy/Physical Quantities Of Energy Purchased
-- Need to work

else If @report_section = 'I.2.B.2.c'
BEGIN
set @sql_stmt='	select 	
		detail.col1 as Source, 
		detail.col2 as Gas,
		Units, 
		round(sum(Yr1Vol),0) Yr1, 
		round(sum(Yr2Vol),0) Yr2, 
		round(sum(Yr3Vol),0) Yr3, 
		round(sum(Yr4Vol),0) Yr4, 
		round(sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(reportingyearvol),0) [Reporting Year Emissions],
		NULL [Estimation Method],
		NULL [Rating]
from '+@table_name+' a left join source_uom su
	on su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.group3))  and a.gas=detail.col2
	and group1_ID='+cast(@indirect_emissions_id as varchar)+'
	and group3_ID='+cast(@Electricity as varchar)+'	
	and ext_deal<>1
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where  head.[ID]=18 and ltrim(rtrim(detail.col1))=''Electricity''
	group by Group3,Units,detail.col2,detail.col1
UNION
	select 	
--		''Steam, Hot Water, and Chilled Water'' as Source, 
--		Gas,
		detail.col1 as Source,
		detail.col2 as Gas,
		Units, 
		round(sum(Yr1Vol),0) Yr1, 
		round(sum(Yr2Vol),0) Yr2, 
		round(sum(Yr3Vol),0) Yr3, 
		round(sum(Yr4Vol),0) Yr4, 
		round(sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(reportingyearvol),0) [Reporting Year Emissions],
		NULL [Estimation Method],
		NULL [Rating]
	from '+@table_name+' a left join source_uom su
	on su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.group3))  and a.gas=detail.col2
	and group1_ID='+cast(@indirect_emissions_id as varchar)+'
	and group3_ID='+cast(@Electricity as varchar)+'	
	and ext_deal<>1
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where  head.[ID]=18 and ltrim(rtrim(detail.col1))<>''Electricity''
	group by Gas, Units,estimation_method,detail.col2,detail.col1
UNION
  		select ''Total'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) Units,
		round(SUM(Yr1Vol*Co2_conversion_factor),0) Yr1,
		round(SUM(Yr2Vol*Co2_conversion_factor),0) Yr2,
		round(SUM(Yr3Vol*Co2_conversion_factor),0) Yr3,
		round(SUM(Yr4Vol*Co2_conversion_factor),0) Yr4,
		round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(SUM(reportingyearvol*Co2_conversion_factor),0) [Reporting Year Emissions],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and ext_deal<>1
	and group1_ID='+cast(@indirect_emissions_id as varchar)

	exec(@sql_stmt)
	RETURN
END

--Schedule I.Section2.PART B.3 Other Indirect Emissions
else If @report_section = 'I.2.B.3'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group2 from '+@table_name+' where 1=1 
	and group1_ID='+cast(@other_indirect_emissions_id as varchar)
	+case when @source is not null then ' And group2='''+@source+'''' else '' end +
	' group by Item, Group2,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	 where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else
set @sql_stmt='	select 	
--		Group2 Source, 
--		Gas,
		detail.col1 Source,
		detail.col2 Gas,
		Units, 
		sum(Yr1Vol) Yr1, 
		sum(Yr2Vol) Yr2, 
		sum(Yr3Vol) Yr3, 
		sum(Yr4Vol) Yr4, 
		sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Base Period Average],
		sum(ReportingYearVol) [Reporting Year Emissions],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from '+@table_name+' a left join source_uom su
	on su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group2))=ltrim(rtrim(detail.col1))
	and group1_id='+cast(@other_indirect_emissions_id as varchar)+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 1=1 and  head.[ID]=19
	group by Group2,Gas, Units,estimation_method,detail.col1,detail.col2
UNION
  		select ''Subtotal'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) Units,
		SUM(Yr1Vol*Co2_conversion_factor) Yr1,
		SUM(Yr2Vol*Co2_conversion_factor) Yr2,
		SUM(Yr3Vol*Co2_conversion_factor) Yr3,
		SUM(Yr4Vol*Co2_conversion_factor) Yr4,
		sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
		SUM(ReportingYearVol*Co2_conversion_factor) [Reporting Year Emissions],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and group1_id='+cast(@other_indirect_emissions_id as varchar)
	exec(@sql_stmt)
	RETURN
END



--Schedule I.Section2.PART B.4.a Enter Terestrial Carbon Fluxes and Stocks/Forestry Activities

else If @report_section = 'I.2.B.4.a'
BEGIN
set @sql_stmt='	
select Source,Gas,Units,[Base Period Average],[Estimated Carbon Stocks in Year Prior to Reporting Year],
[Reporting Year Carbon Stocks],[Reporting Year Stock Change or Carbon Flux],[Estimation Method],[Rating] from
(
select 	
		1 as item,
--		Group3 Source, 
--		Gas,
		detail.col1 Source,
		detail.col2 Gas,
		Units, 
		round(sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(Prior_ReportingYearVol),0) as [Estimated Carbon Stocks in Year Prior to Reporting Year],
		round(sum(ReportingYearVol),0) [Reporting Year Carbon Stocks],
		round(sum(ReportingYearVol)-sum(Prior_ReportingYearVol),0) as [Reporting Year Stock Change or Carbon Flux],
		estimation_method [Estimation Method],
		abs(round(sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end),2)) [Rating]
	from '+@table_name+' a
	RIGHT  JOIN
	ems_tmp_detail detail on ltrim(rtrim(a.Group3))=ltrim(rtrim(detail.col1)) and  a.gas=detail.col2
	and group2_id='+cast(@forest_activities as varchar)+'
	inner join ems_tmp_head head on detail.[ID]=head.[ID]
	where 1=1 and  head.[ID]=20
	group by Item, Group3,Gas, Units,estimation_method,detail.col1,detail.col2 
UNION
	select 
		2 as item,
		''Total'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) Units, 
		round(sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average],
		round(sum(Prior_ReportingYearVol),0) as [Estimated Carbon Stocks in Year Prior to Reporting Year],
		round(sum(ReportingYearVol),0) [Reporting Year Carbon Stocks],
		round(sum(ReportingYearVol)-sum(Prior_ReportingYearVol),0) as [Reporting Year Stock Change or Carbon Flux],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and group2_id='+cast(@forest_activities as varchar)+')a
order by item '

	--print @sql_stmt
	exec(@sql_stmt)
	RETURN
END

--Schedule I.Section2.PART B.4.b.1 Enter Terestrial Carbon Fluxes and Stocks/Wood Products / Method 1


else If @report_section = 'I.2.B.4.b.1'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group3 from '+@table_name+' where 1=1 
	and group3_id='+cast(@wood_products as varchar)
	+case when @source is not null then ' And group3='''+@source+'''' else '' end +
	' group by Item, Group3,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else

set @sql_stmt='	select 	
		detail.col1 Category, 
		detail.col2 Gas,
		Units, 
		sum(Prior_ReportingYearVol) as [Estimated Carbon Stocks in Harvested Wood Products in Year Prior to Reporting Year],
		sum(ReportingYearVol) [Estimated Carbon Stocks in Harvested Wood Products in Reporting Year],
		sum(ReportingYearVol)-sum(Prior_ReportingYearVol) as [Reporting Year Stock Change],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and head.[ID]=21 left join '+@table_name+' a
	on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.Group3)) and  detail.col2=a.gas 
	and group2_id='+cast(@forest_activities as varchar)+' and group3_id='+cast(@wood_products as varchar)+'
	where 1=1
	group by Item, Group3,Gas, Units,estimation_method,detail.col1,detail.col2 '
	exec(@sql_stmt)
	RETURN
END

--Schedule I.Section2.PART B.4.b.2 Enter Terestrial Carbon Fluxes and Stocks/Wood Products/ Method 2

else If @report_section = 'I.2.B.4.b.2'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group3 from '+@table_name+' where 1=1 
	and group3_id='+cast(@wood_products as varchar)
	+case when @source is not null then ' And group3='''+@source+'''' else '' end +
	' group by Item, Group3,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	 where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else
set @sql_stmt='	select
	--	a.generator_id, 	
		col1 Category, 
		col2,
		Units, 
		sum(ReportingYearVol) [Stock of Carbon in Harvested Wood],
		sum(egi.input_value*Conv0.conversion_factor) as [100 Years Residual Carbon Stock],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and head.[ID]=24 left join '+@table_name+' a
	on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.Group3)) and  detail.col2=a.gas  
	and group3_id='+cast(@wood_products as varchar)+' left join rec_generator rg on a.generator_id=rg.generator_id
	left join level_input_map lim on lim.group_level_id=rg.ems_book_id
	left join ems_source_input esi on esi.ems_source_input_id=lim.ems_source_input_id
	and input_output_id='+cast(@system_input_id as varchar)+' 
	left join ems_gen_input egi on egi.ems_input_id=esi.ems_source_input_id
	LEFT OUTER JOIN rec_volume_unit_conversion Conv0 ON            
	 Conv0.from_source_uom_id = egi.uom_id
	 AND Conv0.to_source_uom_id = '+cast(@convert_uom_id as varchar)+'
	 And Conv0.state_value_id IS NULL
	 AND Conv0.assignment_type_value_id IS NULL
	 AND Conv0.curve_id IS NULL
	where 1=1 group by a.generator_id,Item, Group3,Gas, Units,estimation_method ,col1,col2'
	exec(@sql_stmt)
	RETURN
END	


--Schedule I.Section2.PART B.4.c Enter Terestrial Carbon Fluxes and Stocks/Lan restoration and Forest Preservation
else If @report_section = 'I.2.B.4.c'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group3 from '+@table_name+' where 1=1 
	and group2_id='+cast(@land_restoration as varchar)
	+case when @source is not null then ' And group3='''+@source+'''' else '' end +
	' group by Item, Group3,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	 where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else

	set @sql_stmt='	select 	
		Group3 Source, 
 		classification as [Type of Restriction],
		a.first_gen_date [Year Protected],
		sum(egi.input_value) as [Area(Acres)],
		Units, 
		sum(ReportingYearVol) [50% of Carbon Stock Accumulated in 50 Years from Inception of Preservation Activity],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from '+@table_name+' a
	inner join rec_generator rg on a.generator_id=rg.generator_id
	inner join ems_input_map lim on lim.source_model_id=rg.ems_source_model_id
	inner join ems_source_input esi on esi.ems_source_input_id=lim.input_id
	inner join ems_gen_input egi on egi.ems_input_id=esi.ems_source_input_id
	and egi.generator_id=rg.generator_id
	where group2_id='+cast(@land_restoration as varchar)+'
	group by Group3,Units,estimation_method,classification,a.first_gen_date

 UNION	  select 
		''Total'',
 	 	NULL,
		NULL, 
		NULL,
		max(su.uom_name) Units, 
		sum(ReportingYearVol) [50% of Carbon Stock Accumulated in 50 Years from Inception of Preservation Activity],
		NULL as [Estimation Method],
		NULL as [Rating]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and group2_id='+cast(@land_restoration as varchar)
	exec(@sql_stmt)
	RETURN

END

--Schedule I.Section2.PART B.4.d Enter Terestrial Carbon Fluxes and Stocks/Lan restoration and Forest Preservation
else If @report_section = 'I.2.B.4.d'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group3 from '+@table_name+' where 1=1 
	and group2_id='+cast(@natural_disturbance as varchar)
	+case when @source is not null then ' And group3='''+@source+'''' else '' end +
	' group by Item, Group3,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	 where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else

	set @sql_stmt='	select 	
		Group3 Source, 
		sum(egi.input_value) as [Area(Acres)],
 		esd.code as [Type of Disturbance],
		esd1.code as [Year],
		Units, 
		sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Base Period Average],
		sum(Prior_ReportingYearVol) as [Carbon Stocks in Year Before Disturbance],	
		sum(ReportingYearVol) [Reporting Year Carbon Stocks],
		sum(ReportingYearVol)-sum(Prior_ReportingYearVol) as Loss,
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
from '+@table_name+' a
	inner join rec_generator rg on a.generator_id=rg.generator_id
	inner join ems_input_map lim on lim.source_model_id=rg.ems_source_model_id
	inner join ems_source_input esi on esi.ems_source_input_id=lim.input_id
	inner join ems_gen_input egi on egi.ems_input_id=esi.ems_source_input_id
	and egi.generator_id=rg.generator_id
	left join ems_static_data_value esd on esd.value_id=egi.char1
	left join ems_static_data_value esd1 on esd1.value_id=egi.char2

	where group2_id='+cast(@natural_disturbance as varchar)+'
	group by Group3,Units,estimation_method,esd.code,esd1.code

 UNION	  select 
		''Total'',
 	 	NULL,
		NULL, 
		NULL,
		NULL, 
 	 	NULL,
		NULL, 
		NULL,
		sum(ReportingYearVol)-sum(Prior_ReportingYearVol) as Loss, 
 	 	NULL,
		NULL 
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and group2_id='+cast(@natural_disturbance as varchar)
	exec(@sql_stmt)
	RETURN

END

--Schedule I.Section2.PART B.4.e Enter Terestrial Carbon Fluxes and Stocks/Lan restoration and Forest Preservation
else If @report_section = 'I.2.B.4.e'
BEGIN

set @sql_stmt='	select
		rg.name as [Name/Description of Tract Land], 	
		esi.constant_value as [Area(Acres)],

		rg.sustainability_verified as [Has Sustainability been verified by Third Party Certifier(Y/N)],
		sd.code as [Identify System Used to Determine Sustainability]
	from '+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	inner join level_input_map lim on lim.group_level_id=rg.ems_book_id
	inner join ems_source_input esi on esi.ems_source_input_id=lim.ems_source_input_id
	and input_output_id='+cast(@system_input_id as varchar)+' 
	left join static_data_value sd on sd.value_id=rg.sustainability_system
	where group2_id='+cast(@sustainable_forest as varchar)
	--+' group by rg.name,Item, Group3,Gas, Units,estimation_method '

	exec(@sql_stmt)	
END

--Schedule I.Section2.PART B.4.f Enter Terestrial Carbon Fluxes and Stocks/Lan restoration and Forest Preservation
else If @report_section = 'I.2.B.4.f'
BEGIN
	set @sql_stmt='	select

		rg.name as [Name/Description of Tract Land], 	
		esi.constant_value as [Area(Acres)],
		rg.sustainability_verified as [Has Sustainability been verified by Third Party Certifier(Y/N)],
		sd.code as [Identify System Used to Determine Sustainability]
	from '+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	inner join level_input_map lim on lim.group_level_id=rg.ems_book_id
	inner join ems_source_input esi on esi.ems_source_input_id=lim.ems_source_input_id
	and input_output_id='+cast(@system_input_id as varchar)+' 
	left join static_data_value sd on sd.value_id=rg.sustainability_system
	where group2_id='+cast(@sustainable_forest as varchar)
	--+' group by rg.name,Item, Group3,Gas, Units,estimation_method '

	exec(@sql_stmt)	
END


--Schedule I.Section2.PART B.4.g Enter Terestrial Carbon Fluxes and Stocks/Wood Products/ Method 2
else If @report_section = 'I.2.B.4.g'
BEGIN
If @drill_down_level=1
set @sql_stmt='	select 	
		rg.[name] [Generator],
		calc.term_start [Term Start],
		calc.term_end [Term End],
		calc.formula_value [Value],
		su.uom_name [UOM],
		calc.formula_str [Formula]
	from (select generator_id,group3 from '+@table_name+' where 1=1 
	and group2_id='+cast(@other_terestrial_carbon_flux as varchar)
	+case when @source is not null then ' And group3='''+@source+'''' else '' end +
	' group by Item, Group3,generator_id ) a inner join ems_calc_detail_value calc on calc.generator_id=a.generator_id
	inner join rec_generator rg on rg.generator_id=a.generator_id
	inner join source_uom su on su.source_uom_id=calc.uom_id
	 where 1=1 '
	+case when @year is not null then ' And year(term_stat)='+cast(@year as varchar)+'' else '' end
else
set @sql_stmt='	select 	
		col1 as Categories, 
		col2 as Gas,
		Units, 
		sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Base Period Average],
		sum(Prior_ReportingYearVol) as [Estimated Carbon Stocks in Year Prior to Reporting Year],
		sum(ReportingYearVol) [Estimated Carbon Stock in Reporting Year],
		sum(ReportingYearVol)- sum(Prior_ReportingYearVol) as [Reporting Year Stock Change or Carbon Flux],
		estimation_method [Estimation Method],
		sum(RatingValue)/sum(case when ReportingYearVol = 0 then null else ReportingYearVol end) [Rating]
	from ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and head.[ID]=25 left join '+@table_name+' a
	on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.Group3)) and  detail.col2=a.gas and group2_id='+cast(@other_terestrial_carbon_flux as varchar)+'
	where 1=1
	group by Item, Group3,Gas, Units,estimation_method,col1,col2 '

	--print @sql_stmt
	exec(@sql_stmt)
	RETURN
END	


--Schedule I.Section2.PART B.4.h  Terestrial Carbon Fluxes Summary
else If @report_section = 'I.2.B.4.h'
BEGIN
set @sql_stmt='	select 	
		col1 as Categories, 
		col2 as Gas,
--Item, Group2,Gas
		Units, 
		round(sum(ReportingYearVol),0) [Reporting Year Stock Change or Carbon Flux],
		abs(round(sum(RatingValue)/sum(case when ReportingYearVol = 0 then 0 else ReportingYearVol end),2)) [Rating]
	from
ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and head.[ID]=29 left join 
'+@table_name+' a
	on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.Group2)) and  detail.col2=a.gas
	where  1=1	and group1_id='+cast(@carbon_flux_id as varchar)+' group by col1,col2, Units'
	exec(@sql_stmt)
	RETURN
END	

--exec('select * from '+@table_name)

--Schedule I.Section2.PART B.5  Identify and De Minimis Emissions Sources
else If @report_section = 'I.2.B.5'
BEGIN
set @sql_stmt='	select 	
		sub [Emissions Type], 
		Group2 [Emissions Source],
		Gas,
		Units [Unit of Measure], 
		round(sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average Emissions],
		round(sum(ReportingYearVol),0) [Reporting Year Emissions],
		max(ei.last_year) as [Year Last Estimated]
	from '+@table_name+' a inner join rec_generator rg on rg.generator_id=a.generator_id
	left outer join (select generator_id,max(year(term_start)) last_year from emissions_inventory 
		where year(term_start)<'+cast(@reporting_year as varchar)+' group by generator_id)ei on
		a.generator_id=ei.generator_id
	where isnull(rg.de_minimis_source,''n'')=''y''
	group by sub, Group2,Gas, Units
UNION
  		select ''Subtotal'',
	 	NULL,
		'''+@conv_to_gas+''',
		max(su.uom_name) Units,
		round(sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(ISNULL(@base_yr_count,1) as varchar)+',0) [Base Period Average Emissions],
		round(sum(ReportingYearVol*Co2_conversion_factor),0) [Reporting Year Emissions],
		NULL as [Year Last Estimated]
	from '+@table_name+' a  inner join rec_generator rg on rg.generator_id=a.generator_id,source_uom su
	where isnull(rg.de_minimis_source,''n'')=''y'' 
	and  su.source_uom_id='+cast(@convert_uom_id as varchar)
	exec(@sql_stmt)
	RETURN
END	

--Schedule I.Section2.PART C Total Emissions and Carbon Flux
If @report_section = 'I.2.C'
BEGIN
create table #temp_1(
	Item varchar(100) COLLATE DATABASE_DEFAULT,
	source varchar(100) COLLATE DATABASE_DEFAULT,
	Gas varchar(20) COLLATE DATABASE_DEFAULT,
	Units varchar(20) COLLATE DATABASE_DEFAULT,
	Yr1 FLoat,
	Yr2 FLoat,
	Yr3 FLoat,
	Yr4 FLoat,
	[Base Period Average] FLoat,
	[Reporting Year Emissions] Float
	)

set @sql_stmt='	insert into #temp_1
		select case when item=''F'' then ''H'' when item=''G'' then ''F'' else item end,
		case when left(item,1)=''B'' then ''Indirect Emissions from Purchased Energy for Emissions Inventoy'' else sub end as sub,
		gas,Units,Yr1,Yr2,Yr3,Yr4,[Base Period Average],[Reporting Year Emissions] from
		(select 	
		left(item,1) as item,sub,
		'''+@conv_to_gas+''' as gas,
		max(su.uom_name) Units,
		SUM(Yr1Vol*Co2_conversion_factor) Yr1,
		SUM(Yr2Vol*Co2_conversion_factor) Yr2,
		SUM(Yr3Vol*Co2_conversion_factor) Yr3,
		SUM(Yr4Vol*Co2_conversion_factor) Yr4,
		sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Base Period Average],
		sum(ReportingYearVol)  [Reporting Year Emissions]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and ( (left(item,1)=''A'' and co2_captured_for_generator_id is null) or 
	(left(item,1)=''B'' and ext_deal=1)
	or left(item,1)=''E'' 
	or left(item,1)=''F'' 
	or left(item,1)=''G'')
	group by Left(Item,1),sub) a'

	exec(@sql_stmt)
	--print @sql_stmt

set @sql_stmt='	insert into #temp_1
		select ''F'' as Item,
		''Captured CO2 Sequestered in an Onsite Geologic Reservoir'' as sub,
		gas,Units,Yr1,Yr2,Yr3,Yr4,[Base Period Average],[Reporting Year Emissions] from
		(select 	
		left(item,1) as item,sub,
		'''+@conv_to_gas+''' as gas,
		max(su.uom_name) Units,
		SUM(Yr1Vol*Co2_conversion_factor) Yr1,
		SUM(Yr2Vol*Co2_conversion_factor) Yr2,
		SUM(Yr3Vol*Co2_conversion_factor) Yr3,
		SUM(Yr4Vol*Co2_conversion_factor) Yr4,
		sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Base Period Average],
		abs(sum(ReportingYearVol))  [Reporting Year Emissions]
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and (left(item,1)=''A'' and co2_captured_for_generator_id is not null)
	group by Left(Item,1),sub) a'

	exec(@sql_stmt)

set @sql_stmt='	insert into #temp_1
	select ''C'',
		''Indirect Emissions from Purchased Energy for Calculation of Emission Reductions'',
	 	'''+@conv_to_gas+''',
		max(su.uom_name) Units,
		SUM(Yr1Vol*Co2_conversion_factor) Yr1,
		SUM(Yr2Vol*Co2_conversion_factor) Yr2,
		SUM(Yr3Vol*Co2_conversion_factor) Yr3,
		SUM(Yr4Vol*Co2_conversion_factor) Yr4,
		sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
		SUM(reportingyearvol*Co2_conversion_factor) [Reporting Year Emissions]		
	from '+@table_name+', source_uom su
	where  su.source_uom_id='+cast(@convert_uom_id as varchar)+'
	and ext_deal<>1
	and group1_ID='+cast(@indirect_emissions_id as varchar)	
	exec(@sql_stmt)

set @sql_stmt='	insert into #temp_1	
		select ''D'' as Item,
		''Total Emissions(A+B)'',
		max(gas) as gas,
		max(units) as units,
		sum(case when item =''A'' then Yr1 else Yr1*-1 end) as Yr1,
		sum(case when item =''A'' then Yr2 else Yr2*-1 end) as Yr2,
		sum(case when item =''A'' then Yr3 else Yr3*-1 end) as Yr3,
		sum(case when item =''A'' then Yr4 else Yr4*-1 end) as Yr4,
		sum(case when item =''A'' then [Base Period Average] else [Base Period Average]*-1 end) as [Base Period Average],
		sum(case when item =''A'' then [Reporting Year Emissions] else [Reporting Year Emissions]*1 end) as [Reporting Year Emissions]
		from #temp_1
		where item in (''A'',''B'')'
	exec(@sql_stmt)

set @sql_stmt='	insert into #temp_1	
		select ''G'' as Item,
		''Total Inventory Emissions(D-E-F)'',
		max(gas) as gas,
		max(units) as units,
		sum(case when item =''D'' then Yr1 else Yr1*-1 end) as Yr1,
		sum(case when item =''D'' then Yr2 else Yr2*-1 end) as Yr2,
		sum(case when item =''D'' then Yr3 else Yr3*-1 end) as Yr3,
		sum(case when item =''D'' then Yr4 else Yr4*-1 end) as Yr4,
		sum(case when item =''D'' then [Base Period Average] else [Base Period Average]*-1 end) as [Base Period Average],
		sum(case when item =''D'' then [Reporting Year Emissions] else [Reporting Year Emissions]*-1 end) as [Reporting Year Emissions]
		from #temp_1
		where item in (''D'',''E'',''F'') '
	
	exec(@sql_stmt)


select 
	col1 as Item,
	col2 as source,
	col3 as Gas,
	Units,
	round(Yr1,0) Yr1,
	round(Yr2,0) Yr2,
	round(Yr3,0) Yr3,
	round(Yr4,0) Yr4,
	round([Base Period Average],0) [Base Period Average],
	round([Reporting Year Emissions],0) [Reporting Year Emissions]
 from ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and head.[ID]=34 left join #temp_1 a
	on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.Item)) 
	order by col1

	RETURN
END	

--Schedule I.Section2.PART D.1 Emissions Inventory Rating Summary / Base Period Data
If @report_section = 'I.2.D.1'
BEGIN	
	create table #temp_2(		
		rating_value_id int,
		rating_weight int,
		group1_id int,
		volume Float
		)


--first enter base period data from Direct Emissions Schedule I.Section2.PART B.1 and carbon_flux
	set @sql_stmt='	insert into #temp_2
		select
		rating_value_id,
		rating_weight, 
		Group1_id, 
		sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Volume]
	from '+@table_name+'
	where group1_id in('+cast(@direct_emissions_id as varchar)+','+cast(@carbon_flux_id as varchar)+')
	 	and isnull(de_minimis_source,''n'')=''n''
	group by rating_value_id,rating_weight,Group1_id '
	
	exec(@sql_stmt)



-- enter base period from Indirect Emissions from Purchased Energy Schedule I.Section2.PART B.2.b
set @sql_stmt='	insert into #temp_2
		select 	
		rating_value_id,
		rating_weight, 
		Group1_id, 
		sum(SumBaseYearsVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Volume]
	from '+@table_name+' where 1=1
	and group1_ID='+cast(@indirect_emissions_id as varchar)+'	
		and isnull(de_minimis_source,''n'')=''n''
	group by rating_value_id,rating_weight,Group1_id '
	exec(@sql_stmt)


--exec('select a.code as [Rating Category],a.rating_weight as [Weighting Factor],
--	round([Direct Emissions],0) as [Direct Emissions],round([Indirect Emissions],0) as [Indirect Emissions from Purchased Energy],round([Carbon Flux],0) as [Carbon Flux],
--	round([Direct Emissions]+[Indirect Emissions]+[Carbon Flux],0) as [Total Emissions],
--	round(([Direct Emissions]+[Indirect Emissions]+[Carbon Flux])*rating_weight,0) as [Weighted Total Emissions]
--	 from (SELECT sd.code,a.rating_weight, max(CASE WHEN a.group1_id = 2 THEN a.volume ELSE 0 END)
--		 AS [Direct Emissions],max(CASE WHEN a.group1_id = 3 THEN a.volume ELSE 0 END) AS [InDirect Emissions],
--		max(CASE WHEN a.group1_id = 5 THEN a.volume ELSE 0 END) AS [Carbon Flux] from 
--	#temp_2 tmp inner join (
--	select 
--		rating_value_id,
--		rating_weight,
--		group1_id,
--		sum(volume)volume
--	from	
--		#temp_2 group by rating_value_id,rating_weight,group1_id
--	) a
--	on tmp.group1_id=a.group1_id) 
--	')

SET @SQL = 'SELECT sd.code,a.rating_weight, '

SET 	@SQL = @SQL+ 'max(CASE WHEN a.group1_id = ' + CAST(@direct_emissions_id AS VARCHAR(5))+ ' THEN a.volume ELSE 0 END) AS [Direct Emissions],'+
	             'max(CASE WHEN a.group1_id = ' + CAST(@indirect_emissions_id AS VARCHAR(5))+ ' THEN a.volume ELSE 0 END) AS [InDirect Emissions],'+	 
	             'max(CASE WHEN a.group1_id = ' + CAST(@carbon_flux_id AS VARCHAR(5))+ ' THEN a.volume ELSE 0 END) AS [Carbon Flux] '	 	

set @sql='
	select
	col1 as [Rating Category],col2 as [Weighting Factor],
	round([Direct Emissions],0) as [Direct Emissions],round([Indirect Emissions],0) as [Indirect Emissions from Purchased Energy],round([Carbon Flux],0) as [Carbon Flux],
	round([Direct Emissions]+[Indirect Emissions]+[Carbon Flux],0) as [Total Emissions],
	round(([Direct Emissions]+[Indirect Emissions]+[Carbon Flux])*rating_weight,0) as [Weighted Total Emissions]
	 from
		 ('+
	@sql+'  from 
	#temp_2 tmp inner join (
	select 
		rating_value_id,
		rating_weight,
		group1_id,
		sum(volume)volume
	from	
		#temp_2 group by rating_value_id,rating_weight,group1_id
	) a
	on tmp.group1_id=a.group1_id 
	left join static_data_value sd on sd.value_id=a.rating_value_id
	group by sd.code,a.rating_weight ) a 
	RIGHT join  ems_tmp_detail detail on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.code))  
	inner join ems_tmp_head head on head.[ID]=detail.[ID] and head.[ID]=145 	
	where col1 is not null order by col1

'
--print @sql
exec(@SQL)
END

--#####Schedule I.Section2.PART D.2 Emissions Inventory Rating Summary /Reporting Year Data

If @report_section = 'I.2.D.2'
BEGIN	
	create table #temp_3(		
		rating_value_id int,
		rating_weight int,
		group1_id int,
		volume Float
		)
--first enter base period data from Direct Emissions Schedule I.Section2.PART B.1 and carbon_flux
	set @sql_stmt='	insert into #temp_3
		select
		rating_value_id,
		rating_weight, 
		Group1_id, 
		sum(ReportingYearVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Volume]

	from '+@table_name+'
	where group1_id in('+cast(@direct_emissions_id as varchar)+','+cast(@carbon_flux_id as varchar)+')
	 	and isnull(de_minimis_source,''n'')=''n''

	group by rating_value_id,rating_weight,Group1_id '
	
	exec(@sql_stmt)
-- enter base period from Indirect Emissions from Purchased Energy Schedule I.Section2.PART B.2.b
set @sql_stmt='	insert into #temp_3
		select 	
		rating_value_id,
		rating_weight, 
		Group1_id, 
		sum(ReportingYearVol)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' [Volume]
	from '+@table_name+' where 1=1
	and group1_ID='+cast(@indirect_emissions_id as varchar)+'	
	 	and isnull(de_minimis_source,''n'')=''n''

	group by rating_value_id,rating_weight,Group1_id '
	exec(@sql_stmt)



SET @SQL = 'SELECT sd.code,a.rating_weight, '

SET 	@SQL = @SQL+ 'max(CASE WHEN a.group1_id = ' + CAST(@direct_emissions_id AS VARCHAR(5))+ ' THEN a.volume ELSE 0 END) AS [Direct Emissions],'+
	             'max(CASE WHEN a.group1_id = ' + CAST(@indirect_emissions_id AS VARCHAR(5))+ ' THEN a.volume ELSE 0 END) AS [InDirect Emissions],'+	 
	             'max(CASE WHEN a.group1_id = ' + CAST(@carbon_flux_id AS VARCHAR(5))+ ' THEN a.volume ELSE 0 END) AS [Carbon Flux] '	 	

set @sql='
	--select code as [Rating Category],abs(rating_weight) as [Weighting Factor],
	select col1 as [Rating Category],col2 as [Weighting Factor],
	round([Direct Emissions],0) as [Direct Emissions],round([Indirect Emissions],0) as [Indirect Emissions from Purchased Energy],
	round([Carbon Flux],0) as [Carbon Flux],
	round([Direct Emissions]+[Indirect Emissions]+[Carbon Flux],0) as [Total Emissions],
	round(([Direct Emissions]+[Indirect Emissions]+[Carbon Flux])*rating_weight,0) as [Weighted Total Emissions]
	 from ('+
	@sql+'  from 
	#temp_3 tmp inner join (
	select 
		rating_value_id,
		rating_weight,
		group1_id,
		sum(volume)volume
	from	
		#temp_3 group by rating_value_id,rating_weight,group1_id
	) a
	on tmp.group1_id=a.group1_id 
	left join static_data_value sd on sd.value_id=a.rating_value_id
	group by sd.code,a.rating_weight
 ) a
	RIGHT join  ems_tmp_detail detail on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.code))  
	inner join ems_tmp_head head on head.[ID]=detail.[ID] and head.[ID]=145 	
	  where col1 is not null order by col1'

exec(@SQL)
END

--############ Section 3 Emissions Offsets

--Schedule I.Section3.PART A.1 Offsets Obtained by Agreement with Other Reporters
--Schedule I.Section3.PART B.1 Offsets Obtained by Agreement with Other Reporters
-- get from rec deals
If @report_section = 'I.3.A.1' or @report_section = 'I.3.B.1' 
BEGIN	
create table #temp_offsets(
		source_deal_header_id int,
		generator varchar(100) COLLATE DATABASE_DEFAULT,
		counterparty_name varchar(100) COLLATE DATABASE_DEFAULT,
		[Name of other Reporters Subentity] varchar(100) COLLATE DATABASE_DEFAULT,
		[Domestic or Foreign] varchar(100) COLLATE DATABASE_DEFAULT,
		curve_name varchar(100) COLLATE DATABASE_DEFAULT,
		uom_name varchar(100) COLLATE DATABASE_DEFAULT,
		quantity float,
		[Registered by Other Reporter] varchar(10) COLLATE DATABASE_DEFAULT,
		source_deal_type_name varchar(100) COLLATE DATABASE_DEFAULT,
		buy_sell_flag char(1) COLLATE DATABASE_DEFAULT,
		term_start datetime,
		term_end datetime
)


set @sql='
insert into #temp_offsets
select a.*
from ( 
select
		source_deal_header_id,
		rg.name [generator],
		sdh.counterparty_name as [Name of the Reporter],
		NULL [Name of other Reporter''s Sunentity],
		case when country_id='+cast(@domestic_country_id as varchar)+' then ''D'' else ''F'' end as [Domestic or Foreign],
		Gas [Gas],
		units [Unit of Measure],
		reduction_volume [Quantity],
		rg.mandatory as [Registered by Other Reporter],
		source_deal_type_name,
		buy_sell_flag,
		term_start,
		term_end
	from
		'+@table_name+' sdh 
		inner join rec_generator rg on rg.generator_id=sdh.generator_id 
		left join static_data_value sd on sd.value_id=rg.country_id
		left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id
	where 1=1 
		and buy_sell_flag=''b'' 
		and ext_deal=0

	--group by counterparty_name,sd.code,Gas,units ,rg.name
) a
'

exec(@sql)

If @report_section = 'I.3.A.1'
set @sql='select
		counterparty_name as [Name of the Reporter],
		NULL [Name of other Reporter''s Subentity],
		[Domestic or Foreign],
		curve_name as [Env Product],
		uom_name as[Unit of Measure],
		SUM([Quantity]) as Volume,
		max( [Registered by Other Reporter]) as [Registered by Other Reporter]
	from 
		#temp_offsets where [Registered by Other Reporter]=''n''
	group by counterparty_name,[Domestic or Foreign],curve_name,uom_name
		
'
else
set @sql='select
		counterparty_name as [Name of the Reporter],
		NULL [Name of other Reporter''s Subentity],
		[Domestic or Foreign],
		curve_name as [Env Product],
		uom_name as[Unit of Measure],
		SUM([Quantity]) as Volume,
		max( [Registered by Other Reporter]) as [Registered by Other Reporter]
	from 
		#temp_offsets where [Registered by Other Reporter]=''y''
	group by counterparty_name,[Domestic or Foreign],curve_name,uom_name
		
'
		
exec(@sql)

END		


--Schedule I.Section3.PART B.1 Offsets Obtained by Agreement with Other Reporters
/*
If @report_section = 'I.3.B.1'
BEGIN	
set @sql='select
		sc.counterparty_name as [Name of the Reporter],
		NULL [Name of other Reporter''s Sunentity],
		sd.code [Domestic or Foreign],
		spcd.curve_name [Gas],
		su.uom_name [Unit of Measure],
		sdd.deal_volume [Quantity],
		''Y'' as [Registered by Other Reporter]
	from
		source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		inner join rec_generator rg on rg.generator_id=sdh.generator_id 
		INNER JOIN #ssbm ON #ssbm.fas_book_id = rg.fas_book_id

		left join static_data_value sd on sd.value_id=rg.country_id
		left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id
		left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id
		left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id		
	where 1=1 
		and year(sdd.term_start)='+cast(@reporting_year as varchar)

exec(@sql)
END		
*/
---##################################################################################################

---######### Schedule III Section 1 and Section II
-- Emissions Reductions



If @report_section = 'III.I.A' or @report_section = 'III.I.B' or @report_section = 'III.II.A' or @report_section = 'III.II.B'
BEGIN	

--Schedule III.Section1.PART A Enter Domestic Net Entity-Level Registered Reductions and Carbon Storage (metric tons CO2e) 
--Schedule III.Section1.PART B Enter Foreign Net Entity-Level Registered Reductions and Carbon Storage (metric tons CO2e) 
--Schedule III.Section2.PART A Enter Foreign Net Entity-Level Reported Reductions and Carbon Storage (metric tons CO2e) 
--Schedule III.Section2.PART B Enter Foreign Net Entity-Level Reported Reductions and Carbon Storage (metric tons CO2e) 


	If @report_section = 'III.I.A' or @report_section = 'III.I.B' or @report_section = 'III.II.A' or @report_section = 'III.II.B'
	BEGIN
	
		create table #temp_reduc_summary(
			[Item] varchar(100) COLLATE DATABASE_DEFAULT,
			[Method/Source] varchar(100) COLLATE DATABASE_DEFAULT,
			[Gross Registered Reductions] float,
			[Registered Reductions Distributed to Other Reporters] float,
			[Net Registered Reductions] float
		)

--Uday hardcoding/changes 
		if @report_section in ('III.I.B', 'III.II.B')
		begin
			select NULL as [Item], NULL as [Method/Source], null as [Gross Registered Reductions],
				NULL as [Registered Reductions Distributed to Other Reporters],NULL as [Net Registered Reductions]
			return 
		end


		set @sql='
		insert into #temp_reduc_summary
		select 
			''A'' as [Item],''Changes in Emissions Intensity'' as [Method/Source],NULL as [Gross Registered Reductions],
				NULL as [Registered Reductions Distributed to Other Reporters],NULL as [Net Registered Reductions]
		UNION
		

		select
			''A1'' as [Item],''Direct Emissions'' as [Method/Source],
			sum(case when isnull(source_deal_header_id,'''')='''' then reduction_volume else 0 end) as [Gross Registered Reductions],
			sum(case when isnull(source_deal_header_id,'''')<>'''' then reduction_volume else 0 end) as [Registered Reductions Distributed to Other Reporters],
			NULL as [Net Registered Reductions]
	
		from
			'+@table_name+' a inner join rec_generator rg on rg.generator_id=a.generator_id
 		where
			group1_ID='+cast(@direct_emissions_id as varchar)+' and rg.reduction_type=5251
		UNION						

		select
			''A2'' as [Item],''InDirect From Purchased Energy'' as [Method/Source],
			sum(case when isnull(source_deal_header_id,'''')='''' then reduction_volume else 0 end) as [Gross Registered Reductions],
			sum(case when isnull(source_deal_header_id,'''')<>'''' then reduction_volume else 0 end) as [Registered Reductions Distributed to Other Reporters],
			NULL as [Net Registered Reductions]
	
		from
			'+@table_name+' a inner join rec_generator rg on rg.generator_id=a.generator_id
 		where
			group1_ID='+cast(@indirect_emissions_id as varchar)+' and rg.reduction_type=5251
	
		UNION						

		select 
			''B'' as [Item],''Changes in Absoulte Emissions'' as [Method/Source],NULL as [Gross Registered Reductions],
				NULL as [Registered Reductions Distributed to Other Reporters],NULL as [Net Registered Reductions]
		UNION

		select
		--Uday harcoding/changes
			''B1'' as [Item],''Direct Emissions'' as [Method/Source],
			sum(case when isnull(source_deal_header_id,'''')='''' then co2_conversion_factor * reduction_volume else 0 end) as [Gross Registered Reductions],
			sum(case when isnull(source_deal_header_id,'''')<>'''' then co2_conversion_factor * reduction_volume else 0 end) as [Registered Reductions Distributed to Other Reporters],
			sum(case when isnull(source_deal_header_id,'''')='''' then co2_conversion_factor * reduction_volume else 0 end) -
				sum(case when isnull(source_deal_header_id,'''')<>'''' then co2_conversion_factor * reduction_volume else 0 end)
				 as [Net Registered Reductions]
	
		from
			'+@table_name+' a inner join rec_generator rg on rg.generator_id=a.generator_id
 		where
			group1_ID='+cast(@direct_emissions_id as varchar)+' and rg.reduction_type=5252 and ext_deal <> 1
			and isnull(rg.de_minimis_source,''n'')=''n''

		UNION						

		select
		--Uday harcoding/changes
			''B2'' as [Item],''InDirect From Purchased Energy'' as [Method/Source],
			sum(case when isnull(source_deal_header_id,'''') ='''' OR ext_deal = 1  then case when (ext_deal=1) then -1*ReportingYearVol else co2_conversion_factor * reduction_volume end  else 0 end) as [Gross Registered Reductions],
			sum(case when isnull(source_deal_header_id,'''')<>'''' and isnull(buy_sell_flag, '''')=''s'' and ext_deal<>1 then co2_conversion_factor * reduction_volume else 0 end) as [Registered Reductions Distributed to Other Reporters],
			sum(case when isnull(source_deal_header_id,'''') ='''' OR ext_deal = 1  then case when (ext_deal=1) then -1*ReportingYearVol else co2_conversion_factor * reduction_volume end  else 0 end) - 
			 sum(case when isnull(source_deal_header_id,'''')<>'''' and isnull(buy_sell_flag, '''')=''s'' and ext_deal<>1 then co2_conversion_factor * reduction_volume else 0 end) as [Net Registered Reductions]
	
		from
			'+@table_name+' a inner join rec_generator rg on rg.generator_id=a.generator_id
 		where
			group1_ID='+cast(@indirect_emissions_id as varchar)+' and (rg.reduction_type=5252 OR ext_deal = 1)
	
		UNION	
					
		select	[Item],[description],SUM([Gross Registered Reductions]),SUM([Registered Reductions Distributed to Other Reporters]),
			SUM([Gross Registered Reductions]-[Registered Reductions Distributed to Other Reporters]) as	[Net Registered Reductions]
		from
		(
			select 
				case when reduction_type=5258 then ''C''
				     when reduction_type=5259 then ''D''
				     when reduction_type=5260 and reduction_sub_type=5253 then ''E''	
				     when reduction_type=5260 and reduction_sub_type=5254 then ''F''	
				     when reduction_type=5260 and reduction_sub_type=5261 then ''G''	
				     when reduction_type=5260 and reduction_sub_type=5262 then ''H''	
				     when reduction_type=5260 and reduction_sub_type=5263 then ''I''	
				     when reduction_type=5260 and reduction_sub_type=5264 then ''J''	
				     when reduction_type=5260 and reduction_sub_type=5265 then ''K''	
				     when reduction_type=5260 and reduction_sub_type=5266 then ''L''	
				     when reduction_type=5260 and reduction_sub_type=5267 then ''M''	
				     when reduction_type=5260 and reduction_sub_type=5268 then ''N''	
				     when reduction_type=5260 and reduction_sub_type=5269 then ''O''	
				   end as [Item],
				case when reduction_type=5260 then reduction_sub.[description] else reduction.[description] end as [description],
				case when isnull(source_deal_header_id,'''')='''' then sum(reduction_volume) else 0 end as [Gross Registered Reductions],
				case when isnull(source_deal_header_id,'''')<>'''' then sum(reduction_volume) else 0 end as [Registered Reductions Distributed to Other Reporters],
				NULL as [Net Registered Reductions]
			from
				'+@table_name+' tmp inner join
				rec_generator rg on rg.generator_id=tmp.generator_id
				inner join static_data_value reduction on reduction.value_id=rg.reduction_type
				left join static_data_value reduction_sub on reduction_sub.value_id=rg.reduction_sub_type
				left outer join  (select generator_id, case when (ems_book_id in (186,187)) then 0 else 1 end include_co2_capture 
						from rec_generator 
						where co2_captured_for_generator_id is not null)ic on ic.generator_id = tmp.generator_id
			--Uday hardcoding/changes
			where 1=1 and reduction_type not in(5251,5252) and isnull(ic.include_co2_capture, 1) = 1 --only include owned capture
			 group by [item],rg.reduction_type,rg.reduction_sub_type,reduction_sub.[description],reduction.[description],source_deal_header_id
		) a
			group by [item],[description] 

		
		UNION
		
		select	''Q'' as Item,''Offsets''as [Method/Source],NULL as [Gross Registered Reductions],
				NULL as [Registered Reductions Distributed to Other Reporters],NULL as [Net Registered Reductions]

		UNION
		
		select	''Q1'' as Item,''Offsets Obtained from Other Reporters''as [Method/Source],
				SUM(reduction_volume) as [Gross Registered Reductions],
				NULL as [Registered Reductions Distributed to Other Reporters],
				SUM(reduction_volume) as [Net Registered Reductions]
		from
			'+@table_name+' tmp inner join
			rec_generator rg on rg.generator_id=tmp.generator_id 
		where 1=1 and tmp.buy_sell_flag=''b'' '
-- 			+case when @report_section = 'III.I.A' then ' and country_id='+cast(@domestic_country_id as varchar)+' and rg.registered=''y'' ' else '' end -- domestic registered
-- 			+case when @report_section = 'III.I.B' then ' and country_id<>'+cast(@domestic_country_id as varchar)+' and rg.registered=''y'' ' else '' end -- foreign registered
-- 			+case when @report_section = 'III.II.A' then ' and country_id='+cast(@domestic_country_id as varchar)+' and rg.mandatory=''y'' ' else '' end -- domestic reported
-- 			+case when @report_section = 'III.II.B' then ' and country_id<>'+cast(@domestic_country_id as varchar)+' and rg.mandatory=''y'' ' else '' end -- foreign reported
		+' AND rg.mandatory=''y'' 

		UNION
		

		select	''Q2'' as Item,''Offsets Obtained from Other Non-Reporters''as [Method/Source],
			SUM(reduction_volume) as [Gross Registered Reductions],
				NULL as [Registered Reductions Distributed to Other Reporters],
			SUM(reduction_volume) as [Net Registered Reductions]
		from
			'+@table_name+' tmp inner join
			rec_generator rg on rg.generator_id=tmp.generator_id
		where 1=1 and tmp.buy_sell_flag=''b'' '
		+' AND rg.mandatory=''n'' '
--Uday hardcoding/changes

		EXEC spa_print @sql
		exec(@sql)

		insert into #temp_reduc_summary
		select 
			'P' as [Item],'SubTotal(Sum Rows A1 through O)' as [Method/Source],sum(isnull([Gross Registered Reductions],0)) as [Gross Registered Reductions],
				sum(isnull([Registered Reductions Distributed to Other Reporters],0)) as [Registered Reductions Distributed to Other Reporters],
				sum(isnull([Gross Registered Reductions],0))-sum(isnull([Registered Reductions Distributed to Other Reporters],0)) as [Net Registered Reductions]
		from
			#temp_reduc_summary
			where
				item in('A1','A2','B1','B2','C','D','E','F','G','H','I','J','K','L','M','N','O')


		insert into #temp_reduc_summary

		select 
			'R' as [Item],'SubTotal(Sum Rows P through Q2)' as [Method/Source],sum(isnull([Gross Registered Reductions],0)) as [Gross Registered Reductions],
				sum(isnull([Registered Reductions Distributed to Other Reporters],0)) as [Registered Reductions Distributed to Other Reporters],
				sum(isnull([Net Registered Reductions],0)) as [Net Registered Reductions]
		from
			#temp_reduc_summary
			where
				item in('p','Q1','Q2')
		

		--###insert previous year values
		insert into #temp_reduc_summary
		select 
			'S' as [Item],'Reduction Deficits Carried Over from Last Year Report' as [Method/Source],0,0,0
		
		---### SUm Total
		insert into #temp_reduc_summary
		select 
			'T' as [Item],'TOTAL (Add row R to row S)' as [Method/Source],sum(isnull([Gross Registered Reductions],0)) as [Gross Registered Reductions],
				sum(isnull([Registered Reductions Distributed to Other Reporters],0)) as [Registered Reductions Distributed to Other Reporters],
				sum(isnull([Net Registered Reductions],0)) as [Net Registered Reductions]
		from
			#temp_reduc_summary
			where
				item in('R','S')
		
		select * from #temp_reduc_summary where ltrim(rtrim([Item])) not in('Unknow Item') order by Item
	END
END
	
--######### Addendum A1 and A2
--##	Addendum A1 Changes in Emissions Intensity
--##	Addendum A2 Changes in Absolute Intensity

-- Part A.1 Output -- Enter Physical, Economic, or Indexed Output Measures for the Base Period and Reporting Year
-- Part B.1 Emissions,Emissions Intensity and Emission Reductions
-- Part C.1 Distribution of Emission Reductions to Other 1605(b) Reporters

If @report_section = 'A1.A.1' or @report_section = 'A1.B.1' or @report_section = 'A1.C.1' or @report_section = 'A2.A.1' 
	or @report_section = 'A2.B.1' or @report_section = 'A2.C.1' or @report_section = 'A3.B.1'
BEGIN
create table #temp_output(
	[Item] varchar(100) COLLATE DATABASE_DEFAULT,
	[Output Measure] varchar(100) COLLATE DATABASE_DEFAULT,
	[Unit of Measure] varchar(100) COLLATE DATABASE_DEFAULT,
	Yr1 float,Yr2 float,Yr3 float,Yr4 float,
	[Base Period Average] float,
	[Reporting Year] float
)
set @sql='
insert into #temp_output
select 
	
	case when esi.input_output_id=1052 then ''A''
	     when esi.input_output_id=1053 then ''C''
	     when esi.input_output_id=1054 then ''D'' else '''' end as [Item],
	sd.code as [Output Measure],
	su.uom_name as [Unit of Measure],		
	sum(Yr1Vol_Output) Yr1, sum(Yr2Vol_Output) Yr2, sum(Yr3Vol_Output) Yr3, sum(Yr4Vol_Output) Yr4, 
	sum(SumBaseYearsVol_Output)/'+cast(isnull(@base_yr_count,1) as varchar)+' [Base Period Average],
	sum(ReportingYearVol_Output) [Reporting Year]
from
	'+@table_name+' tmp inner join ems_source_input esi on esi.ems_source_input_id=tmp.output_id
	inner join rec_generator rg on rg.generator_id=tmp.generator_id
	left join static_data_value sd on sd.value_id=esi.input_output_id
	left join source_uom su on su.source_uom_id=tmp.output_uom_id
where	output_id is not null '+
--Uday hardcoding/changes
	' and tmp.curve_id = 127 ' +
	+case when @report_section = 'A1.A.1' then ' and rg.reduction_type='+cast(@emissions_intensity as varchar) else '' end
	+case when @report_section = 'A2.A.1' then ' and rg.reduction_type='+cast(@emissions_absolute as varchar) else '' end
	+' group by sd.code,su.uom_name,esi.input_output_id
'
EXEC spa_print @sql
EXEC(@sql)


If @report_section = 'A1.A.1' or @report_section = 'A2.A.1'
BEGIN
--	SET @sql='
--		select * from ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and '+CASE WHEN @report_section = 'A1.A.1' THEN 'head.[ID]=87' ELSE 'head.[ID]=96' END +' left join #temp_output a
--	on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.ITEM))'
--	exec(@sql)
	select * from #temp_output
END

ELSE IF @report_section = 'A1.B.1' or @report_section = 'A2.B.1'
BEGIN

create table #temp_emissions_intensity(
	[Item] varchar(100) COLLATE DATABASE_DEFAULT,
	[Description] varchar(100) COLLATE DATABASE_DEFAULT,
	[Direct Emissions] float,
	[Indirect Emissions from Purchased Energy] float,
	[Other Indirect Emissions] float
)

set @sql_stmt='	
insert into #temp_emissions_intensity
select [Item],[Description],sum([Direct Emissions]) [Direct Emissions],sum([InDirect Emissions from Purchased Energy]) [InDirect Emissions from Purchased Energy],sum([Other Indirect Emissions]) [Other Indirect Emissions] from
	(select  ''E'' as [Item],
		''Base Period Emissions'' as [Description],
	        case when max(left(item,1))=''A'' then sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' else '''' end as [Direct Emissions],
	        case when max(left(item,1))=''B'' then sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' else '''' end as [InDirect Emissions from Purchased Energy],	
	        case when max(left(item,1))=''E'' then sum(SumBaseYearsVol*Co2_conversion_factor)/'+cast(ISNULL(@base_yr_count,1) as varchar)+' else '''' end as [Other Indirect Emissions]	
	from '+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id where left(item,1) in(''A'',''B'',''E'')'+
	case when @report_section = 'A2.A.1' then ' And rg.reduction_type=5251'
	     when @report_section = 'A2.B.1' then ' And rg.reduction_type=5252' else '' end+' 	
	group by left(item,1)

	UNION
	select ''F'' as [Item],
		''Reporting Year Emissions'' as [Description],
	        case when left(item,1)=''A'' then sum(ReportingYearVol*Co2_conversion_factor) else '''' end as [Direct Emissions],
--Uday hardcoding/changes
	        case when left(item,1)=''B'' then sum(case when (a.ext_deal=1) then 1 else Co2_conversion_factor end * ReportingYearVol ) else '''' end as [InDirect Emissions from Purchased Energy],	
	        case when left(item,1)=''E'' then sum(ReportingYearVol*Co2_conversion_factor) else '''' end as [Other Indirect Emissions]	
	from '+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id  
	where left(item,1) in(''A'',''B'',''E'') '+

	case when @report_section = 'A2.A.1' then ' And rg.reduction_type=5251'
	     when @report_section = 'A2.B.1' then ' And (rg.reduction_type=5252 OR a.ext_deal=1)' else '' end+'
	group by left(item,1)) a
	group by [Item],[Description] '	

--print @sql_stmt
exec(@sql_stmt)


if @report_section = 'A2.B.1'
BEGIN
	SELECT a.* FROM ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] and head.[ID]=98
	LEFT JOIN (select 
		[Item],[Description],sum([Direct Emissions]) [Direct Emissions],
		sum([InDirect Emissions from Purchased Energy]) [InDirect Emissions from Purchased Energy],
		sum([Other Indirect Emissions]) [Other Indirect Emissions]
	from 
		#temp_emissions_intensity t group by [Item], [Description]
	UNION
	
	select 
		'G' as Item,'Registered Emission Reductions(E-F)' as [Description],
		sum(case when [item]='F' then -1 else 1 end * [Direct Emissions]) [Direct Emissions],
		sum(case when [item]='F' then -1 else 1 end * [InDirect Emissions from Purchased Energy]) [InDirect Emissions from Purchased Energy],
		sum(case when [item]='F' then -1 else 1 end * [Other Indirect Emissions]) [Other Indirect Emissions]
	from 
		#temp_emissions_intensity 

	UNION

	select 
		'H' as Item,'Reported Emission Reductions(E-F)' as [Description],
		sum(case when [item]='F' then -1 else 1 end * [Direct Emissions]) [Direct Emissions],
		sum(case when [item]='F' then -1 else 1 end * [InDirect Emissions from Purchased Energy]) [InDirect Emissions from Purchased Energy],
		sum(case when [item]='F' then -1 else 1 end * [Other Indirect Emissions]) [Other Indirect Emissions]
	from 
		#temp_emissions_intensity ) a on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.ITEM))
	return		
END


DECLARE @physical_base_value int
DECLARE @economic_base_value int
DECLARE @indexed_base_value int

DECLARE @physical_report_value int
DECLARE @economic_report_value int
DECLARE @indexed_report_value int

select @economic_base_value=ISNULL([base period average],1),@economic_report_value=ISNULL([Reporting Year],1) from #temp_output where [item]='A'
select @physical_base_value=ISNULL([base period average],1),@physical_report_value=ISNULL([Reporting Year],1) from #temp_output where [item]='C'
select @indexed_base_value=ISNULL([base period average],1),@indexed_report_value=ISNULL([Reporting Year],1) from #temp_output where [item]='D'

insert into #temp_emissions_intensity
	select 'G' as [Item],
	'Base Period Intensity' as [Description],
	[Direct Emissions]/@economic_base_value as [Direct Emissions],
	[InDirect Emissions from Purchased Energy]/@physical_base_value as [InDirect Emissions from Purchased Energy],
	[Other Indirect Emissions]/@indexed_base_value as  [Other Indirect Emissions]
from
	#temp_emissions_intensity
where 
	[Item]='E'

------------------------
insert into #temp_emissions_intensity
	select 'H' as [Item],
	'Reporting Year Intensity' as [Description],
	[Direct Emissions]/case when @economic_report_value =0 then 1 else @economic_report_value end  as [Direct Emissions],
	[InDirect Emissions from Purchased Energy]/ case when @physical_report_value =0 then 1 else @physical_report_value end as [InDirect Emissions from Purchased Energy],
	[Other Indirect Emissions]/case when @indexed_report_value =0 then 1 else @indexed_report_value end  as  [Other Indirect Emissions]
from
	#temp_emissions_intensity

where 
	[Item]='F'


insert into #temp_emissions_intensity
	select 'I' as [Item],
	'Emissions Reductions' as [Description],
	SUM((case when [item]='G' then [Direct Emissions] else 0 end-case when [item]='H' then [Direct Emissions] else 0 end))*@economic_report_value,
	SUM((case when [item]='G' then [Direct Emissions] else 0 end-case when [item]='H' then [Direct Emissions] else 0 end))*@physical_report_value,
	SUM((case when [item]='G' then [Direct Emissions] else 0 end-case when [item]='H' then [Direct Emissions] else 0 end))*@indexed_report_value
from
	#temp_emissions_intensity
where 
	[Item] in('G','H') 

	select * from ems_tmp_head head inner join ems_tmp_detail detail on head.[ID]=detail.[ID] LEFT JOIN #temp_emissions_intensity a  on ltrim(rtrim(detail.col1))=ltrim(rtrim(a.ITEM)) 
	where  head.[ID]=89 or head.[ID]=91  or head.[ID]=93

END

ELSE IF @report_section = 'A1.C.1' or @report_section = 'A2.C.1'  or @report_section = 'A3.B.1' or @report_section = 'A8.D.1'
BEGIN


if @report_section = 'A3.B.1'

set @sql='
	select 
		tmp.counterparty_name as [Name of Recipient],
		--sub as [Emission Type],
		co2_curve_desc as [Gas],
		co2_uom_name as [Units],
		abs(SUM(reduction_volume*co2_conversion_factor)) as [Amount]
	from '+@table_name+' tmp inner join rec_generator rg on rg.generator_id=tmp.generator_id
		
	where buy_sell_flag=''s'''	
	+case when @report_section = 'A1.C.1' then ' and rg.reduction_type='+cast(@emissions_intensity as varchar) else '' end
	+case when @report_section = 'A2.C.1' then ' and rg.reduction_type='+cast(@emissions_absolute as varchar) else '' end
	+case when @report_section = 'A3.B.1' then ' and rg.reduction_type='+cast(@emissions_carbon_storage as varchar) else '' end
	+case when @report_section = 'A8.D.1' then ' and rg.reduction_type='+cast(@action_specific as varchar) +'
						     and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar) else '' end
	+' Group By
		tmp.counterparty_name,sub,Gas,co2_curve_desc,co2_uom_name
'
else
set @sql='
	select 
		tmp.counterparty_name as [Name of Recipient],
		sub as [Emission Type],
		co2_curve_desc as [Gas],
		co2_uom_name as [Units],
		abs(SUM(reduction_volume*co2_conversion_factor)) as [Amount]
	from '+@table_name+' tmp inner join rec_generator rg on rg.generator_id=tmp.generator_id
		
	where buy_sell_flag=''s'''	
	+case when @report_section = 'A1.C.1' then ' and rg.reduction_type='+cast(@emissions_intensity as varchar) else '' end
	+case when @report_section = 'A2.C.1' then ' and rg.reduction_type='+cast(@emissions_absolute as varchar) else '' end
	+case when @report_section = 'A3.B.1' then ' and rg.reduction_type='+cast(@emissions_carbon_storage as varchar) else '' end
	+case when @report_section = 'A8.D.1' then ' and rg.reduction_type='+cast(@action_specific as varchar) +'
						     and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar) else '' end
	+' Group By
		tmp.counterparty_name,sub,Gas,co2_curve_desc,co2_uom_name
'


exec(@sql)		

END

END

--##### Addendum A3 Changes in Carbon Storage
-- Part A3.1 Terrestrial Carbon Flux

If @report_section = 'A3.A.1'
BEGIN
set @sql_stmt='	select 	
		case when group2_id='+cast(@forest_activities as varchar)+' then ''A''
		     when group2_id='+cast(@wood_products as varchar)+' then ''B''
		     when group2_id='+cast(@wood_products as varchar)+' then ''C''
		     when group2_id='+cast(@land_restoration as varchar)+' then ''D''
		     when group2_id='+cast(@sustainable_forest as varchar)+' then ''E''
		     when group2_id='+cast(@land_restoration as varchar)+' then ''F''
		     when group2_id='+cast(@other_terestrial_carbon_flux as varchar)+' then ''G''	
		else '''' end as [Item],
 		Group2 Categories, 
		co2_uom_name as [Units of Measure], 
		sum(ReportingYearVol*Co2_conversion_factor) [Reporting Year Stock Change or Carbon Flux]
from '+@table_name+'
	where  isnull(source_deal_header_id,'''') ='''' 
	and group1_id='+cast(@carbon_flux_id as varchar)+'
	group by Item, Group2,co2_curve_desc, co2_uom_name,group2_id
UNION
select 
	''H'' as [Item],
	''Total Reporting Year Terrestrial Carbon Flux'',
	co2_uom_name, 
	sum(ReportingYearVol*Co2_conversion_factor) [Reporting Year Stock Change or Carbon Flux]
from '+@table_name+'
	where  isnull(source_deal_header_id,'''') ='''' 
	and group1_id='+cast(@carbon_flux_id as varchar)+'
	group by co2_uom_name
'

--print @sql_stmt
exec(@sql_stmt)

END	

--##### Addendum A4 Geoligical Sequestrationj
-- Part A8.A.1 Action Identification

If @report_section = 'A8.A.1'
BEGIN
set @sql_stmt='
select
	rg.name as [Name],
	rg.city_value_id as [City],
	state.[description] as [State],
	country.[description] as [Country]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join static_data_value state on state.value_id=rg.gen_state_value_id
	left join static_data_value country on country.value_id=rg.gen_state_value_id
where
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg.name,rg.city_value_id,state.description,country.[description]
'

--print @sql_stmt
exec(@sql_stmt)

END


--## Part A8.B.1 Action Quantification
--Enter Source of Carbon Dioxide Sequestered in Current Reporting Year (metric tons CO2e)
If @report_section = 'A8.B.1'
BEGIN

set @sql_stmt='
select
	''A'' as [Item],	
	rg1.name,
	rg1.city_value_id as [City],
	sum(reduction_volume) as [CO2 Extracted/Captured],
	sum(b.volume) as [CO2 Acquired Via Transfer or Purchase], 
	ISNULL(sum(reduction_volume),0)+isnull(sum(b.volume),0) as [Total CO2 Captured or Acquired],
	rg.name as [Name of Storage Site]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
	left join rec_generator rg1 on rg1.generator_id=rg.CO2_captured_for_generator_id
where
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg1.name,rg1.city_value_id,rg.name 
UNION
select
	''F'' as [Item],	
	''Total(sum of Items)'',
	NULL as [City],
	sum(reduction_volume) as [CO2 Extracted/Captured],
	sum(b.volume) as [CO2 Acquired Via Transfer or Purchase], 
	ISNULL(sum(reduction_volume),0)+isnull(sum(b.volume),0) as [Total CO2 Captured or Acquired],
	NULL as [Name of Storage Site]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
	left join rec_generator rg1 on rg1.generator_id=rg.CO2_captured_for_generator_id
where
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)

--print @sql_stmt
exec(@sql_stmt)
END

--## Part A8.B.1 Action Quantification
--Enter Amount Sequestered in Current Reporting Year (metric tons CO2e)
If @report_section = 'A8.B.2'
BEGIN
set @sql_stmt='
select
	''G'' as [Item],	
	rg.name,
	rg.city_value_id as [Location of Storage Site],
	''Yes'' as [Enhanced Resource Recovery],
	sum(ReportingYearVol) as [CO2 Injected in Current Reporting Year], 
	NULL as [Monitoring Method],
	abs(sum(ReportingYearVol)-sum(reduction_volume)) as [Quantity],
	sum(reduction_volume) as [Total CO2 Sequestered in Current Reporting Year]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
	
where	rg.mandatory=''y'' and
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg.name,rg.city_value_id

UNION
select
	''J'' as [Item],	
	rg.name,
	rg.city_value_id as [Location of Storage Site],
	''Yes'' as [Enhanced Resource Recovery],
	abs(sum(ReportingYearVol)) as [CO2 Injected in Current Reporting Year], 
	NULL as [Monitoring Method],
	sum(ReportingYearVol)+sum(reduction_volume) as [Quantity],
	sum(reduction_volume) as [Total CO2 Sequestered in Current Reporting Year]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
where	rg.mandatory<>''y'' and
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg.name,rg.city_value_id '

--print @sql_stmt
exec(@sql_stmt)
END

--- ## Enter Amount Sequestered in Base Year (metric tons CO2e)

If @report_section = 'A8.B.3'
BEGIN
set @sql_stmt='
select
	''G'' as [Item],	
	rg.name,
	rg.city_value_id as [Location of Storage Site],
	''Yes'' as [Enhanced Resource Recovery],
	sum(SumBaseYearsVol) as [Amount Injected in Base Year], 
	NULL as [Monitoring Method],
	sum(SumBaseYearsVol) as [Quantity],
	sum(SumBaseYearsVol) as [Total CO2 Sequestered in Base Year]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
	
where	rg.mandatory=''y'' and
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg.name,rg.city_value_id

UNION
select
	''J'' as [Item],	
	rg.name,
	rg.city_value_id as [Location of Storage Site],
	''Yes'' as [Enhanced Resource Recovery],
	sum(SumBaseYearsVol) as [Amount Injected in Base Year], 
	NULL as [Monitoring Method],
	sum(SumBaseYearsVol) as [Quantity],
	sum(SumBaseYearsVol) as [Total CO2 Sequestered in Current Reporting Year]
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
where	rg.mandatory<>''y'' and
	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg.name,rg.city_value_id '

--print @sql_stmt
exec(@sql_stmt)
END

--- ## PART C -- Emissions Reductions 
If @report_section = 'A8.C.1'
BEGIN
set @sql_stmt='
select
	''U'' as [Item],	
	''Emission Reductions(M7-T7)'' as [Descriptions],
	''Metrics Tons CO2e'' as [Unit of Measure],
	abs((sum(ReportingYearVol)-sum(SumBaseYearsVol))*max(co2_conversion_factor)) as Quantity
from
	'+@table_name+' a inner join rec_generator rg on a.generator_id=rg.generator_id
	left join (select generator_id,sum(reduction_volume) volume from '+@table_name+' where buy_sell_flag=''s'' group by generator_id) b
	on a.generator_id=b.generator_id
	
where	rg.reduction_type='+cast(@action_specific as varchar) +'
	and rg.reduction_sub_type='+cast(@geo_seq_reduc as varchar)
+' group by rg.name,rg.city_value_id '

EXEC(@sql_stmt)
END






