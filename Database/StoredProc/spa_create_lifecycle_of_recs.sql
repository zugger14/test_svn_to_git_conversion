
IF OBJECT_ID('[dbo].[spa_create_lifecycle_of_recs]') IS NOT null
DROP PROC [dbo].[spa_create_lifecycle_of_recs] 
GO

CREATE PROCEDURE [dbo].[spa_create_lifecycle_of_recs]        
	@as_of_date varchar(20),        
	@book_deal_type_map_id varchar(max) = null,        
	@source_deal_header_id varchar(5000)  = NULL,
	@cert_from BIGINT = NULL,
	@cert_to BIGINT = NULL,
	@deal_date_from VARCHAR(20) = NULL, 
	@deal_date_to VARCHAR(20) = NULL,
	@deal_id_from INT = NULL,
	@deal_id_to INT = NULL,
	@counterparty_id varchar(500) = NULL, 
	@deal_type_id VARCHAR(100) = NULL,
	@deal_sub_type_id VARCHAR(100) = NULL,
	@deal_category_value_id int=NULL,
	@physical_financial_flag CHAR(10)=NULL,
    @trader_id int=NULL,
    @tenor_from varchar(20) = NULL,
	@tenor_to varchar(20) = NULL,
	@description1 varchar(100)=NULL,
	@description2 varchar(100)=NULL,
	@description3 varchar(100)=NULL,
	@generator_id INT = NULL ,
    @compliance_year int = NULL,
    @gis_value_id int = NULL ,
    @gis_cert_date varchar(20) = NULL ,
	@gen_cert_number varchar (250) = NULL ,
	@gen_cert_date varchar(20) = NULL,
	@assignment_type_value_id int = NULL,
	@state_value_id int = NULL,
	@assigned_date datetime = NULL ,
	@assigned_by varchar (50) = NULL,
	@status_value_id int = NULL,
	@status_date datetime = NULL,
	@header_buy_sell_flag varchar(1)=NULL,
	@deal_id varchar(100)=NULL,
	
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
	
AS        
  SET NOCOUNT ON 

-- select * from #temp_assign_unassign
-- return
-- DECLARE  @as_of_date varchar(20)        
-- DECLARE  @book_deal_type_map_id varchar(1000)        
-- DECLARE  @source_deal_header_id varchar(5000)        
-- 
-- drop table #temp_assign_unassign      
--        
-- SET @as_of_date = '2006-11-01'        
-- SET @book_deal_type_map_id = null        
-- SET @source_deal_header_id = '1778'  

--DECLARE      
--	@as_of_date varchar(20)='2017-09-08',        
--	@book_deal_type_map_id varchar(max) = '364',        
--	@source_deal_header_id varchar(5000)  = NULL,
--	@cert_from BIGINT = NULL,
--	@cert_to BIGINT = NULL,
--	@deal_date_from VARCHAR(20) = '2017-01-01', 
--	@deal_date_to VARCHAR(20) = '2017-09-30',
--	@deal_id_from INT = NULL,
--	@deal_id_to INT = NULL,
--	@counterparty_id varchar(500) = NULL, 
--	@deal_type_id VARCHAR(100) = NULL,
--	@deal_sub_type_id VARCHAR(100) = NULL,
--	@deal_category_value_id int=NULL,
--	@physical_financial_flag CHAR(10)='b',
--    @trader_id int=NULL,
--    @tenor_from varchar(20) = NULL,
--	@tenor_to varchar(20) = NULL,
--	@description1 varchar(100)=NULL,
--	@description2 varchar(100)=NULL,
--	@description3 varchar(100)=NULL,
--	@generator_id INT = NULL ,
--    @compliance_year int = NULL,
--    @gis_value_id int = NULL ,
--    @gis_cert_date varchar(20) = NULL ,
--	@gen_cert_number varchar (250) = NULL ,
--	@gen_cert_date varchar(20) = NULL,
--	@assignment_type_value_id int = '5149',
--	@state_value_id int = NULL,
--	@assigned_date datetime = NULL ,
--	@assigned_by varchar (50) = NULL,
--	@status_value_id int = NULL,
--	@status_date datetime = NULL,
--	@header_buy_sell_flag varchar(1)=NULL,
--	@deal_id varchar(100)=NULL,
	
--	@batch_process_id VARCHAR(50)=NULL,
--	@batch_report_param VARCHAR(1000)=NULL,
--	@enable_paging INT = 0,  --'1' = enable, '0' = disable
--	@page_size INT = NULL,
--	@page_no INT = NULL      
        
DECLARE @sql_stmt1 varchar(max)        
DECLARE @sql_stmt2 varchar(max)        
DECLARE @sql_stmt0 varchar(max)        
DECLARE @sql_stmt4 varchar(max)

--drop table #temp_assign_unassign
--drop table #temp_assign_unassign_gis

If @deal_id_from IS NOT NULL AND @deal_id_to IS NULL 
	SET @deal_id_to = @deal_id_from 
If @deal_id_to IS NOT NULL AND @deal_id_from IS NULL 
	SET @deal_id_from = @deal_id_to 

If @deal_date_from IS NOT NULL AND @deal_date_to IS NULL
	SET @deal_date_to = @deal_date_from
If @deal_date_from IS  NULL AND @deal_date_to IS NOT NULL
	SET @deal_date_from = @deal_date_to

