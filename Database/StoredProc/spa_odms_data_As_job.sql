
IF OBJECT_ID(N'spa_odms_data_As_job', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_odms_data_As_job]
GO 

CREATE PROCEDURE [dbo].[spa_odms_data_As_job]
	@fromdate varchar(20),
	@todate varchar(20),
	@table_name varchar(100) =NULL

AS

DECLARE @year_from int
DECLARE @month_from int		
DECLARE @year_to int
DECLARE @month_to int	
DECLARE @default_uom_id int

DECLARE @process_id varchar(100)
DECLARE @date datetime
SET @date=getdate()
SET @default_uom_id=24

SET @year_from=YEAR(@fromdate)
SET @month_from=MONTH(@fromdate)
SET @year_to=YEAR(@todate)
SET @month_to=MONTH(@todate)

			
---- CREATE Linkedserver---------------------------------------------
-- EXEC sp_droplinkedsrvlogin 'ODMS',@user_name
-- EXEC sp_addlinkedsrvlogin 'ODMS',  false,@user_name, 'COD_USER', 'COD8ES'

--EXEC sp_dropserver 'ODMS'
-- EXEC sp_addlinkedserver   'ODMS',  'CODP',  'MSDAORA',  'CODP'
-- EXEC sp_addlinkedsrvlogin 'ODMS',  false,'sa', 'COD_USER', 'COD8ES'

---- GET DATA FROM ORACLE----------------------------------------

CREATE TABLE #temp_ODMS( 
	UTIL_CODE VARCHAR(100) COLLATE DATABASE_DEFAULT,
	UNIT_TYPE_DESCR  VARCHAR(100) COLLATE DATABASE_DEFAULT,
	PLANT_ID VARCHAR(100) COLLATE DATABASE_DEFAULT,
	PLANT_NAME VARCHAR(100) COLLATE DATABASE_DEFAULT,
	PLANT_CODE VARCHAR(100) COLLATE DATABASE_DEFAULT,
	STATE_CODE VARCHAR(100) COLLATE DATABASE_DEFAULT,
	UNIT_CODE VARCHAR(100) COLLATE DATABASE_DEFAULT,
	UNIT_MSR_YR INT,
	UNIT_MSR_MTH INT,
	ACT_GR_MTHLY_MWH FLOAT,
	ACT_NET_MTHLY_MWH FLOAT
)

EXEC('insert into #temp_ODMS select * from '+@table_name)
/*	
INSERT INTO #temp_ODMS  
select * FROM OPENQUERY(ODMS_Rectracker,'SELECT 
             COD_UTILITY.UTIL_CODE,
             COD_UNIT_TYPE.UNIT_TYPE_DESCR, 
             Cod_plant.PLANT_ID,
             COD_PLANT.PLANT_NAME, 
             COD_PLANT.Plant_code, 
 	     COD_STATE.STATE_CODE,
             COD_UNIT.UNIT_CODE,
             COD_MTHLY_UNIT_MEASURE.UNIT_MSR_YR, 
             COD_MTHLY_UNIT_MEASURE.UNIT_MSR_MTH, 
             COD_MTHLY_UNIT_MEASURE.ACT_GR_MTHLY_MWH, 
             COD_MTHLY_UNIT_MEASURE.ACT_NET_MTHLY_MWH

 FROM COD_PLANT, COD_UNIT,COD_UNIT_TYPE,COD_MTHLY_UNIT_MEASURE,
COD_UTILITY, COD_STATE

 WHERE COD_UTILITY.UTIL_ID = COD_PLANT.UTIL_ID 

      AND COD_MTHLY_UNIT_MEASURE.UNIT_ID = COD_UNIT.UNIT_ID

      AND COD_PLANT.PLANT_ID = COD_UNIT.PLANT_ID

      AND COD_UNIT.UNTY_ID = COD_UNIT_TYPE.UNTY_ID

      AND cod_state.state_id = cod_plant.state_id  ' )
where UNIT_MSR_YR between @year_from and @year_to ANd UNIT_MSR_MTH between @month_from and @month_to
and cast(Plant_code  as varchar) in
(select rg.id2 from rec_generator rg inner join source_counterparty sc
  on rg.ppa_counterparty_id=sc.source_counterparty_id where int_ext_flag='i')
*/
-- drop table #import_status
-- drop table #temp_generator
declare @def_counterparty int, @def_counter_name varchar(100),@gis_id int, @gis_name varchar(100)
declare @FirstGenDate DATETIME,@df_deal_type int,@df_trader varchar(20),@strategy_name_for_odms varchar(50)
set @def_counterparty=201
set @def_counter_name='Xcel Energy'
set @gis_id=5161
set @gis_name='ERCOT'
SET @FirstGenDate='2006-01-01'
set @df_deal_type=53
set @df_trader='xcelgen'
set @strategy_name_for_odms='Owned'

