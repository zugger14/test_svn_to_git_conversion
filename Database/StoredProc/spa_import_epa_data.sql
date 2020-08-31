
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_epa_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_epa_data]
GO 

create proc [dbo].[spa_import_epa_data]
@temp_table_name varchar(100),  
@table_id varchar(100),  
  
@job_name varchar(100),  
  
@process_id varchar(100),  
  
@user_login_id varchar(50)  
  
AS  
Declare @sql varchar(8000)
declare @errorCount int
declare @url varchar(5000), @desc varchar(5000),@errorcode varchar(10),@ems_input_id_GENERATION int


set @ems_input_id_GENERATION=92
set @errorCount = 0


 create table  #temp_epa(
		[state] [varchar] (50) COLLATE DATABASE_DEFAULT,
		[FACILITY_NAME][varchar](255) COLLATE DATABASE_DEFAULT,
		[ORISPL_CODE][varchar](50) COLLATE DATABASE_DEFAULT,
		[UNITID][varchar](50) COLLATE DATABASE_DEFAULT,
		[OP_YEAR][varchar](255) COLLATE DATABASE_DEFAULT,
		[ASSOC_STACKS][varchar](255) COLLATE DATABASE_DEFAULT,
		[OP_MONTH][varchar](255) COLLATE DATABASE_DEFAULT,
		[PRG_CODE_INFO][varchar](255) COLLATE DATABASE_DEFAULT,
		[SUM_OP_TIME][varchar](255) COLLATE DATABASE_DEFAULT,
		[GLOAD][varchar](255) COLLATE DATABASE_DEFAULT,
		[SO2_MASS][varchar](255) COLLATE DATABASE_DEFAULT,
		[NOX_RATE][varchar](255) COLLATE DATABASE_DEFAULT,
		[NOX_MASS][varchar](255) COLLATE DATABASE_DEFAULT,
		[CO2_MASS][varchar](255) COLLATE DATABASE_DEFAULT,
		[HEAT_INPUT][varchar](255) COLLATE DATABASE_DEFAULT,
		[CAPACITY_INPUT][varchar](255) COLLATE DATABASE_DEFAULT
		
	)

