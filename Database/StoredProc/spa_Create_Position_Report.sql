
/****** Object:  StoredProcedure [dbo].[spa_Create_Position_Report]    Script Date: 11/30/2010 16:21:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Position_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Position_Report]
/****** Object:  StoredProcedure [dbo].[spa_Create_Position_Report]    Script Date: 11/30/2010 16:21:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec spa_Create_Position_Report '2009-01-10', '230', NULL, NULL, 'i', null, 'f', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2008-12-10', 'd'

CREATE PROC [dbo].[spa_Create_Position_Report]
	@as_of_date						VARCHAR(50), 
	@sub_entity_id					VARCHAR(1000), 
	@strategy_entity_id				VARCHAR(1000) = NULL, 
	@book_entity_id					VARCHAR(1000) = NULL, 
	@summary_option					CHAR(1), --'t'- term 'm' - By Month 'q' - By quater, 's' - By semiannual, 'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
	@convert_unit_id				INT, 
	@settlement_option				CHAR(1) = 'f', 
	@source_system_book_id1 		INT = NULL, 
	@source_system_book_id2 		INT = NULL, 
	@source_system_book_id3 		INT = NULL, 
	@source_system_book_id4 		INT = NULL, 
	@transaction_type				VARCHAR(100) = NULL, 
	@source_deal_header_id			VARCHAR(50) = NULL, 
	@deal_id						VARCHAR(50) = NULL, 
	@as_of_date_from				VARCHAR(50) = NULL, 
	@options						CHAR(1) = 'd', --'d'- include delta positions, 'n'-Do not include delta positions
	@drill_index					VARCHAR(100) = NULL, 
	@drill_contractmonth			VARCHAR(100) = NULL, 
	@major_location 				VARCHAR(250) = NULL, 
	@minor_location 				VARCHAR(250) = NULL, 
	@index							VARCHAR(MAX) = NULL, 
	@commodity_id					INT = NULL, 
--	@sub_type						CHAR(1) = 'b', --'b' both, 'f' forward, 's' spot
	@sub_type 						INT = NULL, 
	@group_by 						CHAR(1) = 'i', -- 'i'-index, 'l'-location
	@physical_financial_flag		CHAR(1) = 'b', 	--'b' both, 'p' physical, 'f' financial
	@deal_type						INT = NULL, 
	@trader_id						INT = NULL, 
	@tenor_from						VARCHAR(20) = NULL, 
	@tenor_to						VARCHAR(20) = NULL, 
	@show_cross_tabformat			CHAR(1) = 'n', 
	@deal_process_id				VARCHAR(100) = NULL,  --WHEN call from Check Position IN deal insert
	@deal_status					INT = NULL, 
	@round_value					CHAR(2) = '0', 
	@book_transfer					CHAR(1) = 'n', 
	@counterparty_id				VARCHAR(MAX) = NULL, 
	@show_per						CHAR(1) = NULL, 
	@match							CHAR(1) = 'n', 
	
	@drill_VolumeUOM				VARCHAR(20) = NULL, 
	@buySell_flag					CHAR(1) = NULL, 
	@show_hedgeVolume				CHAR(1) = 'n', 
	@counterparty_option CHAR(1) = 'a', --i means only internal and e means only extern
	@to_uom_id						INT	= NULL,
	@book_map_entity_id				VARCHAR(1000) = NULL,
	@deal_list_table                VARCHAR(100) = NULL,
	@batch_process_id				VARCHAR(50) = NULL, 
	@batch_report_param				VARCHAR(1000) = NULL
	,@enable_paging INT = 0 --'1' = enable, '0' = disable
	,@page_size INT = NULL
	,@page_no INT = NULL


AS
SET NOCOUNT ON

/*



declare @as_of_date					VARCHAR(50)='2010-01-14', 
	@sub_entity_id					VARCHAR(100)='25,7', 
	@strategy_entity_id				VARCHAR(100) = NULL, 
	@book_entity_id					VARCHAR(100) = null, 
	@summary_option					CHAR(1)='t', --'t'- term 'm' - By Month 'q' - By quater, 's' - By semiannual, 'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
	@convert_unit_id				INT=null, 
	@settlement_option				CHAR(1) = 'f', 
	@source_system_book_id1 		INT = NULL, 
	@source_system_book_id2 		INT = NULL, 
	@source_system_book_id3 		INT = NULL, 
	@source_system_book_id4 		INT = NULL, 
	@transaction_type				VARCHAR(100) = '401, 400, 407', 
	@source_deal_header_id			VARCHAR(50) = '157546', 
	@deal_id						VARCHAR(50) = NULL, 
	@as_of_date_from				VARCHAR(50) = NULL, 
	@options						CHAR(1) = 'd', --'d'- include delta positions, 'n'-Do not include delta positions
	@drill_index					VARCHAR(100) =null, 
	@drill_contractmonth			VARCHAR(100) = null, 
	@major_location 				VARCHAR(250) = NULL, 
	@minor_location 				VARCHAR(250) = NULL, 
	@index							VARCHAR(MAX) = NULL, 
	@commodity_id					INT = NULL, 
	
--exec spa_Create_Position_Report '2010-01-14', '25,7', NULL, NULL, 't', null, 'f', NULL, NULL, NULL, NULL,'401,400,407',NULL, NULL, NULL,'n',NULL,NULL,NULL,NULL,'12',NULL,NULL,'i','b',NULL,NULL,NULL,NULL,'n',NULL,NULL,'0', 'n', NULL,'y', 'n',NULL,NULL,'n',NULL, NULL
--exec spa_Create_Position_Report '2010-12-01', '25,7,31', NULL, NULL, 'm', null, 'a', NULL, NULL, NULL, NULL,'401,400,407','1032', NULL, NULL,'d',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'i','b',NULL,NULL,NULL,NULL,'n',NULL,NULL,'4', 'n', NULL,'n', 'n',NULL,NULL,'n',NULL, NULL
	@sub_type 						INT = NULL, 
	@group_by 						CHAR(1) = 'i', -- 'i'-index, 'l'-location
	@physical_financial_flag		CHAR(1) = 'b', 	--'b' both, 'p' physical, 'f' financial
	@deal_type						INT = NULL, 
	@trader_id						INT = NULL, 
	@tenor_from						VARCHAR(20) = NULL, 
	@tenor_to						VARCHAR(20) = NULL, 
	@show_cross_tabformat			CHAR(1) = 'n', 
	@deal_process_id				VARCHAR(100) = NULL,  --WHEN call from Check Position IN deal insert
	@deal_status					INT = NULL, 
	@round_value					CHAR(1) = '4', 
	@book_transfer					CHAR(1) = 'n', 
	@counterparty_id				INT = NULL, 
	@show_per						CHAR(1) = 'y', 
	@match							CHAR(1) = 'n', 
	
	@drill_VolumeUOM				VARCHAR(20) =null, 
	@buySell_flag					CHAR(1) = NULL, 
	@show_hedgeVolume				CHAR(1) = 'n', 
	@to_uom_id						INT	= NULL,
	@book_map_entity_id				VARCHAR(200) = NULL,
	@batch_process_id				VARCHAR(50) = NULL, 
	@batch_report_param				VARCHAR(1000) = NULL
	

	drop table #books
	drop table #tempItems
	drop table #tempAsset
	drop table #tmp_per
	drop table #tmp_sub
	drop table  #tempPivot
	drop table   #temp_order
	drop table   #unit_conversion
	drop table  #temp_total_vol
	drop table  #term_date
	drop table  #temp_deals
 
--*/

--##############################################