--If @tenor_from IS NOT NULL AND @tenor_to IS NULL
--	SET @tenor_to = @tenor_from
--If @tenor_from IS NULL AND @tenor_to IS NOT NULL
--	SET @tenor_from = @tenor_to


--If @cert_from IS NOT NULL AND @cert_to IS NULL
--	SET @cert_to = @cert_from
--If @cert_from IS NULL AND @cert_to IS NOT NULL
--	SET @cert_from = @cert_to

IF @physical_financial_flag IS NOT NULL
BEGIN
	IF  @physical_financial_flag = 'b'
	BEGIN
		SET @physical_financial_flag = 'f'',''p'
	END
END

DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
        
---=============THIS ONE IS THE AUDIT TRAIL .....        
------------------------------------------------        
    
--//bikash
IF @enable_paging = 1
BEGIN
	SET @sql_stmt0 =  'select         
						cast(sdh.source_deal_header_id as varchar) ID,'
END
ELSE 
BEGIN
	SET @sql_stmt0 = 'select         
						dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), cast(sdh.source_deal_header_id as varchar)) ID,'
END
SET @sql_stmt0 = @sql_stmt0 + '         
 dbo.FNADateFormat(sdh.deal_date) Date,         
 dbo.FNADateFormat(sdd.term_start) [Gen Date],         
 0 as SID,    
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],(gis.certificate_number_from_int),sdd.term_start)  [Cert # From],    
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],(gis.certificate_number_to_int),sdd.term_start)  [Cert # To],      
 cast(round(sdd.deal_volume, 0) as float) Volume,         
 ''Audit'' Source,         
 su.uom_name Unit,'          
 
 IF @enable_paging = 1
 BEGIN
 	SET @sql_stmt0 = @sql_stmt0 + '''Initial:'''
 END 
 ELSE 
 BEGIN
 	SET @sql_stmt0 = @sql_stmt0 + '''<b>Initial: </b>'''
 END
         
 SET @sql_stmt0 = @sql_stmt0 + '+          
case  when sdd.buy_sell_flag=''s'' and sdh.status_value_id=5180 then '' Inventory Adjustments Sale''
  when (sdd.buy_sell_flag = ''b'') then         
  case when (isnull(sc.int_ext_flag, ''e'') = ''i'') then ''Generated''         
   else ''Bought from '' + isnull(sc.counterparty_name, '''') end         
 else ''Sold to '' + isnull(sc.counterparty_name, '''') + '' - from deal '' +        
   dbo.FNAHyperLinkText(10131010,         
   cast(sdh.ext_deal_id as varchar),        
   cast(sdh.source_deal_header_id as varchar))        
 end Assignment,         
 isnull(cast(sdh.compliance_year as varchar),'''') [Compliance Year],        
 COALESCE(expi.code, state.code, state_rg.code) [Assigned State],        
        
 dbo.FNADateFormat(sdh.deal_date) [As Of Date],        
 isnull(au.user_l_name + '', '' + au.user_f_name + '' '' + isNull(user_m_name,''''), '''') [Assigned By],        
 COALESCE(expi.code, state.code, state_rg.code) + '': '' +         
 dbo.FNADEALRECExpiration(sdd.source_deal_detail_id, sdd.contract_expiration_date, NULL) Expiration,         
 sdh.create_ts [Audit TS]   
 from source_deal_header sdh inner join  source_deal_detail sdd      
 on sdh.source_deal_header_id=sdd.source_deal_header_id inner join        
 source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
 sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN        
 portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id LEFT OUTER JOIN        
 static_data_value ass on ass.value_id = sdh.assignment_type_value_id left outer  join        
 static_data_value state on state.value_id = sdh.state_value_id left outer  join        
 application_users au on au.user_login_id = sdh.assigned_by left outer join        
 rec_generator rg on rg.generator_id = sdh.generator_id left outer join         
 state_properties sp on sp.state_value_id = isnull(sdh.state_value_id, rg.state_value_id) left outer join        
 static_data_value state_rg on state_rg.value_id = rg.state_value_id LEFT OUTER JOIN        
        source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id LEFT OUTER JOIN                 
 source_deal_header sellP on sellP.ext_deal_id = case when (sdh.assignment_type_Value_id = 5173) then        
         cast(sdh.source_deal_header_id as varchar)        
       else ''-1xx-1'' end        
--certificate        
LEFT JOIN Gis_certificate gis on      
 gis.source_deal_header_id=sdd.source_deal_detail_id
 LEFT JOIN static_data_value expi ON expi.value_id = gis.state_value_id      
LEFT JOIN      
certificate_rule cr on      
 rg.gis_value_id=cr.gis_id    
left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id    
        
 where 1 = 1 and    sbm.fas_deal_type_value_id=400 and     
 (sdh.assignment_type_value_id IS NULL)        
 AND sdd.deal_volume>0       
'  
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
ELSE 
	+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'  
	ELSE 
		+ CASE WHEN (@deal_id IS NOT NULL) THEN ' and sdh.deal_id in (''' + @deal_id + ''')' 
		ELSE         
			+ CASE WHEN (@book_deal_type_map_id IS NULL) THEN '' ELSE ' and sbm.book_deal_type_map_id in (' + @book_deal_type_map_id + ')' END  
			+ CASE WHEN (@cert_from IS NOT NULL) THEN ' AND gis.certificate_number_from_int>=' + CAST(@cert_from  AS VARCHAR) ELSE '' END 
			+ CASE WHEN (@cert_to IS NOT NULL) THEN ' AND gis.certificate_number_to_int<=' + CAST(@cert_to  AS VARCHAR) + '' ELSE '' END
			+ CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END
			+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_type_id IS NOT NULL THEN ' AND (sdh.source_deal_type_id IN (' + @deal_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_sub_type_id IS NOT NULL THEN ' AND (sdh.deal_sub_type_type_id IN (' + @deal_sub_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_category_value_id IS NOT NULL THEN ' AND (sdh.deal_category_value_id IN (' + CAST(@deal_category_value_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @physical_financial_flag IS NOT NULL THEN ' AND (sdh.physical_financial_flag IN (''' + @physical_financial_flag + ''')) ' ELSE '' END
			+ CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + @tenor_from + '''' ELSE '' END
			+ CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' +  @tenor_to + '''' ELSE '' END			
			+ CASE WHEN @description1 IS NOT NULL THEN ' AND sdh.description1 LIKE ''' + @description1 + '''' ELSE '' END
			+ CASE WHEN @description2 IS NOT NULL THEN ' AND sdh.description2 LIKE ''' + @description2 + '''' ELSE '' END
			+ CASE WHEN @description3 IS NOT NULL THEN ' AND sdh.description3 LIKE ''' + @description3 + '''' ELSE '' END
			+ CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id = ''' + CAST(@generator_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year = ''' + CAST(@compliance_year AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_value_id IS NOT NULL THEN ' AND rg.gis_value_id = ''' + CAST(@gis_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_cert_date IS NOT NULL THEN ' AND gis.gis_cert_date = ''' + @gis_cert_date + '''' ELSE '' END
			+ CASE WHEN @gen_cert_number IS NOT NULL THEN ' AND rg.gis_account_number = ''' + @gen_cert_number + '''' ELSE '' END
			+ CASE WHEN @gen_cert_date IS NOT NULL THEN ' AND rg.registration_date = ''' + @gen_cert_date + '''' ELSE '' END
			+ CASE WHEN @assignment_type_value_id IS NOT NULL THEN ' AND isnull(sdh.assignment_type_value_id, 5149) = ''' + cast(@assignment_type_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @state_value_id IS NOT NULL THEN ' AND COALESCE(expi.value_id, state.value_id, state_rg.value_id) = ''' + CAST(@state_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date = ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' ELSE '' END
			+ CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by = ''' + @assigned_by + '''' ELSE '' END
			+ CASE WHEN @status_value_id IS NOT NULL THEN ' AND sdh.status_value_id = ''' + CAST(@status_value_id  AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @status_date IS NOT NULL THEN ' AND sdh.status_date = ''' + dbo.FNAGetSQLStandardDate(@status_date) + '''' ELSE '' END
			+ CASE WHEN @header_buy_sell_flag IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @header_buy_sell_flag + '''' ELSE '' END +''
		END
	END
END
      
    
--exec(@sql_stmt0)    
--return
--exec (@sql_stmt0)        
--Print @sql_stmt0    

     
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
   cert_from int,
cert_to int,
[ID1] int	
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
[ID1]   
)    
    
select a.* from(    
 
select a.assignment_id,a.assignment_type,round(a.assigned_volume,0) assigned_volume,    
NULL assign_flag,a.source_deal_header_id,a.source_deal_header_id_from,a.create_ts,a.state_value_id,    
a.compliance_year,a.assigned_date,a.assigned_by,a.cert_from,a.cert_to,2 as [ID]
from assignment_audit a     
join source_deal_detail sdd on a.source_deal_header_id_from=sdd.source_deal_detail_id 
join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id inner join        
 source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
 sdh.source_system_book_id4 = sbm.source_system_book_id4
where 1=1
' + case when (@source_deal_header_id IS NULL) THEN ''         
 else ' and sdh.source_deal_header_id in (' + @source_deal_header_id + ')' end         
+ case when (@book_deal_type_map_id IS NULL) THEN ''          
 else ' and sbm.book_deal_type_map_id in (' + cast(@book_deal_type_map_id  as varchar)+ ')' end  +'       
  and a.assigned_volume > 0 
UNION
select a.assignment_id,a.assignment_type,case when assign_flag=''y'' then -1 * round(assigned_volume,0)      
else round(assigned_volume,0) end as assigned_volume,    
a.assign_flag,a.source_deal_header_id,a.source_deal_header_id_from,a.create_ts,a.state_value_id,    
a.compliance_year,a.assigned_date,a.assigned_by,a.cert_from,a.cert_to,1 as [ID] 
from unassignment_audit a 
join source_deal_detail sdd on a.source_deal_header_id_from=sdd.source_deal_detail_id 
join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id inner join        
 source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
 sdh.source_system_book_id4 = sbm.source_system_book_id4
      
LEFT OUTER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id        
LEFT OUTER JOIN static_data_value state_rg ON state_rg.value_id = rg.state_value_id
LEFT OUTER JOIN source_deal_header sellP ON sellP.ext_deal_id = CASE WHEN (sdh.assignment_type_Value_id = 5173) 
	THEN CAST(sdh.source_deal_header_id AS VARCHAR) ELSE ''-1xx-1'' END        
 --certificate        
LEFT JOIN Gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id      
INNER JOIN certificate_rule cr ON rg.gis_value_id=cr.gis_id      
LEFT JOIN source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id  
WHERE 1=1 
' 
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
ELSE 
	+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'  
	ELSE 
		+ CASE WHEN (@deal_id IS NOT NULL) THEN ' and sdh.deal_id in (''' + @deal_id + ''')' 
		ELSE         
			+ CASE WHEN (@book_deal_type_map_id IS NULL) THEN '' ELSE ' and sbm.book_deal_type_map_id in (' + @book_deal_type_map_id + ')' END  
			+ CASE WHEN (@cert_from IS NOT NULL) THEN ' AND gis.certificate_number_from_int>=' + CAST(@cert_from  AS VARCHAR) ELSE '' END 
			+ CASE WHEN (@cert_to IS NOT NULL) THEN ' AND gis.certificate_number_to_int<=' + CAST(@cert_to  AS VARCHAR) + '' ELSE '' END
			+ CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END
			+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_type_id IS NOT NULL THEN ' AND (sdh.source_deal_type_id IN (' + @deal_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_sub_type_id IS NOT NULL THEN ' AND (sdh.deal_sub_type_type_id IN (' + @deal_sub_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_category_value_id IS NOT NULL THEN ' AND (sdh.deal_category_value_id IN (' + CAST(@deal_category_value_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @physical_financial_flag IS NOT NULL THEN ' AND (sdh.physical_financial_flag IN (''' + @physical_financial_flag + ''')) ' ELSE '' END
			+ CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + @tenor_from + '''' ELSE '' END
			+ CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' +  @tenor_to + '''' ELSE '' END			
			+ CASE WHEN @description1 IS NOT NULL THEN ' AND sdh.description1 LIKE ''' + @description1 + '''' ELSE '' END
			+ CASE WHEN @description2 IS NOT NULL THEN ' AND sdh.description2 LIKE ''' + @description2 + '''' ELSE '' END
			+ CASE WHEN @description3 IS NOT NULL THEN ' AND sdh.description3 LIKE ''' + @description3 + '''' ELSE '' END
			+ CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id = ''' + CAST(@generator_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year = ''' + CAST(@compliance_year AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_value_id IS NOT NULL THEN ' AND rg.gis_value_id = ''' + CAST(@gis_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_cert_date IS NOT NULL THEN ' AND gis.gis_cert_date = ''' + @gis_cert_date + '''' ELSE '' END
			+ CASE WHEN @gen_cert_number IS NOT NULL THEN ' AND rg.gis_account_number = ''' + @gen_cert_number + '''' ELSE '' END
			+ CASE WHEN @gen_cert_date IS NOT NULL THEN ' AND rg.registration_date = ''' + @gen_cert_date + '''' ELSE '' END
			+ CASE WHEN @assignment_type_value_id IS NOT NULL THEN ' AND isnull(sdh.assignment_type_value_id, 5149) = ''' + cast(@assignment_type_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @state_value_id IS NOT NULL THEN ' AND a.state_value_id = ''' + CAST(@state_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date = ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' ELSE '' END
			+ CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by = ''' + @assigned_by + '''' ELSE '' END
			+ CASE WHEN @status_value_id IS NOT NULL THEN ' AND sdh.status_value_id = ''' + CAST(@status_value_id  AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @status_date IS NOT NULL THEN ' AND sdh.status_date = ''' + dbo.FNAGetSQLStandardDate(@status_date) + '''' ELSE '' END
			+ CASE WHEN @header_buy_sell_flag IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @header_buy_sell_flag + '''' ELSE '' END +''
		END
	END
END
+'      

) a order by source_deal_header_id_from,[ID],create_ts'
--print (@sql_stmt4)
 exec(@sql_stmt4)
--select * from gis_certificate
-- 
-- select * from #temp_assign_unassign
-- return
-----------------------------------------------------------------    
-- select     
--  [ID],    
--  assignment_id,    
--  source_deal_header_id,    
--  source_deal_header_id_from,    
--  round(assigned_volume,0) as assigned_volume,    
--  assignment_type,    
--  round(abs(case when assign_flag='y' then 0 else abs(assigned_volume) end-(select sum(assigned_volume) from #temp_assign_unassign  where [ID]<=tmp.[ID] and     
--  source_deal_header_id_from=tmp.source_deal_header_id_from))+1,0) as fromvol,    
--  case when assign_flag='y' then  round(abs(assigned_volume),0) else 0 end+    
--  (select round(sum(assigned_volume),0) from #temp_assign_unassign  where [ID]<=tmp.[ID] and     
--  source_deal_header_id_from=tmp.source_deal_header_id_from)as TOvol,    
--  create_ts,    
--  state_value_id,    
--  compliance_year,    
--  assigned_date,    
--  assigned_by,    
--  assign_flag    
-- into #temp_assign_unassign1     
-- FROM #temp_assign_unassign tmp    
    
------------------------------------    
IF (@batch_process_id IS NOT NULL)
BEGIN
	SET @sql_stmt1 = 'select DISTINCT    
 					cast(sdh.source_deal_header_id as varchar) ID,'
END	
ELSE
BEGIN
	SET @sql_stmt1 = 'select DISTINCT    
	dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), cast(sdh.source_deal_header_id as varchar)) ID,'		
END
					

SET @sql_stmt1 = @sql_stmt1 + '        
 dbo.FNADateFormat(sdh.deal_date) Date,         
 dbo.FNADateFormat(sdd.term_start) [Gen Date],         
 isnull(assign.ID, 0) as SID,        
dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_from,sdd.term_start) +''&nbsp;'' [Cert # From],      
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to,sdd.term_start) +''&nbsp;'' [Cert # To],   
 case  when (assign.assignment_type <> 5149)     
 THEN cast(round(abs(assign.assigned_volume), 0) as float)     
 else cast(round(sdd.volume_left, 0) as float) end volume,    
 ''Audit'' Source,        
 su.uom_name Unit,    
 isnull(ass.code, ''Banked'')  +     
 case when assign.assign_flag=''y'' then '' - UnAssigned'' else '''' end  as Assignment,         
 isnull(cast(assign.compliance_year as varchar),'''') [Compliance Year],        
 isnull(state.code, state_rg.code) [Assigned State],        
 isnull(dbo.FNADateFormat(assign.assigned_date), '''') [As Of Date],        
 isnull(au.user_l_name + '', '' + au.user_f_name + '' '' + isNull(user_m_name,''''), '''') [Assigned By],        
 COALESCE(state.code, state_rg.code) + '': '' +         
         
 dbo.FNADEALRECExpiration(sdd.source_deal_detail_id, sdd.contract_expiration_date, NULL) Expiration,        
         
 case  when (assign.assignment_id IS NULL) THEN sdh.create_ts
 else assign.create_ts end [Audit TS]      
  from source_deal_header sdh inner join source_deal_detail sdd on       
 sdh.source_deal_header_id=sdd.source_deal_header_id inner join 
 source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
 sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN        
 portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id     
    
inner JOIN    
#temp_assign_unassign assign    
    
on sdd.source_deal_detail_id=assign.source_deal_header_id_from    
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
LEFT JOIN Gis_certificate gis on      
 gis.source_deal_header_id=sdd.source_deal_detail_id     
INNER JOIN    
certificate_rule cr on      
 rg.gis_value_id=cr.gis_id      
left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id          
 where 1 = 1     
        
' 
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
ELSE 
	+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'  
	ELSE 
		+ CASE WHEN (@deal_id IS NOT NULL) THEN ' and sdh.deal_id in (''' + @deal_id + ''')' 
		ELSE         
			+ CASE WHEN (@book_deal_type_map_id IS NULL) THEN '' ELSE ' and sbm.book_deal_type_map_id in (' + @book_deal_type_map_id + ')' END  
			+ CASE WHEN (@cert_from IS NOT NULL) THEN ' AND gis.certificate_number_from_int>=' + CAST(@cert_from  AS VARCHAR) ELSE '' END 
			+ CASE WHEN (@cert_to IS NOT NULL) THEN ' AND gis.certificate_number_to_int<=' + CAST(@cert_to  AS VARCHAR) + '' ELSE '' END
			+ CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END
			+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_type_id IS NOT NULL THEN ' AND (sdh.source_deal_type_id IN (' + @deal_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_sub_type_id IS NOT NULL THEN ' AND (sdh.deal_sub_type_type_id IN (' + @deal_sub_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_category_value_id IS NOT NULL THEN ' AND (sdh.deal_category_value_id IN (' + CAST(@deal_category_value_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @physical_financial_flag IS NOT NULL THEN ' AND (sdh.physical_financial_flag IN (''' + @physical_financial_flag + ''')) ' ELSE '' END
			+ CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + @tenor_from + '''' ELSE '' END
			+ CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' +  @tenor_to + '''' ELSE '' END			
			+ CASE WHEN @description1 IS NOT NULL THEN ' AND sdh.description1 LIKE ''' + @description1 + '''' ELSE '' END
			+ CASE WHEN @description2 IS NOT NULL THEN ' AND sdh.description2 LIKE ''' + @description2 + '''' ELSE '' END
			+ CASE WHEN @description3 IS NOT NULL THEN ' AND sdh.description3 LIKE ''' + @description3 + '''' ELSE '' END
			+ CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id = ''' + CAST(@generator_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year = ''' + CAST(@compliance_year AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_value_id IS NOT NULL THEN ' AND rg.gis_value_id = ''' + CAST(@gis_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_cert_date IS NOT NULL THEN ' AND gis.gis_cert_date = ''' + @gis_cert_date + '''' ELSE '' END
			+ CASE WHEN @gen_cert_number IS NOT NULL THEN ' AND rg.gis_account_number = ''' + @gen_cert_number + '''' ELSE '' END
			+ CASE WHEN @gen_cert_date IS NOT NULL THEN ' AND rg.registration_date = ''' + @gen_cert_date + '''' ELSE '' END
			+ CASE WHEN @assignment_type_value_id IS NOT NULL THEN ' AND isnull(sdh.assignment_type_value_id, 5149) = ''' + cast(@assignment_type_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @state_value_id IS NOT NULL THEN ' AND ISNULL(state.value_id, state_rg.value_id) = ''' + CAST(@state_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date = ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' ELSE '' END
			+ CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by = ''' + @assigned_by + '''' ELSE '' END
			+ CASE WHEN @status_value_id IS NOT NULL THEN ' AND sdh.status_value_id = ''' + CAST(@status_value_id  AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @status_date IS NOT NULL THEN ' AND sdh.status_date = ''' + dbo.FNAGetSQLStandardDate(@status_date) + '''' ELSE '' END
			+ CASE WHEN @header_buy_sell_flag IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @header_buy_sell_flag + '''' ELSE '' END +''
		END
	END
END
         
        
--PRINT  @sql_stmt1       
--exec(@sql_stmt1)   

IF (@batch_process_id IS NOT NULL)
BEGIN
	SET @sql_stmt4 = 'select DISTINCT    
 					cast(sdh.source_deal_header_id as varchar) ID,'
END	
ELSE
BEGIN
	SET @sql_stmt4 = 'select DISTINCT    
	dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), cast(sdh.source_deal_header_id as varchar)) ID,'		
END

SET @sql_stmt4 = @sql_stmt4 + '        
 dbo.FNADateFormat(sdh.deal_date) Date,         
 dbo.FNADateFormat(sdd.term_start) [Gen Date],         
 isnull(assign.ID, 0) as SID,        
dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_from,sdd.term_start) +''&nbsp;'' [Cert # From],      
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to,sdd.term_start) +''&nbsp;'' [Cert # To],   
 sdd.volume_left AS volume,    
 ''Audit'' Source,        
 su.uom_name Unit,    
 ''Banked'' AS Assignment,         
 isnull(cast(assign.compliance_year as varchar),'''') [Compliance Year],        
 '''' AS [Assigned State],        
 isnull(dbo.FNADateFormat(assign.assigned_date), '''') [As Of Date],        
 isnull(au.user_l_name + '', '' + au.user_f_name + '' '' + isNull(user_m_name,''''), '''') [Assigned By],        
 COALESCE(state.code, state_rg.code) + '': '' + 
 dbo.FNADEALRECExpiration(sdd.source_deal_detail_id, sdd.contract_expiration_date, NULL) Expiration,        
 case  when (assign.assignment_id IS NULL) THEN        
  dbo.FNADateTimeFormat(sdh.create_ts, 1)         
 else dbo.FNADateTimeFormat(assign.create_ts, 1) end [Audit TS]      
  from source_deal_header sdh inner join source_deal_detail sdd on       
 sdh.source_deal_header_id=sdd.source_deal_header_id inner join 
 source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
 sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN        
 portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id     
    
inner JOIN    
#temp_assign_unassign assign    
    
on sdd.source_deal_detail_id=assign.source_deal_header_id_from    
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
LEFT JOIN Gis_certificate gis on      
 gis.source_deal_header_id=sdd.source_deal_detail_id     
INNER JOIN    
certificate_rule cr on      
 rg.gis_value_id=cr.gis_id      
left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id          
 where 1 = 1 AND sdd.volume_left > 0    
        
' 
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
ELSE 
	+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'  
	ELSE 
		+ CASE WHEN (@deal_id IS NOT NULL) THEN ' and sdh.deal_id in (''' + @deal_id + ''')' 
		ELSE         
			+ CASE WHEN (@book_deal_type_map_id IS NULL) THEN '' ELSE ' and sbm.book_deal_type_map_id in (' + @book_deal_type_map_id + ')' END  
			+ CASE WHEN (@cert_from IS NOT NULL) THEN ' AND gis.certificate_number_from_int>=' + CAST(@cert_from  AS VARCHAR) ELSE '' END 
			+ CASE WHEN (@cert_to IS NOT NULL) THEN ' AND gis.certificate_number_to_int<=' + CAST(@cert_to  AS VARCHAR) + '' ELSE '' END
			+ CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END
			+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_type_id IS NOT NULL THEN ' AND (sdh.source_deal_type_id IN (' + @deal_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_sub_type_id IS NOT NULL THEN ' AND (sdh.deal_sub_type_type_id IN (' + @deal_sub_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_category_value_id IS NOT NULL THEN ' AND (sdh.deal_category_value_id IN (' + CAST(@deal_category_value_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @physical_financial_flag IS NOT NULL THEN ' AND (sdh.physical_financial_flag IN (''' + @physical_financial_flag + ''')) ' ELSE '' END
			+ CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + @tenor_from + '''' ELSE '' END
			+ CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' +  @tenor_to + '''' ELSE '' END			
			+ CASE WHEN @description1 IS NOT NULL THEN ' AND sdh.description1 LIKE ''' + @description1 + '''' ELSE '' END
			+ CASE WHEN @description2 IS NOT NULL THEN ' AND sdh.description2 LIKE ''' + @description2 + '''' ELSE '' END
			+ CASE WHEN @description3 IS NOT NULL THEN ' AND sdh.description3 LIKE ''' + @description3 + '''' ELSE '' END
			+ CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id = ''' + CAST(@generator_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year = ''' + CAST(@compliance_year AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_value_id IS NOT NULL THEN ' AND rg.gis_value_id = ''' + CAST(@gis_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_cert_date IS NOT NULL THEN ' AND gis.gis_cert_date = ''' + @gis_cert_date + '''' ELSE '' END
			+ CASE WHEN @gen_cert_number IS NOT NULL THEN ' AND rg.gis_account_number = ''' + @gen_cert_number + '''' ELSE '' END
			+ CASE WHEN @gen_cert_date IS NOT NULL THEN ' AND rg.registration_date = ''' + @gen_cert_date + '''' ELSE '' END
			+ CASE WHEN @assignment_type_value_id IS NOT NULL THEN ' AND isnull(sdh.assignment_type_value_id, 5149) = ''' + cast(@assignment_type_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @state_value_id IS NOT NULL THEN ' AND ISNULL(state.value_id, state_rg.value_id) = ''' + CAST(@state_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date = ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' ELSE '' END
			+ CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by = ''' + @assigned_by + '''' ELSE '' END
			+ CASE WHEN @status_value_id IS NOT NULL THEN ' AND sdh.status_value_id = ''' + CAST(@status_value_id  AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @status_date IS NOT NULL THEN ' AND sdh.status_date = ''' + dbo.FNAGetSQLStandardDate(@status_date) + '''' ELSE '' END
			+ CASE WHEN @header_buy_sell_flag IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @header_buy_sell_flag + '''' ELSE '' END +''
		END
	END
END 

 --order by draa.create_ts asc        
        
---=============THIS ONE IS THE LAST STATUS ON THE DEAL        
------------------------------------------------        
--exec(@sql_stmt1)    
--return    

create table #temp_assign_unassign_gis(
source_deal_detail_id int,
cert_from int,
cert_to int,
assignment_type int,
total_volume int)

-- set @sql_stmt2=' insert #temp_assign_unassign_gis(source_deal_detail_id,cert_from,cert_to,assignment_type)
--    exec spa_get_dealblockdetail '+ isNull(@source_deal_header_id,'NULL') +','+isNull(@book_deal_type_map_id,'Null') 
 insert #temp_assign_unassign_gis(source_deal_detail_id,cert_from,cert_to,assignment_type,total_volume)
 exec spa_get_dealblockdetail @source_deal_header_id,@book_deal_type_map_id
--SELECT * FROM #temp_assign
--return
--exec(@sql_stmt2)

IF (@batch_process_id IS NOT NULL)
BEGIN
	SET @sql_stmt2 = 'select DISTINCT    
 					cast(sdh.source_deal_header_id as varchar) ID,'
END	
ELSE
BEGIN
	SET @sql_stmt2 = 'select DISTINCT    
	dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), cast(sdh.source_deal_header_id as varchar)) ID,'		
END

set @sql_stmt2 = @sql_stmt2 + '    
 dbo.FNADateFormat(sdh.deal_date) Date,         
 dbo.FNADateFormat(sdd.term_start) [Gen Date],         
 0 as SID,        
 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign1.cert_from,	sdd.term_start) 
	 [Cert # From] ,  
dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign1.cert_to,sdd.term_start)    [Cert # To],        
--case when assign1.source_deal_detail_id is not null  then (assign1.cert_to-assign1.cert_from + 1)
--else
-- round(sdd.volume_left,2)
--end
(sdd.deal_volume)
  Volume,         
 ''Transactions'' Source,        
 su.uom_name Unit,        
 case when  sdd.volume_left>0 then ''Final: Banked'' else '''' end Assignment,    
 isnull(cast(sdh.compliance_year as varchar),'''') [Compliance Year],        
 CASE WHEN  sdd.volume_left>0 then '''' ELSE COALESCE(expi.code, state.code, state_rg.code) END [Assigned State],             
   dbo.FNADateFormat(''' + @as_of_date + ''')  [As Of Date],        
 isnull(au.user_l_name + '', '' + au.user_f_name + '' '' + isNull(user_m_name,''''), '''') [Assigned By],        
 COALESCE(expi.code, state.code, state_rg.code) + '': '' +         
  cast(dbo.FNADEALRECExpiration(sdd.source_deal_detail_id, sdd.term_start, NULL) as varchar) Expiration,        
 sdh.update_ts [Audit TS]
  from 

source_deal_header sdh inner join  source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id      
 inner join     
 source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
 sdh.source_system_book_id4 = sbm.source_system_book_id4 
-- INNER JOIN        
-- portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id    
-- left join assignment_audit assign on    
-- assign.source_deal_header_id_from=sdd.source_deal_detail_id    
left join     
static_data_value ass on ass.value_id = sdh.assignment_type_value_id    
left join    
static_data_value ass1 on ass1.value_id = sdh.assignment_type_value_id    
left outer  join        

 static_data_value state on state.value_id = sdh.state_value_id left outer  join        
 application_users au on au.user_login_id = isnull(sdh.assigned_by, sdh.update_user) left outer join        
 rec_generator rg on rg.generator_id = sdh.generator_id left outer join         
 state_properties sp on sp.state_value_id = isnull(sdh.state_value_id, rg.state_value_id) left outer join        
 static_data_value state_rg on state_rg.value_id = rg.state_value_id LEFT OUTER JOIN        
 source_deal_header sellP on sellP.ext_deal_id = case when (sdh.assignment_type_Value_id = 5173) then        
         cast(sdh.source_deal_header_id as varchar)        
       else ''-1xx-1'' end        
 LEFT OUTER JOIN source_counterparty sc on sc.source_counterparty_id = sellP.counterparty_id         
  
--certificate        
 JOIN  
#temp_assign_unassign_gis assign1    
on assign1.source_deal_detail_id=sdd.source_deal_detail_id  and assign1.assignment_type=5149    
LEFT JOIN Gis_certificate gis on      
 gis.source_deal_header_id=sdd.source_deal_detail_id
 LEFT JOIN static_data_value expi ON expi.value_id = gis.state_value_id      
inner join     
certificate_rule cr on      
 rg.gis_value_id=cr.gis_id    
left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id   
 where 1 = 1 and sdd.volume_left<>0  
 --and sdd.buy_sell_flag=''b''
' 
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
ELSE 
	+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'  
	ELSE 
		+ CASE WHEN (@deal_id IS NOT NULL) THEN ' and sdh.deal_id in (''' + @deal_id + ''')' 
		ELSE         
			+ CASE WHEN (@book_deal_type_map_id IS NULL) THEN '' ELSE ' and sbm.book_deal_type_map_id in (''' + @book_deal_type_map_id + ''')' END  
			+ CASE WHEN (@cert_from IS NOT NULL) THEN ' AND gis.certificate_number_from_int>=' + CAST(@cert_from  AS VARCHAR) ELSE '' END 
			+ CASE WHEN (@cert_to IS NOT NULL) THEN ' AND gis.certificate_number_to_int<=' + CAST(@cert_to  AS VARCHAR) + '' ELSE '' END
			+ CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END
			+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (''' + @counterparty_id + ''')) ' ELSE '' END
			+ CASE WHEN @deal_type_id IS NOT NULL THEN ' AND (sdh.source_deal_type_id IN (''' + @deal_type_id + ''')) ' ELSE '' END
			+ CASE WHEN @deal_sub_type_id IS NOT NULL THEN ' AND (sdh.deal_sub_type_type_id IN (' + @deal_sub_type_id + ')) ' ELSE '' END
			+ CASE WHEN @deal_category_value_id IS NOT NULL THEN ' AND (sdh.deal_category_value_id IN (' + CAST(@deal_category_value_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @physical_financial_flag IS NOT NULL THEN ' AND (sdh.physical_financial_flag IN (''' + @physical_financial_flag + ''')) ' ELSE '' END
			+ CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR) + ')) ' ELSE '' END
			+ CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + @tenor_from + '''' ELSE '' END
			+ CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_end <= ''' +  @tenor_to + '''' ELSE '' END
			+ CASE WHEN @description1 IS NOT NULL THEN ' AND sdh.description1 LIKE ''' + @description1 + '''' ELSE '' END
			+ CASE WHEN @description2 IS NOT NULL THEN ' AND sdh.description2 LIKE ''' + @description2 + '''' ELSE '' END
			+ CASE WHEN @description3 IS NOT NULL THEN ' AND sdh.description3 LIKE ''' + @description3 + '''' ELSE '' END
			+ CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id = ''' + CAST(@generator_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year = ''' + CAST(@compliance_year AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_value_id IS NOT NULL THEN ' AND rg.gis_value_id = ''' + CAST(@gis_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @gis_cert_date IS NOT NULL THEN ' AND gis.gis_cert_date = ''' + @gis_cert_date + '''' ELSE '' END
			+ CASE WHEN @gen_cert_number IS NOT NULL THEN ' AND rg.gis_account_number = ''' + @gen_cert_number + '''' ELSE '' END
			+ CASE WHEN @gen_cert_date IS NOT NULL THEN ' AND rg.registration_date = ''' + @gen_cert_date + '''' ELSE '' END
			+ CASE WHEN @assignment_type_value_id IS NOT NULL THEN ' AND isnull(sdh.assignment_type_value_id, 5149) = ''' + cast(@assignment_type_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @state_value_id IS NOT NULL THEN ' AND COALESCE(expi.value_id, state.value_id, state_rg.value_id) = ''' + CAST(@state_value_id AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date = ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' ELSE '' END
			+ CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by = ''' + @assigned_by + '''' ELSE '' END
			+ CASE WHEN @status_value_id IS NOT NULL THEN ' AND sdh.status_value_id = ''' + CAST(@status_value_id  AS VARCHAR) + '''' ELSE '' END
			+ CASE WHEN @status_date IS NOT NULL THEN ' AND sdh.status_date = ''' + dbo.FNAGetSQLStandardDate(@status_date) + '''' ELSE '' END
			+ CASE WHEN @header_buy_sell_flag IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @header_buy_sell_flag + '''' ELSE '' END +''
		END
	END
END
   
--PRINT @sql_stmt0
--PRINT @sql_stmt1
--PRINT @sql_stmt2 
--PRINT @sql_stmt4
-- exec(@sql_stmt2)

--PRINT 'FINAL QUERY:'
--PRINT ('select ID,Date,[Gen Date],[Cert # From],[Cert # To],Volume,Source,Unit,Assignment,[Compliance Year],[Assigned State]    
  --,[As Of Date],[Assigned By],Expiration,[Audit TS]    
 --from (' + @sql_stmt0 + ' UNION all ' + @sql_stmt1 +  ' UNION all ' + @sql_stmt2 + ') xx        
--order by Id asc, Source ASC, isNull([Cert # From],''z'') , SID ASC, cast([As Of Date] as varchar) asc, cast([Audit TS] as DateTime) asc, ----Assignment asc  ')        


EXEC ('select ID,Date,[Gen Date],[Cert # From],[Cert # To],Volume,Source,Unit,Assignment,[Compliance Year],[Assigned State]    
  ,[As Of Date],[Assigned By],Expiration,dbo.FNADateTimeFormat([Audit TS],1) [Audit TS] '+ @str_batch_table +'       
 from (' + @sql_stmt0 + ' UNION all ' + @sql_stmt1 +  ' UNION ALL ' + @sql_stmt4 + ' UNION all ' + @sql_stmt2 + ') xx        
order by Id asc, Source ASC, isNull([Cert # From],''z'') , SID ASC, cast([As Of Date] as varchar) asc, cast([Audit TS] as DateTime) asc, Assignment asc  ')        

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_lifecycle_of_recs', 'Life cycle of transaction')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   --EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO