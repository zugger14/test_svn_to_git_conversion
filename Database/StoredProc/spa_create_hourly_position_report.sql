IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_hourly_position_report]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_create_hourly_position_report]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Calculate Hourly Position for deals and portfolio

	Parameters : 
	@summary_option: 's' Summary,'e' Daily, 'd' Detail,'l' Detail deal level, 'j' Returns deal id and block, 'w' report writer, 'c' Data for cube reporting
	@sub_entity_id: Subsidiary filter for deals to process
	@strategy_entity_id: Strategy filter for deals to process
	@book_entity_id: Book filter for deals to process 
	@counterparty: Counterparty filter to process
	@as_of_date: Date for processing
	@term_start: Term Start filter to process
	@term_END: Term End filter to process
	@granularity: Granularity filter to process
	@group_by: Grouping data by 'l' Location, 'g' Location Grid, 'c' Country, 'r' Region
	@source_system_book_id1: Deals filter by source_system_book_id1
	@source_system_book_id2: Deals filter by source_system_book_id2
	@source_system_book_id3: Deals filter by source_system_book_id3
	@source_system_book_id4: Deals filter by source_system_book_id4
	@source_deal_header_id: Deal header id filter to process
	@deal_id: Deal id filter to process
	@block_group: Not in use
	@period: Calculate term_start and term_end from the help of as_of_date and period
	@commodity: Commodity filter to process
	@convert_uom: Value for the conversion 
	@round_value: Value to round the final output
	@curve_id: Curve filter to process
	@location_id: Location filter to process
	@physical_financial_flag: Filter 'f' Financial, 'p' Physical
	@tenor_option: TBD
	@allocation_option: Not in use
	@format_option: TBD
	@hour_from: Hour from filter to process
	@hour_to: Hour to filter to process
	@country: Country filter to process
	@region: Region filter to process
	@location_group: Location group filter to process 
	@location_grid: Grid location filter to process
	@deal_status: Deal status filter to process
	@col_7_to_6: TBD
	@drill_index: TBD
	@drill_term: TBD
	@drill_freq: TBD
	@drill_clm_hr: TBD
	@drill_uom: TBD
	@parent_counterparty: Parent counterparty filter to process
	@deal_date_from: Deal date from filter to process
	@deal_date_to: Deal date to filter to process
	@source_book_map_id: TBD
	@include_no_breakdown: TBD
	@whatif_criteria_id: Criteria ID to select data for 
	@deal_list_table: Process table holding list of deals to process
	@drill_location: TBD
	@batch_process_id: Process id when run through batch
	@batch_report_param: Paramater to run through barch
	@enable_paging: '1' Enable, '0' Disable
	@page_size: Number of rows on the page 
	@page_no: Number of pages
  */

CREATE PROC [dbo].[spa_create_hourly_position_report]                    
@summary_option CHAR(1)=NULL,-- 's' Summary,'e' Daily, 'd' Detail,'l' -- detail deal level,-'j' which returns deal id and block  ,w=report writer, c = data for cube reporting
@sub_entity_id VARCHAR(500),                 
@strategy_entity_id VARCHAR(500) = NULL,               
@book_entity_id VARCHAR(500) = NULL,           
@counterparty VARCHAR(MAX)=NULL,   
@as_of_date  VARCHAR(100)=NULL,  
@term_start VARCHAR(100)=NULL,  
@term_END VARCHAR(100)=NULL,  
@granularity INT,  
@group_by CHAR(1),-- 'i'- Index, 'l' - Location   
@source_system_book_id1 INT=NULL,   
@source_system_book_id2 INT=NULL,   
@source_system_book_id3 INT=NULL,   
@source_system_book_id4 INT=NULL,  
@source_deal_header_id VARCHAR(MAX)=NULL,  
@deal_id VARCHAR(250)=NULL,  
@block_group INT=NULL,  
@period INT=NULL,  
@commodity VARCHAR(MAX)=NULL,  
@convert_uom INT=NULL,  
@round_value CHAR(1) = '0',  
@curve_id VARCHAR(500)=NULL,
@location_id VARCHAR(500)=NULL,	
@physical_financial_flag CHAR(1)='p',
@tenor_option CHAR(1)='f',	
@allocation_option CHAR(1)='h',	
@format_option CHAR(1)='C',		
@hour_from INT=NULL,
@hour_to INT=NULL,
@country INT=NULL,
@region INT=NULL,
@location_group INT=NULL, 
@location_grid INT=NULL,
@deal_status VARCHAR(500) = NULL,
@col_7_to_6 VARCHAR(1)='n',
@drill_index VARCHAR(250)=NULL,  
@drill_term VARCHAR(100)=NULL,  
@drill_freq CHAR(1)=NULL,   	
@drill_clm_hr VARCHAR(100)=NULL, 
@drill_uom VARCHAR(100)=NULL, 
@parent_counterparty VARCHAR(10) = NULL ,
@deal_date_from  VARCHAR(20)=NULL,
@deal_date_to  VARCHAR(20)=NULL,
@source_book_map_id VARCHAR(100) = NULL,
@include_no_breakdown varchar(1)='n' ,
@whatif_criteria_id VARCHAR(100) = NULL, --used for whatif
@deal_list_table VARCHAR(200) = NULL,
@drill_location VARCHAR(250)=NULL,  
@batch_process_id VARCHAR(50)=NULL, 
@batch_report_param VARCHAR(1000)=NULL   ,
@enable_paging INT = 0,  --'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL
AS      



--select * from source_major_location
-- select * from source_minor_location

SET NOCOUNT ON              

--Grid (field added under the location)
--Country (Region field under the location)
--Zone (Location Group)


-- select @physical_financial_flag
--************************        
-- testing  
/*  
declare
@summary_option CHAR(1)=NULL,-- 's' Summary,'e' Daily, 'd' Detail,'l' -- detail deal level,-'j' which returns deal id and block  ,w=report writer, c = data for cube reporting
@sub_entity_id VARCHAR(500),                 
@strategy_entity_id VARCHAR(500) = NULL,               
@book_entity_id VARCHAR(500) = NULL,           
@counterparty VARCHAR(MAX)=NULL,   
@as_of_date  VARCHAR(100)=NULL,  
@term_start VARCHAR(100)=NULL,  
@term_END VARCHAR(100)=NULL,  
@granularity INT,  
@group_by CHAR(1),-- 'i'- Index, 'l' - Location   
@source_system_book_id1 INT=NULL,   
@source_system_book_id2 INT=NULL,   
@source_system_book_id3 INT=NULL,   
@source_system_book_id4 INT=NULL,  
@source_deal_header_id VARCHAR(MAX)=NULL,  
@deal_id VARCHAR(250)=NULL,  
@block_group INT=NULL,  
@period INT=NULL,  
@commodity VARCHAR(MAX)=NULL,  
@convert_uom INT=NULL,  
@round_value CHAR(1) = '0',  
@curve_id VARCHAR(500)=NULL,
@location_id VARCHAR(500)=NULL,	
@physical_financial_flag CHAR(1)='p',
@tenor_option CHAR(1)='f',	
@allocation_option CHAR(1)='h',	
@format_option CHAR(1)='C',		
@hour_from INT=NULL,
@hour_to INT=NULL,
@country INT=NULL,
@region INT=NULL,
@location_group INT=NULL, 
@location_grid INT=NULL,
@deal_status VARCHAR(500) = NULL,
@col_7_to_6 VARCHAR(1)='n',
@drill_index VARCHAR(100)=NULL,  
@drill_term VARCHAR(100)=NULL,  
@drill_freq CHAR(1)=NULL,   	
@drill_clm_hr VARCHAR(100)=NULL, 
@drill_uom VARCHAR(100)=NULL, 
@parent_counterparty VARCHAR(10) = NULL ,
@deal_date_from  VARCHAR(20)=NULL,
@deal_date_to  VARCHAR(20)=NULL,
@source_book_map_id VARCHAR(100) = NULL,
@include_no_breakdown varchar(1)='n' ,
@whatif_criteria_id VARCHAR(100) = NULL, --used for whatif
@deal_list_table VARCHAR(200) = NULL,
@batch_process_id VARCHAR(50)=NULL, 
@batch_report_param VARCHAR(1000)=NULL   ,
@enable_paging INT = 0,  --'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL

DROP TABLE #books  
drop table #unit_conversion
DROP TABLE #temp_deals  
DROP TABLE #deal_summary  
--DROP TABLE #deal_detail  
DROP TABLE #proxy_term
DROP TABLE #proxy_term_summary
DROP TABLE #source_deal_header_id
DROP TABLE #temp_deal_header
DROP TABLE #temp
DROP TABLE #term_date
DROP TABLE #minute_break

DECLARE @_contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @_contextinfo
--EXEC spa_create_hourly_position_report 'm', NULL, NULL, NULL, NULL, '2018-07-11', NULL, NULL, 982, 'i', NULL, NULL, NULL, NULL,'7050', NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, 'b', 'a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL

select   @summary_option ='m',-- 's' Summary,'e' Daily, 'd' Detail,'l' -- detail deal level  
@sub_entity_id = null,                 
@strategy_entity_id = null,               
@book_entity_id  = NULL,           
@counterparty =NULL,   
@as_of_date  ='2018-07-11',  
@term_start =null,  
@term_end=null,  
@granularity =982,  
@group_by ='i',-- 'i'- Index, 'l' - Location   
@source_system_book_id1 =NULL,   
@source_system_book_id2 =NULL,   
@source_system_book_id3 =NULL,   
@source_system_book_id4 =NULL,  
@source_deal_header_id='7050',  
@deal_id =null,  
@block_group =NULL,  
@period =NULL,  
@commodity =NULL,  
@convert_uom =NULL,  
@round_value = '2',  
@curve_id =NULL,
@location_id =NULL,	
@physical_financial_flag='b',
@tenor_option ='a',	
@allocation_option =null,	
@format_option =null,	
@hour_from =null
,@hour_to=null
--,@proxy_curve =null
, @country =null
,@location_group =null
, @location_grid =null


, @drill_index =null,  
@drill_term =null,  
@drill_freq=null,   	
--@clm_hr=null,  
@batch_process_id =NULL,  
@batch_report_param =NULL   

 --exec spa_create_hourly_position_report 'm','149', '151', NULL, NULL, '2011-05-22', NULL, NULL, 982, 'c', NULL, NULL, NULL, NULL,NULL, NULL,NULL,NULL,NULL,NULL,4,NULL,NULL,'b','a',NULL,'c',NULL,NULL,291981,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
--set @source_deal_header_id=1606  
--*/  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT @as_of_date = MAX(item) FROM [dbo].[SplitCommaSeperatedValues](@as_of_date)

DECLARE @Sql_Select VARCHAR(MAX)            --,@region int  
DECLARE @Sql_Where VARCHAR(MAX)              
DECLARE @report_type INT   
DECLARE @storage_inventory_sub_type_id INT  
--DECLARE @process_id VARCHAR(50)  
--DECLARE @user_login_id VARCHAR(50)  
DECLARE @sel_sql VARCHAR(1000)  
DECLARE @group_sql VARCHAR(200)  
--DECLARE @str_batch_table varchar(MAX)          
DECLARE @block_sql VARCHAR(100)  
DECLARE @col_name VARCHAR(20)  
DECLARE @frequency VARCHAR(20)  
DECLARE @term_END_parameter VARCHAR(100)  
DECLARE @term_start_parameter VARCHAR(100)  
DECLARE @actual_summary_option     CHAR(1)  
DECLARE @drill_index_id            INT,
        @drill_uom_id              INT,
		@drill_location_id int

DECLARE @hour_pivot_table          VARCHAR(100),
        @missing_data              VARCHAR(1) = 'n'

DECLARE @orginal_summary_option CHAR(1),@remain_month VARCHAR(1000)

DECLARE @column_level              VARCHAR(100),
        @temp_process_id           VARCHAR(100)
---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
DECLARE @str_batch_table VARCHAR(8000),@deal_filter_tbl VARCHAR(200),@subqry2  VARCHAR(MAX)
DECLARE @is_batch BIT
DECLARE @sql_paging VARCHAR(8000)
DECLARE @user_login_id     VARCHAR(50),
        @drill_start       VARCHAR(10),
        @drill_end         VARCHAR(10),
        @proxy_curve_view  CHAR(1),@hypo_breakdown VARCHAR(MAX)
	,@hypo_breakdown1 VARCHAR(MAX) ,@hypo_breakdown2 VARCHAR(MAX),@hypo_breakdown3 VARCHAR(MAX)
	
DECLARE @baseload_block_type VARCHAR(10)
DECLARE @baseload_block_define_id VARCHAR(10)
DECLARE @default_time_zone INT
DECLARE @dst_group_value_id INT

SELECT @default_time_zone = var_value FROM dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1

SELECT @dst_group_value_id = tz.dst_group_value_id FROM dbo.adiha_default_codes_values (nolock) adcv INNER JOIN time_zones tz
		ON tz.TIMEZONE_ID = adcv.var_value WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1


CREATE TABLE #source_deal_header_id (source_deal_header_id VARCHAR(200) COLLATE DATABASE_DEFAULT )