-- ******************************************************* 
-- this report works only for Summary Level Data
-- ****************************************************** 
---###########Declare Variables
SET @drill_VolumeUOM=NULL
DECLARE @Sql_Select VARCHAR(MAX)
DECLARE @term_where_clause VARCHAR(1000)
DECLARE @Sql_Where VARCHAR(8000)
DECLARE @report_identifier INT
DECLARE @granularity_type VARCHAR(1)
DECLARE @process_id VARCHAR(50)
DECLARE @user_login_id VARCHAR(50)
DECLARE @tempTable VARCHAR(128)
DECLARE @deal_volume_str VARCHAR(max)
DECLARE @deal_volume_str_total VARCHAR(max)
DECLARE @storage_inventory_sub_type_id INT
DECLARE @drill_contract_month_clause	VARCHAR(100)
DECLARE @year VARCHAR(4)
DECLARE @start_month VARCHAR(4)
DECLARE @end_month VARCHAR(4)
DECLARE @str_batch_table VARCHAR(MAX)        
DECLARE @listCol VARCHAR(5000)
DECLARE @tbl_name_header VARCHAR(150)
DECLARE @tbl_name_detail VARCHAR(150)

SET @storage_inventory_sub_type_id = 17
SET @str_batch_table = ''        
SET @sql_Where = ''
SET @tbl_name_header = 'source_deal_header'
SET @tbl_name_detail = 'source_deal_detail'
SET @user_login_id = dbo.FNADBuser()
CREATE TABLE #source_deal_header_id (source_deal_header_id INT)
IF @deal_process_id IS NOT NULL  --WHEN call from Check Position IN deal insert
BEGIN
	SET @tbl_name_header = dbo.FNAProcessTableName('deal_header', @user_login_id, @deal_process_id)
	SET @tbl_name_detail = dbo.FNAProcessTableName('deal_detail', @user_login_id, @deal_process_id)
END

DECLARE @Sql_WhereB VARCHAR(5000)
DECLARE @Sql_SelectB VARCHAR(5000)
CREATE TABLE #books (fas_book_id INT, source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT) 
If OBJECT_ID(@deal_list_table) is not null
	BEGIN
		EXEC('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM '+@deal_list_table)
	END
SET @Sql_SelectB = '
	INSERT INTO  #books
	SELECT  distinct 
	ssbm.fas_book_id,ssbm.source_system_book_id1,ssbm.source_system_book_id2,ssbm.source_system_book_id3,ssbm.source_system_book_id4
	FROM portfolio_hierarchy book (nolock) INNER JOIN
	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
	source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
	WHERE 1=1 '   

SET @Sql_WhereB=''
      
IF @sub_entity_id IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( '	+ @sub_entity_id + ') '         
IF @strategy_entity_id IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN('	+ @strategy_entity_id + ' ))'        
IF @book_entity_id IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN('	+ @book_entity_id + ')) '  
IF @book_map_entity_id IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB + ' AND ssbm.book_deal_type_map_id IN  (' + @book_map_entity_id + ')' 	
IF @transaction_type IS NOT NULL
	SET @Sql_WhereB = @Sql_WhereB + ' AND (ssbm.fas_deal_type_value_id IN ( ' + @transaction_type  + '))'  
if @source_system_book_id1 IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB +' AND (ssbm.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR) + ')) ' 
if @source_system_book_id2 IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB +' AND (ssbm.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) ' 
if @source_system_book_id3 IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB +' AND (ssbm.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) ' 
if @source_system_book_id4 IS NOT NULL 
	SET @Sql_WhereB = @Sql_WhereB +' AND (ssbm.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) ' 
    
SET @Sql_SelectB = @Sql_SelectB + @Sql_WhereB        
--PRINT  (@Sql_SelectB)
EXEC (@Sql_SelectB)



create table #temp_deals (source_deal_header_id int)

