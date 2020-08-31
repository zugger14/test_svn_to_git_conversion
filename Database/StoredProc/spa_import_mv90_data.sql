
IF OBJECT_ID(N'spa_import_mv90_data', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_import_mv90_data]
GO 

CREATE PROCEDURE [dbo].[spa_import_mv90_data]  
	@temp_table_name varchar(100),  
	@table_id varchar(100),  
	@job_name varchar(100),
	@process_id varchar(100),
	@user_login_id varchar(50)
AS  
  
DECLARE @sql varchar(8000)  
  
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
	 recorder_id,
	 max(case when isdate(left(gen_date,10))=1 then dbo.FNAGETContractMonth(cast(left(gen_date,10) as datetime)) else NULL end),  
	 case when isdate(left(from_date,10))=1 then dbo.FNAGETContractMonth(cast(left(from_date,10) as datetime)) else NULL end,  
	 case when isdate(left(to_date,10))=1 then DATEADD(month,1,dbo.FNAGETContractMonth(cast(left(to_date,10) as datetime)))-1 else NULL end,channel,  
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
	where detail_id<10000062
	 group by  
	  recorder_id,case when isdate(left(from_date,10))=1 then dbo.FNAGETContractMonth(cast(left(from_date,10) as datetime)) else NULL end,
	  case when isdate(left(to_date,10))=1 then DATEADD(month,1,dbo.FNAGETContractMonth(cast(left(to_date,10) as datetime)))-1 else NULL end,channel,header11  
	'   
  
EXEC(@sql)  
   