declare @all_row_count int
SET @process_id = REPLACE(newid(),'-','_')
--Create temporary table to log import status
CREATE TABLE #import_status
(
	temp_id int identity(1,1),
	process_id varchar(100) COLLATE DATABASE_DEFAULT,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
	Module varchar(100) COLLATE DATABASE_DEFAULT,
	Source varchar(100) COLLATE DATABASE_DEFAULT,
	type varchar(100) COLLATE DATABASE_DEFAULT,
	[description] varchar(250) COLLATE DATABASE_DEFAULT,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
)

set @all_row_count=(select count(*) from #temp_ODMS)

-- ########Creating TEMP Table from ODMS Excel 
select UPPER(plant_code) Code,Plant_Name,PLANT_ID [ID],
upper(UTIL_Code) owner,'5157' ClassificationId,s.value_id Technology,@FirstGenDate FirstGenDate,'y' upgraded,
state.value_id State, 'y' registered,NULL legal,'n' gen_offset_technology,null source_curve_def_id, 
state.value_id GenStateID,@gis_id GIS,@def_counterparty counter_party,
cast(unit_msr_yr as varchar) +'-'+ cast(unit_msr_mth as varchar) + '-1' Gen_Term_Start,
DBO.FNALastDayInDate(cast(unit_msr_yr as varchar) +'-'+ cast(unit_msr_mth as varchar) + '-1') Gen_Term_End,
sum(isnull(act_gr_mthly_MWH,0)) deal_volume ,
UPPER(plant_code)+'_'+right(cast(unit_msr_yr as varchar),2)+ replicate('0',2-len(cast(unit_msr_mth as varchar)))+cast(unit_msr_mth as varchar)   FeederId,
STATE_Code
into #temp_generator
from #temp_ODMS o join static_data_value s
on rtrim(o.unit_type_descr)=s.code and s.type_id=10009 
--join portfolio_hierarchy legal on o.util_code=legal.entity_name 
--LEFT JOIN source_Price_curve_def e ON 'REC-'+ [unit_type_descr] =e.curve_id  
join static_data_value state 
on o.state_code=state.code and state.type_id=10002
group by plant_id,plant_name,plant_code,UTIL_Code,s.value_id,state.value_id,
unit_msr_yr,unit_msr_mth,STATE_Code

--select * from #temp_generator
---- ########Creating Rec Generator Only Insert new GENERATOR FOUND
-- INSERT INTO rec_generator(
-- 	Code,
-- 	[name],
-- 	[id],
-- 	[owner],
-- 	classification_value_id,
-- 	technology,
-- 	first_gen_date,
-- 	upgraded,
-- 	state_value_id,
-- 	registered,
-- 	legal_entity_value_id,
-- 	gen_offset_technology,
-- 	source_curve_def_id,
-- 	gen_state_value_id,
-- 	gis_value_id,
-- 	ppa_counterparty_id,
-- 	[id2]
-- )	
-- select 
--  o.Code,Plant_Name, o.[ID],
--  o.owner, o.ClassificationId, o.Technology, o.FirstGenDate, o.upgraded,
--  o.State, o.registered, o.legal,o.gen_offset_technology,o.source_curve_def_id, 
-- o.GenStateID, o.GIS,o.counter_party,o.[ID2] from rec_generator r 
-- right outer join #temp_generator  o
-- on r.id2=cast(o.id as varchar)
-- where r.generator_id is null

--###### NOTIFY for new generator FOUND

-- insert into #import_status (process_id,errorCode,module,Source,type,[description],[nextstep])
-- select @process_id,'Error','ODMS Data','ODMS','Generator',
-- 'New Generator found :<b>'+ plant_name +'</b> cannot proceed, first create generator from Maintain Rec Generator, then retry it again.','Please update generators'
-- from rec_generator r 
-- right outer join #temp_generator o
-- on r.id2=cast(o.id as varchar)
-- where r.generator_id is null

-- #temp_generator
-- where Plant_Name not in (select [name] from rec_generator)
--##FINISHED


--Copy Generator to GENERATOR CRoss Ref table if it is new
	
-- insert into generator_cross_ref(generator_id,subsidiary)
-- select r.generator_id,p.entity_id from #temp_generator t join rec_generator r
-- on r.name=t.plant_name join portfolio_hierarchy p
-- on p.entity_name=t.owner  left outer join generator_cross_ref gcr
-- on r.generator_id=gcr.generator_id and p.entity_id=gcr.subsidiary 
-- where cross_id is null

--Notify IF Book map is not define for STATES
-- insert into #import_status (process_id,errorCode,module,Source,type,[description],[nextstep])
-- select @process_id,'Error','ODMS Data','ODMS','Generator',
-- 'Book map is not define for State :'+ t.STATE_Code ,'Please update Cross Reference'
-- from #temp_generator t
-- left outer join portfolio_hierarchy b  
-- on b.entity_name=t.STATE_Code left outer join
-- portfolio_hierarchy s on b.parent_entity_id=s.entity_id
-- and s.entity_name=@strategy_name_for_odms left outer join source_system_book_map ssbm 
-- on b.entity_id=ssbm.fas_book_id left outer join source_book sb 
-- on sb.source_book_id=ssbm.source_system_book_id1
-- join portfolio_hierarchy s on s.entity_id=r.legal_entity_value_id
-- left join static_data_value sd on sd.value_id=r.gen_state_value_id
-- where source_system_book_id is null
-- group by t.STATE_Code



declare @sqlStmt varchar(5000), @tempTable varchar(200), @user_login_id varchar(50)
set @user_login_id=dbo.FNADBUser()

set @tempTable=dbo.FNAProcessTableName('deal_process_odms_', @user_login_id,@process_id)
	
	set @sqlStmt='create table '+ @tempTable+'( 
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
-- 	 [GIS] [varchar] (255)  NULL ,      
-- 	 [GIS Certificate Number] [varchar] (255)  NULL ,      
-- 	 [GIS Certificate Date] [varchar] (255)  NULL ,      
	 [Deal_Type] [varchar] (10)  NULL ,      
	 [Deal_Sub_Type] [varchar] (10)  NULL ,      
	 [Trader] [varchar] (100)  NULL ,      
	 [Broker] [varchar] (100)  NULL ,      
	 [Index] [varchar] (255)  NULL ,      
	 [Frequency] [varchar] (10)  NULL ,      
	 [Deal_Date] [varchar] (50)  NULL ,      
	 [Currency] [varchar] (255)  NULL ,      
	 [Category] [varchar] (20)  NULL ,      
	 [buy_sell_flag] [varchar] (10)  NULL,
	 [leg] [varchar] (20)  NULL
	)       
	'
	
	exec(@sqlStmt)

