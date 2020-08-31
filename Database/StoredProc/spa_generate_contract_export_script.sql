
if object_id('spa_generate_contract_export_script') is not null
drop proc dbo.spa_generate_contract_export_script
go

create proc dbo.spa_generate_contract_export_script 
	@contract_ids varchar(max)=null
	,@destination_db varchar(1000)=null
as

 --Note:
--Every export table will have a identity column
--Primary key is always identity column
--Join Columns in source table are always original value and will not update by new value
-- Reference columns that not in join column need to be updated into new value in source table before export. Hence, first the sp dbo.spa_export_table_scripter is called by passing argument value  @export_lebel=1 and then update reference columns into new value in source table. After that again need to call  dbo.spa_export_table_scripter  by passing argument value  @export_lebel=2 
-- Or need to call dbo.spa_export_table_scripter twice if there are reference columns need to be resolve.


/*

declare @contract_ids varchar(max)=455
,@destination_db varchar(1000)='SettlementTracker_Master_Eneco_export'

--*/
/*
select * from contract_group
select * from contract_group_detail


select * from formula_editor_parameter
select * from formula_breakdown

--select * from contract_group

*/


if object_id('tempdb..#calendar') is not null
  drop table  #calendar

if OBJECT_ID('tempdb..#list_contracts') is not null
drop table #list_contracts

if OBJECT_ID('tempdb..#arg_referrence_ids') is not null
drop table #arg_referrence_ids

if OBJECT_ID('tempdb..#arg_ref_ids') is not null
drop table #arg_ref_ids

if OBJECT_ID('tempdb..#source_curve_def_id') is not null
drop table #source_curve_def_id

if OBJECT_ID('tempdb..#formula_list') is not null
drop table #formula_list

if OBJECT_ID('tempdb..#list_contract_charge_type') is not null
drop table #list_contract_charge_type

if OBJECT_ID('tempdb..#meter_id') is not null
drop table #meter_id

if OBJECT_ID('tempdb..#static_data_value_id') is not null
drop table #static_data_value_id

if OBJECT_ID('tempdb..#currency_id') is not null
drop table #currency_id

if OBJECT_ID('tempdb..#uom_id') is not null
drop table #uom_id



create table #list_contracts (contract_id int)

if @contract_ids is not null
	insert into #list_contracts (contract_id )
	select scsv.item from dbo.SplitCommaSeperatedValues(@contract_ids) scsv 
else
	insert into #list_contracts (contract_id )
	select contract_id from dbo.contract_group

/*

	select * from formula_editor_parameter

	select * from formula_breakdown


*/



declare @st varchar(max)

create table #arg_referrence_ids (arg_referrence_field_value_id int,referrence_id int,sequence int)


select  --contract_charge_type_id,* 
	settlement_calendar calendar_id into #calendar	
 from contract_group_detail cgd inner join  #list_contracts lc on cgd.contract_id=lc.contract_id  where  settlement_calendar is not null
union 
select pnl_calendar	 from contract_group  cgd inner join  #list_contracts lc on cgd.contract_id=lc.contract_id where  pnl_calendar is not null
union 
select payment_calendar	 from contract_group  cgd inner join  #list_contracts lc on cgd.contract_id=lc.contract_id where  payment_calendar is not null
union 
select holiday_calendar_id 	 from contract_group  cgd inner join  #list_contracts lc on cgd.contract_id=lc.contract_id  where  holiday_calendar_id is not null



create table #list_contract_charge_type (contract_charge_type_id int)

insert into #list_contract_charge_type (contract_charge_type_id )
select distinct contract_charge_type_id  from contract_group cct inner join #list_contracts fl on cct.contract_id=fl.contract_id where contract_charge_type_id is not null
union
select distinct contract_template from contract_group_detail cct inner join #list_contracts fl on cct.contract_id=fl.contract_id where contract_template is not null


create table #static_data_value_id (value_id int)

create table #uom_id (uom_id int)
create table #currency_id (currency_id int)


--select * from #static_data_value_id where type_id=10019
insert into  #static_data_value_id (value_id )
select distinct * from (
select  cct_d.invoice_line_item_id from #list_contract_charge_type cct inner join contract_charge_type_detail  cct_d 
	on  cct.contract_charge_type_id=cct_d.contract_charge_type_id and cct_d.invoice_line_item_id is not null
union
select  cct_d.true_up_charge_type_id from #list_contract_charge_type cct inner join contract_charge_type_detail  cct_d 
	on  cct.contract_charge_type_id=cct_d.contract_charge_type_id and cct_d.true_up_charge_type_id is not null
union
select  cct_d.alias from #list_contract_charge_type cct inner join contract_charge_type_detail  cct_d 
	on  cct.contract_charge_type_id=cct_d.contract_charge_type_id and cct_d.alias is not null	
	
) a

