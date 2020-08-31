
/****** Object:  StoredProcedure [dbo].[spa_import_edrXML_inventory]    Script Date: 03/25/2009 17:00:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_edrXML_inventory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_edrXML_inventory]
GO

/****** Object:  StoredProcedure [dbo].[spa_import_edrXML_inventory]    Script Date: 03/25/2009 17:00:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_import_edrXML_inventory 'farrms_admin','adiha_process.dbo.import_edr_farrms_admin_A91719D4_357A_43B1_BFE0_DCB16E3A8940'
CREATE proc [dbo].[spa_import_edrXML_inventory]
	@user_id varchar(50),
	@table_name varchar(100),
	@process_id varchar(100)=null
as
--drop table #temp_inv
--drop table #temp1
--drop table #import_status
--drop table #imp_rec_status
EXEC spa_print 'Start import:'--+convert(varchar(100),getdate(),113)

--####### Declare variables and set values
	DECLARE @insert_row INT
	DECLARE @sql_stmt VARCHAR(5000)
	Declare @tot_source INT
	DECLARE @tot_source_import INT
	DECLARE @series_type_id INT
	DECLARE @Gload_record_type_code INT
	DECLARE @Gload_sub_type_id INT
	DECLARE @gas_conversion_factor FLOAT
	DECLARE @oil_conversion_factor FLOAT

	SET @gas_conversion_factor=0.0595
	SET @oil_conversion_factor=0.0820

	SET @series_type_id=14302
	SET @Gload_record_type_code=300
	SET @Gload_sub_type_id=1607

	if @process_id is null
		SET @process_id = REPLACE(newid(),'-','_')


--#### Create Tmporary Tables
--Inventory Table
	create table #temp_inv
	(
		temp_id int identity(1,1),
		facility_id varchar(10) COLLATE DATABASE_DEFAULT,
		stack_id varchar(100) COLLATE DATABASE_DEFAULT,
		unit_id varchar(100) COLLATE DATABASE_DEFAULT,
		record_type_code varchar(50) COLLATE DATABASE_DEFAULT,
		sub_type_id varchar(50) COLLATE DATABASE_DEFAULT,
		edr_date varchar(20) COLLATE DATABASE_DEFAULT,
		edr_value float,
		curve_id varchar(50) COLLATE DATABASE_DEFAULT,
		uom_id varchar(50) COLLATE DATABASE_DEFAULT,
		uom_id1 varchar(50) COLLATE DATABASE_DEFAULT,
		edr_hour varchar(50) COLLATE DATABASE_DEFAULT
	)

	CREATE  INDEX [IX_ti1] ON [#temp_inv](facility_id)   
	CREATE  INDEX [IX_fi2] ON [#temp_inv](stack_id)		
	CREATE  INDEX [IX_fi3] ON [#temp_inv](unit_id)		
	CREATE  INDEX [IX_fi4] ON [#temp_inv](edr_date)	
	CREATE  INDEX [IX_fi5] ON [#temp_inv](edr_hour)	

--Record Specif Table
	CREATE TABLE #300_1605(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T1] ON [#300_1605](facility_id)   
	CREATE  INDEX [IX_T2] ON [#300_1605](unit_id)		
	CREATE  INDEX [IX_T3] ON [#300_1605](edr_date)	
	CREATE  INDEX [IX_T4] ON [#300_1605](edr_hour)	


	CREATE TABLE #300_1603(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T5] ON [#300_1603](facility_id)   
	CREATE  INDEX [IX_T6] ON [#300_1603](unit_id)		
	CREATE  INDEX [IX_T7] ON [#300_1603](edr_date)	
	CREATE  INDEX [IX_T8] ON [#300_1603](edr_hour)


	CREATE TABLE #330_1600(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T49] ON [#330_1600](facility_id)   
	CREATE  INDEX [IX_T410] ON [#330_1600](unit_id)		
	CREATE  INDEX [IX_T411] ON [#330_1600](edr_date)	
	CREATE  INDEX [IX_T412] ON [#330_1600](edr_hour)


	CREATE TABLE #320_1609(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T413] ON [#320_1609](facility_id)   
	CREATE  INDEX [IX_T414] ON [#320_1609](unit_id)		
	CREATE  INDEX [IX_T415] ON [#320_1609](edr_date)	
	CREATE  INDEX [IX_T416] ON [#320_1609](edr_hour)


	CREATE TABLE #324_1613(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T417] ON [#324_1613](facility_id)   
	CREATE  INDEX [IX_T418] ON [#324_1613](unit_id)		
	CREATE  INDEX [IX_T419] ON [#324_1613](edr_date)	
	CREATE  INDEX [IX_T420] ON [#324_1613](edr_hour)


	CREATE TABLE #310_1600(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T421] ON [#310_1600](facility_id)   
	CREATE  INDEX [IX_T422] ON [#310_1600](unit_id)		
	CREATE  INDEX [IX_T423] ON [#310_1600](edr_date)	
	CREATE  INDEX [IX_T424] ON [#310_1600](edr_hour)


	CREATE TABLE #300_1607(facility_id VARCHAR(6) COLLATE DATABASE_DEFAULT,unit_id VARCHAR(6) COLLATE DATABASE_DEFAULT,edr_date DATETIME,[edr_hour] INT,edr_value FLOAT)
	CREATE  INDEX [IX_T425] ON [#300_1607](facility_id)   
	CREATE  INDEX [IX_T426] ON [#300_1607](unit_id)		
	CREATE  INDEX [IX_T427] ON [#300_1607](edr_date)	
	CREATE  INDEX [IX_T428] ON [#300_1607](edr_hour)


--Status Table
	CREATE TABLE #import_status
	(
		temp_id int,
		process_id varchar(100) COLLATE DATABASE_DEFAULT,
		ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
		Module varchar(100) COLLATE DATABASE_DEFAULT,
		Source varchar(100) COLLATE DATABASE_DEFAULT,
		type varchar(100) COLLATE DATABASE_DEFAULT,
		[description] varchar(250) COLLATE DATABASE_DEFAULT,
		[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
	)

EXEC spa_print 'Temporary table created:'--+convert(varchar(100),getdate(),113)

--#### Tmporary Tables Created





	SET @sql_stmt='
			insert into #temp_inv (facility_id,stack_id,unit_id,record_type_code,sub_type_id,edr_date,edr_hour,curve_id,edr_value,uom_id,uom_id1)
			select 
					RIGHT(''000000''+ltrim(rtrim(facility_id)),6),
					ltrim(rtrim(stack_id)),
					ltrim(rtrim(unit_id)),
					record_type_code,
					sub_type_id,
					edr_date,
					edr_hour,
					curve_id,
					sum(cast(edr_value as float)),
					uom_id,uom_id1 
			from 
				'+@table_name +'
				group by facility_id,ltrim(rtrim(stack_id)),ltrim(rtrim(unit_id)),
				record_type_code,sub_type_id,edr_date,edr_hour,curve_id,
				uom_id,uom_id1 '

	EXEC (@sql_stmt)




-------------############################### FIND the incomplete Data
		select 
				count(distinct edr_date) counts,
				facility_id,
				unit_id,
				record_type_code,
				sub_type_id,
				dbo.fnagetcontractmonth(edr_date) edr_date
		into #incomplete_data
		from
			#temp_inv
		where
			record_type_code=300 and sub_type_id=1605
		group by 
				facility_id,unit_id,record_type_code,sub_type_id,
				dbo.fnagetcontractmonth(edr_date)
		having count(distinct edr_date)<>day(dateadd(month,1,dbo.fnagetcontractmonth(edr_date))-1)



-------------###############################
		delete  
				a
		from 
			#temp_inv a
			inner join #incomplete_data b on a.facility_id=b.facility_id
		    and a.unit_id=b.unit_id
		    and cast(CAST(Year(a.edr_date) As Varchar)+'-'+ CAST(month(a.edr_date) As Varchar) +'-01' as datetime)=
		    cast(CAST(Year(b.edr_date) As Varchar)+'-'+ CAST(month(b.edr_date) As Varchar) +'-01' as datetime)
		   

EXEC spa_print 'Incomplete Data deleted:'--+convert(varchar(100),getdate(),113)

-------------############### Generate and log Error Message
	select 
			record_type_code,
			sub_type_id,
			count(*) as tot_rec,
			0 imp_rec into #imp_rec_status 
	from 
			#temp_inv 
	group by record_type_code,sub_type_id
	
	select @tot_source=count(*) from #temp_inv

	exec('
			insert into #import_status 
			select 
				-1,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Incomelete Data Found for Facility id:''+ isnull(a.facility_id,''NULL'')+''Unit id:''+ isnull(a.unit_id,''NULL'')+''Date:''+ isnull(a.edr_date,''NULL'') ,
				''Please check your data'' 
			from 
				#incomplete_data a '
		)


	exec('
			insert into #import_status 
			select 
				a.temp_id,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Data error for Facility ID is NULL '',
				''Please check your data'' 
			from 
				#temp_inv a 
			where a.facility_id is null '
		)

	
	exec('
			insert into #import_status 
			select 
				a.temp_id,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Data error for Facility id:''+ isnull(a.facility_id,''NULL'') +'' Not found'',
				''Please check your data'' 
			from 
				#temp_inv a left outer join rec_generator b on a.facility_id=b.id 
			where id is null'
		)



	exec('
			insert into #import_status 
			select 
				a.temp_id,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Data error for As of Date.( As of Date:''+a.edr_date+'' Hour:''+a.edr_hour+'' Volume: ''+ cast(a.edr_value as varchar)+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+''Facility Id  ''+isnull(a.facility_id,''NULL'')+'')'',
				''Please check your data'' 
			from 
				#temp_inv a 
			where isdate(a.edr_date)=0'
		)


	exec('
			insert into #import_status 
			select 
				a.temp_id,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Data error for Volume.( As of Date:''+ISNULL(a.edr_date,'''')+'' Hour:''+ISNULL(a.edr_hour,'''')+'' Volume: ''+cast(ISNULL(a.edr_value,'''') as varchar)+''.Facility Id  ''+isnull(a.facility_id,''NULL'')+'')'',
				''Please check your data'' 
			from 
				#temp_inv a 
			where isnumeric(a.edr_value)=0'
		)





	exec('
			insert into #import_status 
			select 
				a.temp_id,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Data Warning for Empty Volume.( As of Date:''+a.edr_date+'' Hour:''+a.edr_hour+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+''.Facility Id  ''+isnull(a.facility_id,''NULL'')+'')'',
				''Please check your data'' 
			from 
				#temp_inv a 
			where 
				isnull(cast(a.edr_value as float),0)=0 or isnull(a.edr_value,'''')='''''
		)


	exec('
			insert into #import_status 
			select 
				a.temp_id,
				'''+ @process_id+''',
				''Error'',
				''Import Data'',
				'''+@table_name+''',
				''Data Error'',
				''Data warning for missing Book ID .(Facility id ''+ isnull(a.facility_id,''NULL'')+'' Generator ID:''+	cast(b.generator_id as varchar(20))+'' Generator Code:''+b.code+'' As of date:''+a.edr_date+'' Hour:''+a.edr_hour+'' Curve id: ''+a.curve_id+'' UOM ID:''+uom_id+'')'',
				''Please check your data'' 
			from 
				#temp_inv a inner join rec_generator b on a.facility_id=b.id where fas_book_id is null'
		)




	exec('
			delete #temp_inv 
			from 
				#import_status inner join #temp_inv a on #import_status.temp_id=a.temp_id'
			)




	select @tot_source_import=count(*) from #temp_inv
	
	insert into #imp_rec_status (
			record_type_code,
			sub_type_id,
			tot_rec,imp_rec
		)
	 select 
			record_type_code,
			sub_type_id,
			max(0),
			count(*) 
	from 
		#temp_inv 
	group by record_type_code,sub_type_id


EXEC spa_print 'Error Log Created:'--+convert(varchar(100),getdate(),113)

-------------############### Error Message Log completed


-------------############### Delete and insert in edr_raw_data table
	delete r 
	from 
		edr_raw_data r 
		inner join #temp_inv t on r.facility_id=t.facility_id 
		and r.unit_id=t.unit_id
		and r.record_type_code=t.record_type_code
		and r.sub_type_id=t.sub_type_id 
		and cast(CAST(Year(r.edr_date) As Varchar)+'-'+ CAST(month(r.edr_date) As Varchar) +'-01' as datetime)=
		cast(CAST(Year(t.edr_date) As Varchar)+'-'+ CAST(month(t.edr_date) As Varchar) +'-01' as datetime)
--	 
--
--print 'Data deleted from edr_raw_data:'+convert(varchar(100),getdate(),113)
--
--
	INSERT INTO edr_raw_data (
			facility_id,
			stack_id,
			unit_id,
			record_type_code,
			sub_type_id,
			edr_date,
			edr_hour,
			edr_value,
			curve_id,
			uom_id,
			uom_id1
		)
	select 
			facility_id,
			stack_id,
			unit_id,
			record_type_code,
			sub_type_id,
			edr_date,
			isnull(edr_hour,0),
			CAST(isnull(edr_value,0) AS FLOAT),
			curve_id,
			uom_id,
			uom_id1 
	from  
			#temp_inv



EXEC spa_print 'Data inserted in edr_raw_date:'--+convert(varchar(100),getdate(),113)
				
-------------############### Now insert in the table #temp_gen_input for each facility,unit, for eahc month
	select 
		tmp.generator_id generator_id,
		im.input_id as ems_input_id ,
		'r' as estimate_type,
		term_start,
		dateadd(month,1,term_start)-1 as term_end,
		703 as frequency,
		edr_value,
		esi.uom_id,
		NULL as forecast_type
	into 
		#temp_gen_input	
	from
			((select r.generator_id,sum(cast(isnull(edr_value,0) as float)) edr_value,dbo.fnagetcontractmonth(edr_date) as term_start 
					from #temp_inv t 
				 left join ems_stack_unit_map esum on esum.ORSIPL_ID=t.facility_id 
					and esum.stack_id=t.unit_id 
					join rec_generator r on r.id=t.facility_id 
					join ems_multiple_source_unit_map emsum on emsum.generator_Id=r.generator_Id
					and ISNULL(esum.unit_id,t.unit_id )=ISNULL(emsum.EDR_unit_ID,'''')
					and t.unit_id not like '%cs%'
					where record_type_code=@Gload_record_type_code and sub_type_id=@Gload_sub_type_id
					group by r.generator_id,dbo.fnagetcontractmonth(edr_date)
			) tmp
			inner join ems_source_model_effective esme on esme.generator_id=tmp.generator_id
			inner join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
					ems_source_model_effective group by generator_id) ab
		on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
		and isnull(esme.effective_date,'1900-01-01')<=tmp.term_start
		left join 
			ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
		left join ems_input_map im on im.source_model_id=esm.ems_source_model_id
		and input_id in(select ems_source_input_id from ems_source_input where input_output_id=1052)
		left join ems_source_input esi on esi.ems_source_input_id=im.input_id)
	

EXEC spa_print 'Data inserted in #temp_gen_input:'--+convert(varchar(100),getdate(),113)
-------------#############
	select
		rg.generator_id,
		rg.[id],
		esm.edr_unit_id,
		st.stack_id
	into 
		#zzz_rec_generator
	from
		rec_generator rg 
		inner join ems_multiple_source_unit_map esm on rg.generator_id=esm.generator_id
		inner join (select distinct generator_id from #temp_gen_input) tmp on tmp.generator_id=rg.generator_id
		left join ems_stack_unit_map st on esm.ORSIPL_ID=st.ORSIPL_ID and esm.edr_unit_id=st.unit_id




---######################################################################
-- Calculate the values from EDR table and insert in edr_calculated_values
	
	Insert into #300_1607 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from #temp_inv 
	where 
		record_type_code=300 and sub_type_id=1607

	insert into #300_1605 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from #temp_inv 
	where 
		record_type_code=300 and sub_type_id=1605

	
	insert into #300_1603 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from #temp_inv 
	where 
		record_type_code=300 and sub_type_id=1603

	
	insert into #330_1600 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from #temp_inv 
	where 
		record_type_code=330 and sub_type_id=1600

	
	insert into #320_1609 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from #temp_inv 
	where 
		record_type_code=320 and sub_type_id=1609

	
	insert into #324_1613 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from 	#temp_inv 
	where record_type_code=324 and sub_type_id=1613

	insert into #310_1600 
	select 
		facility_id,unit_id,edr_date,[edr_hour],edr_value from #temp_inv 
	where 
		record_type_code=310 and sub_type_id=1600



EXEC spa_print 'Data inserted in record specific tables:'--+convert(varchar(100),getdate(),113)

---- insert heatInputValues #################################

select rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date) edr_date,
		sum(ed1.edr_value*ed.edr_value) as HeatINput
into #temp_heatinput		
			from 
					#temp_inv ed
					join rec_generator rg on ed.facility_id=rg.[ID] 
					and ed.sub_type_id=1603 and ed.record_type_code=300	
					join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
					and emsum.EDR_UNIT_ID=ed.unit_id
					join #temp_inv ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed1.sub_type_id=1605 and ed1.record_type_code=300
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
			where 1=1
				and rg.generator_id in(select distinct generator_id from #temp_gen_input)
				group by  rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date)

--####### MWH Values
select rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date) edr_date,
		sum(ed.edr_value*ed1.edr_value) as Mwh
into #temp_Mwh		
			from 
					#300_1605 ed
					join #zzz_rec_generator rg on rg.[id]=ed.facility_id
						and rg.EDR_unit_id=ed.unit_id				
						left join #300_1607 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
			where 1=1
					and rg.generator_id in(select distinct generator_id from #temp_gen_input)
					and rg.stack_id is null
					group by  rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date)

-----------##############**************
---- insert Co2MassEmissions Values
	select 
			rg.generator_id,
			dbo.fnagetcontractmonth(ed.edr_date) edr_date,
			sum(ed.edr_value*ed1.edr_value) as Data
	into #temp_CO2
			from 
					#300_1605 ed
					left join #zzz_rec_generator rg on rg.[id]=ed.facility_id
						and rg.EDR_unit_id=ed.unit_id				
						left join #330_1600 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
				where 1=1
					and rg.generator_id in(select distinct generator_id from #temp_gen_input)
					and rg.stack_id is null
					group by  rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date)


--- CO2 COMMON STACK calculation
	insert into #temp_CO2(generator_id,edr_date,Data)
	select generator_id,dbo.fnagetcontractmonth(edr_date) edr_date,sum([co2emissionsvalues]) [co2emissionsvalues]
--into #temp_CO2
	from
		(
		select  
			rg.generator_id,--dbo.fnagetcontractmonth(ed.edr_date),
			ed.edr_date,ed.edr_hour,
			sum(((ed.edr_value*ed1.edr_value)/ISNULL(NULLIF(ed2.edr_value,0),1))*ed3.edr_value)/(select count(distinct stack_id) from #zzz_rec_generator where generator_id=rg.generator_id) as [co2emissionsvalues]
			from 
					#300_1603 ed	 
						join #zzz_rec_generator rg on rg.[id]=ed.facility_id
						and rg.stack_id is not null
						and rg.EDR_unit_id=ed.unit_id		
					join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
					join #300_1605 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
					left join #300_1603 ed2 on 
						ed2.facility_id=ed.facility_id
						and ed2.unit_id=rg.stack_id
						and ed.edr_date=ed2.edr_date
						and ed.edr_hour=ed2.edr_hour
					left join #330_1600 ed3 on 
						ed3.facility_id=ed.facility_id
						and ed3.unit_id=rg.stack_id
						and ed.edr_date=ed3.edr_date
						and ed.edr_hour=ed3.edr_hour

				where 1=1
						and rg.generator_id not in(954,955)
						and rg.generator_id in(select distinct generator_id from #temp_gen_input)
						and rg.stack_id is not null
						group by  rg.generator_id,--dbo.fnagetcontractmonth(ed.edr_date),
						ed.edr_date,ed.edr_hour
					
		) a
		group by generator_id,dbo.fnagetcontractmonth(edr_date)




	insert into #temp_CO2(generator_id,edr_date,Data)
	select generator_id,dbo.fnagetcontractmonth(edr_date) edr_date,sum([co2emissionsvalues]) [co2emissionsvalues]
	--into #temp_CO2
	from
	(
		select  
			rg.generator_id,
			ed.edr_date,ed.edr_hour,
			sum(((ed3.edr_value*ed1.edr_value)/round(ISNULL(NULLIF((ed2.edr_value*ed7.edr_value),0),1),2))*
			(((ed.edr_value*ed1.edr_value)/round(ISNULL(NULLIF(((ed.edr_value*ed1.edr_value)+(ed5.edr_value*ed6.edr_value)),0),1),2))*
				round(((ed2.edr_value*ed7.edr_value)+(ed4.edr_value*ed7.edr_value)),2)))/2[co2emissionsvalues]
			
			from 
					#300_1603 ed	 
						join #zzz_rec_generator rg on rg.[id]=ed.facility_id
						and rg.stack_id is not null
						and rg.EDR_unit_id=ed.unit_id		
					join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
					join #300_1605 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
					left join #300_1603 ed2 on 
						ed2.facility_id=ed.facility_id
						and ed2.unit_id=rg.stack_id
						and ed.edr_date=ed2.edr_date
						and ed.edr_hour=ed2.edr_hour
					left join #330_1600 ed3 on 
						ed3.facility_id=ed.facility_id
						and ed3.unit_id=rg.stack_id
						and ed.edr_date=ed3.edr_date
						and ed.edr_hour=ed3.edr_hour
					left join #300_1603 ed4 on 
						ed4.facility_id=ed.facility_id
						and ed4.unit_id like 'CS%' and  ed4.unit_id<>ed2.unit_id
						and ed.edr_date=ed4.edr_date
						and ed.edr_hour=ed4.edr_hour
					left join #300_1603 ed5 on 
						ed5.facility_id=rg.id
						and rg.stack_id is not null
						and ed5.unit_id not like 'CS%' and  ed5.unit_id<>ed.unit_id
						and ed5.unit_id<>'8'
						and ed.edr_date=ed5.edr_date
						and ed.edr_hour=ed5.edr_hour
					left join #300_1605 ed6 on 
						ed6.facility_id=rg.id
						and rg.stack_id is not null
						and ed5.unit_id =ed6.unit_id
						and ed.edr_date=ed6.edr_date
						and ed.edr_hour=ed6.edr_hour
					left join #300_1605 ed7 on 
						ed3.facility_id=ed7.facility_id
						and rg.stack_id is not null
						and ed3.unit_id =ed7.unit_id
						and ed3.edr_date=ed7.edr_date
						and ed3.edr_hour=ed7.edr_hour

			where 1=1
						and rg.generator_id in(954,955)
						and rg.stack_id is not null
						group by  rg.generator_id,
						ed.edr_date,ed.edr_hour				

	) a group by generator_id,dbo.fnagetcontractmonth(edr_date)


----------#################*********************************
---------SO2 Mass Emissions Data

	select rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date) edr_date,
			sum(ed.edr_value*ed1.edr_value) as Data
	into #temp_SO2
			from 
				#300_1605 ed
				join #zzz_rec_generator rg on rg.[id]=ed.facility_id
										and rg.EDR_unit_id=ed.unit_id		
						left join #310_1600 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
				where 1=1
					and rg.generator_id in(select distinct generator_id from #temp_gen_input)
					and rg.stack_id is null
					group by  rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date)	


-- COMMON STACK
	insert into #temp_SO2(generator_id,edr_date,data)
	select generator_id,dbo.fnagetcontractmonth(edr_date) edr_date,sum([co2emissionsvalues]) [co2emissionsvalues]
	--into #temp_SO2
	from
	(
		select  
			rg.generator_id,--dbo.fnagetcontractmonth(ed.edr_date),
			ed.edr_date,ed.edr_hour,
			sum(((ed.edr_value*ed1.edr_value)/ISNULL(NULLIF(ed2.edr_value,0),1))*ed3.edr_value)/(select count(distinct stack_id) from #zzz_rec_generator where generator_id=rg.generator_id) as [co2emissionsvalues]
			from 
					#300_1603 ed	 
						join #zzz_rec_generator rg on rg.[id]=ed.facility_id
						and rg.stack_id is not null
						and rg.EDR_unit_id=ed.unit_id		
					join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
					join #300_1605 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
					left join #300_1603 ed2 on 
						ed2.facility_id=ed.facility_id
						and ed2.unit_id=rg.stack_id
						and ed.edr_date=ed2.edr_date
						and ed.edr_hour=ed2.edr_hour
					left join #310_1600 ed3 on 
						ed3.facility_id=ed.facility_id
						and ed3.unit_id=rg.stack_id
						and ed.edr_date=ed3.edr_date
						and ed.edr_hour=ed3.edr_hour

				where 1=1
						and rg.generator_id in(select distinct generator_id from #temp_gen_input)
						group by  rg.generator_id,--dbo.fnagetcontractmonth(ed.edr_date),
						ed.edr_date,ed.edr_hour

					
	) a
	group by generator_id,dbo.fnagetcontractmonth(edr_date)


---##############********************
---------NOX Mass Emissions Data

	select rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date) edr_date, --,ed.edr_hour,
			sum(ed.edr_value*COALESCE(ed2.edr_value,ed3.edr_value)*ed1.edr_value) as Data
	into #temp_NOX
			from 
				#300_1605 ed
				join #zzz_rec_generator rg on rg.[id]=ed.facility_id
										and rg.EDR_unit_id=ed.unit_id		
					join #300_1603 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
					left join #320_1609 ed2 on 
						ed2.facility_id=ed.facility_id
						and ed2.unit_id=ed.unit_id
						and ed.edr_date=ed2.edr_date
						and ed.edr_hour=ed2.edr_hour
					left join #324_1613 ed3 on 
						ed3.facility_id=ed.facility_id
						and ed3.unit_id=ed.unit_id
						and ed.edr_date=ed3.edr_date
						and ed.edr_hour=ed3.edr_hour

			where 1=1
					and rg.generator_id in(select distinct generator_id from #temp_gen_input)
					and rg.stack_id is null
			group by  rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date)



---NOX Common STack Claculations
	insert into #temp_NOX(generator_id,edr_date,data)
	select rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date) edr_date, --,ed.edr_hour,
			sum(ed.edr_value*ed2.edr_value*ed1.edr_value)/(select count(distinct stack_id) from #zzz_rec_generator where generator_id=rg.generator_id) as NOXMassEmissionData
		from 
				#300_1605 ed
				join #zzz_rec_generator rg on rg.[id]=ed.facility_id
										and rg.EDR_unit_id=ed.unit_id		
					join #300_1603 ed1 on 
						ed1.facility_id=ed.facility_id
						and ed1.unit_id=ed.unit_id
						and ed.edr_date=ed1.edr_date
						and ed.edr_hour=ed1.edr_hour
				  left join #320_1609 ed2 on 
						ed2.facility_id=ed.facility_id
						and ed2.unit_id=rg.stack_id
						and ed.edr_date=ed2.edr_date
						and ed.edr_hour=ed2.edr_hour
					

			where 1=1
					and rg.generator_id in(select distinct generator_id from #temp_gen_input)
					and rg.stack_id is not null	
			group by  
					rg.generator_id,dbo.fnagetcontractmonth(ed.edr_date) order by dbo.fnagetcontractmonth(ed.edr_date)


EXEC spa_print 'Emissions Calculated:'--+convert(varchar(100),getdate(),113)

---- Now insert into calculated values table
-- first delete from the table if exists
		delete a
		from
			 edr_calculated_values a
			 join #temp_heatinput b on 
			 a.generator_id=b.generator_id and a.term_date=b.edr_date

---################################
	insert into edr_calculated_values(
			generator_id,
			facility_id,
			stack_id,
			unit_id,
			term_date,
			heatinputvalue,
			co2massemissiondata,
			so2massemissiondata,	
			noxmassemissiondata,
			Mwh
		)
	select
		a.generator_id,
		ems.ORSIPL_ID,
		NULL,
		ems.EDR_UNIT_ID,
		a.edr_date,
		a.heatinput,
		b.data,
		c.data,
		d.data,
		e.Mwh
	from
		#temp_heatinput a 
		left join #temp_co2 b on a.generator_id=b.generator_id and a.edr_date=b.edr_date
		left join #temp_so2 c on a.generator_id=c.generator_id and a.edr_date=c.edr_date
		left join #temp_nox d on a.generator_id=d.generator_id and a.edr_date=d.edr_date
		left join #temp_Mwh e on e.generator_id=a.generator_id and a.edr_date=e.edr_date
		left join ems_multiple_source_unit_map ems on ems.generator_id=a.generator_id


-------------##############################################################################
--- Now run the calc for 
	declare @process_table varchar(128),@process_id1 varchar(100),@term_start datetime,@term_end datetime
	declare @counts_process int,@table_desc varchar(100)
	declare @errorMsg varchar(200)
	declare @errorcode varchar(200)
	declare @detail_errorMsg varchar(200)
	declare @error int
	declare @id int
	declare @count int
	declare @totalcount int
	Declare @url varchar(500)
	declare @desc varchar(500)
	declare @desc1 varchar(500)
	declare @Er_desc1 varchar(500)


	SET @process_id1 = REPLACE(newid(),'-','_')
	set @process_table=dbo.FNAProcessTableName('edr_process',@user_id,@process_id1)
	select @term_start=min(term_start),@term_end=max(term_end) from #temp_gen_input
	exec(
		'select 
			distinct generator_id,term_start,term_end
		into '+@process_table+' from #temp_gen_input'
		)

--	if @term_start is not null
--		exec spa_calc_emissions_inventory NULL,@term_start,@term_end,NULL,NULL,NULL,NULL,@series_type_id,@process_table
		
	
--- Calculation Completed

	FinalStep:
			insert into source_system_data_import_status(
					process_id,
					code,
					module,
					source,
					[type],
					[description],
					recommendation
				) 
			select 
					max(@process_id),
					max('Success'),
					max('Import Data'),
					max('EDR.Import'),
					max('Data Import'),
					cast(record_type_code as varchar)+': '+s.description+ ' ( Total '+ cast(sum(imp_rec) as varchar)+' records out of '+ cast(sum(tot_rec) as varchar)+')',
					max('Please Check your data')
			 from 
					#imp_rec_status t 
					inner join static_data_value s on t.sub_type_id=s.value_id 
			 group by record_type_code,t.sub_type_id,s.description

	
		if @tot_source_import<>@tot_source
			set @Er_desc1='(Some ERRORS found)'
		else
			set @Er_desc1=''


	exec('truncate table '+@table_name)
	--delete from edr_as_imported --where process_id=@process_id

	if (select count(*) from #imp_rec_status)<= 0 
	begin
		select @desc1=' (No records Imported).'
		set @errorcode='e'
	end
	else
		select @desc1='Total '+cast(sum(imp_rec) as varchar)+' records are imported out of '+cast(sum(tot_rec) as varchar) from #imp_rec_status

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_id+''''


	select @desc = '<a target="_blank" href="' + @url + '">' + 
				'Import process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_id) + 
			@desc1+@Er_desc1+
			'.</a></font>'


	set @desc1=case when @errorcode='e' then '<font color=red>' else '' end+'Import.Data'+'</font>'

	EXEC  spa_message_board 'i', @user_id,
				null, @desc1,
				@desc, 'Proceed..', '','a', @errorcode


	 
	set @errorcode='s'
	 
	 Exec spa_ErrorHandler 0, 'Emission Inventory', 
 				'Emission Inventory', 'Status', 
 				'Emission Inventory has been scheduled and will complete shortly.', 
 				'Please check/refresh your message board.'




EXEC spa_print 'Complete:'--+convert(varchar(100),getdate(),113)












