SET @sql_Select = '
	insert into #temp_deals (source_deal_header_id )
	select distinct sdh.source_deal_header_id
		FROM   ' + @tbl_name_header + ' sdh ' +
		CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN  #source_deal_header_id t on t.source_deal_header_id = sdh.source_deal_header_id ' ELSE '' END +
			' inner join #books ssbm 	on sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
					AND sdh.source_system_book_id3 = ssbm.source_system_book_id3  AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
			INNER JOIN ' + @tbl_name_detail + ' sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			
	where 1=1 '
 + CASE WHEN @options = 'n' THEN ' AND ISNULL(sdh.option_flag, ''n'')<>''y''' ELSE '' END
 + CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR) + ')) '  ELSE '' END
 + CASE WHEN @deal_id IS NOT NULL THEN 	' AND sdh.deal_id = ''' + CAST(@deal_id AS VARCHAR) + ''''  ELSE '' END
 + CASE WHEN @deal_type IS NOT NULL THEN ' AND sdh.source_deal_type_id = ' + CAST(@deal_type AS VARCHAR) ELSE '' END
 + CASE WHEN @trader_id IS NOT NULL THEN ' AND sdh.trader_id = ' + CAST(@trader_id AS VARCHAR) ELSE '' END
 + CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id IN (' + CAST(@counterparty_id AS VARCHAR) + ')' ELSE '' END
 + CASE WHEN @deal_status IS NOT NULL THEN ' AND sdh.deal_status = ' + CAST(@deal_status AS VARCHAR) ELSE '' END
 + CASE WHEN @tenor_from IS NOT NULL AND @match = 'y' THEN ' AND sdh.entire_term_start = ''' + @tenor_from + '''' ELSE '' END
 + CASE WHEN @tenor_to IS NOT NULL AND @match = 'y' THEN ' AND sdh.entire_term_end = ''' + @tenor_to + '''' ELSE '' END

--print(@sql_Select)

exec(@sql_Select)




-- Create temp table for Unit converison
CREATE TABLE #unit_conversion(
	convert_from_uom_id INT,
	convert_to_uom_id INT,
	conversion_factor FLOAT
)

INSERT INTO #unit_conversion(convert_from_uom_id,convert_to_uom_id,conversion_factor) 	
	SELECT	
		from_source_uom_id,
		to_source_uom_id,
		conversion_factor
	FROM
		rec_volume_unit_conversion
	WHERE	
		to_source_uom_id=@to_uom_id
		AND state_value_id IS NULL
		AND curve_id IS NULL
		AND assignment_type_value_id IS NULL
		AND to_curve_id IS NULL	



SET @str_batch_table = ''        
IF @batch_process_id IS NOT NULL  
BEGIN      
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)   
	SET @str_batch_table = @str_batch_table
END

IF @as_of_date_from IS NULL
	SET @as_of_date_from = '1900-01-01'

SET @granularity_type = @summary_option

SET @drill_contract_month_clause = ''
IF @settlement_option = 'f'
	SET @term_where_clause = ' AND ((sdd.term_start >= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND sdd.deal_volume_frequency IN (''d'', ''h'')) OR (sdd.term_start >= CONVERT(DATETIME, dbo.FNAGetContractMonth(''' + @as_of_date + ''') , 102) AND sdd.deal_volume_frequency not IN (''d'', ''h'')))'
ELSE 
IF @settlement_option = 'c'
	SET @term_where_clause = ' AND sdd.term_start >=  CONVERT(DATETIME, ''' + CAST(MONTH(@as_of_date) AS VARCHAR) + '/1/' + CAST(YEAR(@as_of_date) AS VARCHAR) + ''' , 102)'
ELSE IF @settlement_option = 's'
	SET @term_where_clause = ' AND ((sdd.term_start <=  CONVERT(DATETIME, ''' + CAST(MONTH(@as_of_date) AS VARCHAR) + '/1/' + CAST(YEAR(@as_of_date) AS VARCHAR) + ''' , 102) AND COALESCE(spcd1.block_define_id, sdh.block_define_id) IS NULL) OR (sdd.term_start <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND COALESCE(spcd1.block_define_id, sdh.block_define_id) IS NOT NULL))'
ELSE
	SET @term_where_clause = ''

IF @drill_index IS NOT NULL
	SET @granularity_type = 'd'

IF @summary_option IN ('t')
	SELECT @drill_contract_month_clause = CASE WHEN @drill_contractmonth IS NOT NULL THEN  ' AND sdd.term_start = ''' + cast(dbo.FNAStdDate(@drill_contractmonth) AS VARCHAR) + '''' ELSE '' END
ELSE IF @summary_option IN ('m')
	SELECT @drill_contract_month_clause = CASE WHEN @drill_contractmonth IS NOT NULL THEN ' AND convert(varchar(7),sdd.term_start,120) = ''' + @drill_contractmonth+'''' ELSE '' END
ELSE IF @summary_option IN ('q')
BEGIN
	SELECT @start_month = CASE 
	                           WHEN @drill_contractmonth LIKE '%1st%' THEN 
	                                '-01'
	                           WHEN @drill_contractmonth LIKE '%2nd%' THEN 
	                                '-04'
	                           WHEN @drill_contractmonth LIKE '%3rd%' THEN 
	                                '-07'
	                           WHEN @drill_contractmonth LIKE '%4th%' THEN 
	                                '-10'
	                      END
	
	SELECT @end_month = CASE 
	                         WHEN @drill_contractmonth LIKE '%1st%' THEN 
	                              '-03'
	                         WHEN @drill_contractmonth LIKE '%2nd%' THEN 
	                              '-06'
	                         WHEN @drill_contractmonth LIKE '%3rd%' THEN 
	                              '-09'
	                         WHEN @drill_contractmonth LIKE '%4th%' THEN 
	                              '-12'
	                    END
	SELECT @year = SUBSTRING(@drill_contractmonth, CHARINDEX('-', @drill_contractmonth, 0) + 1, 4)
	SELECT @drill_contract_month_clause = CASE WHEN @drill_contractmonth IS NOT NULL THEN 
		' AND CAST((sdd.term_start) as datetime) BETWEEN ''' + (@year + @start_month + '-01') + ''' AND ''' + (@year + @end_month + '-01') + '''' ELSE '' END
END
ELSE IF @summary_option IN ('s')
BEGIN
	SELECT @start_month = CASE 
	                           WHEN @drill_contractmonth LIKE '%1st%' THEN 
	                                '-01'
	                           WHEN @drill_contractmonth LIKE '%2nd%' THEN 
	                                '-07'
	                      END
	
	SELECT @end_month = CASE 
	                         WHEN @drill_contractmonth LIKE '%1st%' THEN 
	                              '-06'
	                         WHEN @drill_contractmonth LIKE '%2nd%' THEN 
	                              '-12'
	                    END
	SELECT @year = SUBSTRING(@drill_contractmonth, CHARINDEX('-', @drill_contractmonth, 0) + 1, 4)
	SELECT @drill_contract_month_clause = CASE WHEN @drill_contractmonth IS NOT NULL THEN 
		' AND CAST((sdd.term_start) as datetime) BETWEEN ''' + (@year + @start_month + '-01') + ''' AND ''' + (@year + @end_month + '-01') + '''' ELSE '' END
END
ELSE IF @summary_option IN ('a')
BEGIN
	SELECT @drill_contract_month_clause = CASE WHEN @drill_contractmonth IS NOT NULL THEN ' AND YEAR(sdd.term_start) = ''' + @drill_contractmonth + '''' ELSE '' END
END		

---###### For the Deal sub type filter

--	IF @sub_type = 't'
--		SET @sub_type = 4
--	ELSE IF @sub_type = 's'
--		SET @sub_type = 1

---######
------####### Create Temporary Tables

CREATE TABLE [dbo].[#tempItems] (
	[source_deal_header_id]		INT, 
	[fas_book_id]				INT NOT NULL , 
	[deal_id]					VARCHAR (200)  NOT NULL, 
	[contract_expiration_date]	DATETIME, 
--		[NetItemVol]				FLOAT NULL , 
	[NetItemVol]				NUMERIC(38, 20) NULL , 
	[deal_volume_frequency]		CHAR (20)  , 
	[IndexName]					VARCHAR (100)   , 
	[sui]						INT  NOT NULL,  --[sui] INT NOT NULL, (chande
	deal_date					DATETIME, 
	term_start					DATETIME, 
	term_end					DATETIME, 
	price						FLOAT, 
	block_type					INT, 
	block_definition_id 		INT, 
	volume_frequency			CHAR(1), 
	location					VARCHAR(100), 
	physical_financial_flag		CHAR(1),
	total_volume				NUMERIC(38, 20), 
	leg							INT,
	pay_opposite				CHAR(1)
) ON [PRIMARY]

-----------########################### Find out the reference Curve
SET @user_login_id = dbo.FNADBUser()	
SET @process_id = dbo.FNAGetNewID()	
SET @tempTable = dbo.FNAProcessTableName('pricecurve_reference', @user_login_id, @process_id)

EXEC spa_get_price_curve_reference @tempTable

-----############# Reference Curve fetch completed

-----------#############################Get all the Items first

--------------------------------New logic to calculate total_volume----------------------------------------

create table #term_date( block_define_id int ,term_date date,term_start date,term_end date,
	hr1 tinyint,hr2 tinyint,hr3 tinyint,hr4 tinyint,hr5 tinyint,hr6 tinyint,hr7 tinyint,hr8 tinyint
	,hr9 tinyint,hr10 tinyint,hr11 tinyint,hr12 tinyint,hr13 tinyint,hr14 tinyint,hr15 tinyint,hr16 tinyint
	,hr17 tinyint,hr18 tinyint,hr19 tinyint,hr20 tinyint,hr21 tinyint,hr22 tinyint,hr23 tinyint,hr24 tinyint,add_dst_hour int
)
insert into #term_date(block_define_id  ,term_date,term_start,term_end,hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 
,hr13 ,hr14 ,hr15 ,hr16 ,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,add_dst_hour
)
select distinct a.block_define_id  ,hb.term_date,a.term_start ,a.term_end,
	hb.hr1 ,hb.hr2 ,hb.hr3 ,hb.hr4 ,hb.hr5 ,hb.hr6 ,hb.hr7 ,hb.hr8 
	,hb.hr9 ,hb.hr10 ,hb.hr11 ,hb.hr12 ,hb.hr13 ,hb.hr14 ,hb.hr15 ,hb.hr16 
	,hb.hr17 ,hb.hr18 ,hb.hr19 ,hb.hr20 ,hb.hr21 ,hb.hr22 ,hb.hr23 ,hb.hr24 ,hb.add_dst_hour
from (
		select distinct isnull(spcd.block_define_id,292037) block_define_id,s.term_start,s.term_end 
		from report_hourly_position_breakdown s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
		 	AND bk.source_system_book_id1=s.source_system_book_id1 AND bk.source_system_book_id2=s.source_system_book_id2 
		 	AND bk.source_system_book_id3=s.source_system_book_id3 AND bk.source_system_book_id4=s.source_system_book_id4 
		 		INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
		 		left JOIN source_price_curve_def spcd with (nolock) 
		 		ON spcd.source_curve_def_id=s.curve_id 
		) a
		outer apply	(select h.* from hour_block_term h with (nolock) where block_define_id=a.block_define_id and h.block_type=12000 
		and term_date between a.term_start  and a.term_end --and term_date>@as_of_date
) hb


declare @as_of_date_filter datetime

if @settlement_option = 'f'
	set  @as_of_date_filter= @as_of_date
else if  @settlement_option = 'c' 
	set @as_of_date_filter = DATEADD(day,-1,@as_of_date)
else
	set  @as_of_date_filter= '1900-01-01'

create index indxterm_dat on #term_date(block_define_id ,term_start,term_end)
CREATE TABLE #temp_total_vol (
	source_deal_header_id INT
	,curve_id INT
	,location_id INT
	,term_start DATETIME
	,expiration_date DATETIME
	,commodity_id int
	,counterparty_id int
	,deal_volume_uom_id int
	,physical_financial_flag varchar(1) COLLATE DATABASE_DEFAULT 
	,deal_status_id int
	,total_volume NUMERIC(22,10)
)
INSERT INTO #temp_total_vol(
	source_deal_header_id ,
	curve_id, 
	location_id ,
	term_start
	,expiration_date
	,commodity_id
	,counterparty_id
	,deal_volume_uom_id
	,physical_financial_flag
	,deal_status_id
	,total_volume)
SELECT s.source_deal_header_id, s.curve_id
	,ISNULL(s.location_id,-1) location_id,s.term_start
	,s.expiration_date
	,s.commodity_id
	,s.counterparty_id
	,s.deal_volume_uom_id
	,s.physical_financial_flag
	,s.deal_status_id
	,s.hr1+s.hr2+s.hr3+s.hr4+s.hr5+s.hr6+s.hr7+s.hr8+s.hr9+s.hr10+s.hr11+s.hr12+s.hr13+s.hr14+s.hr15+s.hr16+s.hr17+s.hr18+s.hr19+s.hr20+s.hr21+s.hr22+s.hr23+s.hr24 total_volume
	from report_hourly_position_deal s  (nolock)  
	INNER JOIN #temp_deals td on s.source_deal_header_id=td.source_deal_header_id
WHERE --s.term_start>@as_of_date_filter AND 
	s.deal_date<=@as_of_date
union all
SELECT s.source_deal_header_id, s.curve_id,s.location_id,s.term_start
	,s.expiration_date
	,s.commodity_id
	,s.counterparty_id
	,s.deal_volume_uom_id
	,s.physical_financial_flag
	,s.deal_status_id
	,s.hr1+s.hr2+s.hr3+s.hr4+s.hr5+s.hr6+s.hr7+s.hr8+s.hr9+s.hr10+s.hr11+s.hr12+s.hr13+s.hr14+s.hr15+s.hr16+s.hr17+s.hr18+s.hr19+s.hr20+s.hr21+s.hr22+s.hr23+s.hr24 total_volume
	from report_hourly_position_profile s  (nolock)  INNER JOIN #temp_deals td on s.source_deal_header_id=td.source_deal_header_id
WHERE -- s.term_start>@as_of_date_filter AND 
	s.deal_date<=@as_of_date


IF @physical_financial_flag<>'p'

	INSERT INTO #temp_total_vol(
		source_deal_header_id ,
		curve_id, 
		location_id ,
		term_start
		,expiration_date
		,commodity_id
		,counterparty_id
		,deal_volume_uom_id
		,physical_financial_flag
		,deal_status_id
		,total_volume)
	SELECT s.source_deal_header_id, s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start
		,s.expiration_date
		,s.commodity_id
		,s.counterparty_id
		,s.deal_volume_uom_id
		,s.physical_financial_flag
		,s.deal_status_id
				,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
				+(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-'+CAST(MONTH(DATEADD(m,1,@as_of_date)) AS VARCHAR)+'-01' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  
			 AS total_volume
			from report_hourly_position_breakdown s  (nolock)  INNER JOIN #temp_deals td on s.source_deal_header_id=td.source_deal_header_id				 left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id 
				LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
				outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,292399)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
				outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
				where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,292399)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
				left join #term_date hb on hb.block_define_id=isnull(spcd.block_define_id,292399) and hb.term_start = s.term_start
				and hb.term_end=s.term_end 
				outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
					h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
				 outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN('REBD')) hg1   
				 outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>@as_of_date THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
							AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
							AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN('REBD')) remain_month  
				 where ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,'9999-01-01')>@as_of_date) OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
				 AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
				  AND s.deal_date<=@as_of_date	--and hb.term_date>@as_of_date_filter


--SELECT SUM(total_volume) FROM #temp_total_vol WHERE source_deal_header_id = '13189'  RETURN;
-----------------------------------------------------------------------------------------------------------
create index indx_temp_total_vol_aaa on #temp_total_vol (source_deal_header_id,curve_id,location_id,term_start)



if @summary_Option in( 't','r','d')
	SELECT @deal_volume_str = CASE WHEN @options = 'd' THEN ' sdd.deal_volume * (CASE WHEN (sdh.option_flag = ''y'') THEN CASE WHEN ISNULL(sdd.leg, -1) = 1 THEN abs(DELTA) WHEN ISNULL(sdd.leg, -1) = 2 THEN abs(DELTA2) ELSE 0 END * case when isnull(sdh.option_type,''c'')=''p'' then -1 else 1 end ELSE 1 END) ' 
		ELSE ' sdd.deal_volume ' END
	+' * CASE WHEN sdd.curve_id IS NOT NULL THEN (CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 else 1 end) else 0 end * ISNULL(cr.factor, 1) * ISNULL(NULLIF(sdd.multiplier, 0), 1)'+ CASE WHEN @to_uom_id IS NOT NULL THEN '* ISNULL(uc1.conversion_factor,1)' else '' end
ELSE
BEGIN
	SELECT @deal_volume_str = 
		CASE WHEN @options = 'd' THEN 
			' ttv.total_volume * (CASE WHEN (sdh.option_flag = ''y'') THEN CASE WHEN ISNULL(sdd.leg, -1) = 1 THEN  abs(DELTA) WHEN ISNULL(sdd.leg, -1) = 2 THEN abs(DELTA2) ELSE 0 END * case when isnull(sdh.option_type,''c'')=''p'' then -1 else 1 end else 1 end) ' 
		ELSE 
			' ttv.total_volume' 
		END + CASE WHEN @to_uom_id IS NOT NULL THEN ' * ISNULL(uc1.conversion_factor, 1)' else '' end 
END


SET @sql_Select = 'INSERT INTO #tempItems	SELECT sdh.source_deal_header_id, ssbm.fas_book_id, ' + 
		CASE WHEN @deal_process_id IS NOT NULL THEN '''''' ELSE 
			'dbo.FNAHyperLinkText2(10131010, (cast(sdh.source_deal_header_id as VARCHAR) + ''('' + sdh.deal_id +  '')''),sdh.source_deal_header_id,'+@round_value+')' 
		END +', (sdd.term_start) AS contract_expiration_date,'+ 
		@deal_volume_str +'  AS NetItemVol, '
			 
IF @book_transfer <> 'y'		 
	SET @sql_Select = @sql_Select + '			
			CASE 
				WHEN '+case when @granularity_type='t' then ' sdd.deal_volume_frequency ' else ' sdd.deal_volume_frequency ' end +' = ''m'' THEN ''Monthly'' 
				WHEN '+case when @granularity_type='t' then ' sdd.deal_volume_frequency ' else ' sdd.deal_volume_frequency ' end +' = ''a'' THEN ''Annually'' 
				WHEN '+case when @granularity_type='t' then ' sdd.deal_volume_frequency ' else ' sdd.deal_volume_frequency ' end +' = ''d'' THEN ''Daily'' 
				WHEN sdd.deal_volume_frequency = ''w'' THEN ''Weekly''
				WHEN sdd.deal_volume_frequency = ''s'' THEN ''Semi-Annually'' 
				WHEN sdd.deal_volume_frequency = ''q'' THEN ''Quarterly'' 
				WHEN sdd.deal_volume_frequency = ''h'' AND ''' + @granularity_type + ''' = ''t'' THEN ''Hourly'' ---''Monthly''
				WHEN sdd.deal_volume_frequency = ''h'' AND DATEDIFF(day, sdd.term_start, sdd.term_end) <= 0  AND ''' + @summary_option + ''' NOT IN (''t'', ''d'', ''r'') THEN ''Daily''
				WHEN sdd.deal_volume_frequency = ''h'' AND DATEDIFF(day, sdd.term_start, sdd.term_end)>1  AND ''' + @summary_option + ''' NOT IN (''t'', ''d'', ''r'') THEN ''Monthly''
				WHEN sdd.deal_volume_frequency = ''h'' AND ((''' + @granularity_type + ''' = ''d'' AND ''' + @summary_option + ''' IN (''t'', ''d'')) OR ''' + @summary_option + ''' IN (''r'')) THEN ''Hourly''
			END AS deal_volume_frequency, 
			CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE spcd.curve_name END AS IndexName, 
			'
			
ELSE
	SET @sql_Select = @sql_Select + ' --sdd.deal_volume_frequency deal_volume_frequency, 
		isnull(CASE 
			WHEN '+case when @granularity_type='t' then ' sdd.deal_volume_frequency ' else ' sdd.deal_volume_frequency ' end +' = ''m'' THEN ''m'' 
			WHEN '+case when @granularity_type='t' then ' sdd.deal_volume_frequency ' else ' sdd.deal_volume_frequency ' end +' = ''a'' THEN ''a'' 
			WHEN '+case when @granularity_type='t' then ' sdd.deal_volume_frequency ' else ' sdd.deal_volume_frequency ' end +' = ''d'' THEN ''d'' 
			WHEN sdd.deal_volume_frequency = ''w'' THEN ''w''
			WHEN sdd.deal_volume_frequency = ''s'' THEN ''s'' 
			WHEN sdd.deal_volume_frequency = ''q'' THEN ''q'' 
			WHEN sdd.deal_volume_frequency = ''h'' AND ''' + @granularity_type + ''' = ''t'' THEN ''m''
			WHEN sdd.deal_volume_frequency = ''h'' AND DATEDIFF(day, sdd.term_start, sdd.term_end) <= 0  AND ''' + @summary_option + ''' NOT IN (''t'', ''d'', ''r'') THEN ''d''
			WHEN sdd.deal_volume_frequency = ''h'' AND DATEDIFF(day, sdd.term_start, sdd.term_end)>1  AND ''' + @summary_option + ''' NOT IN (''t'', ''d'', ''r'') THEN ''m''
			WHEN sdd.deal_volume_frequency = ''h'' AND ((''' + @granularity_type + ''' = ''d'' AND ''' + @summary_option + ''' IN (''t'', ''d'')) OR ''' + @summary_option + ''' IN (''r'')) THEN ''h''
		END,''m'') AS deal_volume_frequency, 
		spcd.source_curve_def_id  AS IndexName, '

SET @sql_Select = @sql_Select + 
	 CASE WHEN @to_uom_id IS NOT NULL THEN CAST(@to_uom_id AS VARCHAR) ELSE ' COALESCE(spcd.display_uom_id,ttv.deal_volume_uom_id,sdd.deal_volume_uom_id)' END +' deal_volume_uom_id, 
		 sdh.deal_date, 
		 sdd.term_start, 
		 sdd.term_end, 
		' + CASE WHEN @summary_Option = 'r' THEN ' (CASE WHEN sdd.fixed_price IS NOT NULL AND sdd.fixed_price>0 THEN sdd.fixed_price ELSE NULL END )' ELSE '0' END + ', 
		COALESCE(spcd1.block_type, sdh.block_type) block_type, 
		COALESCE(spcd1.block_define_id, sdh.block_define_id) block_define_id, 
		sdd.deal_volume_frequency, '

IF @book_transfer <> 'y'
	SET @sql_Select = @sql_Select + 'mi.location_name, '
ELSE 
	SET @sql_Select = @sql_Select + 'mi.source_minor_location_id, '

SET @sql_Select = @sql_Select + '
	sdd.physical_financial_flag ,'+
	 @deal_volume_str+' AS Total_Vol, 
	sdd.leg,
	sdd.pay_opposite
	FROM   ' + @tbl_name_header + ' sdh 
		 INNER JOIN #temp_deals td on sdh.source_deal_header_id=td.source_deal_header_id
		inner join #books ssbm 
		on sdh.source_system_book_id1 = ssbm.source_system_book_id1 
					AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
					AND sdh.source_system_book_id3 = ssbm.source_system_book_id3  
					AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		INNER JOIN ' + @tbl_name_detail + ' sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		cross apply (
			select max(deal_volume_uom_id) deal_volume_uom_id ,sum(total_volume) total_volume from #temp_total_vol where source_deal_header_id=sdh.source_deal_header_id 
				and sdd.curve_id=curve_id and  isnull(sdd.location_id,-1)=location_id and term_start between sdd.term_start and sdd.term_end
		) ttv 
		LEFT JOIN ' + @tempTable + ' cr ON ISNULL(cr.curve_id, -1) = sdd.curve_id
		LEFT OUTER JOIN source_price_curve_def spcd ON ISNULL(cr.Curve_ref_id, sdd.curve_id) = spcd.source_curve_def_id
		--LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
		LEFT JOIN source_minor_location mi on sdd.location_id = mi.source_minor_location_id 
		LEFT JOIN source_major_location ma  on ma.source_major_location_id = mi.source_major_location_id
		LEFT JOIN ' + @tbl_name_detail + ' sdd1 on sdh.source_deal_header_id = sdd1.source_deal_header_id
					AND sdd.term_start = sdd1.term_start AND sdd1.leg = 1
		LEFT JOIN source_price_curve_def spcd1 ON ISNULL(cr.Curve_ref_id, sdd1.curve_id) = spcd1.source_curve_def_id'
	 + CASE WHEN @options = 'd' THEN 
		' outer apply (
			select top(1) deal_volume,deal_volume2,delta,delta2  from source_deal_pnl_detail_options where as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) 
				AND source_deal_header_id = sdh.source_deal_header_id	AND term_start =case when isnull(sdh.internal_deal_subtype_value_id,1)=101 then term_start else sdd.term_start end
		)sdpdo 				
		'
	  ELSE '' END
	 + CASE WHEN @to_uom_id IS NOT NULL THEN '  LEFT JOIN #unit_conversion uc1 ON uc1.convert_from_uom_id=COALESCE(spcd.display_uom_id,sdd.deal_volume_uom_id) AND uc1.convert_to_uom_id='+ cast(@to_uom_id as varchar) else '' end
	 + ' WHERE  ISNULL(sdh.internal_deal_subtype_value_id, -1)<>' + CAST(@storage_inventory_sub_type_id AS VARCHAR)
	

	 + CASE WHEN @commodity_id IS NOT NULL THEN ' AND spcd.commodity_id = ''' + CAST(@commodity_id AS VARCHAR) + ''''  ELSE '' END
	 + --CASE WHEN @source_deal_header_id IS  NULL AND @deal_id IS  NULL THEN 
		' AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) ' + 
		CASE WHEN @as_of_date_from IS NOT NULL THEN '  AND (sdh.deal_date >= CONVERT(DATETIME, ''' + @as_of_date_from + ''' , 102))  ' ELSE '' END + @term_where_clause --ELSE '' END
	 + CASE WHEN @major_location IS NOT NULL THEN ' AND ma.source_major_location_id IN (' + @major_location + ')'  ELSE '' END
	 + CASE WHEN @minor_location IS NOT NULL THEN ' AND sdd.location_id IN (' + @minor_location + ')' ELSE '' END
	 + CASE WHEN @index IS NOT NULL THEN  ' AND sdd.curve_id IN (' + @index + ')' ELSE '' END
	 + @drill_contract_month_clause
	 --+ ' AND (( sdd.contract_expiration_date >= ''' + @as_of_date + ''' AND sdd.leg <> 1) OR sdd.leg = 1)'
	 + ' AND sdd.curve_id IS NOT NULL'
	 + CASE WHEN @tenor_from IS NOT NULL AND @match = 'n' THEN ' AND sdd.term_start >= ''' + @tenor_from + '''' ELSE '' END
	 + CASE WHEN @tenor_to IS NOT NULL AND @match = 'n' THEN ' AND sdd.term_start <= ''' + @tenor_to + '''' ELSE '' END
	 + CASE WHEN @buySell_flag IS NOT NULL THEN ' AND sdd.buy_sell_flag = ''' + @buySell_flag + '''' ELSE '' END

 IF @sub_type IS NOT NULL 
	SET @sql_Select = @sql_Select + ' AND sdh.deal_sub_type_type_id = ' + CAST(@sub_type AS VARCHAR)

--PRINT 'Print:' + @sql_Select  + @sql_Where

EXEC (@sql_Select + @sql_Where)

if ISNULL(@options,'n')='n'
delete  #tempItems where total_volume is null

--### deal position breakdown
IF @settlement_option = 'f'
	SET @term_where_clause = ' AND ((dpbd.fin_term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND deal_volume_frequency IN (''d'', ''h'')) OR dpbd.fin_term_start >  CONVERT(DATETIME, dbo.FNAGetContractMonth(''' + @as_of_date + ''') , 102) AND deal_volume_frequency not IN (''d'', ''h''))'
ELSE IF @settlement_option = 'c'
	SET @term_where_clause = ' AND (dpbd.fin_term_start >=  CONVERT(DATETIME, ''' + CAST(MONTH(@as_of_date) AS VARCHAR) + '/1/' + CAST(YEAR(@as_of_date) AS VARCHAR) + ''' , 102))'
ELSE IF @settlement_option = 's'
	SET @term_where_clause = ' AND ((dpbd.fin_term_start <=  CONVERT(DATETIME, ''' + CAST(MONTH(@as_of_date) AS VARCHAR) + '/1/' + CAST(YEAR(@as_of_date) AS VARCHAR) + ''' , 102) AND spcd.block_define_id IS NULL) OR dpbd.fin_term_start <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND spcd.block_define_id IS NOT NULL)'
ELSE
	SET @term_where_clause = ''

--################ Find out Percentage available
CREATE TABLE #tmp_per(source_deal_header_id INT, percentage_rem FLOAT)

SET @sql_Select = '	
	INSERT INTO #tmp_per
	select 
			used_per.source_deal_header_id, 
			1 - SUM(percentage_use) percentage_rem 
	
	FROM 
			(
				SELECT 	dh.source_deal_header_id,SUM(gfld.percentage_included) AS  percentage_use, MAX(''o'') src
				FROM 	
						' + @tbl_name_header + ' dh 
						INNER JOIN gen_fas_link_detail gfld ON gfld.deal_number = dh.source_deal_header_id 
						INNER JOIN gen_fas_link_header gflh ON gflh.gen_link_id = gfld.gen_link_id
								   AND gflh.gen_status = ''a''
				GROUP BY 
						dh.source_deal_header_id
				UNION ALL
				SELECT 
						source_deal_header_id, 
						SUM(CASE WHEN ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' >= ISNULL(fas_link_header.link_end_date, ''9999-01-01'') THEN 0 ELSE percentage_included END) percentage_included, MAX(''f'') 
				FROM 
						fas_link_detail 
						inner join fas_link_header ON  fas_link_detail.link_id = fas_link_header.link_id 
				GROUP BY source_deal_header_id
			) used_per 
	GROUP BY used_per.source_deal_header_id'
	
--PRINT(@sql_Select)
EXEC(@sql_Select)

--supporting granularity type 's' means monthly, 'q' quarter, 's' semi-annual, 'a' anual


DECLARE @group_by_sql VARCHAR(200)	
SET @group_by_sql = CASE WHEN @group_by = 'i' THEN ' IndexName, ' ELSE ' location, ' END 

IF @granularity_type <> 'd' AND @summary_option <> 'r' 
	SET @summary_option = 's'


SET @Sql_Select = ' SELECT ' +  
		CASE
			WHEN @group_by = 'i' THEN  'IndexName AS [Index Name], '  
			ELSE 'location, '  
		END + 
		CASE WHEN (@granularity_type IN ('t')) THEN  ' [dbo].FNAGetGenericDate(it.ced,'''+@user_login_id+''') AS Term, ' 
		WHEN (@granularity_type IN ('m')) THEN  ' convert(varchar(7),it.ced,120) AS Term, ' 			
		ELSE ' dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + ''') AS Term, ' END + 						
		' CAST(SUM(it.NetItemVol) AS NUMERIC(38, ' + isnull(@round_value,2) + ')) AS [Volume], '