--Copy all the Deals to Temp table for processing Transaction, Only whose book map is define in Cross Ref table
declare @count_temp int,@totalcount int

	set @sqlStmt='insert into '+ @tempTable +'
	select s.entity_name+''_''+'''+@strategy_name_for_odms+'''+''_''+sd.code,
--	sb.source_book_name,
	t.feederId,t.gen_term_start,
	t.gen_term_end,FLOOR(t.deal_volume),'+cast(@default_uom_id as varchar)+',0 price,null formula,
	t.counter_party,r.generator_id,'+cast(@df_deal_type as varchar)+',null,'''+@df_trader+''',null broker,
	r.source_curve_def_id,
	''h'',t.gen_term_start dealdate,NULL,475,''b'',null
	from #temp_generator t 
	join rec_generator r on r.id2=cast(t.[id]  as varchar) 
	join portfolio_hierarchy s on s.entity_id=r.legal_entity_value_id
	left join static_data_value sd on sd.value_id=r.gen_state_value_id
-- 	join source_system_book_map ssbm 
-- 	on b.entity_id=ssbm.fas_book_id  join source_book sb 
-- 	on sb.source_book_id=ssbm.source_system_book_id1
'
EXEC spa_print @sqlStmt
exec(@sqlStmt)
set @count_temp=@@rowcount
EXEC spa_print 'Processing'
-- Call Prcess Transaction to create Deals
if @count_temp > 0
	EXEC spb_Process_Transactions @user_login_id ,@tempTable, 'n','y'