---------------------------------  
create table #temp_detail(  
recorderid varchar(100) COLLATE DATABASE_DEFAULT,channel int,  
from_date datetime,Field1 float,Field4 float,Field7 float,Field10 float,  
Field13 float,Field16 float,Field19 float,Field22 float,Field25 float,  
Field28 float,Field31 float,Field34 float,detail_id int,header11 int,data_missing char(1) COLLATE DATABASE_DEFAULT)  
  
  
CREATE  INDEX [IX_rec1] ON [#temp_detail]([recorderid])                    
CREATE  INDEX [IX_rec2] ON [#temp_detail]([channel])  
CREATE  INDEX [IX_rec3] ON [#temp_detail]([from_date])  
CREATE  INDEX [IX_rec4] ON [#temp_detail]([detail_id])  
  
  
EXEC('  
	insert into #temp_detail  
	select recorder_id,channel, cast(left(from_date,10) as datetime),  
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
	detail_id,header11,
	case when (field2=''9'' or field5=''9'' or field8=''9'' or field11=''9'' or field14=''9'' or field17=''9'' or field20=''9'' or field23=''9'' or 
		   field26=''9'' or field29=''9'' or field32=''9'' or field35=''9'') then ''y'' else ''n'' end 
	from '+@temp_table_name
)  
  
--- update the data if data exists   

update a  
set   
 a.volume=b.volume   
from  
 meter_id mi 
 INNER JOIN mv90_data a ON a.meter_id=mi.meter_id 
 INNER JOIN #temp_table b  ON 
	mi.recorderid=b.recorderid and  
	a.from_date=b.from_date and   
	a.to_date=b.to_date and  
	a.channel=b.channel   

--------------------------------------------------------------------  
--insert new values  


INSERT   
 into mv90_data(meter_id,gen_date,from_date,to_date,channel,volume,uom_id,descriptions)  
select  
 mi.meter_id,dbo.FNAGetContractMonth(a.from_date),dbo.FNAGetContractMonth(a.from_date),dbo.FNAGetContractMonth(a.to_date),a.channel,a.volume,a.uom_id,a.descriptions  
from  
 #temp_table a  
 INNER JOIN meter_id mi ON a.recorderId=mi.recorderid
 left join mv90_data b on  mi.meter_id=b.meter_id and a.from_date=b.from_date and a.channel=b.channel   
 where b.meter_id is null  



-------------------------------------------------------------  


------------------------------------------
--#### insert raw data in the table
---- first delete if data exists
--delete a
--from
--	mv90_data_raw a
--	INNER JOIN meter_id mi ON mi.meter_id=a.meter_id
--	INNER JOIN #temp_table b ON 
--where
--	a.recorder_id=b.recorderid
--	and a.channel=b.channel and a.from_date=b.from_date and a.to_date=b.to_date

---- insert
--set @sql='
--insert into mv90_data_raw(header_id,recorder_id,channel,from_date,to_date,header1,header2,header3,header4,header5,header6,header7,header8,header9,header10,header11,header12,header13,header14,header15,header16,header17,header18,header19,header20,header21,gen_date,header23,detail_id,Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field91,Field10,Field11,Field12,Field13,Field14,Field15,Field16,Field17,Field18,Field19,Field20,Field21,Field22,Field23,Field24,Field25,Field26,Field27,Field28,Field29,Field30,Field31,Field32,Field33,Field34,Field35,Field36,Field37)
--select 
--	header_id,recorder_id,channel,
--	case when isdate(left(from_date,8))=1 then cast(left(from_date,8) as datetime) else NULL end,  
--	case when isdate(left(to_date,8))=1 then cast(left(to_date,8) as datetime) else NULL end,
--	header1,header2,header3,header4,header5,header6,header7,header8,header9,header10,header11,header12,header13,header14,header15,header16,header17,header18,header19,header20,header21,gen_date,header23,detail_id,Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field91,Field10,Field11,Field12,Field13,Field14,Field15,Field16,Field17,Field18,Field19,Field20,Field21,Field22,Field23,Field24,Field25,Field26,Field27,Field28,Field29,Field30,Field31,Field32,Field33,Field34,Field35,Field36,Field37
--from
--	'+@temp_table_name

--Exec(@sql) 

-------------------------------------------------------------- 
--insert detail hourly data  
create table #temp_Hour(  
	[id] int,  
	meter_data_id INT,
	prod_date datetime,  
	HR1 float,HR2 float,HR3 float,HR4 float,HR5 float,HR6 float,HR7 float,  
	HR8 float,HR9 float,HR10 float,HR11 float,HR12 float,HR13 float,HR14 float,HR15 float,HR16 float,HR17 float,  
	HR18 float,HR19 float,HR20 float,HR21 float,HR22 float,HR23 float,HR24 float,  
	detail_id int,UOM int,data_missing char(1) COLLATE DATABASE_DEFAULT,proxy_date datetime
)  
  
CREATE  INDEX [IX_HR1] ON [#temp_Hour]([meter_data_id])                    
CREATE  INDEX [IX_HR3] ON [#temp_Hour]([prod_date])  
CREATE  INDEX [IX_HR5] ON [#temp_Hour]([detail_id])  
  
-- delete if exists  
delete a  
from  
 mv90_data_hour a
 INNER JOIN mv90_data mv ON mv.meter_data_id=a.meter_data_id
 INNER JOIN meter_id mi ON mv.meter_id=mi.meter_id
 INNER JOIN #temp_table b  ON 
	mi.recorderid=b.recorderid and  
	dbo.FNAGETContractMonth(a.prod_date)=dbo.FNAGETContractMonth(b.from_date) and   
	mv.channel=b.channel    
  
--------------------------------------------------------------
delete a  
from  
 mv90_data_proxy a
 INNER JOIN mv90_data mv ON mv.meter_data_id=a.meter_data_id
 INNER JOIN meter_id mi ON mv.meter_id=mi.meter_id
 INNER JOIN #temp_table b  ON
 mi.recorderid=b.recorderid and  
 dbo.FNAGETContractMonth(a.prod_date)=dbo.FNAGETContractMonth(b.from_date) and   
 mv.channel=b.channel    
     
-- insert new values  
  
declare @value float  
declare @recorderid varchar(100)  
declare @channel int  
declare @from_date datetime  
declare @detail_id int  
declare @count int  
declare @DST_hour int  
declare @DST_date datetime  
DECLARE @meter_data_id INT

	

declare cur1 cursor for  
  
  
	select   
		a.recorderid,a.from_date,a.channel,mv.meter_data_id 
	 from 
	 #temp_table a
 	 INNER JOIN meter_id mi ON a.recorderid=mi.recorderid
	 INNER JOIN mv90_data mv ON mi.meter_id=mv.meter_id
		AND mv.from_date=a.from_date
		AND mv.channel=a.channel   
	order by a.from_date
open cur1  
  
fetch next from cur1 into @recorderid,@from_date,@channel,@meter_data_id   
while @@FETCH_STATUS=0  
BEGIN  
	 set @count=0   

	  declare cur2 cursor for  
	  select   
	   detail_id from #temp_detail where recorderid=@recorderid and channel=@channel and dbo.fnagetcontractmonth(from_date)=@from_date  order by detail_id
	  open cur2  

	    
	  fetch next from cur2 into @detail_id  
	  while @@FETCH_STATUS=0  
	  BEGIN  
	  
			  insert into #temp_Hour(meter_data_id,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,detail_id,UOM)  
			  select @meter_data_id ,dateadd(day,@count,@from_date),Field1,Field4,Field7,Field10,Field13,Field16,Field19,Field22,Field25,  
			  Field28,Field31,Field34,detail_id,header11
			  from  
			  #temp_detail   
			  where recorderid=@recorderid and channel=@channel   
			  and detail_id%2=0   
			  and detail_id=@detail_id  
		 	-- END  
		  
		  IF @@ROWCOUNT>0  
		   set @count=@count+1  
	       
	 fetch next from cur2 into @detail_id  
	        END  
	  CLOSE cur2  
	  DEALLOCATE cur2  
	   
fetch next from cur1 into @recorderid,@from_date,@channel,@meter_data_id     
END  
CLOSE cur1  
DEALLOCATE cur1  
  
  

  
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
	 Hr24=Field34,
	 a.data_missing=b.data_missing  
   

from  
 #temp_Hour a
 INNER JOIN mv90_data mv ON a.meter_data_id=mv.meter_data_id
 INNER JOIN meter_id mi ON mi.meter_id=mv.meter_id
 INNER JOIN #temp_detail b ON
	 mi.recorderid=b.recorderid  
	 and mv.channel=b.channel and  
	 a.detail_id+1=b.detail_id and  
	 dbo.FNAGETCOntractMonth(a.prod_date)=dbo.FNAGETCOntractMonth(b.from_date)  
-------------------------------------  


--##### insert missing data into table
create table #temp_missing_data(
	meter_data_id INT,
	prod_date datetime,
	min_date datetime,
	proxy_date datetime
)
		
insert into #temp_missing_data(
	meter_data_id,
	prod_date,
	min_date,
	proxy_date
)
select 
	a.meter_data_id,a.prod_date,b.min_date,
	case when dbo.FNALastDayInMonth(a.prod_date)-day(b.min_date)>9 then 
		case when dbo.FNALastDayInMonth(dateadd(month,-1,a.prod_date))>dbo.FNALastDayInMonth(a.prod_date) then dateadd(month,-1,a.prod_date+1)
      	  	     when dbo.FNALastDayInMonth(dateadd(month,-1,a.prod_date))<dbo.FNALastDayInMonth(a.prod_date) then dateadd(month,-1,a.prod_date-1)
		     else dateadd(month,-1,a.prod_date) end
	else a.prod_date-(dbo.FNALastDayInMonth(a.prod_date)-day(b.min_date)+1) end as proxy_date
	
from
	#temp_hour a inner join 
	(select meter_data_id,min(prod_date)as min_date from #temp_hour where data_missing='y' group by meter_data_id) b
	on a.meter_data_id=b.meter_data_id
where
	a.data_missing='y'


---
update a
set
	a.proxy_date=c.proxy_date

from
	#temp_Hour a inner join #temp_missing_data c on a.meter_data_id=c.meter_data_id
	and a.prod_date=c.prod_date
	left join mv90_data_hour b on b.meter_data_id=c.meter_data_id and 
	b.prod_date=c.proxy_date
	left join #temp_Hour d on d.meter_data_id=c.meter_data_id and 
	d.prod_date=c.proxy_date
	
-- insert into poxy table
insert into mv90_data_proxy(meter_data_id,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,HR14  
	,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,UOM_ID,data_missing,proxy_date) 
select 
	a.meter_data_id,a.prod_date,ISNULL(b.HR1,d.HR1),
	ISNULL(b.HR1,d.HR1),ISNULL(b.HR2,d.HR2),ISNULL(b.HR3,d.HR3),ISNULL(b.HR4,d.HR4),ISNULL(b.HR5,d.HR5),ISNULL(b.HR6,d.HR6),ISNULL(b.HR7,d.HR7),
	ISNULL(b.HR8,d.HR8),ISNULL(b.HR9,d.HR9),ISNULL(b.HR10,d.HR10),ISNULL(b.HR11,d.HR11),ISNULL(b.HR12,d.HR12),ISNULL(b.HR13,d.HR13),
	ISNULL(b.HR14,d.HR14),ISNULL(b.HR15,d.HR15),
	ISNULL(b.HR16,d.HR16),ISNULL(b.HR17,d.HR17),ISNULL(b.HR18,d.HR18),ISNULL(b.HR19,d.HR19),ISNULL(b.HR20,d.HR21),ISNULL(b.HR22,d.HR22),
	ISNULL(b.HR23,d.HR23),ISNULL(b.HR24,d.HR24),
	a.UOM,'y',a.proxy_date 
	
from
	#temp_Hour a inner join #temp_missing_data c on a.meter_data_id=c.meter_data_id
	and a.prod_date=c.prod_date
	left join mv90_data_hour b on b.meter_data_id=c.meter_data_id and 
	b.prod_date=c.proxy_date
	left join #temp_Hour d on d.meter_data_id=c.meter_data_id and 
	d.prod_date=c.proxy_date

----------------------------------------
--## Log error for all the missing data to show in the message board
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
 'Some data missing for recorderid: '+mi.recorderid+', channel: '+cast(mv.channel as varchar)+', from date: '+cast(dbo.FNADATEFORMAT(min_date) as varchar), ' Calculations will be based on estimation logic.'        
from
	(select meter_data_id,min_date from #temp_missing_data group by meter_data_id,min_date) a
	INNER JOIN mv90_data mv ON mv.meter_data_id=a.meter_data_id
	INNER JOIN meter_id mi ON mi.meter_id=mv.meter_id
order by mi.recorderid,mv.channel,a.min_date


----------------
---##### now create a logic to insert a proxy date
-- insert into main table  
insert into mv90_data_hour(meter_data_id,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,HR14  
	,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,UOM_ID,data_missing,proxy_date)   
select  
	meter_data_id,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,HR14  
	,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,UOM,data_missing,proxy_date 
from 
	#temp_Hour  


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
if not exists(select distinct recorderid from  #temp_table)  
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
declare @url_desc varchar(250)  
declare @url varchar(250)  
DECLARE @error_count int        
DECLARE @type char        
        
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
END
--**********************************************************  
--------------------New Added to create deal based on mv90 data----------------------------------  
--**********************************************************  
/*
declare @tempTable varchar(128)  
declare @sqlStmt varchar(5000)  
declare @strategy_name_for_mv90 varchar(100)  
declare @trader varchar(100)  
declare @default_uom int  
set @strategy_name_for_mv90='PPA'  
set @trader='xcelgen'  
set @default_uom=24  
  
  
  
 set @user_login_id=@user_login_id
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
  [leg] [varchar] (20)  NULL  , 
  [settlement_volume] varchar(100),
  [settlement_uom] varchar(100))
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
	  leg,
	  settlement_volume,
	  settlement_uom  
	  )  
	 SELECT   
	  max(s.entity_name)+''_''+'''+@strategy_name_for_mv90+'''+''_''+max(sd1.code),  
	 -- ''SUB1_PPA_MN'',  
	 -- sb.source_book_name,  
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
	    1 ,
	   sum(settlement_volume)*ISNULL(max(rg.contract_allocation),1),
	   max(uom_id)	
	    	  
	 from  
	      (select recorderid as recorderid,sum(volume*conv.conversion_factor) as volume,max(uom_id) as uom_id,sum(volume) as settlement_volume,   
	  max(from_date) from_date from   
	  (select   
	        mv.recorderid as recorderid,  
	        (mv.volume-(COALESCE(meter.gre_per,meter1.gre_per,0))*mv.volume) * mult_factor as volume,  
	        mv.channel,  
	        mult_factor,  
	        md.uom_id,  
	        dbo.FNAGetContractMonth(mv.from_date) from_date       
	 from  
	  #temp_table mv   
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
	  group by recorderid) a   
	  inner join recorder_generator_map rgm on rgm.recorderid=a.recorderid  
	  inner join  
	  rec_generator rg on rg.generator_id=rgm.generator_id  
	  inner join static_data_value sd on rg.state_value_id=sd.value_id  
	      join portfolio_hierarchy s on s.entity_id=rg.legal_entity_value_id  
	     left join static_data_value sd1 on sd1.value_id=rg.state_value_id  
	 group by   
	  rg.generator_id,a.from_date  
	  
	--   inner join portfolio_hierarchy b    
	--   on b.entity_name=sd.code inner join  
	--   portfolio_hierarchy s on b.parent_entity_id=s.entity_id  
	--   and s.entity_name='''+ @strategy_name_for_mv90 +'''  join source_system_book_map ssbm   
	--   on b.entity_id=ssbm.fas_book_id  join source_book sb   
	--   on sb.source_book_id=ssbm.source_system_book_id1    
'   
    
 EXEC(@sqlStmt)  
  
 exec spb_process_transactions @user_login_id,@tempTable,'n','y'  
---------------------------------------------------------------------------------------------------  
*/        
         
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
  
  
















