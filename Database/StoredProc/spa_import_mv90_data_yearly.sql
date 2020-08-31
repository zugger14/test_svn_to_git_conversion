
IF OBJECT_ID(N'spa_import_mv90_data_yearly', N'P') IS NOT NULL
DROP PROCEDURE dbo.spa_import_mv90_data_yearly
GO 

CREATE PROCEDURE dbo.spa_import_mv90_data_yearly
	@temp_table_name VARCHAR(100),
	@table_id VARCHAR(100),
	@job_name VARCHAR(100),
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50)
AS

DECLARE @sql varchar(8000)
declare @url_desc varchar(250)
declare @url varchar(250)
DECLARE @error_count int      
DECLARE @type char    

-----------------------------------------------------
create table #temp_table(
	temp_id int identity(1,1),
	recorderId varchar(50) COLLATE DATABASE_DEFAULT,
	gen_date datetime,
	from_date datetime,
	to_date datetime,
	channel int,
	volume float,
	uom_id int,
	descriptions varchar(500) COLLATE DATABASE_DEFAULT	
)

CREATE  INDEX [IX_recs1] ON [#temp_table]([recorderid])                  
CREATE  INDEX [IX_recs2] ON [#temp_table]([channel])
CREATE  INDEX [IX_recs3] ON [#temp_table]([from_date])
CREATE  INDEX [IX_recs4] ON [#temp_table]([to_date])
CREATE  INDEX [IX_recs5] ON [#temp_table]([gen_date])


set @sql='
insert 
	into #temp_table(recorderID,gen_date,from_date,to_date,channel,volume,uom_id,descriptions)
select 
	recorder_id,max(case when isdate(left(gen_date,8))=1 then cast(left(gen_date,8) as datetime) else NULL end),
	case when isdate(left(from_date,8))=1 then cast(left(from_date,8) as datetime) else NULL end,
	case when isdate(left(to_date,8))=1 then cast(left(to_date,8) as datetime) else NULL end,channel,
	sum(ROUND(cast(isnull(field1,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field4,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field7,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field10,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field13,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field16,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field19,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field22,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field25,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field28,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field31,0) as float)-0.0005,0)+
	ROUND(cast(isnull(field34,0) as float)-0.0005,0)),
	header11,max(header19)
	from
		'+@temp_table_name+'
	group by
		recorder_id,from_date,to_date,channel,header11
'	

EXEC(@sql)
 
---------------------------------
create table #temp_detail(
recorderid varchar(100) COLLATE DATABASE_DEFAULT,channel int,
from_date datetime,Field1 float,Field4 float,Field7 float,Field10 float,
Field13 float,Field16 float,Field19 float,Field22 float,Field25 float,
Field28 float,Field31 float,Field34 float,detail_id int,header11 int)

CREATE  INDEX [IX_rec1] ON [#temp_detail]([recorderid])                  
CREATE  INDEX [IX_rec2] ON [#temp_detail]([channel])
CREATE  INDEX [IX_rec3] ON [#temp_detail]([from_date])
CREATE  INDEX [IX_rec4] ON [#temp_detail]([detail_id])

EXEC('
insert into #temp_detail
select recorder_id,channel, cast(left(from_date,8) as datetime),
round(cast(isnull(field1,0) as float)-0.0005,0),
round(cast(isnull(field4,0) as float)-0.0005,0),
round(cast(isnull(field7,0) as float)-0.0005,0),
round(cast(isnull(field10,0) as float)-0.0005,0),
round(cast(isnull(field13,0) as float)-0.0005,0),
round(cast(isnull(field16,0) as float)-0.0005,0),
round(cast(isnull(field19,0) as float)-0.0005,0),
round(cast(isnull(field22,0) as float)-0.0005,0),
round(cast(isnull(field25,0) as float)-0.0005,0),
round(cast(isnull(field28,0) as float)-0.0005,0),
round(cast(isnull(field31,0) as float)-0.0005,0),
round(cast(isnull(field34,0) as float)-0.0005,0),	
detail_id,header11
from '+@temp_table_name)

--- update the data if data exists 
-- update a
-- set 
-- 	a.volume=b.volume 
-- from
-- 	mv90_data a,
-- 	#temp_table b
-- where
-- 	a.recorderid=b.recorderid and
-- 	a.from_date=b.from_date and	
-- 	a.to_date=b.to_date and
-- 	a.channel=b.channel 
-- --------------------------------------------------------------------
-- --insert new values
-- 
-- INSERT 
-- 	into mv90_data(recorderID,gen_date,from_date,to_date,channel,volume,uom_id,descriptions)
-- select
-- 	a.recorderid,a.gen_date,a.from_date,a.to_date,a.channel,a.volume,a.uom_id,a.descriptions
-- from
-- 	#temp_table a
-- 	left join mv90_data b on
-- 	a.recorderid=b.recorderid and	a.from_date=b.from_date and a.to_date=b.to_date and a.channel=b.channel	
-- 	where b.recorderid is null
-------------------------------------------------------------
--insert detail hourly data


create table #temp_Hour(
[id] int,
recorderid varchar(100) COLLATE DATABASE_DEFAULT,channel int,
prod_date datetime,
HR1 float,HR2 float,HR3 float,HR4 float,HR5 float,HR6 float,HR7 float,
HR8 float,HR9 float,HR10 float,HR11 float,HR12 float,HR13 float,HR14 float,HR15 float,HR16 float,HR17 float,
HR18 float,HR19 float,HR20 float,HR21 float,HR22 float,HR23 float,HR24 float,
detail_id int,UOM int)


CREATE  INDEX [IX_HR1] ON [#temp_Hour]([recorderid])                  
CREATE  INDEX [IX_HR2] ON [#temp_Hour]([channel])
CREATE  INDEX [IX_HR3] ON [#temp_Hour]([prod_date])
CREATE  INDEX [IX_HR5] ON [#temp_Hour]([detail_id])


-- delete if exists
delete a
from
	mv90_data_hour a,
	#temp_table b
where
	a.recorderid=b.recorderid and
	--dbo.FNAGETContractMonth(a.prod_date)=dbo.FNAGETContractMonth(b.from_date) and	
	year(dbo.FNAGETContractMonth(a.prod_date))=year(dbo.FNAGETContractMonth(b.from_date)) and	
	a.channel=b.channel		

	
-- insert new values
declare @recorderid varchar(100)
declare @channel int
declare @from_date datetime
declare @detail_id int
declare @count int

declare cur1 cursor for
select 
	recorderid,from_date,channel from #temp_table order by from_date
open cur1

fetch next from cur1 into @recorderid,@from_date,@channel
while @@FETCH_STATUS=0
BEGIN
	set @count=0	
 	declare cur2 cursor for
 	select 
 		detail_id from #temp_detail where recorderid=@recorderid and channel=@channel and from_date=@from_date order by detail_id
 	open cur2
 	
 	fetch next from cur2 into @detail_id
 	while @@FETCH_STATUS=0
 	BEGIN

		insert into #temp_Hour(recorderid,channel,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,detail_id,UOM)
		select @recorderid,@channel,dateadd(day,@count,@from_date),Field1,Field4,Field7,Field10,Field13,Field16,Field19,Field22,Field25,
		Field28,Field31,Field34,detail_id,header11
		from
		#temp_detail 
		where recorderid=@recorderid and channel=@channel 
		and detail_id%2=0 
		and detail_id=@detail_id

		IF @@ROWCOUNT>0
			set @count=@count+1
	   	
	fetch next from cur2 into @detail_id
        END
 	CLOSE cur2
 	DEALLOCATE cur2
	
fetch next from cur1 into @recorderid,@from_date,@channel
END
CLOSE cur1
DEALLOCATE cur1



-- select * from #temp_detail where recorderid='0302124310E01' and channel=4
-- order by detail_id
-- 
-- select * from #temp_hour where recorderid='0302124310E01' and channel=4
-- order by detail_id
--return
--
-- SELECT * FROM #temp_hour
-- SELECT * FROM #temp_detail order by detail_id

---------------------
update a
set 
	Hr13=Field1,
	Hr14=Field4,
	Hr15=Field7,
	Hr16=Field10,
	Hr17=Field13,
	Hr18=Field16,
	Hr19=Field19,
	Hr20=Field22,
	Hr21=Field25,
	Hr22=Field28,
	Hr23=Field31,
	Hr24=Field34
	

from
	#temp_Hour a,
	#temp_detail b
where
	a.recorderid=b.recorderid
	and a.channel=b.channel and
	a.detail_id+1=b.detail_id 
	--and dbo.FNAGETCOntractMonth(a.prod_date)=b.from_date
-------------------------------------

insert into mv90_data_hour(recorderid,channel,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,HR14
,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,UOM_ID) 
select
recorderid,channel,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,HR14
,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,UOM from #temp_Hour

--select * from mv90_data_hour order by prod_date

delete	a
from 
	mv90_data a,
	#temp_table b
where
	a.recorderid=b.recorderid and
	YEAR(a.from_date)=YEAR(b.from_date) and	
	YEAR(a.to_date)=YEAR(b.to_date) and
	a.channel=b.channel 
--------------------------------------------------------------------
--insert new values

INSERT 
	into mv90_data(recorderID,gen_date,from_date,to_date,channel,volume,uom_id)
select
	a.recorderid,dbo.fnagetcontractmonth(prod_date),dbo.fnagetcontractmonth(prod_date),dbo.fnagetcontractmonth(prod_date),a.channel,SUM(HR1+HR2+HR3+HR4+HR5+HR6+HR7+HR8+HR9+HR10+HR11+HR12+HR13+HR14
+HR15+HR16+HR17+HR18+HR19+HR20+HR21+HR22+HR23+HR24),max(a.uom)
from
	#temp_Hour a
	group by recorderid,channel,dbo.fnagetcontractmonth(prod_date)

update a
	set a.descriptions=b.descriptions
from 
	mv90_data a,
	#temp_table b
where
	a.recorderid=b.recorderid and
	YEAR(a.from_date)=YEAR(b.from_date) and	
	YEAR(a.to_date)=YEAR(b.to_date) and
	a.channel=b.channel 

---------------------------
update mv90_data
set to_date=dbo.FNALastDayInDate(to_date)

-----------------------------------------------------

select a.* into #temp_table1
from
	mv90_data a,
	#temp_table b
where
	a.recorderid=b.recorderid and
	YEAR(a.from_date)=YEAR(b.from_date) and	
	YEAR(a.to_date)=YEAR(b.to_date) and
	a.channel=b.channel 


-----------------------------------------------------------------------------------------------------------

if @@error<>0
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Data', 'Run Import' , 'Data Errors', 
	'It is possible that the Data may be incorrect', 'Correct the error and reimport.'      
		


-- check for data. if no data exists then give error
if not exists(select distinct recorderid from 	#temp_table)
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Data', 'Run Import' , 'Data Errors', 'It is possible that the file format may be incorrect', 'Correct the error and reimport.'      


--Check for errors      
  
      
SET @url_desc = 'Detail...'      
SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id +       
	 '&spa=exec spa_get_import_transactions_log ''' + @process_id + ''''      
	           
	      
SELECT  @error_count =   COUNT(*)       
FROM        
	Import_Transactions_Log      
WHERE     
	process_id = @process_id AND code = 'Error'      
	      
If @error_count > 0       
	 BEGIN      
		 BEGIN TRAN      
		 INSERT INTO [Import_Transactions_Log]       
		 (      
		 --[Import_Transaction_log_id],      
		 [process_id] ,      
		 [code],      
		 [module],      
		 [source],      
		 [type] ,      
		 [description],      
		 [nextsteps])      
		 SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Results', 
		'Import/Update Data completed with error(s).', 'Correct error(s) and reimport.'      
		 COMMIT TRAN      
		      
	  	 SET @type = 'e'      
	 END      
Else      

	 BEGIN      
		 BEGIN TRAN      
	
		 INSERT INTO [Import_Transactions_Log]       
		 (      
		 --[Import_Transaction_log_id],      
		 [process_id] ,      
		 [code],      
		 [module],      
		 [source],      
		 [type] ,      
		 [description],      
		 [nextsteps])      
		 SELECT     @process_id, 'Success', 'Import Data', 'Run Import' , 'Results',       
		 'Import/Update Data completed without error for RecorderID: ' + recorderID + ', Channel: ' +       
		 cast(channel as varchar)+ ', Volume: ' +cast(Volume as varchar),  ''      
		 from #temp_table
		 COMMIT TRAN      
		 SET @type = 's'     

--**********************************************************
--------------------New Added to create deal based on mv90 data----------------------------------
--**********************************************************
declare @tempTable varchar(128)
declare @sqlStmt varchar(5000)
declare @strategy_name_for_mv90 varchar(100)
declare @trader varchar(100)
declare @default_uom int
set @strategy_name_for_mv90='PPA'
set @trader='xcelgen'
set @default_uom=24



	set @user_login_id=system_user
	set @process_id=REPLACE(newid(),'-','_')
	set @tempTable=dbo.FNAProcessTableName('deal_invoice', @user_login_id,@process_id)
	
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
	 [leg] [varchar] (20)  NULL )
	'
	exec(@sqlStmt)

set @sqlStmt=
	'
	INSERT INTO '+@tempTable+'
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
		leg
		)
	SELECT 
		max(s.entity_name)+''_''+'''+@strategy_name_for_mv90+'''+''_''+max(sd1.code),
	--	''SUB1_PPA_MN'',
	--	sb.source_book_name,
		''mv90_''+cast(rg.generator_id as varchar)+''_''+dbo.FNAContractMonthFormat(a.from_date),
		dbo.FNAGetSQLStandardDate(a.from_date),
		dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(a.from_date)),
		FLOOR(sum(a.volume)*ISNULL(max(rg.contract_allocation),1)),
		'+cast(@default_uom as varchar)+',
		NULL,
		max(rg.ppa_counterparty_id),
		rg.generator_id,
		''Rec Energy'',
		''m'',
		'''+@trader+''',
		a.from_date,
		''USD'',
		''b'',
		  1	
	from
	     (select recorderid as recorderid,sum(volume*conv.conversion_factor) as volume,max(uom_id) as uom_id 
		,from_date from_date from 
		(select 
	       mv.recorderid as recorderid,
	       (mv.volume-(COALESCE(meter.gre_per,meter1.gre_per,0))*mv.volume) * mult_factor as volume,
	       mv.channel,
	       mult_factor,
	       md.uom_id,
	       dbo.FNAGetContractMonth(mv.from_date) from_date					
	from
		#temp_table1 mv 
		inner join (select recorderid from recorder_generator_map group by recorderid
			having count(distinct generator_id)=1) a
		on mv.recorderid=a.recorderid inner join
		recorder_properties md on mv.recorderid=md.recorderid and md.channel=mv.channel
		left join meter_id_allocation meter on meter.recorderid=mv.recorderid
		 and meter.production_month=mv.from_date
		left join meter_id_allocation meter1 on meter1.recorderid=mv.recorderid 
		where mv.volume>0 
	) a inner join rec_volume_unit_conversion conv on
		a.uom_id=conv.from_source_uom_id and conv.to_source_uom_id='+cast(@default_uom as varchar)+'
		and conv.state_value_id is null and conv.assignment_type_value_id is null
		and conv.curve_id is null 
		group by recorderid,from_date) a 
		inner join recorder_generator_map rgm on rgm.recorderid=a.recorderid
		inner join
		rec_generator rg on rg.generator_id=rgm.generator_id
		inner join static_data_value sd on rg.state_value_id=sd.value_id
	
   		join portfolio_hierarchy s on s.entity_id=rg.legal_entity_value_id
   		left join static_data_value sd1 on sd1.value_id=rg.state_value_id

	group by 
		rg.generator_id,a.from_date


-- 		inner join portfolio_hierarchy b  
-- 		on b.entity_name=sd.code inner join
-- 		portfolio_hierarchy s on b.parent_entity_id=s.entity_id
-- 		and s.entity_name='''+ @strategy_name_for_mv90 +'''  join source_system_book_map ssbm 
-- 		on b.entity_id=ssbm.fas_book_id  join source_book sb 
-- 		on sb.source_book_id=ssbm.source_system_book_id1

'
	--print @sqlStmt
		
	EXEC(@sqlStmt)

	exec spb_process_transactions @user_login_id,@tempTable,'n','y'
---------------------------------------------------------------------------------------------------

END      
	      
	declare @total_count int, @total_count_v varchar(50) 

	set @total_count = 0      
	Select @total_count = count(*) from #temp_table      
	      
	set @total_count_v = cast(isnull(@total_count, 0) as varchar)      
	      
	SET @url_desc = '<a target="_blank" href="' + @url + '">' +       
	  'Import Data processed ' + @total_count_v  + ' record(s) for run date ' + dbo.FNAUserDateFormat(getdate(), @user_login_id) +       

	  case when (@type = 'e') then ' (ERRORS found)' else '' end +      
	  '.</a>'      
	      
	EXEC  spa_message_board 'i', @user_login_id,      
	   NULL, 'Import Transaction ',      
	   @url_desc, '', '', @type, @job_name