declare @detail_errorMsg varchar(1000),@msg_rec varchar(1000),@count int
declare @url varchar(5000), @desc varchar(5000),@errorcode varchar(10)

set @count=(select count(distinct temp_id) from #import_status)
set @totalcount=(select count(*) from #temp_generator)

set @msg_rec='Total '+ cast(@totalcount as varchar) +' REC Generator found out of '+ cast(@all_row_count as varchar) +' row provided.'
if @count >0
	begin


		set @errorcode='e'
		if @count_temp >0
		     select @detail_errorMsg = cast(@count_temp as varchar(100))+' REC has been processed out of '+cast(@totalcount as varchar(100))+'. Some Error found while importing. Please review Errors'
		else
		     select @detail_errorMsg = ' Error found while importing. Please review Errors'
				
		insert into source_system_data_import_status(process_id,code,module,source,
		type,[description],recommendation) 
		select @process_id,'Error','ODMS Data','ODMS','Data Error',@detail_errorMsg,'Please Check your data'

		insert into source_system_data_import_status_detail(process_id,source,
		type,[description]) 
		select @process_id,'ODMS',type,[description]  from #import_status where process_id=@process_id
		
		---------------------------------------------------------------------------------------------------
		Insert into email_notes(
			internal_type_value_id,
			notes_object_name,
			notes_object_id,
			notes_subject,
			notes_text,
			send_from,
			send_to,
			send_status,
			active_flag
		)
		SELECT 	
			750,				
			'Email',
			0,
			'Error on Import Process for ODMS data',
			'There was an error while Importing Data for ODMS. Please login to Rectracker to see the detail error message',
			au1.user_emal_add,
			au.user_emal_add,
			'n',
			'y'
		FROM
			application_role_user aru inner join
			application_security_role asr on aru.role_id=asr.role_id
			inner join static_data_value sd on asr.role_type_value_id=sd.value_id
			inner join application_users au on aru.user_login_id=au.user_login_id
			CROSS JOIN
			application_users au1 where au1.user_login_id=dbo.FNAAppAdminID()
			and sd.value_id=3 and au.user_emal_add is not null				
	End
else
begin
	set @detail_errorMsg=cast(@count_temp as varchar(100))+' REC has been processed out of '+cast(@totalcount as varchar(100))

	set @errorcode='s'
	insert into source_system_data_import_status(process_id,code,module,source,
	type,[description],recommendation) 
	values(@process_id,'Success','ODMS Data','ODMS','Successful',@detail_errorMsg,'')
end

-- SET @sql = dbo.FNAProcessDeleteTableSql(@temptablename)
-- exec (@sql)
CREATE table #temp_user(user_login_id varchar(100) COLLATE DATABASE_DEFAULT)

if @count >0 
insert into #temp_user
select DISTINCT ISNULL(af.login_id,ar.user_login_id)
	from
		application_functional_users af
		RIGHT JOIN application_role_user ar
		on ar.role_id=af.role_id or af.login_id is not null
		where	af.function_id=2
ELSE
insert into #temp_user select @user_login_id 


	DECLARE curtemp CURSOR FOR
	SELECT 	user_login_id from #temp_user
	OPEN curtemp
	FETCH next from curtemp into @user_login_id
	WHILE @@FETCH_STATUS=0
	BEGIN	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
	
	select @desc = '<a target="_blank" href="' + @url + '">' + 
				'ODMS process Completed:' + @msg_rec + 
			case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
			'.</a>'
	
	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Import.ODMS',
				@desc, '', '', @errorcode, 'ODMS Import'
	
	FETCH next from curtemp into @user_login_id
	END
	CLOSE curtemp
	DEALLOCATE curtemp