IF @book_transfer <> 'y'		
	SET @Sql_Select = @Sql_Select + CASE 
				WHEN @granularity_type = 'm' THEN '''Monthly'''
				WHEN @granularity_type = 'q' THEN '''Quarterly'''
			   	WHEN @granularity_type = 's' THEN '''Semi-Annually'''
			   	WHEN @granularity_type = 'a' THEN '''Annually'''
			   	WHEN @granularity_type = 'w' THEN '''Weekly'''
				ELSE ' MAX(it.dvf) ' END + ' AS Frequency, '
ELSE 
	SET @Sql_Select = @Sql_Select + CASE 
				WHEN @granularity_type = 'm' THEN '''m'''
			   	WHEN @granularity_type = 'q' THEN '''q'''
			   	WHEN @granularity_type = 's' THEN '''s'''
			   	WHEN @granularity_type = 'a' THEN '''a'''
				WHEN @granularity_type = 'w' THEN '''w'''
				ELSE ' MAX(it.dvf) ' END + ' AS Frequency, '
			   
SET @Sql_Select = @Sql_Select + CASE when @book_transfer <> 'y' then ' IUOM.uom_name AS UOM ' ELSE ' max(IUOM.source_uom_id) AS UOM '	END 
SET @Sql_Select = @Sql_Select + CASE WHEN @show_cross_tabformat = 'y' THEN ', MAX(it.ced) AS [actualTerm]' ELSE '' END
	 +  @str_batch_table + 	'				  			     
	FROM portfolio_hierarchy sub INNER JOIN portfolio_hierarchy stra ON sub.entity_id = stra.parent_entity_id 
	INNER JOIN portfolio_hierarchy book ON stra.entity_id = book.parent_entity_id 
	inner join '
	
SET @Sql_Select = @Sql_Select + ' 
	(SELECT fas_book_id, ti.contract_expiration_date AS ced, SUM(ti.NetItemVol) NetItemVol,
			--	' + CASE WHEN @granularity_type = 't' THEN 'SUM((ti.NetItemVol)' ELSE ' SUM((ti.NetItemVol * CASE WHEN ti.physical_financial_flag = ''p'' THEN ISNULL(vft.Volume_Mult, 1) ELSE ISNULL(vft1.Volume_Mult, 1) END ) ' END + ' * ' 
			+ CASE WHEN @show_hedgeVolume = 'y' THEN '(ISNULL(tmp.percentage_rem, 1))' ELSE '1' END + ') AS NetItemVol,'
			IF @book_transfer <> 'y' 		
				set @Sql_Select = @Sql_Select +'
				case  isnull(ti.deal_volume_frequency,''m'') when ''m'' then ''Monthly''
				when ''q'' then ''Quarterly''
				when ''s'' then ''Semi-Annually''
				when ''a'' then ''Annually''
				when ''w'' then ''Weekly''
				when ''d'' then ''Daily''
				else  ti.deal_volume_frequency end AS dvf, 
				' 
			ELSE
				SET @Sql_Select = @Sql_Select + '
				isnull(ti.deal_volume_frequency,''m'')AS dvf,  
				'	
				
			SET @Sql_Select = @Sql_Select 	+ @group_by_sql + ' 
				ti.sui
		  FROM   #tempItems ti
				LEFT join #tmp_per tmp on ti.source_deal_header_id = tmp.source_deal_header_id '
			 + CASE WHEN @show_per = 'y' THEN ' WHERE ISNULL(ROUND(tmp.percentage_rem, 2), 1) > 0 ' ELSE '' END + 
			 + CASE WHEN @physical_financial_flag<>'b' THEN ' AND ti.physical_financial_flag = ''' + @physical_financial_flag + '''' ELSE '' END+
			' GROUP BY 
				ti.fas_book_id, ti.contract_expiration_date, ti.deal_volume_frequency, ' + @group_by_sql + '  ti.sui
		) it  		ON it.fas_book_id = book.entity_id '
	+' LEFT JOIN source_uom IUOM on IUOM.source_uom_id = it.sui '


						
	SET @Sql_Select = @Sql_Select + ' GROUP BY  ' + @group_by_sql + 
	 CASE WHEN (@granularity_type IN ( 't')) THEN  ' it.ced ' 
			WHEN (@granularity_type IN ('m')) THEN  ' convert(varchar(7),it.ced,120) ' 
			 ELSE '  
					SUBSTRING(dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + '''),  
					LEN(dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + ''')) -3, 4), 
					dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + ''') ' 
	 END + 
	 CASE when @book_transfer <> 'y' then ',IUOM.uom_name ' ELSE ''	END 

--SELECT @Sql_Select
--RETURN
--SELECT * FROM #tmp_sub

IF @summary_option = 's' AND @granularity_type <> 'd'	
BEGIN
	SET @Sql_Select = @Sql_Select + ' ORDER BY ' + @group_by_sql  
		+CASE WHEN (@granularity_type IN ( 'd','m')) THEN  ' convert(varchar(7),it.ced,120) ' 
		ELSE '  
			SUBSTRING(dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + ''') , LEN(dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + ''')) -3, 4), 
			dbo.FNAGetTermGrouping(it.ced , ''' + @granularity_type + ''') '  
				 --ELSE ', substring(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + '''), dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') - 5, 4)'
		END