insert into  #static_data_value_id (value_id )
select distinct cgd.invoice_line_item_id from contract_group_detail cgd inner join #list_contracts fl on cgd.contract_id=fl.contract_id and invoice_line_item_id is not null
left join #static_data_value_id sdv on sdv.value_id=cgd.invoice_line_item_id
where sdv.value_id is null 



insert into  #static_data_value_id (value_id )
select distinct cgd.true_up_charge_type_id from contract_group_detail cgd inner join #list_contracts fl on cgd.contract_id=fl.contract_id and cgd.true_up_charge_type_id is not null
left join #static_data_value_id sdv on sdv.value_id=cgd.true_up_charge_type_id
where sdv.value_id is null 

insert into  #static_data_value_id (value_id )
select distinct cgd.alias from contract_group_detail cgd inner join #list_contracts fl on cgd.contract_id=fl.contract_id and cgd.alias is not null
left join #static_data_value_id sdv on sdv.value_id=cgd.alias
where sdv.value_id is null 



insert into  #static_data_value_id (value_id )
select distinct uddft.field_id from maintain_udf_static_data_detail_values cgd inner join #list_contracts fl on cgd.primary_field_object_id=fl.contract_id
inner join dbo.application_ui_template_fields autf on autf.application_field_id =cgd.application_field_id
inner join dbo.user_defined_fields_template  uddft on uddft.udf_template_id= autf.udf_template_id
left join #static_data_value_id sdv on sdv.value_id= cgd.primary_field_object_id
where sdv.value_id is null 



create table #formula_list (formula_id int)

insert into #formula_list (formula_id )
select formula_id from contract_group_detail cgd inner join #list_contracts lc on cgd.contract_id=lc.contract_id and cgd.formula_id is not null
union 
select  cct_d.formula_id from #list_contract_charge_type cct inner join contract_charge_type_detail  cct_d 
	on  cct.contract_charge_type_id=cct_d.contract_charge_type_id and cct_d.formula_id is not null


insert into #formula_list (formula_id )
select fn.formula_id from formula_nested fn inner join #formula_list fl on fn.formula_group_id=fl.formula_id
left join #formula_list f on f.formula_id=fn.formula_id
where f.formula_id is null 



-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------Start: Extract reference id from fromula-------------------------------------------------------------------------------------------------------

select fb.formula_breakdown_id,fb.formula_id,p.func_name,p.arg_referrence_field_value_id,p.sequence into #arg_ref_ids 
from #formula_list f
inner join dbo.formula_breakdown fb on	 fb.formula_id=f.formula_id
cross apply
( 
	select fep.function_name func_name,fep.arg_referrence_field_value_id,fep.sequence 
	FROM dbo.formula_editor_parameter fep
	where fep.function_name = fb.func_name
	AND fep.arg_referrence_field_value_id is not null    
 )  p


if @@ROWCOUNT>0
begin
	insert into #arg_referrence_ids (arg_referrence_field_value_id,sequence,referrence_id)
	select distinct ari.arg_referrence_field_value_id,ari.sequence,
		case  ari.sequence 
			when 1 then fb.arg1
			when 2 then fb.arg2
			when 3 then fb.arg3
			when 4 then fb.arg4
			when 5 then fb.arg5
			when 6 then fb.arg6
			when 7 then fb.arg7
			when 8 then fb.arg8
			when 9 then fb.arg9
			when 10 then fb.arg10
			when 11 then fb.arg11
			when 12 then fb.arg12
			when 13 then fb.arg13
			when 14 then fb.arg14
			when 15 then fb.arg15
			when 16 then fb.arg16
			when 17 then fb.arg17
			when 18 then fb.arg18
		end
	from #arg_ref_ids ari 
	inner join dbo.formula_breakdown fb on fb.formula_breakdown_id=ari.formula_breakdown_id

 end
 

---extract: Curve ID
create table #source_curve_def_id (source_curve_def_id int)

