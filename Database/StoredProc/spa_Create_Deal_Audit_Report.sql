IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Create_Deal_Audit_Report]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_Create_Deal_Audit_Report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used to get deal audit for report

	Parameters
	@report_option : Report Option
	@deal_date_from : Deal Date From
	@deal_date_to : Deal Date To
	@update_by : Update By
	@update_date_from : Update Date From
	@update_date_to : Update Date To
	@counterparty_id : Counterparty Id
	@trader_id : Trader Id
	@source_system_book_id1 : Source System Book Id1
	@source_system_book_id2 : Source System Book Id2
	@source_system_book_id3 : Source System Book Id3
	@source_system_book_id4 : Source System Book Id4
	@deal_id_from : Deal Id From
	@deal_id_to : Deal Id To
	@source_deal_header_id : Source Deal Header Id
	@tenor_from : Tenor From
	@tenor_to : Tenor To
	@book_deal_type_map_id : Book Deal Type Map Id
	@sub_id : Sub Id
	@stra_id : Stra Id
	@book_id : Book Id
	@deal_status : Deal Status
	@user_action : User Action
	@generator_id : Generator Id
	@compliance_year : Compliance Year
	@cert_entity : Cert Entity
	@cert_date : Cert Date
	@assignment_type : Assignment Type
	@assigned_jurisdiction : Assigned Jurisdiction
	@assigned_date : Assigned Date
	@assigned_by : Assigned By
	@status : Status
	@status_date : Status Date
	@cert_no_from : Cert No From
	@cert_no_to : Cert No To
	@drill_deal_id : Drill Deal Id
	@update_timestamp : Update Timestamp
	@prior_updatedate : Prior Updatedate
	@prefix_table : Prefix Table
	@deleted_deals : Deleted Deals
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
	@enable_paging : Enable Paging
	@page_size : Page Size
	@page_no : Page No
*/
CREATE PROC [dbo].[spa_Create_Deal_Audit_Report]   
  @report_option CHAR(1) = 's',  
  @deal_date_from VARCHAR(20) = NULL,   
  @deal_date_to VARCHAR(20) = NULL,  
  @update_by VARCHAR(100) = NULL,  
  @update_date_from DATETIME,  
  @update_date_to DATETIME,    
  @counterparty_id NVARCHAR(1000) = NULL,   
  @trader_id VARCHAR(MAX) = NULL,  
  @source_system_book_id1 INT = NULL,   
  @source_system_book_id2 INT = NULL,   
  @source_system_book_id3 INT = NULL,   
  @source_system_book_id4 INT = NULL,   
  @deal_id_from INT = NULL,  
  @deal_id_to INT = NULL,  
  @source_deal_header_id VARCHAR(MAX) = NULL,  
  @tenor_from VARCHAR(20) = NULL,  
  @tenor_to VARCHAR(20) = NULL,  
  @book_deal_type_map_id VARCHAR(MAX) = NULL,  
  @sub_id VARCHAR(MAX) = NULL,  
  @stra_id VARCHAR(MAX) = NULL,   
  @book_id VARCHAR(MAX) = NULL,  
  @deal_status INT = NULL,  
  @user_action VARCHAR(50) = NULL,    
  @generator_id INT = NULL,  
  @compliance_year INT = NULL,  
  @cert_entity INT = NULL,  
  @cert_date DATETIME = NULL,  
  @assignment_type INT = NULL,  
  @assigned_jurisdiction INT = NULL,  
  @assigned_date DATETIME = NULL,  
  @assigned_by VARCHAR(50) = NULL,  
  @status INT = NULL,  
  @status_date DATETIME = NULL,  
  @cert_no_from INT = NULL,  
  @cert_no_to INT = NULL,  
  @drill_deal_id VARCHAR(100) = NULL,  
  @update_timestamp VARCHAR(100) = NULL,  
  @prior_updatedate VARCHAR(20) = NULL,
  @prefix_table VARCHAR(100) = NULL,    
  @deleted_deals CHAR(1) = 'n',
  @batch_process_id VARCHAR(50) = NULL,  
  @batch_report_param VARCHAR(500) = NULL,   
  @enable_paging INT = 0,  --'1'=enable, '0'=disable  
  @page_size INT = NULL,  
  @page_no INT = NULL  
AS

/*
	--/**************************TEST CODE START************************				
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON'); SET CONTEXT_INFO @contextinfo

DECLARE @report_option CHAR(1) = 's',  
	  @deal_date_from VARCHAR(20) = NULL,   
	  @deal_date_to VARCHAR(20) = NULL,  
	  @update_by VARCHAR(100) = NULL,  
	  @update_date_from DATETIME,  
	  @update_date_to DATETIME,    
	  @counterparty_id NVARCHAR(1000) = NULL,   
	  @trader_id VARCHAR(MAX) = NULL,  
	  @source_system_book_id1 INT = NULL,   
	  @source_system_book_id2 INT = NULL,   
	  @source_system_book_id3 INT = NULL,   
	  @source_system_book_id4 INT = NULL,   
	  @deal_id_from INT = NULL,  
	  @deal_id_to INT = NULL,  
	  @source_deal_header_id VARCHAR(MAX) = NULL,  
	  @tenor_from VARCHAR(20) = NULL,  
	  @tenor_to VARCHAR(20) = NULL,  
	  @book_deal_type_map_id VARCHAR(MAX) = NULL,  
	  @sub_id VARCHAR(MAX) = NULL,  
	  @stra_id VARCHAR(MAX) = NULL,   
	  @book_id VARCHAR(MAX) = NULL,  
	  @deal_status INT = NULL,  
	  @user_action VARCHAR(50) = NULL,    
	  @generator_id INT = NULL,  
	  @compliance_year INT = NULL,  
	  @cert_entity INT = NULL,  
	  @cert_date DATETIME = NULL,  
	  @assignment_type INT = NULL,  
	  @assigned_jurisdiction INT = NULL,  
	  @assigned_date DATETIME = NULL,  
	  @assigned_by VARCHAR(50) = NULL,  
	  @status INT = NULL,  
	  @status_date DATETIME = NULL,  
	  @cert_no_from INT = NULL,  
	  @cert_no_to INT = NULL,  
	  @drill_deal_id VARCHAR(100) = NULL,  
	  @update_timestamp VARCHAR(100) = NULL,  
	  @prior_updatedate VARCHAR(20) = NULL,
	  @prefix_table VARCHAR(100) = NULL,    
	  @deleted_deals CHAR(1) = 'n',
	  @batch_process_id VARCHAR(50) = NULL,  
	  @batch_report_param VARCHAR(500) = NULL,   
	  @enable_paging INT = 0,  --'1'=enable, '0'=disable  
	  @page_size INT = NULL,  
	  @page_no INT = NULL 


IF OBJECT_ID(N'tempdb..#amendment', N'U') IS NOT NULL
	DROP TABLE	#amendment			
IF OBJECT_ID(N'tempdb..#codevalue', N'U') IS NOT NULL
	DROP TABLE	#codevalue			
IF OBJECT_ID(N'tempdb..#cursor_valueid_code', N'U') IS NOT NULL
	DROP TABLE	#cursor_valueid_code			
IF OBJECT_ID(N'tempdb..#deal_deatail_aaa', N'U') IS NOT NULL
	DROP TABLE	#deal_deatail_aaa			
IF OBJECT_ID(N'tempdb..#deals', N'U') IS NOT NULL
	DROP TABLE	#deals			
IF OBJECT_ID(N'tempdb..#filter_deal', N'U') IS NOT NULL
	DROP TABLE	#filter_deal			
IF OBJECT_ID(N'tempdb..#final_filter_deal', N'U') IS NOT NULL
	DROP TABLE	#final_filter_deal			
IF OBJECT_ID(N'tempdb..#map_table', N'U') IS NOT NULL
	DROP TABLE	#map_table			
IF OBJECT_ID(N'tempdb..#map_table_detail', N'U') IS NOT NULL
	DROP TABLE	#map_table_detail			
IF OBJECT_ID(N'tempdb..#ssbm', N'U') IS NOT NULL
	DROP TABLE	#ssbm			
IF OBJECT_ID(N'tempdb..#tmp_commodity', N'U') IS NOT NULL
	DROP TABLE	#tmp_commodity			
IF OBJECT_ID(N'tempdb..#tmp_deal_detail', N'U') IS NOT NULL
	DROP TABLE	#tmp_deal_detail			
IF OBJECT_ID(N'tempdb..#tmp_formula', N'U') IS NOT NULL
	DROP TABLE	#tmp_formula			
IF OBJECT_ID(N'tempdb..#udf_detail_template', N'U') IS NOT NULL
	DROP TABLE	#udf_detail_template			
IF OBJECT_ID(N'tempdb..#udf_detail_template_populate', N'U') IS NOT NULL
	DROP TABLE	#udf_detail_template_populate			
IF OBJECT_ID(N'tempdb..#udf_template', N'U') IS NOT NULL
	DROP TABLE	#udf_template			
IF OBJECT_ID(N'tempdb..#udf_template_populate', N'U') IS NOT NULL
	DROP TABLE	#udf_template_populate			
IF OBJECT_ID(N'tempdb..#udf_templateid_valueid_code', N'U') IS NOT NULL
	DROP TABLE	#udf_templateid_valueid_code			
--**************************TEST CODE END************************/				
 --*/  

SET NOCOUNT ON
DECLARE @Sql                       VARCHAR(MAX)  
DECLARE @sql_select                VARCHAR(MAX),
        @sql_select_sub            VARCHAR(MAX),
        @sql_select1               VARCHAR(MAX),
        @sql_select1_sub1          VARCHAR(MAX),
        @sql_select1_sub2          VARCHAR(MAX),
        @sql_select1_sub3          VARCHAR(MAX),
        @sql_select2               VARCHAR(MAX),
		@sql_select2_1             VARCHAR(MAX),
        @sql_select2_sub1          VARCHAR(MAX),
        @sql_select2_sub2          VARCHAR(MAX),
        @sql_select2_sub3          VARCHAR(MAX),
        @sql_select2_sub4          VARCHAR(MAX),
        @sql_select3               VARCHAR(MAX)
DECLARE @sql_where                 VARCHAR(MAX)  
DECLARE @sql_group                 VARCHAR(5000)  
DECLARE @group1                    VARCHAR(100),
        @group2                    VARCHAR(100),
        @group3                    VARCHAR(100),
        @group4                    VARCHAR(100),
        @source_deal_detail_audit  VARCHAR(100),
		@is_view                   BIT,
		@str_view_table		   VARCHAR(100)

DECLARE @timeparameter             INT  
  
--////////////////////////////Paging_Batch///////////////////////////////////////////  
EXEC spa_print '@batch_process_id:', @batch_process_id   
EXEC spa_print '@batch_report_param:', @batch_report_param  
  
DECLARE @str_batch_table VARCHAR(MAX),@str_get_row_number VARCHAR(100)  
DECLARE @temptablename VARCHAR(128),@user_login_id VARCHAR(50),@flag CHAR(1)  
DECLARE @is_batch                  BIT  
DECLARE @maturity_date             VARCHAR(50)  
DECLARE @sql_paging VARCHAR(8000)
SET @maturity_date = CAST(@compliance_year AS VARCHAR) + '-12-01'  
SET @str_batch_table = ''  
SET @str_get_row_number = ''  

SET @source_deal_detail_audit = 'source_deal_detail_audit' + CASE WHEN @prefix_table = 'main' THEN '' ELSE isnull(@prefix_table,'') END
DECLARE @sql_stmt VARCHAR(5000)  
  
IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
    SET @is_batch = 1
ELSE
    SET @is_batch = 0  

SET @user_action = NULLIF(@user_action, 'null')
SET @user_action = '''' + REPLACE(@user_action, ',', ''',''') + ''''

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NULL
	SET @is_view = 1
ELSE
	SET @is_view = 0


IF @is_view = 1 
BEGIN
	SET @user_login_id = dbo.FNADBUser()   
    SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 

    SET @str_view_table = ' INTO ' + @temptablename  
END
  
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
  
--////////////////////////////End_Batch///////////////////////////////////////////  
 
--########### Group Label  
  
  
IF @deal_id_from IS NOT NULL AND @deal_id_to IS NULL
    SET @deal_id_to = @deal_id_from
IF @deal_id_to IS NOT NULL AND @deal_id_from IS NULL
    SET @deal_id_from = @deal_id_to   
  
IF @deal_date_from IS NOT NULL AND @deal_date_to IS NULL
    SET @deal_date_to = @deal_date_from
IF @deal_date_from IS NULL AND @deal_date_to IS NOT NULL
    SET @deal_date_from = @deal_date_to

--When calling this sp from maintain transaction page the parameter @update_date_from and @update_date_to is set as NULL. 
--So to handel this NULL value the following condition is checked.
IF @report_option = 'c' AND @update_date_from IS NULL AND @update_date_to IS NULL 
BEGIN
	SET @update_date_to = GETDATE()
	SET @update_date_from = (
			SELECT MIN(update_ts)
			FROM source_deal_header_audit sdh
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) s ON sdh.source_deal_header_id = s.item
			)
END  
  
IF @update_date_from IS NOT NULL AND @update_date_to IS NULL
    SET @update_date_to = @update_date_from
IF @update_date_from IS NULL AND @update_date_to IS NOT NULL
    SET @update_date_from = @update_date_to

  
IF @tenor_from IS NOT NULL AND @tenor_to IS NULL
    SET @tenor_to = @tenor_from
IF @tenor_from IS NULL AND @tenor_to IS NOT NULL
    SET @tenor_from = @tenor_to  
  
  
IF @cert_no_from IS NOT NULL AND @cert_no_to IS NULL
    SET @cert_no_to = @cert_no_from
IF @cert_no_from IS NULL AND @cert_no_to IS NOT NULL
    SET @cert_no_from = @cert_no_to  

  
IF EXISTS( SELECT group1, group2, group3, group4 FROM source_book_mapping_clm)
BEGIN
  SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm  
END
ELSE
BEGIN
    SET @group1 = 'Book1'  
    SET @group2 = 'Book2'  
    SET @group3 = 'Book3'  
    SET @group4 = 'Book4'
END  
--######## End  
  
CREATE TABLE #ssbm(  
	source_system_book_id1  INT,
	source_system_book_id2  INT,
	source_system_book_id3  INT,
	source_system_book_id4  INT,
	book_deal_type_map_id   INT,
	fas_book_id             INT,
	stra_book_id            INT,
	sub_entity_id           INT
)  
 ----------------------------------  
 SET @sql=  
 'INSERT INTO #ssbm
 SELECT ssbm.source_system_book_id1,
        ssbm.source_system_book_id2,
        ssbm.source_system_book_id3,
        ssbm.source_system_book_id4,
        ssbm.book_deal_type_map_id,
        book.entity_id fas_book_id,
        book.parent_entity_id stra_book_id,
        stra.parent_entity_id sub_entity_id
 FROM   source_system_book_map ssbm
 INNER JOIN portfolio_hierarchy book(NOLOCK) ON  ssbm.fas_book_id = book.entity_id
 INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.entity_id
 WHERE  1 = 1 '  
 +CASE WHEN @sub_id IS NOT NULL THEN ' AND stra.parent_entity_id IN('+@sub_id+')' ELSE '' END  
 +CASE WHEN @stra_id IS NOT NULL THEN ' AND stra.entity_id IN('+@stra_id+')' ELSE '' END  
 +CASE WHEN @book_id IS NOT NULL THEN ' AND book.entity_id IN('+@book_id+')' ELSE '' END  
 +CASE 
	WHEN @book_deal_type_map_id IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN(' + @book_deal_type_map_id + ')' 
	ELSE '' 
  END  
  
--PRINT @sql  
EXEC(@sql)  
  
-- max(dbo.FNADateFormat(sdha.entire_term_start)) [Entire Term Start],  
-- max(dbo.FNADateFormat(sdha.entire_term_end)) [Entire Term End],  
-- max(sdha.header_buy_sell_flag) [Deal Buy Sell Flag],  
  
DECLARE @date_style INT, @ds VARCHAR(5)     
    
SELECT @date_style = CASE region_id
                          WHEN 1 THEN 101
                          WHEN 3 THEN 110
                          WHEN 2 THEN 103
                          WHEN 5 THEN 104
                          WHEN 4 THEN 105
                          ELSE 120
                     END
FROM   application_users
WHERE  user_login_id = dbo.FNADBUser()   
   
SET @ds = CAST(@date_style AS VARCHAR(5))   

--START OF UDF DATA POPULATE 
--edited by Monish Manandhar
-- populating udf used in header of selected deals and filter applied into temp table
	
IF OBJECT_ID('tempdb..#udf_template_populate') is NOT NULL
DROP table #udf_template_populate
CREATE TABLE #udf_template_populate(udf_template_populate VARCHAR(100) COLLATE DATABASE_DEFAULT  )	
	
	
SET @sql = 'INSERT INTO #udf_template_populate 
select uddft.field_label  
FROM user_defined_deal_fields_audit uddfa 
INNER JOIN user_defined_deal_fields_template uddft ON uddfa.udf_template_id = uddft.udf_template_id 
INNER JOIN source_deal_header_audit sdha ON sdha.audit_id = uddfa.header_audit_id
WHERE	1=1
AND EXISTS (
	SELECT 1
	FROM source_deal_detail_audit sdda 
	WHERE sdda.header_audit_id = sdha.audit_id
	AND sdha.source_deal_header_id = sdda.source_deal_header_id'
	+CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
	+CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
		'sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '' END +
')
AND EXISTS (
	SELECT 1 FROM source_deal_header_audit sdha1
	INNER JOIN #ssbm ssbm1 
		ON sdha1.source_system_book_id1 = ssbm1.source_system_book_id1
		AND sdha1.source_system_book_id2 = ssbm1.source_system_book_id2
		AND sdha1.source_system_book_id3 = ssbm1.source_system_book_id3
		AND sdha1.source_system_book_id4 = ssbm1.source_system_book_id4
	LEFT JOIN source_deal_header_audit sdh1
		ON sdh1.source_deal_header_id = sdha1.source_deal_header_id 
		AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
		AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
		AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
		AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
	WHERE sdha1.source_deal_header_id = sdha.source_deal_header_id
	AND isnull(sdh1.source_deal_header_id,-1) = 
			CASE WHEN sdha1.user_action = ''delete'' THEN -1  
			ELSE sdh1.source_deal_header_id END
) 
AND(sdha.update_ts BETWEEN ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_from) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59') AS VARCHAR)+''')'
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdha.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
ELSE   
	+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN (' + @source_deal_header_id + ')'  ELSE '' END  
	+CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdha.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
	  
	+CASE WHEN @update_by IS NOT NULL THEN ' AND sdha.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
	+CASE WHEN NULLIF(@trader_id,'') IS NOT NULL THEN ' AND (sdha.trader_id IN (' + @trader_id  + ')) ' ELSE '' END  
	+CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN ' AND (sdha.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdha.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdha.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdha.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdha.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END
	+CASE WHEN @user_action <> 'all' THEN ' AND sdha.user_action IN (' + @user_action+')' ELSE '' END  
	+CASE WHEN @generator_id IS NOT NULL THEN ' AND sdha.generator_id=' + CAST(@generator_id AS VARCHAR) ELSE '' END  
	+CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdha.compliance_year=' + CAST(@compliance_year AS VARCHAR) ELSE '' END     
	+CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdha.assignment_type_value_id=' + CAST(@assignment_type AS VARCHAR) ELSE '' END  
	+CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdha.state_value_id=' + CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
	+CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdha.assigned_date=''' + CAST(@assigned_date AS VARCHAR) + '''' ELSE '' END  
	+CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdha.assigned_by=''' + CAST(@assigned_by AS VARCHAR) + '''' ELSE '' END  
	+CASE WHEN @status  IS NOT NULL THEN ' AND sdha.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END 
END    
+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN ('+@source_deal_header_id+')'  ELSE '' END  
+CASE WHEN @update_timestamp IS NOT NULL AND @report_option='d' THEN ' AND dbo.FNAConvertTZAwareDateFormat(sdha.update_ts, 4) ='''+ @update_timestamp +'''' ELSE '' END  
	
SET @sql = @sql + ' GROUP BY uddft.field_label' 
 
--PRINT @sql
EXEC(@sql)


-- populating udf used in detail of selected deals and filter applied into temp table
	
IF OBJECT_ID('tempdb..#udf_detail_template_populate') is NOT NULL
DROP table #udf_detail_template_populate
CREATE TABLE #udf_detail_template_populate(udf_detail_template_populate VARCHAR(100) COLLATE DATABASE_DEFAULT  )	
	
	
SET @sql = 'INSERT INTO #udf_detail_template_populate 
select uddft.field_label  
FROM user_defined_deal_detail_fields_audit uddfa 
INNER JOIN user_defined_deal_fields_template uddft ON uddfa.udf_template_id = uddft.udf_template_id 
INNER JOIN source_deal_detail_audit sdda ON sdda.audit_id = uddfa.header_audit_id
INNER JOIN source_deal_header_audit sdha ON sdha.audit_id = sdda.header_audit_id
AND sdha.source_deal_header_id = sdda.source_deal_header_id
WHERE 1=1
AND EXISTS (
	SELECT * FROM source_deal_header_audit sdha1
	INNER JOIN #ssbm ssbm1 
		ON sdha1.source_system_book_id1 = ssbm1.source_system_book_id1
		AND sdha1.source_system_book_id2 = ssbm1.source_system_book_id2
		AND sdha1.source_system_book_id3 = ssbm1.source_system_book_id3
		AND sdha1.source_system_book_id4 = ssbm1.source_system_book_id4
	LEFT JOIN source_deal_header_audit sdh1 
		ON sdh1.source_deal_header_id = sdha1.source_deal_header_id 
		AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
		AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
		AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
		AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
	WHERE sdha1.source_deal_header_id = sdha.source_deal_header_id
	AND isnull(sdh1.source_deal_header_id,-1) = 
			CASE WHEN sdha1.user_action = ''delete'' THEN -1  
			ELSE sdh1.source_deal_header_id END
) 
AND(sdha.update_ts BETWEEN ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_from) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59') AS VARCHAR)+''')'
+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdha.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
ELSE   
	+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN (' + @source_deal_header_id + ')'  ELSE '' END  
	+CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdha.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
	+CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
	+CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
		'sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '' END  
	+CASE WHEN @update_by IS NOT NULL THEN ' AND sdha.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
	+CASE WHEN NULLIF(@trader_id,'') IS NOT NULL THEN ' AND (sdha.trader_id IN (' + @trader_id + ')) ' ELSE '' END  
	+CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN ' AND (sdha.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdha.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdha.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdha.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
	+CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdha.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END
	+CASE WHEN @user_action <> 'all' THEN ' AND sdha.user_action IN ('+@user_action+')' ELSE '' END  
	+CASE WHEN @generator_id IS NOT NULL THEN ' AND sdha.generator_id='+CAST(@generator_id AS VARCHAR) ELSE '' END  
	+CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdha.compliance_year='+CAST(@compliance_year AS VARCHAR) ELSE '' END     
	+CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdha.assignment_type_value_id='+CAST(@assignment_type AS VARCHAR) ELSE '' END  
	+CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdha.state_value_id='+CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
	+CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdha.assigned_date='''+CAST(@assigned_date AS VARCHAR)+'''' ELSE '' END  
	+CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdha.assigned_by='''+CAST(@assigned_by AS VARCHAR)+'''' ELSE '' END  
	+CASE WHEN @status  IS NOT NULL THEN ' AND sdha.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END 