END
ELSE	
BEGIN
	CREATE table #tmp_sub (
		aa INT
		,source_deal_header_id INT
		,Subsidiary VARCHAR(150) COLLATE DATABASE_DEFAULT 
		,Strategy VARCHAR(150) COLLATE DATABASE_DEFAULT
		,Book VARCHAR(150) COLLATE DATABASE_DEFAULT 
		,IndexName VARCHAR(150) COLLATE DATABASE_DEFAULT 
		,ContractMonth DATETIME
		, [TYPE] VARCHAR(10) COLLATE DATABASE_DEFAULT 
		, DealID VARCHAR(200) COLLATE DATABASE_DEFAULT 
		, VolumeFrequency VARCHAR(50) COLLATE DATABASE_DEFAULT 
		, VolumeUOM VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, deal_date DATETIME 
		,[volume] FLOAT
		, term_start DATETIME
		, term_end DATETIME
		, price	FLOAT
		, location	VARCHAR(150) COLLATE DATABASE_DEFAULT 
		,conv_factor FLOAT
    )
	SET @Sql_Select = 'insert into #tmp_sub
		SELECT    1 as aa, 
		ti.source_deal_header_id, max(sub.entity_name) AS Subsidiary, max(stra.entity_name) AS Strategy, max(book.entity_name) AS Book, ti.IndexName,  
		contract_expiration_date AS ContractMonth,	''Items'' Type, ti.deal_id DealID,			
		' + CASE WHEN (@granularity_type = 'd' AND (@summary_option = 't' OR @summary_option = 'd') OR @summary_option = 'r') THEN 'ti.deal_volume_frequency' ELSE '''Monthly''' END + ' AS VolumeFrequency,
		  MAX(uom_name) AS UOM, ti.deal_date, 
			sum(ROUND(ti.NetItemVol, ' + @round_value + ')) AS [volume], ti.term_start, ti.term_end, avg(ti.price) price	, MAX(ti.location) location,
		   '+CASE WHEN @to_uom_id IS NOT NULL THEN ' MAX(uc.conversion_factor)' ELSE '1' END+	
		' FROM  portfolio_hierarchy sub INNER JOIN portfolio_hierarchy stra ON sub.entity_id = stra.parent_entity_id
		INNER JOIN portfolio_hierarchy book ON  stra.entity_id = book.parent_entity_id 
		inner join #tempItems ti on ti.fas_book_id = book.entity_id
	    '+CASE WHEN @to_uom_id IS NOT NULL THEN ' LEFT JOIN #unit_conversion uc ON uc.convert_from_uom_id=sui
										   AND uc.convert_to_uom_id='+CAST(@to_uom_id AS VARCHAR) ELSE '' END	
		+'LEFT OUTER JOIN source_uom UOM ON  UOM.source_uom_id= '+CASE WHEN @to_uom_id IS NOT NULL THEN  CAST(@to_uom_id AS VARCHAR) ELSE ' sui ' END +'
		WHERE 1=1 '+
		 + CASE WHEN @physical_financial_flag<>'b' THEN ' AND ti.physical_financial_flag = ''' + @physical_financial_flag + '''' ELSE '' END+
		 + CASE WHEN @drill_index IS NOT NULL AND @group_by='i' THEN ' AND IndexName='''+@drill_index+''''  WHEN @drill_index IS NOT NULL AND @group_by='l' THEN ' AND ti.location='''+@drill_index+'''' ELSE '' END+
		' GROUP BY ti.fas_book_id,  ti.IndexName, ti.contract_expiration_date, ti.source_deal_header_id, 
			ti.deal_id, ti.deal_volume_frequency, sui, ti.deal_date, ti.term_start, ti.term_end'

	--PRINT @Sql_Select
	EXEC(@Sql_Select)

	IF @granularity_type = 'd'
	BEGIN
		SET @Sql_Select = 'SELECT A.Subsidiary, A.Strategy, A.Book, ISNULL(A.location + ''/'', '''') + A.IndexName [location/Index], A.DealId [Deal Id],
				[dbo].FNAGetGenericDate(ContractMonth,'''+@user_login_id+''') AS ContractMonth, 		
			CAST(A.[volume] as numeric(30, ' + @round_value + ')) as Volume, 
			CAST(ROUND(ISNULL(tmp.percentage_rem, 1), 2) as VARCHAR) [Percentage Available], 
			CASE WHEN ROUND(ISNULL(tmp.percentage_rem, 1), 2) = 0 THEN 0 ELSE CAST(A.[volume] * ISNULL(tmp.percentage_rem, 1) as numeric(30, ' + @round_value + ')) END [Volume Available], 
			 A.VolumeFrequency [Volume Frequency], A.VolumeUOM [Volume UOM] ' +  @str_batch_table + 
			' FROM #tmp_sub A LEFT join #tmp_per tmp on a.source_deal_header_id = tmp.source_deal_header_id '
		IF @show_per = 'y'
				SET @Sql_Select = @Sql_Select + ' WHERE ISNULL(ROUND(tmp.percentage_rem, 2), 1) > 0' + CASE WHEN  @drill_VolumeUOM IS NOT NULL THEN ' AND  A.VolumeUOM = ''' + @drill_VolumeUOM + '''' ELSE '' END
		IF @show_per = 'n'
			SET @Sql_Select = @Sql_Select + CASE WHEN  @drill_VolumeUOM IS NOT NULL THEN ' WHERE  A.VolumeUOM = ''' + @drill_VolumeUOM + '''' ELSE ' ' END

		SET @Sql_Select = @Sql_Select + ' ORDER BY A.Subsidiary, A.Strategy, A.Book, A.IndexName, A.ContractMonth, A.Type, A.DealId'
	END
	
	ELSE IF @summary_Option = 'r'
	BEGIN
		SET @Sql_Select = 'SELECT A.Subsidiary, A.Strategy, A.Book, ISNULL(MAX(a.location) + ''/'', '''') + MAX(A.IndexName) [location/Index], A.DealId [Deal Id]
		, [dbo].FNAGetGenericDate(A.deal_date,'''+@user_login_id+''') [Deal Date], [dbo].FNAGetGenericDate(min(A.term_start),'''+@user_login_id+''') + '' - '' + [dbo].FNAGetGenericDate(MAX(A.term_end),'''+@user_login_id+''') Term, 
					CAST(sum(A.[volume]) as numeric(30, ' + @round_value + ')) as Volume, CAST(ROUND(MAX(ISNULL(tmp.percentage_rem, 1)), 2) as VARCHAR) [Percentage Available], CASE WHEN ROUND(MAX(ISNULL(tmp.percentage_rem, 1)), 2) = 0 THEN 0 ELSE CAST(sum(A.[volume]) * MAX(ISNULL(tmp.percentage_rem, 1)) as numeric(30, ' + @round_value + ')) END [Volume Available], 
					CAST(AVG(A.Price) as numeric(30, ' + @round_value + ')) Price, 
					' + 
				'  A.VolumeFrequency [Volume Frequency], A.VolumeUOM [Volume UOM] ' +  @str_batch_table + 
				' FROM #tmp_sub A LEFT join #tmp_per tmp on a.source_deal_header_id = tmp.source_deal_header_id
				'
		IF @show_per = 'y'
			SET @Sql_Select = @Sql_Select + ' WHERE ISNULL(ROUND(tmp.percentage_rem, 2), 1) > 0 '

		SET @Sql_Select = @Sql_Select + ' group by A.Subsidiary, A.Strategy, A.Book, A.DealId, A.deal_date, A.VolumeFrequency, A.VolumeUOM
				ORDER BY A.Subsidiary, A.Strategy, A.Book,  A.DealId, A.deal_date'
	END
	--PRINT ' @summary_Option:' + @summary_Option