SET @deal_id= replace(@deal_id,'%20',' ')
if @summary_option='h' and @source_deal_header_id is not null and @drill_index is not null and @drill_term is not NULL and @format_option ='c'
BEGIN
	SELECT @granularity = isnull(sdht.hourly_position_breakdown,982)
	FROM  source_deal_header sdh  
	INNER JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id
	--and sdh.source_deal_header_id=@source_deal_header_id
	AND sdh.source_deal_header_id IN (SELECT * FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id))
		
	IF @granularity = 981
	    SET @summary_option = 'd'
	ELSE IF @granularity = 987
	    SET @summary_option = 'x'
	ELSE IF @granularity = 989
	    SET @summary_option = 'y'
	ELSE 
		SET @summary_option = 'h'
END





SET @orginal_summary_option = @summary_option
SET @str_batch_table = ''
SET @temp_process_id=dbo.FNAGetNewID()

SET @user_login_id = dbo.FNADBUser() 

declare @region_id varchar(3)


SELECT @region_id =  cast(case region_id
						 WHEN 1 THEN  101
						 WHEN 3 THEN  110
						 WHEN 2 THEN 103
						 WHEN 5 THEN 104
						 WHEN 4 THEN 105
						 ELSE 120
					END as varchar)
FROM   application_users	WHERE  user_login_id = @user_login_id 

-- If group by proxy curvem set group by ='l' and assign another variable
SET @proxy_curve_view = 'n'

IF @group_by = 'p'
BEGIN
	SET @group_by = 'i'
	SET @proxy_curve_view = 'y'
END


SET @deal_filter_tbl= dbo.FNAProcessTableName('deal_filter', @user_login_id, @batch_process_id)
IF OBJECT_ID(@deal_filter_tbl) IS NULL
	SET @deal_filter_tbl=''

IF @deal_filter_tbl=''
BEGIN
	SET @deal_filter_tbl= dbo.FNAProcessTableName('deal_filter_for_grid', @user_login_id, @batch_process_id)
	IF OBJECT_ID(@deal_filter_tbl) IS NULL
		SET @deal_filter_tbl=''
	ELSE
		set @batch_process_id=null
END

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

-- when called from Report Writer, @batch_report_param is NULL, but we still need to store result in a process table.
-- So set @str_batch_table wehn @batch_process_id is available. But we don't need message board update (at the end), so
-- @is_batch still need to be set as false.
--IF @is_batch = 1
--	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	
IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()
ELSE
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
		
IF @enable_paging = 1 --paging processing
BEGIN
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL  
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
		EXEC (@sql_paging)  
		RETURN  
	END
END

---END Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------

SET @hour_pivot_table=dbo.FNAProcessTableName('hour_pivot', @user_login_id,@batch_process_id)  

declare @position_deal varchar(250)  ,@position_no_breakdown varchar(250)--, @position_breakdown varchar(250)
SET @position_deal=dbo.FNAProcessTableName('position_deal', @user_login_id,@batch_process_id)  
SET @position_no_breakdown=dbo.FNAProcessTableName('position_no_breakdown', @user_login_id,@batch_process_id)  

--SET @position_breakdown=dbo.FNAProcessTableName('position_breakdown', @user_login_id,@batch_process_id)  

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

--IF @summary_option='j'
--	SET @orginal_summary_option=@summary_option
	


IF @whatif_criteria_id IS NOT NULL  --call for hypo. position 
BEGIN 
	EXEC dbo.spa_calc_mtm_whatif 'p', @as_of_date,@whatif_criteria_id, NULL,@user_login_id, @batch_process_id --added null for criteria group param 4/22/2013
	
	set @temp_process_id=@batch_process_id --+'_1'
	SET @deal_filter_tbl=dbo.FNAProcessTableName('std_whatif_deals', @user_login_id,@temp_process_id)  	
	
	--SET @Sql_Select = 'select * from ' + @deal_filter_tbl
	--EXEC (@Sql_Select)
	
	IF OBJECT_ID(@deal_filter_tbl) IS NULL
		SET @deal_filter_tbl=''
	
END
	
IF ISNULL(@drill_clm_hr,'')<>'' AND ISNULL(@col_7_to_6,'n')='y'  AND @summary_option='l' AND @format_option<>'r'
BEGIN
	SELECT @drill_clm_hr='Hr' 
	+ CAST(CASE CAST(RIGHT(@drill_clm_hr,1) AS INT)
			WHEN  7 THEN 1
			WHEN  8 THEN 2
			WHEN  9 THEN 3
			WHEN  10 THEN 4
			WHEN  11 THEN 5
			WHEN  12 THEN 6
			WHEN  13 THEN 7
			WHEN  14 THEN 8
			WHEN  15 THEN 9
			WHEN  16 THEN 10
			WHEN  17 THEN 11
			WHEN  18 THEN 12
			WHEN  19 THEN 13
			WHEN  20 THEN 14
			WHEN  21 THEN 15
			WHEN  22 THEN 16
			WHEN  23 THEN 17
			WHEN  24 THEN 18
			WHEN  1 THEN 19
			WHEN  2 THEN 20
			WHEN  3 THEN 21
			WHEN  4 THEN 22
			WHEN  5 THEN 23
			WHEN  6 THEN 24
			WHEN  24 THEN 25
	END	 AS VARCHAR)					
END
IF LEN(@drill_term) = 7
BEGIN
	IF @drill_freq='q' 
	BEGIN
		SET  @drill_start= CONVERT(VARCHAR(10),CAST(LEFT(@drill_term,4) +'-'+CAST((CAST(RIGHT(@drill_term,1) AS INT)*3)-2 AS VARCHAR) +'-01' AS DATETIME),120)
		SET @drill_end = CONVERT(VARCHAR(10),DATEADD(MONTH,1,CAST(LEFT(@drill_term,4) +'-'+CAST(CAST(RIGHT(@drill_term,1) AS INT)*3 AS VARCHAR)+'-01' AS DATETIME))-1,120)
		SET @drill_term=@drill_start
	--	select @drill_term,@drill_start,@drill_end
	END
	ELSE
		SET @drill_term = @drill_term+'-01'
END
ELSE IF LEN(@drill_term) = 4 	
BEGIN
	SET @drill_start = CONVERT(VARCHAR(10),CAST(@drill_term +'-01-01' AS DATETIME),120)
	SET @drill_end =  CONVERT(VARCHAR(10),DATEADD(MONTH,1,CAST(@drill_term +'-12-01' AS DATETIME))-1,120)
	SET @drill_term=@drill_start
END

IF @hour_from IS NOT NULL
BEGIN
	IF @hour_to IS NULL
		SET @hour_to=@hour_from
END	
ELSE
BEGIN
	IF @hour_to IS NOT NULL
		SET @hour_from= @hour_to
END

-- if convert UOM is sleected, drill UOM should be NULL
IF @convert_uom IS NOT NULL
	SET @drill_uom= NULL

IF NULLIF(@format_option,'') IS NULL
	SET @format_option='c'
	
CREATE TABLE #temp_deal_header ( deal_id VARCHAR(250) COLLATE DATABASE_DEFAULT )

DECLARE @term_start_temp DATETIME,@term_END_temp DATETIME  
 
CREATE TABLE #temp ( deal_id VARCHAR(250) COLLATE DATABASE_DEFAULT )
 
IF @deal_id IS NOT NULL AND @source_deal_header_id IS NULL
BEGIN
	INSERT INTO #temp_deal_header 
	SELECT source_deal_header_id FROM source_deal_header WHERE deal_id = @deal_id

	SET @source_deal_header_id = NULL
	SELECT @source_deal_header_id = COALESCE(@source_deal_header_id+',' ,'') + deal_id
	FROM #temp_deal_header
END
IF @source_deal_header_id IS NOT NULL
BEGIN

 	INSERT INTO #temp   SELECT  * FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id)
	
END
IF @deal_id IS NOT NULL AND @source_deal_header_id IS NULL
BEGIN
	SELECT @source_deal_header_id=source_deal_header_id FROM source_deal_header WHERE deal_id=@deal_id
	
	IF @source_deal_header_id IS NULL
	SET @source_deal_header_id=-1
END	
If OBJECT_ID(@deal_list_table) is not null
BEGIN
	EXEC('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM '+@deal_list_table)
	SET @source_deal_header_id = NULL
	SELECT @source_deal_header_id = COALESCE(@source_deal_header_id+',' ,'') + source_deal_header_id
	FROM #source_deal_header_id
END

	
--PRINT @source_deal_header_id  
--if 'period' has been defined, calculate term_start and term_END from the help of as_of_date and period.  

IF @period IS NOT NULL  
BEGIN  
	SET @term_start_temp= CAST(YEAR(@as_of_date) AS VARCHAR)+ '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-01' ;  
	SET @term_start_temp= DATEADD(mm,1,@term_start_temp)  
	SET @term_start= CAST(YEAR(@term_start_temp) AS VARCHAR)+ '-' + CAST(MONTH(@term_start_temp) AS VARCHAR) + '-01' ;  

	SET @term_END_temp= DATEADD(mm,@period,@term_start_temp)  
	SET @term_END_temp= DATEADD(dd,-1,@term_END_temp)  
	SET @term_END= CAST(YEAR(@term_END_temp) AS VARCHAR)+ '-' + CAST(MONTH(@term_END_temp) AS VARCHAR) + '-' + CAST(DAY(@term_END_temp) AS VARCHAR)  ;  
END  

--tenor logic for criteria
DECLARE @tenor_type CHAR(1), @tenor_from VARCHAR(10) = NULL, @tenor_to VARCHAR(10) = NULL

IF @whatif_criteria_id IS NOT NULL
BEGIN
	SELECT @term_start = mwc.term_start, @term_END = mwc.term_end, @tenor_from = mwc.tenor_from, @tenor_to = mwc.tenor_to
	FROM maintain_whatif_criteria mwc WHERE mwc.criteria_id = @whatif_criteria_id
	
	-- setting term_start, term_end (priority 1: fixed tenor, priority 2: relative tenor) and relative tenor conversion on reference with as of date
	SET @term_start = COALESCE(dbo.FNAGetContractMonth(ISNULL(@term_start, DATEADD (MONTH, CAST(@tenor_from AS INT), @as_of_date))), @as_of_date)
	SET @term_end = COALESCE(dbo.FNALastDayInDate(ISNULL(@term_end, DATEADD (MONTH, CAST(@tenor_to AS INT), @as_of_date))), '9999-12-30')
END
--tenor logic for criteria

IF @term_start IS NOT NULL AND @term_END IS NULL              
	SET @term_END = @term_start              
IF @term_start IS NULL AND @term_END IS NOT NULL              
	SET @term_start = @term_END       	  
  
IF @deal_date_from IS NOT NULL AND @deal_date_to IS NULL              
	SET @deal_date_to = @deal_date_from              
IF @deal_date_from IS NULL AND @deal_date_to IS NOT NULL              
	SET @deal_date_from = @deal_date_to  
SET @sql_Where = ''              
 
--PRINT 'CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    '
      
CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)    

SET @Sql_Select = 
'   INSERT INTO #books
    SELECT DISTINCT book.entity_id,
           ssbm.source_system_book_id1,
           ssbm.source_system_book_id2,
           ssbm.source_system_book_id3,
           ssbm.source_system_book_id4 fas_book_id
    FROM   portfolio_hierarchy book(NOLOCK)
           INNER JOIN Portfolio_hierarchy stra(NOLOCK)
                ON  book.parent_entity_id = stra.entity_id
           INNER JOIN source_system_book_map ssbm
                ON  ssbm.fas_book_id = book.entity_id
    WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id IN (400 ,309300,309299,410, 401))  ' 
        
IF @sub_entity_id IS NOT NULL   
	SET @Sql_Select = @Sql_Select + ' AND stra.parent_entity_id IN  ( '  + @sub_entity_id + ') '              
IF @strategy_entity_id IS NOT NULL   
	SET @Sql_Select = @Sql_Select + ' AND (stra.entity_id IN('  + @strategy_entity_id + ' ))'           
IF @book_entity_id IS NOT NULL   
	SET @Sql_Select = @Sql_Select + ' AND (book.entity_id IN('   + @book_entity_id + ')) '   
IF @source_book_map_id IS NOT NULL
	SET @Sql_Select = @Sql_Select + ' AND ssbm.book_deal_type_map_id IN (' + @source_book_map_id + ' ) '

--PRINT ( @Sql_Select)    
EXEC ( @Sql_Select)    

