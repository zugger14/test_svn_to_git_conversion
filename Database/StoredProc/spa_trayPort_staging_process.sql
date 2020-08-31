
IF OBJECT_ID('spa_trayport_staging_process') IS NOT NULL
drop PROCEDURE [dbo].[spa_trayport_staging_process] 
GO 
/****** Object:  StoredProcedure [dbo].[spa_trayport_staging_process]    Script Date: 03/29/2012 17:09:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM dbo.Trayport_Staging_Error
--DROP TABLE adiha_process.dbo.report_position_sa_C2542F4A_AEFE_4ED1_B3EE_F0EBC9C26DDF
--spa_trayPort_staging_process '70390677_0EC1_4C21_93FD_A8C0364146B1','y'  
create PROCEDURE [dbo].[spa_trayport_staging_process]  
@process_id varchar(150),  
@adhoc_call char(1)=NULL,  --- y from Import window Staging, 's' means manually term start/term end
@temp_table VARCHAR(150)=null
As  
--RETURN
----- TEST
--declare @process_id varchar(150),  @temp_table VARCHAR(150) ,@adhoc_call char(1)

--set @process_id='70390677_0EC1_4C21_93FD_A8C0364146B1'
----set @adhoc_call='s'
--DROP TABLE #temp1
--DROP TABLE #week_more 
--DROP TABLE #temp_term 
----TEST 

declare @temptbl varchar(1000)  
declare @user_login_id varchar(100)  
declare @call_imp_engine varchar(1000)  
declare @tblname varchar(1000)  
declare @sql varchar(5000),@msg VARCHAR(5000)  
  
create table #temp1(table_name varchar(200) COLLATE DATABASE_DEFAULT)  
insert #temp1  
exec spa_import_temp_table '4028' --new 5 columns added format  
  
declare @tName varchar(500),@staging_table_name varchar(100)  
select @tName=table_name from #temp1  
  
set @user_login_id=dbo.FNADBUser()  
   
declare @source_system_id varchar(10),@source_system VARCHAR(50),  
@tray_port_RWE_ID VARCHAR(5),@source_system_book_id1 VARCHAR(150)  
SET @source_system='FARRMS'  
SET @tray_port_RWE_ID='26'  
SET @source_system_book_id1='Trayport_outstanding_book'  
select @source_system_id=source_system_id from source_system_description where source_system_Name=@source_system  
DECLARE @start_ts datetime  
DECLARE @elapsed_time float  
SET @start_ts = GETDATE()  
  
DECLARE @xml_filename VARCHAR(100)  
  DECLARE @staging_sno int
  
if @adhoc_call is NULL  
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Trayport_Staging WHERE process_id = @process_id)
	BEGIN
		--if <TRADE Action="Query", such file won't be processed and won't be loaded in staging table, which makes staging table empty. 
		--In such case, no message is required in either message board or audit log report.
		SELECT 'e' [status]
		RETURN
	END
	ELSE
	BEGIN
		SELECT TOP 1 @xml_filename=xml_fileName FROM Trayport_Staging WHERE process_id=@process_id  
		SET @staging_table_name = 'Trayport_Staging'   
		SET @msg ='Process from XML file: ' + @xml_filename  
	END
END
ELSE if @adhoc_call='s'
begin  
 SELECT TOP 1 @staging_sno=staging_sno,@xml_filename=xml_fileName FROM Trayport_Staging_Error WHERE process_id=@process_id  
 set @staging_table_name='Trayport_Staging_Error'    
 SET @msg='Manually Term mapping define: ' + @xml_filename  
 set @process_id=dbo.FNAGetNewID()
 UPDATE dbo.Trayport_Staging_Error SET process_id=@process_id   WHERE staging_sno=@staging_sno
end 
ELSE    
BEGIN  
 SET @msg='Manually Import from Staging Table'  
 set @staging_table_name='Trayport_Staging_Error'   
 update Trayport_Staging_Error set process_id=@process_id  
   
END   

-----------Log Audit  
set @sql='insert import_data_files_audit(dir_path,  
     imp_file_name,  
     as_of_date,  
     status,  
     elapsed_time,  
     process_id,  
     create_user,  
     create_ts,  
     source_system_id)  
   SELECT ''TrayPort'','''+  
     @msg +''','''+  
     convert(varchar,getdate(),102) +''',''p'',  
     0,'''+ @process_id +''',  
     '''+ @user_login_id +''','''+  
     convert(varchar,getdate(),120) +''','''+  
     @source_system_id +''''  
exec(@sql)  
  
---- Delete from Error Log  
SET @sql = 'DELETE source_deal_error_log  
   FROM source_deal_error_log l  
   INNER JOIN '+ @staging_table_name +' t ON l.deal_id = t.trade_id'     
exec spa_print @sql  
EXEC (@sql)  

---------Check if RWEST Company ID
set @sql='insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation)         
  select '''+ @process_id +''',''Error'',''Import Data'',''Data Error'',''TrayPort Import'',''File does not contain RWEST Data.'' ,''Aggressor/Initiator must be Rwest ID:'+ @tray_port_RWE_ID +' ''  
  from '+@staging_table_name+' t WHERE aggressorCompanyID <> '+@tray_port_RWE_ID+' and initiatorCompanyID <>'+@tray_port_RWE_ID+' '  
exec spa_print @sql  
EXEC (@sql)
IF @@ROWCOUNT>0 
BEGIN
	EXEC('delete '+@staging_table_name+'  WHERE aggressorCompanyID <> '+@tray_port_RWE_ID+' and initiatorCompanyID <>'+@tray_port_RWE_ID)
END
------------Check Deal Template  
set @sql='insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation)         
  select '''+ @process_id +''',''Error'',''Import Data'',''Deal Template'',''TrayPort Import'',''Deal Template ''+t.InstName +'' not found.'' ,''Create Deal Template and re-run''  
  from '+@staging_table_name+' t left outer join source_deal_header_template ht on  
  t.InstName=ht.template_name WHERE ht.template_id IS NULL and t.action in (''Insert'',''Update'')  
  GROUP BY t.instName'  
exec spa_print @sql  
EXEC (@sql)    
   
set @sql='  
  insert into source_system_data_import_status_detail(process_id,source,type,[description])       
  select '''+ @process_id +''',''Deal Template'',''Error'',''For Deal Id:''+ t.Trade_id+'', Deal Template ''+t.InstName +'' not found.'' from   
  '+@staging_table_name+' t left outer join source_deal_header_template ht on  
 t.InstName=ht.template_name WHERE ht.template_id IS NULL  and t.action in (''Insert'',''Update'')'  
exec spa_print @sql  
EXEC (@sql)    
   
set @sql='  
  INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)      
  SELECT convert(varchar,getdate(),102), t.Trade_id, ''Deal Template'', NULL, ''Deal Template ''+t.InstName +'' not found.''    
  from '+@staging_table_name+' t left outer join source_deal_header_template ht on  
  t.InstName=ht.template_name WHERE ht.template_id IS NULL  and t.action in (''Insert'',''Update'')'  
exec spa_print @sql  
EXEC (@sql)      

IF ISNULL(@adhoc_call,'n') <>'s' ---if not manually entry Term 
begin      
					  ------------Check Term Map  
					set @sql='  
					  insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation)         
					  select '''+ @process_id +''',''Error'',''Import Data'',''Term_Map'',''TrayPort Import'',''Term Map ''+t.FirstSequenceItemName +'' not found.'' ,
					  dbo.FNAHyperLinkText(10103110,''Create ''+t.FirstSequenceItemName,''''''term_map_id=NULL&mode=i'''''') +'' OR ''+
					  dbo.FNAHyperLinkText(10103120,''Create Manual'',''''''trade_id=''+trade_id +'''''''')   
					  from '+@staging_table_name+' t left outer join term_map_detail ht on  
					  t.FirstSequenceItemName=ht.term_code WHERE ht.term_code IS NULL and t.action in (''Insert'',''Update'')  
					  GROUP BY t.FirstSequenceItemName,trade_id '  
					exec spa_print @sql  
					EXEC (@sql)  

					set @sql='  
					 insert into source_system_data_import_status_detail(process_id,source,type,[description])       
					  select '''+ @process_id +''',''Term_Map'',''Error'',''For Deal Id:''+ t.Trade_id+'', Term Map ''+t.FirstSequenceItemName +'' not found.''   
					  from '+@staging_table_name+' t left outer join term_map_detail ht on  
					  t.FirstSequenceItemName=ht.term_code WHERE ht.term_code IS NULL and t.action in (''Insert'',''Update'')'  
					exec spa_print @sql  
					EXEC (@sql)  
					  
					set @sql='  
					  INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)      
					  SELECT convert(varchar,getdate(),102), t.Trade_id, ''Term_Map'', NULL, ''Term Map ''+t.FirstSequenceItemName +'' not found.''    
					  from '+@staging_table_name+' t left outer join term_map_detail ht on  
					  t.FirstSequenceItemName=ht.term_code WHERE ht.term_code IS NULL and t.action in (''Insert'',''Update'')'  
					exec spa_print @sql  
					EXEC (@sql)  
					    
						  EXEC spa_print '--- Calc Term----'  
					CREATE TABLE #week_more(
						block_value_id INT,
						weekday INT,
						val int
					)

					INSERT #week_more(weekday,val)
					SELECT 8,0
					UNION
					SELECT 9,0
					UNION
					SELECT 10,0
					UNION
					SELECT 11,0

					  CREATE TABLE #temp_term(  
					  sno INT IDENTITY(1,1),
					 [Terms] [datetime] NULL,  
					 [active_date] [int] NOT NULL,  
					 [relative_term_start] [datetime] NULL,  
					 [relative_term_end] [datetime] NULL,  
					 [term_start] [datetime] NULL,  
					 [term_end] [datetime] NULL,  
					 [trade_Id] [varchar](50) COLLATE DATABASE_DEFAULT NULL,  
					 [date_or_block] [char](1) COLLATE DATABASE_DEFAULT NULL,
					 no_of_days INT NULL  
					) ON [PRIMARY]  
					    
					set @sql='    
					  INSERT #temp_term([Terms]  
							   ,[active_date]  
							   ,[relative_term_start]  
							   ,[relative_term_end]  
							   ,[term_start]  
							   ,[term_end]  
							   ,[trade_Id]  
							   ,[date_or_block]
							   ,no_of_days)  
					  SELECT CASE WHEN t.date_or_block=''b'' THEN   
					DATEADD(d, CASE WHEN weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME))<0 THEN  
					(weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME)))  
					ELSE weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME)) END,DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME))  
					ELSE NULL END Terms,  
					ISNULL(CASE WHEN hg.hol_date IS NOT NULL THEN   
					CASE WHEN ISNULL(t.holiday_include_exclude,''i'')=''i'' THEN 1 ELSE 0 END   
					ELSE val END,1) active_date,  
					CASE WHEN t.date_or_block=''r'' THEN DATEADD(d,ISNULL(t.relative_days,0),ts.DATETIME) ELSE NULL end relative_term_start,  
					CASE WHEN t.date_or_block=''r'' THEN  DATEADD(d,ISNULL(t.no_of_days,0),DATEADD(d,ISNULL(t.relative_days,0),ts.DATETIME)) ELSE NULL END relative_term_end,  
					CASE WHEN t.date_or_block=''m'' THEN  dbo.FNAGetNextAvailDate(DATEADD(d,ISNULL(t.relative_days,1),ts.DATETIME),1,t.holiday_calendar_id )
					 ELSE  dbo.FNAGetNextAvailDate(t.term_start,1,t.holiday_calendar_id )  END term_start,
					CASE WHEN t.date_or_block=''m'' THEN  dbo.FNAGetTermEndDate(''m'',ts.DATETIME,0) ELSE t.term_end END term_end,
					ts.trade_Id,t.date_or_block,t.no_of_days    
					FROM '+@staging_table_name+'  ts join term_map_detail t   
					on ts.FirstSequenceItemName=t.term_code 
					outer  apply (
					SELECT  block_value_id,weekday,val FROM (
						SELECT w.block_value_id,tw.weekday AS weekday,w.val FROM #week_more tw JOIN working_days w
						ON tw.weekday-7=w.weekday AND w.block_value_id=t.working_day_id
						UNION ALL 
						SELECT block_value_id,weekday,val FROM dbo.working_days 
						WHERE block_value_id=t.working_day_id
						) a
					)wd 
					LEFT OUTER JOIN dbo.holiday_group hg  
					ON DATEADD(d, CASE 
	 					WHEN weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME))<0 
	 						THEN  (weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME)))  
							ELSE weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME)) END, DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME))=hg.hol_date   
					AND hol_group_value_id=t.holiday_calendar_id  
					where CASE WHEN t.date_or_block=''b'' THEN  DATEADD(d, CASE WHEN weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME))<0 THEN  
					(weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME)))  
					ELSE weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME)) END,DATEADD(wk,ISNULL(t.relative_days,0),ts.DATETIME))  
					ELSE DATEADD(d,1,ts.DATETIME)  END > ts.DATETIME 
					order by terms  
					'  
					exec spa_print @sql  
					EXEC (@sql)  
		
					 /*BOM Term start = Trade date + 2 days	
						UNLESS Trade date + 2 days = sunday, in that case Term start = Trade date + 3 days (= monday)
						*/		
					 UPDATE #temp_term
					 SET term_start = CASE WHEN DATEPART(w, term_start) = 1 THEN DATEADD(d, 1, term_start) ELSE term_start END
					 WHERE date_or_block = 'm'							
					
					DECLARE @first_1 INT,@last_0 INT,@no_of_days INT
					SELECT TOP 1 @first_1=sno,@no_of_days=no_of_days  FROM #temp_term t WHERE active_date=1 ORDER BY sno 
					SELECT TOP 1 @last_0=sno FROM #temp_term t WHERE active_date=0 AND sno > @first_1 ORDER BY sno 
					if @last_0 is null 
						select @last_0=MAX(sno)+1 FROM #temp_term t WHERE sno > @first_1
									
					DELETE #temp_term WHERE sno NOT IN (SELECT sno  FROM #temp_term WHERE (sno >=@first_1 AND sno < isNUll(@last_0,@first_1))) 
					and exists(select * from #temp_term  WHERE (sno >=@first_1 and sno <isNUll(@last_0,@first_1)))
					AND terms IS NOT NULL
					
					
					IF ISNULL(@no_of_days,0) > 0
					BEGIN
						EXEC('delete  #temp_term where sno not in (SELECT TOP '+ @no_of_days +' sno FROM #temp_term ORDER by active_date DESC,terms)')
					END 
				
					  set @sql='  
					 update '+@staging_table_name+' set term_start=convert(varchar,ht.term_start,111) , term_end=convert(varchar,ht.term_end,111)  
					 from '+@staging_table_name+' t join (select trade_id,MIN(CASE WHEN date_or_block=''b'' then terms  
						 WHEN date_or_block=''r'' THEN relative_term_start   
						 WHEN date_or_block IN (''d'',''m'') THEN term_start   
						 ELSE NULL  
						 END   
						 ) term_start,MAX(CASE WHEN date_or_block=''b'' then terms  
						 WHEN date_or_block=''r'' THEN relative_term_end  
						 WHEN date_or_block IN (''d'',''m'') THEN term_end  ELSE NULL  
						 END) term_end from        
						 #temp_term where [active_date]=1 group by trade_id) ht on t.trade_id=ht.trade_id  
					 where  t.action in (''Insert'',''Update'')  
					 '   
					exec spa_print @sql  
					EXEC (@sql)  
END --- Manually Entry Term flag=s

 ------------REMOVE DEALs   
 EXEC spa_print '############ Remove Deal Started '  
set @sql='  
  insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation)         
  select '''+ @process_id +''',''Error'',''Import Data'',''Remove Deal'',''TrayPort Import'',''Remove Deal ID ''+t.trade_id +'' not found.'' ,''Check XML file''  
  from '+@staging_table_name+' t left outer join source_deal_header ht on  
  t.trade_id=ht.deal_id WHERE ht.deal_id IS NULL and t.action=''Remove''  
  GROUP BY t.trade_id '  
exec spa_print @sql  
EXEC (@sql)  
  
set @sql='  
 insert into source_system_data_import_status_detail(process_id,source,type,[description])       
  select '''+ @process_id +''',''Remove Deal'',''Error'',''Remove Deal Id:''+ t.Trade_id+'', Term Map ''+t.FirstSequenceItemName +'' not found.''   
  from '+@staging_table_name+' t left outer join source_deal_header ht on  
  t.trade_id=ht.deal_id WHERE ht.deal_id IS NULL and t.action=''Remove'''  
exec spa_print @sql  
EXEC (@sql)  
  
set @sql='  
  INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)      
  SELECT convert(varchar,getdate(),102), t.Trade_id, ''Remove Deal'', NULL, ''Remove Deal Id:''+ t.Trade_id+'', Term Map ''+t.FirstSequenceItemName +'' not found.''    
  from '+@staging_table_name+' t left outer join source_deal_header ht on  
  t.trade_id=ht.deal_id WHERE ht.deal_id IS NULL and t.action=''Remove'''  
exec spa_print @sql  
EXEC (@sql)  
  
 create table #temp_dealsID(  
 source_deal_header_id int,  
 deal_id varchar(50) COLLATE DATABASE_DEFAULT  
 )  
 set @sql='  
 insert #temp_dealsID(source_deal_header_id,deal_id)  
 select sdh.source_deal_header_id,sdh.deal_id from '+@staging_table_name+' t join source_deal_header sdh on  
  t.trade_id=sdh.deal_id WHERE t.action=''Remove'''  
 EXEC (@sql)  
   
 if exists(select 'x' from #temp_dealsID)   
 begin   
 declare @delete_deal_id varchar(max)  
 set @delete_deal_id=''  
 select @delete_deal_id=cast(source_deal_header_id as varchar) +','+ @delete_deal_id from #temp_dealsID  
 if len(ltrim(rtrim(@delete_deal_id)))>0   
 begin  
  set @delete_deal_id=left(@delete_deal_id,len(@delete_deal_id)-1)   
 end  
 else  
  set @delete_deal_id=NULL  
    
 if @delete_deal_id is not null  
 begin  
  create table #temp_RemoveStatus(  
  ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,  
  Module Varchar(150) COLLATE DATABASE_DEFAULT,  
  Area Varchar(150) COLLATE DATABASE_DEFAULT,  
  Status varchar(50) COLLATE DATABASE_DEFAULT,  
  Message varchar(500) COLLATE DATABASE_DEFAULT,  
  Recommendation Varchar(500) COLLATE DATABASE_DEFAULT  
  )    
  insert #temp_RemoveStatus(ErrorCode,Module,Area,Status,Message,Recommendation)  
  exec spa_sourcedealheader 'd',null,null,null,null,null,@delete_deal_id  
  declare @remove_status varchar(50),@remove_message varchar(500),@Recommendation varchar(500)  
  select @remove_status=Status,@remove_message=Message,@Recommendation=Recommendation from #temp_RemoveStatus  
    
  set @sql='  
    insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation)         
    select '''+ @process_id +''','''+@remove_status+''',''Import Data'',''Remove Deal'',''TrayPort Import'',  
    '''+isNUll(@remove_message,'') +''' ,'''+isNUll(@Recommendation,'') +'''  
    from '+@staging_table_name+' t join #temp_dealsID ht on  
    t.trade_id=ht.deal_id'  
  exec spa_print @sql  
  EXEC (@sql)  
  
  set @sql='  
   insert into source_system_data_import_status_detail(process_id,source,type,[description])       
    select '''+ @process_id +''','''+@remove_status+''',''Import Data'',''Remove Deal'',''TrayPort Import'',  
    '''+isNUll(@remove_message,'') +''' ,'''+isNUll(@Recommendation,'') +'''  
    from '+@staging_table_name+' t join #temp_dealsID ht on  
    t.trade_id=ht.deal_id'  
  exec spa_print @sql  
  EXEC (@sql)  
  
 end  
   
end  

---- Delete Deal End  

------ create monthly term
CREATE TABLE #term_trayport(
term_start DATETIME,
term_end DATETIME)

DECLARE @Gen_Term_Start VARCHAR(50),@Gen_Term_end VARCHAR(50),@frequency_type CHAR(1)
set @sql='insert #term_trayport select MIN(convert(datetime,term_start,101)),MAX(convert(datetime,term_end,101)) from '+@staging_table_name +' where process_id='''+@process_id +''''
exec spa_print @sql  
EXEC (@sql)  

SELECT @Gen_Term_Start=convert(datetime,term_start,101),@Gen_Term_end=convert(datetime,term_end,101) 
FROM #term_trayport 

SELECT * INTO #term_month FROM FNATermBreakdown('m',@Gen_Term_Start,@Gen_Term_end)

 
set @sql='insert '+@tName+'(deal_id,source_system_id,term_start,term_end,leg,contract_expiration_date,fixed_float_leg,  
buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,  
deal_detail_description,formula_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,  
source_deal_type_id,source_deal_sub_type_id,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,  
source_system_book_id3,source_system_book_id4,description1,description2,description3,deal_category_value_id,trader_id,  
header_buy_sell_flag,broker_id,contract_id,legal_entity,  
internal_portfolio_id,reference,commodity_id,internal_desk_id,physical_financial_flag_detail,template,location_id,table_code)  
select t.trade_id,'+@source_system_id+' source_system_id,m.term_start,m.term_end,1 leg,m.term_end,dt.fixed_float_leg,  
case when t.aggressorCompanyID='''+ @tray_port_RWE_ID +''' then  
 case when t.aggressorAction=''Buy'' then ''b'' else ''s'' end  
else  
 case when t.InitiatorAction=''Buy'' then ''b'' else ''s'' end  
end buy_sell_flag,  
curve.curve_id,  
price fixed_price,  
ccy.currency_id,  
null option_strike_price,abs(t.Volume) deal_volume,  
dt.deal_volume_frequency,  
uom.uom_id deal_volume_uom_id,  
NULL block_description,null,dt.formula,t.datetime,null ext_deal_id,  
ht.physical_financial_flag ,  
null structured_deal_id,  
case when t.aggressorCompanyID='''+ @tray_port_RWE_ID +''' then  
 t.InitiatorCompany  
else  
 t.aggressorCompany  
end counterparty,b.deal_type_id,sb.deal_type_id source_deal_sub_type_id,ht.option_flag,  
ht.option_type,ht.option_exercise_type,  
'''+ @source_system_book_id1 +''' source_system_book_id1,  
''-2'' source_system_book_id2,  
''-3'' source_system_book_id3,  
''-4'' source_system_book_id4,null  description1,  
null  description2,null  description3,476,  
case when t.aggressorCompanyID='''+ @tray_port_RWE_ID +''' then  
 t.aggressorTrader  
else  
 t.InitiatorTrader  
END Trader,  
case when t.aggressorCompanyID='''+ @tray_port_RWE_ID +''' then  
 case when t.aggressorAction=''Buy'' then ''b'' else ''s'' end  
else  
 case when t.InitiatorAction=''Buy'' then ''b'' else ''s'' end  
end  header_buy_sell_flag,  
case when t.aggressorCompanyID='''+ @tray_port_RWE_ID +''' then  
 t.aggressorBroker   
else  
 t.InitiatorBroker  
end  
 broker_id,cg.source_contract_id,ht.legal_entity,  
ht.internal_portfolio_id ,t.FirstSequenceItemName reference,sc.commodity_id,ht.internal_desk_id,  
dt.physical_financial_flag , t.InstName,loc.Location_Name,
4005 table_code  
from '+@staging_table_name+' t JOIN #term_month m ON
m.term_start BETWEEN convert(datetime,t.term_start,101) AND convert(datetime,t.[term_end],101)  
join source_deal_header_template ht on t.InstName=ht.template_name  
join source_deal_detail_template dt on dt.template_id=ht.template_id and dt.leg=1  
LEFT OUTER JOIN dbo.source_price_curve_def curve ON curve.source_curve_def_id=dt.curve_id  
LEFT OUTER JOIN dbo.source_commodity sc ON sc.source_commodity_id=ht.commodity_id  
left OUTER join source_deal_type b on b.source_deal_type_id=ht.source_deal_type_id  
left OUTER join source_deal_type sb on sb.source_deal_type_id=ht.deal_sub_type_type_id and sb.sub_type=''y''  
LEFT OUTER JOIN source_uom uom ON uom.source_uom_id=dt.deal_volume_uom_id  
left OUTER join source_currency  ccy ON ccy.source_currency_id=dt.currency_id  
left OUTER join source_minor_location loc ON loc.source_minor_location_id=dt.location_id
LEFT JOIN contract_group cg ON cg.contract_id = ht.contract_id
where t.process_id='''+@process_id +''' and t.term_start is not null and t.action in (''Insert'',''Update'')  
ORDER BY t.trade_id,t.term_start,t.action '  
EXEC spa_print @sql  
exec(@sql)  
--EXEC('select * from '+@tName)
--return

CREATE TABLE #temp_check(total_error INT)

SET @sql = 'insert #temp_check(total_error) select count(*) FROM source_deal_error_log l  
   INNER JOIN '+ @staging_table_name +' t ON l.deal_id = t.trade_id and t.process_id='''+@process_id +''''    
exec spa_print @sql  
EXEC (@sql) 

DECLARE @error_check INT,@total_row int, @error_count INT,@errorcode CHAR(1) 
SELECT @error_check=total_error from #temp_check
DELETE #temp_check

SET @sql = 'insert #temp_check(total_error) select count(*) FROM '+@tName     
exec spa_print @sql  
EXEC (@sql) 
SELECT @total_row=total_error from #temp_check
  
declare @is_schedule varchar(1)  
if @adhoc_call is NULL  
 set @is_schedule='y'  
else  
 set @is_schedule='n'  
	 
IF ISNULL(@error_check,0)=0  AND @total_row>0
BEGIN

		create table #temp_deal_exists(
			sno INT IDENTITY(1,1),
			source_deal_header_id VARCHAR(50) COLLATE DATABASE_DEFAULT
		)
		EXEC('insert  #temp_deal_exists(source_deal_header_id) 
			select distinct sdh.source_deal_header_id 
			FROM dbo.source_deal_header sdh join '+@staging_table_name+' t   
			on sdh.deal_id=t.trade_id 
			WHERE t.action=''UPDATE''
		')
		DELETE dbo.source_deal_detail FROM source_deal_detail sdd JOIN #temp_deal_exists t 
		ON sdd.source_deal_header_id= t.source_deal_header_id 
				
		
		 set @call_imp_engine='exec spa_import_data_job '''+@tName +''',4005,''TrayPort-Import'','''+@process_id+''','''+ @user_login_id+''',''y'',12'  
		EXEC spa_print @call_imp_engine  
		exec(@call_imp_engine)  


		 DECLARE @table_name VARCHAR(150)  
		 SET @table_name = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)  
		 SET @sql='Create table '+@table_name +'  
		 (  
		 Action char(1),  
		 source_deal_header_id int  
		 )'  
		 EXEC(@sql)  
		   
		 SET @sql='insert '+@table_name +'(Action,source_deal_header_id)  
		 SELECT distinct ''i'',sdh.source_deal_header_id   
		 FROM dbo.source_deal_header sdh join '+@tName+' t   
		 on sdh.deal_id=t.deal_id and sdh.source_system_id=t.source_system_id  
		 '  
		 EXEC spa_print @sql  
		 EXEC(@sql)  
   
   		create table #temp_audit(
			sno INT IDENTITY(1,1),
			trade_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
			insert_update CHAR(1) COLLATE DATABASE_DEFAULT
		)
		EXEC('insert  #temp_audit(trade_id,insert_update) 
			select distinct sdh.source_deal_header_id,case when t.action=''Insert'' then ''i'' else ''u'' end  
			FROM dbo.source_deal_header sdh join '+@staging_table_name+' t   
			on sdh.deal_id=t.trade_id
		')

END     	
ELSE 
BEGIN 
	SET @errorcode='e' 
END 

					 SET @sql='delete '+@staging_table_name+'  
					  where trade_id not in (select deal_id from source_deal_error_log)  and process_id='''+ @process_id +''''  
					 EXEC spa_print @sql  
					 EXEC(@sql)  
  
				 if @adhoc_call is NULL  ---- If not manual call and error in deal then copy to Error Staging table  
				 begin  
					
					
					INSERT INTO [Trayport_Staging_Error]  
					  ([Action]  
					  ,[Trade_Id]  
					  ,[RelationshipID]  
					  ,[Price]  
					  ,[Volume]  
					  ,[DateTime]  
					  ,[LastUpdate]  
					  ,[AggressorCompany]  
					  ,[AggressorCompanyID]  
					  ,[AggressorTrader]  
					  ,[AggressorTraderID]  
					  ,[AggressorUser]  
					  ,[AggressorUserID]  
					  ,[AggressorAction]  
					  ,[AggressorBroker]  
					  ,[AggressorBrokerID]  
					  ,[InitiatorCompany]  
					  ,[InitiatorCompanyID]  
					  ,[InitiatorTrader]  
					  ,[InitiatorTraderID]  
					  ,[InitiatorUser]  
					  ,[InitiatorUserID]  
					  ,[InitiatorAction]  
					  ,[InitiatorBroker]  
					  ,[InitiatorBrokerID]  
					  ,[ClearingStatus]  
					  ,[ClearingID]  
					  ,[ManualDeal]  
					  ,[VoiceDeal]  
					  ,[InitSleeve]  
					  ,[AggSleeve]  
					  ,[PNC]  
					  ,[PostTradeNegotiating]  
					  ,[InitiatorOwnedSpread]  
					  ,[AggressorOwnedSpread]  
					  ,[UnderInvestigation]  
					  ,[EngineID]  
					  ,[OrderID]  
					  ,[InstID]  
					  ,[SeqSpan]  
					  ,[FirstSequenceID]  
					  ,[FirstSequenceItemID]  
					  ,[SecondSequenceItemID]  
					  ,[TermFormatID]  
					  ,[InstName]  
					  ,[FirstSequenceItemName]  
					  ,[SecondSequenceItemName]  
					  ,[Trade_SNO]  
					  ,[Create_ts]  
					  ,[process_id]  
					  ,[XML_FileName]  
					  ,[term_start]  
					  ,[term_end]  
					  ,[last_proceed_ts])  
				  select [Action]  
					  ,[Trade_Id]  
					  ,[RelationshipID]  
					  ,[Price]  
					  ,[Volume]  
					  ,convert(varchar,DATETIME,120)
					  ,[LastUpdate]  
					  ,[AggressorCompany]  
					  ,[AggressorCompanyID]  
					  ,[AggressorTrader]  
					  ,[AggressorTraderID]  
					  ,[AggressorUser]  
					  ,[AggressorUserID]  
					  ,[AggressorAction]  
					  ,[AggressorBroker]  
					  ,[AggressorBrokerID]  
					  ,[InitiatorCompany]  
					  ,[InitiatorCompanyID]  
					  ,[InitiatorTrader]  
					  ,[InitiatorTraderID]  
					  ,[InitiatorUser]  
					  ,[InitiatorUserID]  
					  ,[InitiatorAction]  
					  ,[InitiatorBroker]  
					  ,[InitiatorBrokerID]  
					  ,[ClearingStatus]  
					  ,[ClearingID]  
					  ,[ManualDeal]  
					  ,[VoiceDeal]  
					  ,[InitSleeve]  
					  ,[AggSleeve]  
					  ,[PNC]  
					  ,[PostTradeNegotiating]  
					  ,[InitiatorOwnedSpread]  
					  ,[AggressorOwnedSpread]  
					  ,[UnderInvestigation]  
					  ,[EngineID]  
					  ,[OrderID]  
					  ,[InstID]  
					  ,[SeqSpan]  
					  ,[FirstSequenceID]  
					  ,[FirstSequenceItemID]  
					  ,[SecondSequenceItemID]  
					  ,[TermFormatID]  
					  ,[InstName]  
					  ,[FirstSequenceItemName]  
					  ,[SecondSequenceItemName]  
					  ,[Trade_SNO]  
					  ,[Create_ts]  
					  ,[process_id]  
					  ,[XML_FileName]  
					  ,[term_start]  
					  ,[term_end]  
					  ,[last_proceed_ts]  
					from [Trayport_Staging] where [Trade_Id] not in (select [Trade_Id] from [Trayport_Staging_Error])  
					and process_id=@process_id  
				      
				   delete [Trayport_Staging] where process_id=@process_id  
				 end  
		
IF ISNULL(@error_check,0)=0  AND @total_row>0
BEGIN		    
		 SET @sql='update source_deal_header  set deal_status=ht.deal_status,  
		 deal_category_value_id=ht.deal_category_value_id,
		 block_type=ht.block_type,block_define_id=ht.block_define_id ,
		 deal_locked=CASE WHEN a.insert_update=''i'' THEN ''n'' ELSE deal_locked end,
		 pricing=ht.pricing
		 from '+@table_name +' t join source_deal_header sdh  
		 on t.source_deal_header_id=sdh.source_deal_header_id  
		 join source_deal_header_template ht on ht.template_id=sdh.template_id
		 JOIN #temp_audit a ON a.trade_id=sdh.source_deal_header_id
		 '  
		 EXEC(@sql)  
 		   
 		   
 		 SET @sql='update source_deal_detail set price_uom_id=dt.price_uom_id,
 		 pay_opposite=dt.pay_opposite,
 		 pv_party=case when sdd.physical_financial_flag=''p'' then 292065 else NULL end
		 from #temp_audit t join source_deal_header sdh  
		 on t.trade_id=sdh.source_deal_header_id 
		 join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id 
		 join source_deal_header_template ht on ht.template_id=sdh.template_id
		 join source_deal_detail_template dt on dt.template_id=ht.template_id and dt.leg=1  
		 '  
		 EXEC(@sql)


		 EXEC [spa_update_deal_total_volume] null, @process_id,0,NULL,@user_login_id  
				
		 ----- Audit Log ------
		 
			DECLARE @audit_log_id VARCHAR(MAX),@total_row_audit INT,@ctr INT,@deal_nos_batch int
			SELECT @total_row_audit=COUNT(*) FROM #temp_audit
			SET @ctr=0
			SET @deal_nos_batch=500

			WHILE @ctr<=@total_row_audit
			BEGIN
				
				set @audit_log_id='' 
				SELECT @audit_log_id=trade_id +','+ @audit_log_id from #temp_audit t
				WHERE t.insert_update='i' AND sno BETWEEN @ctr AND (@ctr+@deal_nos_batch)
				
				EXEC spa_print 'Insert Audit:', @ctr, ' out-of ', @total_row_audit, ' --- ', @audit_log_id
				
				 if len(ltrim(rtrim(@audit_log_id)))>0   
				 BEGIN
					 set @audit_log_id=left(@audit_log_id,len(@audit_log_id)-1)   
				 END
				 ELSE
					set @audit_log_id=NULL
					
				IF @audit_log_id IS NOT NULL
					EXEC spa_insert_update_audit 'i',@audit_log_id
				
				
				set @audit_log_id='' 
				SELECT @audit_log_id=trade_id +','+ @audit_log_id from #temp_audit t
				WHERE t.insert_update='u' AND sno BETWEEN @ctr AND (@ctr+@deal_nos_batch)
				
				EXEC spa_print 'Update Audit:', @ctr, ' outof ', @total_row_audit, ' --- ', @audit_log_id
				 if len(ltrim(rtrim(@audit_log_id)))>0   
				 begin  
				   set @audit_log_id=left(@audit_log_id,len(@audit_log_id)-1)   
				 end  
				 else  
					set @audit_log_id=NULL

				IF @audit_log_id IS NOT NULL
					EXEC spa_insert_update_audit 'u',@audit_log_id
					
				SET @ctr=@ctr+@deal_nos_batch+1
				
			END
END

	select @error_count=count(*) from source_system_data_import_status   
		where process_id=@process_id and code='Error'  
		DECLARE @url VARCHAR(5000),@desc VARCHAR(5000)

		If @error_count = 0   AND ISNULL(@errorcode,'s')='s'
		BEGIN  
		 SET @errorcode='s'  
			IF @adhoc_call IS NOT null
			BEGIN
 			SET @msg=@msg+' Completed '
  			SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

				select @desc = '<a target="_blank" href="' + @url + '">' + 
						@msg  + 
					case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
					'.</a>'
				
				EXEC spa_NotificationUserByRole 5,@process_id,'Tray-Port',@desc,@errorcode,'Tray-Port Import'  
			 END
 
		end  
	 ELSE  
	BEGIN  
	 SET @errorcode='e'  
		
 		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		select @desc = '<a target="_blank" href="' + @url + '">' + 
					@msg  + 
				case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
				'.</a>'

	 EXEC spa_NotificationUserByRole 5,@process_id,'Tray-Port',@desc,@errorcode,'Tray-Port Import'  
	END  
	update import_data_files_audit        
	   set status=@errorcode,        
		elapsed_time=datediff(ss,create_ts,getdate())        
	   where process_id=@process_id  
		IF @errorcode IS null
	SET @errorcode='s'   
IF @adhoc_call='s'
BEGIN

	exec('insert '+@temp_table +' values('''+ @errorcode  +''')')
end    
ELSE
BEGIN
	--don't treat missing Term Map as error as in such case files need be moved to Success folder for such error. (Eventum ID: 6212)
	DECLARE @error_except_missing_term_map_exists BIT
	
	IF EXISTS (SELECT 1	FROM source_system_data_import_status   
				WHERE process_id = @process_id AND code = 'Error'
					AND source <> 'Term_Map')
		SET @error_except_missing_term_map_exists = 1
		
	SELECT (CASE WHEN @error_except_missing_term_map_exists = 1 THEN @errorcode ELSE 's' END) AS [status]  
END 
--  SELECT * FROM dbo.source_deal_header_audit ORDER BY audit_id desc