END



IF @show_cross_tabformat = 'y' AND @summary_Option NOT IN ('d', 'r') AND @drill_index IS NULL-----show the report IN cross tab forMAT
BEGIN
	
	CREATE TABLE #tempPivot(Item VARCHAR(100) COLLATE DATABASE_DEFAULT, [Term] VARCHAR(20) COLLATE DATABASE_DEFAULT, Volume FLOAT, VolumeFrequency VARCHAR(20) COLLATE DATABASE_DEFAULT, VolumeUOM VARCHAR(20) COLLATE DATABASE_DEFAULT, [actualTerm] DATETIME)
	SET @Sql_Select = REPLACE(@Sql_Select, @str_batch_table, '')
	SET @Sql_Select = ' INSERT INTO #tempPivot' + @Sql_Select	
	--print(@Sql_Select)	  	
	EXEC(@Sql_Select)

	
	SELECT DISTINCT YEAR([actualTerm])[actualTerm], [Term] INTO #temp_order FROM #tempPivot ORDER BY YEAR([actualTerm])

	SELECT  @listCol = STUFF(( SELECT  '], [' + [Term]
		 FROM    #temp_order
			    FOR XML PATH('')), 1, 2, '') + ']'

	DECLARE @listCol_SUM VARCHAR(MAX)
	SET @listCol_SUM = ''
		SELECT  @listCol_SUM = @listCol_SUM + CASE WHEN @listCol_SUM = '' THEN '' ELSE ', ' END + 'ROUND([' + [Term] + '], ' + @round_value + ')  as [' + [Term] + ']'	 FROM    #temp_order 

	IF @listCol_SUM = ''
	BEGIN
		SELECT 'No Data Found...' Status
		RETURN
	END

	IF @listCol IS NULL
		SET @listCol = '[0]'
	
	SET @Sql_Select = 
		'SELECT [Item] AS ' + CASE WHEN @group_by = 'i' THEN ' [IndexName]' ELSE '[location]' END + ', ' + @listCol_SUM + ', VolumeUOM ' + @str_batch_table + 
		' FROM (
				SELECT [Item], [Term], Volume, VolumeUOM  FROM #tempPivot
			 ) P
		 PIVOT
			(
				SUM(Volume) FOR [Term] IN (' + @listCol + ')
			) AS PVT	
	
			'
	--PRINT(@Sql_Select)
	EXEC(@Sql_Select)