CREATE  INDEX [IX_Book] ON [#books]([fas_book_id])                    


create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int,dst_group_value_id int
)
insert into #term_date(block_define_id  ,term_date,term_start,term_end,
hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
	,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour,dst_group_value_id
)
select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,a.dst_group_value_id
from (
		select distinct isnull(spcd.block_define_id,@baseload_block_define_id) block_define_id,s.term_start,s.term_end, tz.dst_group_value_id 
		from report_hourly_position_breakdown s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
		 	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
		 	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
		 		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
		LEFT JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id
		LEFT JOIN dbo.vwDealTimezoneContract tz ON tz.source_deal_header_id = s.source_deal_header_id
			AND tz.curve_id = isnull(s.curve_id, -1)  AND tz.location_id =  -1
		) a
		outer apply	(
			select h.* from hour_block_term h with (nolock,FORCESEEK) where block_define_id=a.block_define_id and h.block_type=12000
		and term_date between a.term_start  and a.term_end --and term_date>@as_of_date
		AND h.dst_group_value_id = a.dst_group_value_id
) hb
/* Most of the scenarios SQL Server engine produce and select the best and accurate execution plan. But, there are scenarios we may need to override by enforcing it, where table hints coming into play.  
Here FORCESEEK  table hint is used to gain performance.*/

IF @baseload_block_define_id IS NULL 
	SET @baseload_block_define_id = 'NULL'

create index indxterm_dat on #term_date(block_define_id  ,term_start,term_end,dst_group_value_id)

--PRINT 'CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(2,1))    '

CREATE TABLE #minute_break ( granularity int,period tinyint, factor numeric(6,2))  

if @summary_option='y' --30 minutes
begin
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,48),(981,30,2)

	insert into #minute_break ( granularity ,period , factor )  --hourly
	values (982,0,2),(982,30,2)
end    
else if @summary_option='x' --15 minutes
begin
	--insert into #minute_break ( granularity ,period , factor )   --daily
	--values (981,0,96),(981,15,96),(981,30,96),(981,45,4)

	insert into #minute_break ( granularity ,period , factor )  --hourly
	values (982,0,4),(982,15,4),(982,30,4),(982,45,4)
	
	insert into #minute_break ( granularity ,period , factor )  --30 minute
	values (989,15,2),(989,45,2)
end
     
          

  
--***************************              
--END of source book map table and build index              
--*****************************     

IF @drill_index IS NOT NULL AND @group_by IN('l')  AND @physical_financial_flag='p'
	SELECT @drill_index_id= source_minor_location_id FROM  source_minor_location WHERE location_name=@drill_index  
	
IF @drill_index IS NOT NULL AND @group_by IN ('g') AND @physical_financial_flag='p'
	SELECT @drill_index_id= value_id FROM  static_data_value WHERE code=@drill_index   AND [TYPE_ID]=18000

IF @drill_index IS NOT NULL AND @group_by IN ('c') AND @physical_financial_flag='p'
	SELECT @drill_index_id= value_id FROM  static_data_value WHERE code=@drill_index  AND [TYPE_ID]=14000
	
IF @drill_index IS NOT NULL AND @group_by IN ('r') AND @physical_financial_flag='p'
	SELECT @drill_index_id= value_id FROM  static_data_value WHERE code=@drill_index AND [TYPE_ID]=11150
	
IF @drill_index IS NOT NULL AND @group_by ='z' AND @physical_financial_flag='p'
	SELECT @drill_index_id= source_major_location_id FROM  source_major_location WHERE location_name=@drill_index  

IF @drill_location IS NOT NULL AND @group_by IN('i')  AND @physical_financial_flag='p'
	SELECT @drill_location_id= source_minor_location_id FROM  source_minor_location WHERE location_name=@drill_location  



IF @group_by ='z'
	SET @column_level =' [LocationGroup]'
ELSE IF @group_by ='g'
	SET @column_level =' [Grid]'
ELSE IF @group_by ='c'
	SET @column_level =' [Country]'
ELSE IF @group_by ='r'
	SET @column_level =' [Region]'
ELSE IF @group_by ='l'
	SET @column_level =' [Location]'
ELSE IF @group_by ='b'
	SET @column_level =' [BlockName]'
ELSE 
	SET @column_level =' [Index]'


IF @drill_index IS NOT NULL AND @group_by ='b' 
BEGIN
	--IF @summary_option='l'
	--	SELECT   @drill_index_id=spcd.source_curve_def_id FROM  source_price_curve_def spcd WHERE  spcd.curve_name=@drill_index
	--ELSE		
		SELECT @drill_index_id= id FROM  block_type_group WHERE block_name=@drill_index  
END

IF @drill_uom IS NOT NULL
	SELECT @drill_uom_id= source_uom_id FROM  source_uom WHERE uom_name=@drill_uom


IF 	@drill_index_id IS NULL
begin
	SELECT   @drill_index_id=spcd.source_curve_def_id 
	FROM  source_price_curve_def spcd 
		--left JOIN  source_price_curve_def spcd1 ON  isnull(spcd1.source_curve_def_id,-1)=isnull(spcd.proxy_source_curve_def_id,1) 
		--and spcd.proxy_source_curve_def_id is not null   
	WHERE  spcd.curve_name=@drill_index
	if @group_by ='b' -- block group is null and showing curve name 
		set @missing_data='y'		
end

CREATE TABLE  #temp_deals(  
	 fas_book_id INT,  
	 source_deal_header_id VARCHAR(250) COLLATE DATABASE_DEFAULT ,  
	 deal_date DATETIME,  
	 counterparty_id INT,  
	 counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	 block_type INT,  
	 block_definition_id INT,  
	 profile_id INT,  
	 template_id INT   
)  

CREATE TABLE #unit_conversion(  
	 convert_from_uom_id INT,  
	 convert_to_uom_id INT,  
	 conversion_factor NUMERIC(38,20)  
)  


INSERT INTO #unit_conversion(convert_from_uom_id,convert_to_uom_id,conversion_factor)    
SELECT   
  from_source_uom_id,  
  to_source_uom_id,  
  conversion_factor  
FROM  
	rec_volume_unit_conversion  
WHERE  state_value_id IS NULL  
  AND curve_id IS NULL  
  AND assignment_type_value_id IS NULL  
  AND to_curve_id IS NULL   
  
-- Collect Required Deals  

--select * from #unit_conversion
DECLARE @view_name VARCHAR(100),@volume_clm VARCHAR(MAX),@view_name1 VARCHAR(100)
DECLARE @dst_column VARCHAR(2000),@vol_multiplier VARCHAR(2000) ,@report_hourly_position_breakdown VARCHAR(MAX)
,@report_hourly_position_breakdown1 VARCHAR(MAX) ,@report_hourly_position_breakdown2 VARCHAR(MAX),@report_hourly_position_breakdown3 VARCHAR(MAX)
,@subqry  VARCHAR(MAX),@sub_criteria varchar(max) ,@subqry1  VARCHAR(MAX)
 ,@report_hourly_position_no_breakdown VARCHAR(MAX)
,@report_hourly_position_no_breakdown1 VARCHAR(MAX) ,@report_hourly_position_no_breakdown2 VARCHAR(MAX),@report_hourly_no_position_breakdown3 VARCHAR(MAX)

--IF @group_by='b' AND @summary_option<>'l'
--BEGIN
--	IF @summary_option<>'j'
--		SET @summary_option='x'
--END
-- Select different views depENDing on the criteria
IF @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w') OR @group_by='d' OR isnull(@deal_filter_tbl,'')<>''
BEGIN
	SET @view_name='report_hourly_position_deal'
	SET @view_name1='report_hourly_position'

END
ELSE
BEGIN
	SET @view_name='vwHourly_position_AllFilter'	
	SET @view_name1='vwHourly_position_AllFilter'
END

--print '-----------------------@sub_criteria'
SET @sub_criteria=''
SET @sub_criteria= CASE WHEN @source_deal_header_id IS NOT NULL  THEN ' AND s.source_deal_header_id IN ('+ CAST(@source_deal_header_id AS VARCHAR(MAX)) + ')' ELSE '' END
	+ CASE WHEN @deal_id IS NOT NULL  THEN ' AND s.source_deal_header_id IN (SELECT sdh.source_deal_header_id FROM source_deal_header sdh INNER JOIN #temp deal_header_id ON deal_header_id.deal_id = sdh.source_deal_header_id) ' ELSE '' END