exec ('insert into #temp_epa 
		select 
			replace(STATE,''"'',''''),
			replace(FACILITY_NAME,''"'',''''),
			RIGHT(''000000''+LTRIM(RTRIM(replace(ORISPL_CODE,''"'',''''))),6),
			replace(UNITID,''"'',''''),
			replace(OP_YEAR,''"'',''''),
			replace(ASSOC_STACKS,''"'',''''),
			replace(OP_MONTH,''"'',''''),
			replace(PRG_CODE_INFO,''"'',''''),
			replace(SUM_OP_TIME,''"'',''''),
			replace(GLOAD,''"'',0),
			replace(SO2_MASS,''"'',0),
			replace(NOX_RATE,''"'',0),
			replace([NOX_MASS],''"'',0),
			replace(CO2_MASS,''"'',0),
			replace(HEAT_INPUT,''"'',0),
			replace(CAPACITY_INPUT,''"'',0)

from ' + @temp_table_name)



--print @sql
--
exec(@sql)


set @errorCount = (select count(*) from #temp_epa epa
				left join rec_generator rg on 
				 rg.id = epa.ORISPL_CODE and rg.id2 = epa.UNITID
				where	
					rg.generator_id is null)




--select * from emissions_inventory

--insert into emissions_inventory( 
--			as_of_date,term_start,term_end,generator_id,frequency,curve_Id,volume,uom_id,calculated,current_forecast,forecast_type)			
			select 
					cast(epa.OP_YEAR + '-12-01' as datetime) as as_of_date,
					cast(epa.OP_YEAR + '-' + epa.OP_MONTH + '-01' as datetime) as term_start,
					cast(epa.OP_YEAR + '-' + epa.OP_MONTH  + '-' +  cast(day(dateadd(month,1,epa.OP_YEAR + '-' + epa.OP_MONTH + '-01')-1) as varchar) as datetime) as term_end,
					rg.generator_id,	
					ssim.frequency as frequency,
					ssim.curve_Id as curve_id,
					CO2_MASS*conv.conversion_factor as volume,
					esm.uom_id as  uom_id,	
					'n' as calculated,
					'r' as current_forecast,
					ssim.forecast_type as forecast_type,
					epa.HEAT_INPUT,
					ssim.heatcontent_uom_id,
					epa.GLOAD as GLOAD,
					ssim.MWH_uom_id		
				into #temp_inventory		
				from
				#temp_epa epa
				inner join rec_generator rg 
				on epa.ORISPL_CODE=rg.[id]
				join ems_multiple_source_unit_map emsum on rg.generator_id=emsum.generator_id
				and epa.UNITID=isnull(emsum.EPA_Unit_id,rg.id2)				 
				join source_system_input_map ssim on ssim.source_system_id = 603
				and ssim.curve_id=127
				inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
				inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
							ems_source_model_effective  group by generator_id) ab
				on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
				inner join 
					ems_source_model_detail esm on esm.ems_source_model_id=esme.ems_source_model_id
					and esm.curve_id=127
				left join rec_volume_unit_conversion conv on 
				conv.state_value_id is null
				and conv.curve_id is null
				and conv.assignment_type_value_id is null
				and conv.from_source_uom_id=ssim.uom_id
				and conv.to_source_uom_id=esm.uom_id
				where CO2_MASS is not null
					
UNION
	select 
					epa.OP_YEAR + '-12-01' as as_of_date,
					epa.OP_YEAR + '-' + epa.OP_MONTH + '-01' as term_start,
					epa.OP_YEAR + '-' + epa.OP_MONTH  + '-' +  cast(day(dateadd(month,1,epa.OP_YEAR + '-' + epa.OP_MONTH + '-01')-1) as varchar) as term_end,
					rg.generator_id,	
					ssim.frequency as frequency,
					ssim.curve_Id as curve_id,
					NOX_MASS*conv.conversion_factor as volume,
					esm.uom_id as  uom_id,	
					'n' as calculated,
					'r' as current_forecast,
					ssim.forecast_type as forecast_type,
					epa.HEAT_INPUT,
					ssim.heatcontent_uom_id,
					epa.GLOAD as GLOAD,
					ssim.MWH_uom_id 		 				 				
				from
				#temp_epa epa
				inner join rec_generator rg 
				on epa.ORISPL_CODE=rg.[id]
				join ems_multiple_source_unit_map emsum on rg.generator_id=emsum.generator_id
				and epa.UNITID=isnull(emsum.EPA_Unit_id,rg.id2)				 
				join source_system_input_map ssim on ssim.source_system_id = 603
				and ssim.curve_id=183
				inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
				inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
							ems_source_model_effective  group by generator_id) ab
				on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
				inner join 
					ems_source_model_detail esm on esm.ems_source_model_id=esme.ems_source_model_id
					and esm.curve_id=183
				left join rec_volume_unit_conversion conv on 
				conv.state_value_id is null
				and conv.curve_id is null
				and conv.assignment_type_value_id is null
				and conv.from_source_uom_id=ssim.uom_id
				and conv.to_source_uom_id=esm.uom_id
				where NOX_MASS is not null
					
UNION
	select 
					epa.OP_YEAR + '-12-01' as as_of_date,
					epa.OP_YEAR + '-' + epa.OP_MONTH + '-01' as term_start,
					epa.OP_YEAR + '-' + epa.OP_MONTH  + '-' +  cast(day(dateadd(month,1,epa.OP_YEAR + '-' + epa.OP_MONTH + '-01')-1) as varchar) as term_end,
					rg.generator_id,	
					ssim.frequency as frequency,
					ssim.curve_Id as curve_id,
					SO2_MASS*conv.conversion_factor as volume,
					esm.uom_id as  uom_id,	
					'n' as calculated,
					'r' as current_forecast,
					ssim.forecast_type as forecast_type,
					epa.HEAT_INPUT,
					ssim.heatcontent_uom_id,
					epa.GLOAD as GLOAD,
					ssim.MWH_uom_id 		 				 				
				from
				#temp_epa epa
				inner join rec_generator rg 
				on epa.ORISPL_CODE=rg.[id]
				join ems_multiple_source_unit_map emsum on rg.generator_id=emsum.generator_id
				and epa.UNITID=isnull(emsum.EPA_Unit_id,rg.id2)				 
				join source_system_input_map ssim on ssim.source_system_id = 603
				and ssim.curve_id=1248
				inner join ems_source_model_effective esme on esme.generator_id=rg.generator_id
				inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
							ems_source_model_effective  group by generator_id) ab
				on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
				inner join 
					ems_source_model_detail esm on esm.ems_source_model_id=esme.ems_source_model_id
					and esm.curve_id=1248
				left join rec_volume_unit_conversion conv on 
				conv.state_value_id is null
				and conv.curve_id is null
				and conv.assignment_type_value_id is null
				and conv.from_source_uom_id=ssim.uom_id
				and conv.to_source_uom_id=esm.uom_id
				where SO2_MASS is not null

----- Now The Heat Content Value delete if exists

delete
	 ei

		from emissions_inventory ei
		join #temp_inventory ti on ti.generator_id = ei.generator_id
		and ti.curve_id=ei.curve_id and ti.term_start=ei.term_start
		and ti.forecast_type=ei.forecast_type
		


insert into emissions_inventory( 
			as_of_date,term_start,term_end,generator_id,frequency,curve_Id,volume,uom_id,calculated,current_forecast,forecast_type)			
select	
			as_of_date,term_start,term_end,generator_id,frequency,curve_Id,case when volume<0 then 0 else volume end,uom_id,calculated,current_forecast,forecast_type
	from
		#temp_inventory

--------------------------------------------------------------------------


-- Now delete from ems_calc_detail_value
--delete from ems_calc_detail_value 
--		where 
--inventory_id  not in(select emissions_inventory_id from emissions_inventory)				
--------------------------------------------------			
insert into ems_calc_detail_value(inventory_id,as_of_date,term_start,term_end,generator_id,curve_id,input_id,volume,uom_id,frequency,current_forecast,reduction,heatcontent_value,heatcontent_uom_id,forecast_type,
			output_value,output_uom_id)
select 
		ei.emissions_inventory_id,ei.as_of_date,ei.term_start,ei.term_end,ei.generator_id,ei.curve_id,NULL,
		case when ei.volume<0 then 0 else ei.volume end ,ei.uom_id,ei.frequency,ei.current_forecast,'n',ti.heat_input,ti.heatcontent_uom_id,ei.forecast_type,
		case when ti.GLOAD<0 then 0 else ti.GLOAD end ,ti.MWH_uom_id
	from
			emissions_inventory ei
			inner join #temp_inventory ti on ti.generator_id = ei.generator_id
			and ti.curve_id=ei.curve_id and ti.term_start=ei.term_start
			and ti.forecast_type=ei.forecast_type		
			--where ti.curve_id=127
	


--- Now Insert into ems_gen_input
--
--delete egi 
--	from 
--			ems_gen_input egi
--			inner join #temp_inventory ti on egi.generator_id=ti.generator_id
--			and egi.ems_input_id=@ems_input_id_GENERATION
--			and ti.term_start = egi.term_start
--			and ti.forecast_type=egi.forecast_type
----------------------------------------------------

--insert into ems_gen_input(generator_id,ems_input_id,estimate_type,term_start,term_end,frequency,input_value,uom_id,forecast_type)
--	select
--			generator_id,@ems_input_id_GENERATION,'r',term_start,term_end,frequency,GLoad,MWH_uom_id,forecast_type
--	from
--		#temp_inventory
--		where curve_id=127
			
if @errorCount > 0
begin
set @errorcode='e'
--	insert into source_system_data_import_status(process_id,code,module,source,
--			type,[description],recommendation)
--					select @process_id,'Error', 'EPA Data', 'EPA','Data Error', distinct [epa.FACILITY_NAME] , 'Please Check your Data'
--					from #temp_epa epa
--					left join rec_generator rg on 
--					 rg.id = epa.ORISPL_CODE and rg.id2 = epa.UNITID
--					where	
--						rg.generator_id is null
--					order by rg.generator_id

select  DISTINCT epa.[FACILITY_NAME] as facility_name
	into #temp_facility_name
					from #temp_epa epa
					left join rec_generator rg on 
					 rg.id = epa.ORISPL_CODE and rg.id2 = epa.UNITID
					where	
						rg.generator_id is null
--
--select * from #temp_facility_name
insert into source_system_data_import_status(process_id,code,module,source,
			type,[description],recommendation) 
					select @process_id,'Error', 'EPA Data', 'EPA','Data Error', 
					'Data of ' + cast(count(facility_name) as varchar) + ' Source/Sink  not found in the application' , 'Please Check your Data'
					from #temp_facility_name 

--insert into source_system_data_import_status_detail(process_id,source,
--		type,[description]) 
--		select @process_id,'EPA','Data Error','Data of Source/Sink ' + facility_name + ' not found in the application' 
--from #temp_facility_name

--insert into source_system_data_import_status(process_id,code,module,source,
--			type,[description],recommendation) 
--					select @process_id,'Error', 'EPA Data', 'EPA','Data Error', 
--					'Data of Source/Sink ' + facility_name + ' not found in the application' , 'Please Check your Data'
--					from #temp_facility_name 	
end
else
begin
	insert into source_system_data_import_status(process_id,code,module,source,
	type,[description],recommendation) 
	values(@process_id,'Success','EPA Data','EPA','Successful','EPA Data imported Sucessfully','')
end


CREATE table #temp_user(user_login_id varchar(100) COLLATE DATABASE_DEFAULT)

--select @errorCount
set @user_login_id=dbo.FNADBUser()

--select dbo.FNADBUser()

if @errorCount >0 
insert into #temp_user
select DISTINCT ISNULL(af.login_id,ar.user_login_id)
	from
		application_functional_users af
		RIGHT JOIN application_role_user ar
		on ar.role_id=af.role_id or af.login_id is not null
		where	af.function_id=2

insert into #temp_user select @user_login_id 
--
--select @user_login_id
--select * from #temp_user


	DECLARE curtemp CURSOR FOR
	SELECT 	user_login_id from #temp_user
	OPEN curtemp
	FETCH next from curtemp into @user_login_id
	WHILE @@FETCH_STATUS=0
	BEGIN	

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
	
	select @desc = '<a target="_blank" href="' + @url + '">' + 
				'EPA import process Completed:' + 
			case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
			'.</a>'
	
	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Import.EPA',
				@desc, '', '', @errorcode, 'EPA Import'
	
	FETCH next from curtemp into @user_login_id
	END
	CLOSE curtemp
	DEALLOCATE curtemp







