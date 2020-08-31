

/****** Object:  StoredProcedure [dbo].[spa_create_rec_transaction_report]    Script Date: 10/09/2009 09:56:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_transaction_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_transaction_report]
/****** Object:  StoredProcedure [dbo].[spa_create_rec_transaction_report]    Script Date: 10/09/2009 09:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_create_rec_transaction_report]
  @sub_entity_id varchar(100),
  @strategy_entity_id varchar(100),
  @book_entity_id varchar(100),	  
  @assigned_state int,
  @gen_state int,
  @assignment_type int,
  @technology int,
  @buysell_flag char(1),
  @generator_id int,
  @gen_date_from DATETIME,
  @gen_date_to DATETIME, 
  @certno_from varchar(100)=NULL,
  @certno_to   varchar(100)=NULL,
  @transaction_from datetime,
  @transaction_to datetime,
  @assigned_year int,
  @include_inventory char(1)='n',
  @counterparty_id INT=NULL,		
  @report_type CHAR(1)='a', -- 'a' for html and 'x' for xml format
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL

--'4','5','9',NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2007-01-01', '2009-12-31', NULL,NULL,NULL,'x','5515BC9A_9A3F_4B85_9A76_52D48E4364F1','spa_create_rec_transaction_report ''4'',''5'',''9'',NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ''2007-01-01'', ''2009-12-31'', NULL,NULL,NULL,x'

--   @book_deal_type_map_id varchar(5000) = null,        
--   @source_deal_header_id varchar(5000)  = null        
        
        
AS        
 
 SET NOCOUNT ON 

--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:', @batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(128),@user_login_id varchar(50),@flag CHAR(1)
set @str_batch_table=''
SET @str_get_row_number=''


	
IF @batch_process_id IS not NULL
begin
		
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	exec spa_print '@temptablename', @temptablename
	SET @str_batch_table=' INTO ' + @temptablename
	--SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	
		
end

--////////////////////////////End_Batch///////////////////////////////////////////


        
DECLARE @sql_stmt1 varchar(6000)        
DECLARE @sql_stmt2 varchar(6000)        
DECLARE @sql_stmt0 varchar(6000)        
DECLARE @sql_stmt4 varchar(6000)
        

DECLARE @sql_stmt varchar(8000)  
DECLARE @Sql_Select varchar(8000)  
DECLARE @Sql_Where varchar(8000)  
 
set @Sql_Where=''  
 

IF @gen_date_from IS NOT NULL AND @gen_date_to IS NULL            
 set @gen_date_to = '9999-1-1'  
IF @gen_date_to IS NOT NULL AND @gen_date_from IS NULL            
 set @gen_date_from = '1900-1-1'

IF @transaction_from IS NOT NULL AND @transaction_to IS NULL            
 set @transaction_to = '9999-1-1'  
IF @transaction_to IS NOT NULL AND @transaction_from IS NULL            
 set @transaction_from = '1900-1-1'
  

 
--******************************************************  
--CREATE source book map table and build index  
--*********************************************************  
CREATE TABLE #ssbm(  
  source_system_book_id1 int,            
 source_system_book_id2 int,            
 source_system_book_id3 int,            
 source_system_book_id4 int,            
 fas_deal_type_value_id int,            
 book_deal_type_map_id int,            
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)  
----------------------------------  
SET @Sql_Select=  
'INSERT INTO #ssbm            
SELECT            
 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
FROM            
 source_system_book_map ssbm             
INNER JOIN            
 portfolio_hierarchy book (nolock)             
ON             
  ssbm.fas_book_id = book.entity_id             
INNER JOIN            
 Portfolio_hierarchy stra (nolock)            
 ON            
  book.parent_entity_id = stra.entity_id             
            
WHERE 1=1 '            
IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'            
 IF @book_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            
EXEC (@Sql_Select)            



--------------------------------------------------------------  
CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])        
CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])        
CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])        
CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])        
CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])        
CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])        
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])        
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])        
  
--******************************************************  
--End of source book map table and build index  
--*********************************************************  

---=============THIS ONE IS THE AUDIT TRAIL .....        
------------------------------------------------        
    
SET @sql_stmt0 = '        
 select      
 sdh.source_deal_header_id as [Deal_Id],	
 rg.[name] AS [Source],
 technology.code as Type,
 dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), cast(sdh.source_deal_header_id as varchar)) ID,        
 0 as SID,    
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],gis.certificate_number_from_int,sdd.term_start)+''&nbsp;'' [Cert # From],    
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],gis.certificate_number_to_int,sdd.term_start)+''&nbsp;'' [Cert # To],      
 cast(round(sdd.deal_volume, 0) as float) Volume,         
 '''' +        
 case  when sdd.buy_sell_flag=''s'' and sdh.status_value_id=5180 then '' Inventory Adjustments Sale''
 when (sdd.buy_sell_flag = ''b'') then         
  case when (isnull(sc.int_ext_flag, ''e'') = ''i'') then ''Generated - '' + isnull(rg.[name],'''')         
   else ''Bought from '' + isnull(sc.counterparty_name, '''') end         
 else ''Sold to '' + isnull(sc.counterparty_name, '''')      
 end Assignment,         
 ISNULL(gis.gis_cert_date,sdh.deal_date) gis_cert_date,
 NULL as assignment_type,
 isnull(cast(sdh.compliance_year as varchar),YEAR(sdd.term_start)) ComplianceYear,
 NULL as create_ts,
 CASE WHEN sdd.buy_sell_flag = ''s'' THEN parent_cea.external_value ELSE cea.external_value END AS [Sell Acct],	
 CASE WHEN sdd.buy_sell_flag = ''b'' THEN parent_cea.external_value ELSE cea.external_value END AS [Buy Acct],
 CASE WHEN sdd.buy_sell_flag = ''s'' THEN parent_sc.counterparty_contact_id ELSE sc.counterparty_contact_id END AS [Sell AAR],	
 CASE WHEN sdd.buy_sell_flag = ''b'' THEN parent_sc.counterparty_contact_id ELSE sc.counterparty_contact_id END AS [Buy AAR],
 ''N'' AS [Perpetuity],
 isnull(cast(sdh.compliance_year as varchar),YEAR(sdd.term_start)) [Allw Year],
dbo.FNACertificateRule(cr.cert_rule,rg.[ID],gis.certificate_number_from_int,sdd.term_start) [Ser Start],    
dbo.FNACertificateRule(cr.cert_rule,rg.[ID],gis.certificate_number_to_int,sdd.term_start) [Ser End]

 from 
 source_deal_header sdh inner join  source_deal_detail sdd      
 on sdh.source_deal_header_id=sdd.source_deal_header_id   
 inner join #ssbm sbm ON  
   sdh.source_system_book_id1 = sbm.source_system_book_id1 AND   
   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND  
   sdh.source_system_book_id3 = sbm.source_system_book_id3 AND   
   sdh.source_system_book_id4 = sbm.source_system_book_id4   
 LEFT OUTER JOIN        
 static_data_value ass on ass.value_id = sdh.assignment_type_value_id left outer  join        
 static_data_value state on state.value_id = sdh.state_value_id left outer  join        
 application_users au on au.user_login_id = sdh.assigned_by left outer join        
 rec_generator rg on rg.generator_id = sdh.generator_id left outer join         
 state_properties sp on sp.state_value_id = isnull(sdh.state_value_id, rg.state_value_id) left outer join        
 static_data_value state_rg on state_rg.value_id = rg.state_value_id 
 LEFT OUTER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
 LEFT OUTER JOIN counterparty_epa_account cea ON cea.counterparty_id=sc.source_counterparty_id AND cea.external_type_id=2201
 LEFT OUTER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id=sbm.sub_entity_id
 LEFT OUTER JOIN source_counterparty parent_sc ON parent_sc.source_counterparty_id=fs.counterparty_id
 LEFT OUTER JOIN counterparty_epa_account parent_cea ON parent_cea.counterparty_id=parent_sc.source_counterparty_id AND parent_cea.external_type_id=2201
 LEFT OUTER JOIN                 
 source_deal_header sellP on sellP.ext_deal_id = case when (sdh.assignment_type_Value_id = 5173) then        
         cast(sdh.source_deal_header_id as varchar)        
       else ''-1xx-1'' end        
--certificate        
LEFT join static_data_value technology on technology.value_id=rg.technology
LEFT JOIN Gis_certificate gis on      
 gis.source_deal_header_id=sdd.source_deal_detail_id      
LEFT JOIN      
certificate_rule cr on      
 rg.gis_value_id=cr.gis_id     
 Left outer join rec_generator_assignment rga on rg.generator_id=rga.generator_id
 and ((sdd.term_start between rga.term_start and rga.term_end) OR (sdd.term_end between rga.term_start and rga.term_end))
 where 1 = 1 and    sbm.fas_deal_type_value_id=400 and     
 (sdh.assignment_type_value_id IS NULL)'
+ case when (@gen_state IS NULL) then '' else ' AND  rg.gen_state_value_id = ' + cast(@gen_state as varchar) end
 + case when (isnull(@assigned_state,'')<>'') then
 ' AND rg.state_value_id='+cast(@assigned_state as varchar)
 else ' '  end 
+ case when (@generator_id IS NULL) then '' else ' AND  rg.generator_id = ' + cast(@generator_id as varchar) end  
+ case when (@gen_date_from IS NULL) then '' else ' AND  sdd.term_start BETWEEN ''' + cast(@gen_date_from as varchar)+ ''' AND ''' + cast(@gen_date_to as varchar)+ '''' end      
+ case when (@buysell_flag IS NULL) then '' else ' AND  sdd.buy_sell_flag = ''' + cast(@buysell_flag as varchar)+'''' end   
+ case when (@assignment_type IS NULL) then '' else ' AND  sdh.assignment_type_value_id = ' + cast(@assignment_type as varchar) end  
+ case when (@transaction_from IS NULL) then '' else ' AND  sdh.deal_date BETWEEN ''' + cast(@transaction_from as varchar)+ ''' AND ''' + cast(@transaction_to as varchar)+ '''' end      
+ case when (@assigned_year IS NULL) then '' else ' AND  year(sdh.assigned_date) = ' + cast(@assigned_year as varchar) end  
+ case when @include_inventory ='y' then ' AND ISNULL(rga.exclude_inventory,rg.exclude_inventory)=''y''' else case when isnull(@assignment_type,5149)=5149 then  ' AND (ISNULL(rga.exclude_inventory,rg.exclude_inventory) is null or ISNULL(rga.exclude_inventory,rg.exclude_inventory)=''n'') ' else ''  end  end
+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id='+CAST(@counterparty_id AS VARCHAR) ELSE '' END
+ case when (@technology IS NULL) then '' else ' AND  rg.technology = ' + cast(@technology as varchar) end  

IF (@certno_from IS NOT NULL AND @certno_to IS NULL)   
	SET @sql_stmt0 = @sql_stmt0 +' AND ( gis.certificate_number_from_int  >= '+ @certno_from +') '
ELSE IF (@certno_from IS NULL AND @certno_to IS NOT NULL)
	SET @sql_stmt0 = @sql_stmt0 +' and  (gis.certificate_number_to_int  <= '+ @certno_to     
        +') ' 
ELSE IF (@certno_from IS NOT NULL AND @certno_to IS NOT NULL) 
  SET @sql_stmt0 = @sql_stmt0 +' AND ( gis.certificate_number_from_int  >= '+ @certno_from  +' and  gis.certificate_number_to_int  <= '+ @certno_to     
        +') ' 
--exec(@sql_stmt0)    
--return

--Print 'SQl0: ' + @sql_stmt0   
--exec (@sql_stmt0)        
--RETURN

---=============THIS ONE IS THE AUDIT TRAIL .....         
------------------------------------------------        
CREATE TABLE #temp_assign_unassign(    
 [ID] int identity(1,1),    
 assignment_id int,    
 assignment_type int,    
 assigned_volume float,    
 assign_flag char(1) COLLATE DATABASE_DEFAULT ,    
 source_deal_header_id int,    
 source_deal_header_id_from int,    
 create_ts datetime,    
 state_value_id int,    
 compliance_year int,    
 assigned_date datetime,    
 assigned_by varchar(100) COLLATE DATABASE_DEFAULT ,    
 cert_from  varchar(500) COLLATE DATABASE_DEFAULT ,
 cert_to varchar(500) COLLATE DATABASE_DEFAULT ,
 generator_Id int

)     

set @sql_stmt4='
INSERT into #temp_assign_unassign (assignment_id,     
 assignment_type,     
 assigned_volume,    
 assign_flag,    
 source_deal_header_id,    
 source_deal_header_id_from,    
 create_ts,    
 state_value_id,    
 compliance_year,    
 assigned_date,    
 assigned_by ,
cert_from,
cert_to,
generator_id
   
)    
    
select a.* from(    
select a.assignment_id,a.assignment_type,case when assign_flag=''y'' then -1 * round(assigned_volume,0)      
else round(assigned_volume,0) end as assigned_volume,    
a.assign_flag,a.source_deal_header_id,a.source_deal_header_id_from,a.update_ts,a.state_value_id,    
a.compliance_year,a.assigned_date,a.assigned_by,a.cert_from,a.cert_to,sdh.generator_id
from unassignment_audit a 
join source_deal_detail sdd on a.source_deal_header_id_from=sdd.source_deal_detail_id 
join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
inner join #ssbm sbm ON  
   sdh.source_system_book_id1 = sbm.source_system_book_id1 AND   
   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND  
   sdh.source_system_book_id3 = sbm.source_system_book_id3 AND   
   sdh.source_system_book_id4 = sbm.source_system_book_id4   
where 1=1 

 
union    
    
select a.assignment_id,a.assignment_type,round(a.assigned_volume,0) assigned_volume,    
NULL assign_flag,a.source_deal_header_id,a.source_deal_header_id_from,a.update_ts,a.state_value_id,    
a.compliance_year,a.assigned_date,a.assigned_by,a.cert_from,a.cert_to,sdh.generator_id 
from assignment_audit a     
join source_deal_detail sdd on a.source_deal_header_id_from=sdd.source_deal_detail_id 
join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
 inner join #ssbm sbm ON  
   sdh.source_system_book_id1 = sbm.source_system_book_id1 AND   
   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND  
   sdh.source_system_book_id3 = sbm.source_system_book_id3 AND   
   sdh.source_system_book_id4 = sbm.source_system_book_id4   
where 1=1
	 and a.assigned_volume > 0 
	and a.source_deal_header_id not in(select source_deal_header_id from unassignment_audit where assign_flag is null)
) a order by source_deal_header_id_from,update_ts    '

--print (@sql_stmt4)
exec(@sql_stmt4)


SET @sql_stmt1 = '        
 select
 sdh1.source_deal_header_id as [Deal_ID], 	 
 rg.[name] AS [Source],        
 technology.code as Type,
 dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), cast(sdh.source_deal_header_id as varchar)) ID, 
 isnull(assign.ID, 0) as SID,        
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_from,sdd.term_start) +''&nbsp;'' [Cert # From],      
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to,sdd.term_start) +''&nbsp;'' [Cert # To],   
 case  when (assign.assignment_type <> 5149)     
 THEN cast(round(abs(assign.assigned_volume), 0) as float)     
 else cast(round(sdd.volume_left, 0) as float) end volume,    
 isnull(ass.code, ''Banked'')  +     
	 case when  assign.assignment_type=5173 then '' to '' +sc.counterparty_name 
     when  assign.assignment_type<> 5173 then '' , '' + state.code +'' - ''+rg.[name] else '''' end +
		   case when assign.assign_flag=''y'' then '' - UnAssigned'' else '''' end 
	 	
 as Assignment,         
 ISNULL(gis.gis_cert_date,sdh.deal_date) gis_cert_date,
 ass.code,
 isnull(cast(assign.compliance_year as varchar),YEAR(sdd.term_start)) ComplianceYear ,       
 assign.create_ts,
 parent_cea.external_value  AS [Sell Acct],	
 cea.external_value AS [Buy Acct],
 parent_sc.counterparty_contact_id AS [Sell AAR],
 sc.counterparty_contact_id AS [Buy AAR],
 ''N'' AS [Perpetuity],
  isnull(cast(sdh.compliance_year as varchar),YEAR(sdd.term_start)) [Allw Year],
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],CAST(gis.certificate_number_from_int AS VARCHAR),sdd.term_start) [Ser Start],    
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],CAST(gis.certificate_number_to_int AS VARCHAR),sdd.term_start) [Ser End]

from source_deal_header sdh inner join source_deal_detail sdd on       
sdh.source_deal_header_id=sdd.source_deal_header_id 
inner join #ssbm sbm ON  
   sdh.source_system_book_id1 = sbm.source_system_book_id1 AND   
   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND  
   sdh.source_system_book_id3 = sbm.source_system_book_id3 AND   
   sdh.source_system_book_id4 = sbm.source_system_book_id4       
inner JOIN    
#temp_assign_unassign assign    
on sdd.source_deal_detail_id=assign.source_deal_header_id_from    
join source_deal_detail sdd1 on sdd1.source_deal_detail_id=assign.source_deal_header_id
join source_deal_header sdh1 on sdh1.source_deal_header_id=sdd1.source_deal_header_id   
left outer  join        
static_data_value ass on ass.value_id = assign.assignment_type left outer  join        
static_data_value state on state.value_id = assign.state_value_id left outer  join        
application_users au on au.user_login_id = assign.assigned_by left outer join        
rec_generator rg on rg.generator_id = sdh.generator_id left outer join         
state_properties sp on sp.state_value_id = isnull(assign.state_value_id, rg.state_value_id) left outer join        
static_data_value state_rg on state_rg.value_id = rg.state_value_id LEFT OUTER JOIN        
source_deal_header sellP on sellP.ext_deal_id = case when (sdh.assignment_type_Value_id = 5173)  then        
        cast(sdh.source_deal_header_id as varchar)        
       else ''-1xx-1'' end        
 --certificate        
--left join rec_generator rg1 on rg1.generator_id=sdh1.generator_id
left join source_counterparty sc on sc.source_counterparty_id=sdh1.counterparty_id
LEFT OUTER JOIN counterparty_epa_account cea ON cea.counterparty_id=sc.source_counterparty_id AND cea.external_type_id=2201
LEFT OUTER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id=sbm.sub_entity_id
LEFT OUTER JOIN source_counterparty parent_sc ON sc.source_counterparty_id=fs.counterparty_id
LEFT OUTER JOIN counterparty_epa_account parent_cea ON parent_cea.counterparty_id=parent_sc.source_counterparty_id AND parent_cea.external_type_id=2201
LEFT join static_data_value technology on technology.value_id=rg.technology
LEFT JOIN Gis_certificate gis on      
 gis.source_deal_header_id=sdd.source_deal_detail_id      
INNER JOIN    
certificate_rule cr on      
 rg.gis_value_id=cr.gis_id 
 Left outer join rec_generator_assignment rga on rg.generator_id=rga.generator_id
 and ((sdd.term_start between rga.term_start and rga.term_end) OR (sdd.term_end between rga.term_start and rga.term_end))     
 where 1 = 1 '        
+ case when (@gen_state IS NULL) then '' else ' AND  rg.gen_state_value_id = ' + cast(@gen_state as varchar) end
 + case when (isnull(@assigned_state,'')<>'') then
 ' AND rg.state_value_id='+cast(@assigned_state as varchar)
 else ' '  end 
+ case when (@generator_id IS NULL) then '' else ' AND  rg.generator_id = ' + cast(@generator_id as varchar) end  
+ case when (@gen_date_from IS NULL) then '' else ' AND  sdd1.term_start BETWEEN ''' + cast(@gen_date_from as varchar)+ ''' AND ''' + cast(@gen_date_to as varchar)+ '''' end      
+ case when (@technology IS NULL) then '' else ' AND  rg.technology = ' + cast(@technology as varchar) end  
+ case when (@assignment_type IS NULL) then '' else ' AND  assign.assignment_type = ' + cast(@assignment_type as varchar) end  
+ case when (@buysell_flag IS NULL) then '' else ' AND  sdd1.buy_sell_flag = ''' + cast(@buysell_flag as varchar)+'''' end  
+ case when (@transaction_from IS NULL) then '' else ' AND  sdh1.deal_date BETWEEN ''' + cast(@transaction_from as varchar)+ ''' AND ''' + cast(@transaction_to as varchar)+ '''' end      
+ case when (@assigned_year IS NULL) then '' else ' AND  year(assign.assigned_date) = ' + cast(@assigned_year as varchar) end 
+ case when @include_inventory ='y' then ' AND ISNULL(rga.exclude_inventory,rg.exclude_inventory)=''y''' else case when isnull(@assignment_type,5149)=5149 then ' AND (ISNULL(rga.exclude_inventory,rg.exclude_inventory) is null or ISNULL(rga.exclude_inventory,rg.exclude_inventory)=''n'') ' else '' end end
+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id='+CAST(@counterparty_id AS VARCHAR) ELSE '' END

IF (@certno_from IS NOT NULL AND @certno_to IS NULL)   
	SET @sql_stmt1 = @sql_stmt1 +' AND ( gis.certificate_number_from_int  >= '+ @certno_from +') '
ELSE IF (@certno_from IS NULL AND @certno_to IS NOT NULL)
	SET @sql_stmt1 = @sql_stmt1 +' and  (gis.certificate_number_to_int  <= '+ @certno_to     
        +') ' 
ELSE IF (@certno_from IS NOT NULL AND @certno_to IS NOT NULL) 
  SET @sql_stmt1 = @sql_stmt1 +' AND ( gis.certificate_number_from_int  >= '+ @certno_from  +' and  gis.certificate_number_to_int  <= '+ @certno_to     
        +') ' 

--PRINT (@sql_stmt1)





IF @report_type='x'
	EXEC ('select [Sell Acct],[Buy Acct],[Sell AAR],[Buy AAR],[Perpetuity],[Allw Year],[Ser Start],[Ser End]'+ @str_get_row_number+' '+ @str_batch_table +'
	 from (' + @sql_stmt0 + ' UNION all ' + @sql_stmt1 + ') xx  
	where volume>0      
	order by Id asc,create_ts asc , isNull([Cert # From],''z'') , SID ASC, cast(gis_cert_date as varchar) asc  ')   

ELSE
	EXEC ('select dbo.FNAHyperLinkText(10131010, cast(deal_id as varchar), cast(deal_id as varchar)) as [ID],  
			[Source],[Cert # From],[Cert # To],volume as [# of RECs],assignment as [Last Operation],dbo.FNADateFormat(gis_cert_date) as [Last Operation Date],
	assignment_type as [Assignment],ComplianceYear  as [Compliance Year] '+ @str_get_row_number+' '+ @str_batch_table +'
	 from (' + @sql_stmt0 + ' UNION all ' + @sql_stmt1 + ') xx  
	where volume>0      
	order by Id asc,create_ts asc , isNull([Cert # From],''z'') , SID ASC, cast(gis_cert_date as varchar) asc  ')        
        
--exec spa_create_lifecycle_of_recs '2006-09-18',NULL,NULL

if @batch_process_id is not null
begin
	exec spa_print '@str_batch_table'  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   exec spa_print @str_batch_table
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_REC_Exposure_Report','Run REC Exposure Report')         
	 EXEC spa_print @str_batch_table
	 EXEC(@str_batch_table)        
	EXEC spa_print 'finsh spa_REC_Exposure_Report'
	return
END



	

























