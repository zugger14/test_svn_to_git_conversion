
IF OBJECT_ID(N'[dbo].[spa_import_mv90_data_mins]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_mv90_data_mins]
GO
CREATE procedure [dbo].[spa_import_mv90_data_mins]  
@temp_table_name varchar(100),  
@table_id varchar(100),  
  
@job_name varchar(100),  
  
@process_id varchar(100),  
  
@user_login_id varchar(50)  
  
AS  
  
DECLARE @sql varchar(8000)  
DECLARE @round_digit int

SET @round_digit=5
-----------------------------------------------------  
create table #temp_table
	(  
		 temp_id int identity(1,1),  
		 recorderId varchar(50) COLLATE DATABASE_DEFAULT,  
		 gen_date datetime,  
		 from_date datetime,  
		 to_date datetime,  
		 channel int,  
		 volume Money,  
		 uom_id int,  
		 descriptions varchar(500) COLLATE DATABASE_DEFAULT   
	)  
  

CREATE  INDEX [IX_recs1] ON [#temp_table]([recorderid])                    
CREATE  INDEX [IX_recs2] ON [#temp_table]([channel])  
CREATE  INDEX [IX_recs3] ON [#temp_table]([from_date])  
CREATE  INDEX [IX_recs4] ON [#temp_table]([to_date])  
CREATE  INDEX [IX_recs5] ON [#temp_table]([gen_date])  
  
  
set @sql='  
	INSERT INTO #temp_table
		(
			recorderID,gen_date,from_date,to_date,channel,volume,uom_id,descriptions
		)  
	select   
		 recorder_id,
		 max(case when isdate(left(gen_date,8))=1 then cast(left(gen_date,8) as datetime) else NULL end),  
		 dbo.fnagetcontractmonth(cast(from_date as datetime)),
		 dateadd(month,+1,dbo.fnagetcontractmonth(cast(to_date as datetime)))-1,
		 channel,  
		 sum(
		 ROUND(cast(isnull(field1,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field4,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND( cast(isnull(field7,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field10,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field13,0.0005) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field16,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field19,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field22,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field25,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field28,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field31,0) as float),'+cast(@round_digit as varchar)+')  +  
		 ROUND(cast(isnull(field34,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field37,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field40,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field43,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field46,0) as float),'+cast(@round_digit as varchar)+')  +
 		 ROUND(cast(isnull(field49,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field52,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field55,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field58,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field61,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field64,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field67,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field70,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field73,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field76,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field79,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field82,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field85,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field88,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field91,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field94,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field97,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field100,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field103,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field106,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field109,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field112,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field115,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field118,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field121,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field124,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field130,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field133,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field136,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field139,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field142,0) as float),'+cast(@round_digit as varchar)+')  +
		 ROUND(cast(isnull(field145,0) as float),'+cast(@round_digit as varchar)+') ),
		 header11,max(header19)  
	 from  
	  '+@temp_table_name+'  
	group by  
		recorder_id,dbo.fnagetcontractmonth(cast(from_date as datetime)),
		dbo.fnagetcontractmonth(cast(to_date as datetime)),channel,header11  
	'   

EXEC(@sql)  



---------------------------------  
create table #temp_detail(  
recorderid varchar(100) COLLATE DATABASE_DEFAULT,channel int,  
from_date datetime,Field1 float,Field4 float,Field7 float,Field10 float,  
Field13 float,Field16 float,Field19 float,Field22 float,Field25 float,  
Field28 float,Field31 float,Field34 float,Field37 float,Field40 float,Field43 float,Field46 float,
Field49 float,Field52 float,Field55 float,Field58 float,Field61 float,Field64 float,Field67 float,
Field70 float,Field73 float,Field76 float,Field79 float,Field82 float,Field85 float,Field88 float,
Field91 float,Field94 float,Field97 float,Field100 float,Field103 float,Field106 float,Field109 float,
Field112 float,Field115 float,Field118 float,Field121 float,Field124 float,Field127 float,Field130 float,
Field133 float,Field136 float,Field139 float,Field142 float,Field145 float,
detail_id int,header11 int,data_missing char(1) COLLATE DATABASE_DEFAULT)  
  
  
CREATE  INDEX [IX_rec1] ON [#temp_detail]([recorderid])                    
CREATE  INDEX [IX_rec2] ON [#temp_detail]([channel])  
CREATE  INDEX [IX_rec3] ON [#temp_detail]([from_date])  
CREATE  INDEX [IX_rec4] ON [#temp_detail]([detail_id])  
  
set @sql= 

'	insert into #temp_detail  
	select recorder_id,channel, 
	--cast(left(from_date,8) as datetime),  
	cast(left(from_date,10) as datetime),  
	case when field2=''9'' then NULL else  round(cast(isnull(field1,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field5=''9'' then NULL else  round(cast(isnull(field4,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field8=''9'' then NULL else  round(cast(isnull(field7,0) as float) ,'+cast(@round_digit as varchar)+') end,  
	case when field11=''9'' then NULL else  round(cast(isnull(field10,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field14=''9'' then NULL else  round(cast(isnull(field13,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field17=''9'' then NULL else  round(cast(isnull(field16,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field20=''9'' then NULL else  round(cast(isnull(field19,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field23=''9'' then NULL else  round(cast(isnull(field22,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field26=''9'' then NULL else  round(cast(isnull(field25,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field29=''9'' then NULL else  round(cast(isnull(field28,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field32=''9'' then NULL else  round(cast(isnull(field31,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field35=''9'' then NULL else  round(cast(isnull(field34,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field38=''9'' then NULL else  round(cast(isnull(field37,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field41=''9'' then NULL else  round(cast(isnull(field40,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field44=''9'' then NULL else  round(cast(isnull(field43,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field47=''9'' then NULL else  round(cast(isnull(field46,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field50=''9'' then NULL else  round(cast(isnull(field49,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field53=''9'' then NULL else  round(cast(isnull(field52,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field56=''9'' then NULL else  round(cast(isnull(field55,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field59=''9'' then NULL else  round(cast(isnull(field58,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field62=''9'' then NULL else  round(cast(isnull(field61,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field65=''9'' then NULL else  round(cast(isnull(field64,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field68=''9'' then NULL else  round(cast(isnull(field67,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field71=''9'' then NULL else  round(cast(isnull(field70,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field74=''9'' then NULL else  round(cast(isnull(field73,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field77=''9'' then NULL else  round(cast(isnull(field76,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field80=''9'' then NULL else  round(cast(isnull(field79,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field83=''9'' then NULL else  round(cast(isnull(field82,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field86=''9'' then NULL else  round(cast(isnull(field85,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field89=''9'' then NULL else  round(cast(isnull(field88,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field92=''9'' then NULL else  round(cast(isnull(field91,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field95=''9'' then NULL else  round(cast(isnull(field94,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field98=''9'' then NULL else  round(cast(isnull(field97,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field101=''9'' then NULL else  round(cast(isnull(field100,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field104=''9'' then NULL else  round(cast(isnull(field103,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field107=''9'' then NULL else  round(cast(isnull(field106,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field110=''9'' then NULL else  round(cast(isnull(field109,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field113=''9'' then NULL else  round(cast(isnull(field112,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field116=''9'' then NULL else  round(cast(isnull(field115,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field119=''9'' then NULL else  round(cast(isnull(field118,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field122=''9'' then NULL else  round(cast(isnull(field121,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field125=''9'' then NULL else  round(cast(isnull(field124,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field128=''9'' then NULL else  round(cast(isnull(field127,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field131=''9'' then NULL else  round(cast(isnull(field130,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field134=''9'' then NULL else  round(cast(isnull(field133,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field137=''9'' then NULL else  round(cast(isnull(field136,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field140=''9'' then NULL else  round(cast(isnull(field139,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field143=''9'' then NULL else  round(cast(isnull(field142,0) as float),'+cast(@round_digit as varchar)+')  end,  
	case when field145=''9'' then NULL else  round(cast(isnull(field145,0) as float),'+cast(@round_digit as varchar)+')  end,  
	detail_id,header11,
	case when (field2=''9'' or field5=''9'' or field8=''9'' or field11=''9'' or field14=''9'' or field17=''9'' or field20=''9''
	or field23=''9'' or	field26=''9'' or field29=''9'' or field32=''9'' or field35=''9'' or field38=''9''
	or field41=''9'' or field44=''9'' or field47=''9'' or field50=''9'' or field53=''9'' or field56=''9''
	or field59=''9'' or field62=''9'' or field65=''9'' or field68=''9'' or field71=''9'' or field74=''9'' 
	or field77=''9'' or field80=''9'' or field83=''9'' or field86=''9'' or field89=''9'' or field92=''9'' 
	or field95=''9'' or field98=''9'' or field101=''9'' or field104=''9'' or field107=''9'' or field110=''9'' 
	or field113=''9'' or field116=''9'' or field119=''9'' or field122=''9'' or field125=''9'' or field128=''9''
	or field131=''9'' or field134=''9'' or field137=''9'' or field140=''9'' or field143=''9''
	) then ''y'' else ''n'' end 
	from '+@temp_table_name



--print @sql
EXEC(@sql)


--- update the data if data exists   


--update a  
--set   
-- a.volume=b.volume   
--from  
-- mv90_data a,  
-- #temp_table b  
--where  
-- a.recorderid=b.recorderid and  
-- a.from_date=b.from_date and   
-- a.to_date=b.to_date and  
-- a.channel=b.channel   

--------------------------------------------------------------------  
--insert new values  
 
--INSERT   
-- into mv90_data(recorderID,gen_date,from_date,to_date,channel,volume,uom_id,descriptions)  
--select  
-- a.recorderid,ISNULL(a.gen_date,a.from_date),a.from_date,a.to_date,a.channel,a.volume,a.uom_id,a.descriptions  
--from  
-- #temp_table a  
-- left join mv90_data b on  
-- a.recorderid=b.recorderid and a.from_date=b.from_date and a.to_date=b.to_date and a.channel=b.channel   
-- where b.recorderid is null  


-------------------------------------------------------------  

------------------------------------------
--#### insert raw data in the table
-- first delete if data exists
/*
delete a
from
	mv90_data_raw a,
	#temp_table b
where
	a.recorder_id=b.recorderid
	and a.channel=b.channel and a.from_date=b.from_date and a.to_date=b.to_date

-- insert
set @sql='
insert into mv90_data_raw(header_id,recorder_id,channel,from_date,to_date,header1,header2,header3,header4,header5,header6,header7,header8,header9,header10,header11,header12,header13,header14,header15,header16,header17,header18,header19,header20,header21,gen_date,header23,detail_id,Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field91,Field10,Field11,Field12,Field13,Field14,Field15,Field16,Field17,Field18,Field19,Field20,Field21,Field22,Field23,Field24,Field25,Field26,Field27,Field28,Field29,Field30,Field31,Field32,Field33,Field34,Field35,Field36,Field37)
select 
	header_id,recorder_id,channel,
	case when isdate(left(from_date,8))=1 then cast(left(from_date,8) as datetime) else NULL end,  
	case when isdate(left(to_date,8))=1 then cast(left(to_date,8) as datetime) else NULL end,
	header1,header2,header3,header4,header5,header6,header7,header8,header9,header10,header11,header12,header13,header14,header15,header16,header17,header18,header19,header20,header21,gen_date,header23,detail_id,Field1,Field2,Field3,Field4,Field5,Field6,Field7,Field8,Field91,Field10,Field11,Field12,Field13,Field14,Field15,Field16,Field17,Field18,Field19,Field20,Field21,Field22,Field23,Field24,Field25,Field26,Field27,Field28,Field29,Field30,Field31,Field32,Field33,Field34,Field35,Field36,Field37
from
	'+@temp_table_name

Exec(@sql) 
*/


-------------------------------------------------------------- 
--insert detail hourly data  
create table #temp_Hour(  
	[id] int,  
	recorderid varchar(100) COLLATE DATABASE_DEFAULT,channel int,  
	prod_date datetime,  
	Hr1_15 float,Hr1_30 float,Hr1_45 float,Hr1_60 float,
	Hr2_15 float,Hr2_30 float,Hr2_45 float,Hr2_60 float,
	Hr3_15 float,Hr3_30 float,Hr3_45 float,Hr3_60 float,
	Hr4_15 float,Hr4_30 float,Hr4_45 float,Hr4_60 float,
	Hr5_15 float,Hr5_30 float,Hr5_45 float,Hr5_60 float,
	Hr6_15 float,Hr6_30 float,Hr6_45 float,Hr6_60 float,
	Hr7_15 float,Hr7_30 float,Hr7_45 float,Hr7_60 float,  
	Hr8_15 float,Hr8_30 float,Hr8_45 float,Hr8_60 float,
	Hr9_15 float,Hr9_30 float,Hr9_45 float,Hr9_60 float,
	Hr10_15 float,Hr10_30 float,Hr10_45 float,Hr10_60 float,
	Hr11_15 float,Hr11_30 float,Hr11_45 float,Hr11_60 float,
	Hr12_15 float,Hr12_30 float,Hr12_45 float,Hr12_60 float,
	Hr13_15 float,Hr13_30 float,Hr13_45 float,Hr13_60 float,
	Hr14_15 float,Hr14_30 float,Hr14_45 float,Hr14_60 float,
	Hr15_15 float,Hr15_30 float,Hr15_45 float,Hr15_60 float,
	Hr16_15 float,Hr16_30 float,Hr16_45 float,Hr16_60 float,
	Hr17_15 float,Hr17_30 float,Hr17_45 float,Hr17_60 float,  
	Hr18_15 float,Hr18_30 float,Hr18_45 float,Hr18_60 float,
	Hr19_15 float,Hr19_30 float,Hr19_45 float,Hr19_60 float,
	Hr20_15 float,Hr20_30 float,Hr20_45 float,Hr20_60 float,
	Hr21_15 float,Hr21_30 float,Hr21_45 float,Hr21_60 float,
	Hr22_15 float,Hr22_30 float,Hr22_45 float,Hr22_60 float,
	Hr23_15 float,Hr23_30 float,Hr23_45 float,Hr23_60 float,
	Hr24_15 float,Hr24_30 float,Hr24_45 float,Hr24_60 float,  
	detail_id int,UOM int,data_missing char(1) COLLATE DATABASE_DEFAULT,proxy_date datetime
)  
  
CREATE  INDEX [IX_Hr1] ON [#temp_Hour]([recorderid])                    
CREATE  INDEX [IX_Hr2] ON [#temp_Hour]([channel])  
CREATE  INDEX [IX_Hr3] ON [#temp_Hour]([prod_date])  
CREATE  INDEX [IX_Hr5] ON [#temp_Hour]([detail_id])  
  
-- delete if exists  



 

--------------------------------------------------------------
--delete a  
--from  
-- mv90_data_proxy_mins a,  
-- #temp_table b  
--where  
-- a.recorderid=b.recorderid and  
-- dbo.FNAGETContractMonth(a.prod_date)=dbo.FNAGETContractMonth(b.from_date) and   
-- a.channel=b.channel    
     
-- insert new values  

  
declare @value float  
declare @recorderid varchar(100)  
declare @channel int  
declare @from_date datetime  
declare @detail_id int  
declare @count int  
declare @DST_hour int  
declare @DST_date datetime  
  
--declare cur1 cursor for  
--  
--select   
-- recorderid,from_date,channel from #temp_table  order by from_date
--open cur1  
--  
--fetch next from cur1 into @recorderid,@from_date,@channel  
--while @@FETCH_STATUS=0  
--BEGIN  
--	 set @count=0   
--	  declare cur2 cursor for  
--	  select   
--	   detail_id from #temp_detail where recorderid=@recorderid and channel=@channel 
--	   and dbo.fnagetcontractmonth(from_date)=@from_date  order by detail_id
--	  open cur2  
--
--	    
--	  fetch next from cur2 into @detail_id  
--	  while @@FETCH_STATUS=0  
--	  BEGIN  
	  
		    insert into #temp_Hour(recorderid,channel,prod_date,
			Hr1_15,Hr1_30,Hr1_45,Hr1_60,
			Hr2_15,Hr2_30,Hr2_45,Hr2_60,
			Hr3_15,Hr3_30,Hr3_45,Hr3_60,
			Hr4_15,Hr4_30,Hr4_45,Hr4_60,
			Hr5_15,Hr5_30,Hr5_45,Hr5_60,
			Hr6_15,Hr6_30,Hr6_45,Hr6_60,
			Hr7_15,Hr7_30,Hr7_45,Hr7_60,
			Hr8_15,Hr8_30,Hr8_45,Hr8_60,
			Hr9_15,Hr9_30,Hr9_45,Hr9_60,
			Hr10_15,Hr10_30,Hr10_45,Hr10_60,
			Hr11_15,Hr11_30,Hr11_45,Hr11_60,
			Hr12_15,Hr12_30,Hr12_45,Hr12_60,
			detail_id,UOM,data_missing	)  
		    select recorderid,channel,from_date,
			Field1,Field4,Field7,Field10,
			Field13,Field16,Field19,Field22,
			Field25,Field28,Field31,Field34,
			Field37,Field40,Field43,Field46,
			Field49,Field52,Field55,Field58,
			Field61,Field64,Field67,Field70,
			Field73,Field76,Field79,Field82,
			Field85,Field88,Field91,Field94,
			Field97,Field100,Field103,Field106,
			Field109,Field112,Field115,Field118,
			Field121,Field124,Field127,Field130,
			Field133,Field136,Field139,Field142,
			
			detail_id,header11,data_missing
			  from  
			  #temp_detail   
			  where 
			  --recorderid=@recorderid and channel=@channel and   
			  detail_id%2=0   
			  --and detail_id=@detail_id  
		 	-- END  
		  
--		  IF @@ROWCOUNT>0  
--		   set @count=@count+1  
--	       
--	 fetch next from cur2 into @detail_id  
--	        END  
--	  CLOSE cur2  
--	  DEALLOCATE cur2  
--	   
--fetch next from cur1 into @recorderid,@from_date,@channel  
--END  
--CLOSE cur1  
--DEALLOCATE cur1  
  


-- select * from #temp_detail where recorderid='0302124310E01' and channel=4  
-- order by detail_id  
--   
-- select * from #temp_hour where recorderid='0302124310E01' and channel=4  
-- order by detail_id  
--return  


---------------------  
update a  
set   
	Hr13_15=Field1,Hr13_30=Field4,Hr13_45=Field7,Hr13_60=Field10,  
	Hr14_15=Field13,Hr14_30=Field16,Hr14_45=Field19,Hr14_60=Field22,
	Hr15_15=Field25,Hr15_30=Field28,Hr15_45=Field31,Hr15_60=Field34,
	Hr16_15=Field37,Hr16_30=Field40,Hr16_45=Field43,Hr16_60=Field46,
	Hr17_15=Field49,Hr17_30=Field52,Hr17_45=Field55,Hr17_60=Field58,
	Hr18_15=Field61,Hr18_30=Field64,Hr18_45=Field67,Hr18_60=Field70,
	Hr19_15=Field73,Hr19_30=Field76,Hr19_45=Field79,Hr19_60=Field82,
	Hr20_15=Field85,Hr20_30=Field88,Hr20_45=Field91,Hr20_60=Field94,
	Hr21_15=Field97,Hr21_30=Field100,Hr21_45=Field103,Hr21_60=Field106,
	Hr22_15=Field109,Hr22_30=Field112,Hr22_45=Field115,Hr22_60=Field118,
	Hr23_15=Field121,Hr23_30=Field124,Hr23_45=Field127,Hr23_60=Field130,
	Hr24_15=Field133,Hr24_30=Field136,Hr24_45=Field139,Hr24_60=Field142,
	a.data_missing=(case when a.data_missing='y' then 'y' else b.data_missing end) 
   
  
from  
 #temp_Hour a,  
 #temp_detail b  
where  
 a.recorderid=b.recorderid  
 and a.channel=b.channel and  
 a.detail_id+1=b.detail_id and  
-- dbo.FNAGETCOntractMonth(a.prod_date)=dbo.FNAGETCOntractMonth(b.from_date)  
 a.prod_date=b.from_date
-------------------------------------  

--select * from #temp_Hour
--return


--##### insert missing data into table
create table #temp_missing_data(
	recorderid varchar(100) COLLATE DATABASE_DEFAULT,
	channel int,
	prod_date datetime,
	min_date datetime,
	proxy_date datetime
)
		
--insert into #temp_missing_data(
--	recorderid,
--	channel,
--	prod_date,
--	min_date,
--	proxy_date
--)
--select 
--	a.recorderid,a.channel,a.prod_date,b.min_date,
--	case when dbo.FNALastDayInMonth(a.prod_date)-day(b.min_date)>9 then 
--		case when dbo.FNALastDayInMonth(dateadd(month,-1,a.prod_date))>dbo.FNALastDayInMonth(a.prod_date) then dateadd(month,-1,a.prod_date+1)
--      	  	     when dbo.FNALastDayInMonth(dateadd(month,-1,a.prod_date))<dbo.FNALastDayInMonth(a.prod_date) then dateadd(month,-1,a.prod_date-1)
--		     else dateadd(month,-1,a.prod_date) end
--	else a.prod_date-(dbo.FNALastDayInMonth(a.prod_date)-day(b.min_date)+1) end as proxy_date
--	
--from
--	#temp_hour a inner join 
--	(select recorderid,channel,min(prod_date)as min_date from #temp_hour where data_missing='y' group by recorderid,channel)b
--	on a.recorderid=b.recorderid and a.channel=b.channel
--where
--	a.data_missing='y'


---
update a
set
	a.proxy_date=c.proxy_date

from
	#temp_Hour a inner join #temp_missing_data c on a.recorderid=c.recorderid
	and a.channel=c.channel and a.prod_date=c.prod_date
	left join mv90_data_mins b on b.recorderid=c.recorderid and b.channel=c.channel and 
	b.prod_date=c.proxy_date
	left join #temp_Hour d on d.recorderid=c.recorderid and d.channel=c.channel and 
	d.prod_date=c.proxy_date
	
-- insert into poxy table
/*
insert into mv90_data_proxy_mins(recorderid,channel,prod_date,
	Hr1_15 ,Hr1_30 ,Hr1_45 ,Hr1_60 ,
	Hr2_15 ,Hr2_30 ,Hr2_45 ,Hr2_60 ,
	Hr3_15 ,Hr3_30 ,Hr3_45 ,Hr3_60 ,
	Hr4_15 ,Hr4_30 ,Hr4_45 ,Hr4_60 ,
	Hr5_15 ,Hr5_30 ,Hr5_45 ,Hr5_60 ,
	Hr6_15 ,Hr6_30 ,Hr6_45 ,Hr6_60 ,
	Hr7_15 ,Hr7_30 ,Hr7_45 ,Hr7_60 ,  
	Hr8_15 ,Hr8_30 ,Hr8_45 ,Hr8_60 ,
	Hr9_15 ,Hr9_30 ,Hr9_45 ,Hr9_60 ,
	Hr10_15 ,Hr10_30 ,Hr10_45 ,Hr10_60 ,
	Hr11_15 ,Hr11_30 ,Hr11_45 ,Hr11_60 ,
	Hr12_15 ,Hr12_30 ,Hr12_45 ,Hr12_60 ,
	Hr13_15 ,Hr13_30 ,Hr13_45 ,Hr13_60 ,
	Hr14_15 ,Hr14_30 ,Hr14_45 ,Hr14_60 ,
	Hr15_15 ,Hr15_30 ,Hr15_45 ,Hr15_60 ,
	Hr16_15 ,Hr16_30 ,Hr16_45 ,Hr16_60 ,
	Hr17_15 ,Hr17_30 ,Hr17_45 ,Hr17_60 ,  
	Hr18_15 ,Hr18_30 ,Hr18_45 ,Hr18_60 ,
	Hr19_15 ,Hr19_30 ,Hr19_45 ,Hr19_60 ,
	Hr20_15 ,Hr20_30 ,Hr20_45 ,Hr20_60 ,
	Hr21_15 ,Hr21_30 ,Hr21_45 ,Hr21_60 ,
	Hr22_15 ,Hr22_30 ,Hr22_45 ,Hr22_60 ,
	Hr23_15 ,Hr23_30 ,Hr23_45 ,Hr23_60 ,
	Hr24_15 ,Hr24_30 ,Hr24_45 ,Hr24_60 , 
	UOM_ID,data_missing,proxy_date) 
select 
	a.recorderid,a.channel,a.prod_date,
	ISNULL(b.Hr1_15,d.Hr1_15),ISNULL(b.Hr1_30,d.Hr1_30),ISNULL(b.Hr1_45,d.Hr1_45),ISNULL(b.Hr1_60,d.Hr1_60),
	ISNULL(b.Hr2_15,d.Hr2_15),ISNULL(b.Hr2_30,d.Hr2_30),ISNULL(b.Hr2_45,d.Hr2_45),ISNULL(b.Hr2_60,d.Hr2_60),
	ISNULL(b.Hr3_15,d.Hr3_15),ISNULL(b.Hr3_30,d.Hr3_30),ISNULL(b.Hr3_45,d.Hr3_45),ISNULL(b.Hr3_60,d.Hr3_60),
	ISNULL(b.Hr4_15,d.Hr4_15),ISNULL(b.Hr4_30,d.Hr4_30),ISNULL(b.Hr4_45,d.Hr4_45),ISNULL(b.Hr4_60,d.Hr4_60),
	ISNULL(b.Hr5_15,d.Hr5_15),ISNULL(b.Hr5_30,d.Hr5_30),ISNULL(b.Hr5_45,d.Hr5_45),ISNULL(b.Hr5_60,d.Hr5_60),
	ISNULL(b.Hr6_15,d.Hr6_15),ISNULL(b.Hr6_30,d.Hr6_30),ISNULL(b.Hr6_45,d.Hr6_45),ISNULL(b.Hr6_60,d.Hr6_60),
	ISNULL(b.Hr7_15,d.Hr7_15),ISNULL(b.Hr7_30,d.Hr7_30),ISNULL(b.Hr7_45,d.Hr7_45),ISNULL(b.Hr7_60,d.Hr7_60),
	ISNULL(b.Hr8_15,d.Hr8_15),ISNULL(b.Hr8_30,d.Hr8_30),ISNULL(b.Hr8_45,d.Hr8_45),ISNULL(b.Hr8_60,d.Hr8_60),
	ISNULL(b.Hr9_15,d.Hr9_15),ISNULL(b.Hr9_30,d.Hr9_30),ISNULL(b.Hr9_45,d.Hr9_45),ISNULL(b.Hr9_60,d.Hr9_60),
	ISNULL(b.Hr10_15,d.Hr10_15),ISNULL(b.Hr10_30,d.Hr10_30),ISNULL(b.Hr10_45,d.Hr10_45),ISNULL(b.Hr10_60,d.Hr10_60),
	ISNULL(b.Hr11_15,d.Hr11_15),ISNULL(b.Hr11_30,d.Hr11_30),ISNULL(b.Hr11_45,d.Hr11_45),ISNULL(b.Hr11_60,d.Hr11_60),
	ISNULL(b.Hr12_15,d.Hr12_15),ISNULL(b.Hr12_30,d.Hr12_30),ISNULL(b.Hr12_45,d.Hr12_45),ISNULL(b.Hr12_60,d.Hr12_60),
	ISNULL(b.Hr13_15,d.Hr13_15),ISNULL(b.Hr13_30,d.Hr13_30),ISNULL(b.Hr13_45,d.Hr13_45),ISNULL(b.Hr13_60,d.Hr13_60),
	ISNULL(b.Hr14_15,d.Hr14_15),ISNULL(b.Hr14_30,d.Hr14_30),ISNULL(b.Hr14_45,d.Hr14_45),ISNULL(b.Hr14_60,d.Hr14_60),
	ISNULL(b.Hr15_15,d.Hr15_15),ISNULL(b.Hr15_30,d.Hr15_30),ISNULL(b.Hr15_45,d.Hr15_45),ISNULL(b.Hr15_60,d.Hr15_60),
	ISNULL(b.Hr16_15,d.Hr16_15),ISNULL(b.Hr16_30,d.Hr16_30),ISNULL(b.Hr16_45,d.Hr16_45),ISNULL(b.Hr16_60,d.Hr16_60),
	ISNULL(b.Hr17_15,d.Hr17_15),ISNULL(b.Hr17_30,d.Hr17_30),ISNULL(b.Hr17_45,d.Hr17_45),ISNULL(b.Hr17_60,d.Hr17_60),
	ISNULL(b.Hr18_15,d.Hr18_15),ISNULL(b.Hr18_30,d.Hr18_30),ISNULL(b.Hr18_45,d.Hr18_45),ISNULL(b.Hr18_60,d.Hr18_60),
	ISNULL(b.Hr19_15,d.Hr19_15),ISNULL(b.Hr19_30,d.Hr19_30),ISNULL(b.Hr19_45,d.Hr19_45),ISNULL(b.Hr19_60,d.Hr19_60),
	ISNULL(b.Hr20_15,d.Hr20_15),ISNULL(b.Hr20_30,d.Hr20_30),ISNULL(b.Hr20_45,d.Hr20_45),ISNULL(b.Hr20_60,d.Hr20_60),
	ISNULL(b.Hr21_15,d.Hr21_15),ISNULL(b.Hr21_30,d.Hr21_30),ISNULL(b.Hr21_45,d.Hr21_45),ISNULL(b.Hr21_60,d.Hr21_60),
	ISNULL(b.Hr22_15,d.Hr22_15),ISNULL(b.Hr22_30,d.Hr22_30),ISNULL(b.Hr22_45,d.Hr22_45),ISNULL(b.Hr22_60,d.Hr22_60),
	ISNULL(b.Hr23_15,d.Hr23_15),ISNULL(b.Hr23_30,d.Hr23_30),ISNULL(b.Hr23_45,d.Hr23_45),ISNULL(b.Hr23_60,d.Hr23_60),
	ISNULL(b.Hr24_15,d.Hr24_15),ISNULL(b.Hr24_30,d.Hr24_30),ISNULL(b.Hr24_45,d.Hr24_45),ISNULL(b.Hr24_60,d.Hr24_60),
	a.UOM,'y',a.proxy_date 
from
	#temp_Hour a inner join #temp_missing_data c on a.recorderid=c.recorderid
	and a.channel=c.channel and a.prod_date=c.prod_date
	left join mv90_data_mins b on b.recorderid=c.recorderid and b.channel=c.channel and 
	b.prod_date=c.proxy_date
	left join #temp_Hour d on d.recorderid=c.recorderid and d.channel=c.channel and 
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
 'Some data missing for RecorderID: ' + ISNULL(a.recorderID,'') + ', Channel: ' +         
   cast(ISNULL(channel,'') as varchar)+ ', Counterparty:'+ISNULL(sc.counterparty_name,'')+',Prod Month: '+ISNULL(dbo.fnacontractmonthformat(a.min_date),'')+'&nbsp;',  ''       
from
	(select recorderid,channel,min_date from #temp_missing_data group by recorderid,channel,min_date) a
   left join recorder_generator_map rgm on rgm.recorderid=a.recorderid
   left join rec_generator rg on rg.generator_id=rgm.generator_id
   left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id
order by a.recorderid,a.channel,a.min_date


*/
/*
select  
	recorderid,channel,prod_date,
	Hr1_15 ,Hr1_30 ,Hr1_45 ,Hr1_60 ,
	Hr2_15 ,Hr2_30 ,Hr2_45 ,Hr2_60 ,
	Hr3_15 ,Hr3_30 ,Hr3_45 ,Hr3_60 ,
	Hr4_15 ,Hr4_30 ,Hr4_45 ,Hr4_60 ,
	Hr5_15 ,Hr5_30 ,Hr5_45 ,Hr5_60 ,
	Hr6_15 ,Hr6_30 ,Hr6_45 ,Hr6_60 ,
	Hr7_15 ,Hr7_30 ,Hr7_45 ,Hr7_60 ,  
	Hr8_15 ,Hr8_30 ,Hr8_45 ,Hr8_60 ,
	Hr9_15 ,Hr9_30 ,Hr9_45 ,Hr9_60 ,
	Hr10_15 ,Hr10_30 ,Hr10_45 ,Hr10_60 ,
	Hr11_15 ,Hr11_30 ,Hr11_45 ,Hr11_60 ,
	Hr12_15 ,Hr12_30 ,Hr12_45 ,Hr12_60 ,
	Hr13_15 ,Hr13_30 ,Hr13_45 ,Hr13_60 ,
	Hr14_15 ,Hr14_30 ,Hr14_45 ,Hr14_60 ,
	Hr15_15 ,Hr15_30 ,Hr15_45 ,Hr15_60 ,
	Hr16_15 ,Hr16_30 ,Hr16_45 ,Hr16_60 ,
	Hr17_15 ,Hr17_30 ,Hr17_45 ,Hr17_60 ,  
	Hr18_15 ,Hr18_30 ,Hr18_45 ,Hr18_60 ,
	Hr19_15 ,Hr19_30 ,Hr19_45 ,Hr19_60 ,
	Hr20_15 ,Hr20_30 ,Hr20_45 ,Hr20_60 ,
	Hr21_15 ,Hr21_30 ,Hr21_45 ,Hr21_60 ,
	Hr22_15 ,Hr22_30 ,Hr22_45 ,Hr22_60 ,
	Hr23_15 ,Hr23_30 ,Hr23_45 ,Hr23_60 ,
	Hr24_15 ,Hr24_30 ,Hr24_45 ,Hr24_60 , 
	UOM,data_missing,proxy_date 
from 
	#temp_Hour
*/
--select * from mv90_data_mins
----------------
---##### now create a logic to insert a proxy date
-- insert into main table  
delete a  
from  
 mv90_data_mins a,  
 #temp_Hour b  
where  
 a.recorderid=b.recorderid
 --and dbo.FNAGETContractMonth(a.prod_date)=dbo.FNAGETContractMonth(b.from_date) and   
 and a.prod_date=b.prod_date
 and a.channel=b.channel   

set @sql = 'insert into mv90_data_mins(recorderid,channel,prod_date,
	Hr1_15 ,Hr1_30 ,Hr1_45 ,Hr1_60 ,
	Hr2_15 ,Hr2_30 ,Hr2_45 ,Hr2_60 ,
	Hr3_15 ,Hr3_30 ,Hr3_45 ,Hr3_60 ,
	Hr4_15 ,Hr4_30 ,Hr4_45 ,Hr4_60 ,
	Hr5_15 ,Hr5_30 ,Hr5_45 ,Hr5_60 ,
	Hr6_15 ,Hr6_30 ,Hr6_45 ,Hr6_60 ,
	Hr7_15 ,Hr7_30 ,Hr7_45 ,Hr7_60 ,  
	Hr8_15 ,Hr8_30 ,Hr8_45 ,Hr8_60 ,
	Hr9_15 ,Hr9_30 ,Hr9_45 ,Hr9_60 ,
	Hr10_15 ,Hr10_30 ,Hr10_45 ,Hr10_60 ,
	Hr11_15 ,Hr11_30 ,Hr11_45 ,Hr11_60 ,
	Hr12_15 ,Hr12_30 ,Hr12_45 ,Hr12_60 ,
	Hr13_15 ,Hr13_30 ,Hr13_45 ,Hr13_60 ,
	Hr14_15 ,Hr14_30 ,Hr14_45 ,Hr14_60 ,
	Hr15_15 ,Hr15_30 ,Hr15_45 ,Hr15_60 ,
	Hr16_15 ,Hr16_30 ,Hr16_45 ,Hr16_60 ,
	Hr17_15 ,Hr17_30 ,Hr17_45 ,Hr17_60 ,  
	Hr18_15 ,Hr18_30 ,Hr18_45 ,Hr18_60 ,
	Hr19_15 ,Hr19_30 ,Hr19_45 ,Hr19_60 ,
	Hr20_15 ,Hr20_30 ,Hr20_45 ,Hr20_60 ,
	Hr21_15 ,Hr21_30 ,Hr21_45 ,Hr21_60 ,
	Hr22_15 ,Hr22_30 ,Hr22_45 ,Hr22_60 ,
	Hr23_15 ,Hr23_30 ,Hr23_45 ,Hr23_60 ,
	Hr24_15 ,Hr24_30 ,Hr24_45 ,Hr24_60 , 
	UOM_ID,data_missing,proxy_date)   
select  
	recorderid,channel,prod_date,
	Hr1_15 ,Hr1_30 ,Hr1_45 ,Hr1_60 ,
	Hr2_15 ,Hr2_30 ,Hr2_45 ,Hr2_60 ,
	Hr3_15 ,Hr3_30 ,Hr3_45 ,Hr3_60 ,
	Hr4_15 ,Hr4_30 ,Hr4_45 ,Hr4_60 ,
	Hr5_15 ,Hr5_30 ,Hr5_45 ,Hr5_60 ,
	Hr6_15 ,Hr6_30 ,Hr6_45 ,Hr6_60 ,
	Hr7_15 ,Hr7_30 ,Hr7_45 ,Hr7_60 ,  
	Hr8_15 ,Hr8_30 ,Hr8_45 ,Hr8_60 ,
	Hr9_15 ,Hr9_30 ,Hr9_45 ,Hr9_60 ,
	Hr10_15 ,Hr10_30 ,Hr10_45 ,Hr10_60 ,
	Hr11_15 ,Hr11_30 ,Hr11_45 ,Hr11_60 ,
	Hr12_15 ,Hr12_30 ,Hr12_45 ,Hr12_60 ,
	Hr13_15 ,Hr13_30 ,Hr13_45 ,Hr13_60 ,
	Hr14_15 ,Hr14_30 ,Hr14_45 ,Hr14_60 ,
	Hr15_15 ,Hr15_30 ,Hr15_45 ,Hr15_60 ,
	Hr16_15 ,Hr16_30 ,Hr16_45 ,Hr16_60 ,
	Hr17_15 ,Hr17_30 ,Hr17_45 ,Hr17_60 ,  
	Hr18_15 ,Hr18_30 ,Hr18_45 ,Hr18_60 ,
	Hr19_15 ,Hr19_30 ,Hr19_45 ,Hr19_60 ,
	Hr20_15 ,Hr20_30 ,Hr20_45 ,Hr20_60 ,
	Hr21_15 ,Hr21_30 ,Hr21_45 ,Hr21_60 ,
	Hr22_15 ,Hr22_30 ,Hr22_45 ,Hr22_60 ,
	Hr23_15 ,Hr23_30 ,Hr23_45 ,Hr23_60 ,
	Hr24_15 ,Hr24_30 ,Hr24_45 ,Hr24_60 , 
	UOM,data_missing,proxy_date 
from 
	#temp_Hour'

EXEC spa_print @sql
exec(@sql)



--select * from mv90_data_mins

--return
--select * from mv90_data_mins

--select * from #temp_Hour
/*
select  
	recorderid,channel,prod_date,
	Hr1_15 ,Hr1_30 ,Hr1_45 ,Hr1_60 ,
	Hr2_15 ,Hr2_30 ,Hr2_45 ,Hr2_60 ,
	Hr3_15 ,Hr3_30 ,Hr3_45 ,Hr3_60 ,
	Hr4_15 ,Hr4_30 ,Hr4_45 ,Hr4_60 ,
	Hr5_15 ,Hr5_30 ,Hr5_45 ,Hr5_60 ,
	Hr6_15 ,Hr6_30 ,Hr6_45 ,Hr6_60 ,
	Hr7_15 ,Hr7_30 ,Hr7_45 ,Hr7_60 ,  
	Hr8_15 ,Hr8_30 ,Hr8_45 ,Hr8_60 ,
	Hr9_15 ,Hr9_30 ,Hr9_45 ,Hr9_60 ,
	Hr10_15 ,Hr10_30 ,Hr10_45 ,Hr10_60 ,
	Hr11_15 ,Hr11_30 ,Hr11_45 ,Hr11_60 ,
	Hr12_15 ,Hr12_30 ,Hr12_45 ,Hr12_60 ,
	Hr13_15 ,Hr13_30 ,Hr13_45 ,Hr13_60 ,
	Hr14_15 ,Hr14_30 ,Hr14_45 ,Hr14_60 ,
	Hr15_15 ,Hr15_30 ,Hr15_45 ,Hr15_60 ,
	Hr16_15 ,Hr16_30 ,Hr16_45 ,Hr16_60 ,
	Hr17_15 ,Hr17_30 ,Hr17_45 ,Hr17_60 ,  
	Hr18_15 ,Hr18_30 ,Hr18_45 ,Hr18_60 ,
	Hr19_15 ,Hr19_30 ,Hr19_45 ,Hr19_60 ,
	Hr20_15 ,Hr20_30 ,Hr20_45 ,Hr20_60 ,
	Hr21_15 ,Hr21_30 ,Hr21_45 ,Hr21_60 ,
	Hr22_15 ,Hr22_30 ,Hr22_45 ,Hr22_60 ,
	Hr23_15 ,Hr23_30 ,Hr23_45 ,Hr23_60 ,
	Hr24_15 ,Hr24_30 ,Hr24_45 ,Hr24_60 , 
	UOM_ID,data_missing,proxy_date 
from 
	mv90_data_mins
*/
--return
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

--select recorderid from #temp_Hour

-- Sum 15 mins data and insert it into hourly table CODE START

delete a  
from  
 mv90_data_hour a,  
 #temp_detail b  
where  
 a.recorderid=b.recorderid
 -- and dbo.FNAGETContractMonth(a.prod_date)=dbo.FNAGETContractMonth(b.from_date) and   
 and a.prod_date=b.from_date
 and a.channel=b.channel



--select * from mv90_data_hour
--return

set @sql = '
	insert into mv90_data_hour(recorderid,channel,prod_date,
	Hr1, Hr2, Hr3, Hr4,
	Hr5, Hr6, Hr7, Hr8,
	Hr9, Hr10, Hr11, Hr12,
	Hr13, Hr14, Hr15, Hr16,
	Hr17, Hr18, Hr19, Hr20,
	Hr21, Hr22, Hr23, Hr24,
	UOM_ID,data_missing,proxy_date)

	select  
	recorderid, channel, prod_date,
	sum(Hr1_15 + Hr1_30 + Hr1_45 + Hr1_60),
	sum(Hr2_15 + Hr2_30 + Hr2_45 + Hr2_60),
	sum(Hr3_15 + Hr3_30 + Hr3_45 + Hr3_60),
	sum(Hr4_15 + Hr4_30 + Hr4_45 + Hr4_60),
	sum(Hr5_15 + Hr5_30 + Hr5_45 + Hr5_60),
	sum(Hr6_15 + Hr6_30 + Hr6_45 + Hr6_60),
	sum(Hr7_15 + Hr7_30 + Hr7_45 + Hr7_60),
	sum(Hr8_15 + Hr8_30 + Hr8_45 + Hr8_60),
	sum(Hr9_15 + Hr9_30 + Hr9_45 + Hr9_60),
	sum(Hr10_15 + Hr10_30 + Hr10_45 + Hr10_60),
	sum(Hr11_15 + Hr11_30 + Hr11_45 + Hr11_60),
	sum(Hr12_15 + Hr12_30 + Hr12_45 + Hr12_60),
	sum(Hr13_15 + Hr13_30 + Hr13_45 + Hr13_60),
	sum(Hr14_15 + Hr14_30 + Hr14_45 + Hr14_60),
	sum(Hr15_15 + Hr15_30 + Hr15_45 + Hr15_60),
	sum(Hr16_15 + Hr16_30 + Hr16_45 + Hr16_60),
	sum(Hr17_15 + Hr17_30 + Hr17_45 + Hr17_60),
	sum(Hr18_15 + Hr18_30 + Hr18_45 + Hr18_60),
	sum(Hr19_15 + Hr19_30 + Hr19_45 + Hr19_60),
	sum(Hr20_15 + Hr20_30 + Hr20_45 + Hr20_60),
	sum(Hr21_15 + Hr21_30 + Hr21_45 + Hr21_60),
	sum(Hr22_15 + Hr22_30 + Hr22_45 + Hr22_60),
	sum(Hr23_15 + Hr23_30 + Hr23_45 + Hr23_60),
	sum(Hr24_15 + Hr24_30 + Hr24_45 + Hr24_60),
	UOM,data_missing,proxy_date 
from 
	#temp_Hour 
group by  recorderid, channel,prod_date, UOM, data_missing, proxy_date'
EXEC spa_print @sql
exec (@sql)



--######## Now Delete and insert into mv90_Data
DELETE a 
from  
 mv90_data a,  
 #temp_table b  
where  
 a.recorderid=b.recorderid and  a.channel=b.channel
 and a.from_date=b.from_date 
-----
insert into mv90_data(recorderid,gen_date,from_date,to_date,channel,uom_id,descriptions,volume)
select a.recorderid,a.from_date,a.from_date,a.to_date,a.channel,max(a.uom_id),max(a.descriptions),
	  sum(b.HR1+b.HR2+b.HR3+b.HR4+b.HR5+b.HR6+b.HR7+b.HR8+b.HR9+b.HR10+
		b.HR11+b.HR12+b.HR13+b.HR14+b.HR15+b.HR16+b.HR17+b.HR18+b.HR19+b.HR20+	
		b.HR21+b.HR22+b.HR23+b.HR24)
from
		#temp_table a,
		mv90_data_hour b
where
	a.recorderid=b.recorderid and a.channel=b.channel
	and a.from_date=dbo.fnagetcontractmonth(b.prod_date) 
group by 
	a.recorderid,a.channel,a.from_date,a.to_date


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

-- -- Sum 15 mins data and insert it into hourly table CODE END
    
  
  
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
   'Import/Update Data completed without error for RecorderID: ' + ISNULL(tmp.recorderID,'') + ', Channel: ' +         
   cast(ISNULL(channel,'') as varchar)+ ', Counterparty:'+ISNULL(sc.counterparty_name,'')+',Prod Month: '+ISNULL(dbo.fnacontractmonthformat(tmp.from_date),'')+', Volume: ' +cast(ISNULL(Volume,'') as varchar(100))+'&nbsp;',  ''        
   from #temp_table tmp
   left join recorder_generator_map rgm on rgm.recorderid=tmp.recorderid
   left join rec_generator rg on rg.generator_id=rgm.generator_id
   left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id	 
   COMMIT TRAN        
   SET @type = 's'        
END


--**********************************************************  
--------------------New Added to create deal based on mv90 data----------------------------------  
--**********************************************************  
-------------------------------------------------------------------------------

declare @tempTable varchar(100)  
declare @sqlStmt varchar(5000)  
declare @strategy_name_for_mv90 varchar(100)  
declare @trader varchar(100)  
declare @default_uom int  
declare @xcel_owned_counterparty int

set @xcel_owned_counterparty=201
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
	   --max(s.entity_name)+''_''+'''+@strategy_name_for_mv90+'''+''_''+max(sd1.code), 
		max(s.entity_name)+''_''+case when max(rg.ppa_counterparty_id)='+cast(@xcel_owned_counterparty as varchar)+' then ''Owned'' else ''PPA'' end +''_''+max(sd1.code), 
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
		--where mv.volume>0  
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
	where 1=1
	 and a.volume>0
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
  
-- exec spb_process_transactions @user_login_id,@tempTable,'n','y'  

---------------------------------------------------------------------------------------------------  
        
         
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






/****** Object:  StoredProcedure [dbo].[spa_contract_group_detail]    Script Date: 06/18/2008 11:06:15 ******/
SET ANSI_NULLS ON