set @st='
insert into #source_curve_def_id(source_curve_def_id)
select spcd.source_curve_def_id 
FROM [dbo].[source_price_curve_def] spcd '
 +case when exists(select * from #arg_ref_ids where arg_referrence_field_value_id=40000) then
	 ' inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000' else ' where 1=2 '
end
+ case when exists(select * from #arg_ref_ids where arg_referrence_field_value_id=40000) then
		'
		union 
		select spcd.[proxy_curve_id3]
		FROM [dbo].[source_price_curve_def] spcd 
			inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000
		where [proxy_curve_id3] is not null
		union 
		select spcd.[proxy_source_curve_def_id]
		FROM [dbo].[source_price_curve_def] spcd 
		 inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000
		 where [proxy_source_curve_def_id] is not null
		union 
		select spcd.[settlement_curve_id]
		FROM [dbo].[source_price_curve_def] spcd  inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000
		 where [settlement_curve_id] is not null
		union 
		select spcd.[reference_curve_id]
		FROM [dbo].[source_price_curve_def] spcd 
			inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000
		where [reference_curve_id] is not null
		union 
		select spcd.[proxy_curve_id]
		FROM [dbo].[source_price_curve_def] spcd 
			inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000
		where [proxy_curve_id] is not null
		union 
		select spcd.[monthly_index]
		FROM [dbo].[source_price_curve_def] spcd 
			inner join #arg_referrence_ids ari on spcd.source_curve_def_id=ari.referrence_id and ari.arg_referrence_field_value_id=40000
		where [monthly_index] is not null'
	else ''
end

EXEC spa_print @st
exec(@st)
---Extract: meter id

create table #meter_id (meter_id int)

insert into #meter_id (meter_id)
select distinct ar.referrence_id from #arg_referrence_ids  ar left join #meter_id mi on ar.referrence_id=mi.meter_id
 where ar.arg_referrence_field_value_id=40002 and ISNUMERIC(ar.referrence_id)=1 and referrence_id is not null  and mi.meter_id is null

---Extract: value_id
insert into #static_data_value_id (value_id )
select distinct referrence_id from #arg_referrence_ids ar left join #static_data_value_id sdv on ar.referrence_id=sdv.value_id
 where arg_referrence_field_value_id=40003 and ISNUMERIC(referrence_id)=1 and referrence_id is not null and sdv.value_id is null

---Extract: uom
insert into #uom_id (uom_id )
select volume_uom	 from contract_group  cgd inner join  #list_contracts lc on cgd.contract_id=lc.contract_id where  volume_uom is not null

---Extract: currency
insert into #currency_id (currency_id )
select currency	 from contract_group  cgd inner join  #list_contracts lc on cgd.contract_id=lc.contract_id where  currency is not null

 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------end: Extract reference id from fromula-------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
----start script generating-----------------------------------------

if OBJECT_ID('tempdb..#query_result') is null
	create table #query_result (rowid int identity(1,1),query_result varchar(max) COLLATE DATABASE_DEFAULT )
else 
	truncate table #query_result


insert into #query_result (query_result)
select '
----Script Generation Time:'+convert(varchar(100),getdate(),120)+'; Database:'+db_name(DB_ID())

if @destination_db is not null
	insert into #query_result (query_result)
	select 'USE '+@destination_db

insert into #query_result (query_result)
select 
	'
	if object_id(''tempdb..#dst_arg_referrence_ids'') is not null drop table #dst_arg_referrence_ids;
	if object_id(''tempdb..#dst_arg_ref_ids'') is not null drop table #dst_arg_ref_ids;
'

insert into #query_result (query_result)
select '
BEGIN TRY
BEGIN TRAN
'

insert into #query_result (query_result)
select '
if object_id(''tempdb..#old_new_id'') is not null
drop table #old_new_id

create table #old_new_id(tran_type varchar(1) COLLATE DATABASE_DEFAULT ,table_name varchar(250) COLLATE DATABASE_DEFAULT ,new_id int,old_id int,unique_key1 varchar(250) COLLATE DATABASE_DEFAULT ,unique_key2 varchar(250) COLLATE DATABASE_DEFAULT ,unique_key3 varchar(250) COLLATE DATABASE_DEFAULT ); '


-----------------------------------------------------------------------------------------------------------------
---------------------------------Start Sysnc Reference Table For Contranct------------------------------- 
 


exec dbo.spa_export_table_scripter @tbl_name ='static_data_value'
	,@filter =' inner join #static_data_value_id flt on flt.value_id=src.value_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='code'
	,@primary_key_column2 ='type_id'
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0

	
exec dbo.spa_export_table_scripter @tbl_name ='source_uom'
	,@filter =' inner join #uom_id flt on flt.uom_id=src.source_uom_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='uom_id'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0	
	
exec dbo.spa_export_table_scripter @tbl_name ='source_currency'
	,@filter =' inner join #currency_id flt on flt.currency_id=src.source_currency_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='currency_id'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0	
	
exec dbo.spa_export_table_scripter @tbl_name ='holiday_group'
	,@filter =' inner join #calendar flt on flt.calendar_id=src.hol_group_value_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='hol_group_value_id'
	,@primary_key_column2 ='hol_date'
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0


exec dbo.spa_export_table_scripter @tbl_name ='source_price_curve_def'
	,@filter =' inner join #source_curve_def_id id on src.source_curve_def_id=id.source_curve_def_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='curve_id'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0

exec dbo.spa_export_table_scripter @tbl_name ='meter_id'
	,@filter =' inner join #meter_id id on src.meter_id=id.meter_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='recorderid'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0

exec dbo.spa_export_table_scripter @tbl_name ='formula_editor'
	,@filter =' inner join #formula_list fl on src.formula_id=fl.formula_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='formula_name'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0

--generate export data script(insert into #formula_nested values ...) from source table formula_nested.
exec dbo.spa_export_table_scripter @tbl_name ='formula_nested'
	,@filter =' inner join #formula_list fl on src.formula_id=fl.formula_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='formula_group_id'
	,@primary_key_column2 ='sequence_order'
	,@primary_key_column3 =null
	,@master_table_name ='formula_editor' 
	,@join_column_name_master ='formula_id' 
	,@join_column_name_child  ='formula_group_id' 
	,@primary_key_column1_master ='formula_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1


--update reference column from master table into export table #formula_nested
insert into #query_result (query_result)
select
'
update #formula_nested set formula_id=f.new_recid
from #formula_nested m inner join #formula_editor f on m.formula_id=f.formula_id

--update #formula_nested set formula_group_id=f.new_recid
--from #formula_nested m inner join #formula_editor f on m.formula_group_id=f.formula_id
'
--generate script for update and insert into destination table.
exec dbo.spa_export_table_scripter @tbl_name ='formula_nested'
	,@filter =' inner join #formula_list fl on src.formula_id=fl.formula_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='formula_group_id'
	,@primary_key_column2 ='sequence_order'
	,@primary_key_column3 =null
	,@master_table_name ='formula_editor' 
	,@join_column_name_master ='formula_id' 
	,@join_column_name_child  ='formula_group_id' 
	,@primary_key_column1_master ='formula_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2

	
--update #formula_nested set formula_group_id=f.new_recid
--from #formula_nested m inner join #formula_editor f on m.formula_group_id=f.formula_id	
	
--generate export data script(insert into #formula_editor_sql values ...) from source table formula_editor_sql.
exec dbo.spa_export_table_scripter @tbl_name ='formula_editor_sql'
	,@filter =' inner join #formula_list fl on src.formula_id=fl.formula_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='formula_id'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name ='formula_editor' 
	,@join_column_name_master ='formula_id' 
	,@join_column_name_child  ='formula_id' 
	,@primary_key_column1_master ='formula_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0



exec dbo.spa_export_table_scripter @tbl_name ='formula_breakdown'
	,@filter =' inner join #formula_list fl on src.formula_id=fl.formula_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='formula_id'
	,@primary_key_column2 ='nested_id'
	,@primary_key_column3 ='level_func_sno'
	,@master_table_name ='formula_editor' 
	,@join_column_name_master ='formula_id' 
	,@join_column_name_child  ='formula_id' 
	,@primary_key_column1_master ='formula_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1

insert into #query_result (query_result)
select
'
update #formula_breakdown set formula_nested_id=f.new_recid
from #formula_breakdown m inner join #formula_editor f on m.formula_nested_id=f.formula_id
'


----------------------------------------Star Process formula manipulation---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
insert into #query_result (query_result)
select
'
create table #dst_arg_referrence_ids (formula_breakdown_id int,arg_referrence_field_value_id int,referrence_id int,sequence int)

select fb.formula_breakdown_id,fb.formula_id,p.func_name,p.arg_referrence_field_value_id,p.sequence into #dst_arg_ref_ids 
from #formula_editor f
inner join #formula_breakdown fb on	 fb.formula_id=f.formula_id
cross apply
( 
	select fep.function_name func_name,fep.arg_referrence_field_value_id,fep.sequence 
	FROM dbo.formula_editor_parameter fep
	where fep.function_name = fb.func_name
	AND fep.arg_referrence_field_value_id is not null    
 )  p;
 '
insert into #query_result (query_result)
select
'
if @@ROWCOUNT>0
begin
	insert into #dst_arg_referrence_ids (formula_breakdown_id,arg_referrence_field_value_id,sequence,referrence_id)
	select distinct fb.formula_breakdown_id,ari.arg_referrence_field_value_id,ari.sequence,
		case  ari.sequence 
			when 1 then fb.arg1
			when 2 then fb.arg2
			when 3 then fb.arg3
			when 4 then fb.arg4
			when 5 then fb.arg5
			when 6 then fb.arg6
			when 7 then fb.arg7
			when 8 then fb.arg8
			when 9 then fb.arg9
			when 10 then fb.arg10
			when 11 then fb.arg11
			when 12 then fb.arg12
			when 13 then fb.arg13
			when 14 then fb.arg14
			when 15 then fb.arg15
			when 16 then fb.arg16
			when 17 then fb.arg17
			when 18 then fb.arg18
		end
	from #dst_arg_ref_ids ari 
	inner join #formula_breakdown fb on fb.formula_breakdown_id=ari.formula_breakdown_id

 end
'


insert into #query_result (query_result)
select
'
declare @arg_referrence_field_value_id int,@sequence int,@sql varchar(max)

DECLARE db_cursor CURSOR FOR  
	select DISTINCT arg_referrence_field_value_id,sequence from #dst_arg_referrence_ids
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @arg_referrence_field_value_id,@sequence
WHILE @@FETCH_STATUS = 0   
BEGIN   
		set @sql=''update #formula_breakdown set arg''+cast(@sequence as varchar)+ ''=src.new_recid
		from #formula_breakdown fb inner join #dst_arg_referrence_ids ari on isnumeric(fb.arg''+cast(@sequence as varchar)+'')=1 
			and fb.arg''+cast(@sequence as varchar)+''=round(fb.arg''+cast(@sequence as varchar)+'',0) and fb.formula_breakdown_id=ari.formula_breakdown_id 
			and ari.arg_referrence_field_value_id=''+cast(@arg_referrence_field_value_id as varchar)+''
			inner join ''+case @arg_referrence_field_value_id
							when 40000 then ''#source_price_curve_def src on src.source_curve_def_id=fb.arg''+cast(@sequence as varchar)
							when 40001 then ''#source_counterparty src on src.source_counterparty_id=fb.arg''+cast(@sequence as varchar)
							when 40002 then ''#meter_id src on src.meter_id=fb.arg''+cast(@sequence as varchar)
							when 40003 then ''#static_data_value src on src.value_id=fb.arg''+cast(@sequence as varchar)
						end
		EXEC spa_print @sql
		exec(@sql)

       FETCH NEXT FROM db_cursor INTO @arg_referrence_field_value_id,@sequence    
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

'


exec dbo.spa_export_table_scripter @tbl_name ='formula_breakdown'
	,@filter =' inner join #formula_list fl on src.formula_id=fl.formula_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='formula_id'
	,@primary_key_column2 ='nested_id'
	,@primary_key_column3 ='level_func_sno'
	,@master_table_name ='formula_editor' 
	,@join_column_name_master ='formula_id' 
	,@join_column_name_child  ='formula_id' 
	,@primary_key_column1_master ='formula_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2



--building formula and update formula editor

insert into #query_result (query_result)
select
'
alter table #formula_editor add old_formula varchar(max);
exec(''update #formula_editor set old_formula=formula'') ; 
'


insert into #query_result (query_result)
select
'
exec [spa_rebuild_formula_content];

update formula_editor set formula=replace(src.formula ,''parenthesis'','''')
from formula_editor dst inner join #formula_editor src on dst.formula_id=src.new_recid ; '


----------------------------------------End Process formula manupulation---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


exec dbo.spa_export_table_scripter @tbl_name ='contract_charge_type'
	,@filter =' inner join #list_contract_charge_type fl on src.contract_charge_type_id=fl.contract_charge_type_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='contract_charge_desc'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=0


exec dbo.spa_export_table_scripter @tbl_name ='contract_charge_type_detail'
	,@filter =' inner join #list_contract_charge_type fl on src.contract_charge_type_id=fl.contract_charge_type_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='contract_charge_type_id'
	,@primary_key_column2 ='invoice_line_item_id'
	,@primary_key_column3 =null
	,@master_table_name ='contract_charge_type' 
	,@join_column_name_master ='contract_charge_type_id' 
	,@join_column_name_child  ='contract_charge_type_id' 
	,@primary_key_column1_master ='contract_charge_desc'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1

insert into #query_result (query_result)
select
'
update #contract_charge_type_detail set formula_id=f.new_recid
from #contract_charge_type_detail m inner join #formula_editor f on m.formula_id=f.formula_id

--update #contract_charge_type_detail set invoice_line_item_id=f.new_recid
--from #contract_charge_type_detail m inner join #static_data_value f on m.invoice_line_item_id=f.value_id


update #contract_charge_type_detail set true_up_charge_type_id=f.new_recid
from #contract_charge_type_detail m inner join #static_data_value f on m.true_up_charge_type_id=f.value_id

update #contract_charge_type_detail set alias=f.new_recid
from #contract_charge_type_detail m inner join #static_data_value f on m.alias=f.value_id

'

exec dbo.spa_export_table_scripter @tbl_name ='contract_charge_type_detail'
	,@filter =' inner join #list_contract_charge_type fl on src.contract_charge_type_id=fl.contract_charge_type_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='contract_charge_type_id'
	,@primary_key_column2 ='invoice_line_item_id'
	,@primary_key_column3 =null
	,@master_table_name ='contract_charge_type' 
	,@join_column_name_master ='contract_charge_type_id' 
	,@join_column_name_child  ='contract_charge_type_id' 
	,@primary_key_column1_master ='contract_charge_desc'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2
---------------------------------End Sysnc Reference Table For Contranct------------------------------- 
-----------------------------------------------------------------------------------------------------------------



----#old_new_id(table_name,new_id,unique_key1,unique_key2,unique_key3)



----------------------------------------Start Contract export process---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

exec dbo.spa_export_table_scripter @tbl_name ='contract_group'
	,@filter =' inner join #list_contracts fl on src.contract_id=fl.contract_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='source_contract_id'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1

exec dbo.spa_export_table_scripter @tbl_name ='contract_group_detail'
	,@filter =' inner join #list_contracts fl on src.contract_id=fl.contract_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'contract_id'
	,@primary_key_column2  ='invoice_line_item_id'
	,@primary_key_column3 =null
	,@master_table_name ='contract_group' --the name should provide for child table's script is generating 
	,@join_column_name_master ='contract_id' 
	,@join_column_name_child  ='contract_id' 
	,@primary_key_column1_master ='source_contract_id'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1


--update reference_id that is of contract_group_detail
insert into #query_result (query_result)
select
'
update #contract_group set contract_charge_type_id=f.new_recid
from #contract_group m inner join #contract_charge_type f on m.contract_charge_type_id=f.contract_charge_type_id

update #contract_group set volume_uom=f.new_recid
from #contract_group m inner join #source_uom f on m.volume_uom=f.source_uom_id

update #contract_group set currency=f.new_recid
from #contract_group m inner join #source_currency f on m.currency=f.source_currency_id

update #contract_group_detail set contract_component_template=f.new_recid
from #contract_group_detail m inner join #contract_charge_type_detail f on m.contract_template=f.contract_charge_type_id
	and m.contract_component_template=f.id  

update #contract_group_detail set contract_template=f.new_recid
from #contract_group_detail m inner join #contract_charge_type f on m.contract_template=f.contract_charge_type_id

update #contract_group_detail set formula_id=f.new_recid
from #contract_group_detail m inner join #formula_editor f on m.formula_id=f.formula_id

--update #contract_group_detail set invoice_line_item_id=f.new_recid
--from #contract_group_detail m inner join #static_data_value f on m.invoice_line_item_id=f.value_id

update #contract_group_detail set true_up_charge_type_id=f.new_recid
from #contract_group_detail m inner join #static_data_value f on m.true_up_charge_type_id=f.value_id

update #contract_group_detail set alias=f.new_recid
from #contract_group_detail m inner join #static_data_value f on m.alias=f.value_id


'

exec dbo.spa_export_table_scripter @tbl_name ='contract_group'
	,@filter =' inner join #list_contracts fl on src.contract_id=fl.contract_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1  ='source_contract_id'
	,@primary_key_column2 =null
	,@primary_key_column3 =null
	,@master_table_name =null 
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2

exec dbo.spa_export_table_scripter @tbl_name ='contract_group_detail'
	,@filter =' inner join #list_contracts fl on src.contract_id=fl.contract_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'contract_id'
	,@primary_key_column2  ='invoice_line_item_id'
	,@primary_key_column3 =null
	,@master_table_name ='contract_group' --the name should provide for child table's script is generating 
	,@join_column_name_master ='contract_id' 
	,@join_column_name_child  ='contract_id' 
	,@primary_key_column1_master ='source_contract_id'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2



--export udf contract
/*
exec dbo.spa_export_table_scripter @tbl_name ='maintain_udf_static_data_detail_values'
	,@filter =' inner join #list_contracts fl on src.primary_field_object_id=fl.contract_id'  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'primary_field_object_id'
	,@primary_key_column2  ='application_field_id'
	,@primary_key_column3 =null
	,@master_table_name ='contract_group' --the name should provide for child table's script is generating 
	,@join_column_name_master ='contract_id' 
	,@join_column_name_child  ='primary_field_object_id' 
	,@primary_key_column1_master ='source_contract_id'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=null


exec dbo.spa_export_table_scripter @tbl_name ='user_defined_fields_template'
	,@filter =' inner join #static_data_value_id a on a.value_id= src.field_id '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'field_id'
	,@primary_key_column2  =null
	,@primary_key_column3 =null
	,@master_table_name ='static_data_value' --the name should provide for child table's script is generating 
	,@join_column_name_master ='value_id' 
	,@join_column_name_child  ='field_id' 
	,@primary_key_column1_master ='code'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=null



exec dbo.spa_export_table_scripter @tbl_name ='adiha_grid_definition'
	,@filter =' cross apply (select top(1) ud.* from maintain_udf_static_data_detail_values ud inner join application_ui_template_fields atf on ud.application_field_id= atf.application_field_id inner join application_ui_template_group g on g.application_group_id=atf.application_group_id and g.application_grid_id=src.grid_id inner join #list_contracts fl on ud.primary_field_object_id=fl.contract_id) a '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'grid_name'
	,@primary_key_column2  =null
	,@primary_key_column3 =null
	,@master_table_name =null
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=null

exec dbo.spa_export_table_scripter @tbl_name ='application_ui_template'
	,@filter =' cross apply (select top(1) ud.* from maintain_udf_static_data_detail_values ud inner join application_ui_template_fields atf on ud.application_field_id= atf.application_field_id inner join application_ui_template_group g on g.application_ui_template_id=src.application_ui_template_id and atf.application_group_id=g.application_group_id inner join #list_contracts fl on ud.primary_field_object_id=fl.contract_id) a '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'template_name'
	,@primary_key_column2  =null
	,@primary_key_column3 =null
	,@master_table_name =null
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=null


exec dbo.spa_export_table_scripter @tbl_name ='application_ui_template_group'
	,@filter =' cross apply (select top(1) ud.* from maintain_udf_static_data_detail_values ud inner join application_ui_template_fields atf on ud.application_field_id= atf.application_field_id and atf.application_group_id=src.application_group_id inner join #list_contracts fl on ud.primary_field_object_id=fl.contract_id) a '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'application_ui_template_id'
	,@primary_key_column2  ='group_name'
	,@primary_key_column3 =null
	,@master_table_name ='application_ui_template'
	,@join_column_name_master ='application_ui_template_id' 
	,@join_column_name_child  ='application_ui_template_id' 
	,@primary_key_column1_master = 'template_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1




--update reference_id that is of contract_group_detail
insert into #query_result (query_result)
select
'
update #application_ui_template_group set application_grid_id=f.new_recid
from #application_ui_template_group m inner join #adiha_grid_definition f on m.application_grid_id=f.grid_id

'


exec dbo.spa_export_table_scripter @tbl_name ='application_ui_template_group'
	,@filter =' cross apply (select top(1) ud.* from maintain_udf_static_data_detail_values ud inner join application_ui_template_fields atf on ud.application_field_id= atf.application_field_id and atf.application_group_id=src.application_group_id inner join #list_contracts fl on ud.primary_field_object_id=fl.contract_id) a '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'application_ui_template_id'
	,@primary_key_column2  ='group_name'
	,@primary_key_column3 =null
	,@master_table_name ='application_ui_template'
	,@join_column_name_master ='application_ui_template_id' 
	,@join_column_name_child  ='application_ui_template_id' 
	,@primary_key_column1_master = 'template_name'
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2




	--select src.* from application_ui_template_group src inner join application_ui_template_fields atf on atf.application_group_id=src.application_group_id
	-- inner join maintain_udf_static_data_detail_values a on a.application_field_id= atf.application_field_id 
	-- where  a.primary_field_object_id=555
	
	--select a.* from maintain_udf_static_data_detail_values a 
	--where a.primary_field_object_id=555 
	
	--inner join application_ui_template_fields atf on  a.primary_field_object_id=555 and a.application_field_id= atf.application_field_id 
	--inner join application_ui_template_group src on atf.application_group_id=src.application_group_id




exec dbo.spa_export_table_scripter @tbl_name ='application_ui_template_fields'
	,@filter =' inner join maintain_udf_static_data_detail_values a on a.application_field_id= src.application_field_id inner join #list_contracts fl on a.primary_field_object_id=fl.contract_id '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'sequence'
	,@primary_key_column2  ='udf_template_id'
	,@primary_key_column3 =null
	,@master_table_name =null
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=1


insert into #query_result (query_result)
select
'

update #application_ui_template_fields set application_group_id=f.new_recid
from #application_ui_template_fields m inner join #application_ui_template_group f on m.application_group_id=f.application_group_id

'


exec dbo.spa_export_table_scripter @tbl_name ='application_ui_template_fields'
	,@filter =' inner join maintain_udf_static_data_detail_values a on a.application_field_id= src.application_field_id inner join #list_contracts fl on a.primary_field_object_id=fl.contract_id '  --- the alias name for source_table is always src
	,@is_result_output ='n'
	,@primary_key_column1 = 'sequence'
	,@primary_key_column2  ='udf_template_id'
	,@primary_key_column3 =null
	,@master_table_name =null
	,@join_column_name_master =null 
	,@join_column_name_child  =null 
	,@primary_key_column1_master =null
	,@primary_key_column2_master =null
	,@primary_key_column3_master =null
	,@export_lebel=2

insert into #query_result (query_result)
select
'
update maintain_udf_static_data_detail_values set primary_field_object_id=f.new_recid
from maintain_udf_static_data_detail_values m inner join #contract_group f on m.primary_field_object_id=f.contract_id

update maintain_udf_static_data_detail_values set application_field_id=f.new_recid
from maintain_udf_static_data_detail_values m inner join #application_ui_template_fields f on m.application_field_id=f.application_field_id

update user_defined_fields_template set field_id=f.new_recid
from user_defined_fields_template m 
inner join #user_defined_fields_template m1 on m1.new_recid=m.udf_template_id
inner join #static_data_value f on m.field_id=f.value_id

'





*/






--	inner join dbo.application_ui_template_fields autf on autf.application_field_id =cgd.application_field_id
--inner join dbo.user_defined_fields_template  uddft on uddft.udf_template_id= autf.udf_template_id

--	SELECT * FROM user_defined_fields_template AS uddft WHERE uddft.field_name = -5702
--SELECT * FROM application_ui_template_fields where udf_template_id=280
--SELECT * FROM maintain_udf_static_data_detail_values where  primary_field_object_id = 525

/*



select musdv.* 
from maintain_udf_static_data_detail_values AS musdv --WHERE primary_field_object_id = 525
inner join application_ui_template_fields autf ON autf.application_field_id = musdv.application_field_id
INNER JOIN user_defined_fields_template udft
  ON udft.udf_template_id = autf.udf_template_id 
inner join static_data_value sdv
  ON sdv.value_id = udft.field_name

WHERE musdv.primary_field_object_id = 525
AND sdv.value_id = -5702


SELECT * FROM static_data_value WHERE type_id= 5500
SELECT * FROM static_data_value WHERE code LIKE 'llfc'
SELECT * FROM user_defined_fields_template AS uddft WHERE uddft.field_name = -5702
SELECT * FROM application_ui_template_fields where udf_template_id=280
SELECT * FROM maintain_udf_static_data_detail_values where  primary_field_object_id = 525


*/




--update reference_id 
insert into #query_result (query_result)
select
'
update contract_charge_type_detail set invoice_line_item_id=f.new_recid
from contract_charge_type_detail m 
inner join #contract_charge_type_detail m1 on m1.new_recid=m.ID
inner join #static_data_value f on m.invoice_line_item_id=f.value_id

update contract_group_detail set invoice_line_item_id=f.new_recid
from contract_group_detail m
inner join #contract_group_detail m1 on m1.new_recid=m.id
inner join #static_data_value f on m.invoice_line_item_id=f.value_id

'
----------------------------------------END Contract export process---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
insert into #query_result (query_result)
select '
	if @@TRANCOUNT>0
		COMMIT
END TRY
BEGIN CATCH
	if @@TRANCOUNT>0
		ROLLBACK

	PRINT ERROR_MESSAGE()

END CATCH
'


select * from #query_result order by 1
return





/*




---formula_group_id= 740


select * from formula_nested

select * from #formula_editor
select * from formula_breakdown

select * from formula_editor_parameter

select * from formula_nested where formula_group_id= 740
select * from formula_nested where formula_id= 740
select * from formula_nested where formula_group_id= 740 order by formula_id
select * from formula_editor  where formula_id=740

select formula_id,nested_id,formula_level,* from formula_breakdown where formula_id=740
order by 1,2,3 desc
select * from formula_editor  where formula_id in (
741,
742,
743,
744)

select * from formula_breakdown where formula_id in (
741,
742,
743,
744)
*/








 --contract_charge_type_id
--select * from static_data_value where value_id=300832

--select * from static_data_type where type_id=10017

--select * from formula_editor