END
ELSE
BEGIN
	--PRINT @Sql_Select
	EXEC(@Sql_Select)
END

--------- ============================== 

-- ***************** FOR BATCH PROCESSING **********************************    
 
IF  @batch_process_id IS NOT NULL        
BEGIN        
	 SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
	 EXEC(@str_batch_table)        
	 DECLARE @report_name VARCHAR(100)        

	 SET @report_name = 'Run Index Position Report'        
	        
	 SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Position_Report', @report_name)         
	 EXEC(@str_batch_table)        
	        
END        
-- ********************************************************************   

/*

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
dbcc stackdump(1)


*/


/*

	INSERT INTO  #books
	SELECT  distinct 
	ssbm.fas_book_id,ssbm.source_system_book_id1,ssbm.source_system_book_id2,ssbm.source_system_book_id3,ssbm.source_system_book_id4
	FROM portfolio_hierarchy book (nolock) INNER JOIN
	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
	source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
	WHERE 1=1  AND stra.parent_entity_id IN  ( 25,7,31)  AND (ssbm.fas_deal_type_value_id IN ( 401, 400, 407))

(34 row(s) affected)

	insert into #temp_deals (source_deal_header_id )
	select distinct sdh.source_deal_header_id
		FROM   source_deal_header sdh 
			inner join #books ssbm 	on sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
					AND sdh.source_system_book_id3 = ssbm.source_system_book_id3  AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	where 1=1  AND (sdh.source_deal_header_id IN (1032)) 

(1 row(s) affected)

(0 row(s) affected)

(0 row(s) affected)

(0 row(s) affected)

(0 row(s) affected)

(2922 row(s) affected)

(0 row(s) affected)
EXEC spa_print:INSERT INTO #tempItems	



*/