END    
+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN (' + @source_deal_header_id + ')'  ELSE '' END  
+CASE WHEN @update_timestamp IS NOT NULL AND @report_option='d' THEN ' AND dbo.FNAConvertTZAwareDateFormat(sdha.update_ts, 4) =''' + @update_timestamp + '''' ELSE '' END  
	
SET @sql = @sql + ' GROUP BY uddft.field_label' 
--PRINT @sql
EXEC(@sql)
	
	-- creating list of udfs of header and detail in comma separated form
		
	DECLARE @udf_template_with_tablename VARCHAR(MAX), @udf_template varchar(MAX),@udf_template2 VARCHAR(MAX), @udf_detail_template_with_tablename VARCHAR(MAX), @udf_detail_template varchar(MAX), @udf_detail_template2 varchar(MAX)

	SELECT @udf_template_with_tablename = STUFF((
					(SELECT ' , max(udf_table.[' + CAST(udf_template_populate AS VARCHAR(max)) + ']) AS [' + udf_template_populate + ']' from #udf_template_populate FOR XML PATH(''), root('MyString'), type 
		 ).value('/MyString[1]','varchar(max)')
				), 1, 3, '')
	
	SELECT @udf_template = STUFF((
					(SELECT ' ],[' + CAST(udf_template_populate AS VARCHAR(max)) from #udf_template_populate FOR XML PATH(''), root('MyString'), type 
		 ).value('/MyString[1]','varchar(max)')
				), 1, 4, '')
				
	SELECT @udf_detail_template_with_tablename = STUFF((
					(SELECT ' , udf_detail_table.[' + CAST(udf_detail_template_populate AS VARCHAR(max)) + '] AS [' + udf_detail_template_populate + ']'  from #udf_detail_template_populate FOR XML PATH(''), root('MyString'), type 
		 ).value('/MyString[1]','varchar(max)')
				), 1, 3, '')
	
	SELECT @udf_detail_template = STUFF((
					(SELECT ' ],[' + CAST(udf_detail_template_populate AS VARCHAR(max)) from #udf_detail_template_populate FOR XML PATH(''), root('MyString'), type 
		 ).value('/MyString[1]','varchar(max)')
				), 1, 4, '')
				
	
	-- populating sql_string of header udf's having dropdown into temp table
	
	CREATE TABLE #udf_template(udf_template_id INT, sql_string VARCHAR(1000) COLLATE DATABASE_DEFAULT )
	
	set @sql ='INSERT INTO #udf_template(udf_template_id, sql_string) 
	SELECT uddft.udf_template_id, max(ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string)) sql_string FROM user_defined_deal_fields_audit uddfa 
	INNER JOIN user_defined_deal_fields_template uddft ON uddfa.udf_template_id = uddft.udf_template_id 
	INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
	INNER JOIN source_deal_header_audit sdha ON sdha.audit_id = uddfa.header_audit_id
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
	WHERE 1 = 1 AND NULLIF(ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string), '''') IS NOT NULL
	AND EXISTS (
		SELECT 1
		FROM source_deal_detail_audit sdda 
		WHERE sdha.audit_id = sdda.header_audit_id
			AND sdha.source_deal_header_id = sdda.source_deal_header_id'
		+CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
		+CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
		   'sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '' END + 
	')
	AND EXISTS (
		SELECT 1 FROM source_deal_header_audit sdha1
		INNER JOIN #ssbm ssbm1 
			ON sdha1.source_system_book_id1 = ssbm1.source_system_book_id1
			AND sdha1.source_system_book_id2 = ssbm1.source_system_book_id2
			AND sdha1.source_system_book_id3 = ssbm1.source_system_book_id3
			AND sdha1.source_system_book_id4 = ssbm1.source_system_book_id4
		LEFT JOIN source_deal_header_audit sdh1 
			ON sdh1.source_deal_header_id = sdha1.source_deal_header_id 
			AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
			AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
			AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
			AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
		WHERE sdha1.source_deal_header_id = sdha.source_deal_header_id
		AND isnull(sdh1.source_deal_header_id,-1) = 
				CASE WHEN sdha1.user_action = ''delete'' THEN -1  
				ELSE sdh1.source_deal_header_id END
	) 
	AND(sdha.update_ts BETWEEN ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_from) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59') AS VARCHAR)+''')'
	+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdha.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
	ELSE   
		+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN (' + @source_deal_header_id + ')'  ELSE '' END  
		+CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdha.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
		+CASE WHEN @update_by IS NOT NULL THEN ' AND sdha.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
		+CASE WHEN NULLIF(@trader_id,'') IS NOT NULL THEN ' AND (sdha.trader_id IN (' + @trader_id + ')) ' ELSE '' END  
		+CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN ' AND (sdha.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdha.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdha.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdha.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdha.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END
		+CASE WHEN @user_action <> 'all' THEN ' AND sdha.user_action IN (' + @user_action+')' ELSE '' END  
		+CASE WHEN @generator_id IS NOT NULL THEN ' AND sdha.generator_id=' + CAST(@generator_id AS VARCHAR) ELSE '' END  
		+CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdha.compliance_year=' + CAST(@compliance_year AS VARCHAR) ELSE '' END     
		+CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdha.assignment_type_value_id=' + CAST(@assignment_type AS VARCHAR) ELSE '' END  
		+CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdha.state_value_id=' + CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
		+CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdha.assigned_date=''' + CAST(@assigned_date AS VARCHAR) + '''' ELSE '' END  
		+CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdha.assigned_by=''' + CAST(@assigned_by AS VARCHAR) + '''' ELSE '' END  
		+CASE WHEN @status  IS NOT NULL THEN ' AND sdha.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END 
	END    
	+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN ('+@source_deal_header_id+')'  ELSE '' END  
	+CASE WHEN @update_timestamp IS NOT NULL AND @report_option='d' THEN ' AND dbo.FNAConvertTZAwareDateFormat(sdha.update_ts, 4) ='''+ @update_timestamp +'''' ELSE '' END  
	
	SET @sql = @sql + ' GROUP BY uddft.udf_template_id' 
 
	--PRINT @sql
	EXEC(@sql)
--select * from #udf_template
	-- populating sql_string of detail udf's having dropdown into temp table
	
	CREATE TABLE #udf_detail_template(udf_template_id INT, sql_string VARCHAR(1000) COLLATE DATABASE_DEFAULT  )
	
	
	SET @sql = 'INSERT INTO #udf_detail_template(udf_template_id, sql_string) 
	SELECT uddft.udf_template_id, max(ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string)) sql_string
	FROM user_defined_deal_detail_fields_audit uddfa 
	INNER JOIN user_defined_deal_fields_template uddft ON uddfa.udf_template_id = uddft.udf_template_id 
	INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
	INNER JOIN source_deal_detail_audit sdda ON sdda.audit_id = uddfa.header_audit_id
	INNER JOIN source_deal_header_audit sdha ON sdha.audit_id = sdda.header_audit_id
	AND sdha.source_deal_header_id = sdda.source_deal_header_id
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
	WHERE	1=1 AND NULLIF(uddft.sql_string, '''') IS NOT NULL
	AND EXISTS (
		SELECT * FROM source_deal_header_audit sdha1
		INNER JOIN #ssbm ssbm1 
			ON sdha1.source_system_book_id1 = ssbm1.source_system_book_id1
			AND sdha1.source_system_book_id2 = ssbm1.source_system_book_id2
			AND sdha1.source_system_book_id3 = ssbm1.source_system_book_id3
			AND sdha1.source_system_book_id4 = ssbm1.source_system_book_id4
		LEFT JOIN source_deal_header_audit sdh1 
			ON sdh1.source_deal_header_id = sdha1.source_deal_header_id 
			AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
			AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
			AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
			AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
		WHERE sdha1.source_deal_header_id = sdha.source_deal_header_id
		AND isnull(sdh1.source_deal_header_id,-1) = 
				CASE WHEN sdha1.user_action = ''delete'' THEN -1  
				ELSE sdh1.source_deal_header_id END
	) 
	AND(sdha.update_ts BETWEEN ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_from) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59') AS VARCHAR)+''')'
	+ CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdha.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
	ELSE   
		+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN (' + @source_deal_header_id + ')'  ELSE '' END  
		+CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdha.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
		+CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
		+CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
		   'sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '' END  
		+CASE WHEN @update_by IS NOT NULL THEN ' AND sdha.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
		+CASE WHEN NULLIF(@trader_id,'') IS NOT NULL THEN ' AND (sdha.trader_id IN (' + @trader_id + ')) ' ELSE '' END  
		+CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN ' AND (sdha.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdha.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdha.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdha.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
		+CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdha.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END
		+CASE WHEN @user_action <> 'all' THEN ' AND sdha.user_action IN ('+@user_action+')' ELSE '' END  
		+CASE WHEN @generator_id IS NOT NULL THEN ' AND sdha.generator_id='+CAST(@generator_id AS VARCHAR) ELSE '' END  
		+CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdha.compliance_year='+CAST(@compliance_year AS VARCHAR) ELSE '' END     
		+CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdha.assignment_type_value_id='+CAST(@assignment_type AS VARCHAR) ELSE '' END  
		+CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdha.state_value_id='+CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
		+CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdha.assigned_date='''+CAST(@assigned_date AS VARCHAR)+'''' ELSE '' END  
		+CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdha.assigned_by='''+CAST(@assigned_by AS VARCHAR)+'''' ELSE '' END  
		+CASE WHEN @status  IS NOT NULL THEN ' AND sdha.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END 
	END    
	+CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN (' + @source_deal_header_id + ')'  ELSE '' END  
	+CASE WHEN @update_timestamp IS NOT NULL AND @report_option='d' THEN ' AND dbo.FNAConvertTZAwareDateFormat(sdha.update_ts, 4) =''' + @update_timestamp + '''' ELSE '' END  
	
	SET @sql = @sql + ' GROUP BY  uddft.udf_template_id' 
	--PRINT @sql
	EXEC(@sql)
	
	CREATE TABLE #map_table(id VARCHAR(500) COLLATE DATABASE_DEFAULT  , [value] VARCHAR(500) COLLATE DATABASE_DEFAULT  , udf_template_id INT, state VARCHAR(156) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #map_table_detail(id VARCHAR(500) COLLATE DATABASE_DEFAULT  , [value] VARCHAR(500) COLLATE DATABASE_DEFAULT  , udf_template_id INT, state VARCHAR(156) COLLATE DATABASE_DEFAULT )
	
	--Running cursor to populate temp table after executing the sql string for dropdown
	
	DECLARE @temp_udf_template_id INT , @sql_string VARCHAR(500)  
	--cursor for header udf fields mapping table
	BEGIN TRY 
	
	

	DECLARE cur_status CURSOR LOCAL FOR
	SELECT udf_template_id , sql_string FROM #udf_template
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @temp_udf_template_id, @sql_string
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		BEGIN TRY	
			INSERT INTO #map_table(id, VALUE) exec spa_execute_query @sql_string
		END TRY
		BEGIN CATCH
			INSERT INTO #map_table(id, VALUE, state) exec spa_execute_query @sql_string
		END CATCH
		
		UPDATE #map_table SET udf_template_id = @temp_udf_template_id WHERE udf_template_id IS NULL 
		
		FETCH NEXT FROM cur_status INTO @temp_udf_template_id, @sql_string
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	
	
	END TRY
	BEGIN CATCH
		EXEC spa_print 'error: ' --+ ERROR_MESSAGE()
	END CATCH 
	
	--cursor for udf detail fields mapping table
	BEGIN TRY 
	
	DECLARE cur_status CURSOR LOCAL FOR
	SELECT udf_template_id , sql_string FROM #udf_detail_template
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @temp_udf_template_id, @sql_string
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		BEGIN TRY	
			INSERT INTO #map_table_detail(id, VALUE) exec spa_execute_query @sql_string
		END TRY
		BEGIN CATCH
			INSERT INTO #map_table_detail(id, VALUE, state) exec spa_execute_query @sql_string
		END CATCH

		UPDATE #map_table_detail SET udf_template_id = @temp_udf_template_id WHERE udf_template_id IS NULL 
		
		FETCH NEXT FROM cur_status INTO @temp_udf_template_id, @sql_string
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	
	
	END TRY
	BEGIN CATCH
		EXEC spa_print 'error: ' --+ ERROR_MESSAGE()
	END CATCH 
--END OF UDF DATA POPULATE 

IF @report_option = 's' OR @report_option = 'd'  
BEGIN
	IF @deal_id_from IS NOT NULL
	BEGIN
		SET @source_deal_header_id = NULL
		SET @deal_date_from = NULL
		SET @tenor_from = NULL
		SET @update_date_from = '1900-1-1'
		SET @update_date_to = '9999-1-1'
		SET @update_by = NULL
		SET @trader_id = NULL
		SET @counterparty_id = NULL
		SET @source_system_book_id1 = NULL
		SET @source_system_book_id2 = NULL
		SET @source_system_book_id3 = NULL
		SET @source_system_book_id4 = NULL
		SET @book_deal_type_map_id = NULL
		SET @deal_status = NULL
		--SET @user_action = NULL
		SET @generator_id = NULL
		SET @compliance_year = NULL
		SET @cert_entity = NULL
		SET @cert_date = NULL
		SET @assignment_type = NULL
		SET @assigned_jurisdiction = NULL
		SET @assigned_date = NULL
		SET @assigned_by = NULL
		SET @status  = NULL
		SET @status_date = NULL
		SET @cert_no_from  = NULL
		SET @drill_deal_id = NULL
		SET @source_deal_header_id = NULL
		SET @update_timestamp = NULL
		
	END

	IF @report_option = 's'
	BEGIN
		SET @sql_select = '
							SELECT 
								sdha.user_action [User Action],
								dbo.FNADateTimeFormat(sdha.update_ts,1) [Deal Update Timestamp],
								sdha.update_user [Deal Update User],
								--CASE 
								--	WHEN sdh.source_deal_header_id IS NOT NULL 
								--	THEN dbo.FNAHyperLinkText(10131010, CAST(sdha.source_deal_header_id AS VARCHAR), sdha.source_deal_header_id) 
								--	ELSE dbo.FNAHyperLinkText(10131010, CAST(sdha.source_deal_header_id AS VARCHAR), '''''''' + CAST(sdha.source_deal_header_id AS VARCHAR) + ''&deleted_deal=y'' + '''''''') 
								--END 
								sdha.source_deal_header_id AS [Source Deal Header ID],
								--MAX(ISNULL(sdha.deal_id, sdha.source_deal_header_id)) [Deal ID],
								CASE WHEN sdh.source_deal_header_id IS NOT NULL THEN MAX(dbo.FNATRMWinHyperlink(''a'', 10131010, ISNULL(sdha.deal_id, sdha.source_deal_header_id), ABS(sdha.source_deal_header_id), NULL,null,null,null,null,null,null,null,null,null,null,0)) ELSE MAX(ISNULL(sdha.deal_id, sdha.source_deal_header_id)) END [Deal ID],
								MAX(CONVERT(VARCHAR(10), sdha.deal_date,'+ISNULL(@ds,105)+')) [Deal Date],
								CASE 
									WHEN MAX(sdha.physical_financial_flag) = ''p'' THEN ''Physical''
									ELSE ''Financial''
								END AS [Physical / Financial],
								MAX(grnl.code) [Granularity],
								MAX(deal_cat.code) [Deal Category],
								MAX(sb1.source_book_name) ['+@group1+'],  
								MIN(CONVERT(VARCHAR(10), sdha.entire_term_start, ' + ISNULL(@ds,105) + ')) [Entire Term Start],  
								MAX(CONVERT(VARCHAR(10), sdha.entire_term_end, ' + ISNULL(@ds,105) + ')) [Entire Term End],  
								MAX(sc2.counterparty_name) [Broker],  
								CASE sdha.header_buy_sell_flag WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' END [Buy Sell Flag],  
								MAX(commodity_name) [Commodity],  
								MAX(contract_name) [Contract],  
								sc.counterparty_name [Counterparty],  
								MAX(trader_name) [Trader Name],  
								MAX(CAST(sdha.comments AS VARCHAR(8000))) [Comments]   
								,sdv_ds.code [Deal Status]  
								,sdv_cs.code [Confirm Type]      
								,CASE sdha.option_flag WHEN ''y'' THEN ''Yes'' WHEN ''n'' THEN ''No'' END [Option Flag]       
								,CASE sdha.option_type WHEN ''c'' THEN ''CALL'' WHEN ''p'' THEN ''Put'' END [Option TYPE]  
								,CASE sdha.option_excercise_type WHEN ''e'' THEN ''European'' WHEN ''a'' THEN ''American'' END [Option Exercise Type]  
								,sdha.option_settlement_date [Option Settlement Date] 
								' + case when isnull(@udf_template_with_tablename,'-1') = '-1' THEN '' ELSE ', ' + @udf_template_with_tablename  END + '								 
								' + @str_batch_table     
	END
	ELSE IF @report_option = 'd'
	BEGIN
		SET @sql_select = '
							SELECT
								sdha.user_action [User Action],
								dbo.FNADateTimeFormat(sdha.update_ts,1) [Deal Update Timestamp],
								sdha.update_user [Deal Update User],  
								--CASE WHEN sdh.source_deal_header_id IS NOT NULL THEN dbo.FNAHyperLinkText(10131010,cast(sdha.source_deal_header_id as VARCHAR),sdha.source_deal_header_id) ELSE dbo.FNAHyperLinkText(10131010,cast(sdha.source_deal_header_id as VARCHAR),'''''''' + cast(sdha.source_deal_header_id as varchar) + ''&deleted_deal=y''+'''''''') END AS [Source Deal Header ID],  
								sdha.source_deal_header_id AS [Source Deal Header ID],
								--sdha.deal_id [Deal ID], 
								CASE WHEN sdh.source_deal_header_id IS NOT NULL THEN  dbo.FNATRMWinHyperlink(''a'', 10131010, sdha.deal_id, ABS(sdha.source_deal_header_id),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0) ELSE sdha.deal_id END [Deal ID],  
								CONVERT(VARCHAR(10),sdha.deal_date,'+ISNULL(@ds,105)+') [Deal Date],  
								CONVERT(VARCHAR(10),sdha.entire_term_start,'+ISNULL(@ds,105)+') [Entire Term Start],  
								CONVERT(VARCHAR(10),sdha.entire_term_end,'+ISNULL(@ds,105)+') [Entire Term End],  
								sb1.source_book_name ['+@group1+'],  
								sb2.source_book_name ['+@group2+'],  
								sb3.source_book_name ['+@group3+'],  
								sb4.source_book_name ['+@group4+'],  
								sdda.source_deal_detail_id [Source Deal Detail ID],  
								Leg [Leg],  
								CONVERT(VARCHAR(10),sdda.term_start,'+ISNULL(@ds,105)+') [Term Start],  
								CONVERT(VARCHAR(10),sdda.term_end,'+ISNULL(@ds,105)+') [Term End],  
								sdha.aggregate_environment [Aggregate Environment],  
								sdha.assigned_by [Assigned By],  
								CONVERT(VARCHAR(10),sdha.assigned_date,'+ISNULL(@ds,105)+') [Assigned Date],  
								sdha.assignment_type_value_id [Assignment Type],  
								sdv.Code [Block Definition],  
								block_description [Block Description],  
								--sdv1.Code [Block Type],  
								Booked [Booked],  
								sc2.counterparty_name [Broker],  
								case sdha.header_buy_sell_flag when ''b'' then ''Buy'' when ''s'' then ''Sell'' end [Deal Buy Sell Flag],  
								sdha.close_reference_id [Close Reference ID],  
								commodity_name [Commodity],  
								sdha.compliance_year [Compliance Year],  
								CONVERT(VARCHAR(10),sdda.contract_expiration_date,'+ISNULL(@ds,105)+') [Contract Expiration Date],  
								contract_name [Contract],  
								sc.counterparty_name [Counterparty],  
								case sdha.physical_financial_flag when ''p'' then ''physical'' when ''f'' then ''financial'' else '''' end [Physical Financial Flag],
								deal_cat.code [Deal Category],
								fsc.currency_name [Currency],  
								spcdsu.curve_name [Curve],  
								deal_detail_description [Deal Detail Description],  
								fe.formula [Formula],  
								--sdha.deal_locked [Deal Locked],  								
								CASE WHEN ISNULL(sdha.deal_locked, ''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END [Deal Locked],								
								sdt_sub.source_deal_type_name [Deal Sub Type],  
								--deal_volume [Deal Volume],
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), deal_volume), ''n'') [Deal Volume],  
								case deal_volume_frequency when ''m'' then ''Monthly'' when ''d'' then ''Daily'' when ''h'' then ''hourly''  
								when ''q'' then ''Quarterly'' when ''s'' then ''Semi-Annually'' when ''w'' then ''Weekly'' when ''a'' then ''Annually''  when ''t'' then ''Term''  else '''' end[Deal Volume Frequency],  
								deal_vol_uom.uom_name [Deal Volume UOM],  
								sdha.description1 [Description1],  
								sdha.description2 [Description2],  
								sdha.description3 [Description3],  
								case sdda.physical_financial_flag when ''p'' then ''physical'' when ''f'' then ''financial'' else '''' end [Deal Detail Physical Financial Flag],  
								sdha.ext_deal_id [External Deal ID],  
								case fixed_float_leg when ''f'' then ''fixed'' when ''t'' then ''float'' else '''' end[Fixed Float Leg],  
								--fixed_price [Fixed Price],
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), fixed_price), ''n'') [Fixed Price],
								sdha.generation_source [Generation Source],  
								rg.name [Generator],  
								grnl.Code [Granularity],  
								case sdda.buy_sell_flag when ''b'' then ''Buy'' when ''s'' then ''Sell'' end [Deal Detail Buy Sell Flag],  
								profile.code [Profile],  
								sdha.internal_portfolio_id [Internal Portfolio ID],  
								legal_entity_name [Legal Entity Name],  
								Location_Name [Location Name],  
								mi.recorderid [Meter],    
								case sdha.option_flag when ''y'' then ''Yes'' when ''n'' then ''No'' end [Option Flag],       
								case sdha.option_type when ''c'' then ''Call'' when ''p'' then ''Put'' end [Option Type],  
								case sdha.option_excercise_type when ''e'' then ''European'' when ''a'' then ''American'' end [Option Exercise Type],  
								sdha.option_settlement_date [Option Settlement Date],  
								--option_strike_price [Option Strike Price],  
								--price_adder [Price Adder],  
								--price_multiplier [Price Multiplier],  
								dbo.FNARemoveTrailingZeroes(CONVERT(NUMERIC(38, 12), option_strike_price)) [Option Strike Price],
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), price_adder), ''n'') [Price Adder],  
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), price_multiplier), ''n'') [Price Multiplier],
								pricing.code [Pricing],
								sp.code [Fixation],  
								sdha.reference [Reference],  
								CASE sdha.rolling_avg WHEN ''s'' THEN ''Semi-Annually'' WHEN ''a'' THEN ''Annually'' WHEN ''q'' THEN ''Quaterly'' END [Rolling Average],  
								CONVERT(VARCHAR(10),sdda.settlement_date,'+ISNULL(@ds,105)+') [Settlement Date],  
								--settlement_uom [Settlement UOM], 
								sui.uom_id [Settlement UOM],
								--settlement_volume [Settlement Volume],  
								dbo.FNARemoveTrailingZeroes(CONVERT(NUMERIC(38, 12), settlement_volume)) [Settlement Volume],  
								sdt.source_deal_type_name [Source Deal Type],  
								sc.state [State],  
								CONVERT(VARCHAR(10),sdha.status_date,'+ISNULL(@ds,105)+') [Status Date],  
								sdha.structured_deal_id [Structured Deal ID],  
								template_name [Template Name],  
								trader_name [Trader Name],  
								--volume_left [Volume Left],
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), volume_left), ''n'') [Volume Left],    
								sdha.aggregate_envrionment_comment [Aggregate Environment Comment],  
								--fixed_cost [Fixed Cost],
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), fixed_cost), ''n'') [Fixed Cost],  
								--multiplier [Volume Multiplier],  
								dbo.FNANumberFormat(CONVERT(NUMERIC(38, 12), multiplier), ''n'') [Volume Multiplier],
								price_adder_currency1.currency_name [Price Adder Currency],  
								fixed_cost_currency.currency_id [Fixed Cost Currency],  
								formula_currency.currency_name [Formula Currency],  
								--price_adder2 [Price Adder 2],
								dbo.FNARemoveTrailingZeroes(CONVERT(NUMERIC(38, 12), price_adder2)) [Price Adder 2],  
								price_adder_currency2.currency_name [Price Adder Currency 2],  
								--volume_multiplier2 [Volume Multiplier 2],
								dbo.FNARemoveTrailingZeroes(CONVERT(NUMERIC(38, 12), volume_multiplier2)) [Volume Multiplier 2],  
								--total_volume [Total Monthly Volume],  
								pay_opposite [Pay Opposite],  
								--capacity [Capacity],
								dbo.FNARemoveTrailingZeroes(CONVERT(NUMERIC(38, 12), sdda.capacity)) [Capacity],  
								sdv_ds.code [Deal Status],  
								sdv_cs.code [Confirm Type] ,
								fsc2.currency_name [Settlement Currency],
								--standard_yearly_volume [Standard Yearly Volume]
								dbo.FNARemoveTrailingZeroes(CONVERT(NUMERIC(38, 12), standard_yearly_volume)) [Standard Yearly Volume]
								,su.uom_name [Price UOM], sdv4.code [Category], sdv3.code [Profile Code], sdv2.code [PR Party]
								' + case when isnull(@udf_detail_template_with_tablename,'-1') = '-1' THEN '' ELSE ',' + @udf_detail_template_with_tablename   END + '
								' + @str_batch_table    
	END
	
	SET @Sql = '
								FROM source_deal_header_audit sdha
									INNER JOIN ' + ISNULL(@source_deal_detail_audit,'source_deal_detail_audit') + ' sdda 
										ON sdha.audit_id = sdda.header_audit_id
										-- AND sdda.user_action=sdha.user_action   
										AND sdha.source_deal_header_id = sdda.source_deal_header_id

									 LEFT JOIN source_price_curve_def spcdsu ON spcdsu.source_curve_def_id = sdda.curve_id    
									 LEFT JOIN source_uom sui ON spcdsu.display_uom_id = sui.source_uom_id 
									 
									'+ CASE WHEN ISNULL(@udf_template,'-1') = '-1' THEN '' ELSE ' 
									LEFT JOIN 
									(
										SELECT  [' + @udf_template + '], header_audit_id, source_deal_header_id
										FROM
											( 
												SELECT uddfa.source_deal_header_id,uddfa.header_audit_id, uddft.field_label, ISNULL(max(mt.value), max(uddfa.udf_value)) udf_value
												FROM user_defined_deal_fields_audit uddfa 
												inner join user_defined_deal_fields_template uddft on uddft.udf_template_id = uddfa.udf_template_id
												left join #map_table mt ON mt.udf_template_id = uddfa.udf_template_id
													and mt.id = uddfa.udf_value 
												GROUP BY uddfa.source_deal_header_id,uddfa.header_audit_id, uddft.field_label
											) AS sourceTable
										PIVOT
											(
												max(udf_value) FOR field_label IN( [' + @udf_template + '])
											) AS pivotTable
									) udf_table ON sdha.audit_id = udf_table.header_audit_id
									AND udf_table.source_deal_header_id = sdha.source_deal_header_id
									
									' END + '

									'+ CASE WHEN ISNULL(@udf_detail_template,'-1') = '-1' THEN '' ELSE ' 
									LEFT JOIN 
									(
										SELECT [' + @udf_detail_template + '], header_audit_id, source_deal_detail_id
										FROM
											( 
												SELECT udddfa.header_audit_id, uddft.field_label, isnull(mtd.value, udddfa.udf_value) udf_value, udddfa.source_deal_detail_id 
												FROM user_defined_deal_detail_fields_audit udddfa 
												INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddfa.udf_template_id
												LEFT JOIN #map_table_detail mtd ON mtd.udf_template_id = udddfa.udf_template_id
												AND mtd.id = udddfa.udf_value  
											) AS sourceTable1
										PIVOT
											(
												max(udf_value) FOR field_label IN( [' + @udf_detail_template + '])
											) AS pivotTable1
									) udf_detail_table ON sdda.audit_id = udf_detail_table.header_audit_id
									and sdda.source_deal_detail_id = udf_detail_table.source_deal_detail_id
									
									' END + '

									--INNER JOIN source_uom sui 
									--ON sdda.settlement_uom= sui.source_uom_id

									INNER JOIN source_system_book_map sbmp 
										ON sdha.source_system_book_id1 = sbmp.source_system_book_id1
										AND sdha.source_system_book_id2 = sbmp.source_system_book_id2
										AND sdha.source_system_book_id3 = sbmp.source_system_book_id3
										AND sdha.source_system_book_id4 = sbmp.source_system_book_id4
									LEFT JOIN source_book sb1 ON sb1.source_book_id = sdha.source_system_book_id1
									LEFT JOIN source_book sb2 ON sb2.source_book_id = sdha.source_system_book_id2
									LEFT JOIN source_book sb3 ON sb3.source_book_id = sdha.source_system_book_id3
									LEFT JOIN source_book sb4 ON sb4.source_book_id = sdha.source_system_book_id4
									LEFT JOIN source_counterparty sc ON sdha.counterparty_id = sc.source_counterparty_id
									LEFT JOIN source_counterparty sc2 
										ON sdha.broker_id = sc2.source_counterparty_id
										AND sc2.int_ext_flag=''b''
									LEFT JOIN source_deal_type sdt ON sdha.source_deal_type_id = sdt.source_deal_type_id
									LEFT JOIN source_deal_type sdt_sub ON sdha.deal_sub_type_type_id = sdt_sub.source_deal_type_id
									LEFT JOIN static_data_value deal_cat ON sdha.deal_category_value_id = deal_cat.value_id
									LEFT JOIN source_traders st ON sdha.trader_id = st.source_trader_id
									LEFT JOIN static_data_value int_deal_type ON sdha.internal_deal_type_value_id = int_deal_type.value_id
									LEFT JOIN static_data_value int_deal_sub_type ON sdha.internal_deal_subtype_value_id = int_deal_sub_type.value_id
									LEFT JOIN source_deal_header_template sdht ON sdha.template_id = sdht.template_id
									LEFT JOIN source_brokers sbroker ON sdha.broker_id = sbroker.source_broker_id
									LEFT JOIN rec_generator rg ON sdha.generator_id = rg.generator_id
									LEFT JOIN static_data_value stat ON sdha.status_value_id = stat.value_id
									LEFT JOIN static_data_value asgn_type ON sdha.assignment_type_value_id = asgn_type.value_id
									LEFT JOIN static_data_value stt ON sdha.state_value_id = stt.value_id
									LEFT JOIN contract_group cg ON sdha.contract_id = cg.contract_id
									LEFT JOIN source_legal_entity sle ON sdha.legal_entity = sle.source_legal_entity_id
									LEFT JOIN static_data_value sp ON sdha.product_id = sp.value_id
									LEFT JOIN source_commodity scom ON sdha.commodity_id = scom.source_commodity_id
									LEFT JOIN static_data_value pricing ON sdha.pricing = pricing.value_id
									LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdda.curve_id

									--LEFT JOIN static_data_value grnl ON spcd.granularity = grnl.value_id
									LEFT JOIN static_data_value grnl ON sdha.granularity_id = grnl.value_id

									LEFT JOIN source_currency fsc ON sdda.fixed_price_currency_id = fsc.source_currency_id
									LEFT JOIN source_currency fsc2 ON sdda.settlement_currency = fsc2.source_currency_id
									LEFT JOIN source_uom deal_vol_uom ON sdda.deal_volume_uom_id = deal_vol_uom.source_uom_id
									LEFT JOIN static_data_value day_count ON sdda.day_count_id = day_count.value_id
									LEFT JOIN source_minor_location sml ON sdda.location_id = sml.source_minor_location_id
									LEFT JOIN ' + CASE WHEN @deleted_deals = 'y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh on sdh.source_deal_header_id = sdha.source_deal_header_id
									LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdda.source_deal_detail_id
									LEFT JOIN static_data_value sdv ON sdv.value_id = sdha.block_define_id
									LEFT JOIN static_data_value sdv1 ON sdv1.value_id = sdha.block_type
									LEFT JOIN static_data_value sdv2 ON sdv2.value_id = sdda.pv_party
									LEFT JOIN static_data_value sdv3 ON sdv3.value_id = sdda.profile_code
									LEFT JOIN static_data_value sdv4 ON sdv4.value_id = sdda.category
									LEFT JOIN source_uom su ON su.source_uom_id = sdda.price_uom_id
									LEFT JOIN formula_editor fe ON fe.formula_id = sdda.formula_id
									LEFT JOIN static_data_value profile ON profile.value_id = sdha.internal_desk_id
									LEFT JOIN source_currency price_adder_currency1 ON price_adder_currency1.source_currency_id = sdda.adder_currency_id
									LEFT JOIN source_currency price_adder_currency2 ON price_adder_currency2.source_currency_id = sdda.price_adder_currency2
									LEFT JOIN source_currency fixed_cost_currency ON fixed_cost_currency.source_currency_id = sdda.fixed_cost_currency_id
									LEFT JOIN source_currency formula_currency ON formula_currency.source_currency_id = sdda.formula_currency_id
									LEFT JOIN static_data_value sdv_ds ON sdv_ds.value_id = sdha.deal_status
									LEFT JOIN static_data_value sdv_cs ON sdv_cs.value_id = sdha.confirm_status_type
									LEFT JOIN source_minor_location_meter smlm ON sdda.meter_id = smlm.meter_id
									LEFT JOIN meter_id mi On mi.meter_id=smlm.meter_id
								'
exec spa_print @Sql;
	SET @sql_where = '
						WHERE	1=1
								AND EXISTS (
						 			SELECT * FROM source_deal_header_audit sdha1
									INNER JOIN #ssbm ssbm1 
										ON sdha1.source_system_book_id1  = ssbm1.source_system_book_id1 
										AND sdha1.source_system_book_id2 = ssbm1.source_system_book_id2 
										AND sdha1.source_system_book_id3 = ssbm1.source_system_book_id3 
										AND sdha1.source_system_book_id4 = ssbm1.source_system_book_id4 
									LEFT JOIN ' + CASE WHEN @deleted_deals = 'y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh1 
										ON sdh1.source_deal_header_id = sdha1.source_deal_header_id 
										AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
										AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
										AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
										AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
									WHERE sdha1.source_deal_header_id = sdha.source_deal_header_id
									AND isnull(sdh1.source_deal_header_id,-1) = 
											CASE WHEN sdha1.user_action = ''delete'' THEN -1  
											ELSE sdh1.source_deal_header_id END
								)
						AND(sdha.update_ts BETWEEN '''+CAST(dbo.FNAGetSQLStandardDateTime(@update_date_from) AS VARCHAR)+''' AND '''+CAST(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59') AS VARCHAR)+''')'
	
	
	+ CASE 
		WHEN @deal_id_from IS NOT NULL THEN ' AND sdha.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
	ELSE   
 +CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN ('+@source_deal_header_id+')'  ELSE '' END  
 +CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdha.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
 +CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
 +CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
       'sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '' END  
 +CASE WHEN @update_by IS NOT NULL THEN ' AND sdha.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
 +CASE WHEN NULLIF(@trader_id,'') IS NOT NULL THEN ' AND (sdha.trader_id IN (' + @trader_id + ')) ' ELSE '' END  
 +CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN ' AND (sdha.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
 +CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdha.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
 +CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdha.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
 +CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdha.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
 +CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdha.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END  
 --+CASE WHEN @book_deal_type_map_id IS NOT NULL THEN ' AND sbmp.book_deal_type_map_id in( ' + CAST(@book_deal_type_map_id AS VARCHAR(100))+ ')' ELSE '' END  
 +CASE WHEN @deal_status IS NOT NULL THEN ' AND sdh.deal_status=' + CAST(@deal_status AS VARCHAR(100)) ELSE '' END  
 +CASE WHEN @user_action<>'all' THEN ' AND sdha.user_action IN ('+@user_action+')' ELSE '' END  
 +CASE WHEN @generator_id IS NOT NULL THEN ' AND sdha.generator_id='+CAST(@generator_id AS VARCHAR) ELSE '' END  
 +CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdha.compliance_year='+CAST(@compliance_year AS VARCHAR) ELSE '' END  
 +CASE WHEN @cert_entity IS NOT NULL THEN ' AND rg.gis_value_id='+CAST(@cert_entity AS VARCHAR) ELSE '' END  
 +CASE WHEN @cert_date IS NOT NULL THEN ' AND rg.registration_date='''+CAST(@cert_date AS VARCHAR)+'''' ELSE '' END  
 +CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdha.assignment_type_value_id='+CAST(@assignment_type AS VARCHAR) ELSE '' END  
 +CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdha.state_value_id='+CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
 +CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdha.assigned_date='''+CAST(@assigned_date AS VARCHAR)+'''' ELSE '' END  
 +CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdha.assigned_by='''+CAST(@assigned_by AS VARCHAR)+'''' ELSE '' END  
 +CASE WHEN @status  IS NOT NULL THEN ' AND sdha.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END  
 +CASE WHEN @status_date  IS NOT NULL THEN ' AND sdha.status_date ='''+CAST(@status_date  AS VARCHAR)+'''' ELSE '' END  
 +CASE WHEN @cert_no_from  IS NOT NULL THEN ' AND gc.certificate_number_from_int>='+CAST(@cert_no_from  AS VARCHAR) +' AND gc.certificate_number_to_int<='+CAST(@cert_no_to  AS VARCHAR) ELSE '' END  
 + CASE WHEN @drill_deal_id IS NOT NULL THEN ' AND sdha.source_deal_header_id='+@drill_deal_id ELSE '' END  
END  
 + CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdha.source_deal_header_id IN ('+@source_deal_header_id+')'  ELSE '' END  
 + CASE WHEN @update_timestamp IS NOT NULL AND @report_option='d' THEN ' AND dbo.FNAConvertTZAwareDateFormat(sdha.update_ts, 4) ='''+ @update_timestamp +'''' ELSE '' END  
 IF @report_option='s'  
  SET @sql_group=' GROUP BY sc.counterparty_name,sdha.user_action,sdha.update_ts,sdha.update_user,sdha.source_deal_header_id,sdh.source_deal_header_id,sdha.header_buy_sell_flag,sdv_ds.code,sdv_cs.code,sdha.option_flag,sdha.option_type,sdha.option_excercise_type,sdha.option_settlement_date'  
 ELSE  
 SET @sql_group=''   
  
  
-- SET @Sql = @sql_select+@Sql+@sql_where + @sql_group+' Order By sdha.source_deal_header_id,sdha.update_ts DESC '  

--PRINT @sql_select  
--PRINT @Sql  
--PRINT @sql_where   
EXEC spa_print @sql_group, ' Order By sdha.source_deal_header_id,sdha.update_ts DESC '  
EXEC (@sql_select+@Sql+@sql_where + @sql_group+' Order By sdha.source_deal_header_id,sdha.update_ts DESC ') 
  
END --@report_option='s' OR @report_option='d'  
  
ELSE IF @report_option IN ('c','r','a','t') --changed summary  
BEGIN  
	--DECLARE @x DATETIME, @y DATETIME   
	--SET @x = GETDATE()  
	--SELECT @x   
	
	IF @prior_updatedate IS NULL   
	SET @prior_updatedate = GETDATE() ;  
	ELSE  
	BEGIN  
		SELECT  @timeparameter= CHARINDEX ( ':', @prior_updatedate)  
		IF @timeparameter = 0  
		SET @prior_updatedate = @prior_updatedate +' 23:59:59';  
	END  
  
	CREATE TABLE #deals  
	(  
	 source_deal_header_id INT,  
	 audit_id1 INT,  
	 audit_id2 INT  
	)  
  
  --code value for 'char' fields  
	CREATE TABLE #codevalue  
	(  
	 code NCHAR COLLATE DATABASE_DEFAULT,  
	 [VALUE] NVARCHAR(50) COLLATE DATABASE_DEFAULT  ,  
	 Fieldtype NVARCHAR(50) COLLATE DATABASE_DEFAULT    
	)  
  
  INSERT  INTO #codevalue  
    (  
      code,  
      [VALUE],  
      Fieldtype  
    )  
    SELECT  'y',  
      'Yes',  
      'yes_no'  
    UNION ALL  
    SELECT  'n',  
      'No',  
      'yes_no'  
    UNION ALL  
    SELECT  'b',  
      'Buy',  
      'buy_sell'  
    UNION ALL  
    SELECT  's',  
      'Sell',  
      'buy_sell'  
    UNION ALL  
    SELECT  'p',  
      'Physical',  
      'physical_financial'  
    UNION ALL  
    SELECT  'f',  
      'Financial',  
      'physical_financial'  
    UNION ALL  
    SELECT  'c',  
      'Call',  
      'option_type'  
    UNION ALL  
    SELECT  'p',  
      'Put',  
      'option_type'  
    UNION ALL  
    SELECT  'e',  
      'European',  
      'option_exercise'  
    UNION ALL  
    SELECT  'a',  
      'American',  
      'option_exercise'  
    UNION ALL  
    SELECT  'a',  
      'Annual',  
      'frequency'  
    UNION ALL  
    SELECT  'm',  
      'Monthly',  
      'frequency'  
    UNION ALL  
    SELECT  's',  
      'Semi Annual',  
      'frequency'  
    UNION ALL  
    SELECT  'w',  
      'Weekly',  
      'frequency'  
    UNION ALL  
    SELECT  'd',  
      'Daily',  
      'frequency'  
    UNION ALL  
    SELECT  'h',  
      'Hourly',  
      'frequency'  
    UNION ALL  
    SELECT  'q',  
      'Quarterly',  
      'frequency'  
    UNION ALL  
    SELECT  't',  
      'Term',  
      'frequency'        
    UNION ALL  
    SELECT  't',  
      'float',  
      'fixed_float_leg'  
    UNION ALL  
    SELECT  'f',  
      'fixed',  
      'fixed_float_leg'  
    UNION ALL   
    SELECT 'q',  
      'Quarterly',  
      'rolling_avg'  
    UNION ALL  
    SELECT 's',  
      'Semi-Annually',  
      'rolling_avg'  
    UNION ALL  
    SELECT 'a',  
      'Annually',  
      'rolling_avg'        
 
  --[user_defined_deal_fields_template]'s udf_template_id mapping to value_id and code from sql_String and udf_group for dropdown.  
    DECLARE @udf_template_id INT
  
    CREATE TABLE #cursor_valueid_code  
     (  
       value_id VARCHAR(100) COLLATE DATABASE_DEFAULT  ,  
       code NVARCHAR(4000) COLLATE DATABASE_DEFAULT     
     ) ;  
  
    CREATE TABLE #udf_templateid_valueid_code  
     (  
       udf_template_id INT,  
       field_type VARCHAR(100) COLLATE DATABASE_DEFAULT  ,  
       value_id VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
       code NVARCHAR(4000) COLLATE DATABASE_DEFAULT   
     ) ;  
  
    --for udf_group  
    INSERT  INTO #udf_templateid_valueid_code  
      (  
        udf_template_id,  
        field_type,  
        value_id,  
        code  
      )  
      SELECT  udf_template_id,  
        field_type,  
        value_id,  
        code  
      FROM    user_defined_deal_fields_template uddft  
        CROSS APPLY ( SELECT    value_id,  
              code  
             FROM      static_data_value  
             WHERE     TYPE_ID = uddft.udf_group  
           ) a ( value_id, code )  
      WHERE   field_type = 'd'  
        AND ISNULL(uddft.udf_group, '') <> ''  
     
    INSERT  INTO #udf_templateid_valueid_code (  
        udf_template_id,  
        field_type,  
        value_id,  
        code  
	) 
	SELECT udf_template_id,  
        'd',  
        id,  
        value
	FROM #map_table
	UNION ALL
	SELECT udf_template_id,  
        'd',  
        id,  
        value
	FROM #map_table_detail
	      
	 -- --cursor for "exec spa_execute_query @sql_string "  
		--DECLARE sql_cursor CURSOR  
		--FOR SELECT  uddft.udf_template_id,  
		--	udft.sql_string  
		--FROM user_defined_deal_fields_template uddft
		--INNER JOIN user_defined_fields_template udft
		--on uddft.field_name = udft.field_name
		--WHERE   udft.Field_type = 'd'  
		--AND ISNULL(udft.udf_group, '') = ''
       
  --     OPEN sql_cursor  
  
  --     FETCH NEXT FROM sql_cursor INTO @udf_template_id, @sql_string  
  --     WHILE @@FETCH_STATUS = 0  
  --      BEGIN  
  
  --       INSERT  INTO #cursor_valueid_code  
  --         EXEC spa_execute_query @sql_string  
  
  --       INSERT  INTO #udf_templateid_valueid_code  
  --         (  
  --           udf_template_id,  
  --           field_type,  
  --           value_id,  
  --           code  
  --         )  
  --         SELECT  udf_template_id,  
  --           field_type,  
  --           value_id,  
  --           code  
  --         FROM    ( SELECT    @udf_template_id AS udf_template_id,  
  --              'd' AS field_type  
  --           ) a  
  --           CROSS APPLY ( SELECT    value_id,  
  --                 code  
  --                FROM      #cursor_valueid_code  
  --              ) b ( value_id, code )  
  
  --       DELETE  FROM #cursor_valueid_code  
  
  --         -- Get the next udf_template_id,sql_string.  
  --       FETCH NEXT FROM sql_cursor INTO @udf_template_id, @sql_string  
  --      END   
  --     CLOSE sql_cursor  
  --     DEALLOCATE sql_cursor  

--select * from #udf_templateid_valueid_code
 -- EXEC spa_print 'Change summary and as_of_date '
  IF @report_option IN ('c','a','t')
  BEGIN 
  SET @sql_select=  
  'INSERT INTO #deals  
    SELECT DISTINCT sdha1.source_deal_header_id [source_deal_header_id],  
      (sdha1.audit_id) [audit_id1],  
      (sdha2.audit_id) [audit_id2]  
    FROM  source_deal_header_audit sdh  
      INNER JOIN source_deal_header_audit sdha1 ON sdha1.source_deal_header_id=sdh.source_deal_header_id  
      LEFT JOIN ' + @source_deal_detail_audit + ' sdda ON sdha1.audit_id = sdda.header_audit_id  
      AND sdha1.source_deal_header_id = sdda.source_deal_header_id 
      INNER JOIN source_system_book_map sbmp 
      ON sdha1.source_system_book_id1 = sbmp.source_system_book_id1
      AND sdha1.source_system_book_id2 = sbmp.source_system_book_id2
      AND sdha1.source_system_book_id3 = sbmp.source_system_book_id3
      AND sdha1.source_system_book_id4 = sbmp.source_system_book_id4  
      LEFT JOIN rec_generator rg ON sdha1.generator_id = rg.generator_id  
      LEFT JOIN gis_certificate gc ON gc.source_deal_header_id=sdda.source_deal_detail_id  
       
       OUTER APPLY (
    	--grab details fo next change audit id
    	SELECT sdha3.* 
    	FROM (
    		--find next change audit id
    	SELECT max (audit_id) audit_id
    	FROM source_deal_header_audit sdha2_inner
    	WHERE sdha2_inner.source_deal_header_id = sdha1.source_deal_header_id    	
               AND sdha1.audit_id > sdha2_inner.audit_id
    	) sdha2_outer
    	INNER JOIN source_deal_header_audit sdha3 ON sdha3.audit_id = sdha2_outer.audit_id
    ) sdha2
      
      LEFT JOIN source_deal_header_audit sdha3 ON sdha3.source_deal_header_id = sdha1.source_deal_header_id    
	  WHERE	1=1
			AND EXISTS (
				SELECT * FROM source_deal_header_audit sdha4
				INNER JOIN #ssbm ssbm1 
					ON sdha4.source_system_book_id1 = ssbm1.source_system_book_id1
					AND sdha4.source_system_book_id2 = ssbm1.source_system_book_id2
					AND sdha4.source_system_book_id3 = ssbm1.source_system_book_id3
					AND sdha4.source_system_book_id4 = ssbm1.source_system_book_id4
				LEFT JOIN source_deal_header_audit sdh1 
					ON sdh1.source_deal_header_id = sdha4.source_deal_header_id 
					AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
					AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
					AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
					AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
				WHERE sdha4.source_deal_header_id = sdha1.source_deal_header_id
				AND isnull(sdh1.source_deal_header_id,-1) = 
						CASE WHEN sdha4.user_action = ''delete'' THEN -1  
						ELSE isnull(sdh1.source_deal_header_id, -1) END
			)
  --  AND dbo.FNAGetSQLStandardDateTime(sdha2.update_ts) <='''+@prior_updatedate+''' 
      --AND (sdha1.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59'),GETDATE()) AS VARCHAR)+''')  
     -- AND (sdha2.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59'),GETDATE()) AS VARCHAR)+''')
      '  
	+ CASE WHEN @user_action<>'all' THEN ' AND sdha1.user_action IN ('+@user_action+')' ELSE '' END 
    + CASE WHEN   @report_option = 'c' THEN    ' AND (sdha1.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_to +' 23:59:59'),GETDATE()) AS VARCHAR)+''') '
    ELSE    ' AND (sdha1.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+ CAST(dbo.FNAGetSQLStandardDateTime(GETDATE() +' 23:59:59') AS VARCHAR)+''') '  
     END 
     +CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN ('+@source_deal_header_id+')'  
      ELSE   
     CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
      ELSE   
     +CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
     +CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
     --+CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
     --      '
     --      --sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '
     --      ' END  
     +CASE WHEN @update_by IS NOT NULL THEN ' AND sdha1.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
     +CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + @trader_id + ')) ' ELSE '' END  
     +CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdh.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdh.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdh.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdh.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END  
     +CASE WHEN @book_deal_type_map_id IS NOT NULL THEN ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')' ELSE '' END  
     +CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id='+CAST(@generator_id AS VARCHAR) ELSE '' END  
     +CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year='+CAST(@compliance_year AS VARCHAR) ELSE '' END  
     +CASE WHEN @cert_entity IS NOT NULL THEN ' AND rg.gis_value_id='+CAST(@cert_entity AS VARCHAR) ELSE '' END  
     +CASE WHEN @cert_date IS NOT NULL THEN ' AND rg.registration_date='''+CAST(@cert_date AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdh.assignment_type_value_id='+CAST(@assignment_type AS VARCHAR) ELSE '' END  
     +CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdh.state_value_id='+CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
     +CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date='''+CAST(@assigned_date AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by='''+CAST(@assigned_by AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @status  IS NOT NULL THEN ' AND sdh.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END  
     +CASE WHEN @status_date  IS NOT NULL THEN ' AND sdh.status_date ='''+CAST(@status_date  AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @cert_no_from  IS NOT NULL THEN ' AND gc.certificate_number_from_int>='+CAST(@cert_no_from  AS VARCHAR) +' AND gc.certificate_number_to_int<='+CAST(@cert_no_to  AS VARCHAR) ELSE '' END  
     +CASE WHEN @drill_deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id='+@drill_deal_id ELSE '' END  
     +CASE WHEN @user_action <> 'all' THEN ' AND sdha1.user_action IN (' + @user_action + ')' ELSE '' END  
	 END  
    END  
  --  +' GROUP BY sdha1.source_deal_header_id'  
END 

 --PRINT 'Change summary and as_of_date '
  IF @report_option IN ('r')
  BEGIN 
  EXEC spa_print 'in Recent change block'
  SET @sql_select=  
  'INSERT INTO #deals  
    SELECT  sdha1.source_deal_header_id [source_deal_header_id],  
      MAX(sdha1.audit_id) [audit_id1],  
      MAX(sdha2.audit_id) [audit_id2]  
    FROM    ' + CASE WHEN @deleted_deals = 'y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh  
      INNER JOIN source_deal_header_audit sdha1 ON sdha1.source_deal_header_id=sdh.source_deal_header_id  
      LEFT JOIN ' + @source_deal_detail_audit + ' sdda ON sdha1.audit_id = sdda.header_audit_id  
      AND sdha1.source_deal_header_id = sdda.source_deal_header_id 
      INNER JOIN source_system_book_map sbmp 
      ON sdha1.source_system_book_id1 = sbmp.source_system_book_id1
      AND sdha1.source_system_book_id2 = sbmp.source_system_book_id2
      AND sdha1.source_system_book_id3 = sbmp.source_system_book_id3
      AND sdha1.source_system_book_id4 = sbmp.source_system_book_id4  
      LEFT JOIN rec_generator rg ON sdha1.generator_id = rg.generator_id  
      LEFT JOIN gis_certificate gc ON gc.source_deal_header_id=sdda.source_deal_detail_id  
       
       OUTER APPLY (
    	--grab details fo next change audit id
    	SELECT sdha3.* 
    	FROM (
    		--find next change audit id
    	SELECT max (audit_id) audit_id
    	FROM source_deal_header_audit sdha2_inner
    	WHERE sdha2_inner.source_deal_header_id = sdha1.source_deal_header_id    	
               AND sdha1.audit_id > sdha2_inner.audit_id
    	) sdha2_outer
    	INNER JOIN source_deal_header_audit sdha3 ON sdha3.audit_id = sdha2_outer.audit_id
    ) sdha2
      
      LEFT JOIN source_deal_header_audit sdha3 ON sdha3.source_deal_header_id = sdha1.source_deal_header_id    
	  WHERE	1=1
			AND EXISTS (
				SELECT * FROM source_deal_header_audit sdha4
				INNER JOIN #ssbm ssbm1 
					ON sdha4.source_system_book_id1 = ssbm1.source_system_book_id1
					AND sdha4.source_system_book_id2 = ssbm1.source_system_book_id2
					AND sdha4.source_system_book_id3 = ssbm1.source_system_book_id3
					AND sdha4.source_system_book_id4 = ssbm1.source_system_book_id4
				LEFT JOIN ' + CASE WHEN @deleted_deals = 'y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh1 
					ON sdh1.source_deal_header_id = sdha4.source_deal_header_id 
					AND sdh1.source_system_book_id1 = ssbm1.source_system_book_id1
					AND sdh1.source_system_book_id2 = ssbm1.source_system_book_id2
					AND sdh1.source_system_book_id3 = ssbm1.source_system_book_id3
					AND sdh1.source_system_book_id4 = ssbm1.source_system_book_id4
				WHERE sdha4.source_deal_header_id = sdha1.source_deal_header_id
				AND isnull(sdh1.source_deal_header_id,-1) = 
						CASE WHEN sdha4.user_action = ''delete'' THEN -1  
						ELSE sdh1.source_deal_header_id END
			)
    --AND dbo.FNAGetSQLStandardDateTime(sdha2.update_ts) <='''+@prior_updatedate+''' 
    AND sdha1.user_action = ''Update''
      --AND (sdha1.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59'),GETDATE()) AS VARCHAR)+''')  
     -- AND (sdha2.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_to+' 23:59:59'),GETDATE()) AS VARCHAR)+''')
      '  
    + CASE WHEN   @report_option = 'c' THEN    ' AND (sdha1.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_to),GETDATE()) AS VARCHAR)+''') '
    ELSE    ' AND (sdha1.update_ts BETWEEN '''+CAST(isnull(dbo.FNAGetSQLStandardDateTime(@update_date_from),GETDATE()) AS VARCHAR)+''' AND '''+ CAST(GETDATE() AS VARCHAR)+''') '  
     END 
     +CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN ('+@source_deal_header_id+')'  
      ELSE   
     CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id  BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR)   
      ELSE   
     +CASE WHEN @deal_date_from IS NOT NULL THEN ' AND sdh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + '''' ELSE '' END  
     +CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdda.term_start BETWEEN ''' + @tenor_from + ''' AND ''' + @tenor_to + '''' ELSE '' END  
     --+CASE WHEN @update_date_from IS NOT NULL THEN ' AND ( '+  
     --      '
     --      --sdda.update_ts BETWEEN ''' + CAST(dbo.FNAConvertTimezone(@update_date_from,1) AS VARCHAR) + ''' AND ''' + CAST(dbo.FNAConvertTimezone(@update_date_to+' 23:59:59',1) AS VARCHAR) + ''')' ELSE '
     --      ' END  
     +CASE WHEN @update_by IS NOT NULL THEN ' AND sdh.update_user = ''' + CAST(@update_by AS VARCHAR) + '''' ELSE '' END  
     +CASE WHEN @trader_id IS NOT NULL THEN ' AND (sdh.trader_id IN (' + @trader_id + ')) ' ELSE '' END  
     +CASE WHEN @counterparty_id IS NOT NULL THEN ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdh.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND (sdh.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND (sdh.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' ELSE '' END  
     +CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND (sdh.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' ELSE '' END  
     +CASE WHEN @book_deal_type_map_id IS NOT NULL THEN ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')' ELSE '' END  
     +CASE WHEN @generator_id IS NOT NULL THEN ' AND sdh.generator_id='+CAST(@generator_id AS VARCHAR) ELSE '' END  
     +CASE WHEN @compliance_year IS NOT NULL THEN ' AND sdh.compliance_year='+CAST(@compliance_year AS VARCHAR) ELSE '' END  
     +CASE WHEN @cert_entity IS NOT NULL THEN ' AND rg.gis_value_id='+CAST(@cert_entity AS VARCHAR) ELSE '' END  
     +CASE WHEN @cert_date IS NOT NULL THEN ' AND rg.registration_date='''+CAST(@cert_date AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @assignment_type IS NOT NULL THEN ' AND sdh.assignment_type_value_id='+CAST(@assignment_type AS VARCHAR) ELSE '' END  
     +CASE WHEN @assigned_jurisdiction IS NOT NULL THEN ' AND sdh.state_value_id='+CAST(@assigned_jurisdiction AS VARCHAR) ELSE '' END  
     +CASE WHEN @assigned_date IS NOT NULL THEN ' AND sdh.assigned_date='''+CAST(@assigned_date AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @assigned_by IS NOT NULL THEN ' AND sdh.assigned_by='''+CAST(@assigned_by AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @status  IS NOT NULL THEN ' AND sdh.status_value_id ='+CAST(@status  AS VARCHAR) ELSE '' END  
     +CASE WHEN @status_date  IS NOT NULL THEN ' AND sdh.status_date ='''+CAST(@status_date  AS VARCHAR)+'''' ELSE '' END  
     +CASE WHEN @cert_no_from  IS NOT NULL THEN ' AND gc.certificate_number_from_int>='+CAST(@cert_no_from  AS VARCHAR) +' AND gc.certificate_number_to_int<='+CAST(@cert_no_to  AS VARCHAR) ELSE '' END  
     + CASE WHEN @drill_deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id='+@drill_deal_id ELSE '' END  
      END  
    END  
    +' 
      GROUP BY sdha1.source_deal_header_id'  

	--EXEC spa_PRINT @sql_select
-- EXEC(@sql_select)

  END 
  

 --SELECT @sql_select
  --PRINT @sql_select
  EXEC(@sql_select) 
 -- SELECT * FROM #deals 

	CREATE TABLE #tmp_deal_detail (
		[Deal ID] INT,
		[Ref ID] NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[Term Start] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[Leg] INT NULL,
		[Header Detail]	VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		Field NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[Prior Value] NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Current Value] NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Update Timestamp] VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		[Update User] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[User Action] VARCHAR(50) COLLATE DATABASE_DEFAULT 
	) 

  SET @sql_select = '
  INSERT INTO #tmp_deal_detail 
  SELECT  [Deal ID],[Ref ID],[Term Start],[Leg],[Header Detail],Field,[Prior Value],[Current Value],dbo.FNADateTimeFormat([UPDATE TS],1) AS [Update Timestamp],[Update User]  
  ,  [User Action] 
  FROM (  
  --header  
   SELECT  sdha1.source_deal_header_id [Deal ID],  
    sdha1.deal_id [REF ID],  
    dbo.FNADateFormat(sdha1.entire_term_start) [Term START],  
    NULL [Leg],  
    ''Header'' [Header Detail],
    Field,  
    [PRIOR VALUE],  
    [CURRENT VALUE],  
    sdha1.update_ts  [UPDATE TS],  
    dbo.FNAGetUserName(sdha1.update_user) [UPDATE USER],
	sdha1.user_action [User Action] 
  FROM    #deals deals  
    LEFT JOIN source_deal_header_audit sdha1 ON sdha1.audit_id = deals.audit_id1  
    LEFT JOIN source_deal_header_audit sdha2 ON sdha2.audit_id = deals.audit_id2  
               AND sdha1.audit_id > sdha2.audit_id  
    --contract_id: contract_group (contract_id)  
    LEFT JOIN contract_group cg1 ON cg1.contract_id = sdha1.contract_id  
    LEFT JOIN contract_group cg2 ON cg2.contract_id = sdha2.contract_id  
  
    --Pricing : static_data_value (value_id)  
    LEFT JOIN static_data_value sdv_pricing1 ON sdv_pricing1.value_id = sdha1.Pricing  
    LEFT JOIN static_data_value sdv_pricing2 ON sdv_pricing2.value_id = sdha2.Pricing  
  
    --generator_id : rec_generator (generator_id)  
    LEFT JOIN rec_generator rg1 ON rg1.generator_id = sdha1.generator_id  
    LEFT JOIN rec_generator rg2 ON rg2.generator_id = sdha2.generator_id  
  
    --source_system_book_id1 :source_book (source_book_id)  
    LEFT JOIN source_book sb1_1 ON sb1_1.source_book_id = sdha1.source_system_book_id1  
    LEFT JOIN source_book sb1_2 ON sb1_2.source_book_id = sdha2.source_system_book_id1  
  
    --source_system_book_id2 :source_book (source_book_id)  
    LEFT JOIN source_book sb2_1 ON sb2_1.source_book_id = sdha1.source_system_book_id2  
    LEFT JOIN source_book sb2_2 ON sb2_2.source_book_id = sdha2.source_system_book_id2  
  
    --source_system_book_id3 :source_book (source_book_id)  
    LEFT JOIN source_book sb3_1 ON sb3_1.source_book_id = sdha1.source_system_book_id3  
    LEFT JOIN source_book sb3_2 ON sb3_2.source_book_id = sdha2.source_system_book_id3  
  
    --source_system_book_id4 :source_book (source_book_id)  
    LEFT JOIN source_book sb4_1 ON sb4_1.source_book_id = sdha1.source_system_book_id4  
    LEFT JOIN source_book sb4_2 ON sb4_2.source_book_id = sdha2.source_system_book_id4  
  
    --counterparty_id : source_counterparty (source_counterparty_id)  
    LEFT JOIN SOURCE_COUNTERPARTY sc1 ON sc1.source_counterparty_id = sdha1.counterparty_id  
    LEFT JOIN SOURCE_COUNTERPARTY sc2 ON sc2.source_counterparty_id = sdha2.counterparty_id  
  
    --close_reference_id : source_deal_header (source_deal_header_id)  
    LEFT JOIN source_deal_header sdh_close1 ON sdh_close1.source_deal_header_id = sdha1.close_reference_id  
    LEFT JOIN source_deal_header sdh_close2 ON sdh_close2.source_deal_header_id = sdha2.close_reference_id  
  
    --source_deal_type_id : source_deal_type (source_deal_type_id)  
    LEFT JOIN source_deal_type sdtype1 ON sdtype1.source_deal_type_id = sdha1.source_deal_type_id  
    LEFT JOIN source_deal_type sdtype2 ON sdtype2.source_deal_type_id = sdha2.source_deal_type_id  
  
    --deal_sub_type_type_id : source_deal_type (source_deal_type_id)  
    LEFT JOIN source_deal_type sdsubtype1 ON sdsubtype1.source_deal_type_id = sdha1.deal_sub_type_type_id  
    LEFT JOIN source_deal_type sdsubtype2 ON sdsubtype2.source_deal_type_id = sdha2.deal_sub_type_type_id  
  
    --trader_id : source_traders (source_trader_id)  
    LEFT JOIN source_traders straders1 ON straders1.source_trader_id = sdha1.trader_id  
    LEFT JOIN source_traders straders2 ON straders2.source_trader_id = sdha2.trader_id  
  
    --deal_category_value_id : static_data_value (value_id)  
    LEFT JOIN static_data_value sdvdealcat1 ON sdvdealcat1.value_id = sdha1.deal_category_value_id  
    LEFT JOIN static_data_value sdvdealcat2 ON sdvdealcat2.value_id = sdha2.deal_category_value_id  
      
    --char types   
    --header_buy_sell_flag  
    LEFT JOIN #codevalue buy_sell_h1 ON buy_sell_h1.Fieldtype=''buy_sell'' AND buy_sell_h1.code=sdha1.header_buy_sell_flag   
    LEFT JOIN #codevalue buy_sell_h2 ON buy_sell_h2.Fieldtype=''buy_sell'' AND buy_sell_h2.code=sdha2.header_buy_sell_flag  
  
    --physical_financial_flag  
    LEFT JOIN #codevalue phy_fin_h1 ON phy_fin_h1.Fieldtype=''physical_financial'' AND phy_fin_h1.code=sdha1.physical_financial_flag   
    LEFT JOIN #codevalue phy_fin_h2 ON phy_fin_h2.Fieldtype=''physical_financial'' AND phy_fin_h2.code=sdha2.physical_financial_flag  
  
    --option_type  
    LEFT JOIN #codevalue option_type_h1 ON option_type_h1.Fieldtype=''option_type'' AND option_type_h1.code=sdha1.option_type   
    LEFT JOIN #codevalue option_type_h2 ON option_type_h2.Fieldtype=''option_type'' AND option_type_h2.code=sdha2.option_type  
  
    --option_excercise_type  
    LEFT JOIN #codevalue option_ex_h1 ON option_ex_h1.Fieldtype=''option_exercise'' AND option_ex_h1.code=sdha1.option_excercise_type   
    LEFT JOIN #codevalue option_ex_h2 ON option_ex_h2.Fieldtype=''option_exercise'' AND option_ex_h2.code=sdha2.option_excercise_type  
  
    --aggregate_environment  
    LEFT JOIN #codevalue agg_env_h1 ON agg_env_h1.Fieldtype=''yes_no'' AND agg_env_h1.code=ISNULL(sdha1.aggregate_environment,''n'')  
    LEFT JOIN #codevalue agg_env_h2 ON agg_env_h2.Fieldtype=''yes_no'' AND agg_env_h2.code=ISNULL(sdha2.aggregate_environment,''n'')  
  
    --option_flag  
    LEFT JOIN #codevalue option_flag_h1 ON option_flag_h1.Fieldtype=''yes_no'' AND option_flag_h1.code=sdha1.option_flag   
    LEFT JOIN #codevalue option_flag_h2 ON option_flag_h2.Fieldtype=''yes_no'' AND option_flag_h2.code=sdha2.option_flag  
  '
  SET @sql_select_sub = '
    --deal_locked  
    LEFT JOIN #codevalue deal_locked_h1 ON deal_locked_h1.Fieldtype=''yes_no'' AND deal_locked_h1.code=sdha1.deal_locked   
    LEFT JOIN #codevalue deal_locked_h2 ON deal_locked_h2.Fieldtype=''yes_no'' AND deal_locked_h2.code=sdha2.deal_locked  
      
    --rolling_avg  
    LEFT JOIN #codevalue rolling_avg_h1 ON rolling_avg_h1.Fieldtype=''rolling_avg'' AND rolling_avg_h1.code=sdha1.rolling_avg  
    LEFT JOIN #codevalue rolling_avg_h2 ON rolling_avg_h2.Fieldtype=''rolling_avg'' AND rolling_avg_h2.code=sdha2.rolling_avg  
  
    --others, not defined by foreign key and char  
    --internal_deal_type_value_id  
    LEFT JOIN internal_deal_type_subtype_types int_deal_type_h1 ON  int_deal_type_h1.internal_deal_type_subtype_id=sdha1.internal_deal_type_value_id   
    LEFT JOIN internal_deal_type_subtype_types int_deal_type_h2 ON  int_deal_type_h2.internal_deal_type_subtype_id=sdha2.internal_deal_type_value_id  
  
    --internal_deal_subtype_value_id  
    LEFT JOIN internal_deal_type_subtype_types int_deal_subtype_h1 ON  int_deal_subtype_h1.internal_deal_type_subtype_id=sdha1.internal_deal_subtype_value_id   
    LEFT JOIN internal_deal_type_subtype_types int_deal_subtype_h2 ON  int_deal_subtype_h2.internal_deal_type_subtype_id=sdha2.internal_deal_subtype_value_id  
  
    --template_id  
    LEFT JOIN source_deal_header_template template_h1 ON  template_h1.template_id=sdha1.template_id   
    LEFT JOIN source_deal_header_template template_h2 ON  template_h2.template_id=sdha2.template_id  
      
    --commodity_id  
    LEFT JOIN source_commodity commodity_h1 ON  commodity_h1.source_commodity_id=sdha1.commodity_id   
    LEFT JOIN source_commodity commodity_h2 ON  commodity_h2.source_commodity_id=sdha2.commodity_id  
  
    --block_type  
    LEFT JOIN static_data_value sdv_block_type1 ON sdv_block_type1.value_id = sdha1.block_type  
    LEFT JOIN static_data_value sdv_block_type2 ON sdv_block_type2.value_id = sdha2.block_type  
  
    --block_define_id  
    LEFT JOIN static_data_value sdv_block_define1 ON sdv_block_define1.value_id = sdha1.block_define_id  
    LEFT JOIN static_data_value sdv_block_define2 ON sdv_block_define2.value_id = sdha2.block_define_id  
  
    --granularity_id  
    LEFT JOIN static_data_value sdv_granularity1 ON sdv_granularity1.value_id = sdha1.granularity_id  
    LEFT JOIN static_data_value sdv_granularity2 ON sdv_granularity2.value_id = sdha2.granularity_id  
  
    --broker_id  
    LEFT JOIN source_counterparty sc_broker1 ON sc_broker1.source_counterparty_id = sdha1.broker_id  
    LEFT JOIN source_counterparty sc_broker2 ON sc_broker2.source_counterparty_id = sdha2.broker_id  
      
    --internal_desk_id  
    LEFT JOIN static_data_value sid_desk1 ON sid_desk1.value_id = sdha1.internal_desk_id  
    LEFT JOIN static_data_value sid_desk2 ON sid_desk2.value_id = sdha2.internal_desk_id  
  
    --internal_portfolio_id  
    LEFT JOIN static_data_value sip_portfolio1 ON sip_portfolio1.value_id = sdha1.internal_portfolio_id  
    LEFT JOIN static_data_value sip_portfolio2 ON sip_portfolio2.value_id = sdha2.internal_portfolio_id  
  
    --product_id  
    LEFT JOIN static_data_value sp_product1 ON sp_product1.value_id = sdha1.product_id  
    LEFT JOIN static_data_value sp_product2 ON sp_product2.value_id = sdha2.product_id  
  
    --commodity_id  
    LEFT JOIN source_commodity sc_commodity1 ON sc_commodity1.source_commodity_id = sdha1.commodity_id  
    LEFT JOIN source_commodity sc_commodity2 ON sc_commodity2.source_commodity_id = sdha2.commodity_id  
  
    --legal_entity  
    LEFT JOIN source_legal_entity sle_legal1 ON sle_legal1.source_legal_entity_id = sdha1.legal_entity  
    LEFT JOIN source_legal_entity sle_legal2 ON sle_legal2.source_legal_entity_id = sdha2.legal_entity  
      
    --currency  
    LEFT JOIN source_currency scurrency1 ON scurrency1.source_currency_id = sdha1.broker_currency_id  
    LEFT JOIN source_currency scurrency2 ON scurrency2.source_currency_id = sdha2.broker_currency_id  
      
    --Deal Status  
    LEFT JOIN static_data_value sdv_ds1 ON sdv_ds1.value_id = sdha1.deal_status  
    LEFT JOIN static_data_value sdv_ds2 ON sdv_ds2.value_id = sdha2.deal_status     
      
    --Confirm Status Type  
    LEFT JOIN static_data_value sdv_cs1 ON sdv_cs1.value_id = sdha1.confirm_status_type  
    LEFT JOIN static_data_value sdv_cs2 ON sdv_cs2.value_id = sdha2.confirm_status_type  
    
    --counterparty_id2 : source_counterparty (source_counterparty_id)  
    LEFT JOIN SOURCE_COUNTERPARTY sc_1 ON sc_1.source_counterparty_id = sdha1.counterparty_id2  
    LEFT JOIN SOURCE_COUNTERPARTY sc_2 ON sc_2.source_counterparty_id = sdha2.counterparty_id2 
    
    --trader_id2 : source_traders (source_trader_id)  
    LEFT JOIN source_traders straders_1 ON straders_1.source_trader_id = sdha1.trader_id2  
    LEFT JOIN source_traders straders_2 ON straders_2.source_trader_id = sdha2.trader_id2 
	
	--inco_terms
	LEFT JOIN static_data_value sdvit1 ON sdvit1.value_id = sdha1.inco_terms 
    LEFT JOIN static_data_value sdvit2 ON sdvit2.value_id = sdha2.inco_terms

	--payment_term
	LEFT JOIN static_data_value sdvpat1 ON sdvpat1.value_id = sdha1.payment_term 
    LEFT JOIN static_data_value sdvpat2 ON sdvpat2.value_id = sdha2.payment_term

	--governing_law
	LEFT JOIN static_data_value sdvgl1 ON sdvgl1.value_id = sdha1.governing_law 
    LEFT JOIN static_data_value sdvgl2 ON sdvgl2.value_id = sdha2.governing_law

	--arbitration
	LEFT JOIN static_data_value sdvab1 ON sdvab1.value_id = sdha1.arbitration 
    LEFT JOIN static_data_value sdvab2 ON sdvab2.value_id = sdha2.arbitration

	--underlying_options
	LEFT JOIN static_data_value sdvuo1 ON CAST(sdvuo1.value_id AS VARCHAR) = sdha1.underlying_options 
    LEFT JOIN static_data_value sdvuo2 ON CAST(sdvuo2.value_id AS VARCHAR) = sdha2.underlying_options

	--pricing_type
	LEFT JOIN static_data_value sdvhpt1 ON sdvhpt1.value_id = sdha1.pricing_type 
    LEFT JOIN static_data_value sdvhpt2 ON sdvhpt2.value_id = sdha2.pricing_type

	--confirmation_type
	LEFT JOIN static_data_value sdvct1 ON sdvct1.value_id = sdha1.confirmation_type 
    LEFT JOIN static_data_value sdvct2 ON sdvct2.value_id = sdha2.confirmation_type

	--holiday_calendar
	LEFT JOIN static_data_value sdvhl1 ON sdvhl1.value_id = sdha1.holiday_calendar 
    LEFT JOIN static_data_value sdvhl2 ON sdvhl2.value_id = sdha2.holiday_calendar

	--fx_conversion_market
	LEFT JOIN static_data_value sdvfcm1 ON sdvfcm1.value_id = sdha1.fx_conversion_market 
    LEFT JOIN static_data_value sdvfcm2 ON sdvfcm2.value_id = sdha2.fx_conversion_market

	--tier_value_id
	LEFT JOIN static_data_value sdvtvi1 ON sdvtvi1.value_id = sdha1.tier_value_id 
    LEFT JOIN static_data_value sdvtvi2 ON sdvtvi2.value_id = sdha2.tier_value_id

	--reporting_group1
    LEFT JOIN static_data_value rp1_sdv1 ON rp1_sdv1.value_id = sdha1.reporting_group1  
    LEFT JOIN static_data_value rp1_sdv2 ON rp1_sdv2.value_id = sdha2.reporting_group1     
      
	--reporting_group2
    LEFT JOIN static_data_value rp2_sdv1 ON rp2_sdv1.value_id = sdha1.reporting_group2  
    LEFT JOIN static_data_value rp2_sdv2 ON rp2_sdv2.value_id = sdha2.reporting_group2     
      
	--reporting_group3
    LEFT JOIN static_data_value rp3_sdv1 ON rp3_sdv1.value_id = sdha1.reporting_group3  
    LEFT JOIN static_data_value rp3_sdv2 ON rp3_sdv2.value_id = sdha2.reporting_group3     
      
	--reporting_group4
    LEFT JOIN static_data_value rp4_sdv1 ON rp4_sdv1.value_id = sdha1.reporting_group4  
    LEFT JOIN static_data_value rp4_sdv2 ON rp4_sdv2.value_id = sdha2.reporting_group4     
      
	--reporting_group5
    LEFT JOIN static_data_value rp5_sdv1 ON rp5_sdv1.value_id = sdha1.reporting_group5  
    LEFT JOIN static_data_value rp5_sdv2 ON rp5_sdv2.value_id = sdha2.reporting_group5     
               

	'  

  
SET @sql_select1 = '      
    CROSS APPLY (   
        SELECT    N''Ref ID'',  
          CAST(sdha1.deal_id AS NVARCHAR(100)),  
          CAST(sdha2.deal_id AS NVARCHAR(100)),  
          CAST(sdha1.deal_id AS NVARCHAR(100)),  
          CAST(sdha2.deal_id AS NVARCHAR(100))  
        UNION ALL  
        SELECT    N''Charge Type'',  
          CAST(sdha1.unit_fixed_flag AS NVARCHAR(250)),  
          CASE 
			WHEN sdha2.user_action=''Insert'' THEN sdha1.unit_fixed_flag  
			ELSE CAST(sdha2.unit_fixed_flag AS NVARCHAR(250)) 
          END , -- Ignore Charge Type when previous user action is "Insert"  
          CASE sdha1.unit_fixed_flag   
           WHEN   ''u'' THEN ''Unit Fees''   
           WHEN   ''f'' THEN ''Fixed Cost''  
           ELSE ''''  
          END,                       
          CASE sdha2.unit_fixed_flag   
           WHEN   ''u'' THEN ''Unit Fees''   
           WHEN   ''f'' THEN ''Fixed Cost''  
           ELSE ''''  
          END  
                        
        UNION ALL  
        SELECT    N''Broker Unit Fees'',  
          CAST(sdha1.broker_unit_fees AS NVARCHAR(250)),  
          CAST(sdha2.broker_unit_fees AS NVARCHAR(250)),  
          CAST(sdha1.broker_unit_fees AS NVARCHAR(250)),  
          CAST(sdha2.broker_unit_fees AS NVARCHAR(250))  
        UNION ALL  
        SELECT    N''Broker Fixed Cost'',  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha1.broker_fixed_cost), ''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha2.broker_fixed_cost), ''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha1.broker_fixed_cost), ''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha2.broker_fixed_cost), ''n'')
        UNION ALL  
        SELECT    N''Currency'',  
          CAST(sdha1.broker_currency_id AS NVARCHAR(250)),  
          CASE WHEN sdha2.user_action=''Insert'' THEN CAST(sdha1.broker_currency_id AS NVARCHAR(250))  
          ELSE CAST(sdha2.broker_currency_id AS NVARCHAR(250)) END, -- Ignore currency when previous user action is "Insert"  
          CAST(scurrency1.currency_id AS NVARCHAR(100)),  
          CAST(scurrency2.currency_id AS NVARCHAR(100))  
        
         UNION ALL  
         SELECT    N''Source System Name'',  
          CAST(sdha1.source_system_id AS NVARCHAR(250)),  
          CAST(sdha2.source_system_id AS NVARCHAR(250)),  
          CAST(sdha1.source_system_id AS NVARCHAR(250)),  
          CAST(sdha2.source_system_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Deal Date'',  
          CAST(sdha1.deal_date AS NVARCHAR(250)),  
          CAST(sdha2.deal_date AS NVARCHAR(250)),  
          CONVERT(VARCHAR(10),sdha1.deal_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdha2.deal_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''External Deal ID'',  
          CAST(sdha1.ext_deal_id AS NVARCHAR(250)),  
          CAST(sdha2.ext_deal_id AS NVARCHAR(250)),  
          CAST(sdha1.ext_deal_id AS NVARCHAR(250)),  
          CAST(sdha2.ext_deal_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Physical/Financial'',  
          CAST(sdha1.physical_financial_flag AS NVARCHAR(250)),  
          CAST(sdha2.physical_financial_flag AS NVARCHAR(250)),  
          CAST(phy_fin_h1.[value] AS NVARCHAR(250)),  
          CAST(phy_fin_h2.[value] AS NVARCHAR(250))
         UNION ALL  
         SELECT    N''Structured Deal'',  
          CAST(sdha1.structured_deal_id AS NVARCHAR(250)),  
          CAST(sdha2.structured_deal_id AS NVARCHAR(250)),  
          CAST(sdha1.structured_deal_id AS NVARCHAR(250)),  
          CAST(sdha2.structured_deal_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Counterparty'',  
          CAST(sdha1.counterparty_id AS NVARCHAR(250)),  
          CAST(sdha2.counterparty_id AS NVARCHAR(250)),  
          CAST(sc1.counterparty_name AS NVARCHAR(250)),  
          CAST(sc2.counterparty_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Entire Term Start'',  
          CAST(sdha1.entire_term_start AS NVARCHAR(250)),  
          CAST(sdha2.entire_term_start AS NVARCHAR(250)),  
          CONVERT(VARCHAR(10),sdha1.entire_term_start,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdha2.entire_term_start,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Entire Term End'',  
          CAST(sdha1.entire_term_end AS NVARCHAR(250)),  
          CAST(sdha2.entire_term_end AS NVARCHAR(250)),  
          CONVERT(VARCHAR(10),sdha1.entire_term_end,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdha2.entire_term_end,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
        
         UNION ALL  
         SELECT    N''Source Deal Type'',  
          CAST(sdha1.source_deal_type_id AS NVARCHAR(250)),  
          CAST(sdha2.source_deal_type_id AS NVARCHAR(250)),  
          CAST(sdtype1.deal_type_id AS NVARCHAR(250)),  
          CAST(sdtype2.deal_type_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Deal Sub Type'',  
          CAST(sdha1.deal_sub_type_type_id AS NVARCHAR(250)),  
          CAST(sdha2.deal_sub_type_type_id AS NVARCHAR(250)),  
          CAST(sdsubtype1.deal_type_id AS NVARCHAR(250)),  
          CAST(sdsubtype2.deal_type_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Option Flag'',  
          CAST(sdha1.option_flag AS NVARCHAR(250)),  
          CAST(sdha2.option_flag AS NVARCHAR(250)),  
          CAST(option_flag_h1.[value] AS NVARCHAR(250)),  
          CAST(option_flag_h2.[value] AS NVARCHAR(250))'
        
        SET @sql_select1_sub1 = '
         UNION ALL  
         SELECT    N''Option Type'',  
          CAST(sdha1.option_type AS NVARCHAR(250)),  
          CAST(sdha2.option_type AS NVARCHAR(250)),  
          CAST(option_type_h1.[value] AS NVARCHAR(250)),  
          CAST(option_type_h2.[value] AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Option Excercise Type'',  
          CAST(sdha1.option_excercise_type AS NVARCHAR(250)),  
          CAST(sdha2.option_excercise_type AS NVARCHAR(250)),  
          CAST(option_ex_h1.[value] AS NVARCHAR(250)),  
          CAST(option_ex_h2.[value] AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Option Settlement Date'',  
          CAST(dbo.FNADateFormat(sdha1.option_settlement_date) AS NVARCHAR(250)),  
          CAST(dbo.FNADateFormat(sdha2.option_settlement_date) AS NVARCHAR(250)),  
          CAST(dbo.FNADateFormat(sdha1.option_settlement_date) AS NVARCHAR(250)),  
          CAST(dbo.FNADateFormat(sdha2.option_settlement_date) AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Source System Book Id1'',  
          CAST(sdha1.source_system_book_id1 AS NVARCHAR(250)),  
          CAST(sdha2.source_system_book_id1 AS NVARCHAR(250)),  
          CASE WHEN sb1_1.source_system_book_id=''-1'' THEN ''None'' ELSE CAST(sb1_1.source_system_book_id AS NVARCHAR(250)) END,  
          CASE WHEN sb1_2.source_system_book_id=''-1'' THEN ''NONE'' ELSE CAST(sb1_2.source_system_book_id AS NVARCHAR(250)) END  
         UNION ALL  
         SELECT    N''Source System Book Id2'',  
          CAST(sdha1.source_system_book_id2 AS NVARCHAR(250)),  
          CAST(sdha2.source_system_book_id2 AS NVARCHAR(250)),  
          CASE WHEN sb2_1.source_system_book_id=''-2'' THEN ''None'' ELSE CAST(sb2_1.source_system_book_id AS NVARCHAR(250)) END,  
          CASE WHEN sb2_2.source_system_book_id=''-2'' THEN ''NONE'' ELSE CAST(sb2_2.source_system_book_id AS NVARCHAR(250)) END  
         UNION ALL  
         SELECT    N''Source System Book Id3'',  
          CAST(sdha1.source_system_book_id3 AS NVARCHAR(250)),  
          CAST(sdha2.source_system_book_id3 AS NVARCHAR(250)),  
          CASE WHEN sb3_1.source_system_book_id=''-3'' THEN ''None'' ELSE CAST(sb3_1.source_system_book_id AS NVARCHAR(250)) END,  
          CASE WHEN sb3_2.source_system_book_id=''-3'' THEN ''NONE'' ELSE CAST(sb3_2.source_system_book_id AS NVARCHAR(250)) END  
         UNION ALL  
         SELECT    N''Source System Book Id4'',  
          CAST(sdha1.source_system_book_id4 AS NVARCHAR(250)),  
          CAST(sdha2.source_system_book_id4 AS NVARCHAR(250)),  
          CASE WHEN sb4_1.source_system_book_id=''-4'' THEN ''None'' ELSE CAST(sb4_1.source_system_book_id AS NVARCHAR(250)) END,  
          CASE WHEN sb4_2.source_system_book_id=''-4'' THEN ''NONE'' ELSE CAST(sb4_2.source_system_book_id AS NVARCHAR(250)) END  
        
         UNION ALL  
         SELECT    N''Description1'',  
          CAST(sdha1.description1 AS NVARCHAR(250)),  
          CAST(sdha2.description1 AS NVARCHAR(250)),  
          CAST(sdha1.description1 AS NVARCHAR(250)),  
          CAST(sdha2.description1 AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Description2'',  
          CAST(sdha1.description2 AS NVARCHAR(250)),  
          CAST(sdha2.description2 AS NVARCHAR(250)),  
          CAST(sdha1.description2 AS NVARCHAR(250)),  
          CAST(sdha2.description2 AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Description3'',  
          CAST(sdha1.description3 AS NVARCHAR(250)),  
          CAST(sdha2.description3 AS NVARCHAR(250)),  
          CAST(sdha1.description3 AS NVARCHAR(250)),  
          CAST(sdha2.description3 AS NVARCHAR(250))  
         
         UNION ALL  
         SELECT    N''Deal Category Name'',  
          CAST(sdha1.deal_category_value_id AS NVARCHAR(250)),  
          CAST(sdha2.deal_category_value_id AS NVARCHAR(250)),  
          CAST(sdvdealcat1.code AS NVARCHAR(250)),  
          CAST(sdvdealcat2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Trader'',  
          CAST(sdha1.trader_id AS NVARCHAR(250)),  
          CAST(sdha2.trader_id AS NVARCHAR(250)),  
          CAST(straders1.trader_name AS NVARCHAR(250)),  
          CAST(straders2.trader_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Internal Deal type'',  
          CAST(sdha1.internal_deal_type_value_id AS NVARCHAR(250)),  
          CAST(sdha2.internal_deal_type_value_id AS NVARCHAR(250)),  
          CAST(int_deal_type_h1.internal_deal_type_subtype_type AS NVARCHAR(250)),  
          CAST(int_deal_type_h2.internal_deal_type_subtype_type AS NVARCHAR(250))  
          
         UNION ALL  
         SELECT    N''Internal Deal Subtype'',  
          CAST(sdha1.internal_deal_subtype_value_id AS NVARCHAR(250)),  
          CAST(sdha2.internal_deal_subtype_value_id AS NVARCHAR(250)),  
          CAST(int_deal_subtype_h1.internal_deal_type_subtype_type AS NVARCHAR(250)),  
          CAST(int_deal_subtype_h2.internal_deal_type_subtype_type AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Template'',  
          CAST(sdha1.template_id AS NVARCHAR(250)),  
          CAST(sdha2.template_id AS NVARCHAR(250)),  
          CAST(template_h1.template_name AS NVARCHAR(250)),  
          CAST(template_h2.template_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Buy/Sell'',  
          CAST(sdha1.header_buy_sell_flag AS NVARCHAR(250)),  
          CAST(sdha2.header_buy_sell_flag AS NVARCHAR(250)),  
          CAST(buy_sell_h1.[value] AS NVARCHAR(250)),  
          CAST(buy_sell_h2.[value] AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Broker'',  
          CAST(sdha1.broker_id AS NVARCHAR(250)),  
          CAST(sdha2.broker_id AS NVARCHAR(250)),  
          CAST(sc_broker1.counterparty_name AS NVARCHAR(250)),  
          CAST(sc_broker2.counterparty_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Generator Name'',  
          CAST(sdha1.generator_id AS NVARCHAR(250)),  
          CAST(sdha2.generator_id AS NVARCHAR(250)),  
          CAST(rg1.code AS NVARCHAR(250)),  
          CAST(rg2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Status Value'',  
          CAST(sdha1.status_value_id AS NVARCHAR(250)),  
          CAST(sdha2.status_value_id AS NVARCHAR(250)),  
          CAST(sdha1.status_value_id AS NVARCHAR(250)),  
          CAST(sdha2.status_value_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Status Date'',  
          CAST(sdha1.status_date AS NVARCHAR(250)),  
          CAST(sdha2.status_date AS NVARCHAR(250)),  
          CONVERT(VARCHAR(10),sdha1.status_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdha2.status_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Assignment Type Value'',  
          CAST(sdha1.assignment_type_value_id AS NVARCHAR(250)),  
          CAST(sdha2.assignment_type_value_id AS NVARCHAR(250)),  
          CAST(sdha1.assignment_type_value_id AS NVARCHAR(250)),  
          CAST(sdha2.assignment_type_value_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Compliance Year'',  
          CAST(sdha1.compliance_year AS NVARCHAR(250)),  
          CAST(sdha2.compliance_year AS NVARCHAR(250)),  
          CAST(sdha1.compliance_year AS NVARCHAR(250)),  
          CAST(sdha2.compliance_year AS NVARCHAR(250))  
         '
         SET @sql_select1_sub2 = '
         UNION ALL  
         SELECT    N''State Value'',  
          CAST(sdha1.state_value_id AS NVARCHAR(250)),  
          CAST(sdha2.state_value_id AS NVARCHAR(250)),  
          CAST(sdha1.state_value_id AS NVARCHAR(250)),  
          CAST(sdha2.state_value_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Assigned Date'',  
          CAST(sdha1.assigned_date AS NVARCHAR(250)),  
          CAST(sdha2.assigned_date AS NVARCHAR(250)),  
          CONVERT(VARCHAR(10),sdha1.assigned_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdha2.assigned_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Assigned By'',  
          CAST(sdha1.assigned_by AS NVARCHAR(250)),  
          CAST(sdha2.assigned_by AS NVARCHAR(250)),  
          CAST(sdha1.assigned_by AS NVARCHAR(250)),  
          CAST(sdha2.assigned_by AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Generation Source'',  
          CAST(sdha1.generation_source AS NVARCHAR(250)),  
          CAST(sdha2.generation_source AS NVARCHAR(250)),  
          CAST(sdha1.generation_source AS NVARCHAR(250)),  
          CAST(sdha2.generation_source AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Aggregate Environment'',  
          CAST(ISNULL(sdha1.aggregate_environment,''n'') AS NVARCHAR(250)),  
          CAST(ISNULL(sdha2.aggregate_environment, ''n'') AS NVARCHAR(250)),  
          CAST(agg_env_h1.[value] AS NVARCHAR(250)),  
          CAST(agg_env_h2.[value] AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Aggregate Envrionment Comment'',  
          CAST(sdha1.aggregate_envrionment_comment AS NVARCHAR(250)),  
          CAST(sdha2.aggregate_envrionment_comment AS NVARCHAR(250)),  
          CAST(sdha1.aggregate_envrionment_comment AS NVARCHAR(250)),  
          CAST(sdha2.aggregate_envrionment_comment AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Rec Price'',  
          CAST(ISNULL(sdha1.rec_price,''0'') AS NVARCHAR(250)),  
          CAST(ISNULL(sdha2.rec_price,''0'') AS NVARCHAR(250)),  
          CAST(ISNULL(sdha1.rec_price,''0'') AS NVARCHAR(250)),  
          CAST(ISNULL(sdha2.rec_price,''0'') AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Rec Formula Id'',  
          CAST(sdha1.rec_formula_id AS NVARCHAR(250)),  
          CAST(sdha2.rec_formula_id AS NVARCHAR(250)),  
          CAST(sdha1.rec_formula_id AS NVARCHAR(250)),  
          CAST(sdha2.rec_formula_id AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Rolling Avg'',  
          CAST(sdha1.rolling_avg AS NVARCHAR(250)),  
          CAST(sdha2.rolling_avg AS NVARCHAR(250)),  
          CAST(rolling_avg_h1.[value] AS NVARCHAR(250)),  
          CAST(rolling_avg_h2.[value] AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Contract Name'',  
          CAST(sdha1.contract_id AS NVARCHAR(250)),  
          CAST(sdha2.contract_id AS NVARCHAR(250)),  
          CAST(cg1.contract_name AS NVARCHAR(250)),  
          CAST(cg2.contract_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Legal Entity'',  
          CAST(sdha1.legal_entity AS NVARCHAR(250)),  
          CAST(sdha2.legal_entity AS NVARCHAR(250)),  
          CAST(sle_legal1.legal_entity_name AS NVARCHAR(250)),  
          CAST(sle_legal2.legal_entity_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Profile'',  
          CAST(sdha1.internal_desk_id AS NVARCHAR(250)),  
          CAST(sdha2.internal_desk_id AS NVARCHAR(250)),  
          CAST(sid_desk1.code AS NVARCHAR(250)),  
          CAST(sid_desk2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Fixation'',  
          CAST(sdha1.product_id AS NVARCHAR(250)),  
          CAST(sdha2.product_id AS NVARCHAR(250)),  
          CAST(sp_product1.code AS NVARCHAR(250)),  
          CAST(sp_product2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Internal Portfolio'',  
          CAST(sdha1.internal_portfolio_id AS NVARCHAR(250)),  
          CAST(sdha2.internal_portfolio_id AS NVARCHAR(250)),  
          CAST(sip_portfolio1.code AS NVARCHAR(250)),  
          CAST(sip_portfolio2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Commodity'',  
          CAST(sdha1.commodity_id AS NVARCHAR(250)),  
          CAST(sdha2.commodity_id AS NVARCHAR(250)),  
          CAST(sc_commodity1.commodity_name AS NVARCHAR(250)),  
          CAST(sc_commodity2.commodity_name AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Reference'',  
          CAST(sdha1.reference AS NVARCHAR(250)),  
          CAST(sdha2.reference AS NVARCHAR(250)),  
          CAST(sdha1.reference AS NVARCHAR(250)),  
          CAST(sdha2.reference AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Deal Locked'',  
          CAST(ISNULL(sdha1.deal_locked, ''n'') AS NVARCHAR(250)),  
          CAST(ISNULL(sdha2.deal_locked, ''n'') AS NVARCHAR(250)),            
          
          CASE WHEN ISNULL(sdha1.deal_locked, ''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END,
          CASE WHEN ISNULL(sdha2.deal_locked, ''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END
          
         UNION ALL  
          SELECT    N''Close Reference Deal Id'',  
          CAST(sdha1.close_reference_id AS NVARCHAR(250)),  
          CAST(sdha2.close_reference_id AS NVARCHAR(250)),  
          CAST(sdh_close1.deal_id AS NVARCHAR(250)),  
          CAST(sdh_close2.deal_id AS NVARCHAR(250))   
         UNION ALL  
         SELECT    N''Block Definition'',  
          CAST(sdha1.block_define_id AS NVARCHAR(250)),  
          CAST(sdha2.block_define_id AS NVARCHAR(250)),  
          CAST(sdv_block_define1.code AS NVARCHAR(250)),  
          CAST(sdv_block_define2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Granularity'',  
          CAST(sdha1.granularity_id AS NVARCHAR(250)),  
          CAST(sdha2.granularity_id AS NVARCHAR(250)),  
          CAST(sdv_granularity1.code AS NVARCHAR(250)),  
          CAST(sdv_granularity2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Pricing'',  
          CAST(sdha1.pricing AS NVARCHAR(250)),  
          CAST(sdha2.pricing AS NVARCHAR(250)),  
          CAST(sdv_pricing1.code AS NVARCHAR(250)),  
          CAST(sdv_pricing2.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Verified By'',  
          CAST(sdha1.verified_by AS NVARCHAR(250)),  
          CAST(sdha2.verified_by AS NVARCHAR(250)),  
          CAST(sdha1.verified_by AS NVARCHAR(250)),  
          CAST(sdha2.verified_by AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''Verified Date'',  
          CAST(sdha1.verified_date AS NVARCHAR(250)),  
          CAST(sdha2.verified_date AS NVARCHAR(250)),  
          CONVERT(VARCHAR(10),sdha1.verified_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdha2.verified_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Deal Status'',  
          CAST(sdha1.deal_status AS NVARCHAR(250)),  
          CAST(sdha2.deal_status AS NVARCHAR(250)),  
          CAST(sdv_ds1.code AS NVARCHAR(250)),  
          CAST(sdv_ds2.code AS NVARCHAR(250))     
         UNION ALL  
         SELECT    N''Confirm Status'',  
          CAST(sdha1.confirm_status_type AS NVARCHAR(250)),  
          CAST(sdha2.confirm_status_type AS NVARCHAR(250)),  
          CAST(sdv_cs1.code AS NVARCHAR(250)),  
          CAST(sdv_cs2.code AS NVARCHAR(250))    
          '      
        SET @sql_select1_sub3 = '
        UNION ALL  
         SELECT    N''Counterparty2'',  
          CAST(sdha1.counterparty_id2 AS NVARCHAR(250)),  
          CAST(sdha2.counterparty_id2 AS NVARCHAR(250)),  
          CAST(sc_1.counterparty_name AS NVARCHAR(250)),  
          CAST(sc_2.counterparty_name AS NVARCHAR(250)) 
        UNION ALL 
        SELECT    N''Trader2'',  
          CAST(sdha1.trader_id2 AS NVARCHAR(250)),  
          CAST(sdha2.trader_id2 AS NVARCHAR(250)),  
          CAST(straders_1.trader_name AS NVARCHAR(250)),  
          CAST(straders_2.trader_name AS NVARCHAR(250))
		  
		  UNION ALL 
        SELECT    N''INCOTerm'',  
          CAST(sdha1.inco_terms AS NVARCHAR(250)),  
          CAST(sdha2.inco_terms AS NVARCHAR(250)),  
          CAST(sdvit1.code AS NVARCHAR(250)),  
          CAST(sdvit2.code AS NVARCHAR(250)) 

		  UNION ALL 
        SELECT    N''Payment Term'',  
          CAST(sdha1.payment_term AS NVARCHAR(250)),  
          CAST(sdha2.payment_term AS NVARCHAR(250)),  
          CAST(sdvpat1.code AS NVARCHAR(250)),  
          CAST(sdvpat2.code AS NVARCHAR(250)) 

		   UNION ALL 
        SELECT    N''Governing Law'',  
          CAST(sdha1.governing_law AS NVARCHAR(250)),  
          CAST(sdha2.governing_law AS NVARCHAR(250)),  
          CAST(sdvgl1.code AS NVARCHAR(250)),  
          CAST(sdvgl2.code AS NVARCHAR(250)) 

		   UNION ALL 
        SELECT    N''Arbitration'',  
          CAST(sdha1.arbitration AS NVARCHAR(250)),  
          CAST(sdha2.arbitration AS NVARCHAR(250)),  
          CAST(sdvab1.code AS NVARCHAR(250)),  
          CAST(sdvab2.code AS NVARCHAR(250)) 

		  UNION ALL 
        SELECT    N''Underlying Options'',  
          CAST(sdha1.underlying_options AS NVARCHAR(250)),  
          CAST(sdha2.underlying_options AS NVARCHAR(250)),  
          CAST(sdvuo1.code AS NVARCHAR(250)),  
          CAST(sdvuo2.code AS NVARCHAR(250)) 
         
		 UNION ALL 
        SELECT    N''Pricing Type'',  
          CAST(sdha1.pricing_type AS NVARCHAR(250)),  
          CAST(sdha2.pricing_type AS NVARCHAR(250)),  
          CAST(sdvhpt1.code AS NVARCHAR(250)),  
          CAST(sdvhpt2.code AS NVARCHAR(250)) 

		  UNION ALL 
        SELECT    N''Confirmation Type'',  
          CAST(sdha1.confirmation_type AS NVARCHAR(250)),  
          CAST(sdha2.confirmation_type AS NVARCHAR(250)),  
          CAST(sdvct1.code AS NVARCHAR(250)),  
          CAST(sdvct2.code AS NVARCHAR(250)) 
        
		 UNION ALL 
        SELECT    N''Holiday Calendar'',  
          CAST(sdha1.holiday_calendar AS NVARCHAR(250)),  
          CAST(sdha2.holiday_calendar AS NVARCHAR(250)),  
          CAST(sdvhl1.code AS NVARCHAR(250)),  
          CAST(sdvhl2.code AS NVARCHAR(250))

		  UNION ALL 
        SELECT    N''FX Conversion Market'',  
          CAST(sdha1.fx_conversion_market AS NVARCHAR(250)),  
          CAST(sdha2.fx_conversion_market AS NVARCHAR(250)),  
          CAST(sdvfcm1.code AS NVARCHAR(250)),  
          CAST(sdvfcm2.code AS NVARCHAR(250))

		  UNION ALL 
        SELECT    N''Tier'',  
          CAST(sdha1.tier_value_id AS NVARCHAR(250)),  
          CAST(sdha2.tier_value_id AS NVARCHAR(250)),  
          CAST(sdvtvi1.code AS NVARCHAR(250)),  
          CAST(sdvtvi2.code AS NVARCHAR(250))

		   UNION ALL  
         SELECT    N''Payment Days'',  
          CAST(sdha1.payment_days AS VARCHAR(100)),  
          CAST(sdha2.payment_days AS VARCHAR(100)),  
          CAST(sdha1.payment_days AS VARCHAR(100)),  
          CAST(sdha2.payment_days AS VARCHAR(100)) 

		  UNION ALL  
         SELECT    N''Collateral Months'',  
          CAST(sdha1.collateral_months AS VARCHAR(100)),  
          CAST(sdha2.collateral_months AS VARCHAR(100)),  
          CAST(sdha1.collateral_months AS VARCHAR(100)),  
          CAST(sdha2.collateral_months AS VARCHAR(100)) 

		   UNION ALL  
         SELECT    N''Collateral Months'',  
          CAST(sdha1.collateral_months AS VARCHAR(100)),  
          CAST(sdha2.collateral_months AS VARCHAR(100)),  
          CAST(sdha1.collateral_months AS VARCHAR(100)),  
          CAST(sdha2.collateral_months AS VARCHAR(100)) 

		  UNION ALL  
         SELECT    N''Collateral Amount'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha1.collateral_amount),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha2.collateral_amount),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha1.collateral_amount),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha2.collateral_amount),''n'') 

		  UNION ALL  
         SELECT    N''Collateral Req%'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha1.collateral_req_per),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha2.collateral_req_per),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha1.collateral_req_per),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdha2.collateral_req_per),''n'')

		   UNION ALL 
        SELECT    N''Reporting Group1'',  
          CAST(sdha1.reporting_group1 AS NVARCHAR(250)),  
          CAST(sdha2.reporting_group1 AS NVARCHAR(250)),  
          CAST(rp1_sdv1.code AS NVARCHAR(250)),  
          CAST(rp1_sdv2.code AS NVARCHAR(250))

		   UNION ALL 
        SELECT    N''Reporting Group2'',  
          CAST(sdha1.reporting_group2 AS NVARCHAR(250)),  
          CAST(sdha2.reporting_group2 AS NVARCHAR(250)),  
          CAST(rp2_sdv1.code AS NVARCHAR(250)),  
          CAST(rp2_sdv2.code AS NVARCHAR(250))

		   UNION ALL 
        SELECT    N''Reporting Group3'',  
          CAST(sdha1.reporting_group3 AS NVARCHAR(250)),  
          CAST(sdha2.reporting_group3 AS NVARCHAR(250)),  
          CAST(rp3_sdv1.code AS NVARCHAR(250)),  
          CAST(rp3_sdv2.code AS NVARCHAR(250))

		   UNION ALL 
        SELECT    N''Reporting Group4'',  
          CAST(sdha1.reporting_group4 AS NVARCHAR(250)),  
          CAST(sdha2.reporting_group4 AS NVARCHAR(250)),  
          CAST(rp5_sdv1.code AS NVARCHAR(250)),  
          CAST(rp5_sdv2.code AS NVARCHAR(250))

		   UNION ALL 
        SELECT    N''Reporting Group5'',  
          CAST(sdha1.reporting_group5 AS NVARCHAR(250)),  
          CAST(sdha2.reporting_group5 AS NVARCHAR(250)),  
          CAST(rp5_sdv1.code AS NVARCHAR(250)),  
          CAST(rp5_sdv2.code AS NVARCHAR(250))

		  
       ) Q ( Field, [CURRENT Id], [PRIOR Id], [CURRENT VALUE],  
          [PRIOR VALUE])  
  WHERE   ISNULL([CURRENT Id], -1) <> ISNULL([PRIOR Id], -1)
  '  
  
 SET @sql_select2 = ' 
  UNION  
  
  --Detail  
  SELECT  sdda1.source_deal_header_id [Deal ID],  
    sdha1.deal_id [REF ID],  
    dbo.FNADateFormat(sdda1.term_start) [Term START],  
    sdda1.leg [Leg],  
   ''Detail'' [Header Detail],
    Field,  
    [PRIOR VALUE],  
    [CURRENT VALUE],  
    sdda1.update_ts [UPDATE TS],  
    dbo.FNAGetUserName(sdda1.update_user) [UPDATE USER], 
	sdda1.user_action [User Action] 
  FROM    #deals deals  
    INNER JOIN source_deal_header_audit sdha1 ON sdha1.audit_id = deals.audit_id1  
    INNER JOIN ' + @source_deal_detail_audit + ' sdda1 ON deals.audit_id1 = sdda1.header_audit_id  
    INNER JOIN ' + @source_deal_detail_audit + ' sdda2 ON deals.audit_id2 = sdda2.header_audit_id  
               AND sdda1.source_deal_detail_id = sdda2.source_deal_detail_id  
    --formula_id : formula_editor (formula_id)  
    LEFT JOIN formula_editor fe1 ON fe1.formula_id = sdda1.formula_id  
    LEFT JOIN formula_editor fe2 ON fe2.formula_id = sdda2.formula_id   
  
    --fixed_price_currency_id : source_currency (source_currency_id)  
    LEFT JOIN source_currency scurrency1 ON scurrency1.source_currency_id = sdda1.fixed_price_currency_id  
    LEFT JOIN source_currency scurrency2 ON scurrency2.source_currency_id = sdda2.fixed_price_currency_id  
  
    --curve_id : source_price_curve_def (source_curve_def_id)  
    LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = sdda1.curve_id  
    LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = sdda2.curve_id  
  
    --deal_volume_uom_id : source_uom (source_uom_id)  
    LEFT JOIN source_uom suom1 ON suom1.source_uom_id = sdda1.deal_volume_uom_id  
    LEFT JOIN source_uom suom2 ON suom2.source_uom_id = sdda2.deal_volume_uom_id  
  
    --day_count_id : static_data_value (value_id)  
    LEFT JOIN static_data_value sdvday1 ON sdvday1.value_id = sdda1.day_count_id  
    LEFT JOIN static_data_value sdvday2 ON sdvday2.value_id = sdda2.day_count_id  
      
    --location  
    LEFT JOIN source_minor_location sml1 ON sdda1.location_id = sml1.source_minor_location_id  
    LEFT JOIN source_minor_location sml2 ON sdda2.location_id = sml2.source_minor_location_id    
      
    --meter   
    LEFT JOIN source_minor_location_meter smlm1 ON sdda1.meter_id = smlm1.meter_id  
    LEFT JOIN source_minor_location_meter smlm2 ON sdda2.meter_id = smlm2.meter_id  
    LEFT JOIN meter_id mi1 ON smlm1.meter_id = mi1.meter_id  
    LEFT JOIN meter_id mi2 ON smlm2.meter_id = mi2.meter_id  
  
    --char types  
    --fixed_float_leg  
    LEFT JOIN #codevalue fixed_float_d1 ON fixed_float_d1.Fieldtype=''fixed_float_leg'' AND fixed_float_d1.code=sdda1.fixed_float_leg   
    LEFT JOIN #codevalue fixed_float_d2 ON fixed_float_d2.Fieldtype=''fixed_float_leg'' AND fixed_float_d2.code=sdda2.fixed_float_leg
    --buy_sell_flag  
    LEFT JOIN #codevalue buy_sell_d1 ON buy_sell_d1.Fieldtype=''buy_sell'' AND buy_sell_d1.code=sdda1.buy_sell_flag   
    LEFT JOIN #codevalue buy_sell_d2 ON buy_sell_d2.Fieldtype=''buy_sell'' AND buy_sell_d2.code=sdda2.buy_sell_flag  
  
    --deal_volume_frequency   
    LEFT JOIN #codevalue vol_freq_d1 ON vol_freq_d1.Fieldtype=''frequency'' AND vol_freq_d1.code=sdda1.deal_volume_frequency   
    LEFT JOIN #codevalue vol_freq_d2 ON vol_freq_d2.Fieldtype=''frequency'' AND vol_freq_d2.code=sdda2.deal_volume_frequency  
  
    --physical_financial_flag  
    LEFT JOIN #codevalue phy_fin_d1 ON phy_fin_d1.Fieldtype=''physical_financial'' AND phy_fin_d1.code=sdda1.physical_financial_flag   
    LEFT JOIN #codevalue phy_fin_d2 ON phy_fin_d2.Fieldtype=''physical_financial'' AND phy_fin_d2.code=sdda2.physical_financial_flag  
  
    --Booked  
    LEFT JOIN #codevalue booked_d1 ON booked_d1.Fieldtype=''yes_no'' AND booked_d1.code=sdda1.Booked   
    LEFT JOIN #codevalue booked_d2 ON booked_d2.Fieldtype=''yes_no'' AND booked_d2.code=sdda2.Booked  
  
    -- Currency      
    LEFT JOIN source_currency price_adder_currency1_1 ON price_adder_currency1_1.source_currency_id = sdda1.adder_currency_id  
    LEFT JOIN source_currency price_adder_currency1_2 ON price_adder_currency1_2.source_currency_id = sdda2.adder_currency_id  
  
    LEFT JOIN source_currency price_adder_currency2_1 ON price_adder_currency2_1.source_currency_id = sdda1.price_adder_currency2  
    LEFT JOIN source_currency price_adder_currency2_2 ON price_adder_currency2_2.source_currency_id = sdda2.price_adder_currency2  
  
    LEFT JOIN source_currency formula_currency1 ON formula_currency1.source_currency_id = sdda1.formula_currency_id  
    LEFT JOIN source_currency formula_currency2 ON formula_currency2.source_currency_id = sdda2.formula_currency_id  
  
    LEFT JOIN source_currency fixed_cost_currency1 ON fixed_cost_currency1.source_currency_id = sdda1.fixed_cost_currency_id  
    LEFT JOIN source_currency fixed_cost_currency2 ON fixed_cost_currency2.source_currency_id = sdda2.fixed_cost_currency_id  
      
    -- Category
    LEFT JOIN static_data_value sdv1 ON sdv1.value_id = sdda1.category  
    LEFT JOIN static_data_value sdv2 ON sdv2.value_id = sdda2.category
    
    -- Price UOM
    LEFT JOIN source_uom su1 ON su1.source_uom_id = sdda1.price_uom_id  
    LEFT JOIN source_uom su2 ON su2.source_uom_id = sdda2.price_uom_id
    
    -- Profile
    LEFT JOIN static_data_value sdv3 ON sdv3.value_id = sdda1.profile_code  
    LEFT JOIN static_data_value sdv4 ON sdv4.value_id = sdda2.profile_code 
    
    -- PV Party
    LEFT JOIN static_data_value sdv5 ON sdv5.value_id = sdda1.pv_party  
    LEFT JOIN static_data_value sdv6 ON sdv6.value_id = sdda2.pv_party
    
    -- Settlement Currency
    LEFT JOIN  source_currency scur1 ON scur1.source_currency_id = sdda1.settlement_currency
    LEFT JOIN  source_currency scur2 ON scur2.source_currency_id = sdda2.settlement_currency
    
    -- status
    LEFT JOIN static_data_value sdv_status_p ON sdv_status_p.value_id = sdda1.status  
    LEFT JOIN static_data_value sdv_status_f ON sdv_status_f.value_id = sdda2.status 
    
    -- lock_deal_detail
    LEFT JOIN #codevalue lock_deal_detail_p ON lock_deal_detail_p.code = sdda1.lock_deal_detail  
    LEFT JOIN #codevalue lock_deal_detail_f ON lock_deal_detail_f.code = sdda2.lock_deal_detail 
    
    -- detail_commodity_id
    LEFT JOIN source_commodity dsco1 ON dsco1.source_commodity_id = sdda1.detail_commodity_id
    LEFT JOIN source_commodity dsco2 ON dsco2.source_commodity_id = sdda2.detail_commodity_id
    
    -- Origin
    LEFT JOIN commodity_origin co1 ON co1.commodity_origin_id = sdda1.origin
    LEFT JOIN static_data_value sdv_origin1 ON sdv_origin1.value_id = co1.origin    
    LEFT JOIN commodity_origin co2 ON co2.commodity_origin_id = sdda2.origin
    LEFT JOIN static_data_value sdv_origin2 ON sdv_origin2.value_id = co2.origin
    
    -- Form
    LEFT JOIN commodity_form cof1 ON cof1.commodity_form_id = sdda1.[form]
    LEFT JOIN commodity_type_form ctf1 ON ctf1.commodity_type_form_id = cof1.[form]
    LEFT JOIN commodity_form cof2 ON cof2.commodity_form_id = sdda2.[form]
    LEFT JOIN commodity_type_form ctf2 ON ctf2.commodity_type_form_id = cof2.[form]
    
    -- organic
    LEFT JOIN #codevalue organic1 ON organic1.Fieldtype=''yes_no'' AND organic1.code=sdda1.organic   
    LEFT JOIN #codevalue organic2 ON organic2.Fieldtype=''yes_no'' AND organic2.code=sdda2.organic 
    
    -- attribute1
    LEFT JOIN commodity_form_attribute1 att1_1 ON att1_1.commodity_form_attribute1_id = sdda1.attribute1
    LEFT JOIN commodity_attribute_form caf1_1 on caf1_1.commodity_attribute_form_id = att1_1.attribute_form_id    
    LEFT JOIN commodity_form_attribute1 att1_2 ON att1_2.commodity_form_attribute1_id = sdda2.attribute1
    LEFT JOIN commodity_attribute_form caf1_2 on caf1_2.commodity_attribute_form_id = att1_2.attribute_form_id
    
    

	'
	
	SET @sql_select2_1 = '
	-- attribute2
    LEFT JOIN commodity_form_attribute2 att2_1 ON att2_1.commodity_form_attribute2_id = sdda1.attribute2
    LEFT JOIN commodity_attribute_form caf2_1 on caf2_1.commodity_attribute_form_id = att2_1.attribute_form_id    
    LEFT JOIN commodity_form_attribute2 att2_2 ON att2_2.commodity_form_attribute2_id = sdda2.attribute2
    LEFT JOIN commodity_attribute_form caf2_2 on caf2_2.commodity_attribute_form_id = att2_2.attribute_form_id
    
    -- attribute3
    LEFT JOIN commodity_form_attribute3 att3_1 ON att3_1.commodity_form_attribute3_id = sdda1.attribute3
    LEFT JOIN commodity_attribute_form caf3_1 on caf3_1.commodity_attribute_form_id = att3_1.attribute_form_id    
    LEFT JOIN commodity_form_attribute3 att3_2 ON att3_2.commodity_form_attribute3_id = sdda2.attribute3
    LEFT JOIN commodity_attribute_form caf3_2 on caf3_2.commodity_attribute_form_id = att3_2.attribute_form_id
	
	-- attribute4
    LEFT JOIN commodity_form_attribute4 att4_1 ON att4_1.commodity_form_attribute4_id = sdda1.attribute4
    LEFT JOIN commodity_attribute_form caf4_1 on caf4_1.commodity_attribute_form_id = att4_1.attribute_form_id    
    LEFT JOIN commodity_form_attribute4 att4_2 ON att4_2.commodity_form_attribute4_id = sdda2.attribute4
    LEFT JOIN commodity_attribute_form caf4_2 on caf4_2.commodity_attribute_form_id = att4_2.attribute_form_id
    
    -- attribute5
    LEFT JOIN commodity_form_attribute5 att5_1 ON att5_1.commodity_form_attribute5_id = sdda1.attribute5
    LEFT JOIN commodity_attribute_form caf5_1 on caf5_1.commodity_attribute_form_id = att5_1.attribute_form_id    
    LEFT JOIN commodity_form_attribute5 att5_2 ON att5_2.commodity_form_attribute5_id = sdda2.attribute5
    LEFT JOIN commodity_attribute_form caf5_2 on caf5_2.commodity_attribute_form_id = att5_2.attribute_form_id
    
    -- Position UOM
    LEFT JOIN source_uom pos_uom1 ON pos_uom1.source_uom_id = sdda1.position_uom  
    LEFT JOIN source_uom pos_uom2 ON pos_uom2.source_uom_id = sdda2.position_uom

	-- detail_inco_terms
    LEFT JOIN static_data_value sdvdit1 ON sdvdit1.value_id = sdda1.detail_inco_terms 
    LEFT JOIN static_data_value sdvdit2 ON sdvdit2.value_id = sdda2.detail_inco_terms 

	-- crop_year
    LEFT JOIN static_data_value sdvcy1 ON sdvcy1.value_id = sdda1.crop_year 
    LEFT JOIN static_data_value sdvcy2 ON sdvcy2.value_id = sdda2.crop_year 

	-- buyer_seller_option
    LEFT JOIN static_data_value sdvbso1 ON sdvbso1.value_id = sdda1.buyer_seller_option 
    LEFT JOIN static_data_value sdvbso2 ON sdvbso2.value_id = sdda2.buyer_seller_option
	
	-- strike_granularity
    LEFT JOIN static_data_value sdvsg1 ON sdvsg1.value_id = sdda1.strike_granularity 
    LEFT JOIN static_data_value sdvsg2 ON sdvsg2.value_id = sdda2.strike_granularity 

	-- profile_id
	LEFT JOIN forecast_profile fp1 ON fp1.profile_id = sdda1.profile_id 
	LEFT JOIN forecast_profile fp2 ON fp2.profile_id = sdda2.profile_id

	-- pricing_type2
    LEFT JOIN static_data_value sdvpt1 ON sdvpt1.value_id = sdda1.pricing_type2 
    LEFT JOIN static_data_value sdvpt2 ON sdvpt2.value_id = sdda2.pricing_type2 

	-- upstream_counterparty
	LEFT JOIN source_counterparty scuc1 ON scuc1.source_counterparty_id = sdda1.upstream_counterparty 
	LEFT JOIN source_counterparty scuc2 ON scuc2.source_counterparty_id = sdda2.upstream_counterparty

	-- cycle
	LEFT JOIN static_data_value sdvcyl1 ON sdvcyl1.value_id = sdda1.cycle 
    LEFT JOIN static_data_value sdvcyl2 ON sdvcyl2.value_id = sdda2.cycle 

    '
    
    SET @sql_select2_sub1 = ' 
    CROSS APPLY (   
         SELECT    N''Term Start'',  
          CAST(sdda1.term_start AS VARCHAR(100)),  
          CAST(sdda2.term_start AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.term_start,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.term_start,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Term End'',  
          CAST(sdda1.term_end AS VARCHAR(100)),  
          CAST(sdda2.term_end AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.term_end,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.term_end,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Contract Expiration Date'',  
          CAST(sdda1.contract_expiration_date AS VARCHAR(100)),  
          CAST(sdda2.contract_expiration_date AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.contract_expiration_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.contract_expiration_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
        
         UNION ALL  
         SELECT    N''Fixed Float Leg'',  
          CAST(sdda1.fixed_float_leg AS VARCHAR(100)),  
          CAST(sdda2.fixed_float_leg AS VARCHAR(100)),  
          CAST(fixed_float_d1.[value] AS VARCHAR(100)),  
          CAST(fixed_float_d2.[value] AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Buy/Sell'',  
          CAST(sdda1.buy_sell_flag AS VARCHAR(100)),  
          CAST(sdda2.buy_sell_flag AS VARCHAR(100)),  
          CAST(buy_sell_d1.[value] AS VARCHAR(100)),  
          CAST(buy_sell_d2.[value] AS VARCHAR(100))
         UNION ALL  
         SELECT    N''Curve ID'',  
          CAST(sdda1.curve_id AS VARCHAR(100)),  
          CAST(sdda2.curve_id AS VARCHAR(100)),  
          CAST(spcd1.curve_name AS VARCHAR(100)),  
          CAST(spcd2.curve_name AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Fixed Price'',  
          --CAST(sdda1.fixed_price AS VARCHAR(100)),  
          --CAST(sdda2.fixed_price AS VARCHAR(100)),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.fixed_price),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.fixed_price),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.fixed_price),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.fixed_price),''n'')  
         UNION ALL  
         SELECT    N''Fixed Price Currency'',  
          CAST(sdda1.fixed_price_currency_id AS VARCHAR(100)),  
          CAST(sdda2.fixed_price_currency_id AS VARCHAR(100)),  
          CAST(scurrency1.currency_id AS VARCHAR(100)),  
          CAST(scurrency2.currency_id AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Option Strike Price'',  
          CAST(sdda1.option_strike_price AS VARCHAR(100)),  
          CAST(sdda2.option_strike_price AS VARCHAR(100)),  
          CAST(sdda1.option_strike_price AS VARCHAR(100)),  
          CAST(sdda2.option_strike_price AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Deal Volume'',  
          --CAST(sdda1.deal_volume AS VARCHAR(100)),  
          --CAST(sdda2.deal_volume AS VARCHAR(100)),
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.deal_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.deal_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.deal_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.deal_volume),''n'')  
         UNION ALL  
         SELECT    N''Deal Volume Frequency'',  
          CAST(sdda1.deal_volume_frequency AS VARCHAR(100)),  
          CAST(sdda2.deal_volume_frequency AS VARCHAR(100)),  
          CAST(vol_freq_d1.[value] AS VARCHAR(100)),  
          CAST(vol_freq_d2.[value] AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Deal Volume Uom'',  
          CAST(sdda1.deal_volume_uom_id AS VARCHAR(100)),  
          CAST(sdda2.deal_volume_uom_id AS VARCHAR(100)),  
          CAST(suom1.uom_id AS VARCHAR(100)),  
          CAST(suom2.uom_id AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Block Description'',  
          CAST(sdda1.block_description AS VARCHAR(100)),  
          CAST(sdda2.block_description AS VARCHAR(100)),  
          CAST(sdda1.block_description AS VARCHAR(100)),  
          CAST(sdda2.block_description AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Deal Detail Description'',  
          CAST(sdda1.deal_detail_description AS VARCHAR(100)),  
          CAST(sdda2.deal_detail_description AS VARCHAR(100)),  
          CAST(sdda1.deal_detail_description AS VARCHAR(100)),  
          CAST(sdda2.deal_detail_description AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Formula'',  
          CAST(sdda1.formula_text AS VARCHAR(1000)),  
          CAST(sdda2.formula_text AS VARCHAR(1000)),  
          CAST(sdda1.formula_text AS VARCHAR(1000)),  
          CAST(sdda2.formula_text AS VARCHAR(1000))  
        
         UNION ALL  
         SELECT    N''Settlement Volume'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.settlement_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.settlement_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.settlement_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.settlement_volume),''n'')  
         UNION ALL  
         SELECT    N''Settlement Uom'',  
          CAST(sdda1.settlement_uom AS VARCHAR(100)),  
          CAST(sdda2.settlement_uom AS VARCHAR(100)),  
          CAST(sdda1.settlement_uom AS VARCHAR(100)),  
          CAST(sdda2.settlement_uom AS VARCHAR(100))  
         '
         SET @sql_select2_sub2 ='
         UNION ALL  
         SELECT    N''Price Adder'',  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.price_adder),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.price_adder),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.price_adder),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.price_adder),''n'')  
         UNION ALL  
         SELECT    N''Price Multiplier'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.price_multiplier),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.price_multiplier),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.price_multiplier),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.price_multiplier),''n'')  
         UNION ALL  
         SELECT    N''Settlement Date'',  
          CAST(sdda1.settlement_date AS VARCHAR(100)),  
          CAST(sdda2.settlement_date AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.settlement_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.settlement_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')  
         UNION ALL  
         SELECT    N''Day Count'',  
          CAST(sdda1.day_count_id AS VARCHAR(100)),  
          CAST(sdda2.day_count_id AS VARCHAR(100)),  
          CAST(sdvday1.code AS VARCHAR(100)),  
          CAST(sdvday2.code AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Location Name'',  
          CAST(sdda1.location_id AS VARCHAR(100)),  
          CAST(sdda2.location_id AS VARCHAR(100)),  
          CAST(sml1.Location_Name AS VARCHAR(100)),  
          CAST(sml2.Location_Name AS VARCHAR(100))  
  
         UNION ALL  
         SELECT    N''Physical Financial Flag'',  
          CAST(sdda1.physical_financial_flag AS VARCHAR(100)),  
          CAST(sdda2.physical_financial_flag AS VARCHAR(100)),  
          CAST(phy_fin_d1.[value] AS VARCHAR(100)),  
          CAST(phy_fin_d2.[value] AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Booked'',  
          CAST(sdda1.Booked AS VARCHAR(100)),  
          CAST(sdda2.Booked AS VARCHAR(100)),  
          CAST(booked_d1.[value] AS VARCHAR(100)),  
          CAST(booked_d2.[value] AS VARCHAR(100))  
          
         UNION ALL  
         SELECT    N''Fixed Cost'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.fixed_cost),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.fixed_cost),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.fixed_cost),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.fixed_cost),''n'')            
            
         UNION ALL  
         SELECT    N''Volume Multiplier'',  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.multiplier),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.multiplier),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.multiplier),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.multiplier),''n'')  
         UNION ALL  
         SELECT    N''Price Adder Currency'',  
          CAST(sdda1.adder_currency_id AS VARCHAR(100)),  
          CAST(sdda2.adder_currency_id AS VARCHAR(100)),  
          CAST(price_adder_currency1_1.currency_name AS VARCHAR(100)),  
          CAST(price_adder_currency1_2.currency_name AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Fixed Cost Currency'',  
          CAST(sdda1.fixed_cost_currency_id AS VARCHAR(100)),  
          CAST(sdda2.fixed_cost_currency_id AS VARCHAR(100)),  
          CAST(fixed_cost_currency1.currency_name AS VARCHAR(100)),  
          CAST(fixed_cost_currency2.currency_name AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Formula Currency'',  
          CAST(sdda1.formula_currency_id AS VARCHAR(100)),  
          CAST(sdda2.formula_currency_id AS VARCHAR(100)),  
          CAST(formula_currency1.currency_name AS VARCHAR(100)),  
          CAST(formula_currency2.currency_name AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Price Adder 2'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.price_adder2),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.price_adder2),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.price_adder2),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.price_adder2),''n'')   
         UNION ALL  
         SELECT    N''Price Adder Currency 2'',  
          CAST(sdda1.price_adder_currency2 AS VARCHAR(100)),  
          CAST(sdda2.price_adder_currency2 AS VARCHAR(100)),  
          CAST(price_adder_currency2_1.currency_name AS VARCHAR(100)),  
          CAST(price_adder_currency2_2.currency_name AS VARCHAR(100))   
         '
         SET @sql_select2_sub3 = '
         UNION ALL  
         SELECT    N''Volume Multiplier 2'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.volume_multiplier2),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.volume_multiplier2),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.volume_multiplier2),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.volume_multiplier2),''n'')     
         UNION ALL  
         SELECT    N''Pay Opposite'',  
          CAST(sdda1.pay_opposite AS VARCHAR(100)),  
          CAST(sdda2.pay_opposite AS VARCHAR(100)),  
          CAST(sdda1.pay_opposite AS VARCHAR(100)),  
          CAST(sdda2.pay_opposite AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Capacity'',  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.capacity),''n''),
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.capacity),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.capacity),''n''),
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.capacity),''n'') 
         UNION ALL  
         SELECT    N''Category'',  
          CAST(sdv1.code AS NVARCHAR(250)),  
          CAST(sdv2.code AS NVARCHAR(250)),
          CAST(sdv1.code AS NVARCHAR(250)),  
          CAST(sdv2.code AS NVARCHAR(250))   
         UNION ALL  
         SELECT    N''Profile Code'',  
          CAST(sdv3.code AS NVARCHAR(250)),  
          CAST(sdv4.code AS NVARCHAR(250)),
          CAST(sdv3.code AS NVARCHAR(250)),  
          CAST(sdv4.code AS NVARCHAR(250))  
         UNION ALL  
         SELECT    N''PV Party'',  
          CAST(sdv5.code AS NVARCHAR(250)),  
          CAST(sdv6.code AS NVARCHAR(250)),
          CAST(sdv5.code AS NVARCHAR(250)),  
          CAST(sdv6.code AS NVARCHAR(250))  
          
         UNION ALL  
         SELECT    N''Status'',  
          CAST(sdv_status_p.code AS NVARCHAR(250)),  
          CAST(sdv_status_f.code AS NVARCHAR(250)),
          CAST(sdv_status_p.code AS NVARCHAR(250)),  
          CAST(sdv_status_f.code AS NVARCHAR(250))   
          
          UNION ALL  
         SELECT    N''Deal Detail Lock'',  
          CAST(lock_deal_detail_p.value AS NVARCHAR(250)),  
          CAST(lock_deal_detail_f.value AS NVARCHAR(250)),
          CAST(lock_deal_detail_p.value AS NVARCHAR(250)),  
          CAST(lock_deal_detail_f.value AS NVARCHAR(250))   
          
         UNION ALL  
         SELECT    N''Price UOM'',  
          CAST(su1.uom_name AS NVARCHAR(250)),  
          CAST(su2.uom_name AS NVARCHAR(250)),
          CAST(su1.uom_name AS NVARCHAR(250)),  
          CAST(su2.uom_name AS NVARCHAR(250))
         UNION ALL  
         SELECT    N''Settlement Currency'',  
          CAST(scur1.currency_name AS NVARCHAR(250)),  
          CAST(scur2.currency_name AS NVARCHAR(250)),
          CAST(scur1.currency_name AS NVARCHAR(250)),  
          CAST(scur2.currency_name AS NVARCHAR(250))
         UNION ALL  
         SELECT    N''Standard Yearly Volume'',  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.standard_yearly_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.standard_yearly_volume),''n''),
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.standard_yearly_volume),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.standard_yearly_volume),''n'')
         UNION ALL  
         SELECT    N''Meter'',  
          CAST(mi1.meter_id AS VARCHAR(100)),  
          CAST(mi2.meter_id AS VARCHAR(100)),  
          CAST(mi1.recorderid AS VARCHAR(100)),  
          CAST(mi2.recorderid AS VARCHAR(100))  
            
        '
               
       SET @sql_select2_sub4 = ' 
       UNION ALL  
         SELECT    N''Commodity'',  
          CAST(sdda1.detail_commodity_id AS VARCHAR(100)),  
          CAST(sdda2.detail_commodity_id AS VARCHAR(100)),  
          CAST(dsco1.commodity_name AS VARCHAR(100)),  
          CAST(dsco2.commodity_name AS VARCHAR(100))  
         UNION ALL  
         SELECT    N''Origin'',  
          CAST(sdda1.origin AS VARCHAR(100)),  
          CAST(sdda2.origin AS VARCHAR(100)),  
          CAST(sdv_origin1.code AS VARCHAR(100)),  
          CAST(sdv_origin2.code AS VARCHAR(100))  
        UNION ALL  
         SELECT    N''Form'',  
          CAST(sdda1.[form] AS VARCHAR(100)),  
          CAST(sdda2.[form] AS VARCHAR(100)),  
          CAST(ctf1.commodity_form_name AS VARCHAR(100)),  
          CAST(ctf2.commodity_form_name AS VARCHAR(100))
          UNION ALL  
         SELECT    N''Organic'',  
          CAST(sdda1.organic AS VARCHAR(100)),  
          CAST(sdda2.organic AS VARCHAR(100)),  
          CAST(organic1.[value] AS VARCHAR(100)),  
          CAST(organic1.[value] AS VARCHAR(100)) 
        UNION ALL
        SELECT N''Attribute1'',  
          CAST(sdda1.attribute1 AS VARCHAR(100)),  
          CAST(sdda2.attribute1 AS VARCHAR(100)),  
          CAST(caf1_1.commodity_form_name AS VARCHAR(100)),  
          CAST(caf1_1.commodity_form_name AS VARCHAR(100)) 
        UNION ALL
        SELECT N''Attribute2'',  
          CAST(sdda1.attribute2 AS VARCHAR(100)),  
          CAST(sdda2.attribute2 AS VARCHAR(100)),  
          CAST(caf2_1.commodity_form_name AS VARCHAR(100)),  
          CAST(caf2_2.commodity_form_name AS VARCHAR(100)) 
        UNION ALL
        SELECT N''Attribute3'',  
          CAST(sdda1.attribute3 AS VARCHAR(100)),  
          CAST(sdda2.attribute3 AS VARCHAR(100)),  
          CAST(caf3_1.commodity_form_name AS VARCHAR(100)),  
          CAST(caf3_2.commodity_form_name AS VARCHAR(100))
        UNION ALL
        SELECT N''Attribute4'',  
          CAST(sdda1.attribute4 AS VARCHAR(100)),  
          CAST(sdda2.attribute4 AS VARCHAR(100)),  
          CAST(caf4_1.commodity_form_name AS VARCHAR(100)),  
          CAST(caf4_2.commodity_form_name AS VARCHAR(100))
        UNION ALL
        SELECT N''Attribute5'',  
          CAST(sdda1.attribute5 AS VARCHAR(100)),  
          CAST(sdda2.attribute5 AS VARCHAR(100)),  
          CAST(caf5_1.commodity_form_name AS VARCHAR(100)),  
          CAST(caf5_2.commodity_form_name AS VARCHAR(100))
          
        UNION ALL
        SELECT N''Position UOM'',  
          CAST(sdda1.position_uom AS VARCHAR(100)),  
          CAST(sdda2.position_uom AS VARCHAR(100)),  
          CAST(pos_uom1.uom_name AS VARCHAR(100)),  
          CAST(pos_uom2.uom_name AS VARCHAR(100))

		UNION ALL
        SELECT N''Detail INCOTerm'',  
          CAST(sdda1.detail_inco_terms AS VARCHAR(100)),  
          CAST(sdda2.detail_inco_terms AS VARCHAR(100)),  
          CAST(sdvdit1.code AS VARCHAR(100)),  
          CAST(sdvdit2.code AS VARCHAR(100))

		UNION ALL
        SELECT N''Crop Year'',  
          CAST(sdda1.crop_year AS VARCHAR(100)),  
          CAST(sdda2.crop_year AS VARCHAR(100)),  
          CAST(sdvcy1.code AS VARCHAR(100)),  
          CAST(sdvcy2.code AS VARCHAR(100))

		UNION ALL
        SELECT N''Buyer/Seller Option'',  
          CAST(sdda1.buyer_seller_option AS VARCHAR(100)),  
          CAST(sdda2.buyer_seller_option AS VARCHAR(100)),  
          CAST(sdvbso1.code AS VARCHAR(100)),  
          CAST(sdvbso2.code AS VARCHAR(100))
		UNION ALL
        SELECT N''Strike Granularity'',  
          CAST(sdda1.strike_granularity AS VARCHAR(100)),  
          CAST(sdda2.strike_granularity AS VARCHAR(100)),  
          CAST(sdvsg1.code AS VARCHAR(100)),  
          CAST(sdvsg2.code AS VARCHAR(100))
		  UNION ALL
        SELECT N''Profile'',  
          CAST(sdda1.profile_id AS VARCHAR(100)),  
          CAST(sdda2.profile_id AS VARCHAR(100)),  
          CAST(fp1.profile_name AS VARCHAR(100)),  
          CAST(fp2.profile_name AS VARCHAR(100))
		  UNION ALL
		SELECT N''Pricing Type2'',  
          CAST(sdda1.pricing_type2 AS VARCHAR(100)),  
          CAST(sdda2.pricing_type2 AS VARCHAR(100)),  
          CAST(sdvpt1.code AS VARCHAR(100)),  
          CAST(sdvpt2.code AS VARCHAR(100))
		  UNION ALL
		SELECT N''Cycle'',  
          CAST(sdda1.cycle AS VARCHAR(100)),  
          CAST(sdda2.cycle AS VARCHAR(100)),  
          CAST(sdvcyl1.code AS VARCHAR(100)),  
          CAST(sdvcyl2.code AS VARCHAR(100))
		  UNION ALL
		SELECT N''Upstream Counterparty'',  
          CAST(sdda1.upstream_counterparty AS VARCHAR(100)),  
          CAST(sdda2.upstream_counterparty AS VARCHAR(100)),  
          CAST(scuc1.counterparty_name AS VARCHAR(100)),  
          CAST(scuc1.counterparty_name AS VARCHAR(100))
         UNION ALL  
         SELECT    N''Lot'',  
          CAST(sdda1.lot AS VARCHAR(100)),  
          CAST(sdda2.lot AS VARCHAR(100)),  
          CAST(sdda1.lot AS VARCHAR(100)),  
          CAST(sdda2.lot AS VARCHAR(100))  
		  UNION ALL  
         SELECT    N''Batch ID'',  
          CAST(sdda1.batch_id AS VARCHAR(100)),  
          CAST(sdda2.batch_id AS VARCHAR(100)),  
          CAST(sdda1.batch_id AS VARCHAR(100)),  
          CAST(sdda2.batch_id AS VARCHAR(100))
		  UNION ALL  
         SELECT    N''No Of Strikes'',  
          CAST(sdda1.no_of_strikes AS VARCHAR(100)),  
          CAST(sdda2.no_of_strikes AS VARCHAR(100)),  
          CAST(sdda1.no_of_strikes AS VARCHAR(100)),  
          CAST(sdda2.no_of_strikes AS VARCHAR(100)) 

		  UNION ALL  
         SELECT    N''Upstream Contract'',  
          CAST(sdda1.upstream_contract AS VARCHAR(100)),  
          CAST(sdda2.upstream_contract AS VARCHAR(100)),  
          CAST(sdda1.upstream_contract AS VARCHAR(100)),  
          CAST(sdda2.upstream_contract AS VARCHAR(100))  
		   UNION ALL  
         SELECT    N''FX Conversion Rate'',   
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.fx_conversion_rate),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.fx_conversion_rate),''n''), 
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda1.fx_conversion_rate),''n''),  
          dbo.FNANumberFormat(CONVERT(NUMERIC(38,12),sdda2.fx_conversion_rate),''n'') 
		  UNION ALL  
         SELECT    N''Premium Settlement Date'',  
          CAST(sdda1.premium_settlement_date AS VARCHAR(100)),  
          CAST(sdda2.premium_settlement_date AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.premium_settlement_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.premium_settlement_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')
		
		 UNION ALL  
         SELECT    N''Delivery Date'',  
          CAST(sdda1.delivery_date AS VARCHAR(100)),  
          CAST(sdda2.delivery_date AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.delivery_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.delivery_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')

		  UNION ALL  
         SELECT    N''Payment Date'',  
          CAST(sdda1.payment_date AS VARCHAR(100)),  
          CAST(sdda2.payment_date AS VARCHAR(100)),  
          CONVERT(VARCHAR(10),sdda1.payment_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + '),  
          CONVERT(VARCHAR(10),sdda2.payment_date,' + CAST(ISNULL(@date_style, 103) AS VARCHAR(12)) + ')
		) Q ( Field, [CURRENT Id], [PRIOR Id], [CURRENT VALUE],  
          [PRIOR VALUE] )  
  WHERE   ISNULL([CURRENT Id], -1) <> ISNULL([PRIOR Id], -1)  
'

SET @sql_select3 = '  
UNION  
SELECT  uddfa1.source_deal_header_id [Deal ID],  
        sdha1.deal_id [REF ID],  
        dbo.fnadateformat(sdha1.entire_term_start) [Term START],  
        NULL [Leg],  
        ''UDF Header'' [Header Detail],
        udft.Field_label [Field],  
        CASE   
   WHEN udft.Field_type=''d'' THEN udf_v_c2.code  
   WHEN udft.Field_type=''d'' AND udf_v_c2.code IS NULL AND uddfa2.udf_value IS NOT NULL THEN uddfa2.udf_value 
   WHEN udft.Field_type=''a'' THEN dbo.FNADateFormat(uddfa2.udf_value)  
   WHEN TRY_CONVERT(NUMERIC(38,12),uddfa2.udf_value) IS NOT NULL THEN dbo.FNANUMBERFORMAT(CAST(uddfa2.udf_value AS NUMERIC(38,12)), ''w'')
   ELSE uddfa2.udf_value   
        END [PRIOR VALUE],  
        CASE   
   WHEN udft.Field_type=''d'' THEN udf_v_c1.code 
   WHEN udft.Field_type=''d'' AND udf_v_c1.code IS NULL AND uddfa1.udf_value IS NOT NULL THEN uddfa1.udf_value  
   WHEN udft.Field_type=''a'' THEN dbo.FNADateFormat(uddfa1.udf_value)  
   WHEN TRY_CONVERT(NUMERIC(38,12),uddfa1.udf_value) IS NOT NULL THEN dbo.FNANUMBERFORMAT(CAST(uddfa1.udf_value AS NUMERIC(38,12)), ''w'')
   ELSE uddfa1.udf_value      
        END [CURRENT VALUE],  
        uddfa1.update_ts [UPDATE TS],  
        dbo.FNAGetUserName(uddfa1.update_user) [UPDATE USER],
		uddfa1.user_action [User Action] 
FROM    #deals deals  
        INNER JOIN source_deal_header_audit sdha1 ON sdha1.audit_id = deals.audit_id1  
        LEFT JOIN user_defined_deal_fields_audit uddfa1 ON deals.audit_id1 = uddfa1.header_audit_id  
        LEFT JOIN user_defined_deal_fields_audit uddfa2 ON deals.audit_id2 = uddfa2.header_audit_id  
                                                    AND uddfa1.source_deal_header_id = uddfa2.source_deal_header_id  
                                                    AND uddfa1.udf_template_id = uddfa2.udf_template_id  
  LEFT JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id=uddfa1.udf_template_id  
  LEFT JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
  LEFT JOIN #udf_templateid_valueid_code udf_v_c1 ON udf_v_c1.udf_template_id=uddft.udf_template_id AND udf_v_c1.Field_type=udft.Field_type AND udf_v_c1.value_id=uddfa1.udf_value   
  LEFT JOIN #udf_templateid_valueid_code udf_v_c2 ON udf_v_c2.udf_template_id=uddft.udf_template_id AND udf_v_c2.Field_type=udft.Field_type AND udf_v_c2.value_id=uddfa2.udf_value   
 WHERE   ISNULL(uddfa1.udf_value, -1) <> ISNULL(uddfa2.udf_value, -1) --and uddfa1.udf_value is not null and uddfa2.udf_value is not null
 UNION 
 SELECT  deals.source_deal_header_id [Deal ID],  
        sdha1.deal_id [REF ID],  
        dbo.fnadateformat(sdda1.term_start) [Term START],  
        sdda1.leg [Leg],  
        ''UDF Detail'' [Header Detail],
        udft.Field_label [Field],  
        CASE   
   WHEN udft.Field_type=''d'' THEN udf_v_c2.code 
   WHEN udft.Field_type=''d'' AND udf_v_c2.code IS NULL AND udddfa2.udf_value IS NOT NULL THEN udddfa2.udf_value  
   WHEN udft.Field_type=''a'' THEN dbo.FNADateFormat(udddfa2.udf_value)  
   WHEN TRY_CONVERT(NUMERIC(38,12),udddfa2.udf_value) IS NOT NULL THEN dbo.FNANUMBERFORMAT(CAST(udddfa2.udf_value AS NUMERIC(38,12)), ''w'')
   ELSE udddfa2.udf_value   
        END [PRIOR VALUE],  
        CASE   
   WHEN udft.Field_type=''d'' THEN udf_v_c1.code  
   WHEN udft.Field_type=''d'' AND udf_v_c1.code IS NULL AND udddfa1.udf_value IS NOT NULL THEN udddfa1.udf_value 
   WHEN udft.Field_type=''a'' THEN dbo.FNADateFormat(udddfa1.udf_value)  
   WHEN TRY_CONVERT(NUMERIC(38,12),udddfa1.udf_value) IS NOT NULL THEN dbo.FNANUMBERFORMAT(CAST (udddfa1.udf_value AS NUMERIC(38,12)), ''w'')
   ELSE udddfa1.udf_value      
        END [CURRENT VALUE],  
        udddfa1.update_ts [UPDATE TS],  
        dbo.FNAGetUserName(udddfa1.update_user) [UPDATE USER],
		udddfa1.user_action [User Action]
		  
FROM    #deals deals  
	INNER JOIN source_deal_header_audit sdha1 
		ON sdha1.audit_id = deals.audit_id1
	INNER JOIN source_deal_header_audit sdha2 
		ON sdha2.audit_id = deals.audit_id2
		AND sdha2.source_deal_header_id = sdha1.source_deal_header_id
    LEFT JOIN source_deal_detail_audit sdda1 ON sdda1.header_audit_id = sdha1.audit_id  
	LEFT JOIN source_deal_detail_audit sdda2 
		ON sdda2.header_audit_id = sdha2.audit_id
		AND sdda2.source_deal_header_id = sdda1.source_deal_header_id
		AND sdda2.source_deal_detail_id = sdda1.source_deal_detail_id 
    LEFT JOIN user_defined_deal_detail_fields_audit udddfa1 
		ON sdda1.audit_id = ISNULL(udddfa1.header_audit_id, -1)  
    LEFT JOIN user_defined_deal_detail_fields_audit udddfa2 ON sdda2.audit_id = udddfa2.header_audit_id  
                                                AND udddfa1.source_deal_detail_id = udddfa2.source_deal_detail_id  
                                                AND udddfa1.udf_template_id = udddfa2.udf_template_id  
  INNER JOIN user_defined_deal_fields_template uddft 
	ON uddft.template_id = sdha1.template_id
	AND uddft.udf_template_id = ISNULL(udddfa1.udf_template_id , -1)
  LEFT JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
  LEFT JOIN #udf_templateid_valueid_code udf_v_c1 
	ON udf_v_c1.udf_template_id=uddft.udf_template_id 
	AND udf_v_c1.Field_type=udft.Field_type 
	AND udf_v_c1.value_id=udddfa1.udf_value   

  LEFT JOIN #udf_templateid_valueid_code udf_v_c2 
	ON udf_v_c2.udf_template_id=uddft.udf_template_id 
	AND udf_v_c2.Field_type=udft.Field_type 
	AND udf_v_c2.value_id=udddfa2.udf_value  
  WHERE   ISNULL(udddfa1.udf_value, -1) <> ISNULL(udddfa2.udf_value, -1) --and udddfa1.udf_value is not null and udddfa2.udf_value is not null
 )ChangeSummary 
 ORDER BY [Deal ID],[REF ID],[Term START],[Leg]
  '

--SELECT * FROM source_deal_header_audit sdha WHERE sdha.source_deal_header_id = 231780
	--PRINT @sql_select 
	--PRINT @sql_select_sub 
	--PRINT @sql_select1 
	--PRINT @sql_select1_sub1 
	--PRINT @sql_select1_sub2 
	--PRINT @sql_select1_sub3
	--PRINT @sql_select2
	--PRINT @sql_select2_1
	--PRINT @sql_select2_sub1 
	--PRINT @sql_select2_sub2 
	--PRINT @sql_select2_sub3
	--PRINT @sql_select2_sub4 
	--PRINT @sql_select3
	
	--return
  --print (@sql_select + @sql_select_sub + @sql_select1 + @sql_select1_sub1 + @sql_select1_sub2 + @sql_select1_sub2 + @sql_select2+ @sql_select2_sub1 + @sql_select2_sub2 + @sql_select2_sub3 + @sql_select3)

  EXEC (@sql_select + @sql_select_sub + @sql_select1 + @sql_select1_sub1 + @sql_select1_sub2 + @sql_select1_sub3 + @sql_select2+ @sql_select2_1 +  @sql_select2_sub1 + @sql_select2_sub2 + @sql_select2_sub3 + @sql_select2_sub4 + @sql_select3)


 IF OBJECT_ID('tempdb..#deal_deatail_aaa') IS NOT NULL 
 BEGIN
 	INSERT INTO #deal_deatail_aaa SELECT * FROM #tmp_deal_detail
 END      
 ELSE
 BEGIN
 	 UPDATE #tmp_deal_detail 
 	 SET [Prior Value] = NULL
 	 WHERE [Prior Value] = '01/01/1900'
 	 
 	 UPDATE #tmp_deal_detail 
 	 SET [Current Value] = NULL
 	 WHERE [Current Value] = '01/01/1900'
 	 
	IF @is_view = 1
	BEGIN	
 		SET @sql ='SELECT [User Action],  
						[Update Timestamp] [Update_Timestamp],	
						[Update User],[Deal ID],	
						[Ref ID], 
						[Term Start] [Term_Start],
						[Leg],
						[Header Detail],
						Field,
						[Prior Value],
 						[Current Value] ' + @str_batch_table + ' ' +  @str_view_table  + ' 
					FROM #tmp_deal_detail 
					WHERE 1 = 1 AND ISNULL([Prior Value], '''') <> ISNULL([Current Value], '''') ' + CASE WHEN @user_action <> 'all' THEN 
										' AND[User Action] IN (' + @user_action+') ' 
									ELSE '' 
									END + 
									CASE WHEN @tenor_from IS NOT NULL THEN 
										' AND CAST([Term Start] AS DATE) >= ''' + @tenor_from + ''' 
											AND  CAST([Term Start] AS DATE) <=''' + @tenor_to + '''' 
									ELSE '' 
									END + ' 
							
					--ORDER BY [Deal ID] DESC, CAST([Term Start] AS DATE) DESC, CAST([Update Timestamp] AS DATETIME) DESC, [User Action]
					'
	END 
	ELSE 
	BEGIN
		SET @sql ='SELECT [User Action],  [Update Timestamp] [Update Timestamp], [Update User],[Deal ID]
		,dbo.FNATRMWinHyperlink(''a'', 10131010, [Ref ID], ABS([Deal ID]),CASE WHEN [User Action] = ''delete'' THEN ''y'' ELSE NULL END,null,null,null,null,null,null,null,null,null,null,0)[Ref ID] 
		,[Term Start],[Leg],[Header Detail],Field,[Prior Value]
 					,[Current Value] ' + @str_get_row_number+' ' +  @str_batch_table + ' FROM #tmp_deal_detail
							WHERE ISNULL([Prior Value], '''') <> ISNULL([Current Value], '''')
					ORDER BY [Update Timestamp] DESC   ,[Deal ID] DESC'

	END
	
	--PRINT @Sql
	EXEC(@sql)

 END
END --@report_option='c'  
  
  
/******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Deal_Audit_Report', 'Transaction Audit Log Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