+ CASE WHEN @term_start IS NOT NULL THEN ' AND s.term_start>='''+@term_start +''' AND s.term_start<='''+convert(varchar(10),CAST(@term_END as datetime)+1,120)+'''' ELSE '' END 
	+CASE WHEN @counterparty IS NOT NULL THEN ' AND s.counterparty_id IN (' + @counterparty + ')'ELSE '' END
	+CASE WHEN @commodity IS NOT NULL THEN ' AND s.commodity_id IN('+@commodity+')' ELSE '' END
	+CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND s.source_system_book_id1 ='+CAST(@source_system_book_id1 AS VARCHAR) ELSE '' END
	+CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND s.source_system_book_id2 ='+CAST(@source_system_book_id2 AS VARCHAR) ELSE '' END
	+CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND s.source_system_book_id3 ='+CAST(@source_system_book_id3 AS VARCHAR) ELSE '' END
	+CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND s.source_system_book_id4 ='+CAST(@source_system_book_id4 AS VARCHAR) ELSE '' END
	+CASE WHEN @curve_id IS NOT NULL THEN ' AND s.curve_id IN('+@curve_id+')' ELSE '' END
	+CASE WHEN @location_id IS NOT NULL THEN ' AND s.location_id IN('+@location_id+')' ELSE '' END
	--+CASE WHEN @tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+'''' ELSE '' END  
	+CASE WHEN @physical_financial_flag <>'b' THEN ' AND s.physical_financial_flag='''+@physical_financial_flag+'''' ELSE '' END
	+CASE WHEN @deal_status IS NOT NULL THEN ' AND deal_status_id IN('+@deal_status+')' ELSE '' END
	+CASE WHEN @deal_date_from IS NOT NULL THEN ' AND s.deal_date>='''+CAST(@deal_date_from AS VARCHAR)+''' AND s.deal_date<='''+CAST(@deal_date_to AS VARCHAR)+'''' ELSE '' END  
	+CASE WHEN @as_of_date IS NOT NULL THEN ' AND s.deal_date<='''+@as_of_date +'''' ELSE '' END 

--PRINT @sub_criteria
--print '--------------------------------------------'

---------------------------Start hourly_position_breakdown=null------------------------------------------------------------

declare @std_whatif_deals varchar(250)  ,@hypo_deal_header varchar(250), @hypo_deal_detail varchar(250),@position_hypo varchar(250)--, @position_breakdown varchar(250)

select @hypo_breakdown='',@hypo_breakdown1='',@hypo_breakdown2=''
if @whatif_criteria_id IS NOT NULL --hypo. position
begin
	SET @hypo_deal_header=dbo.FNAProcessTableName('hypo_deal_header', @user_login_id,@temp_process_id)  
	SET @hypo_deal_detail=dbo.FNAProcessTableName('hypo_deal_detail', @user_login_id,@temp_process_id)  
	SET @position_hypo=dbo.FNAProcessTableName('position_hypo', @user_login_id,@batch_process_id)  

	if OBJECT_ID(@hypo_deal_header) is not null
	begin
		create table #term_date_hypo( block_define_id int ,term_date date,term_start date,term_end date,
			hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint
			,hr14 tinyint,hr15 tinyint,hr16 tinyint,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int,volume_mult int
		)
		

		set @hypo_breakdown='
			select sdh.source_deal_header_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4
			,sdh.deal_date,sdh.counterparty_id,sdh.deal_status deal_status_id,sdd.curve_id,sdd.location_id,sdd.term_start,sdd.term_end
			,(sdd.total_volume * (CASE WHEN sdd.buy_sell_flag = ''b'' THEN ''1'' ELSE ''-1'' END)) total_volume 
			,spcd.commodity_id,sdd.physical_financial_flag,sdd.deal_volume_uom_id,bk.fas_book_id,sdd.contract_expiration_date expiration_date 
			,isnull(spcd.block_define_id,'+@baseload_block_define_id+') block_define_id
			 into '+ @position_hypo+'
			from '+@hypo_deal_header+' sdh with (nolock) 
			--inner join source_deal_header_template sdht on sdh.template_id=sdht.template_id and sdht.hourly_position_breakdown is null
			inner join '+@hypo_deal_detail+' sdd with (nolock) on sdh.source_deal_header_id=sdd.source_deal_header_id
			--INNER JOIN [deal_status_group] dsg ON dsg.deal_status_group_id = sdh.deal_status 
			INNER JOIN #books bk ON bk.source_system_book_id1=sdh.source_system_book_id1 AND bk.source_system_book_id2=sdh.source_system_book_id2 
				AND bk.source_system_book_id3=sdh.source_system_book_id3 AND bk.source_system_book_id4=sdh.source_system_book_id4
			left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=sdd.curve_id 
		'
		--print @hypo_breakdown
		exec(@hypo_breakdown)

		set @hypo_breakdown='
			insert into #term_date_hypo(block_define_id,term_date,term_start,term_end,
				hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 ,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour,volume_mult
			)
			select distinct a.block_define_id, hb.term_date,a.term_start ,a.term_end,
				hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
				,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
				,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,hb.volume_mult
			from '+@position_hypo+' a
				outer apply	(select h.* from hour_block_term h with (nolock) where h.block_define_id=a.block_define_id
					and h.dst_group_value_id = '+ CAST(@dst_group_value_id AS VARCHAR(50)) +' and term_date between a.term_start  and a.term_end and term_date>'''+convert(varchar(10),@as_of_date,120) +'''
			) hb
			'
			
		--print @hypo_breakdown
		exec(@hypo_breakdown)

		create index indx_term_date_hypo on #term_date_hypo(term_start,term_end)
		
		SET @dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
		
		SET @vol_multiplier='*cast(cast(s.total_volume as numeric(26,12))/nullif(term_hrs.term_hrs,0) as numeric(28,16))'+case when @summary_option in ('x','y')  then ' /hrs.factor '	else '' end
		
		SET @hypo_breakdown='Union all
		select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
			,cast(isnull(hb.hr1,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END '+ @vol_multiplier +'  AS Hr1
			,cast(isnull(hb.hr2,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr2
			,cast(isnull(hb.hr3,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr3
			,cast(isnull(hb.hr4,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr4
			,cast(isnull(hb.hr5,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr5
			,cast(isnull(hb.hr6,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr6
			,cast(isnull(hb.hr7,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr7
			,cast(isnull(hb.hr8,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr8
			,cast(isnull(hb.hr9,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr9
			,cast(isnull(hb.hr10,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr10
			,cast(isnull(hb.hr11,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr11
			,cast(isnull(hb.hr12,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr12
			,cast(isnull(hb.hr13,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr13'
		
		SET @hypo_breakdown1= ',cast(isnull(hb.hr14,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr14
			,cast(isnull(hb.hr15,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr15
			,cast(isnull(hb.hr16,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr16
			,cast(isnull(hb.hr17,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr17
			,cast(isnull(hb.hr18,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr18
			,cast(isnull(hb.hr19,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr19
			,cast(isnull(hb.hr20,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr20
			,cast(isnull(hb.hr21,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr21
			,cast(isnull(hb.hr22,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr22
			,cast(isnull(hb.hr23,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr23
			,cast(isnull(hb.hr24,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr24
			,'+@dst_column+ @vol_multiplier+' AS Hr25 ' 
		
		SET @hypo_breakdown2=
			 CASE WHEN @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w') OR @group_by IN('d')  THEN ',s.source_deal_header_id' ELSE '' END
			  +',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date ,''y'' AS is_fixedvolume ,deal_status_id, tz.dst_group_value_id 
			 from '+@position_hypo + ' s '
	+' left join #term_date_hypo hb on hb.block_define_id=s.block_define_id and hb.term_start = s.term_start and hb.term_end=s.term_end  and hb.term_date>''' 
	+ @as_of_date +''''
			+case when @summary_option in ('x','y')  then 
				' left join #minute_break hrs on hrs.granularity=982 '
			else '' end+'
			outer apply ( select sum(volume_mult) term_hrs from #term_date_hypo h where h.term_start = s.term_start and h.term_end=s.term_end  and h.term_date>''' + @as_of_date +''') term_hrs
			LEFT JOIN dbo.vwDealTimezoneContract tz ON tz.source_deal_header_id = s.source_deal_header_id
				AND tz.curve_id = isnull(s.curve_id, -1) 
				AND tz.location_id = isnull(s.location_id, -1)
			where 1=1' +@sub_criteria
	end
	else
	begin
		set @whatif_criteria_id=null
	end
end



if isnull(@include_no_breakdown,'n')='y'
begin

	create table #term_date_no_break( block_define_id int ,term_date date,term_start date,term_end date,
		hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint
		,hr14 tinyint,hr15 tinyint,hr16 tinyint,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int,volume_mult int
	)

	set @report_hourly_position_no_breakdown='
		select sdh.source_deal_header_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4
		,sdh.deal_date,sdh.counterparty_id,sdh.deal_status deal_status_id,sdd.curve_id,sdd.location_id,sdd.term_start,sdd.term_end,sdd.total_volume
		,spcd.commodity_id,sdd.physical_financial_flag,sdd.deal_volume_uom_id,bk.fas_book_id,sdd.contract_expiration_date expiration_date,
		isnull(spcd.block_define_id,'+@baseload_block_define_id+') block_define_id
		  into '+ @position_no_breakdown+'
		from source_deal_header sdh with (nolock) inner join source_deal_header_template sdht on sdh.template_id=sdht.template_id and sdht.hourly_position_breakdown is null
		inner join source_deal_detail sdd with (nolock) on sdh.source_deal_header_id=sdd.source_deal_header_id
		INNER JOIN [deal_status_group] dsg ON dsg.deal_status_group_id = sdh.deal_status 
		' +CASE WHEN isnull(@source_deal_header_id ,-1) <>-1 THEN ' and sdh.source_deal_header_id IN (' +CAST(@source_deal_header_id AS VARCHAR(MAX)) + ')' ELSE '' END 
		+ CASE WHEN isnull(@deal_filter_tbl,'')<>'' THEN ' INNER JOIN '+ @deal_filter_tbl +' flt ON flt.source_deal_header_id=s.source_deal_header_id ' ELSE '' END 
		+'	INNER JOIN #books bk ON bk.source_system_book_id1=sdh.source_system_book_id1 AND bk.source_system_book_id2=sdh.source_system_book_id2 
		AND bk.source_system_book_id3=sdh.source_system_book_id3 AND bk.source_system_book_id4=sdh.source_system_book_id4
		left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=sdd.curve_id 
	'
	--print @report_hourly_position_no_breakdown
	exec(@report_hourly_position_no_breakdown)

	set @report_hourly_position_no_breakdown='
		insert into #term_date_no_break(block_define_id,term_date,term_start,term_end,
		hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 
		,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour,volume_mult
		)
		select distinct a.block_define_id,hb.term_date,a.term_start ,a.term_end,
			hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
			,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
			,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour,hb.volume_mult
		from '+@position_no_breakdown+' a

				outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
				and h.dst_group_value_id = '+ CAST(@dst_group_value_id AS VARCHAR(50)) +' and term_date between a.term_start  and a.term_end --and term_date>'''+convert(varchar(10),@as_of_date,120) +'''
		) hb
		'
		
	--print @report_hourly_position_no_breakdown
	exec(@report_hourly_position_no_breakdown)

	create index indxterm_dat_no_break on #term_date_no_break(block_define_id,term_start,term_end)
	
	SET @dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
	
	SET @vol_multiplier='*cast(cast(s.total_volume as numeric(26,12))/nullif(term_hrs.term_hrs,0) as numeric(28,16))'+case when @summary_option in ('x','y')  then ' /hrs.factor '	else '' end
	
	SET @report_hourly_position_no_breakdown='Union all
	select s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,'+case when @summary_option in ('x','y')  then ' hrs.period ' else '0' end +' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
		,cast(isnull(hb.hr1,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END '+ @vol_multiplier +'  AS Hr1
		,cast(isnull(hb.hr2,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr2
		,cast(isnull(hb.hr3,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr3
		,cast(isnull(hb.hr4,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr4
		,cast(isnull(hb.hr5,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr5
		,cast(isnull(hb.hr6,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr6
		,cast(isnull(hb.hr7,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr7
		,cast(isnull(hb.hr8,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr8
		,cast(isnull(hb.hr9,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr9
		,cast(isnull(hb.hr10,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr10
		,cast(isnull(hb.hr11,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr11
		,cast(isnull(hb.hr12,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr12
		,cast(isnull(hb.hr13,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr13'
	
	SET @report_hourly_position_no_breakdown1= ',cast(isnull(hb.hr14,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr14
		,cast(isnull(hb.hr15,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr15
		,cast(isnull(hb.hr16,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr16
		,cast(isnull(hb.hr17,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr17
		,cast(isnull(hb.hr18,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr18
		,cast(isnull(hb.hr19,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr19
		,cast(isnull(hb.hr20,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr20
		,cast(isnull(hb.hr21,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr21
		,cast(isnull(hb.hr22,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr22
		,cast(isnull(hb.hr23,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr23
		,cast(isnull(hb.hr24,0) as numeric(1,0)) *CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END'+ @vol_multiplier+'  AS Hr24
		,'+@dst_column+ @vol_multiplier+' AS Hr25 ' 
	
	SET @report_hourly_position_no_breakdown2=
	CASE WHEN @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w') OR @group_by IN('d')  THEN ',s.source_deal_header_id' ELSE '' END
	+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3
	,s.source_system_book_id4,s.expiration_date ,''y'' AS is_fixedvolume ,deal_status_id 
		 from '+@position_no_breakdown + ' s '
		+' left join #term_date_no_break hb on hb.term_start = s.term_start and hb.term_end=s.term_end  and hb.block_define_id=s.block_define_id --and hb.term_date>''' + @as_of_date +''''
		+case when @summary_option in ('x','y')  then 
	' left join #minute_break hrs on hrs.granularity=982 ' else '' end+'
		outer apply ( select sum(volume_mult) term_hrs from #term_date_no_break h where h.term_start = s.term_start and h.term_end=s.term_end  and h.term_date>''' + @as_of_date +''') term_hrs
	    where 1=1' +@sub_criteria

end

	---------------------------end hourly_position_breakdown=null------------------------------------------------------------
	
	if @physical_financial_flag<>'p' 
	BEGIN 
		SET @dst_column = 'cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0))'  
		--SET @remain_month ='*(CASE WHEN YEAR(hb.term_date)=YEAR(DATEADD(m,1,'''+@as_of_date+''')) AND MONTH(hb.term_date)=MONTH(DATEADD(m,1,'''+@as_of_date+''')) THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)'            	
		SET @remain_month ='*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date+''')) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)'+case when @summary_option in ('x','y')  then ' /hrs.factor '	else '' end    
		
		--SET @dst_column='CASE WHEN (dst.insert_delete)=''i'' THEN isnull(CASE dst.hour WHEN 1 THEN hb.hr1 WHEN 2 THEN hb.hr2 WHEN 3 THEN hb.hr3 WHEN 4 THEN hb.hr4 WHEN 5 THEN hb.hr5 WHEN 6 THEN hb.hr6 WHEN 7 THEN hb.hr7 WHEN 8 THEN hb.hr8 WHEN 9 THEN hb.hr9 WHEN 10 THEN hb.hr10 WHEN 11 THEN hb.hr11 WHEN 12 THEN hb.hr12 WHEN 13 THEN hb.hr13 WHEN 14 THEN hb.hr14 WHEN 15 THEN hb.hr15 WHEN 16 THEN hb.hr16 WHEN 17 THEN hb.hr17 WHEN 18 THEN hb.hr18 WHEN 19 THEN hb.hr19 WHEN 20 THEN hb.hr20 WHEN 21 THEN hb.hr21 WHEN 22 THEN hb.hr22 WHEN 23 THEN hb.hr23 WHEN 24 THEN hb.hr24 END,0) END'              	
		SET @vol_multiplier='/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))'
		
		SET @report_hourly_position_breakdown='select s.curve_id,'+ CASE WHEN @view_name1='vwHourly_position_AllFilter' THEN '-1' ELSE 'ISNULL(s.location_id,-1)' END +' location_id,hb.term_date term_start,'+case when @summary_option in ('x','y')  then ' hrs.period '	else '0' end +' period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr1
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr2
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr3
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr4
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr5
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr6
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr7
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr8
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr9
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr10
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr11
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr12
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr13'
		
		SET @report_hourly_position_breakdown1= ',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr14
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr15
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr16
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr17
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr18
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr19
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr20
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr21
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr22
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr23
			,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))'+ @vol_multiplier +@remain_month+'  AS Hr24
			,(cast(cast(s.calc_volume as numeric(22,10))* '+@dst_column+' as numeric(22,10))) '+ @vol_multiplier +@remain_month+' AS Hr25 ' 
		
		SET @report_hourly_position_breakdown2=
			 CASE WHEN @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w') OR @group_by IN('d')  THEN ',s.source_deal_header_id' ELSE '' END
		+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''y'' AS is_fixedvolume ,deal_status_id ,tz.dst_group_value_id
		from '+@view_name1+'_breakdown s '+CASE WHEN @view_name='vwHourly_position_AllFilter' THEN ' WITH(NOEXPAND) ' ELSE ' (nolock) ' END +' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
			 ' +CASE WHEN @source_deal_header_id IS NOT NULL THEN ' and s.source_deal_header_id IN (' +CAST(@source_deal_header_id AS VARCHAR(MAX)) + ')
			 ' ELSE '' END 
			 +'	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 ' 
			+ CASE WHEN  @deal_status IS NULL AND @source_deal_header_id IS NULL THEN 
			'	INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id ' ELSE '' END 
			 + CASE WHEN isnull(@deal_filter_tbl,'')<>'' THEN ' INNER JOIN '+ @deal_filter_tbl +' flt ON flt.source_deal_header_id=s.source_deal_header_id '   ELSE '' END 
			+' left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			' +CASE WHEN @view_name<>'vwHourly_position_AllFilter' THEN '
			 	LEFT JOIN dbo.vwDealTimezoneContract tz ON tz.source_deal_header_id = s.source_deal_header_id
					AND tz.curve_id = isnull(s.curve_id, -1) AND tz.location_id = -1
			 ' ELSE ' LEFT JOIN time_zones tz ON COALESCE(spcd.time_zone,spcd1.time_zone,'+ CAST( @default_time_zone AS VARCHAR(50)) +') = tz.TIMEZONE_ID' END +'
			outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END AND hbt.dst_group_value_id = tz.dst_group_value_id ) term_hrs
			outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
			where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END  AND hbt.dst_group_value_id = tz.dst_group_value_id) term_hrs_exp
			left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,'+@baseload_block_define_id+') and hb.term_start = s.term_start
			and hb.term_end=s.term_end and hb.dst_group_value_id=tz.dst_group_value_id --and hb.term_date>''' + @as_of_date +'''
			outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
				h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			 outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
			 outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@as_of_date+''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
						AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
						AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month  '
			+case when @summary_option in ('x','y')  then 
				' left join #minute_break hrs on hrs.granularity=982 '
			else '' end+'
		     where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		     AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
		     ' +CASE WHEN @tenor_option <> 'a' THEN ' and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@as_of_date+'''' ELSE '' END + 
			 @sub_criteria
			
		--print @Sql_Select
		--EXEC(@Sql_Select)			
	END
	--select @group_by, @summary_option,@format_option		
	
	IF  @summary_option IN ('d' ,'m','q','a','l')
	BEGIN
	
		SET @volume_clm=''
		SET @volume_clm=
		CASE WHEN @summary_option='l' THEN 
			CASE WHEN @drill_clm_hr IS NOT NULL THEN 'CAST(cast('+case when @group_by='b' then 'hb.'+@drill_clm_hr+'*' else '' end +'vw.'+@drill_clm_hr+' as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*1' ELSE '' END+ ' as numeric(38,20)) Volume_'+@drill_clm_hr+','
			ELSE '('
			END
		WHEN @summary_option = 'm' THEN '('
		ELSE 'SUM('
		END
		
		IF @volume_clm IN ('(','SUM(')
		BEGIN
			SET @volume_clm=@volume_clm + 'ROUND('+ CASE WHEN  @summary_option = 'm' THEN 'SUM(' ELSE '' END +
					'CAST((cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr7 else hb.hr1 end *' else '' end +'vw.hr1 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr8 else hb.hr2 end *' else '' end +'vw.hr2 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr3 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr10 else hb.hr4 end *' else '' end +'vw.hr4 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr11 else hb.hr5 end *' else '' end +'vw.hr5 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr12 else hb.hr6 end *' else '' end +'vw.hr6 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr13 else hb.hr7 end *' else '' end +'vw.hr7 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr14 else hb.hr8 end *' else '' end +'vw.hr8 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr15 else hb.hr9 end *' else '' end +'vw.hr9 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr16 else hb.hr10 end *' else '' end +'vw.hr10 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr17 else hb.hr11 end *' else '' end +'vw.hr11 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr18 else hb.hr12 end *' else '' end +'vw.hr12 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr19 else hb.hr13 end *' else '' end +'vw.hr13 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr20 else hb.hr14 end *' else '' end +'vw.hr14 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr21 else hb.hr15 end *' else '' end +'vw.hr15 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr22 else hb.hr16 end *' else '' end +'vw.hr16 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr23 else hb.hr17 end *' else '' end +'vw.hr17 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr24 else hb.hr18 end *' else '' end +'vw.hr18 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr1 else hb.hr19 end *' else '' end +'vw.hr19 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr2 else hb.hr20 end *' else '' end +'vw.hr20 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr3 else hb.hr21 end *' else '' end +'vw.hr21 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr4 else hb.hr22 end *' else '' end +'vw.hr22 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr5 else hb.hr23 end *' else '' end +'vw.hr23 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')
					+(cast('+case when @group_by='b' then ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr6 else hb.hr24 end *' else '' end +'vw.hr24 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' else '' end +')

					AS NUMERIC(38, 10))  ' + CASE WHEN @summary_option = 'm' THEN ')' ELSE '' END +', ' + @round_value + ' )) Volume'+CASE WHEN @drill_clm_hr IS NOT NULL AND @summary_option IN ('l')  THEN '_'+@drill_clm_hr ELSE '' END  +',' 
			 + CASE @summary_option WHEN 'd' THEN '''Daily'' AS Frequency,'
									WHEN 'm' THEN '''Monthly'' AS Frequency,'
									WHEN 'q' THEN '''Quarterly'' AS Frequency,'
									WHEN 'a' THEN '''Annually'' AS Frequency,'
									ELSE ''						 
			   END 
		END
	END--@summary_option IN ('d' ,'m','q','a','l')
	ELSE 
		SET @volume_clm=
			CASE WHEN @summary_option='m' THEN '''Monthly'' AS Frequency,' WHEN @summary_option='d' THEN '''Daily'' AS Frequency,' WHEN @summary_option='a' THEN '''Annually'' AS Frequency,' WHEN @summary_option='q' THEN '''Quarterly'' AS Frequency,' ELSE '' END +
			'ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr7 else hb.hr1 end *' else '' end +'vw.hr1 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '7' ELSE '1' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr8 else hb.hr2 end *' else '' end +'vw.hr2 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '8' ELSE '2' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr3 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '9' ELSE '3' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr10 else hb.hr4 end *' else '' end +'vw.hr4 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '10' ELSE '4' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr11 else hb.hr5 end *' else '' end +'vw.hr5 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '11' ELSE '5' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr12 else hb.hr6 end *' else '' end +'vw.hr6 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '12' ELSE '6' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr13 else hb.hr7 end *' else '' end +'vw.hr7 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '13' ELSE '7' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr14 else hb.hr8 end *' else '' end +'vw.hr8 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '14' ELSE '8' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr15 else hb.hr9 end *' else '' end +'vw.hr9 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '15' ELSE '9' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr16 else hb.hr10 end *' else '' end +'vw.hr10 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '16' ELSE '10' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr17 else hb.hr11 end *' else '' end +'vw.hr11 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '17' ELSE '11' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr18 else hb.hr12 end *' else '' end +'vw.hr12 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '18' ELSE '12' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr19 else hb.hr13 end *' else '' end +'vw.hr13 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '19' ELSE '13' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr20 else hb.hr14 end *' else '' end +'vw.hr14 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '20' ELSE '14' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr21 else hb.hr15 end *' else '' end +'vw.hr15 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '21' ELSE '15' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr22 else hb.hr16 end *' else '' end +'vw.hr16 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '22' ELSE '16' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr23 else hb.hr17 end *' else '' end +'vw.hr17 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '23' ELSE '17' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr24 else hb.hr18 end *' else '' end +'vw.hr18 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '24' ELSE '18' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr1 else hb.hr19 end *' else '' end +'vw.hr19 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '1' ELSE '19' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr2 else hb.hr20 end *' else '' end +'vw.hr20 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '2' ELSE '20' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr3 else hb.hr21 end *' else '' end +'vw.hr21 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '3' ELSE '21' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr4 else hb.hr22 end *' else '' end +'vw.hr22 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '4' ELSE '22' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr5 else hb.hr23 end *' else '' end +'vw.hr23 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '5' ELSE '23' END  +',
			 ROUND((cast(SUM(cast('+ case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb1.hr6 else hb.hr24 end *' else '' end +'vw.hr24 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr'+ CASE WHEN ISNULL(@col_7_to_6,'n')='y' AND @format_option<>'r' THEN '6' ELSE '24' END  +',
			 '+CASE WHEN @format_option ='r' THEN +'ROUND((cast(SUM(cast('+case WHEN @group_by='b' THEN ' case when vw.commodity_id=-1 AND vw.is_fixedvolume =''n'' then hb.hr9 else hb.hr3 end *' else '' end +'vw.hr25 as numeric(16,8))'+CASE WHEN @convert_uom IS NOT NULL THEN '*cast(uc.conversion_factor as numeric(21,16))' ELSE '' END+') as numeric(38,20))), ' + @round_value + ') Hr25,' ELSE '' END

		SET @Sql_Select=  
		CASE WHEN @summary_option IN('l') THEN 
			'  SELECT vw.source_deal_header_id,vw.deal_date DealDate, isnull(spcd1.curve_name ,spcd.curve_name) [Index],ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name)) [Location],(vw.term_start) [Term],vw.Period,
				'+@volume_clm+' su.uom_name [UOM],
			   vw.counterparty_id,vw.commodity_id,vw.physical_financial_flag [Physical/Financial],spcd.block_define_id,'+CASE WHEN @convert_uom IS NOT NULL THEN 'uc.conversion_factor' ELSE '1' END+' conversion_factor,vw.dst_group_value_id   INTO '+@hour_pivot_table
		 ELSE
			' SELECT ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name)) [Location], 
			'+CASE WHEN @group_by IN ('i') THEN  'isnull(spcd1.curve_name ,spcd.curve_name)' 
				+CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
						 WHEN @group_by='g' THEN 'ISNULL(sdv1.code,isnull(spcd1.curve_name ,spcd.curve_name))' +CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
						 WHEN @group_by='c' THEN 'ISNULL(sdv.code,isnull(spcd1.curve_name ,spcd.curve_name)) '+CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
						 WHEN @group_by='r' THEN 'ISNULL(sdv2.code,isnull(spcd1.curve_name ,spcd.curve_name))'+CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
						 WHEN @group_by='z' THEN 'ISNULL(mjr.location_name,isnull(spcd1.curve_name ,spcd.curve_name))'+CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
						 WHEN @group_by='d' THEN  'vw.source_deal_header_id,ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name))' +CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
						 WHEN @group_by='b' THEN  'isnull(grp.block_name,isnull(spcd1.curve_name ,spcd.curve_name))' +CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END
				 ELSE 
					'ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name))'+CASE WHEN @group_by IN ('z','g','c','r','l','b') AND  @summary_option NOT IN ('j','l')  THEN @column_level ELSE ' [Index]' END 
				END
				+',CASE WHEN vw.physical_financial_flag = ''f'' THEN ''Financial'' WHEN vw.physical_financial_flag = ''P'' THEN ''Physical'' ELSE '''' END [Physical/Financial],'--+case when @group_by='b' then 'COALESCE(spcd1.udf_block_group_id,spcd.udf_block_group_id) udf_block_group_id,' else '' end
			    +CASE WHEN (@format_option ='r' AND @summary_option IN ('h','x','y'))  THEN 'vw.term_start' ELSE CASE WHEN @summary_option='m' THEN 'convert(varchar(7),vw.term_start,120)' WHEN @summary_option='a' THEN 'year(vw.term_start)' WHEN @summary_option='q' THEN 'dbo.FNATermGrouping(vw.term_start,''q'')'  ELSE 'dbo.FNADATEFORMAT(vw.term_start)' END END+' [Term], '
			    +CASE WHEN (@summary_option IN ('x','y'))  THEN 'vw.period Period,' ELSE '' END+ @volume_clm+' su.uom_name [UOM]'--,su.source_uom_id 
			    +CASE WHEN (@format_option ='r' AND @summary_option IN ('h','x','y')) THEN ',MAX(vw.commodity_id) commodity_id,MAX(vw.is_fixedvolume) is_fixedvolume,su.source_uom_id,isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id) source_curve_def_id'
				+ case WHEN @group_by='b' THEN ',isnull(grp.id,isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id)) group_id' else '' end +',max(vw.dst_group_value_id) dst_group_value_id INTO '+@hour_pivot_table ELSE  @str_batch_table END
		END
		+' FROM  '
		
		SET @subqry='select s.curve_id,s.location_id,s.term_start,'+
				+case  @summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) END else  COALESCE(hrs.period,s.period) end'
						when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
			else '0' end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
				+case  @summary_option when 'y' then  
						' s.hr1/COALESCE(hrs.factor,1) hr1, s.hr2/COALESCE(hrs.factor,1) hr2
						 ,s.hr3/COALESCE(hrs.factor,1) hr3, s.hr4/COALESCE(hrs.factor,1) hr4
						, s.hr5/COALESCE(hrs.factor,1) hr5, s.hr6/COALESCE(hrs.factor,1) hr6
						, s.hr7/COALESCE(hrs.factor,1) hr7, s.hr8/COALESCE(hrs.factor,1) hr8
						, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
						, s.hr11/COALESCE(hrs.factor,1) hr11, s.hr12/COALESCE(hrs.factor,1) hr12
						, s.hr13/COALESCE(hrs.factor,1) hr13, s.hr14/COALESCE(hrs.factor,1) hr14
						, s.hr15/COALESCE(hrs.factor,1) hr15, s.hr16/COALESCE(hrs.factor,1) hr16
						, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
						, s.hr19/COALESCE(hrs.factor,1) hr19, s.hr20/COALESCE(hrs.factor,1) hr20
						, s.hr21/COALESCE(hrs.factor,1) hr21, s.hr22/COALESCE(hrs.factor,1) hr22
						,s.hr23/COALESCE(hrs.factor,1) hr23, s.hr24/COALESCE(hrs.factor,1) hr24
						, s.hr25/COALESCE(hrs.factor,1) hr25'				
					when 'x' then  
						' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1) hr2
						 ,s.hr3 /COALESCE(hrs.factor,m30.factor,1) hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1) hr4
						, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1) hr6
						, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1) hr8
						, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
						, s.hr11 /COALESCE(hrs.factor,m30.factor,1) hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1) hr12
						, s.hr13 /COALESCE(hrs.factor,m30.factor,1) hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1) hr14
						, s.hr15 /COALESCE(hrs.factor,m30.factor,1) hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1) hr16
						, s.hr17 /COALESCE(hrs.factor,m30.factor,1) hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1) hr18
						, s.hr19 /COALESCE(hrs.factor,m30.factor,1) hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1) hr20
						, s.hr21 /COALESCE(hrs.factor,m30.factor,1) hr21, s.hr22 /COALESCE(hrs.factor,m30.factor,1) hr22
						, s.hr23 /COALESCE(hrs.factor,m30.factor,1) hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1) hr24
						, s.hr25/COALESCE(hrs.factor,m30.factor,1) hr25'				
				else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16
				,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
				end
			+ CASE WHEN @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w')  OR @group_by IN('d') THEN ',s.source_deal_header_id' ELSE '' END 
			+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
			,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id ,tz.dst_group_value_id
			INTO '+ @position_deal +'  
			from '+@view_name+' s '+CASE WHEN @view_name='vwHourly_position_AllFilter' THEN ' WITH(NOEXPAND) ' ELSE ' (nolock) ' END 
			+' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
				AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
				AND bk.source_system_book_id4=s.source_system_book_id4 
			left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id 	
		' +CASE WHEN @view_name<>'vwHourly_position_AllFilter' THEN '
			LEFT JOIN dbo.vwDealTimezoneContract tz ON tz.source_deal_header_id = s.source_deal_header_id
				AND tz.curve_id = isnull(s.curve_id, -1) AND tz.location_id = -1
			' ELSE ' LEFT JOIN time_zones tz ON COALESCE(spcd.time_zone,'+ CAST( @default_time_zone AS VARCHAR(50)) +') = tz.TIMEZONE_ID' END
			+ CASE WHEN  @deal_status IS NULL AND @source_deal_header_id IS NULL THEN 
			' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
			+ CASE WHEN ISNULL(@deal_filter_tbl,'')<>'' THEN ' INNER JOIN '+ @deal_filter_tbl +' flt ON flt.source_deal_header_id=s.source_deal_header_id ' ELSE '' END 
			+case  @summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
				when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
								left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
				else ''
			end
	+' WHERE 1=1' 
	+CASE WHEN @tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+'''' ELSE '' END +  @sub_criteria 
		
		
		
		SET @subqry1='
			union all
			select s.curve_id,s.location_id,s.term_start,'
				+case  @summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end'
						when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
						else '0'
				end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
				+case  @summary_option	when 'y' then  
						' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
						 ,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
						,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
						, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
						, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
						, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
						, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
						, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
						, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
						, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
						, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
						, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
						, s.hr25/COALESCE(hrs.factor,1)  hr25'				
					when 'x' then  
						' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
						 s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
						, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
						, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
						, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
						, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
						, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
						, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
						, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
						, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
						, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
						, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
						, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25'				
					
					else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
				end
			+ CASE WHEN @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w') OR @group_by IN('d')  THEN ',s.source_deal_header_id' ELSE '' END 
			+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
				 ,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,tz.dst_group_value_id
			from '+@view_name1+'_profile s '+CASE WHEN @view_name='vwHourly_position_AllFilter' THEN ' WITH(NOEXPAND) ' ELSE ' (nolock) ' END 
			+' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
				AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
				AND bk.source_system_book_id4=s.source_system_book_id4 
				left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id 
			' +CASE WHEN @view_name<>'vwHourly_position_AllFilter' THEN '
			 	LEFT JOIN dbo.vwDealTimezoneContract tz ON tz.source_deal_header_id = s.source_deal_header_id
					AND tz.curve_id = isnull(s.curve_id, -1) AND tz.location_id = isnull(s.location_id, -1)
			 ' ELSE ' LEFT JOIN time_zones tz ON COALESCE(spcd.time_zone,'+ CAST( @default_time_zone AS VARCHAR(50)) +') = tz.TIMEZONE_ID' END 
			+ CASE WHEN  @deal_status IS NULL AND @source_deal_header_id IS NULL THEN 
			' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
			+ CASE WHEN ISNULL(@deal_filter_tbl,'')<>'' THEN ' INNER JOIN '+ @deal_filter_tbl +' flt ON flt.source_deal_header_id=s.source_deal_header_id ' ELSE '' END 
			+case  @summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
									when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
													left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
									else ''
			end
			+' WHERE  1=1 ' +CASE WHEN @tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+'''' ELSE '' END
			+ @sub_criteria 
				
			
			
			SET @subqry2='
			union all
			select s.curve_id,s.location_id,s.term_start,'
				+case  @summary_option when 'y' then  'case when s.granularity=987 then case s.period when 15 then 0 when 45 then 30 else COALESCE(hrs.period,s.period) end else  COALESCE(hrs.period,s.period) end'
						when 'x' then  'COALESCE(hrs.period,m30.period,s.period)'
						else '0'
				end+' Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,' 
				+case  @summary_option	when 'y' then  
						' s.hr1/COALESCE(hrs.factor,1)  hr1, s.hr2/COALESCE(hrs.factor,1) hr2
						 ,s.hr3/COALESCE(hrs.factor,1)  hr3, s.hr4/COALESCE(hrs.factor,1) hr4
						,s.hr5/COALESCE(hrs.factor,1)  hr5, s.hr6/COALESCE(hrs.factor,1) hr6
						, s.hr7/COALESCE(hrs.factor,1)  hr7, s.hr8/COALESCE(hrs.factor,1) hr8
						, s.hr9/COALESCE(hrs.factor,1) hr9, s.hr10/COALESCE(hrs.factor,1) hr10
						, s.hr11/COALESCE(hrs.factor,1)  hr11, s.hr12/COALESCE(hrs.factor,1) hr12
						, s.hr13/COALESCE(hrs.factor,1)  hr13, s.hr14/COALESCE(hrs.factor,1) hr14
						, s.hr15/COALESCE(hrs.factor,1)  hr15, s.hr16/COALESCE(hrs.factor,1) hr16
						, s.hr17/COALESCE(hrs.factor,1) hr17, s.hr18/COALESCE(hrs.factor,1) hr18
						, s.hr19/COALESCE(hrs.factor,1)  hr19, s.hr20/COALESCE(hrs.factor,1) hr20
						, s.hr21/COALESCE(hrs.factor,1)  hr21,s.hr22/COALESCE(hrs.factor,1) hr22
						, s.hr23/COALESCE(hrs.factor,1)  hr23, s.hr24/COALESCE(hrs.factor,1) hr24
						, s.hr25/COALESCE(hrs.factor,1)  hr25'				
					when 'x' then  
						' s.hr1 /COALESCE(hrs.factor,m30.factor,1) hr1, s.hr2 /COALESCE(hrs.factor,m30.factor,1)  hr2,
						 s.hr3 /COALESCE(hrs.factor,m30.factor,1)  hr3, s.hr4 /COALESCE(hrs.factor,m30.factor,1)  hr4
						, s.hr5 /COALESCE(hrs.factor,m30.factor,1) hr5, s.hr6 /COALESCE(hrs.factor,m30.factor,1)  hr6
						, s.hr7 /COALESCE(hrs.factor,m30.factor,1) hr7, s.hr8 /COALESCE(hrs.factor,m30.factor,1)  hr8
						, s.hr9 /COALESCE(hrs.factor,m30.factor,1) hr9, s.hr10 /COALESCE(hrs.factor,m30.factor,1) hr10
						, s.hr11 /COALESCE(hrs.factor,m30.factor,1)  hr11, s.hr12 /COALESCE(hrs.factor,m30.factor,1)  hr12
						, s.hr13 /COALESCE(hrs.factor,m30.factor,1)  hr13, s.hr14 /COALESCE(hrs.factor,m30.factor,1)  hr14
						, s.hr15 /COALESCE(hrs.factor,m30.factor,1)  hr15, s.hr16 /COALESCE(hrs.factor,m30.factor,1)  hr16
						, s.hr17 /COALESCE(hrs.factor,m30.factor,1)  hr17, s.hr18 /COALESCE(hrs.factor,m30.factor,1)  hr18
						, s.hr19 /COALESCE(hrs.factor,m30.factor,1)  hr19, s.hr20 /COALESCE(hrs.factor,m30.factor,1)  hr20
						, s.hr21 /COALESCE(hrs.factor,m30.factor,1)  hr21,s.hr22 /COALESCE(hrs.factor,m30.factor,1)  hr22
						, s.hr23 /COALESCE(hrs.factor,m30.factor,1)  hr23, s.hr24 /COALESCE(hrs.factor,m30.factor,1)  hr24
						, s.hr25 /COALESCE(hrs.factor,m30.factor,1)  hr25'				
					else 's.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25'
				end
			+ CASE WHEN @source_deal_header_id IS NOT NULL OR @summary_option IN('l','j','w') OR @group_by IN('d')  THEN ',s.source_deal_header_id' ELSE '' END 
			+',s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
				,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,tz.dst_group_value_id
			from '+replace(@view_name,'_deal','')+'_financial s '+CASE WHEN @view_name='vwHourly_position_AllFilter' THEN ' WITH(NOEXPAND) ' ELSE ' (nolock) ' END 
			+' INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
				AND bk.source_system_book_id2=s.source_system_book_id2	AND bk.source_system_book_id3=s.source_system_book_id3
				AND bk.source_system_book_id4=s.source_system_book_id4 
			left join source_price_curve_def spcd on spcd.source_curve_def_id=s.curve_id
		' +CASE WHEN @view_name<>'vwHourly_position_AllFilter' THEN '
			LEFT JOIN dbo.vwDealTimezoneContract tz ON tz.source_deal_header_id = s.source_deal_header_id
				AND tz.curve_id = isnull(s.curve_id, -1) AND tz.location_id = isnull(s.location_id, -1)
		' ELSE ' LEFT JOIN time_zones tz ON COALESCE(spcd.time_zone,'+ CAST( @default_time_zone AS VARCHAR(50)) +') = tz.TIMEZONE_ID' END 
			+ CASE WHEN  @deal_status IS NULL AND @source_deal_header_id IS NULL THEN 
			' INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id' ELSE '' END
			+ CASE WHEN ISNULL(@deal_filter_tbl,'')<>'' THEN ' INNER JOIN '+ @deal_filter_tbl +' flt ON flt.source_deal_header_id=s.source_deal_header_id ' ELSE '' END 
			+case  @summary_option	when 'y' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982 '
									when 'x' then  ' left join #minute_break hrs on s.granularity=hrs.granularity and hrs.granularity=982
													left join #minute_break m30 on s.granularity=m30.granularity and m30.granularity=989 '
		else '' end
			+' WHERE  1=1 ' +CASE WHEN @tenor_option <> 'a' THEN ' AND s.expiration_date>'''+@as_of_date+''' AND s.term_start>'''+@as_of_date+'''' ELSE '' END
			+ @sub_criteria 			
			
			
		IF @physical_financial_flag<>'x'
			SET @report_hourly_position_breakdown	='	union all ' + @report_hourly_position_breakdown	
		ELSE
		BEGIN
			SET @report_hourly_position_breakdown	=''
			SET @report_hourly_position_breakdown1	=''
			SET @report_hourly_position_breakdown2	=''
			SET @report_hourly_position_breakdown3	=''
		END	
				
		SET @report_hourly_position_breakdown3=
				'  vw '
		+ CASE WHEN  @deal_status IS NULL AND @source_deal_header_id IS NULL THEN '
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = vw.deal_status_id' ELSE '' END +'
					INNER JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=vw.curve_id 
			LEFT JOIN  source_price_curve_def spcd1 (nolock) ON  spcd1.source_curve_def_id='
		+CASE WHEN @proxy_curve_view = 'y' THEN  'spcd.proxy_curve_id' ELSE 'spcd.source_curve_def_id' END
					+case when @group_by='b' then 
						'
			left join block_type_group grp (nolock) ON isnull(spcd1.udf_block_group_id,spcd.udf_block_group_id)=grp.block_type_group_id 
			left JOIN hour_block_term hb (nolock)  ON hb.block_define_id=COALESCE(grp.hourly_block_id,'+@baseload_block_define_id+') AND  hb.block_type=COALESCE(grp.block_type_id,'+@baseload_block_type+') and vw.term_start=hb.term_date AND hb.dst_group_value_id = vw.dst_group_value_id
			left JOIN hour_block_term hb1 (nolock)  ON hb.block_define_id=hb1.block_define_id AND  hb.block_type=hb1.block_type and hb.term_date=hb1.term_date-1 AND hb1.dst_group_value_id = vw.dst_group_value_id
		' else '' end	+'
					LEFT JOIN source_minor_location sml (nolock) ON sml.source_minor_location_id=vw.location_id
					left join static_data_value sdv1 (nolock) on sdv1.value_id=sml.grid_value_id
					left join static_data_value sdv (nolock)  on sdv.value_id=sml.country
					left join static_data_value sdv2 (nolock) on sdv2.value_id=sml.region
					left join source_major_location mjr (nolock) on  sml.source_major_location_ID=mjr.source_major_location_ID
					left join source_counterparty scp (nolock) on vw.counterparty_id = scp.source_counterparty_id	'
			+CASE WHEN @convert_uom IS NOT NULL THEN ' LEFT JOIN #unit_conversion uc ON uc.convert_from_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id) AND uc.convert_to_uom_id='+CAST(@convert_uom AS VARCHAR) +' LEFT JOIN source_uom su on su.source_uom_id='+CAST(@convert_uom AS VARCHAR)  
				ELSE  ' LEFT JOIN source_uom su (nolock) on su.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)'
			END
			+'   WHERE 1=1 '  +
			CASE WHEN @term_start IS NOT NULL THEN ' AND vw.term_start>='''+CAST(@term_start AS VARCHAR)+''' AND vw.term_start<='''+CAST(@term_END AS VARCHAR)+'''' ELSE '' END  
			+ CASE WHEN @parent_counterparty IS NOT NULL THEN ' AND  scp.parent_counterparty_id = ' + CAST(@parent_counterparty AS VARCHAR) ELSE  '' END
			+CASE WHEN @counterparty IS NOT NULL THEN ' AND vw.counterparty_id IN (' + @counterparty + ')' ELSE '' END
			+CASE WHEN @commodity IS NOT NULL THEN ' AND vw.commodity_id IN('+@commodity+')' ELSE '' END
			+CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND vw.source_system_book_id1 ='+CAST(@source_system_book_id1 AS VARCHAR) ELSE '' END
			+CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND vw.source_system_book_id2 ='+CAST(@source_system_book_id2 AS VARCHAR) ELSE '' END
			+CASE WHEN @source_system_book_id3 IS NOT NULL THEN ' AND vw.source_system_book_id3 ='+CAST(@source_system_book_id3 AS VARCHAR) ELSE '' END
			+CASE WHEN @source_system_book_id4 IS NOT NULL THEN ' AND vw.source_system_book_id4 ='+CAST(@source_system_book_id4 AS VARCHAR) ELSE '' END
			+CASE WHEN @curve_id IS NOT NULL THEN ' AND vw.curve_id IN('+@curve_id+')' ELSE '' END
			+CASE WHEN @drill_uom_id IS NOT NULL THEN ' AND ISNULL(spcd.display_uom_id,spcd.uom_id)='+CAST(@drill_uom_id AS VARCHAR)  ELSE '' END
			+CASE WHEN @location_id IS NOT NULL THEN ' AND vw.location_id IN('+@location_id+')' ELSE '' END
			+CASE WHEN @tenor_option <> 'a' THEN ' AND vw.expiration_date>'''+@as_of_date+''' AND vw.term_start>'''+@as_of_date+'''' ELSE '' END  
			+CASE WHEN @drill_location_id IS NOT NULL THEN ' AND vw.location_id= '+cast(@drill_location_id as varchar) ELSE '' END
			+CASE WHEN @drill_index_id IS NOT NULL AND (@group_by='i' OR @physical_financial_flag='f') THEN  ' AND COALESCE('+case when  @group_by IN('b') and  @missing_data='n' then 'grp.id,' else '' end + 'spcd1.source_curve_def_id ,spcd.source_curve_def_id)='+CAST(@drill_index_id AS VARCHAR)
					WHEN @drill_index_id IS NOT NULL AND (@group_by IN ('c') AND @physical_financial_flag='p') THEN  ' and ISNULL(sml.country,spcd.source_curve_def_id)='+CAST(@drill_index_id AS VARCHAR)
					WHEN @drill_index_id IS NOT NULL AND (@group_by IN ('r') AND @physical_financial_flag='p') THEN  ' and ISNULL(sml.region,spcd.source_curve_def_id)='+CAST(@drill_index_id AS VARCHAR)
					WHEN @drill_index_id IS NOT NULL AND (@group_by IN ('g') AND @physical_financial_flag='p') THEN  ' and ISNULL(sdv1.value_id,spcd.source_curve_def_id)='+CAST(@drill_index_id AS VARCHAR)
					WHEN @drill_index_id IS NOT NULL AND (@group_by='z' AND @physical_financial_flag='p') THEN  ' and ISNULL(mjr.source_major_location_ID,spcd.source_curve_def_id)='+CAST(@drill_index_id AS VARCHAR)
					WHEN @drill_index_id IS NOT NULL AND @group_by IN('l') AND @physical_financial_flag='p' THEN ' AND ISNULL(vw.location_id,spcd.source_curve_def_id)='+CAST(@drill_index_id AS VARCHAR) 
					WHEN @drill_index_id IS NOT NULL AND @group_by IN('b') then case when @missing_data='y'  THEN ' AND isnull(grp.id,isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id))=' else ' and  grp.id=' end +CAST(@drill_index_id AS VARCHAR) ELSE '' END  
			+CASE WHEN @physical_financial_flag <>'b' THEN ' AND vw.physical_financial_flag='''+@physical_financial_flag+'''' ELSE '' END
			+CASE WHEN @drill_term IS NOT NULL THEN CASE WHEN @drill_freq='m' THEN ' AND convert(varchar(7),vw.term_start,120)=convert(varchar(7),'''+@drill_term+''',120)' WHEN @drill_freq IN('a','q') THEN ' and (vw.term_start between '''+@drill_start +''' and '''+ @drill_end+''')' ELSE ' AND vw.term_start='''+@drill_term+'''' END ELSE '' END  
			+CASE WHEN @country IS NOT NULL THEN ' AND sdv.value_id='+ CAST(@country AS VARCHAR) ELSE '' END
			+CASE WHEN @region IS NOT NULL THEN ' AND sdv2.value_id='+ CAST(@region AS VARCHAR) ELSE '' END
			+CASE WHEN @location_group IS NOT NULL THEN ' AND mjr.source_major_location_id='+ CAST(@location_group AS VARCHAR) ELSE '' END
			+CASE WHEN @location_grid IS NOT NULL THEN ' AND sdv1.value_id='+ CAST(@location_grid AS VARCHAR) ELSE '' END
 			+CASE WHEN @deal_status IS NOT NULL THEN ' AND deal_status_id IN('+@deal_status+')' ELSE '' END
			+CASE WHEN  @summary_option IN('l') THEN ''
			ELSE 
				' GROUP BY ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name)),' +CASE WHEN (@format_option ='r' AND @summary_option in('h','x','y')) THEN 'isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),' ELSE '' END 
					 +CASE WHEN @group_by='i' THEN 'isnull(spcd1.curve_name ,spcd.curve_name)' 
		 				WHEN @group_by='g' THEN 'ISNULL(sdv1.code,isnull(spcd1.curve_name ,spcd.curve_name))' 
						WHEN @group_by='c' THEN 'ISNULL(sdv.code,isnull(spcd1.curve_name ,spcd.curve_name))' 
						WHEN @group_by='r' THEN 'ISNULL(sdv2.code,isnull(spcd1.curve_name ,spcd.curve_name))' 
						WHEN @group_by='z' THEN 'ISNULL(mjr.location_name,isnull(spcd1.curve_name ,spcd.curve_name))' 
						WHEN @group_by='d' THEN CASE WHEN @summary_option IN('w','c') THEN 'isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),vw.location_id,' ELSE '' END + 'vw.source_deal_header_id,ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name))' 
						WHEN @group_by='b' THEN 'grp.id,isnull(grp.block_name,isnull(spcd1.curve_name ,spcd.curve_name))' 
					 ELSE ' ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name))' END+', '
					 +CASE WHEN @summary_option='m'  THEN 'convert(varchar(7),vw.term_start,120)' WHEN @summary_option='a'  THEN 'year(vw.term_start)'  WHEN @summary_option='q' THEN  'dbo.[FNATermGrouping](vw.term_start,''q'')'  WHEN @summary_option='d' THEN  'vw.term_start' 
						 ELSE  'vw.term_start' END +CASE WHEN (@summary_option IN ('x','y'))  THEN ',vw.period' ELSE '' END	 
					  +',su.uom_name,su.source_uom_id,vw.physical_financial_flag'  --,vw.commodity_id
					+CASE WHEN @group_by IN('d') THEN '' ELSE
						' ORDER BY '+CASE WHEN @group_by='i'  THEN 'isnull(spcd1.curve_name ,spcd.curve_name)'  
										WHEN @group_by='g' THEN 'ISNULL(sdv1.code,isnull(spcd1.curve_name ,spcd.curve_name))' 
										WHEN @group_by='c' THEN 'ISNULL(sdv.code,isnull(spcd1.curve_name ,spcd.curve_name))' 
										WHEN @group_by='r' THEN 'ISNULL(sdv2.code,isnull(spcd1.curve_name ,spcd.curve_name))' 
										WHEN @group_by='z' THEN 'ISNULL(mjr.location_name,isnull(spcd1.curve_name ,spcd.curve_name))' 
										WHEN @group_by='b' THEN 'isnull(grp.block_name,isnull(spcd1.curve_name ,spcd.curve_name))'
									 ELSE 'ISNULL(sml.location_name,isnull(spcd1.curve_name ,spcd.curve_name))' END
						 + CASE WHEN @summary_option IN ('d','h','c','x','y') THEN ',vw.term_start'  ELSE ',3' END 
						 +CASE WHEN (@summary_option IN ('x','y'))  THEN ',vw.period' ELSE '' END
					END 
			END
	--*/
	
		set @report_hourly_position_no_breakdown=isnull(@report_hourly_position_no_breakdown,'')
		set @report_hourly_position_no_breakdown1= isnull(@report_hourly_position_no_breakdown1,'')
		set @report_hourly_position_no_breakdown2=isnull(@report_hourly_position_no_breakdown2,'')

		--PRINT @subqry
		--PRINT @subqry1
		--PRINT @subqry2

		--PRINT @report_hourly_position_breakdown
		--PRINT @report_hourly_position_breakdown1
		--PRINT @report_hourly_position_breakdown2
		--print @report_hourly_position_no_breakdown
		--print @report_hourly_position_no_breakdown1
		--print @report_hourly_position_no_breakdown2
		--EXEC spa_print @hypo_breakdown
		--EXEC spa_print @hypo_breakdown1
		--EXEC spa_print @hypo_breakdown2

		exec(@subqry +@subqry1+@subqry2+ @report_hourly_position_breakdown+ @report_hourly_position_breakdown1+ @report_hourly_position_breakdown2
		+ @report_hourly_position_no_breakdown+@report_hourly_position_no_breakdown1+@report_hourly_position_no_breakdown2
		+@hypo_breakdown+@hypo_breakdown1+@hypo_breakdown2)
		
		
		exec('CREATE INDEX indx_tmp_subqry1'+@batch_process_id+' ON '+@position_deal +'(curve_id);
		CREATE INDEX indx_tmp_subqry2'+@batch_process_id+' ON '+@position_deal +'(location_id);
		CREATE INDEX indx_tmp_subqry3'+@batch_process_id+' ON '+@position_deal +'(counterparty_id)')
	
		--PRINT (@Sql_Select +@position_deal)
		--PRINT @report_hourly_position_breakdown3
		
		
		exec( @Sql_Select+@position_deal+@report_hourly_position_breakdown3)
	
--	END
	
	--print 'iiiiiiiiiiiiiiiiiiii'
	
	IF @summary_option IN('l') --3rd drill down level
	BEGIN
		EXEC('CREATE INDEX index_'+@temp_process_id+'_33 ON ' + @hour_pivot_table +'(source_deal_header_id)')

		SET @Sql_Select='
				SELECT 
				'+CASE WHEN @summary_option='l' THEN 'dbo.FNAHyperLinkText(10131024,cast(sdh.source_deal_header_id as VARCHAR),sdh.source_deal_header_id)' ELSE 'sdh.source_deal_header_id' END +' AS [Deal ID],
				'+CASE WHEN @summary_option='l' THEN '' ELSE 'p.block_define_id,' END+'MAX(deal_id)RefID,convert(varchar(10),MAX(p.[DealDate]),'+@region_id+') [Deal Date], 
				MAX(scp.counterparty_name) [Counterparty],'+  CASE WHEN  @drill_clm_hr IS NOT NULL THEN 'MAX(p.[Index])'  ELSE 'p.[Index]' END + '[Index] ,
					MAX(p.[Location]) [Location],
				'+CASE WHEN @summary_option='l' THEN CASE WHEN  @drill_clm_hr IS NOT NULL THEN ' convert(varchar(10),Term,'+@region_id+') ' ELSE ' convert(varchar(10),convert(varchar(8),Term,120)+''01'','+@region_id+') ' END ELSE ' Term ' END +' [Term],
					SUM('+'Volume'+CASE WHEN  @drill_clm_hr IS NOT NULL THEN '_'+@drill_clm_hr ELSE '' END +')*MAX(p.conversion_factor) '+CASE WHEN  @drill_clm_hr IS NOT NULL THEN @drill_clm_hr ELSE 'Volume' END+',MAX(p.[UOM]) UOM
					'	+@str_batch_table+ ' 
			 FROM '+@hour_pivot_table+' p
			' + case when @whatif_criteria_id IS NOT NULL then 
				' outer apply (
					select source_deal_header_id,deal_id,counterparty_id from dbo.source_deal_header where source_deal_header_id=p.source_deal_header_id 
					union all
					select source_deal_header_id,deal_id,counterparty_id from '+@hypo_deal_header +' where source_deal_header_id=p.source_deal_header_id 
				) sdh'
			else 
			' left join dbo.source_deal_header sdh (nolock) on sdh.source_deal_header_id=p.source_deal_header_id '
			end +'
				LEFT JOIN source_counterparty scp (nolock) on  sdh.counterparty_id=scp.source_counterparty_id
			WHERE 1=1'		
			    --+CASE WHEN @drill_clm_hr IS NOT NULL THEN ' AND REPLACE(p.[Hour],''hr'','''')='+REPLACE(@drill_clm_hr,'hr','') ELSE '' END+
 				+ CASE WHEN @parent_counterparty IS NOT NULL THEN ' AND  scp.parent_counterparty_id = ' + CAST(@parent_counterparty AS VARCHAR) ELSE  '' END
 				+CASE WHEN @drill_term IS NOT NULL AND @summary_option IN('l') THEN  ' AND Term='''+@drill_term+''''  ELSE '' END  
 				
			  +' GROUP BY 
				sdh.source_deal_header_id,'+CASE WHEN @summary_option='l' THEN CASE WHEN  @drill_clm_hr IS NOT NULL THEN ' Term ' ELSE ' convert(varchar(8),Term,120),p.[Index]' END ELSE 'Term' END
			  +CASE WHEN @summary_option='l' THEN '' ELSE ',p.block_define_id' END+
			  + ' order by sdh.source_deal_header_id,'+CASE WHEN  @drill_clm_hr IS NOT NULL THEN ' Term' ELSE ' p.[Index],convert(varchar(8),Term,120) ' END
			 
		--PRINT (@Sql_Select)
		EXEC(@Sql_Select)
				 
	END
--	/*
	ELSE IF @format_option='r' AND @summary_option IN('h','x','y')
	BEGIN	
		
		declare @commodity_str varchar(max),@report_hourly_position_breakdown_0 varchar(max),@commodity_str1 varchar(max)
		--PRINT '@str_batch_table:' + @str_batch_table
		
		SET @report_hourly_position_breakdown='SELECT '
			+ CASE  WHEN @group_by='d' THEN 's.source_deal_header_id'  
					WHEN @group_by='b' THEN 's.BlockName' 
					ELSE  CASE WHEN @group_by IN ('z','g','c','r','l','b')  THEN @column_level ELSE ' s.[Index]' END 
			END
			+ ',s.[physical/Financial],s.commodity_id,s.[Term]'+ case when @summary_option IN('x','y') then ',s.Period' else '' end+',s.is_fixedvolume,cast((s.hr25) AS NUMERIC(38,20)) dst_hr,
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr19 ELSE s.hr1 END - CASE WHEN hb.add_dst_hour=1 THEN isnull(s.hr25,0) ELSE 0 END ) AS NUMERIC(38,20)) [1],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr20 ELSE s.hr2 END - CASE WHEN hb.add_dst_hour=2 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [2],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr21 ELSE s.hr3 END - CASE WHEN hb.add_dst_hour=3 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [3],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr22 ELSE s.hr4 END - CASE WHEN hb.add_dst_hour=4 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [4],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr23 ELSE s.hr5 END - CASE WHEN hb.add_dst_hour=5 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [5],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr24 ELSE s.hr6 END - CASE WHEN hb.add_dst_hour=6 THEN isnull(s.hr25,0) ELSE 0 END) AS NUMERIC(38,20)) [6],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr1 ELSE s.hr7 END - CASE WHEN hb.add_dst_hour=7 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [7],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr2 ELSE s.hr8 END - CASE WHEN hb.add_dst_hour=8 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [8],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr3 ELSE s.hr9 END - CASE WHEN hb.add_dst_hour=9 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [9],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr4 ELSE  s.hr10 END - CASE WHEN hb.add_dst_hour=10 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [10],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr5 ELSE  s.hr11 END - CASE WHEN hb.add_dst_hour=11 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [11],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr6 ELSE  s.hr12 END - CASE WHEN hb.add_dst_hour=12 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [12],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr7 ELSE  s.hr13 END - CASE WHEN hb.add_dst_hour=13 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [13],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr8 ELSE  s.hr14 END - CASE WHEN hb.add_dst_hour=14 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [14],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr9 ELSE  s.hr15 END - CASE WHEN hb.add_dst_hour=15 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [15],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr10 ELSE s.hr16 END - CASE WHEN hb.add_dst_hour=16 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [16],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr11 ELSE s.hr17 END - CASE WHEN hb.add_dst_hour=17 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [17],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr12 ELSE s.hr18 END - CASE WHEN hb.add_dst_hour=18 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [18],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr13 ELSE s.hr19 END - CASE WHEN hb.add_dst_hour=19 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [19],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr14 ELSE s.hr20 END - CASE WHEN hb.add_dst_hour=20 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [20],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr15 ELSE s.hr21 END - CASE WHEN hb.add_dst_hour=21 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [21],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr16 ELSE s.hr22 END - CASE WHEN hb.add_dst_hour=22 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [22],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr17 ELSE s.hr23 END - CASE WHEN hb.add_dst_hour=23 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [23],
			CAST((CASE WHEN s.commodity_id=-1 AND s.is_fixedvolume =''n'' THEN  s.hr18 ELSE s.hr24 END - CASE WHEN hb.add_dst_hour=24 THEN s.hr25 ELSE 0 END) AS NUMERIC(38,20)) [24],
			CAST((s.hr25) AS NUMERIC(38,20)) [25],(hb.add_dst_hour) add_dst_hour,s.dst_group_value_id'
		
		set @commodity_str=' INTO #tmp_pos_detail FROM '+@hour_pivot_table+' s ' +
			CASE WHEN @group_by IN('b') and @missing_data='n' THEN ' left join block_type_group grp ON s.group_id=grp.id '
				else ''
			end +'
				inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.source_curve_def_id 
				inner JOIN hour_block_term hb ON hb.term_date =s.[term] AND not ( s.commodity_id=-1 AND s.is_fixedvolume =''n'') 
				 and hb.block_define_id = ' +
			CASE WHEN @group_by IN('b')  and @missing_data='n' THEN 'grp.hourly_block_id' else 'COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')' end +'
				 and  hb.block_type=12000 AND hb.dst_group_value_id = s.dst_group_value_id
			'
		
		set @report_hourly_position_breakdown_0=''
		
		SET @report_hourly_position_breakdown1= ' 
			select *,CASE WHEN commodity_id=-1 AND is_fixedvolume =''n'' AND  ([hours]<7 OR [hours]=25) THEN dateadd(DAY,1,[term]) ELSE [term] END [term_date] into #unpvt 
			from (SELECT * FROM #tmp_pos_detail
					union all SELECT * FROM #tmp_pos_detail_gas) p
				UNPIVOT
					(Volume for Hours IN
						([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
					) AS unpvt
			WHERE NOT ([hours]=abs(isnull(add_dst_hour,0)) AND add_dst_hour<0) '
			+CASE WHEN @group_by IN('b')  THEN ' and Volume<>0' else '' end+' ;
			
			drop table #tmp_pos_detail;
			CREATE INDEX index_unpvt1 ON #unpvt ([term_date],hours);
			
			SELECT unp.' 
			+  CASE  WHEN @group_by='d' THEN 
					 ' source_deal_header_id' 
				ELSE 
					CASE WHEN @group_by IN ('z','g','c','r','l','b')  THEN @column_level ELSE '[Index]' END
				END 
			+ CASE  WHEN @group_by='d' THEN 
						',dbo.fnadateformat(unp.[term_date]) [Term Date]' 
 			else		
				',YEAR(unp.[term_date]) [Year],	MONTH(unp.[term_date]) [Month],	DAY(unp.[term_date]) [Day]'+ case when @summary_option IN('x','y') then ',Period' else '' end 
			END 
			+	',CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE unp.[Hours] END [Hour],
				CASE WHEN unp.[Hours] = 25 THEN 0 ELSE 	
					CASE WHEN CAST(convert(varchar(10),unp.[term_date],120)+'' ''+RIGHT(''00''+CAST(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE unp.[Hours] END -1 AS VARCHAR),2)+'':00:000'' AS DATETIME) BETWEEN CAST(convert(varchar(10),mv2.[date],120)+'' ''+CAST(mv2.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME) 
						AND CAST(convert(varchar(10),mv3.[date],120)+'' ''+CAST(mv3.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME)
						 THEN 1 ELSE 0 END 
				END AS DST,	cast(unp.Volume as numeric(32,'+isnull(@round_value,'4')+')) [Position]'
				+@str_batch_table+
				' FROM	#unpvt unp
				LEFT JOIN mv90_DST mv (nolock) ON (unp.[term_date])=(mv.[date])
					AND mv.insert_delete=''i'' AND unp.[Hours]=25
					AND mv.dst_group_value_id = unp.dst_group_value_id
				LEFT JOIN mv90_DST mv1 (nolock) ON (unp.[term_date])=(mv1.[date])
					AND mv1.insert_delete=''d''
					AND mv1.Hour=unp.[Hours]
					AND mv1.dst_group_value_id =  unp.dst_group_value_id		
				LEFT JOIN mv90_DST mv2 (nolock) ON YEAR(unp.[term_date])=(mv2.[YEAR])
					AND mv2.insert_delete=''d''
					AND mv2.dst_group_value_id =  unp.dst_group_value_id
				LEFT JOIN mv90_DST mv3 (nolock) ON YEAR(unp.[term_date])=(mv3.[YEAR])
					AND mv3.insert_delete=''i''
					AND mv3.dst_group_value_id =  unp.dst_group_value_id
				WHERE  (((unp.[Hours]=25 AND mv.[date] IS NOT NULL) OR (unp.[Hours]<>25)) AND (mv1.[date] IS NULL))'
			 + CASE WHEN @hour_from IS NOT NULL THEN ' and cast(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE unp.[Hours] END as int) between '+CAST(@hour_from AS VARCHAR) +' and ' +CAST(@hour_to AS VARCHAR) ELSE '' END +
			 + CASE WHEN @drill_term IS NOT NULL THEN CASE WHEN @drill_freq='m' THEN ' AND dbo.FNAGetContractMonth(unp.term)=dbo.FNAGetContractMonth('''+@drill_term+''')' WHEN @drill_freq IN('a','q') THEN ' and (unp.term between '''+@drill_start +''' and '''+ @drill_end+''')'  ELSE ' AND unp.term='''+@drill_term+'''' END ELSE '' END  
			 +' ORDER BY unp.'+ CASE  WHEN @group_by='d' THEN 'source_deal_header_id,unp.[term_date],3' ELSE  CASE WHEN @group_by IN ('z','g','c','r','l','b')  THEN @column_level ELSE '[Index]' END +',unp.[term_date]'+ case when @summary_option IN('x','y') then ',6,Period' else ',5' end   END
	
		set @commodity_str1=' INTO #tmp_pos_detail_gas FROM '+@hour_pivot_table+' s  ' +
			CASE WHEN @group_by IN('b') and @missing_data='n'  THEN ' left join block_type_group grp ON s.group_id=grp.id '
			else ''	end +'
			inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.source_curve_def_id
			inner JOIN hour_block_term hb ON s.commodity_id=-1 AND s.is_fixedvolume =''n'' and hb.term_date -1=s.[term] 
			AND hb.block_define_id =' +
			CASE WHEN @group_by IN('b')  and @missing_data='n'  THEN 'grp.hourly_block_id' else 'COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')' end +' and  hb.block_type=12000 
			AND hb.dst_group_value_id = s.dst_group_value_id'
		
		--not for gas and all the finalcial
		--print 'not for gas or all the finalcial'
		--PRINT @report_hourly_position_breakdown
		--PRINT @commodity_str
		--PRINT @report_hourly_position_breakdown_0
		
		--				-- for physical gas only
		--print '*******************for physical gas only*********************'

		--PRINT @report_hourly_position_breakdown
		--PRINT @commodity_str1
		--PRINT @report_hourly_position_breakdown_0
		--PRINT @report_hourly_position_breakdown1
	
		exec(@report_hourly_position_breakdown+@commodity_str+@report_hourly_position_breakdown_0+ '; 
		'+@report_hourly_position_breakdown+ @commodity_str1 +@report_hourly_position_breakdown_0 +@report_hourly_position_breakdown1 )
		

	END
--*/
 
batch_level:
/*
--*********FOR BATCH PROCESSING*****************      
       
 IF  @batch_process_id is not null          
  BEGIN          
    SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)  
     
    EXEC(@str_batch_table)          
    declare @report_name VARCHAR(100)          
  
    SET @report_name='Run Hourly Position Report Batch Job'          
             
    SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_create_hourly_position_report',@report_name)           
    EXEC(@str_batch_table)          
             
  END          
--**********************************     
*/


/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)                   

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_hourly_position_report', 'Hourly Position Report')         
	EXEC(@str_batch_table)        
	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
