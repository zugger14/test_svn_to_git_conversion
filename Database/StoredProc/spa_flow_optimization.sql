IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_flow_optimization]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_flow_optimization]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Gas Scheduling related operations for menu Flow Optimization.
	Parameters
	@flag						: Flag
								  'l' Extract receipt location and delivery location with positions for flow optimization grid
								  'c' Extract optimizer grid cell information(path mdq, path rmdq, etc) for flow optimization grid
								  'r' Firing run solver with SSIS solver package and filling up optimizer grid cell information
								  'y' Extracting path and contract level information to load on path list of outer popup and inner popup
								  'q' Filling up Contract Detail information on Main Popup on Optimization Grid
								  'g'
								  'z' For saving manual scheduling adjustments to process table
								  'p' For position report drill on begining inverntory optimization grid
								  'm' Load receipt side grid data for Flow Optimization Match
								  'n' Load delivery side grid data for Flow Optimization Match
								  'pl'
								  'x' To get sum of other volumes on optimization grid box of given contract, path, box for contract validation
								  'd' To get destination sub book values for save schedule
								  'w'
								  'h' Get period_from period_to combo values on flow optimization ui as granularity value selected
								  'b' Call flag "l" and "c" to prepare for the flow optimization proccess to begin
								  'a' Get all other locations from the path with the provided location
								  'e' Get proxy child locations

	@sub						: Subsidiary IDs comma separated
	@str						: Stratrgy IDs comma separated
	@book						: Book IDs comma separated
	@commodity					: Commodity ID
	@receipt_delivery			: Receipt Delivery Side (FROM,TO)
	@daily_rolling				: Daily Rolling flag (d:daily, m:monthly, r:daily rolling)
	@round						: Rounding value
	@flow_date_from				: Flow Date From
	@major_location				: Major Location IDs comma separated
	@minor_location				: Minor Location IDs comma separated
	@from_location				: From Location IDs comma separated
	@to_location				: To Location IDs comma separated
	@path_priority				: Path Priority value
	@opt_objective				: Optimization Objective
	@process_id					: Process Id
	@priority_from				: Priority From value for range
	@priority_to				: Priority To value for range
	@contract_id				: Contract Ids comma separated
	@pipeline_ids				: Pipeline Ids comma separated
	@xml_manual_vol				: Manual scheduling volume informations in XML format. This parameter is also used for passing box_id value.
	@flow_date_to				: Flow Date To
	@sub_book_id				: Sub Book Ids comma separated
	@uom						: Uom id
	@granularity				: Granularity 
	@period_from				: Period From
	@source_deal_header_ids		: Source Deal Header Ids
	@show_zero_volume			: Show Zero Volume flag
	@delivery_path				: Delivery Path ID
	@hide_pos_zero				: Hide Pos Zero flag
	@reschedule					: Reschedule flag
	@storage_location_id		: Storage Location Id
	@pool_location_id			: Pool Location Id
	@pool_id					: Pool Id
	@receipt_deals_id			: Receipt Deals Ids
	@delivery_deals_id			: Delivery Deals Ids
	@call_from					: Call From flag
	@volume_conversion			: Volume Conversion To UOM Id
	@counterparty_id			: Counterparty Id
	@output_process_id			: Process ID to output
	@batch_process_id			: Batch Process Id
	@batch_report_param			: Batch Report Param
	@enable_paging				: Enable Paging flag
*/
CREATE PROCEDURE [dbo].[spa_flow_optimization]
	@flag CHAR(2),
    @sub VARCHAR(500) = NULL,
    @str VARCHAR(500) = NULL,
    @book VARCHAR(500) = NULL,
    @commodity VARCHAR(20) = NULL, 
    @receipt_delivery VARCHAR(500) = NULL,
    @daily_rolling CHAR(1) = NULL,		--d:daily, m:monthly, r:daily rolling
    @round	TINYINT = 18,
    @flow_date_from DATETIME = NULL,
	@major_location VARCHAR(1000) = NULL,
	@minor_location VARCHAR(8000) = NULL,
	@from_location VARCHAR(8000) = NULL,
	@to_location VARCHAR(8000) = NULL,
	@path_priority INT = NULL,
	@opt_objective INT = NULL,
	@process_id varchar(2000) = NULL,
	@priority_from INT = NULL,
	@priority_to INT = NULL,
	@contract_id VARCHAR(5000) = NULL,
	@pipeline_ids VARCHAR(5000) = NULL,
	@xml_manual_vol VARCHAR(MAX) = NULL, --also used to pass box id
	@flow_date_to DATETIME = NULL,
	@sub_book_id varchar(2000) = null,
	@uom int = null,
	@granularity INT = 982, --this does not filter deal but filters position pick up
	@period_from VARCHAR(500) = null,
	@source_deal_header_ids VARCHAR(1000) = NULL,
	@show_zero_volume CHAR(1) = 'n', --added to show zero volume or not 'y' or 'n'
	@delivery_path INT = NULL, 
	@hide_pos_zero CHAR(1) = 'n',
	@reschedule tinyint = 0,
	@storage_location_id VARCHAR(8000) = NULL,
	@pool_location_id VARCHAR(8000) = NULL,
	@pool_id VARCHAR(8000) = NULL,
	@receipt_deals_id VARCHAR(8000) = NULL,
	@delivery_deals_id VARCHAR(8000) = NULL,
	@call_from VARCHAR(50) = NULL,
	@volume_conversion INT = NULL,
	@counterparty_id VARCHAR(5000) = NULL,
	@output_process_id VARCHAR(2000) = NULL OUTPUT ,
	@batch_process_id varchar(50)  =NULL,
	@batch_report_param varchar(500)=NULL   ,
	@enable_paging INT = NULL   --'1'=enable, '0'=disable
AS 
SET NOCOUNT ON
/*

declare @flag CHAR(2),
    @sub VARCHAR(500) = NULL,
    @str VARCHAR(500) = NULL,
    @book VARCHAR(500) = NULL,
    @commodity VARCHAR(20) = NULL, 
    @receipt_delivery VARCHAR(500) = NULL,
    @daily_rolling CHAR(1) = NULL,		--d:daily, m:monthly, r:daily rolling
    @round	TINYINT = 18,
    @flow_date_from DATETIME = NULL,
	@major_location VARCHAR(1000) = NULL,
	@minor_location VARCHAR(8000) = NULL,
	@from_location VARCHAR(8000) = NULL,
	@to_location VARCHAR(8000) = NULL,
	@path_priority INT = NULL,
	@opt_objective INT = NULL,
	@process_id varchar(2000) = NULL,
	@priority_from INT = NULL,
	@priority_to INT = NULL,
	@contract_id VARCHAR(5000) = NULL,
	@pipeline_ids VARCHAR(5000) = NULL,
	@xml_manual_vol VARCHAR(MAX) = NULL,
	@flow_date_to DATETIME = NULL,
	@sub_book_id varchar(2000) = null,
	@uom int = null,
	@granularity INT = 982, --this does not filter deal but filters position pick up
	@period_from VARCHAR(500) = null,
	@source_deal_header_ids VARCHAR(1000) = NULL,
	@show_zero_volume CHAR(1) = 'n', --added to show zero volume or not 'y' or 'n'
	@delivery_path INT = NULL, 
	@hide_pos_zero CHAR(1) = 'n',
	@reschedule tinyint = 0,
	@storage_location_id VARCHAR(8000) = NULL,
	@pool_location_id VARCHAR(8000) = NULL,
	@pool_id VARCHAR(8000) = NULL,
	@receipt_deals_id VARCHAR(8000) = NULL,
	@delivery_deals_id VARCHAR(8000) = NULL,
	@call_from VARCHAR(50) = NULL,
	@volume_conversion INT = NULL,
	@counterparty_id VARCHAR(5000) = NULL,
	@output_process_id VARCHAR(2000) = NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL   ,
	@enable_paging INT = NULL   --'1'=enable, '0'=disable

EXEC dbo.spa_drop_all_temp_table

DECLARE @run_user VARBINARY(128) = CONVERT(VARBINARY(128), 'sligal')
SET CONTEXT_INFO @run_user

SELECT @flag='pl'
,@flow_date_from='2019-11-11'
,@flow_date_to='2019-11-11'
,@process_id='1591089894260'
,@uom='6'
,@pool_id='3105,3113,3115,3116,3117,3118,3119,3120,3121,3122,3123,3124,3125,3126,3128,3131,3132,3133,3134,3135,3144,3104,3136,3137,3138,3139'
,@pipeline_ids='7968'
,@major_location='9,5,8,10,-10,7'
,@minor_location='3106,3107,3108,3109,3110,3111,3112,3125,3126,3127,3128,3129,3130,3131,3133,3139'

--select @flag='c'
--,@flow_date_from='2020-06-01'
--,@flow_date_to='2020-06-01'
--,@from_location='3146'
--,@to_location='3135'
--,@path_priority='303954'
--,@opt_objective='38301'
--,@uom='6'
--,@process_id='C7B55C58_003C_4C3B_A714_9B217D61B40C'
--,@reschedule='0'
--,@granularity='981'
--,@period_from='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'


--select @flag='p',@flow_date_from='2019-11-11',@minor_location='3107',@process_id='A196EFBA_C524_427C_A66E_F4965241F965',@flow_date_to='2019-11-11',@uom=6,@reschedule=0
--select @flag='p', @uom='null', @flow_date_from='2019-11-11',  @flow_date_to='2019-11-11', @minor_location='3132', @process_id='5C87FBF6_0518_46E8_A8A9_22289F2DBA72', @reschedule='0'

--select @flag='m'
--,@flow_date_from='2019-11-11'
--,@flow_date_to='2019-11-11'
--,@major_location='9,8,10,-10,7'
--,@minor_location='3131,3132'
--,@process_id='1591089894260'
--,@pipeline_ids='7968'
--,@uom='6'
--*/

SELECT @sub = NULLIF(NULLIF(@sub, ''), 'NULL')
	, @str = NULLIF(NULLIF(@str, ''), 'NULL')
	, @book = NULLIF(NULLIF(@book, ''), 'NULL')
	, @sub_book_id = NULLIF(NULLIF(@sub_book_id, ''), 'NULL')
	, @contract_id = NULLIF(NULLIF(@contract_id, ''), 'NULL')
	, @counterparty_id = NULLIF(NULLIF(@counterparty_id, ''), 'NULL')    
	, @period_from = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
	, @pipeline_ids = NULLIF(NULLIF(@pipeline_ids, ''), 'NULL')
	, @commodity = NULLIF(NULLIF(@commodity, ''), 'NULL')
	, @from_location = NULLIF(NULLIF(@from_location, ''), 'NULL')
	, @to_location = NULLIF(NULLIF(@to_location, ''), 'NULL')
	, @pool_location_id = NULLIF(NULLIF(@pool_location_id, ''), 'NULL')
	, @pool_id = NULLIF(NULLIF(@pool_id, ''), 'NULL')

--logic flag for proxy, there are two separate logic of proxy on behalf of child proxy and behalf of parent proxy. one logic is applied according to flag.
declare @proxy_logic_side char(1) = 'p' --p=>parent proxy logic
DECLARE @spa VARCHAR(MAX)
DECLARE @sql VARCHAR(MAX)
--temp fix, to minimize the change for range of terms
--2016-10-25
declare @flow_date_to_temp datetime = @flow_date_to
--set @flow_date_to = @flow_date_from

--temp fix

DECLARE @batch_flag INT = 1

DECLARE @min_contract_id INT

IF @batch_process_id IS null
BEGIN
	SET @batch_flag = 0
	SET @batch_process_id = REPLACE(NEWID(), '-', '_')
END

DECLARE @temptablename VARCHAR(100)
DECLARE @user_login_id_batch VARCHAR(30)
SET @user_login_id_batch = dbo.FNADBUser()	
SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id_batch, @batch_process_id)

IF @process_id IS NULL
	SET @process_id= dbo.FNAGetNewID()

/* SETTING PRIORITY CODE START */
select @priority_from = sdv.code from static_data_value sdv where sdv.value_id = @priority_from
select @priority_to = sdv.code from static_data_value sdv where sdv.value_id = @priority_to
/* SETTING PRIORITY CODE END */


--, @period_to = isnull(@period_to, case @granularity when 989 then 48 when 987 then 96 else 24 end)
/* SET PERIOD FROM AND PERIOD TO IF BLANK END */

--DECLARE @user_login_id VARCHAR(100) = 'sangam' -- dbo.FNADBUser()
DECLARE @user_login_id VARCHAR(100) = dbo.FNADBUser()
DECLARE @location_pos_info VARCHAR(500) = dbo.FNAProcessTableName('location_pos_info', @user_login_id, @process_id)
DECLARE @contractwise_detail_mdq VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq', @user_login_id, @process_id)
DECLARE @contractwise_detail_mdq_group VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq_group', @user_login_id, @process_id)
DECLARE @cw_mdq_group_wo_loss VARCHAR(500) = dbo.FNAProcessTableName('cw_mdq_group_wo_loss', @user_login_id, @process_id)
DECLARE @contractwise_detail_mdq_fresh VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq_fresh', @user_login_id, @process_id)
DECLARE @solver_decisions VARCHAR(500) = dbo.FNAProcessTableName('solver_decisions', @user_login_id, @process_id)
DECLARE @opt_deal_detail_pos VARCHAR(500) = dbo.FNAProcessTableName('opt_deal_detail_pos', @user_login_id, @process_id)
DECLARE @avail_volume_breakdowm VARCHAR(500) = dbo.FNAProcessTableName('avail_volume_breakdown', @user_login_id, @process_id)
DECLARE @check_solver_case VARCHAR(500)= dbo.FNAProcessTableName('check_solver_case', @user_login_id, @process_id)
DECLARE @storage_constraint VARCHAR(500)= dbo.FNAProcessTableName('storage_constraint', @user_login_id, @process_id)
DECLARE @storage_position VARCHAR(500)= dbo.FNAProcessTableName('storage_position', @user_login_id, @process_id)
DECLARE @hourly_pos_info VARCHAR(500) = dbo.FNAProcessTableName('hourly_pos_info', @user_login_id, @process_id)

SET @sql = '
			IF OBJECT_ID(''' + @storage_position + ''') IS NULL				
			BEGIN
				CREATE TABLE  ' + @storage_position + ' (
					type			CHAR(1),				
					location_id		INT,				
					position		NUMERIC(38,0)
				
				)
			END
			'			
			
EXEC(@sql)

DECLARE @minor_location_vals VARCHAR(5000) = ''

--commodity pick logic
IF @commodity IS NULL
BEGIN
	--include natural gas,gas as commodity when not provided
	SELECT @commodity = STUFF(
		(SELECT ',' + CAST(sc.source_commodity_id AS VARCHAR(10))
		FROM source_commodity sc
		WHERE sc.commodity_name IN ('Natural Gas', 'Gas')
		FOR XML PATH(''))
	,1, 1, '')

	--however if no commodity found set 50 as hardcoded
	SET @commodity = ISNULL(NULLIF(@commodity, ''), 50)
END

declare @transportation_template_name varchar(200) = 'Transportation NG'
DECLARE @transportation_template_id INT
declare @transportation_deal_type_value_id int = 13

SELECT @transportation_template_id = template_id  
FROM source_deal_header_template 
WHERE template_name = @transportation_template_name

IF @delivery_path IS NOT NULL 
BEGIN
	SELECT	@from_location =  from_location, 
			@to_location =  to_location 
	FROM delivery_path 
	WHERE path_id = @delivery_path
END


DECLARE @deal_detail_info VARCHAR(500) = dbo.FNAProcessTableName('deal_detail_info', @user_login_id, @process_id)

IF OBJECT_ID('tempdb..#sch_deals_hourly') IS NOT NULL 
	DROP TABLE #sch_deals_hourly
CREATE TABLE #sch_deals_hourly(source_deal_header_id INT)  

--IF @flag NOT IN ('r','y','q','g','z','x','d') 
IF @flag IN ('l','c','p','m','n','pl','w')
BEGIN

	/* FILTER PORTFOLIO START */
	--print 'FILTER PORTFOLIO START: ' + convert(VARCHAR(50),getdate() ,21)
	IF OBJECT_ID('tempdb..#books') IS NOT NULL
		DROP TABLE #books 

	CREATE TABLE #books (
		book_id INT
		, book VARCHAR(100) COLLATE DATABASE_DEFAULT
		, book_deal_type_map_id INT
		, source_system_book_id1 INT
		, source_system_book_id2 INT
		, source_system_book_id3 INT
		, source_system_book_id4 INT
	)		
	
	SET @sql = '
				INSERT INTO #books (book_id, book,book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4)		
				SELECT book.entity_id, book.entity_name [book], book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
				FROM source_system_book_map sbm            
				INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
				INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
				WHERE 1=1  '
				--only used sub_book_id filter AS ultimately sub_book_id values are passed.
				--+CASE WHEN  @sub IS NULL THEN '' ELSE ' AND stra.parent_entity_id IN ('+@sub+')' END
				--+CASE WHEN  @str IS NULL THEN '' ELSE ' AND stra.entity_id IN ('+@str+')' END
				--+CASE WHEN  @book IS NULL THEN '' ELSE ' AND book.entity_id IN ('+@book+')' END		
				+CASE WHEN  @sub_book_id IS NULL OR @sub_book_id = '' THEN '' ELSE ' AND sbm.book_deal_type_map_id IN ('+@sub_book_id+')' END			
		
	EXEC(@sql)

	IF @flag = 'c' OR @call_from = 'single_match'
	BEGIN
		SET @minor_location = LTRIM(RTRIM(ISNULL(@from_location, '-1') + ISNULL(',' + @to_location, '')))
		
	END

	DECLARE @proxy_locs VARCHAR(2000)
	DECLARE @child_proxy_locs VARCHAR(4000)

	SELECT @proxy_locs = STUFF(
								(	SELECT DISTINCT ','  + CAST(sml.proxy_location_id AS VARCHAR)
									FROM source_minor_location sml 
									INNER JOIN dbo.SplitCommaSeperatedValues(@minor_location) scsv 
										ON scsv.item = sml.source_minor_location_id
									WHERE sml.proxy_location_id IS NOT NULL
									FOR XML PATH(''))
							, 1, 1, '')

	SELECT @child_proxy_locs = STUFF(
										(	SELECT DISTINCT ',' + CAST(sml.source_minor_location_id AS VARCHAR(10))
											FROM source_minor_location sml
											INNER JOIN dbo.SplitCommaSeperatedValues(@minor_location + ISNULL(',' + @proxy_locs, '')) scsv 
												ON scsv.item = sml.proxy_location_id
											LEFT JOIN dbo.SplitCommaSeperatedValues(@minor_location) m 
												ON sml.source_minor_location_id = m.item
											WHERE m.item IS NULL	
											FOR XML PATH('')
											)
									,1,1,'')

	--SELECT @minor_location,@proxy_locs, @child_proxy_locs
	--return
	/* FILTER PORTFOLIO END */
	--print 'FILTER PORTFOLIO END: ' + convert(VARCHAR(50),getdate() ,21)

	--deal term breakdown
	IF @flag NOT IN ('m', 'n')	
	BEGIN
		--calculate deal term breakdown and store breakdown information on temp table
		BEGIN
			IF OBJECT_ID('tempdb..#deal_term_breakdown') IS NOT NULL
				DROP TABLE #deal_term_breakdown

			CREATE TABLE #deal_term_breakdown(
				source_deal_detail_id INT
				, term_start DATETIME
				, term_end DATETIME
				, proxy_record VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
				, location_id INT NULL
				, source_deal_header_id INT
				, curve_id INT NULL
			)
			/*
			IF @flag = 'p'
			BEGIN
				DECLARE @is_from INT
				DECLARE @is_to INT
				DECLARE @sqlCommand NVARCHAR(1000)

				SET @sqlCommand = N'SELECT @cnt=1 FROM ' + @contractwise_detail_mdq +  ' WHERE from_loc_id =  @minor_location '
				EXECUTE sp_executesql @sqlCommand, N'@minor_location NVARCHAR(4000), @cnt INT OUTPUT', @minor_location  =@minor_location,   @cnt=@is_from OUTPUT
		
				SET @sqlCommand = N'SELECT @cnt=1 FROM ' + @contractwise_detail_mdq +  ' WHERE to_loc_id =  @minor_location '
				EXECUTE sp_executesql @sqlCommand, N'@minor_location NVARCHAR(4000), @cnt INT OUTPUT', @minor_location  =@minor_location,   @cnt=@is_to OUTPUT

				SET @receipt_delivery = IIF(@is_from = 1, 'FROM', IIF(@is_to = 1, 'to', @receipt_delivery))
			END 
			*/
			IF OBJECT_ID('tempdb..#source_deal_header') IS NOT NULL
				DROP TABLE #source_deal_header

			CREATE TABLE #source_deal_header(
				source_deal_header_id INT,
				template_id INT,
				source_system_book_id1 INT,
				source_system_book_id2 INT,
				source_system_book_id3 INT,
				source_system_book_id4 INT,
				internal_deal_type_value_id INT,
				term_frequency CHAR(1) COLLATE DATABASE_DEFAULT
			)
		
			CREATE CLUSTERED INDEX ix_tempNCIndex_source_deal_header ON #source_deal_header (source_deal_header_id);

			IF @flag = 'c' OR @call_from = 'single_match'
			BEGIN
				IF NULLIF(@receipt_deals_id,'') IS NOT NULL
				BEGIN
					INSERT INTO #source_deal_header
					SELECT sdh.source_deal_header_id,sdh.template_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4 ,sdh.internal_deal_type_value_id, sdh.term_frequency  
					FROM dbo.SplitCommaSeperatedValues(@receipt_deals_id) scsv
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item 
				END
				ELSE
				BEGIN
					INSERT INTO #source_deal_header
					SELECT DISTINCT sdh.source_deal_header_id,sdh.template_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4 ,sdh.internal_deal_type_value_id, sdh.term_frequency  
					FROM source_deal_detail dd (NOLOCK)
					INNER JOIN source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = dd.source_deal_header_id 
						AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
						AND dd.physical_financial_flag='p'
					INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
						AND bk.source_system_book_id2 = sdh.source_system_book_id2
						AND bk.source_system_book_id3 = sdh.source_system_book_id3
						AND bk.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = dd.location_id
					CROSS APPLY (
						SELECT DISTINCT scsv1.item 
						FROM dbo.SplitCommaSeperatedValues(@from_location) scsv1 
						WHERE scsv1.item = dd.location_id 
					) scsv
					WHERE 1 = 1
						AND dd.physical_financial_flag='p'
						AND (ISNULL(@reschedule, 0) = 0 OR (ISNULL(sdh.internal_deal_type_value_id, -1) <> @transportation_deal_type_value_id AND sdh.template_id <> @transportation_template_id))
				END 

				IF NULLIF(@delivery_deals_id,'') IS NOT NULL
				BEGIN
					INSERT INTO #source_deal_header
					SELECT sdh.source_deal_header_id,sdh.template_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4 ,sdh.internal_deal_type_value_id, sdh.term_frequency   
					FROM dbo.SplitCommaSeperatedValues(@delivery_deals_id) scsv
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item 
				END
				ELSE
				BEGIN
					INSERT INTO #source_deal_header
					SELECT sdh.source_deal_header_id ,sdh.template_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4 ,sdh.internal_deal_type_value_id, sdh.term_frequency   
					FROM source_deal_detail dd (NOLOCK)
					INNER JOIN source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = dd.source_deal_header_id 
						AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
						AND dd.physical_financial_flag='p'
					INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
						AND bk.source_system_book_id2 = sdh.source_system_book_id2
						AND bk.source_system_book_id3 = sdh.source_system_book_id3
						AND bk.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = dd.location_id
					CROSS APPLY (
						SELECT scsv1.item 
						FROM dbo.SplitCommaSeperatedValues(@to_location) scsv1 
						WHERE scsv1.item = dd.location_id 
						GROUP BY scsv1.item 
					) scsv
					WHERE 1 = 1
						AND dd.physical_financial_flag='p'
						AND (ISNULL(@reschedule, 0) = 0 OR (ISNULL(sdh.internal_deal_type_value_id, -1) <> @transportation_deal_type_value_id AND sdh.template_id <> @transportation_template_id))
					GROUP BY sdh.source_deal_header_id ,sdh.template_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4 ,sdh.internal_deal_type_value_id, sdh.term_frequency   
				END 
			END

			INSERT INTO #deal_term_breakdown(source_deal_detail_id,term_start,term_end,proxy_record,location_id,source_deal_header_id,curve_id)
			SELECT source_deal_detail_id,tm.term_start,tm.term_end,scsv.proxy_record,dd.location_id,MAX(dd.source_deal_header_id),MAX(dd.curve_id)
			from source_deal_detail dd (nolock)
			INNER JOIN #source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = dd.source_deal_header_id
			INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
				and bk.source_system_book_id2 = sdh.source_system_book_id2
				and bk.source_system_book_id3 = sdh.source_system_book_id3
				and bk.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = dd.location_id
			CROSS APPLY (
				SELECT DISTINCT scsv1.item, NULL [proxy_record]
				FROM dbo.SplitCommaSeperatedValues(@minor_location) scsv1 
				where scsv1.item = dd.location_id 
				UNION ALL
				SELECT DISTINCT scsv2.item, 'parent_proxy' [proxy_record]
				FROM dbo.SplitCommaSeperatedValues(@proxy_locs) scsv2 
				WHERE scsv2.item = dd.location_id 
					AND scsv2.item NOT IN (SELECT s.item FROM dbo.SplitCommaSeperatedValues(@minor_location) s)
				UNION ALL
				SELECT DISTINCT scsv3.item, 'child_proxy' [proxy_record] 
				FROM dbo.SplitCommaSeperatedValues(@child_proxy_locs) scsv3
				WHERE scsv3.item = dd.location_id 
					AND scsv3.item NOT IN (SELECT s.item FROM dbo.SplitCommaSeperatedValues(@minor_location) s)
				--get proxy location child location's deal incase of total position drill report WHEN proxy exists ON location
				--OR (@flag = 'p' AND sml.proxy_location_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@minor_location)) AND sml.is_aggregate = 'y')
			) scsv
			OUTER APPLY (
				SELECT DATEADD(DAY, n - 1, dd.term_start) term_start, DATEADD(DAY, n - 1, dd.term_start) term_end  
				FROM seq 
				WHERE dd.term_end >= DATEADD(DAY, n - 1, dd.term_start) --AND dd.term_start <> dd.term_end
					AND dd.term_start BETWEEN 
						CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) 
						ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
					AND dd.physical_financial_flag='p'
			) tm
			LEFT JOIN optimizer_header oh ON oh.transport_deal_id = dd.source_deal_header_id
			WHERE  tm.term_start BETWEEN @flow_date_from 
				AND ISNULL(@flow_date_to_temp,@flow_date_from)
				AND dd.physical_financial_flag='p'
				AND dd.Leg=	CASE WHEN (ISNULL(@reschedule, 0) = 0 OR @flag = 'c') THEN dd.Leg
							ELSE
								CASE WHEN
									sdh.template_id = @transportation_template_id					
								THEN 
									CASE WHEN @flag IN ('l', 'p') THEN 
										CASE WHEN @receipt_delivery='FROM' THEN 2 ELSE 1 END
									ELSE NULL
									END
				
								ELSE dd.Leg 
								END
							END
				AND (ISNULL(oh.group_path_id, -1) <> -99 OR ISNULL(@reschedule, 0) = 0)
			GROUP BY source_deal_detail_id,tm.term_start,tm.term_end,scsv.proxy_record,dd.location_id
			UNION
			SELECT source_deal_detail_id,tm.term_start,tm.term_end,scsv.proxy_record,dd.location_id,MAX(dd.source_deal_header_id),MAX(dd.curve_id)
			from source_deal_detail dd (nolock)
			INNER JOIN source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = dd.source_deal_header_id 
				AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from) -- NOT required condition AS tm.term_start IS needed to filter
				AND dd.physical_financial_flag='p'
			INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
				and bk.source_system_book_id2 = sdh.source_system_book_id2
				and bk.source_system_book_id3 = sdh.source_system_book_id3
				and bk.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = dd.location_id
			CROSS APPLY (
				SELECT scsv1.item, NULL [proxy_record]
				FROM dbo.SplitCommaSeperatedValues(@minor_location) scsv1 
				where scsv1.item = dd.location_id 
					AND NOT(@flag = 'c' OR ISNULL(@call_from,'') = 'single_match')
				GROUP BY scsv1.item
				UNION ALL
				SELECT scsv2.item, 'parent_proxy' [proxy_record]
				FROM dbo.SplitCommaSeperatedValues(@proxy_locs) scsv2 
				WHERE scsv2.item = dd.location_id 
					AND scsv2.item NOT IN (SELECT s.item FROM dbo.SplitCommaSeperatedValues(@minor_location) s)
				GROUP BY scsv2.item
				UNION ALL
				SELECT scsv3.item, 'child_proxy' [proxy_record] 
				FROM dbo.SplitCommaSeperatedValues(@child_proxy_locs) scsv3
				WHERE scsv3.item = dd.location_id 
					AND scsv3.item NOT IN (SELECT s.item FROM dbo.SplitCommaSeperatedValues(@minor_location) s)
				GROUP BY scsv3.item
				UNION ALL
				SELECT scsv4.item, 'pool_id' [proxy_record]
				FROM dbo.SplitCommaSeperatedValues(@pool_id) scsv4 
				WHERE scsv4.item = dd.location_id
					AND scsv4.item NOT IN (SELECT s.item FROM dbo.SplitCommaSeperatedValues(@minor_location) s)
				GROUP BY scsv4.item
				UNION ALL
				SELECT scsv5.item, 'pool_location_id' [proxy_record] 
				FROM dbo.SplitCommaSeperatedValues(@pool_location_id) scsv5
				WHERE scsv5.item = dd.location_id
					AND scsv5.item NOT IN (SELECT s.item FROM dbo.SplitCommaSeperatedValues(@minor_location) s)
				GROUP  BY scsv5.item
			) scsv
			OUTER APPLY (
				SELECT DATEADD(DAY, n - 1, dd.term_start) term_start, DATEADD(DAY, n - 1, dd.term_start) term_end  
				FROM seq 
				WHERE dd.term_end >= DATEADD(DAY, n - 1, dd.term_start) --AND dd.term_start <> dd.term_end
					AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
					AND dd.physical_financial_flag='p'
			) tm
			LEFT JOIN optimizer_header oh ON oh.transport_deal_id = dd.source_deal_header_id
			WHERE  tm.term_start BETWEEN @flow_date_from 
				AND ISNULL(@flow_date_to_temp,@flow_date_from)
				AND dd.physical_financial_flag='p'
				AND dd.Leg=	CASE WHEN (ISNULL(@reschedule, 0) = 0 OR @flag = 'c') THEN dd.Leg
							ELSE
								CASE WHEN sdh.template_id = @transportation_template_id					
								THEN 
									CASE WHEN @flag IN ('l', 'p') THEN 
										CASE WHEN @receipt_delivery='FROM' THEN 2 ELSE 1 END
									ELSE NULL
									END				
								ELSE dd.Leg 
								END
							END
				AND (ISNULL(oh.group_path_id, -1) <> -99 OR ISNULL(@reschedule, 0) = 0)
			GROUP BY source_deal_detail_id,tm.term_start,tm.term_end,scsv.proxy_record,dd.location_id
			--print 'DETAIL TERM BREAKDOWN END: ' + convert(VARCHAR(50),getdate() ,21)
		END
	END


	IF @flag NOT IN ('m','n','w')
	BEGIN

		/* STORE LOCATION RANKING VALUES START */
		IF OBJECT_ID('tempdb..#tmp_location_ranking_values2') IS NOT NULL 
			DROP TABLE #tmp_location_ranking_values2
		
		SELECT ROW_NUMBER() OVER (PARTITION BY location_id ORDER BY effective_date DESC) cnt,sdv_lr.code [rank], lr.effective_date, lr.location_id 
		INTO #tmp_location_ranking_values2 --SELECT * FROM #tmp_location_ranking_values2 WHERE location_id IN (27382,30406)
		FROM location_ranking lr
		INNER JOIN static_data_value sdv_lr 
		ON sdv_lr.value_id = lr.rank_id
		WHERE lr.effective_date <= @flow_date_from

		/* STORE LOCATION RANKING VALUES END */

		/* STORE SCHEDULED DEAL INFO START */
		--print 'SCHEDULED DEAL INFO START: ' + convert(VARCHAR(50),getdate() ,21)
		DECLARE @scheduled_deals VARCHAR(150)
		SET @scheduled_deals = dbo.FNAProcessTableName('scheduled_deals', @user_login_id, @process_id)

		IF OBJECT_ID('tempdb..#sch_deal_info') IS NOT NULL 
			DROP TABLE #sch_deal_info
	
		SELECT sdd.source_deal_header_id 
			, CASE WHEN MAX(minor_from.proxy_location_id) IS NOT NULL AND MAX(minor_from.is_aggregate) = 'n' 
				THEN MAX(minor_from.proxy_location_id)
				ELSE MAX(minor_from.source_minor_location_id) 
			  END from_loc
			, CASE WHEN MAX(minor_to.proxy_location_id) IS NOT NULL AND MAX(minor_to.is_aggregate) = 'n' 
				THEN MAX(minor_to.proxy_location_id)
				ELSE MAX(minor_to.source_minor_location_id) 
			  END to_loc
			, MAX(sdh.contract_id) contract_id, CAST(ROUND(MIN(sdd.deal_volume), 1) AS INT) deal_volume 	
		INTO #sch_deal_info--SELECT * FROM #sch_deal_info WHERE from_loc = 5563
		FROM   source_deal_detail sdd
		INNER JOIN source_deal_header sdh 
			ON  sdh.source_deal_header_id = sdd.source_deal_header_id AND sdh.physical_financial_flag='p' 
			AND sdd.term_start BETWEEN @flow_date_from AND ISNULL(@flow_date_to, @flow_date_from)
		INNER JOIN source_deal_header_template sdht 
			ON sdht.template_id = sdh.template_id
		INNER JOIN #books bk 
			ON bk.source_system_book_id1 = sdh.source_system_book_id1
			AND bk.source_system_book_id2 = sdh.source_system_book_id2
			AND bk.source_system_book_id3 = sdh.source_system_book_id3
			AND bk.source_system_book_id4 = sdh.source_system_book_id4
		LEFT JOIN source_minor_location minor_from 
			ON minor_from.source_minor_location_id = sdd.location_id 
			AND sdd.Leg = 1
		LEFT JOIN source_minor_location minor_to 
			ON minor_to.source_minor_location_id = sdd.location_id 
			AND sdd.Leg = 2
		LEFT JOIN delivery_path dp 
			ON dp.from_location = minor_from.source_minor_location_id 
			AND dp.to_location = minor_to.source_minor_location_id
		WHERE ((sdht.template_name = @transportation_template_name 
				OR sdh.internal_deal_type_value_id = @transportation_deal_type_value_id
				) 
				AND ISNULL(@reschedule, 0) = 0)
				--	AND sdh.source_deal_header_id = 9526
				AND sdd.term_start BETWEEN @flow_date_from AND ISNULL(@flow_date_to, @flow_date_from)
		GROUP BY sdd.source_deal_header_id

		/* STORE SCHEDULED DEAL INFO END */
		--print 'SCHEDULED DEAL INFO END: ' + convert(VARCHAR(50),getdate() ,21)


		 ----print 'time01' + convert(VARCHAR(50),getdate() ,21)

		/* STORE LOSS FACTOR INFORMATION START */
		--print 'LOSS FACTOR INFORMATION START: ' + convert(VARCHAR(50),getdate() ,21)
		--extract latest effective date FOR loss factor1
		IF OBJECT_ID('tempdb..#tmp_lf1_eff_date') IS NOT NULL 
		DROP TABLE #tmp_lf1_eff_date

		SELECT pls.path_id, pls.contract_id, MAX(pls.effective_date) effective_date
		INTO #tmp_lf1_eff_date
		FROM path_loss_shrinkage pls
		WHERE pls.effective_date <= @flow_date_from
		GROUP BY pls.path_id, pls.contract_id

		--extract value associated WITH latest effective date found FOR loss factor1
		IF OBJECT_ID('tempdb..#tmp_lf1') IS NOT NULL 
		DROP TABLE #tmp_lf1

		SELECT *
		INTO #tmp_lf1
		FROM #tmp_lf1_eff_date t1
		CROSS APPLY (
			SELECT p.loss_factor, p.shrinkage_curve_id 
			FROM path_loss_shrinkage p 
			WHERE p.path_id = t1.path_id 
				AND p.effective_date = t1.effective_date
				and p.contract_id = t1.contract_id
		) ca_lf


		--extract latest effective date FOR loss factor2(time series data)
		IF OBJECT_ID('tempdb..#tmp_lf2_eff_date') IS NOT NULL 
		DROP TABLE #tmp_lf2_eff_date

		SELECT tsd.time_series_definition_id, MAX(tsd.effective_date) effective_date
		INTO #tmp_lf2_eff_date
		FROM time_series_data tsd
		WHERE tsd.effective_date <= @flow_date_from
		GROUP BY tsd.time_series_definition_id

		--extract value associated WITH latest effective date found FOR loss factor2(time series data)
		IF OBJECT_ID('tempdb..#tmp_lf2') IS NOT NULL 
		DROP TABLE #tmp_lf2

		SELECT t2.time_series_definition_id, t2.effective_date, ca_lf.loss_factor
		INTO #tmp_lf2
		FROM #tmp_lf2_eff_date t2
		CROSS APPLY (
			SELECT t.value loss_factor 
			FROM time_series_data t 
			WHERE t.time_series_definition_id = t2.time_series_definition_id AND t.effective_date = t2.effective_date
		) ca_lf

		--final store of loss factor information
		IF OBJECT_ID('tempdb..#tmp_loss_factor') IS NOT NULL 
		DROP TABLE #tmp_loss_factor

		SELECT l1.path_id,l1.contract_id, l1.effective_date effective_date1, l1.loss_factor loss_factor1
			, l1.shrinkage_curve_id, l2.effective_date effective_date2, l2.loss_factor loss_factor2
			, COALESCE(l1.loss_factor, l2.loss_factor, 0) loss_factor
		INTO #tmp_loss_factor
		FROM #tmp_lf1 l1
		LEFT JOIN #tmp_lf2 l2 
			ON l2.time_series_definition_id = l1.shrinkage_curve_id

		--SELECT * FROM #tmp_loss_factor
		--return
		/* STORE LOSS FACTOR INFORMATION END */
		--print 'LOSS FACTOR INFORMATION END: ' + convert(VARCHAR(50),getdate() ,21)

		/* STORE PATH MDQ INFORMATION START */
		--print 'PATH MDQ INFORMATION START: ' + convert(VARCHAR(50),getdate() ,21)
		--extract latest effective date FOR PATH mdq
		IF OBJECT_ID('tempdb..#tmp_pmdq_eff_date') IS NOT NULL 
		DROP TABLE #tmp_pmdq_eff_date

		SELECT dpm.path_id,MAX(dpm.effective_date) effective_date
		INTO #tmp_pmdq_eff_date --SELECT * FROM #tmp_pmdq_eff_date
		FROM delivery_path_mdq dpm
		WHERE dpm.effective_date <= @flow_date_from
		GROUP BY dpm.path_id

		--extract value associated WITH latest effective date found FOR PATH mdq
		IF OBJECT_ID('tempdb..#tmp_pmdq') IS NOT NULL 
		DROP TABLE #tmp_pmdq

		SELECT *
		INTO #tmp_pmdq --SELECT * FROM #tmp_pmdq WHERE path_id in (195,196,201)
		FROM #tmp_pmdq_eff_date t1
		CROSS APPLY (
			SELECT dpm.mdq, dpm.contract_id, dpm.rec_del 
			FROM delivery_path_mdq dpm 
			WHERE dpm.path_id = t1.path_id 
				AND dpm.effective_date = t1.effective_date
		) ca_lf

		/* STORE PATH MDQ INFORMATION END */
		--print 'PATH MDQ INFORMATION END: ' + convert(VARCHAR(50),getdate() ,21)

		----print 'time03' + convert(VARCHAR(50),getdate() ,21)

		/* STORE CONTRACT MDQ INFORMATION START */
		--print 'CONTRACT MDQ INFORMATION START: ' + convert(VARCHAR(50),getdate() ,21)
		--extract latest effective date FOR PATH mdq
		IF OBJECT_ID('tempdb..#tmp_cmdq_eff_date') IS NOT NULL 
		DROP TABLE #tmp_cmdq_eff_date

		SELECT tcm.contract_id, MAX(tcm.effective_date) effective_date
		INTO #tmp_cmdq_eff_date
		FROM transportation_contract_mdq tcm
		WHERE tcm.effective_date <= @flow_date_from
		GROUP BY tcm.contract_id

		--extract value associated WITH latest effective date found FOR PATH mdq
		IF OBJECT_ID('tempdb..#tmp_cmdq') IS NOT NULL 
		DROP TABLE #tmp_cmdq

		SELECT *
		INTO #tmp_cmdq
		FROM #tmp_cmdq_eff_date t1
		CROSS APPLY (
			SELECT tcm.mdq 
			FROM transportation_contract_mdq tcm 
			WHERE tcm.contract_id = t1.contract_id 
				AND tcm.effective_date = t1.effective_date
		) ca_lf

		/* STORE CONTRACT MDQ INFORMATION END */
		--print 'CONTRACT MDQ INFORMATION END: ' + convert(VARCHAR(50),getdate() ,21)

		----print 'time04' + convert(VARCHAR(50),getdate() ,21)

		/* STORE CAPACITY RELEASE DEALS INFO START */
		--print 'CAPACITY RELEASE DEALS INFO START: ' + convert(VARCHAR(50),getdate() ,21)
		IF OBJECT_ID('tempdb..#tmp_release_deals') IS NOT NULL 
			DROP TABLE #tmp_release_deals

		SELECT uddf.udf_value [delivery_path], sdd.term_start, SUM(sdd.deal_volume * CASE sdt.source_deal_type_name WHEN 'Capacity NG' THEN -1 ELSE 1 END) [released_mdq] 
		INTO #tmp_release_deals--SELECT * FROM #tmp_release_deals
		FROM source_deal_header sdh (NOLOCK)
		INNER JOIN source_deal_header_template sdht 
			ON sdh.template_id = sdht.template_id
		INNER JOIN maintain_field_template mft (NOLOCK)
			 ON sdht.field_template_id = mft.field_template_id AND mft.template_name = 'Capacity NG'
		INNER JOIN source_deal_detail sdd (NOLOCK) 
			ON sdd.source_deal_header_id = sdh.source_deal_header_id 
			AND sdd.term_start 
				BETWEEN 
					CASE WHEN sdht.term_frequency_type = 'm' THEN dbo.FNAGetFirstLastDayOfMonth(@flow_date_from, 'f') ELSE @flow_date_from END
				AND CASE WHEN sdht.term_frequency_type = 'm' THEN dbo.FNAGetFirstLastDayOfMonth(ISNULL(@flow_date_to,@flow_date_from), 'l') ELSE ISNULL(@flow_date_to,@flow_date_from) END
		LEFT JOIN user_defined_deal_fields_template uddft (NOLOCK)
			ON  uddft.field_name = 293432	-- delivery_path
			AND uddft.template_id = sdh.template_id
		LEFT JOIN user_defined_deal_fields uddf (NOLOCK)
			ON  uddf.source_deal_header_id = sdh.source_deal_header_id
			AND uddft.udf_template_id = uddf.udf_template_id
		LEFT JOIN source_deal_type sdt 
			ON sdt.source_deal_type_id = sdh.source_deal_type_id
		WHERE sdd.leg = 2 --AND uddf.udf_value=1473 --pick only leg1
		GROUP BY uddf.udf_value, sdd.term_start


		/* STORE CAPACITY RELEASE DEALS INFO END */
		--print 'CAPACITY RELEASE DEALS INFO END: ' + convert(VARCHAR(50),getdate() ,21)

		--STORE HEADER DEAL DETAIL UDF FIELD VALUES START
		--print 'UDF FIELD VALUES START: ' + convert(VARCHAR(50),getdate() ,21)
		IF OBJECT_ID('tempdb..#deal_detail_udf') IS NOT NULL 
			DROP TABLE #deal_detail_udf
		SELECT DISTINCT sdd.source_deal_detail_id,sdd.term_start, sdd.Leg, sdd.source_deal_header_id, uddft_pri.field_label, udddf.udf_value
		INTO #deal_detail_udf
		FROM  user_defined_deal_fields_template uddft_pri			
		LEFT JOIN user_defined_deal_detail_fields udddf
			ON uddft_pri.udf_template_id = udddf.udf_template_id	
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = udddf.source_deal_detail_id  AND sdd.physical_financial_flag='p'
		WHERE  1=1 
			AND uddft_pri.field_label IN ('priority') 
			AND uddft_pri.field_name IN(309152) --AND udddf.source_deal_detail_id=376127--priority
			AND (sdd.term_start BETWEEN @flow_date_from AND ISNULL(@flow_date_to, @flow_date_from))
	
		--store single path info used incase of group path
		BEGIN
			IF OBJECT_ID('tempdb..#single_path_detail') IS NOT NULL
				DROP TABLE #single_path_detail

			SELECT dpd.path_id [parent_path_id]
				, dpd.Path_name [path_id]
				, spath_clevel.contract_id
				, spath_clevel.[contract_name]
				, ISNULL(tm.mdq, dp.mdq) [path_mdq]
				, trd.released_mdq [released_mdq]
				, spath_sch_vol.deal_volume [sch_vol]
				, spath_clevel.contract_mdq
				, spath_clevel.contract_rmdq
				, lf.loss_factor
				, spath_clevel.contract_uom
			INTO #single_path_detail --SELECT * FROM #single_path_detail WHERE parent_path_id=197
			FROM delivery_path_detail dpd
			LEFT JOIN delivery_path dp ON dp.path_id = dpd.Path_name
			LEFT JOIN #tmp_pmdq tm ON tm.path_id = dpd.path_name
			LEFT JOIN #tmp_release_deals trd ON trd.delivery_path = dpd.path_name
			OUTER APPLY (
				SELECT  ccrs.path_id, dp2.path_name, cg.contract_id, cg.contract_name, ISNULL(tc.mdq, cg.mdq) [contract_mdq]
					, (ISNULL(tc.mdq, cg.mdq) * ISNULL(uom_cv.conversion_factor, 1)) - ISNULL(oa_crmdq.sch_vol,0) [contract_rmdq]
					, cg.volume_uom [contract_uom]
				FROM counterparty_contract_rate_schedule ccrs (NOLOCK)
				INNER JOIN contract_group cg ON cg.contract_id = ccrs.contract_id
				INNER JOIN delivery_path dp2 ON dp2.path_id = ccrs.path_id
				LEFT JOIN #tmp_cmdq tc ON tc.contract_id = cg.contract_id
				OUTER APPLY (
					SELECT sdi.contract_id, SUM(sdi.deal_volume) sch_vol
					FROM #sch_deal_info sdi
					WHERE sdi.contract_id = cg.contract_id
						AND ((sdi.from_loc = dp.from_location AND sdi.to_loc = dp.to_location AND ISNULL(cg.segmentation, 'n') = 'y') OR ISNULL(cg.segmentation, 'n') = 'n')
					GROUP BY sdi.contract_id
				) oa_crmdq
				OUTER APPLY (
					SELECT rvuc.conversion_factor
					FROM rec_volume_unit_conversion rvuc
					WHERE rvuc.from_source_uom_id = cg.volume_uom 
						AND rvuc.to_source_uom_id = @uom
				) uom_cv
				WHERE dp2.from_location = dp.from_location 
					AND dp2.to_location = dp.to_location 
					AND dp2.path_id = dp.path_id
		
			) spath_clevel
			OUTER APPLY (
				SELECT SUM(sdi.deal_volume) deal_volume
				FROM #sch_deal_info sdi
				WHERE sdi.from_loc = dp.from_location
					AND sdi.to_loc = dp.to_location
					AND sdi.contract_id = spath_clevel.contract_id			
				GROUP BY sdi.from_loc, sdi.to_loc, sdi.contract_id
			) spath_sch_vol
			LEFT JOIN #tmp_loss_factor lf ON lf.path_id = dp.path_id
				AND lf.contract_id = spath_clevel.contract_id
		END
		
	END

	--store hourly position info on process table
	IF @flag IN ('l','c','p')
	BEGIN
		--HOURLY POSITION CALC START
		BEGIN
			
			IF OBJECT_ID(@hourly_pos_info,'U') IS NOT NULL
				EXEC('DROP TABLE ' + @hourly_pos_info)
			SET @sql = '
			SELECT unpv.source_deal_header_id
				, unpv.location_id
				, unpv.curve_id
				, unpv.term_start
				, unpv.granularity
				, CAST(REPLACE(unpv.[hour],''hr'','''') AS INT) [hour]
				, unpv.period
				, IIF(unpv.location_name = ''storage'', ABS(CAST(unpv.[position] AS NUMERIC(20,5))), CAST(unpv.[position] AS NUMERIC(20,5))) [position]
				, unpv.source_deal_detail_id
			INTO ' + @hourly_pos_info + '
			FROM (
				SELECT rhpd.source_deal_header_id, dtb.source_deal_detail_id, rhpd.curve_id, rhpd.location_id, smj.location_name, rhpd.term_start, rhpd.granularity, rhpd.period, 
				rhpd.hr1, rhpd.hr2, rhpd.hr3, rhpd.hr4, rhpd.hr5, rhpd.hr6, rhpd.hr7, rhpd.hr8, rhpd.hr9, rhpd.hr10, rhpd.hr11, rhpd.hr12
				, rhpd.hr13, rhpd.hr14, rhpd.hr15, rhpd.hr16, rhpd.hr17, rhpd.hr18, rhpd.hr19, rhpd.hr20, rhpd.hr21, rhpd.hr22, rhpd.hr23, rhpd.hr24, rhpd.hr25
	
				FROM report_hourly_position_deal rhpd
				INNER JOIN #deal_term_breakdown dtb ON dtb.source_deal_header_id = rhpd.source_deal_header_id
					AND dtb.location_id = rhpd.location_id
					AND dtb.term_start = rhpd.term_start
					AND dtb.curve_id = rhpd.curve_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = rhpd.source_deal_header_id
				INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
					AND sdt.source_deal_type_name NOT LIKE ''Capacity%''
				INNER JOIN source_minor_location sml
					ON sml.source_minor_location_id = rhpd.location_id
				INNER JOIN source_major_location smj
					ON smj.source_major_location_id = sml.source_major_location_id
				
				UNION ALL
				SELECT rhpp.source_deal_header_id, dtb.source_deal_detail_id, rhpp.curve_id, rhpp.location_id, smj.location_name, rhpp.term_start, rhpp.granularity, rhpp.period, 
				rhpp.hr1, rhpp.hr2, rhpp.hr3, rhpp.hr4, rhpp.hr5, rhpp.hr6, rhpp.hr7, rhpp.hr8, rhpp.hr9, rhpp.hr10, rhpp.hr11, rhpp.hr12
				, rhpp.hr13, rhpp.hr14, rhpp.hr15, rhpp.hr16, rhpp.hr17, rhpp.hr18, rhpp.hr19, rhpp.hr20, rhpp.hr21, rhpp.hr22, rhpp.hr23, rhpp.hr24, rhpp.hr25
	
				FROM report_hourly_position_profile rhpp
				INNER JOIN #deal_term_breakdown dtb ON dtb.source_deal_header_id = rhpp.source_deal_header_id
					AND dtb.location_id = rhpp.location_id
					AND dtb.term_start = rhpp.term_start
					AND dtb.curve_id = rhpp.curve_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = rhpp.source_deal_header_id
				INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
					AND sdt.source_deal_type_name NOT LIKE ''Capacity%''
				INNER JOIN source_minor_location sml
					ON sml.source_minor_location_id = rhpp.location_id
				INNER JOIN source_major_location smj
					ON smj.source_major_location_id = sml.source_major_location_id
			) a
			UNPIVOT ([position] FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12
			, hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24, hr25) 
			) AS unpv
			WHERE CAST(REPLACE([hour],''hr'','''') AS INT) IN (' + @period_from + ')
			'
			--print(@sql)
			EXEC(@sql)
		END
	END

END

IF @flag = 'l' --Extract receipt location and delivery location with positions for flow optimization grid
BEGIN
	
	--STORAGE POSITION EXTRACT
	DECLARE @storage_position_interim VARCHAR(500) = dbo.FNAProcessTableName('storage_position_interim', @user_login_id, @process_id)
	DECLARE @sql_mid VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#storage_position_html') IS NOT NULL
		DROP TABLE #storage_position_html

	CREATE TABLE #storage_position_html (
		location VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL
		, contract VARCHAR(500) COLLATE DATABASE_DEFAULT NULL
		, term VARCHAR(max) COLLATE DATABASE_DEFAULT NULL
		, injection  VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL
		, injection_amount  VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL
		, withdrawal  VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL
		, withdrawal_amount  VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL
		, wacog  VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL
		, balance VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
		, balance_amount VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
		, uom VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
	)

	IF OBJECT_ID('tempdb..#locwise_range_total') IS NOT NULL
		DROP TABLE #locwise_range_total

	CREATE TABLE #locwise_range_total (
		location_id INT NULL,
		total_position NUMERIC(20,5),
		[beg_pos] NUMERIC(20,5)
	)

	DECLARE @is_loc_storage INT = 0
	IF EXISTS(
		SELECT TOP 1 1
		FROM source_minor_location sml
		INNER JOIN source_major_location smj ON smj.source_major_location_id = sml.source_major_location_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@minor_location) scsv ON scsv.item = sml.source_minor_location_id
		WHERE smj.location_name = 'storage'
	)
	BEGIN
		SET @is_loc_storage = 1
	END

	IF @is_loc_storage = 1
	BEGIN
		SET @sql_mid = '
		IF OBJECT_ID(''' + @storage_position_interim + ''') IS NOT NULL
		BEGIN
			INSERT INTO #storage_position_html
			SELECT * FROM ' + @storage_position_interim + '
		END
		ELSE
		BEGIN		

			INSERT INTO #storage_position_html
			EXEC spa_storage_position_report @location_id = ''' + @from_location + ISNULL(',' + @to_location, '') + ''', @term_start = ''' + convert(VARCHAR(50), @flow_date_from, 21)+ ''',@term_end = ''' + convert(VARCHAR(50), @flow_date_to, 21) + ''', @uom = ''' + CAST(@uom AS VARCHAR(10))+ ''', @volume_conversion = ''' + CAST(@uom AS VARCHAR(10)) + ''', @call_from=''optimization''
		
			IF OBJECT_ID(''' + @storage_position_interim + ''') IS NOT NULL drop table ' + @storage_position_interim + '
			SELECT * into ' + @storage_position_interim + ' from #storage_position_html

		END
			'
	
		EXEC(@sql_mid)
		--print 'storage sp call END: ' + convert(VARCHAR(50),getdate() ,21)
		
	END	
	SELECT dbo.FNAStripHTML(sp.location) location
		, dbo.FNAStripHTML(sp.contract) contract
		, RIGHT(dbo.FNAStripHTML(sp.term), 10) term
		, dbo.FNAStripHTML(sp.injection) injection
		, dbo.FNAStripHTML(sp.injection_amount) injection_amount
		, dbo.FNAStripHTML(sp.withdrawal) withdrawal
		, dbo.FNAStripHTML(sp.withdrawal_amount) withdrawal_amount
		, dbo.FNAStripHTML(sp.wacog) wacog
		, sp.balance balance
		, dbo.FNAStripHTML(sp.uom) uom
	INTO #storage_position
	FROM #storage_position_html sp

	--select * from #storage_position
	--return

	--derive minor location from from location and to location
	BEGIN
		IF @from_location IS NULL AND @to_location IS NULL
		BEGIN
			SELECT @minor_location_vals = STUFF(
					(SELECT DISTINCT ','  + cast(minor.source_minor_location_id AS varchar)
					FROM source_minor_location minor	
					LEFT JOIN source_major_location major 
						ON major.source_major_location_ID = minor.source_major_location_ID		  
					INNER JOIN dbo.SplitCommaSeperatedValues(@major_location) scsv 
						ON scsv.item = major.source_major_location_ID
					WHERE 1 = 1  
					FOR XML PATH(''))
				, 1, 1, '')

			SELECT @minor_location = ISNULL(@minor_location_vals, 0)
		
		END	
		ELSE IF @from_location IS NULL OR @to_location IS NULL
		BEGIN		
			IF @receipt_delivery = 'FROM'
			BEGIN
				if @from_location is null
				begin
					SELECT @minor_location_vals = STUFF(
						(SELECT DISTINCT ','  + cast(minor.source_minor_location_id AS VARCHAR)
						FROM source_minor_location minor	
						LEFT JOIN source_major_location major 
							ON major.source_major_location_ID = minor.source_major_location_ID
						INNER JOIN dbo.SplitCommaSeperatedValues(@major_location) scsv 
							ON scsv.item = major.source_major_location_ID
						WHERE 1=1
						FOR XML PATH(''))
					, 1, 1, '')

					SELECT @minor_location = ISNULL(@minor_location, 0) + ',' + ISNULL(@minor_location_vals, 0)
				end
			
			END			
			ELSE
			BEGIN
				if @to_location is null
				begin
					SELECT @minor_location_vals = STUFF(
						(SELECT DISTINCT ','  + cast(minor.source_minor_location_id AS VARCHAR)
						FROM source_minor_location minor	
						LEFT JOIN source_major_location major 
							ON major.source_major_location_ID = minor.source_major_location_ID
						INNER JOIN dbo.SplitCommaSeperatedValues(@major_location) scsv 
							ON scsv.item = major.source_major_location_ID
						WHERE 1=1
						FOR XML PATH(''))
					, 1, 1, '')
				
					SELECT @minor_location = ISNULL(@minor_location, 0) + ',' + ISNULL(@minor_location_vals, 0)
				end
			
			END
		
		END
		ELSE IF @from_location IS NOT NULL AND @to_location IS NOT NULL
		BEGIN
			if @receipt_delivery = 'FROM'
				SELECT @minor_location = @from_location 
			else
				SELECT @minor_location = @to_location 
		END
	END

	--select @minor_location
	--select @proxy_locs
	--return

	--CALCULATE TOTAL POSITION FOR RANGE OF TERMS START
	IF @receipt_delivery = 'FROM' AND OBJECT_ID(@deal_detail_info,'U') IS NOT NULL
	BEGIN
		EXEC('DROP TABLE ' + @deal_detail_info)
	END
	
	SET @sql = CASE WHEN @receipt_delivery = 'FROM' THEN '
	SELECT ''from'' [market_side], sdd.source_deal_header_id, sdd.source_deal_detail_id,sdd.curve_id, dtb.term_start, sdd.location_id, sdd.deal_volume, CAST(NULL AS NUMERIC(38,17)) total_volume, CAST(NULL AS NUMERIC(38,17)) avail_volume, GETDATE() [create_ts]
	INTO ' + @deal_detail_info
	ELSE 
	'
	INSERT INTO ' + @deal_detail_info + '
	SELECT ''to'' [market_side], sdd.source_deal_header_id, sdd.source_deal_detail_id,sdd.curve_id, dtb.term_start, sdd.location_id, sdd.deal_volume,NULL, NULL,GETDATE() [create_ts]' 
	end +
	'
	FROM source_deal_detail sdd
	INNER JOIN #deal_term_breakdown dtb ON dtb.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN dbo.SplitCommaSeperatedValues(''' + @minor_location + ''') l1 ON l1.item = sdd.location_id
	INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
		AND bk.source_system_book_id2 = sdh.source_system_book_id2
		AND bk.source_system_book_id3 = sdh.source_system_book_id3
		AND bk.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	OUTER APPLY ( 
		SELECT SUM(volume) vol 
		FROM source_deal_detail_hour 
		WHERE source_deal_detail_id = sdd.source_deal_detail_id 
			AND term_date= dtb.term_start 
			AND sdd.deal_volume_frequency=''t''
     ) sddh
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	LEFT JOIN #deal_detail_udf detail_udf ON detail_udf.source_deal_detail_id = sdd.source_deal_detail_id
	LEFT JOIN static_data_value sdv_d_pr ON CAST(sdv_d_pr.value_id AS VARCHAR(10)) = detail_udf.udf_value	
	WHERE sdh.commodity_id IN (' + @commodity + ')
		AND sdh.physical_financial_flag = ''p''
		AND CASE  
				WHEN sdht.template_name = ''' + @transportation_template_name + ''' THEN ISNULL(TRY_CONVERT(INT, sdh.description2), 168)
				ELSE ISNULL(TRY_CONVERT(INT, sdv_d_pr.code), 168)
			END BETWEEN ' + CAST(ISNULL(@priority_from,0) AS VARCHAR(10)) + ' AND ' + CAST(ISNULL(@priority_to,9999) AS VARCHAR(10)) + '
		AND sdt.source_deal_type_name NOT LIKE ''Capacity%''
	'	
	--PRINT(@sql)
	EXEC(@sql)
	--CALCULATE TOTAL POSITION FOR RANGE OF TERMS END

	--get first term start of available position
	DECLARE @first_term_start DATETIME
	SELECT @first_term_start = MIN(dtb.term_start) FROM #deal_term_breakdown dtb

	--pick location wise total position and beginning position
	SET @sql = '
	INSERT INTO #locwise_range_total -- select * from #locwise_range_total
	SELECT hp.location_id
		, SUM(hp.position * ISNULL(rvuc.conversion_factor, 1)) [total_position]
		, SUM(IIF(hp.term_start = ''' + CONVERT(VARCHAR(10), @first_term_start, 21) + ''', hp.position,0)) [beg_pos]
	FROM ' + @hourly_pos_info + ' hp 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = hp.source_deal_detail_id
	LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.to_source_uom_id = ' + CAST(@uom AS VARCHAR(5)) + '
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	GROUP BY hp.location_id
	'
	EXEC(@sql)

	IF OBJECT_ID('tempdb..#tmp_sdd') IS NOT NULL 
		DROP TABLE #tmp_sdd

	select sdd.location_id, sml.Location_Name, sdd.source_deal_detail_id, sdd.source_deal_header_id, sdht.template_name
		, case 
			when sdht.template_name = @transportation_template_name then sdh.description2
			else isnull(sdv_d_pr.code, 168) 
		  end [priority]
		, dtb.term_start
		, ISNULL(rvuc.conversion_factor, 1) * sdd.total_volume * case sdd.buy_sell_flag when 's' then -1 else 1 end [total_volume]
		, ISNULL(rvuc.conversion_factor, 1) * sdd.deal_volume * case sdd.buy_sell_flag when 's' then -1 else 1 end [deal_volume]
		, sdd.Leg
		, sdd.deal_volume_frequency
		, dtb.proxy_record
		, sml.proxy_location_id
		, coalesce(sml.proxy_position_type, indirect_proxy_pos_type_c.proxy_position_type,indirect_proxy_pos_type_p.proxy_position_type) [proxy_position_type]

		--set proxy position for case where proxy_pos = self position
		, case	when (sml.proxy_location_id is not null and coalesce(sml.proxy_position_type, indirect_proxy_pos_type_c.proxy_position_type,indirect_proxy_pos_type_p.proxy_position_type) = 110201)
					then ISNULL(rvuc.conversion_factor, 1) * sdd.deal_volume * case sdd.buy_sell_flag when 's' then -1 else 1 end
				else null
		  end [proxy_position_value]
		--, null [proxy_position_value]
		--,indirect_proxy_pos_type.source_minor_location_id [indirect_child_loc_id]
		--,indirect_proxy_pos_type.proxy_position_type [indirect_proxy_position_type]
	into #tmp_sdd --select proxy_record,* from #deal_term_breakdown where location_id = 30376
	from source_deal_detail sdd
	INNER JOIN source_deal_header sdh 
		ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		AND sdh.physical_financial_flag='p'
	INNER JOIN #deal_term_breakdown dtb 
		ON dtb.source_deal_detail_id = sdd.source_deal_detail_id 
		AND sdd.physical_financial_flag='p'
	--inner join (select distinct item from dbo.SplitCommaSeperatedValues(@minor_location + ISNULL(',' + @proxy_locs, ''))) loc_list on loc_list.item = sdd.location_id
	outer apply(
		select distinct item 
		from dbo.SplitCommaSeperatedValues(@minor_location) l1
		where l1.item = sdd.location_id
	) loc_list
	--inner join dbo.SplitCommaSeperatedValues('5524,5561,5562,5563,5565,5566,5569,5631,6070,6071,6072') loc_list on loc_list.item = sdd.location_id
	INNER JOIN #books bk 
		ON bk.source_system_book_id1 = sdh.source_system_book_id1
		AND bk.source_system_book_id2 = sdh.source_system_book_id2
		AND bk.source_system_book_id3 = sdh.source_system_book_id3
		AND bk.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_type sdt 
		ON sdt.source_deal_type_id = sdh.source_deal_type_id
    INNER JOIN dbo.SplitCommaSeperatedValues(@commodity) com ON com.item = sdh.commodity_id
	OUTER APPLY ( 
		SELECT SUM(volume) vol 
		FROM source_deal_detail_hour 
		WHERE source_deal_detail_id = sdd.source_deal_detail_id 
		AND term_date = dtb.term_start 
		AND sdd.deal_volume_frequency = 't'
    ) sddh
	LEFT JOIN source_minor_location sml 
		ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_deal_header_template sdht 
		ON sdht.template_id = sdh.template_id
	LEFT JOIN #deal_detail_udf detail_udf 
		ON detail_udf.source_deal_detail_id = sdd.source_deal_detail_id
	LEFT JOIN static_data_value sdv_d_pr 
		ON CAST(sdv_d_pr.value_id AS VARCHAR(10)) = detail_udf.udf_value
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = @uom 
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	outer apply (
		select top 1 sml1.source_minor_location_id, sml1.proxy_position_type
		from source_minor_location sml1
		where (sml.proxy_location_id is not null)
			and sml1.source_minor_location_id <> sml.source_minor_location_id
			and sml1.proxy_location_id = sml.proxy_location_id
			and sml1.proxy_position_type is not null
	) indirect_proxy_pos_type_c
	outer apply (
		select top 1 sml1.source_minor_location_id, sml1.proxy_position_type
		from source_minor_location sml1
		where (sml.proxy_location_id is null)
			and sml1.proxy_location_id = sml.source_minor_location_id
			and sml1.proxy_position_type is not null
	) indirect_proxy_pos_type_p
	where 1 = 1 
		AND CASE 
			WHEN sdht.template_name = @transportation_template_name
				THEN ISNULL(TRY_CONVERT(INT, sdh.description2), 168)
			ELSE ISNULL(TRY_CONVERT(INT, sdv_d_pr.code), 168)
			END BETWEEN ISNULL(@priority_from, 0)
			AND ISNULL(@priority_to, 9999)
		AND sdt.source_deal_type_name not like 'Capacity%'

	IF OBJECT_ID('tempdb..#loc_proxy_level') IS NOT NULL 
	DROP TABLE #loc_proxy_level

	SELECT ts1.location_id
		, SUM(ts1.deal_volume) deal_volume
		, MAX(ts1.proxy_location_id) proxy_location_id
		, MAX(ts1.proxy_position_type) proxy_position_type
		, NULL [proxy_pos_value_total]
		, NULL [proxy_pos_value_beg]
		, SUM(IIF(ts1.term_start = dbo.FNAGetFirstLastDayOfMonth(@flow_date_from,'f'),ts1.deal_volume,NULL)) deal_volume_beg
	into #loc_proxy_level
	from #tmp_sdd ts1 
	group by ts1.location_id

	update ts set ts.proxy_pos_value_total
		= case when proxy_position_type is not null then
			case when ts.proxy_location_id is not null and ts.proxy_position_type = 110201 then 
						(select sum(t2.deal_volume) from #loc_proxy_level t2 where t2.proxy_location_id = ts.proxy_location_id) 
				 when ts.proxy_location_id is not null and ts.proxy_position_type = 110200 then 
					(select t1.deal_volume from #loc_proxy_level t1 where t1.location_id = ts.proxy_location_id)
				 when ts.proxy_location_id is null and proxy_position_type = 110200 then ts.deal_volume
				 when ts.proxy_location_id is null and proxy_position_type = 110201 then
					ts.deal_volume + (select sum(t2.deal_volume) from #loc_proxy_level t2 where t2.proxy_location_id = ts.location_id) 
			else null 
			end
		else null
	  end,
	  ts.proxy_pos_value_beg
		= case when proxy_position_type is not null then
			case when ts.proxy_location_id is not null and ts.proxy_position_type = 110201 then 
					(select sum(t2.deal_volume) from #loc_proxy_level t2 where t2.proxy_location_id = ts.proxy_location_id)
				 when ts.proxy_location_id is not null and ts.proxy_position_type = 110200 then 
					(select t1.deal_volume_beg from #loc_proxy_level t1 where t1.location_id = ts.proxy_location_id)
				 when ts.proxy_location_id is null and proxy_position_type = 110200 then ts.deal_volume_beg
				 when ts.proxy_location_id is null and proxy_position_type = 110201 then
					ts.deal_volume_beg + (select sum(t2.deal_volume_beg) from #loc_proxy_level t2 where t2.proxy_location_id = ts.location_id) 
			else null 
			end
		else null
	  end
	from #loc_proxy_level ts

	update ts
	set ts.proxy_pos_value_total = (select t1.proxy_pos_value_total from #loc_proxy_level t1 where t1.location_id = ts.proxy_location_id)
		, ts.proxy_pos_value_beg = (select t1.proxy_pos_value_beg from #loc_proxy_level t1 where t1.location_id = ts.proxy_location_id)
	from #loc_proxy_level ts
	WHERE ts.proxy_location_id IS NOT NULL 
		AND ts.proxy_position_type = 110201
		AND ts.proxy_pos_value_beg IS NULL

	----print 'time4' + convert(varchar(50),getdate() ,21)

	UPDATE #tmp_sdd
		SET total_volume = CASE WHEN deal_volume_frequency = 'm' 
							THEN total_volume/([dbo].[FNALastDayInMonth](term_start))
							ELSE total_volume
							END,
			deal_volume = CASE WHEN deal_volume_frequency = 'm' 
							THEN deal_volume/([dbo].[FNALastDayInMonth](term_start))
							ELSE deal_volume
							END

	IF OBJECT_ID('tempdb..#tmp_location_pos_info') IS NOT NULL 
		DROP TABLE #tmp_location_pos_info

	select 
		@receipt_delivery [from_to]
		, minor.location_name [location_name]
		, minor.source_minor_location_id [location_id]
		, major.location_name [location_type]
		, round(
			case major.location_name 
				when 'storage' then isnull(max(oa_sp.storage_position), 0)
				--else ISNULL(sum(sdd.deal_volume), 0)
				else ISNULL(max(beg_vol.beg_vol), 0)
			end
		, @round) [position]
		, round(
			case major.location_name 
				when 'storage' then isnull(max(oa_sp.storage_position), 0)
				else ISNULL(sum(sdd.deal_volume), 0)
			end
		, @round) [total_position]
		, isnull(lr.[rank], 9999) [rank]
		, isnull(max(minor.proxy_location_id), minor.source_minor_location_id) [proxy_loc_id]
		, null [proxy_pos]
		, null [proxy_pos_total]
		, null [is_aggregate]
		, CAST(NULL AS CHAR(1)) is_unschedule
		, max(beg_vol.[proxy_position_type]) [proxy_position_type]
	into #tmp_location_pos_info --select * from #tmp_location_pos_info
	--select *
	from source_minor_location minor (nolock)
	cross apply(
		select distinct item 
		from dbo.SplitCommaSeperatedValues(@minor_location) l1
		where l1.item = minor.source_minor_location_id
	) loc_list
	LEFT JOIN #tmp_sdd sdd --select * from #tmp_sdd
		ON ISNULL(sdd.location_id, -1) = minor.source_minor_location_id
	LEFT JOIN source_major_location major 
		ON major.source_major_location_ID = minor.source_major_location_ID
	LEFT JOIN #tmp_location_ranking_values2 lr ON lr.cnt = 1 AND lr.location_id = minor.source_minor_location_id --AND lr.effective_date <= @flow_date_from
	OUTER APPLY (
		--changed logic to show daily balance for that term on storage location (modified on:2019-08-12, for TRMTracker_Gas_Demo, Consulted BA: Sulav Nepal, Dev: Sangam Ligal)
		select 
			--sum(cast(sp.injection as float) - cast(sp.withdrawal as float)) [storage_position]
			sum(cast(sp.balance as numeric(20,10))) [storage_position]
		from #storage_position sp
		where sp.location = minor.Location_Name and cast(sp.term as datetime) = isnull(@flow_date_to,@flow_date_from)
		group by sp.location
	) oa_sp
	--left join #tmp_proxy_agg2 pp on pp.source_minor_location_id = minor.source_minor_location_id
	--outer apply (select top 1 tpa1.pos_agg from #tmp_proxy_agg2 tpa1 where tpa1.proxy_location_id = minor.source_minor_location_id) child_proxy_pos
	outer apply ( 
		select sum(tsdd.deal_volume) [beg_vol], max(tsdd.proxy_position_type) [proxy_position_type]
		from #tmp_sdd tsdd
		where tsdd.term_start = @flow_date_from
			and tsdd.location_id = sdd.location_id
	) beg_vol
	WHERE 1=1 
		--AND IIF(@hide_pos_zero = 'y',sdd.location_id, 1) IS NOT NULL	
	GROUP BY  minor.location_id
			, minor.Location_Name
			, minor.source_minor_location_id
			, major.location_name
			, ISNULL(lr.[rank], 9999)
			, lr.effective_date

	UPDATE tlpi 
		SET tlpi.proxy_pos = ISNULL(lpl1.proxy_pos_value_beg,lpl2.proxy_pos_value_beg)
			,tlpi.proxy_pos_total = ISNULL(lpl1.proxy_pos_value_total,lpl2.proxy_pos_value_total)
	from #tmp_location_pos_info tlpi
	OUTER APPLY (
		SELECT
			proxy_pos_value_beg
			,proxy_pos_value_total
		FROM #loc_proxy_level lpl
		WHERE lpl.location_id = tlpi.location_id
	) lpl1
	OUTER APPLY (
		SELECT
			proxy_pos_value_beg
			,proxy_pos_value_total
		FROM #loc_proxy_level lpl
		WHERE lpl.proxy_location_id = tlpi.location_id
	) lpl2
		
	--imbalance path logic
	BEGIN
		DECLARE @delivery_path_id INT
				,@grp_delivery_path_id INT 

		SELECT @delivery_path_id = value_id 
		FROM static_data_value sdv 
		WHERE code = 'Delivery Path'	
	
		SELECT @grp_delivery_path_id = value_id 
		FROM static_data_value sdv 
		WHERE code = 'Path detail id'	

		SET @sql = 'UPDATE tlpi
						SET is_unschedule = ''y''
					FROM #tmp_location_pos_info tlpi
					INNER JOIN ' + @deal_detail_info + ' ddi
						ON tlpi.location_id = ddi.location_id
					INNER JOIN source_deal_detail sdd
						ON sdd.source_deal_detail_id = ddi.source_deal_detail_id
					LEFT JOIN optimizer_detail od
						ON od.source_deal_header_id = sdd.source_deal_header_id 
					WHERE tlpi.position = 0 
						AND od.flow_date BETWEEN ''' + CAST(@flow_date_from AS VARCHAR(20)) + ''' AND ''' + CAST(ISNULL(@flow_date_to, @flow_date_from) AS VARCHAR(20)) + '''
						AND tlpi.from_to = ''FROM''
						AND od.source_deal_header_id IS NULL'

		EXEC(@sql)
	
	
		IF OBJECT_ID('tempdb..#temp_imbalance_path') IS NOT NULL 
			DROP TABLE #temp_imbalance_path
	
		CREATE TABLE #temp_imbalance_path (
			from_to VARCHAR(20) COLLATE DATABASE_DEFAULT,
			location_id INT,
			imbalance_location_id INT	
		)

		DECLARE @all_demand_loc_id VARCHAR(5000)

		SET @sql = '
					INSERT INTO #temp_imbalance_path
					SELECT DISTINCT ''All'',tlpi.location_id,  ISNULL(dp.to_location, dp_sp.to_location) to_location
					FROM #tmp_location_pos_info tlpi
					LEFT JOIN ' + @deal_detail_info + ' ddi
						ON tlpi.location_id = ddi.location_id
					LEFT JOIN source_deal_detail sdd
						ON sdd.source_deal_detail_id = ddi.source_deal_detail_id
					LEFT JOIN optimizer_detail od
						ON od.transport_deal_id = sdd.source_deal_header_id 
					OUTER APPLY (	SELECT MAX(path_name) path_id 
									FROM delivery_path_detail 
									WHERE path_id = od.group_path_id
								) last_path
					LEFT JOIN delivery_path dp
						ON last_path.path_id = dp.path_id
					LEFT JOIN delivery_path dp_sp
						ON dp_sp.path_id = od.single_path_id
					WHERE up_down_stream = ''d''
						AND group_path_id <> -99
					'
		EXEC(@sql)	

		SELECT @all_demand_loc_id =  ISNULL(@all_demand_loc_id + ', ', '')  +  CAST(imbalance_location_id AS VARCHAR(10)) 
		FROM (SELECT DISTINCT imbalance_location_id FROM #temp_imbalance_path WHERE from_to = 'all') a
		
		DELETE FROM #temp_imbalance_path WHERE from_to = 'all'

		SET @sql = '
					INSERT INTO #temp_imbalance_path
					SELECT DISTINCT tlpi.from_to,tlpi.location_id, IIF(od.source_deal_header_id IS NULL, -1,  ISNULL(dp.to_location, dp_sp.to_location)) 	
					FROM #tmp_location_pos_info tlpi
					LEFT JOIN  ' + @deal_detail_info + ' ddi
						ON tlpi.location_id = ddi.location_id
					LEFT JOIN source_deal_detail sdd
						ON sdd.source_deal_detail_id = ddi.source_deal_detail_id
					LEFT JOIN optimizer_detail od
						ON od.transport_deal_id = sdd.source_deal_header_id 
					OUTER APPLY (SELECT max(path_name) path_id from delivery_path_detail where path_id = od.group_path_id) last_path
					LEFT JOIN delivery_path dp
						ON last_path.path_id = dp.path_id
					LEFT JOIN delivery_path dp_sp
						ON dp_sp.path_id = od.single_path_id
					WHERE (od.source_deal_header_id is null and od.up_down_stream = ''u'') OR   
							(tlpi.position < 0  AND 
							 up_down_stream = ''d''
							AND group_path_id <> -99
							AND tlpi.from_to =''FROM''
							)
				'
		EXEC(@sql)

	
		SET @sql = '
				INSERT INTO #temp_imbalance_path
				SELECT DISTINCT  tlpi.from_to,tlpi.location_id, sdd_t.location_id
				FROM #tmp_location_pos_info tlpi
				LEFT JOIN ' + @deal_detail_info + ' ddi
					ON tlpi.location_id = ddi.location_id
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_detail_id = ddi.source_deal_detail_id
				LEFT JOIN  optimizer_header oh
					ON tlpi.location_id = oh.delivery_location_id
					AND oh.flow_date = sdd.term_start
				LEFT JOIN optimizer_detail od
					ON od.transport_deal_id = oh.transport_deal_id
				LEFT JOIN source_deal_detail sdd_t
					ON sdd_t.source_deal_header_id = od.source_deal_header_id
					AND sdd_t.term_start = od.flow_date	
				WHERE tlpi.position> 0 
					AND od.group_path_id <> -99
					AND sdd_t.leg = 1
					AND tlpi.from_to = ''TO''
					AND od.up_down_stream = ''u''	
			'
		--print @sql
		EXEC(@sql)

		DECLARE @imbalance_paths VARCHAR(1000)

		UPDATE tlpi 
			SET is_unschedule = 'y' 
		FROM #temp_imbalance_path tip 
		INNER JOIN #tmp_location_pos_info tlpi
			ON tip.location_id = tlpi.location_id
			AND tip.from_to = tlpi.from_to

		IF EXISTS(SELECT 1 FROM #temp_imbalance_path WHERE imbalance_location_id = -1)	
		BEGIN
			SET @imbalance_paths = @all_demand_loc_id
		END
		ELSE 
		BEGIN
			SELECT @imbalance_paths =  ISNULL(@imbalance_paths + ', ', '')  +  CAST(imbalance_location_id AS VARCHAR(10))  
			FROM (SELECT DISTINCT imbalance_location_id FROM #temp_imbalance_path) tip
		END 
	END

	IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL
		DROP TABLE #temp_final

	SELECT 
		CASE WHEN sml.location_id <> sml.location_name 
			THEN sml.location_id + '-' 
			ELSE '' 
		END  + sml.location_name + ISNULL(' [' + tlpi.location_type + ']', '') [location_name]
		, tlpi.location_id
		, tlpi.location_type
		, dbo.FNARemoveTrailingZero(ROUND(COALESCE(tlpi.proxy_pos,IIF(pmj.location_name = 'storage',tlpi.position,lrt.[beg_pos]),0), 0)) [position]
		, dbo.FNARemoveTrailingZero(ROUND(ISNULL( CASE pmj.location_name WHEN 'storage' THEN tlpi.position ELSE COALESCE(tlpi.proxy_pos_total,lrt.total_position,0) END,0), 0)) [total_pos]
		, tlpi.[rank]
		, CASE WHEN tlpi.proxy_loc_id = tlpi.location_id THEN -1 ELSE tlpi.proxy_loc_id END [proxy_loc_id]
		, ISNULL(pmj.location_name, -1) [proxy_loc_type]
		, CASE tlpi.proxy_position_type WHEN 110200 THEN 'cv' WHEN 110201 THEN 'cv' ELSE 'np' END [proxy_type]
		, tlpi.proxy_pos 
		, CASE WHEN tlpi.location_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@proxy_locs) EXCEPT SELECT item FROM dbo.SplitCommaSeperatedValues(@minor_location)) THEN 
			CASE WHEN @receipt_delivery = 'FROM' THEN 1 ELSE 2 END
			ELSE 0 
			END [is_proxy]
		, @process_id [process_id]
		--, tpa2.*
		,tlpi.is_unschedule
		,@imbalance_paths imbalance_paths
	INTO #temp_final
	from #tmp_location_pos_info tlpi --select * from #tmp_location_pos_info
	INNER JOIN source_minor_location sml 
		ON sml.source_minor_location_id = tlpi.location_id
	LEFT JOIN source_minor_location pmi 
		ON pmi.source_minor_location_id = tlpi.proxy_loc_id
	LEFT JOIN source_major_location pmj 
		ON pmj.source_major_location_ID = pmi.source_major_location_ID
	--left join #tmp_proxy_agg2 tpa2 on tpa2.source_minor_location_id = tlpi.location_id
	LEFT JOIN #locwise_range_total lrt 
		ON lrt.location_id = tlpi.location_id
	WHERE 1 = (
					CASE WHEN ISNULL(NULLIF(@hide_pos_zero, ''), 'n') = 'y' 
					THEN 
						CASE WHEN ISNULL(CASE pmj.location_name WHEN 'storage' THEN tlpi.position ELSE COALESCE(tlpi.proxy_pos_total,lrt.total_position,0) END,0) <> 0 
						THEN 1 
						ELSE 0 
						END
					ELSE 1
					END
				)
	
	IF ISNULL(@call_from, '-1') <> 'HIDE_OUTPUT'
	BEGIN
		SELECT * 
		FROM #temp_final 
		ORDER BY [rank], [location_id]
	END

	if @receipt_delivery = 'FROM'
	begin
		SET @sql = 'INSERT INTO ' + @storage_position + '
					SELECT ''w'', location_id, total_pos 
					FROM   #temp_final 
					where location_type = ''Storage'''
		exec(@sql)

		exec('
		IF OBJECT_ID(''' + @location_pos_info + ''') IS NOT NULL DROP TABLE ' + @location_pos_info + '
		SELECT ''supply'' [market_side], * INTO ' + @location_pos_info + ' FROM #temp_final
		')

		SET @output_process_id = @process_id
	end
	else if @receipt_delivery = 'TO'
	begin
		SET @sql = 'INSERT INTO ' + @storage_position + '
					SELECT ''i'', location_id, total_pos 
					FROM   #temp_final 
					where location_type = ''Storage'''
		exec(@sql)

		exec('
		INSERT INTO ' + @location_pos_info + ' 
		SELECT ''demand'', * FROM  #temp_final
		')
		
	end

END

ELSE IF @flag = 'c' --Extract optimizer grid cell information(path mdq, path rmdq, etc) for flow optimization grid
BEGIN

	--EXEC spa_flow_optimization  @flag='c',@sub=NULL,@str=NULL,@book=NULL,@sub_book_id=NULL,@flow_date_from='2017-06-01',@flow_date_to='2017-06-06',@from_location='1602,1542,1543,1295,1608,1267',@to_location='1598,1599,1611,1312,1603,1600,1606,1352,1604,1536,1541',@path_priority='303954',@opt_objective='38301',@priority_from=NULL,
	--@priority_to=NULL,@contract_id=NULL,@pipeline_ids=NULL,@uom='6',@process_id='3433C450_094D_446E_889B_3CE1E6CF0FD8',@delivery_path='1450'
	
	--DEAL DETAIL LEVEL POSITION INFO
	----print '@flag = ''c'', DEAL DETAIL LEVEL POSITION INFO START: ' + convert(varchar(50),getdate() ,21)
	set @sql = '
	IF OBJECT_ID(''' + @opt_deal_detail_pos + ''') IS NOT NULL
		DROP TABLE ' + @opt_deal_detail_pos + '
	SELECT DISTINCT sdd.source_deal_detail_id 
		, sdd.source_deal_header_id
		, sdh.deal_id [reference_id]
		, bk.book [book]
		--, udf_from_deal.udf_value [from_deal]
		, NULL [from_deal]
		--, udf_to_deal.udf_value [to_deal]
		, NULL [to_deal]
		, sdh.description1 [nom_group]
		, COALESCE(TRY_CONVERT(INT, sdv_pr.code), TRY_CONVERT(INT, sdh.description2), 168) [priority]
		, sdh.counterparty_id
		, sdh.contract_id
		, major.source_major_location_ID [location_type_id]
		, minor.source_minor_location_id [location_id]
		, minor.location_name
		, major.location_name [location_type]
		, ISNULL(lr.rank, 9999) [location_rank]
		, lr.effective_date [lr_eff_date]
		, sdd.term_start
		, sdd.term_end
		, ROUND(ISNULL(rvuc.conversion_factor, 1) * ISNULL(pos.position, 0), 0) [position]
		, sdd.deal_volume_uom_id [uom_id]
		, sdd.leg
		, sdd.buy_sell_flag
		, CASE 
			WHEN sdht.template_name = ''' + @transportation_template_name + ''' THEN 
				CASE
					WHEN major.location_name = ''M2'' THEN
						CASE sdd.leg WHEN 2 THEN ''Gath Nom'' 
							ELSE ''Interstate Nom''
						END
					WHEN major.location_name = ''Storage'' THEN ''Storage''
					ELSE ''Interstate Nom''
				END
			ELSE CASE WHEN sdd.buy_sell_flag = ''b'' THEN ''Purchase'' WHEN sdd.buy_sell_flag = ''s'' THEN ''Sales'' END
		 END [Group]
		 , ISNULL(rvuc.conversion_factor, 1) [uom_conversion_factor]
		 , loc_list.is_proxy
	INTO ' + @opt_deal_detail_pos + '
	FROM source_deal_detail sdd (NOLOCK)
	INNER JOIN #deal_term_breakdown dtb (NOLOCK) ON dtb.source_deal_detail_id = sdd.source_deal_detail_id 
		AND sdd.physical_financial_flag = ''p''
	CROSS APPLY (
		SELECT DISTINCT s.item, NULL is_proxy
		FROM dbo.SplitCommaSeperatedValues(''' + ISNULL(@from_location, '-1') + ISNULL(',' + @to_location, '') + ISNULL(',' + @pool_id, '') + ISNULL(',' + @pool_location_id,'') +''') s 
		WHERE s.item = sdd.location_id
		UNION ALL
		SELECT DISTINCT s.item, 1 is_proxy 
		FROM dbo.SplitCommaSeperatedValues(''' + ISNULL(@proxy_locs, '-1') + ISNULL(',' +  NULLIF(@child_proxy_locs, ''), '') +''') s 
		WHERE s.item = sdd.location_id
			AND s.item NOT IN (' + ISNULL(@minor_location, '') + ')
	) loc_list 
	INNER JOIN source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
		AND bk.source_system_book_id2 = sdh.source_system_book_id2
		AND bk.source_system_book_id3 = sdh.source_system_book_id3
		AND bk.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_minor_location minor (NOLOCK) ON minor.source_minor_location_id = sdd.location_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	INNER JOIN source_counterparty (NOLOCK) sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN source_major_location major (NOLOCK) ON major.source_major_location_ID = minor.source_major_location_ID
	LEFT JOIN #tmp_location_ranking_values2 lr ON lr.cnt = 1 
		AND lr.location_id = sdd.location_id 
		AND lr.effective_date <= sdd.term_start
	LEFT JOIN #deal_detail_udf dudf_priority (NOLOCK) ON dudf_priority.source_deal_detail_id = sdd.source_deal_detail_id 
		AND dudf_priority.field_label = ''Priority''
	LEFT JOIN static_data_value sdv_pr ON CAST(sdv_pr.value_id AS VARCHAR) = dudf_priority.udf_value
	LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.to_source_uom_id = ' + CAST(ISNULL(@uom, -1) AS VARCHAR(10)) + ' 
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	OUTER APPLY ( 
		SELECT SUM(volume) vol 
		FROM source_deal_detail_hour 
		WHERE source_deal_detail_id = sdd.source_deal_detail_id 
			AND term_date = dtb.term_start 
			AND sdd.deal_volume_frequency = ''t''
	) sddh
	OUTER APPLY (
		SELECT SUM(hp.position) [position]
		FROM ' + @hourly_pos_info + ' hp 
		WHERE hp.source_deal_header_id = sdd.source_deal_header_id
			AND hp.term_start = dtb.term_start
			AND hp.location_id = sdd.location_id
			AND hp.curve_id = sdd.curve_id
		GROUP BY hp.source_deal_header_id, hp.term_start, hp.location_id, hp.curve_id
	) pos --get daily position of deal to use instead of deal volume
	WHERE 1=1 
		AND sdh.commodity_id IN (' + @commodity + ')
		AND COALESCE(TRY_CONVERT(INT, sdv_pr.code), TRY_CONVERT(INT, sdh.description2), 168)
		BETWEEN ' + ISNULL(CAST(@priority_from AS VARCHAR), '0') + ' AND ' + ISNULL(CAST(@priority_to AS VARCHAR), '9999')
	
	IF @call_from IN ('flow_match', 'flow_auto')
	BEGIN
		SET @sql += ' AND (sdh.source_deal_header_id IN ('+ISNULL(NULLIF(@receipt_deals_id,''),'0')+') OR sdh.source_deal_header_id IN ('+ISNULL(NULLIF(@delivery_deals_id,''),'0')+')) '
	END
	--print(@sql)
	EXEC(@sql)
	--exec('select * from ' + @opt_deal_detail_pos)
	
	----print '@flag = ''c'', #tmp_solver_decisions S: ' + convert(varchar(50),getdate() ,21)
	
	DECLARE @counterparty_contract_id VARCHAR(1000)= NULL
	IF EXISTS(SELECT 1 FROM counterparty_contract_rate_schedule WHERE path_id = @delivery_path)
	BEGIN
		SELECT @counterparty_contract_id = ISNULL(@counterparty_contract_id + ',', '') + CAST(contract_id AS VARCHAR(10)) 
		FROM counterparty_contract_rate_schedule 
		WHERE path_id = @delivery_path
	END 

	
	IF OBJECT_ID('tempdb..#tmp_solver_decisions') IS NOT NULL 
		DROP TABLE #tmp_solver_decisions
		
	SELECT distinct --added distinct clause so that duplicate path contract info when child proxy also has path to that locations exists, is reduced.
		CAST(f1.item AS VARCHAR) [from_loc_id],
		major_from.source_major_location_ID [from_loc_grp_id],
		major_from.location_name [from_loc_grp_name],
		major_to.source_major_location_ID [to_loc_grp_id],
		major_to.location_name [to_loc_grp_name],
		sml.Location_Name [from_loc],
		CAST(f2.item AS VARCHAR) [to_loc_id],
		sml2.Location_Name [to_loc],
		CAST(0 AS NUMERIC(38, 18)) [received],
		CAST(0 AS NUMERIC(38, 18)) [delivered],
		coalesce(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id, 0) [path_id],
		spath.path_id [single_path_id],
		coalesce(dp.path_name,dp_proxy_from.path_name,dp_child_proxy_from.path_name,dp_proxy_to.path_name,dp_child_proxy_to.path_name,dp_proxy_from_to.path_name,dp_child_proxy_from_to.path_name) [path_name],
		coalesce(dp.groupPath,dp_proxy_from.groupPath,dp_child_proxy_from.groupPath,dp_proxy_to.groupPath,dp_child_proxy_to.groupPath,dp_proxy_from_to.groupPath,dp_child_proxy_from_to.groupPath) [group_path],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			(coalesce(spath.path_mdq, tm.mdq, dp.mdq, dp_proxy_from.mdq, dp_child_proxy_from.mdq, dp_proxy_to.mdq, dp_child_proxy_to.mdq, dp_proxy_from_to.mdq, dp_child_proxy_from_to.mdq) + coalesce(spath.released_mdq, trd.released_mdq, 0))
			* isnull(NULLIF(uom_cv.conversion_factor, 0), 1)
		), @round), 0) [path_mdq],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			(coalesce(spath.path_mdq, tm.mdq, dp.mdq, dp_proxy_from.mdq, dp_child_proxy_from.mdq, dp_proxy_to.mdq, dp_child_proxy_to.mdq, dp_proxy_from_to.mdq, dp_child_proxy_from_to.mdq) * isnull(NULLIF(uom_cv.conversion_factor, 0), 1)
			 + coalesce(spath.released_mdq, trd.released_mdq, 0) - coalesce(spath.sch_vol, sch_vol.deal_volume,0))
			
		), @round), 0) [path_rmdq],
		coalesce(spath.contract_id, contract_level.contract_id, dp.CONTRACT) [contract_id],
		coalesce(spath.contract_name, contract_level.contract_name, cg.contract_name) [contract_name],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			coalesce(spath.contract_mdq, contract_level.contract_mdq,dp.mdq)
			* isnull(NULLIF(uom_cv.conversion_factor, 0), 1)
		), @round), 0) [mdq],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			coalesce(spath.contract_rmdq, contract_level.[contract_rmdq],coalesce(spath.contract_mdq, contract_level.contract_mdq,dp.mdq) * isnull(NULLIF(uom_cv.conversion_factor, 0), 1))
		), @round), 0) [rmdq],
		coalesce(spath.sch_vol, sch_vol.deal_volume,0) [total_sch_volume],
		coalesce(spath.loss_factor, lf.loss_factor, 0) [loss_factor],
		sdv3.code [priority],
		sdv3.value_id [priority_id],
		cast(ISNULL(lr.[rank], 99999) as int) [from_rank],
		cast(ISNULL(lr2.[rank], 99999) as int) [to_rank],
		CASE WHEN major_from.location_name = 'Storage' THEN 
			'w'
		ELSE 
			CASE WHEN major_to.location_name = 'Storage' THEN
				'i'
			ELSE 'n'
			END
		END [storage_deal_type],
		null [storage_asset_id],
		0 [storage_volume],
		sml.proxy_location_id [from_proxy_loc_id],
		sml2.proxy_location_id [to_proxy_loc_id],
		0 [from_is_proxy],
		0 [to_is_proxy],
		null [parent_from_loc_id],
		null [parent_to_loc_id],
		isnull(cg.segmentation, 'n') [segmentation]
		--, sml.proxy_position_type [from_proxy_position_type]
		--, sml2.proxy_position_type [to_proxy_position_type]
		 , ISNULL(uom_cv.conversion_factor, 1) [uom_conversion_factor] 
	
	INTO #tmp_solver_decisions --select * from #tmp_solver_decisions order by 1

	--select dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id,*
	FROM dbo.FNASplit(@from_location, ',') f1
	CROSS JOIN dbo.FNASplit(@to_location, ',') f2 
	INNER JOIN source_minor_location sml (NOLOCK) 
		ON sml.source_minor_location_id = f1.item
	INNER JOIN source_minor_location sml2 (NOLOCK) 
		ON sml2.source_minor_location_id = f2.item
	LEFT JOIN delivery_path dp (NOLOCK) 
		ON dp.from_location = f1.item 
		AND dp.to_location = f2.item 
		AND ISNULL(dp.priority, 1) = CASE WHEN dp.groupPath = 'y' THEN ISNULL(dp.priority, 1) ELSE COALESCE(@path_priority,dp.priority,1) END  --(CASE WHEN @path_priority IS NOT NULL THEN @path_priority ELSE ISNULL(dp.priority, 1) END) 
		AND ISNULL(dp.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp.counterparty, -1) AS VARCHAR(100)))))		
	LEFT JOIN delivery_path dp_proxy_from (NOLOCK) 
		ON dp_proxy_from.from_location = sml.proxy_location_id 
		AND dp_proxy_from.to_location = f2.item 
		AND ISNULL(dp_proxy_from.priority, 1) = CASE WHEN dp_proxy_from.groupPath = 'y' THEN ISNULL(dp_proxy_from.priority, 1) ELSE COALESCE(@path_priority,dp_proxy_from.priority,1) END  --(CASE WHEN @path_priority IS NOT NULL THEN @path_priority ELSE ISNULL(dp_proxy_from.priority, 1) END) 
		AND ISNULL(dp_proxy_from.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_proxy_from.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_proxy_from.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_proxy_from.counterparty, -1) AS VARCHAR(100)))))
	left join delivery_path dp_child_proxy_from on dp_child_proxy_from.to_location = f2.item
			and dp_child_proxy_from.from_location in (
				select item 
				from dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp1 
				inner join source_minor_location sml1 on sml1.source_minor_location_id = cp1.item
				where sml1.proxy_location_id = f1.item
			)
	LEFT JOIN delivery_path dp_proxy_to (NOLOCK) 
		ON dp_proxy_to.from_location = f1.item 
		AND dp_proxy_to.to_location =  sml2.proxy_location_id
		AND ISNULL(dp_proxy_to.priority, 1) = CASE WHEN dp_proxy_to.groupPath = 'y' THEN ISNULL(dp_proxy_to.priority, 1) ELSE COALESCE(@path_priority,dp_proxy_to.priority,1) END  --(CASE WHEN @path_priority IS NOT NULL THEN @path_priority ELSE ISNULL(dp_proxy_to.priority, 1) END) 
		AND ISNULL(dp_proxy_to.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_proxy_to.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_proxy_to.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_proxy_to.counterparty, -1) AS VARCHAR(100)))))
	left join delivery_path dp_child_proxy_to on dp_child_proxy_to.from_location = f1.item
			and dp_child_proxy_to.to_location in (
				select item 
				from dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp1 
				inner join source_minor_location sml1 on sml1.source_minor_location_id = cp1.item
				where sml1.proxy_location_id = f2.item
			)
	LEFT JOIN delivery_path dp_proxy_from_to (NOLOCK) 
		ON dp_proxy_from_to.from_location = sml.proxy_location_id 
		AND dp_proxy_from_to.to_location = sml2.proxy_location_id 
		AND ISNULL(dp_proxy_from_to.priority, 1) = CASE WHEN dp_proxy_from_to.groupPath = 'y' THEN ISNULL(dp_proxy_from_to.priority, 1) ELSE COALESCE(@path_priority,dp_proxy_from_to.priority,1) END  --(CASE WHEN @path_priority IS NOT NULL THEN @path_priority ELSE ISNULL(dp_proxy_from_to.priority, 1) END) 
		AND ISNULL(dp_proxy_from_to.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_proxy_from_to.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_proxy_from_to.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_proxy_from_to.counterparty, -1) AS VARCHAR(100)))))
	LEFT JOIN delivery_path dp_child_proxy_from_to (NOLOCK) 
		ON dp_child_proxy_from_to.from_location in (
				select item 
				from dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp2 
				inner join source_minor_location sml2 on sml2.source_minor_location_id = cp2.item
				where sml2.proxy_location_id = f1.item
			) 
		AND dp_child_proxy_from_to.to_location in (
				select item 
				from dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp3 
				inner join source_minor_location sml3 on sml3.source_minor_location_id = cp3.item
				where sml3.proxy_location_id = f2.item
			) 
		AND ISNULL(dp_child_proxy_from_to.priority, 1) = CASE WHEN dp_child_proxy_from_to.groupPath = 'y' THEN ISNULL(dp_child_proxy_from_to.priority, 1) ELSE COALESCE(@path_priority,dp_child_proxy_from_to.priority,1) END  --(CASE WHEN @path_priority IS NOT NULL THEN @path_priority ELSE ISNULL(dp_child_proxy_from_to.priority, 1) END) 
		AND ISNULL(dp_child_proxy_from_to.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_child_proxy_from_to.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_child_proxy_from_to.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_child_proxy_from_to.counterparty, -1) AS VARCHAR(100)))))			
	LEFT JOIN #tmp_location_ranking_values2 lr 
		ON lr.cnt = 1 
		AND lr.location_id = sml.source_minor_location_id 
		--AND lr.effective_date <= @flow_date_from
	LEFT JOIN #tmp_location_ranking_values2 lr2 
		ON lr2.cnt = 1 
		AND lr2.location_id = sml2.source_minor_location_id --AND lr2.effective_date <= @flow_date_from
	LEFT JOIN static_data_value sdv3 (NOLOCK) 
		ON dp.priority = sdv3.value_id
	LEFT JOIN contract_group cg (NOLOCK) 
		ON cg.contract_id = dp.[contract]
	LEFT JOIN source_major_location major_from (NOLOCK) 
		ON major_from.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN source_major_location major_to (NOLOCK) 
		ON major_to.source_major_location_ID = sml2.source_major_location_ID
	LEFT JOIN #tmp_pmdq tm 
		ON tm.path_id = coalesce(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id, dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
	OUTER APPLY (
		SELECT  ccrs.path_id, dp2.path_name, cg1.contract_id, cg1.contract_name, isnull(tc.mdq, cg1.mdq) [contract_mdq]
			, (isnull(tc.mdq, cg1.mdq) * isnull(NULLIF(uom_cv.conversion_factor, 0), 1)) - oa_crmdq.sch_vol [contract_rmdq], cg1.volume_uom [contract_uom]
		FROM counterparty_contract_rate_schedule ccrs (nolock)
		INNER JOIN contract_group cg1 (NOLOCK) 
			ON cg1.contract_id = ccrs.contract_id
		INNER JOIN delivery_path dp2 (NOLOCK) 
			ON dp2.path_id = ccrs.path_id
		LEFT JOIN #tmp_cmdq tc 
			ON tc.contract_id = cg1.contract_id
		outer apply (
			select sdi.contract_id, sum(sdi.deal_volume) sch_vol
			from #sch_deal_info sdi --select * from #sch_deal_info
			where sdi.contract_id = cg1.contract_id
				and ((sdi.from_loc = f1.item and sdi.to_loc = f2.item and isnull(cg1.segmentation, 'n') = 'y') or isnull(cg1.segmentation, 'n') = 'n')
			group by sdi.contract_id
		) oa_crmdq
		outer apply (
			select rvuc.conversion_factor
			from rec_volume_unit_conversion rvuc
			WHERE rvuc.from_source_uom_id = cg1.volume_uom 
				AND rvuc.to_source_uom_id = @uom
		) uom_cv
		WHERE 1=1
		--dp2.from_location = f1.item 
		--	AND dp2.to_location = f2.item 
			AND dp2.path_id = coalesce(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id, dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
		--WHERE dp2.from_location = 27263 and dp2.to_location = 27386 and dp2.path_id = 8406
		--group by ccrs.path_id
	) contract_level
	OUTER APPLY (
		SELECT min(sdi.deal_volume) deal_volume
		FROM #sch_deal_info sdi
		WHERE sdi.from_loc = f1.item 
			and sdi.to_loc = f2.item 
			AND sdi.contract_id = contract_level.contract_id			
		GROUP BY sdi.from_loc, sdi.to_loc, sdi.contract_id
    ) sch_vol
	LEFT JOIN #tmp_release_deals trd 
		ON dp.path_id = trd.delivery_path
	LEFT JOIN #single_path_detail spath 
		ON spath.parent_path_id = coalesce(dp.path_id,dp_proxy_from.path_id,dp_proxy_to.path_id, dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
	outer apply (
		select rvuc.conversion_factor
		from rec_volume_unit_conversion rvuc
		where rvuc.from_source_uom_id = coalesce(spath.contract_uom,contract_level.contract_uom) and rvuc.to_source_uom_id = @uom
	) uom_cv
	LEFT JOIN #tmp_loss_factor lf 
		ON lf.path_id = coalesce(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id, dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
		and lf.contract_id = coalesce(spath.contract_id, contract_level.contract_id, dp.CONTRACT)
	
	UPDATE t 
	SET storage_asset_id = a.general_assest_id
	from #tmp_solver_decisions t
	CROSS APPLY (	SELECT MAX(general_assest_id) general_assest_id 
					FROM general_assest_info_virtual_storage
					WHERE storage_location = t.from_loc_id
				) a
	WHERE from_loc_grp_name = 'Storage'

	UPDATE t 
	SET storage_asset_id = a.general_assest_id
	from #tmp_solver_decisions t
	CROSS APPLY (	SELECT MAX(general_assest_id) general_assest_id 
					FROM general_assest_info_virtual_storage
					WHERE storage_location = t.to_loc_id
				) a
	WHERE to_loc_grp_name = 'Storage'

	UPDATE   tsd
		SET priority = sdv.code,
			priority_id = sdv.value_id
	FROM  #tmp_solver_decisions tsd
	INNER JOIN delivery_path dp
		ON tsd.single_path_id = dp.path_id
	INNER JOIN static_data_value sdv
		ON dp.priority = sdv.value_id
	WHERE tsd.group_path = 'y'

	--select * from #single_path_detail
	----print '@flag = ''c'', #tmp_solver_decisions E: ' + convert(varchar(50),getdate() ,21)

	IF OBJECT_ID('tempdb..#tmp_from_proxy_info') IS NOT NULL 
		DROP TABLE #tmp_from_proxy_info

	select distinct tsd.from_loc_id, tsd.to_loc_id, from_proxy_loc_id, null [has_proxy_data]
	into #tmp_from_proxy_info --select * from #tmp_from_proxy_info
	from #tmp_solver_decisions tsd 
	where tsd.from_proxy_loc_id is not null --and isnull(tsd.path_id, -1) < 1

	update tsd
	set tsd.from_is_proxy = 1, tsd.parent_from_loc_id = tfp.from_loc_id
	from #tmp_solver_decisions tsd
	inner join #tmp_from_proxy_info tfp on tfp.from_proxy_loc_id = tsd.from_loc_id
	
	IF OBJECT_ID('tempdb..#tmp_to_proxy_info') IS NOT NULL 
		DROP TABLE #tmp_to_proxy_info
	select distinct tsd.from_loc_id, tsd.to_loc_id, to_proxy_loc_id, null [has_proxy_data]
	into #tmp_to_proxy_info --select * from #tmp_to_proxy_info
	from #tmp_solver_decisions tsd 
	where tsd.to_proxy_loc_id is not null --and isnull(tsd.path_id, -1) < 1

	update tsd
	set tsd.to_is_proxy = 1, tsd.parent_to_loc_id = tfp.to_loc_id
	from #tmp_solver_decisions tsd
	inner join #tmp_to_proxy_info tfp on tfp.to_proxy_loc_id = tsd.to_loc_id
	
	--select * from #tmp_solver_decisions
	--select * from #tmp_from_proxy_info
	--select * from #tmp_to_proxy_info

	IF OBJECT_ID('tempdb..#from_proxy_path_copy') IS NOT NULL DROP TABLE #from_proxy_path_copy
	select 
		tfpi.from_loc_id,loc_info.from_loc_grp_id,loc_info.from_loc_grp_name, loc_info.to_loc_grp_id, loc_info.to_loc_grp_name, loc_info.from_loc, tfpi.to_loc_id, loc_info.to_loc, loc_info.received, loc_info.delivered
		
		, tsd.path_id,tsd.single_path_id,tsd.path_name,tsd.group_path,tsd.path_mdq,tsd.path_rmdq,tsd.contract_id
		,tsd.contract_name,tsd.mdq,tsd.rmdq,tsd.total_sch_volume,tsd.loss_factor,tsd.priority,tsd.priority_id

		,loc_info.from_rank, loc_info.to_rank, loc_info.storage_deal_type, loc_info.storage_asset_id, loc_info.storage_volume, loc_info.from_proxy_loc_id, loc_info.to_proxy_loc_id, loc_info.from_is_proxy, loc_info.to_is_proxy, loc_info.parent_from_loc_id, loc_info.parent_to_loc_id, loc_info.segmentation, loc_info.uom_conversion_factor
	into #from_proxy_path_copy
	from #tmp_solver_decisions tsd
	inner join #tmp_from_proxy_info tfpi on tfpi.from_proxy_loc_id = tsd.from_loc_id and tfpi.to_loc_id = tsd.to_loc_id
	cross apply (
		select top 1 tsd1.from_loc, tsd1.from_loc_grp_id, tsd1.from_loc_grp_name, tsd1.to_loc, tsd1.to_loc_grp_id, tsd1.to_loc_grp_name, tsd1.received, tsd1.delivered, tsd1.from_rank, tsd1.to_rank, tsd1.storage_deal_type, tsd1.storage_asset_id, tsd1.storage_volume, tsd1.from_proxy_loc_id, tsd1.to_proxy_loc_id, tsd1.from_is_proxy, tsd1.to_is_proxy, tsd1.parent_from_loc_id, tsd1.parent_to_loc_id, tsd1.segmentation, tsd1.uom_conversion_factor
		from #tmp_solver_decisions tsd1
		where tsd1.from_loc_id = tfpi.from_loc_id and tsd1.to_loc_id = tfpi.to_loc_id
	) loc_info

	IF OBJECT_ID('tempdb..#to_proxy_path_copy') IS NOT NULL DROP TABLE #to_proxy_path_copy
	select 
		tfpi.from_loc_id,loc_info.from_loc_grp_id,loc_info.from_loc_grp_name, loc_info.to_loc_grp_id, loc_info.to_loc_grp_name, loc_info.from_loc, tfpi.to_loc_id, loc_info.to_loc, loc_info.received, loc_info.delivered
		
		, tsd.path_id,tsd.single_path_id,tsd.path_name,tsd.group_path,tsd.path_mdq,tsd.path_rmdq,tsd.contract_id
		,tsd.contract_name,tsd.mdq,tsd.rmdq,tsd.total_sch_volume,tsd.loss_factor,tsd.priority,tsd.priority_id

		,loc_info.from_rank, loc_info.to_rank, loc_info.storage_deal_type, loc_info.storage_asset_id, loc_info.storage_volume, loc_info.from_proxy_loc_id, loc_info.to_proxy_loc_id, loc_info.from_is_proxy, loc_info.to_is_proxy, loc_info.parent_from_loc_id, loc_info.parent_to_loc_id, loc_info.segmentation, loc_info.uom_conversion_factor
	into #to_proxy_path_copy
	from #tmp_solver_decisions tsd
	inner join #tmp_to_proxy_info tfpi on tfpi.to_proxy_loc_id = tsd.to_loc_id and tfpi.from_loc_id = tsd.from_loc_id
	cross apply (
		select top 1 tsd1.from_loc, tsd1.from_loc_grp_id, tsd1.from_loc_grp_name, tsd1.to_loc, tsd1.to_loc_grp_id, tsd1.to_loc_grp_name, tsd1.received, tsd1.delivered, tsd1.from_rank, tsd1.to_rank, tsd1.storage_deal_type, tsd1.storage_asset_id, tsd1.storage_volume, tsd1.from_proxy_loc_id, tsd1.to_proxy_loc_id, tsd1.from_is_proxy, tsd1.to_is_proxy, tsd1.parent_from_loc_id, tsd1.parent_to_loc_id, tsd1.segmentation, tsd1.uom_conversion_factor
		from #tmp_solver_decisions tsd1
		where tsd1.from_loc_id = tfpi.from_loc_id and tsd1.to_loc_id = tfpi.to_loc_id
	) loc_info
	

	update fp set fp.has_proxy_data = 1
	from #tmp_from_proxy_info fp
	inner join #from_proxy_path_copy fpc on fpc.from_proxy_loc_id = fp.from_proxy_loc_id and fpc.to_loc_id = fp.to_loc_id

	update tp set tp.has_proxy_data = 1
	from #tmp_to_proxy_info tp
	inner join #to_proxy_path_copy tpc on tpc.to_proxy_loc_id = tp.to_proxy_loc_id and tpc.from_loc_id = tp.from_loc_id

	--select tsd.*
	delete from tsd
	from #tmp_solver_decisions tsd
	inner join #tmp_from_proxy_info tfpi on tfpi.from_loc_id = tsd.from_loc_id and tfpi.to_loc_id = tsd.to_loc_id and tfpi.has_proxy_data = 1

	--select tsd.*
	delete from tsd
	from #tmp_solver_decisions tsd
	inner join #tmp_to_proxy_info tfpi on tfpi.from_loc_id = tsd.from_loc_id and tfpi.to_loc_id = tsd.to_loc_id and tfpi.has_proxy_data = 1

	insert into #tmp_solver_decisions
	select * from #from_proxy_path_copy

	insert into #tmp_solver_decisions
	select * from #to_proxy_path_copy

	declare @proxy_locs_c varchar(2000)
	SELECT @proxy_locs_c = STUFF(
		(SELECT DISTINCT ','  + cast(sml.proxy_location_id AS VARCHAR)
		from source_minor_location sml 
		INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(@from_location,'-1') + ISNULL(',' + @to_location, '')) scsv 
			ON scsv.item = sml.source_minor_location_id
		WHERE sml.proxy_location_id IS NOT NULL 
			AND sml.source_minor_location_id NOT IN (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@from_location,'-1') + ISNULL(',' + @to_location, ''))
			)	
		FOR XML PATH(''))
	, 1, 1, '')

	--select @proxy_locs_c
	----print '@flag = ''c'', #tmp_filtered_data S: ' + convert(varchar(50),getdate() ,21)
	IF OBJECT_ID('tempdb..#tmp_filtered_data') is not null
		DROP TABLE #tmp_filtered_data

	SELECT DENSE_RANK() OVER (ORDER BY a.from_rank, CAST(a.from_loc_id AS INT), a.to_rank, CAST(a.to_loc_id AS INT)) [box_id], a.* 
		, case  
			when a.from_loc_id in (select item from dbo.SplitCommaSeperatedValues(isnull(@proxy_locs_c, '')))
				and a.to_loc_id in (select item from dbo.SplitCommaSeperatedValues(isnull(@proxy_locs_c, ''))) 
				and a.from_is_proxy = 1 and a.to_is_proxy = 1 then 'from_to_proxy'
			when a.from_loc_id in (select item from dbo.SplitCommaSeperatedValues(isnull(@proxy_locs_c, ''))) 
				and a.from_is_proxy = 1 then 'from_proxy' 
			when a.to_loc_id in (select item from dbo.SplitCommaSeperatedValues(isnull(@proxy_locs_c, '')))
				and a.to_is_proxy = 1 then 'to_proxy'
			else 'no_proxy'
		  end [box_type], CAST('0' AS VARCHAR(1000)) receipt_deals, CAST('0' AS VARCHAR(1000)) delivery_deals
		  , CAST(NULL AS DATETIME) match_term_start,  CAST(NULL AS DATETIME) match_term_end
		  , @uom [uom]
	INTO #tmp_filtered_data --select * from #tmp_filtered_data
	from #tmp_solver_decisions a
	
	SET @sql = '
	IF OBJECT_ID(''' + @contractwise_detail_mdq + ''') IS NOT NULL
	DROP TABLE ' + @contractwise_detail_mdq + '

	SELECT t.*, t.path_rmdq [path_ormdq], t.rmdq [ormdq] 
		, COALESCE(pos_s.position, pos_s_childs.position) [supply_position]
		, COALESCE(pos_d.position, pos_d_childs.position) [demand_position]
		, ''' + CONVERT(VARCHAR(10), @flow_date_from, 21) + ''' [term_start]
	INTO ' + @contractwise_detail_mdq + ' 
	FROM #tmp_filtered_data t
	OUTER APPLY (
		SELECT SUM(hp.position) [position]
		FROM ' + @hourly_pos_info + ' hp
		WHERE hp.location_id = t.from_loc_id
			AND hp.term_start = ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + '''
	) pos_s
	OUTER APPLY (
		SELECT SUM(hp.position) [position]
		FROM ' + @hourly_pos_info + ' hp
		WHERE hp.location_id IN (SELECT source_minor_location_id FROM source_minor_location sml WHERE sml.proxy_location_id = t.from_loc_id)
			AND hp.term_start = ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + '''
	) pos_s_childs
	OUTER APPLY (
		SELECT SUM(hp.position) [position]
		FROM ' + @hourly_pos_info + ' hp
		WHERE hp.location_id = t.to_loc_id
			AND hp.term_start = ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + '''
	) pos_d
	OUTER APPLY (
		SELECT SUM(hp.position) [position]
		FROM ' + @hourly_pos_info + ' hp
		WHERE hp.location_id IN (SELECT source_minor_location_id FROM source_minor_location sml WHERE sml.proxy_location_id = t.to_loc_id)
			AND hp.term_start = ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + '''
	) pos_d_childs
	--select * from ' + @contractwise_detail_mdq + '
	'
	EXEC(@sql)

	--keep fresh table values for data just after refresh, to dump this value on contractwise_detail_mdq before solver run. (added due to issue: continoulsy decrement of prmdq value on multiple times solver run)
	EXEC('
	IF OBJECT_ID(''' + @contractwise_detail_mdq_fresh + ''') IS NOT NULL
	DROP TABLE ' + @contractwise_detail_mdq_fresh + '
	SELECT * INTO ' + @contractwise_detail_mdq_fresh + ' FROM ' + @contractwise_detail_mdq + '
	--select * from ' + @contractwise_detail_mdq_fresh + '
	')

	
	--For storage constraint
	SET @sql = '
			IF OBJECT_ID(''' + @storage_constraint + ''') IS NOT NULL
				DROP TABLE ' + @storage_constraint + '

			CREATE TABLE  ' + @storage_constraint + ' (
				box_id			INT,
				from_max_withdrawal	BIGINT,
				from_min_withdrawal	BIGINT,
				to_max_injection	BIGINT,
				to_min_injection	BIGINT,
				from_ratchet_limit	BIGINT,
				to_ratchet_limit	BIGINT				
			)

			INSERT INTO ' + @storage_constraint + ' (box_id) 
			SELECT box_id FROM  ' + @contractwise_detail_mdq_fresh + '

			UPDATE a
			SET to_max_injection = sub.to_max_injection,
				to_min_injection = sub.to_min_injection,
				to_ratchet_limit = r.ratchet_limit
			FROM ' + @storage_constraint + ' a
			INNER JOIN 
				(
					SELECT box_id, 
							[18601] AS to_max_injection, 
							[18605] AS to_min_injection		
					FROM 
					(
						SELECT cdm.box_id, to_vsc.constraint_type, to_vsc.value
						FROM ' + @storage_constraint + ' sc
						INNER JOIN ' + @contractwise_detail_mdq_fresh + ' cdm
							ON sc.box_id = cdm.box_id
						LEFT JOIN [dbo].[general_assest_info_virtual_storage] to_ga
							ON cdm.to_loc_id = to_ga.storage_location
						LEFT JOIN [dbo].[virtual_storage_constraint] to_vsc
							ON to_vsc.general_assest_id = to_ga.general_assest_id
							and to_vsc.effective_date <= ''' + cast(@flow_date_from as varchar(50)) + '''
						LEFT JOIN static_data_value sdv
							ON sdv.value_id = to_vsc.constraint_type
					)p
					PIVOT
					( MAX(value)
						FOR constraint_type IN ([18601], [18605])
					) AS pvt
				) sub
				ON a.box_id = sub.box_id
			LEFT JOIN ' + @contractwise_detail_mdq_fresh + ' cdmf
				ON cdmf.box_id = a.box_id
			OUTER APPLY (
				SELECT ISNULL(NULLIF(sr.fixed_value, 0), (g.storage_capacity * case when g.volumn_uom = 1209 then 1000000 else 1 end) * (sr.perc_of_contracted_storage_space/100)) ratchet_limit
				FROM general_assest_info_virtual_storage g
				INNER JOIN  storage_ratchet sr
					ON g.general_assest_id = sr.general_assest_id
				INNER JOIN ' + @storage_position + ' sp
					ON sp.location_id = g.storage_location
					and sp.type = sr.type
				--WHERE   (sp.position/ (g.storage_capacity * case when g.volumn_uom = 1209 then 1000000 else 1 end) * 100) >= ISNULL(gas_in_storage_perc_from, 0)
				--		AND (sp.position/ (g.storage_capacity * case when g.volumn_uom = 1209 then 1000000 else 1 end) * 100) <= gas_in_storage_perc_to
				--		AND sp.location_id = cdmf.to_loc_id
				where sp.position between
					CASE WHEN coalesce(sr.inventory_level_from, sr.inventory_level_to) IS NOT NULL THEN coalesce(sr.inventory_level_from,sr.inventory_level_to-1, 0) ELSE (isnull(sr.gas_in_storage_perc_from, -100) / 100.0 * g.storage_capacity * CASE WHEN g.volumn_uom = 1209 THEN 1000000 ELSE 1 END) END
					AND CASE WHEN coalesce(sr.inventory_level_from, sr.inventory_level_to) IS NOT NULL THEN isnull(sr.inventory_level_to, sp.position + 1) ELSE (sr.gas_in_storage_perc_to / 100.0 * g.storage_capacity * CASE WHEN g.volumn_uom = 1209 THEN 1000000 ELSE 1 END) END
					AND sp.location_id = cdmf.to_loc_id
					and ''' + cast(@flow_date_from as varchar(50)) + ''' between sr.term_from and sr.term_to
			
			) r

			UPDATE a
			SET from_max_withdrawal = sub.from_max_withdrawal,
				from_min_withdrawal = sub.from_min_withdrawal,
				from_ratchet_limit = r.ratchet_limit
			FROM ' + @storage_constraint + ' a
			INNER JOIN 
				(
					SELECT box_id, 
							[18602] AS from_max_withdrawal, 
							[18606] AS from_min_withdrawal		
					FROM 
					(
						SELECT cdm.box_id, from_vsc.constraint_type, from_vsc.value
						FROM ' + @storage_constraint + ' sc
						INNER JOIN ' + @contractwise_detail_mdq_fresh + ' cdm
							ON sc.box_id = cdm.box_id
						LEFT JOIN [dbo].[general_assest_info_virtual_storage] from_ga
							ON cdm.from_loc_id = from_ga.storage_location
						LEFT JOIN [dbo].[virtual_storage_constraint] from_vsc
							ON from_vsc.general_assest_id = from_ga.general_assest_id
							and from_vsc.effective_date <= ''' + cast(@flow_date_from as varchar(50)) + '''
						LEFT JOIN static_data_value sdv
							ON sdv.value_id = from_vsc.constraint_type
					)p
					PIVOT
					( MAX(value)
						FOR constraint_type IN ([18602], [18606])
					) AS pvt
				)sub
				ON a.box_id = sub.box_id
			LEFT JOIN ' + @contractwise_detail_mdq_fresh + ' cdmf
				ON cdmf.box_id = a.box_id
			OUTER APPLY (
				SELECT ISNULL(NULLIF(sr.fixed_value, 0), (g.storage_capacity * case when g.volumn_uom = 1209 then 1000000 else 1 end) * (sr.perc_of_contracted_storage_space/100)) ratchet_limit
				FROM general_assest_info_virtual_storage g
				INNER JOIN  storage_ratchet sr
					ON g.general_assest_id = sr.general_assest_id
				INNER JOIN ' + @storage_position + ' sp
					ON sp.location_id = g.storage_location
					and sp.type = sr.type
				--WHERE   (sp.position/ (g.storage_capacity * case when g.volumn_uom = 1209 then 1000000 else 1 end) * 100) >= ISNULL(gas_in_storage_perc_from, 0)
				--		AND (sp.position/ (g.storage_capacity * case when g.volumn_uom = 1209 then 1000000 else 1 end) * 100) <= gas_in_storage_perc_to
				--		AND sp.location_id = cdmf.from_loc_id	
				where sp.position between
					CASE WHEN coalesce(sr.inventory_level_from, sr.inventory_level_to) IS NOT NULL THEN coalesce(sr.inventory_level_from,sr.inventory_level_to-1, 0) ELSE (isnull(sr.gas_in_storage_perc_from, -100) / 100.0 * g.storage_capacity * CASE WHEN g.volumn_uom = 1209 THEN 1000000 ELSE 1 END) END
					AND CASE WHEN coalesce(sr.inventory_level_from, sr.inventory_level_to) IS NOT NULL THEN isnull(sr.inventory_level_to, sp.position + 1) ELSE (sr.gas_in_storage_perc_to / 100.0 * g.storage_capacity * CASE WHEN g.volumn_uom = 1209 THEN 1000000 ELSE 1 END) END
					AND sp.location_id = cdmf.from_loc_id
					and ''' + cast(@flow_date_from as varchar(50)) + ''' between sr.term_from and sr.term_to								
			) r'
	EXEC(@sql)
	
	IF OBJECT_ID('tempdb..#tmp_filtered_data1') is not null
		DROP TABLE #tmp_filtered_data1

	SELECT t.box_id
		, t.from_loc_id
		, t.from_loc
		, t.to_loc_id
		, t.to_loc
		, t.from_rank
		, t.to_rank
		, SUM(t.received) received
		, SUM(t.delivered) delivered
		, COALESCE(MAX(first_pmdq.first_cmdq), SUM(t.mdq), 0) mdq
		, COALESCE(MAX(first_pmdq.first_crmdq), SUM(t.rmdq), 0) rmdq
		, COALESCE(MAX(first_pmdq.first_crmdq), SUM(t.rmdq), 0) ormdq
		, COALESCE(MAX(first_pmdq.first_sch_vol), SUM(t.total_sch_volume), 0) total_sch_volume
		, t.path_id
		, t.contract_id
		, ISNULL(MAX(ca_paths.path_ids), 0) [path_exists]
		, COALESCE(MAX(first_pmdq.first_pmdq), SUM(t.path_mdq), 0) path_mdq
		, COALESCE(MAX(first_pmdq.first_prmdq), SUM(t.path_rmdq), 0) path_rmdq
		, COALESCE(MAX(first_pmdq.first_prmdq), SUM(t.path_rmdq), 0) path_ormdq
		, @process_id [process_id]
		, t.from_loc_grp_id
		, t.from_loc_grp_name
		, t.to_loc_grp_id
		, t.to_loc_grp_name
		, MAX(t.box_type) box_type
		, MAX(t.from_proxy_loc_id) [from_proxy_loc_id]
		, MAX(t.to_proxy_loc_id) [to_proxy_loc_id]
	INTO #tmp_filtered_data1 --select * from #tmp_filtered_data1
	FROM #tmp_filtered_data t
	OUTER APPLY (
		SELECT [path_ids] = STUFF(
			(SELECT ','  + cast(t1.path_id AS VARCHAR)
			FROM #tmp_filtered_data t1 
			WHERE t1.box_id = t.box_id AND t1.path_id <> 0 AND t1.path_id IS NOT NULL
			FOR XML PATH(''))
		, 1, 1, '') 
		
	) ca_paths
	OUTER APPLY (
		SELECT TOP 1 NULLIF(cd1.path_mdq, 0) [first_pmdq]
			, NULLIF(cd1.path_rmdq, 0) [first_prmdq]
			, NULLIF(cd1.mdq, 0) [first_cmdq]
			, NULLIF(cd1.rmdq, 0) [first_crmdq]
			,  NULLIF(cd1.total_sch_volume, 0) [first_sch_vol]
		FROM delivery_path_detail dpd
		LEFT JOIN #tmp_filtered_data cd1 ON cd1.single_path_id = dpd.Path_name
			AND cd1.path_id = t.path_id
		WHERE dpd.Path_id = t.path_id
		ORDER BY cd1.path_mdq ASC		
	) first_pmdq
	GROUP BY t.box_id, t.from_loc_id, t.from_loc, t.to_loc_id, t.to_loc, t.from_rank, t.to_rank
		, t.from_loc_grp_id, t.from_loc_grp_name, t.to_loc_grp_id, t.to_loc_grp_name, t.path_id, t.contract_id
	
	--final select of data
	IF ISNULL(@call_from, '-1') <> 'HIDE_OUTPUT'
	BEGIN
		SELECT t.box_id
			, t.from_loc_id
			, t.from_loc
			, t.to_loc_id
			, t.to_loc
			, t.from_rank
			, t.to_rank
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.received), 0)) received
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.delivered), 0)) delivered
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.mdq), 0)) mdq
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.rmdq), 0)) rmdq
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.ormdq), 0)) ormdq
			, MAX(t.path_exists) path_exists
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.path_mdq), 0))  path_mdq
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.path_rmdq), 0)) path_rmdq
			, dbo.FNARemoveTrailingZero(ROUND(SUM(t.path_ormdq), 0)) path_ormdq
			, MAX(process_id) process_id
			, t.from_loc_grp_id
			, t.from_loc_grp_name
			, t.to_loc_grp_id
			, t.to_loc_grp_name
			, MAX(t.box_type) box_type
			, MAX(t.from_proxy_loc_id) from_proxy_loc_id
			, MAX(t.to_proxy_loc_id) to_proxy_loc_id
			, NULL [from_is_agg]
			, NULL [to_is_agg]
		FROM #tmp_filtered_data1 t
		GROUP BY t.box_id
				, t.from_loc_id
				, t.from_loc
				, t.to_loc_id
				, t.to_loc
				, t.from_rank
				, t.to_rank
				, t.from_loc_grp_id
				, t.from_loc_grp_name
				, t.to_loc_grp_id
				, t.to_loc_grp_name
		ORDER BY t.box_id
			, t.from_rank
			, t.from_loc_id
			, t.to_rank
			, t.to_loc_id
	END 
	ELSE
	BEGIN
		SELECT @process_id process_id
	END
		
END

ELSE IF @flag = 'r' --Firing run solver with SSIS solver package and filling up optimizer grid cell information
BEGIN

	set @sql = '
	TRUNCATE TABLE ' + @contractwise_detail_mdq + '
	INSERT INTO ' + @contractwise_detail_mdq + '
	SELECT * FROM ' + @contractwise_detail_mdq_fresh + '
	'
	EXEC(@sql)
	
/***
	STEPS FOR GROUP PATH:
	STEP 1: Get the single path with minimum mdq
	STEP 2: Adjust mdq of first single path for path loss
	STEP 3: Run solver for calculating received and delivered amount only for first single path of group path
	STEP 4: Calculate other received and delivered amount of other single paths 
***/

--STEP 1: Get the single path with minimum mdq
SET @sql = CAST('' AS VARCHAR(MAX)) + 
				'	IF OBJECT_ID(''' + @cw_mdq_group_wo_loss + ''') IS NOT NULL
					DROP TABLE ' + @cw_mdq_group_wo_loss + '
				
				IF OBJECT_ID(''' + @contractwise_detail_mdq_group + ''') IS NOT NULL
					DROP TABLE ' + @contractwise_detail_mdq_group + '
				
				IF OBJECT_ID(''' + @check_solver_case + ''') IS NOT NULL
					DROP TABLE ' + @check_solver_case + '

				CREATE TABLE ' + @cw_mdq_group_wo_loss + ' (
					box_id INT 
					,path_id  INT 
					,single_path_id	 INT 
					,path_mdq NUMERIC(38, 18)
					,mdq NUMERIC(38, 18)
					,path_rmdq NUMERIC(38, 18)
					,rmdq NUMERIC(38, 18)
					,path_ormdq NUMERIC(38, 18)
					,ormdq NUMERIC(38, 18)
					,supply_adjust_factor NUMERIC(38, 18)
					,demand_adjust_factor NUMERIC(38, 18)
					,delivery_adjust_factor NUMERIC(38, 18)
				)
					
			SELECT
				a.box_id,  
				a.path_id, 
				a.single_path_id, 
				a.path_rmdq remainning_vol,  
				a.loss_factor,
				a.path_rmdq/(1-a.loss_factor) received_vol, 
				''PATH'' mdq_type, 
				dpd.delivery_path_detail_id 
				INTO #single_paths
			FROM ' + @contractwise_detail_mdq + ' a
			INNER JOIN delivery_path_detail dpd
				ON dpd.Path_name = a.single_path_id
				AND dpd.Path_id = a.path_id
				AND a.group_path = ''y''
			UNION ALL
			SELECT 
				a.box_id,  
				a.path_id, 
				a.single_path_id,  
				a.rmdq remainning_vol, 
				a.loss_factor,
				a.rmdq/(1-a.loss_factor) received_vol, 
				''CONTRACT'' mdq_type, 
				dpd.delivery_path_detail_id 
			FROM ' + @contractwise_detail_mdq + ' a
			INNER JOIN delivery_path_detail dpd
				ON dpd.Path_name = a.single_path_id
				AND dpd.Path_id = a.path_id
				AND a.group_path = ''y''
			ORDER BY a.box_id, mdq_type, dpd.delivery_path_detail_id 
			
			DECLARE 
				@box_id INT,  
				@path_id INT, 
				@single_path_id INT, 
				@remainning_vol NUMERIC(38,18),  
				@loss_factor NUMERIC(38,18),
				@received_vol NUMERIC(38,18), 
				@mdq_type VARCHAR(20), 
				@delivery_path_detail_id INT,
				@min_value NUMERIC(38,18),
				@last_box_id INT = 0

			DECLARE cur_status10 CURSOR LOCAL FOR
				SELECT * 
				FROM #single_paths 
				ORDER BY box_id, remainning_vol, delivery_path_detail_id

			OPEN cur_status10;

			FETCH NEXT FROM cur_status10 INTO @box_id, @path_id, @single_path_id, @remainning_vol, @loss_factor, @received_vol,@mdq_type,@delivery_path_detail_id

			WHILE @@FETCH_STATUS = 0
			BEGIN

				IF @last_box_id <> @box_id
				BEGIN
					SET @last_box_id = @box_id
					SET @min_value = @received_vol

					INSERT INTO ' + @cw_mdq_group_wo_loss + '
					(
					box_id,	path_id,	single_path_id,	path_mdq,	mdq,	path_rmdq,	rmdq,	path_ormdq,	ormdq ,
					supply_adjust_factor,	demand_adjust_factor,	delivery_adjust_factor

					)
					SELECT a.box_id,	a.path_id,	a.single_path_id,	a.path_mdq,	a.mdq,	a.path_rmdq,	a.rmdq,	a.path_ormdq,	a.ormdq 
							,1,1,1
					FROM ' + @contractwise_detail_mdq + ' a
					WHERE box_id = @box_id
						AND single_path_id = @single_path_id

				END

				IF @min_value > @received_vol
					SET @min_value = @received_vol

				IF EXISTS(SELECT 1 FROM #single_paths 
					WHERE box_id = @box_id
					AND delivery_path_detail_id < @delivery_path_detail_id
					AND remainning_vol < @min_value
				)
				BEGIN
		
					DELETE a
					FROM ' + @cw_mdq_group_wo_loss + ' a
					INNER JOIN (
						SELECT TOP 1 * 
						FROM #single_paths 
						WHERE box_id = @box_id
						AND delivery_path_detail_id < @delivery_path_detail_id
						AND remainning_vol < @min_value
						ORDER BY remainning_vol
					) sub
					on a.box_id = sub.box_id 
				
					INSERT INTO ' + @cw_mdq_group_wo_loss + '
					(
					box_id,	path_id,	single_path_id,	path_mdq,	mdq,	path_rmdq,	rmdq,	path_ormdq,	ormdq ,
					supply_adjust_factor,	demand_adjust_factor,	delivery_adjust_factor
		
					)
					SELECT a.box_id,	a.path_id,	a.single_path_id,	a.path_mdq,	a.mdq,	a.path_rmdq,	a.rmdq,	a.path_ormdq,	a.ormdq 
							,1,1,1
					FROM ' + @contractwise_detail_mdq + ' a
					INNER JOIN (
						SELECT TOP 1 * 
						FROM #single_paths 
						WHERE box_id = @box_id
						AND delivery_path_detail_id < @delivery_path_detail_id
						AND remainning_vol < @min_value
						ORDER BY remainning_vol
					) sub 
					ON a.box_id = sub.box_id 
					AND a.single_path_id = sub.single_path_id
				END
	
				FETCH NEXT FROM cur_status10 INTO @box_id, @path_id, @single_path_id, @remainning_vol, @loss_factor, @received_vol,@mdq_type,@delivery_path_detail_id
			END
			CLOSE cur_status10;
			DEALLOCATE cur_status10;

			'
EXEC (@sql)

--STEP 2
SET @sql = CAST('' AS VARCHAR(MAX)) + ' 

			SELECT *
				, CAST(1 AS NUMERIC(38,18)) supply_adjust_factor
				, CAST(1 AS NUMERIC(38,18)) demand_adjust_factor 
				, CAST(1 AS NUMERIC(38,18)) delivery_adjust_factor 
				, CAST(NULL AS INT) [hour]
				, CAST(NULL AS INT) [granularity]
				
			INTO ' + @contractwise_detail_mdq_group + '
			FROM ' + @contractwise_detail_mdq + '
			WHERE 1 = 2

			select sub.box_id, SUM(a.position) position,''supply'' [type] 
			INTO #temp
			--, * 
			from ' + @opt_deal_detail_pos + ' a
			INNER JOIN 
			(
				select box_id, min(from_loc_id)from_loc_id, min(to_loc_id) to_loc_id
				from ' + @contractwise_detail_mdq_fresh + '
				where group_path = ''y''
				group by box_id
			)sub
			on a.location_id  = sub.from_loc_id
			GROUP BY sub.box_id
			UNION ALL
			select sub.box_id, SUM(a.position * -1) position,''demand'' --, * 
			from ' + @opt_deal_detail_pos + ' a
			INNER JOIN 
			(
				select box_id, min(from_loc_id)from_loc_id, min(to_loc_id) to_loc_id
				from ' + @contractwise_detail_mdq_fresh + '
				where group_path = ''y''
				group by box_id
			)sub
			on a.location_id  = sub.to_loc_id
			GROUP BY sub.box_id
			UNION ALL 
			select box_id, dbo.fnamin(path_rmdq,rmdq) , ''mdq''
			from ' + @cw_mdq_group_wo_loss + '

		
			select t.box_id, MAX(t.position) position, ''supply'' type--MAX(t.type) type --TO DO: change logic for limited demand
			INTO ' + @check_solver_case + '
			from #temp t
			cross apply (
			select top 1 * from #temp
			where t.box_id =  box_id
			order by position 
			) a
			where a.position = t.position and
			t.box_id = a.box_id
			GROUP BY t.box_id 


			--SELECT * FROM ' + @check_solver_case + '
				
			DECLARE @r_id INT, @box_id INT, @single_path_id INT, @path_mdq INT, @mdq INT, @loss_factor NUMERIC(38, 18), @next_path INT
				,@last_single_path_id INT, @delivery_path_detail_id INT
	
			--FOR DELIVERY ADJUST
			DECLARE cur_status10 CURSOR LOCAL FOR

				SELECT ROW_NUMBER() OVER (	PARTITION BY a.box_id 
					ORDER BY a.box_id, a.received DESC, dpd1.delivery_path_detail_id DESC)
				 r_id, a.box_id, a.single_path_id, dpd1.delivery_path_detail_id--, a.received, a.delivered, a.loss_factor
				FROM ' + @contractwise_detail_mdq + ' a 
				INNER JOIN ' + @cw_mdq_group_wo_loss + ' g
					ON a.box_id = g.box_id					
				INNER JOIN delivery_path_detail dpd1
					ON dpd1.path_name = a.single_path_id
					AND dpd1.path_id = a.path_id
				INNER JOIN delivery_path_detail dpd2
					ON dpd2.path_name = g.single_path_id
					AND dpd2.path_id = g.path_id				
				WHERE a.group_path = ''y'' 
					AND dpd1.delivery_path_detail_id >= dpd2.delivery_path_detail_id 

			OPEN cur_status10;

			FETCH NEXT FROM cur_status10 INTO @r_id, @box_id, @single_path_id, @delivery_path_detail_id
			WHILE @@FETCH_STATUS = 0
			BEGIN

				--select  @delivery_path_detail_id, @loss_factor
				UPDATE  wo
				SET wo.delivery_adjust_factor = wo.delivery_adjust_factor * (1 -loss_factor)
				FROM ' + @contractwise_detail_mdq + ' a
				INNER JOIN ' + @cw_mdq_group_wo_loss + ' wo
					ON a.box_id = wo.box_id
				INNER JOIN delivery_path_detail dpd
					ON dpd.path_name = a.single_path_id
					AND a.path_id = dpd.path_id
				WHERE a.box_id = @box_id 
					AND dpd.delivery_path_detail_id = @delivery_path_detail_id

				FETCH NEXT FROM cur_status10 INTO @r_id, @box_id, @single_path_id, @delivery_path_detail_id
			END
			CLOSE cur_status10;
			DEALLOCATE cur_status10;	
			

			--FOR LIMITED SUPPLY
			DECLARE cur_status CURSOR LOCAL FOR
				SELECT ROW_NUMBER() OVER (	PARTITION BY a.box_id 
					ORDER BY a.box_id, a.received DESC, dpd1.delivery_path_detail_id DESC)
				 r_id, a.box_id, a.single_path_id, dpd1.delivery_path_detail_id--, a.received, a.delivered, a.loss_factor
				FROM ' + @contractwise_detail_mdq + ' a 
				INNER JOIN ' + @cw_mdq_group_wo_loss + ' g
					ON a.box_id = g.box_id
					--AND a.single_path_id <= g.single_path_id
				INNER JOIN delivery_path_detail dpd1
					ON dpd1.path_name = a.single_path_id
					AND dpd1.path_id = a.path_id
				INNER JOIN delivery_path_detail dpd2
					ON dpd2.path_name = g.single_path_id
					AND dpd2.path_id = g.path_id
				INNER JOIN ' + @check_solver_case + ' t
					ON t.box_id = a.box_id
				WHERE a.group_path = ''y'' and t.type = ''supply''
					AND dpd1.delivery_path_detail_id <= dpd2.delivery_path_detail_id 

			OPEN cur_status;

			FETCH NEXT FROM cur_status INTO @r_id, @box_id, @single_path_id, @delivery_path_detail_id
			WHILE @@FETCH_STATUS = 0
			BEGIN

	
				SELECT @next_path =  MAX(dpd.delivery_path_detail_id) 
				FROM ' + @contractwise_detail_mdq + ' a
				INNER JOIN delivery_path_detail dpd
					ON dpd.path_name = a.single_path_id
					AND a.path_id = dpd.path_id
				WHERE box_id = @box_id 
					AND dpd.delivery_path_detail_id < @delivery_path_detail_id


				SELECT  @loss_factor = loss_factor
				FROM ' + @contractwise_detail_mdq + '
				WHERE box_id = @box_id 
					AND single_path_id = @single_path_id 

	
				--select @received,@delivered, @loss_factor, @box_id,@next_path
				UPDATE  wo
				SET wo.path_mdq = wo.path_mdq/(1- @loss_factor)
					,wo.mdq = wo.mdq/(1- @loss_factor)
					,wo.path_rmdq = wo.path_rmdq/(1- @loss_factor)
					,wo.rmdq = wo.rmdq/(1- @loss_factor)
					,wo.path_ormdq = wo.path_ormdq/(1- @loss_factor)
					,wo.ormdq = wo.ormdq/(1- @loss_factor)
					,wo.single_path_id = dpd.path_name
					,wo.supply_adjust_factor = wo.supply_adjust_factor * (1- loss_factor)
					---,wo.demand_adjust_factor = wo.demand_adjust_factor / (1- @loss_factor)
					
				from ' + @contractwise_detail_mdq + ' a
				INNER JOIN ' + @cw_mdq_group_wo_loss + ' wo
					ON a.box_id = wo.box_id
				INNER JOIN delivery_path_detail dpd
					ON dpd.path_name = a.single_path_id
					AND a.path_id = dpd.path_id
				WHERE a.box_id = @box_id 
					AND dpd.delivery_path_detail_id = @next_path

				FETCH NEXT FROM cur_status INTO @r_id, @box_id, @single_path_id, @delivery_path_detail_id
			END
			CLOSE cur_status;
			DEALLOCATE cur_status;	

			--FOR DEMAND ADJUST
			DECLARE @demand_adjust_factor  NUMERIC(38, 18) = 1
						
			DECLARE cur_status CURSOR LOCAL FOR
				SELECT box_id
				FROM ' + @cw_mdq_group_wo_loss + ' a 
		

			OPEN cur_status;

			FETCH NEXT FROM cur_status INTO  @box_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @demand_adjust_factor = 1
				

				SELECT @demand_adjust_factor = @demand_adjust_factor * (1.00000000000/ (1.0000000000 - loss_factor)) 
				FROM ' + @contractwise_detail_mdq + ' a
				WHERE box_id = @box_id 
				AND a.single_path_id NOT IN (				
					SELECT MIN(single_path_id) single_path_id 
					FROM ' + @contractwise_detail_mdq + ' a
					WHERE box_id = @box_id 
				) 


				UPDATE  wo
				SET wo.demand_adjust_factor = @demand_adjust_factor					
				FROM ' + @cw_mdq_group_wo_loss + ' wo
				WHERE  wo.box_id = @box_id
				

				FETCH NEXT FROM cur_status INTO @box_id
			END
			CLOSE cur_status;
			DEALLOCATE cur_status;	

						
			--FOR LIMITED DEMAND OR MDQ

			DECLARE cur_status1 CURSOR LOCAL FOR

				SELECT ROW_NUMBER() OVER (	PARTITION BY a.box_id 
					ORDER BY a.box_id, a.received DESC, dpd1.delivery_path_detail_id DESC)
				 r_id, a.box_id, a.single_path_id, dpd1.delivery_path_detail_id--, a.received, a.delivered, a.loss_factor
				FROM ' + @contractwise_detail_mdq + ' a 
				INNER JOIN ' + @cw_mdq_group_wo_loss + ' g
					ON a.box_id = g.box_id					
				INNER JOIN delivery_path_detail dpd1
					ON dpd1.path_name = a.single_path_id
					AND dpd1.path_id = a.path_id
				INNER JOIN delivery_path_detail dpd2
					ON dpd2.path_name = g.single_path_id
					AND dpd2.path_id = g.path_id
				INNER JOIN ' + @check_solver_case + ' t
					ON t.box_id = a.box_id
				WHERE a.group_path = ''y'' and t.type IN (''demand'', ''mdq'')
					AND dpd1.delivery_path_detail_id >= dpd2.delivery_path_detail_id 

			OPEN cur_status1;

			FETCH NEXT FROM cur_status1 INTO @r_id, @box_id, @single_path_id, @delivery_path_detail_id
			WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT @next_path =  MAX(dpd.delivery_path_detail_id) 
				FROM ' + @contractwise_detail_mdq + ' a
				INNER JOIN delivery_path_detail dpd
					ON dpd.path_name = a.single_path_id
					AND a.path_id = dpd.path_id
				WHERE box_id = @box_id 
					AND dpd.delivery_path_detail_id > @delivery_path_detail_id

		
				SELECT  @loss_factor = loss_factor
				FROM ' + @contractwise_detail_mdq + '
				WHERE box_id = @box_id 
					AND single_path_id = @single_path_id 

	
				--select @received,@delivered, @loss_factor, @box_id,@next_path
				UPDATE  wo
				SET wo.path_mdq = wo.path_mdq * (1- loss_factor)
					,wo.mdq = wo.mdq * (1- loss_factor)
					,wo.path_rmdq = wo.path_rmdq * (1- loss_factor)
					,wo.rmdq = wo.rmdq * (1- loss_factor)
					,wo.path_ormdq = wo.path_ormdq * (1- loss_factor)
					,wo.ormdq = wo.ormdq * (1- loss_factor)					
					,wo.single_path_id = dpd.path_name
				FROM ' + @contractwise_detail_mdq + ' a
				INNER JOIN ' + @cw_mdq_group_wo_loss + ' wo
					ON a.box_id = wo.box_id
				INNER JOIN delivery_path_detail dpd
					ON dpd.path_name = a.single_path_id
					AND a.path_id = dpd.path_id
				WHERE a.box_id = @box_id 
					AND dpd.delivery_path_detail_id = @next_path



				FETCH NEXT FROM cur_status1 INTO @r_id, @box_id, @single_path_id, @delivery_path_detail_id
			END
			CLOSE cur_status1;
			DEALLOCATE cur_status1;	
			

			INSERT INTO ' + @contractwise_detail_mdq_group + ' (
				box_id
				,from_loc_id
				,from_loc_grp_id
				,from_loc_grp_name
				,to_loc_grp_id
				,to_loc_grp_name
				,from_loc
				,to_loc_id
				,to_loc
				,received
				,delivered
				,path_id
				,single_path_id
				,path_name
				,group_path
				,path_mdq
				,path_rmdq
				,contract_id
				,contract_name
				,mdq
				,rmdq
				,total_sch_volume
				,loss_factor
				,priority
				,priority_id
				,from_rank
				,to_rank
				,storage_deal_type
				,storage_asset_id
				,storage_volume
				,from_proxy_loc_id
				,to_proxy_loc_id
				,from_is_proxy
				,to_is_proxy
				,parent_from_loc_id
				,parent_to_loc_id
				,segmentation
				,uom_conversion_factor
				,box_type
				,receipt_deals
				,delivery_deals
				,match_term_start
				,match_term_end
				,uom
				,path_ormdq
				,ormdq
				,supply_position
				,demand_position
				,term_start
				,supply_adjust_factor
				,demand_adjust_factor
				,delivery_adjust_factor
				,hour
				,granularity
				
			)

			SELECT a.box_id
				,a.from_loc_id
				,a.from_loc_grp_id
				,a.from_loc_grp_name
				,a.to_loc_grp_id
				,a.to_loc_grp_name
				,a.from_loc
				,a.to_loc_id
				,a.to_loc
				,a.received
				,a.delivered
				,a.path_id
				,a.single_path_id
				,a.path_name
				,a.group_path
				,a.path_mdq
				,a.path_rmdq
				,a.contract_id
				,a.contract_name
				,a.mdq
				,a.rmdq
				,a.total_sch_volume
				,a.loss_factor
				,a.priority
				,a.priority_id
				,a.from_rank
				,a.to_rank
				,a.storage_deal_type
				,a.storage_asset_id
				,a.storage_volume
				,a.from_proxy_loc_id
				,a.to_proxy_loc_id
				,a.from_is_proxy
				,a.to_is_proxy
				,a.parent_from_loc_id
				,a.parent_to_loc_id
				,a.segmentation
				, ISNULL(a.uom_conversion_factor, 1)
				,a.box_type
				,a.receipt_deals
				,a.delivery_deals
				,a.match_term_start
				,a.match_term_end
				,a.uom
				,a.path_ormdq
				,a.ormdq
				,a.[supply_position]
				,a.[demand_position]
				,a.[term_start]
				,1 supply_adjust_factor
				,1 demand_adjust_factor
				,1 delivery_adjust_factor
				,NULL [hour]
				,981 [granularity]
				
			FROM ' + @contractwise_detail_mdq + ' a
			WHERE group_path <> ''y''
			UNION ALL
			SELECT a.box_id
				,a.from_loc_id
				,a.from_loc_grp_id
				,a.from_loc_grp_name
				,a.to_loc_grp_id
				,a.to_loc_grp_name
				,a.from_loc
				,a.to_loc_id
				,a.to_loc
				,a.received
				,a.delivered
				,a.path_id
				,a.single_path_id
				,a.path_name
				,a.group_path
				,wo.path_mdq
				,wo.path_rmdq
				,a.contract_id
				,a.contract_name
				,wo.mdq
				,wo.rmdq
				,a.total_sch_volume
				,a.loss_factor
				,a.priority
				,a.priority_id
				,a.from_rank
				,a.to_rank
				,a.storage_deal_type
				,a.storage_asset_id
				,a.storage_volume
				,a.from_proxy_loc_id
				,a.to_proxy_loc_id
				,a.from_is_proxy
				,a.to_is_proxy
				,a.parent_from_loc_id
				,a.parent_to_loc_id
				,a.segmentation
				,ISNULL(a.uom_conversion_factor, 1)
				,a.box_type
				,a.receipt_deals
				,a.delivery_deals
				,a.match_term_start
				,a.match_term_end
				,a.uom
				,wo.path_ormdq
				,wo.ormdq
				,a.[supply_position]
				,a.[demand_position]
				,a.[term_start]
				,wo.supply_adjust_factor
				,wo.demand_adjust_factor
				,wo.delivery_adjust_factor
				,NULL [hour]
				,981 [granularity]
				
			FROM ' + @contractwise_detail_mdq + ' a
			INNER JOIN ' + @cw_mdq_group_wo_loss + ' wo
				ON a.box_id = wo.box_id
				AND a.single_path_id = wo.single_path_id 

				'

EXEC(@sql)

	SET @sql = '       
		IF OBJECT_ID(''' + @solver_decisions + ''') IS NOT NULL
						DROP TABLE ' + @solver_decisions + '
		CREATE TABLE ' + @solver_decisions + ' (
			[decision_id] INT IDENTITY(1, 1) NOT NULL,
			[source_id] INT NULL,
			[source_position] INT NULL,
			[source_rank] INT NULL,
			[source] VARCHAR(512) NULL,
			[destination_id] INT NULL,
			[destination_rank] INT NULL,
			[destination_position] INT NULL,
			[destination] VARCHAR(512) NULL,
			[path_id] INT NULL,
			[contract_id] INT NULL,
			[loss_factor] NUMERIC(38, 20) NULL,
			[mdq] NUMERIC(38, 20) NULL,
			[received] NUMERIC(38, 20) NULL,
			[delivery] NUMERIC(38, 20) NULL,
			[received_mdq] NUMERIC(38, 20) NULL,
			[goal_objective] INT NULL,
			[path_priority] VARCHAR(512) NULL,
			[contract_rank] VARCHAR(512) NULL,
			[as_of_date] DATETIME DEFAULT GETDATE(),
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[granularity] INT NULL,
			[supply_position] NUMERIC(38, 20) NULL,
			[demand_position] NUMERIC(38, 20) NULL
		) '
	EXEC(@sql)
	
	--STEP 3
	BEGIN -- call solver package
		EXEC spa_run_simplex_solver_package @process_id, 'n'

		--act as solver
		/*
		SET @sql = '
		UPDATE cdmg
			SET cdmg.received = 50,
				cdmg.delivered = 50, 
				cdmg.path_rmdq = cdmg.path_rmdq - 50
		FROM ' + @contractwise_detail_mdq_group + ' cdmg
		'
		EXEC(@sql)
		*/
	END

	--exec('select ''opt'',* from ' + @opt_deal_detail_pos)  

	--exec('select * from ' + @contractwise_detail_mdq_group)  return;

	--STEP 4
	SET @sql = '
				-- for group path
				UPDATE a
				SET received = g.received,
					delivered = g.delivered
					--,path_rmdq = g.path_rmdq

				FROM ' + @contractwise_detail_mdq + ' a 
				INNER JOIN ' + @contractwise_detail_mdq_group + ' g
					ON a.box_id = g.box_id
					AND CASE WHEN a.group_path = ''y'' THEN a.single_path_id ELSE -1 END  = CASE WHEN a.group_path = ''y'' THEN g.single_path_id ELSE -1 END
			
				-- for single path
				UPDATE a
				SET received = g.received,
					delivered = g.delivered

				FROM ' + @contractwise_detail_mdq + ' a 
				INNER JOIN ' + @contractwise_detail_mdq_group + ' g ON a.box_id = g.box_id 
					and a.group_path = ''n''
					and a.path_id = g.path_id
					and a.contract_id = g.contract_id
	
				DECLARE @r_id INT, @box_id INT, @single_path_id INT, @received NUMERIC(38, 20), @delivered NUMERIC(38, 20), @loss_factor NUMERIC(38, 18), @next_path INT
						,@delivery_detail_id INT
				
				--UP PATHS
				DECLARE cur_status_up CURSOR LOCAL FOR

					SELECT ROW_NUMBER() OVER (	PARTITION BY a.box_id 
						ORDER BY a.box_id, a.received DESC, dpd1.delivery_path_detail_id DESC)
						r_id, a.box_id, a.single_path_id, dpd1.delivery_path_detail_id--, a.received, a.delivered, a.loss_factor
					FROM ' + @contractwise_detail_mdq + ' a 
					INNER JOIN ' + @contractwise_detail_mdq_group + ' g
						ON a.box_id = g.box_id
					INNER JOIN delivery_path_detail dpd1
						ON dpd1.path_name = a.single_path_id
						AND dpd1.path_id = a.path_id
					INNER JOIN delivery_path_detail dpd2
						ON dpd2.path_name = g.single_path_id
						AND dpd2.path_id = g.path_id
					INNER JOIN ' + @check_solver_case + ' t
						ON t.box_id = a.box_id				
					WHERE a.group_path = ''y''
						AND dpd1.delivery_path_detail_id <= dpd2.delivery_path_detail_id
						AND t.type IN (''demand'', ''mdq'')


				OPEN cur_status_up;

				FETCH NEXT FROM cur_status_up INTO @r_id, @box_id, @single_path_id, @delivery_detail_id
				WHILE @@FETCH_STATUS = 0
				BEGIN

	
					SELECT @next_path=  MAX(dpd1.delivery_path_detail_id) 
					FROM ' + @contractwise_detail_mdq + ' a
					INNER JOIN delivery_path_detail dpd1
						ON dpd1.path_name = a.single_path_id
						AND dpd1.path_id = a.path_id
					WHERE box_id = @box_id 
					AND dpd1.delivery_path_detail_id < @delivery_detail_id
					--and a.single_path_id < @single_path_id


					SELECT	@received = received, 
							@delivered = delivered, 
							@loss_factor = loss_factor
					FROM ' + @contractwise_detail_mdq + '
					WHERE box_id = @box_id 
						AND single_path_id = @single_path_id 
	
					UPDATE a 
					SET delivered = @received,
					received =   @received/(1- loss_factor)
					FROM ' + @contractwise_detail_mdq + ' a
					INNER JOIN delivery_path_detail dpd1
						ON dpd1.path_name = a.single_path_id
						AND dpd1.path_id = a.path_id
					WHERE box_id = @box_id 
						AND dpd1.delivery_path_detail_id = @next_path


					FETCH NEXT FROM cur_status_up INTO @r_id, @box_id, @single_path_id, @delivery_detail_id
				END
				CLOSE cur_status_up;
				DEALLOCATE cur_status_up;	




				--DOWN PATHS
				DECLARE cur_status_dw CURSOR LOCAL FOR

					SELECT ROW_NUMBER() OVER (	PARTITION BY a.box_id 
						ORDER BY a.box_id, a.received DESC, dpd1.delivery_path_detail_id )
					 r_id, a.box_id, a.single_path_id, dpd1.delivery_path_detail_id--, a.received, a.delivered, a.loss_factor
					FROM ' + @contractwise_detail_mdq + ' a 
					INNER JOIN  ' + @contractwise_detail_mdq_group + '  g
						ON a.box_id = g.box_id
				--		AND a.single_path_id >= g.single_path_id
					INNER JOIN delivery_path_detail dpd1
						ON dpd1.path_name = a.single_path_id
						AND dpd1.path_id = a.path_id
					INNER JOIN delivery_path_detail dpd2
						ON dpd2.path_name = g.single_path_id
						AND dpd2.path_id = g.path_id
					INNER JOIN ' + @check_solver_case + ' t
						ON t.box_id = a.box_id				
					WHERE a.group_path = ''y''
						AND dpd1.delivery_path_detail_id >= dpd2.delivery_path_detail_id
						AND t.type = ''supply''

				OPEN cur_status_dw;

				FETCH NEXT FROM cur_status_dw INTO @r_id, @box_id, @single_path_id, @delivery_detail_id
				WHILE @@FETCH_STATUS = 0
				BEGIN

					SELECT @next_path=  MIN(dpd1.delivery_path_detail_id) 
					FROM ' + @contractwise_detail_mdq + ' a
					INNER JOIN delivery_path_detail dpd1
						ON dpd1.path_name = a.single_path_id
						AND dpd1.path_id = a.path_id
					WHERE box_id = @box_id 
					AND dpd1.delivery_path_detail_id > @delivery_detail_id
					--and a.single_path_id > @single_path_id

					SELECT @received = received, @delivered = delivered, @loss_factor = loss_factor
					FROM ' + @contractwise_detail_mdq + '
					WHERE box_id = @box_id 
						AND single_path_id = @single_path_id 

					--SELECT @single_path_id,@next_path, @received, @delivered , @loss_factor
	
					UPDATE a 
						SET received = @delivered,
							delivered = (1- loss_factor) * @delivered
					FROM ' + @contractwise_detail_mdq + ' a
					INNER JOIN delivery_path_detail dpd1
						ON dpd1.path_name = a.single_path_id
						AND dpd1.path_id = a.path_id
					WHERE box_id = @box_id 
						AND dpd1.delivery_path_detail_id = @next_path

					FETCH NEXT FROM cur_status_dw INTO @r_id, @box_id, @single_path_id, @delivery_detail_id
				END
				CLOSE cur_status_dw;
				DEALLOCATE cur_status_dw;	'

	EXEC(@sql)

	set @sql = '
	
	UPDATE ' + @contractwise_detail_mdq + '
		SET path_rmdq = path_rmdq - ISNULL(delivered, 0),
			rmdq = rmdq - ISNULL(delivered, 0)
	
	update cd set cd.rmdq = mdq - ca_mov.moved_vol
	from ' + @contractwise_detail_mdq + ' cd
	cross apply (
		select cd1.contract_id, sum(cd1.delivered) moved_vol
		from ' + @contractwise_detail_mdq + ' cd1
		where cd1.delivered > 0 and cd1.contract_id = cd.contract_id
		group by cd1.contract_id
	) ca_mov
	Where cd.group_path<> ''y''
	'
	exec(@sql)
	

	set @sql = '
	
	SELECT 	
		box_id
		,MAX(from_loc_id)from_loc_id	 
		,MAX(from_loc)	from_loc
		,MAX(to_loc_id)to_loc_id
		,MAX(to_loc)to_loc	
		,MAX(from_rank)	from_rank
		,MAX(to_rank)	to_rank
		,SUM(CAST(received AS INT))	received
		,SUM(CAST(delivered AS INT))	delivered
		,MAX(mdq)	mdq
		,MAX(rmdq)	rmdq
		,MAX(total_sch_volume)	total_sch_volume
		,MAX(path_exists)path_exists	
		,MAX(path_name)	path_name
		,SUM(CAST(path_mdq AS INT))	path_mdq
		,SUM(CAST(path_rmdq AS INT))	path_rmdq
		,SUM(CAST(path_ormdq AS INT))	path_ormdq
		,MAX(from_loc_grp_id)	from_loc_grp_id
		,MAX(from_loc_grp_name)	from_loc_grp_name
		,MAX(to_loc_grp_id)	to_loc_grp_id
		,MAX(to_loc_grp_name)to_loc_grp_name

	
	FROM (
	SELECT tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.received), 0)) [received]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.delivered), 0)) [delivered]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.mdq), 0)) [mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.rmdq), 0)) [rmdq]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.total_sch_volume), 0)) [total_sch_volume]
		, MAX(tsd.path_id) [path_exists]
		, MAX(tsd.path_name) [path_name]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_mdq), 0)) [path_mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_rmdq), 0)) [path_rmdq] 
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_ormdq), 0)) [path_ormdq]
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
	FROM ' + @contractwise_detail_mdq + ' tsd
	WHERE ISNULL(group_path, ''n'') <> ''y''
	GROUP BY tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
	--order by from_rank asc, from_loc asc, to_rank asc, to_loc asc
	UNION ALL
	SELECT tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, dbo.FNARemoveTrailingZero(ROUND(MAX(tsd.received), 0)) [received]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.delivered), 0)) [delivered]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.mdq), 0)) [mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.rmdq), 0)) [rmdq]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.total_sch_volume), 0)) [total_sch_volume]
		, MAX(tsd.path_id) [path_exists]
		, MAX(tsd.path_name) [path_name]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_mdq), 0)) [path_mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_rmdq), 0))  [path_rmdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_ormdq), 0)) [path_ormdq]
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
	FROM ' + @contractwise_detail_mdq + ' tsd
	WHERE ISNULL(group_path, ''n'') =''y''
	GROUP BY tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
	)sub 
	GROUP BY sub.box_id

	order by box_id asc

	'
	--print(@sql)
	EXEC(@sql)

END
ELSE IF @flag = 'y' --Extracting path and contract level information to load on path list of outer popup and inner popup
BEGIN
	--set @sql = '
	--SELECT pt.path_id, isnull(max(first_pmdq.first_pmdq), sum(pt.path_mdq)) [first_path_mdq]
	--	, pt.path_name
	--	, max(pt.[priority]) [path_priority]
	--	, coalesce(max(first_pmdq.first_pmdq), sum(pt.path_mdq)) [path_mdq]
	--	, coalesce(max(first_pmdq.first_pormdq), sum(pt.path_ormdq)) [path_ormdq]
	--	, coalesce(max(first_pmdq.first_cmdq), sum(pt.mdq)) [contract_mdq]
	--	, max(pt.loss_factor) [path_loss_factor]
	--	, max(pt.from_loc_id) [from_location]
	--	, max(pt.to_loc_id) [to_location]
	--	, max(pt.group_path) [group_path]
	--FROM ' + @contractwise_detail_mdq + ' pt
	--outer apply (
	--	select top 1 dpd.path_id, dpd.delivery_path_detail_id, dpd.Path_name
	--		, cd1.path_mdq [first_pmdq], cd1.path_ormdq [first_pormdq], cd1.path_rmdq [first_prmdq]
	--		, cd1.mdq [first_cmdq]
	--	from delivery_path_detail dpd
	--	left join ' + @contractwise_detail_mdq + ' cd1 on cd1.single_path_id = dpd.Path_name
	--		and cd1.path_id = pt.path_id
	--	where dpd.Path_id = pt.path_id
	--	order by dpd.delivery_path_detail_id asc
		
	--) first_pmdq
	--WHERE 1=1 and pt.path_id is not null and pt.path_id > 0 and pt.box_id = ' + @xml_manual_vol + '
	--group by pt.path_id, pt.path_name
	--'
	----print(@sql)
	--exec(@sql)

	--For bookout match
	IF @xml_manual_vol = -1
	BEGIN

		SELECT @min_contract_id = MAX(contract_id)
		FROM contract_group

		SELECT 
				  -1 path_id
				, 0 [first_path_mdq]
				, 'Back to Back Path' [path_name]
				, 1 [path_priority]
				, 0 [path_mdq]
				, 0 [path_ormdq]
				, 0 [contract_mdq]
				, 0 [path_loss_factor]
				, 1 [from_location]
				, 1 [to_location]
				, 'n' [group_path]
				, @min_contract_id [contract_id]
				, '-1' table_id

				return;
	END 
	
	SET @sql = '
	SELECT pt.path_id
		, pt.path_mdq [first_path_mdq]
		, pt.path_name + '' ('' + pt.contract_name + '')'' [path_name]
		, pt.[priority] [path_priority]
		, pt.path_mdq [path_mdq]
		, pt.path_ormdq [path_ormdq]
		, pt.mdq [contract_mdq]
		, pt.loss_factor [path_loss_factor]
		, pt.from_loc_id [from_location]
		, pt.to_loc_id [to_location]
		, pt.group_path [group_path]
		, pt.contract_id [contract_id]
		, CAST(pt.path_id AS VARCHAR(10)) + ''_'' + CAST(pt.contract_id AS VARCHAR(10)) table_id
	FROM ' + @contractwise_detail_mdq + ' pt
	WHERE pt.path_id IS NOT NULL 
		AND pt.path_id > 0 
		AND pt.group_path = ''n''
		AND pt.box_id = ' + @xml_manual_vol + 
	' UNION ALL 
	SELECT pt.path_id
		, MAX(pt.path_mdq) [first_path_mdq]
		, MAX(pt.path_name)  [path_name]
		, MAX(pt.[priority]) [path_priority]
		, MAX(pt.path_mdq) [path_mdq]
		, MAX(pt.path_ormdq) [path_ormdq]
		, MAX(pt.mdq) [contract_mdq]
		, MAX(pt.loss_factor) [path_loss_factor]
		, MAX(pt.from_loc_id)[from_location]
		, MAX(pt.to_loc_id) [to_location]
		, MAX(pt.group_path) [group_path]
		, MAX(pt.contract_id) [contract_id]
		, CAST(pt.path_id AS VARCHAR(10)) table_id
	FROM ' + @contractwise_detail_mdq + ' pt
	WHERE pt.path_id IS NOT NULL 
		AND pt.path_id > 0 
		AND pt.group_path = ''y''
		AND pt.box_id = ' + @xml_manual_vol + 
	' GROUP BY pt.path_id '
	EXEC(@sql)


	--exec spa_print @contractwise_detail_mdq

END
ELSE IF @flag = 'q' --Filling up Contract Detail information on Main Popup on Optimization Grid
BEGIN
	--For bookout match
	IF @xml_manual_vol = -1
	BEGIN
		SELECT @min_contract_id = MAX(contract_id)
		FROM contract_group

		DECLARE @contract_name VARCHAR(500)

		SELECT @contract_name = contract_name		
		FROM contract_group
		WHERE contract_id = @min_contract_id

		SELECT 	-1 from_location
				,-1 to_location
				,-1 path_id
				,'Back to Back Path' path_name
				,-1 delivery_path_detail_id
				,-1 single_path_id
				,0 oss_factor
				,@min_contract_id contract_id
				,@contract_name contract_name
				,0 contract_mdq
				,0 contract_rmdq
				,0 contract_ormdq
				,0 path_mdq
				,0 path_rmdq
				,0 path_ormdq
				,0 first_path_mdq
				,0 total_mdq
				,0 total_rmdq
				,0 receipt
				,0 receipt_total
				,0 delivery
				,0 delivery_total
				,1 segmentation
				,1 pipeline
				,'n' group_path
				,'-1' table_id

		return;
	END 

	set @sql = '
	if OBJECT_ID(''tempdb..##path_detail_q'') is not null
		drop table ##path_detail_q
	SELECT pt.from_loc_id [from_location], pt.to_loc_id [to_location]
		, pt.path_id [path_id], dp.path_name [path_name]
		, dpd.delivery_path_detail_id, pt.single_path_id [single_path_id]
		, pt.loss_factor [loss_factor]
		, pt.contract_id [contract_id], pt.contract_name [contract_name]
		, isnull(pt.mdq, 0) [contract_mdq]
		, isnull(pt.rmdq, 0) [contract_rmdq]
		, isnull(pt.rmdq, 0) [contract_ormdq]
		, isnull(pt.path_mdq, 0) [path_mdq]
		, isnull(pt.path_rmdq,0) [path_rmdq]
		, isnull(pt.path_ormdq,0) [path_ormdq]
		, coalesce(first_pmdq.first_pmdq, pt.path_mdq, 0) [first_path_mdq]
		, isnull(pt.path_mdq, 0) [total_mdq], isnull(pt.path_rmdq, 0) [total_rmdq]
		, isnull(pt.received, 0) [receipt]
		, IIF(pt.group_path = ''y'', total_mdq.first_received, ISNULL(total_mdq.receipt_total, 0)) [receipt_total]
		, isnull(pt.delivered, 0) [delivery]
		, IIF(pt.group_path = ''y'', total_mdq.last_delivered, ISNULL(total_mdq.delivery_total, 0)) [delivery_total]
		, pt.segmentation [segmentation]
		, sc.counterparty_name [pipeline]
		, pt.group_path
		, CAST(pt.path_id AS VARCHAR(10)) + IIF(pt.group_path = ''y'', '''', ''_'' + CAST(pt.contract_id AS VARCHAR(10))) table_id
		into ##path_detail_q
	FROM ' + @contractwise_detail_mdq  + ' pt
	CROSS APPLY (
		select sum(pt1.received) [receipt_total] , sum(pt1.delivered) [delivery_total], MAX(received) first_received, MIN(delivered) last_delivered
		from ' + @contractwise_detail_mdq + ' pt1
		WHERE pt1.box_id = pt.box_id 
			AND pt1.path_id = pt.path_id
	) total_mdq
	outer apply (
		select top 1 dpd.path_id, dpd.delivery_path_detail_id, dpd.Path_name,cd1.path_mdq [first_pmdq]
		from delivery_path_detail dpd
		LEFT JOIN ' + @contractwise_detail_mdq + ' cd1 
			ON cd1.single_path_id = dpd.Path_name
			and cd1.path_id = pt.path_id
		where dpd.Path_id = pt.path_id
		order by cd1.path_mdq asc
	) first_pmdq
	LEFT JOIN delivery_path dp 
		ON dp.path_id = COALESCE(pt.single_path_id, pt.path_id)
	LEFT JOIN source_counterparty sc 
		ON sc.source_counterparty_id = dp.counterParty
	LEFT JOIN delivery_path_detail dpd 
		ON dpd.Path_name = pt.single_path_id 
		AND dpd.path_id = pt.path_id
	WHERE 1=1 
		AND pt.path_id <> 0 
		AND pt.box_id = ' + @xml_manual_vol + '
		AND (pt.group_path = ''n'' OR (pt.group_path = ''y'' AND pt.contract_id=dp.CONTRACt))'

	exec(@sql)
	
	update pdq
	set pdq.total_mdq = agg.total_mdq, pdq.total_rmdq = agg.total_rmdq
	from ##path_detail_q pdq
	cross apply (
		select sum(path_mdq) total_mdq, sum(path_rmdq) total_rmdq
		from ##path_detail_q p1
		where pdq.path_id = p1.path_id --and pdq.single_path_id = p1.single_path_id
		group by p1.path_id
	) agg

	SELECT 	from_location
			,to_location
			,path_id
			,path_name
			,delivery_path_detail_id
			,single_path_id
			,loss_factor
			,contract_id
			,contract_name
			,dbo.FNARemoveTrailingZero(ROUND(contract_mdq, 0)) contract_mdq
			,dbo.FNARemoveTrailingZero(ROUND(contract_rmdq, 0)) contract_rmdq
			,dbo.FNARemoveTrailingZero(ROUND(contract_ormdq, 0)) contract_ormdq
			,dbo.FNARemoveTrailingZero(ROUND(path_mdq, 0)) path_mdq
			,dbo.FNARemoveTrailingZero(ROUND(path_rmdq, 0)) path_rmdq
			,dbo.FNARemoveTrailingZero(ROUND(path_ormdq, 0)) path_ormdq
			,dbo.FNARemoveTrailingZero(ROUND(first_path_mdq, 0)) first_path_mdq
			,dbo.FNARemoveTrailingZero(ROUND(total_mdq, 0)) total_mdq
			,dbo.FNARemoveTrailingZero(ROUND(total_rmdq, 0)) total_rmdq
			,dbo.FNARemoveTrailingZero(ROUND(receipt, 0)) receipt
			,dbo.FNARemoveTrailingZero(ROUND(receipt_total, 0)) receipt_total
			,dbo.FNARemoveTrailingZero(ROUND(delivery, 0)) delivery
			,dbo.FNARemoveTrailingZero(ROUND(delivery_total, 0)) delivery_total
			,segmentation
			,pipeline
			,group_path
			,table_id
	FROM  ##path_detail_q
	ORDER BY delivery_path_detail_id
END
ELSE IF @flag = 'g'
BEGIN
	SET @sql = '
				SELECT pt.contract_name [contract_name]
					, ISNULL(pt.mdq, 0) [contract_mdq]
					, ISNULL(pt.rmdq, 0) - ISNULL(pt.delivered, 0) [contract_rmdq]
					, ISNULL(pt.path_mdq, 0) [path_mdq]
					, ISNULL(pt.path_rmdq, 0) - ISNULL(pt.delivered, 0) [path_rmdq]
					, ISNULL(pt.received, 0) [receipt]
					, ISNULL(pt.delivered, 0) [delivery]
					, pt.path_id [path_id]
					--, dbo.fnadateformat(pt.match_term_start) match_term_start
					--, dbo.fnadateformat(pt.match_term_end) match_term_end
				FROM ' + @contractwise_detail_mdq + ' pt
				--CROSS APPLY (
				--	SELECT SUM(pt1.received) [receipt_total] , SUM(pt1.delivered) [delivery_total]
				--	FROM ' + @contractwise_detail_mdq + ' pt1
				--	WHERE pt1.box_id = pt.box_id AND pt1.path_id = pt.path_id
				--) total_mdq
				WHERE 1=1 
					AND pt.path_id <> 0 
					AND pt.box_id = ' + @xml_manual_vol
	EXEC(@sql)

END
else if @flag = 'z' --For saving manual scheduling adjustments to process table
begin
	declare @idoc_z int
	IF OBJECT_ID('tempdb..#manual_vol_info') IS NOT NULL 
		DROP TABLE #manual_vol_info
	exec sp_xml_preparedocument @idoc_z output, @xml_manual_vol
	
	--insert into #manual_vol_info
	select *
	into #manual_vol_info
	from openxml(@idoc_z,'/Root/PSRecordset',2)
	with (
		box_id				INT		      '@box_id',
		path_id				INT		      '@path_id',
		single_path_id		INT		      '@single_path_id',
		contract_id			INT		      '@contract_id',
		rec_vol				FLOAT	      '@rec_vol',
		del_vol				FLOAT	      '@del_vol',
		loss_factor			FLOAT	      '@loss_factor',
		storage_deal_type	CHAR(1)	      '@storage_deal_type',
		storage_asset_id	INT		      '@storage_asset_id',
		storage_volume		float	      '@storage_volume',
		receipt_deals       varchar(1000) '@receipt_deals',
		delivery_deals      varchar(1000) '@delivery_deals',
		match_term_start    VARCHAR(50)   '@match_term_start',
		match_term_end      VARCHAR(50)	  '@match_term_end'
	)
	SET @sql = 'UPDATE cd
				SET cd.received = mvi.rec_vol, 
					cd.delivered = mvi.del_vol, 
					cd.storage_deal_type = mvi.storage_deal_type
					, cd.storage_asset_id = mvi.storage_asset_id
					, cd.storage_volume = mvi.storage_volume
					, cd.receipt_deals = mvi.receipt_deals
					, cd.delivery_deals = mvi.delivery_deals
					, cd.match_term_start = mvi.match_term_start
					, cd.match_term_end = mvi.match_term_end
					, cd.loss_factor = mvi.loss_factor
				FROM ' + @contractwise_detail_mdq + ' cd
				INNER JOIN #manual_vol_info mvi 
					ON mvi.box_id = cd.box_id 
					AND mvi.path_id = cd.path_id 
					AND mvi.contract_id = cd.contract_id
					AND COALESCE(NULLIF(mvi.single_path_id,''-1''),-1) = COALESCE(cd.single_path_id,-1)
				'
	--print(@sql)
	exec(@sql)
	select * from #manual_vol_info
end
ELSE IF @flag = 'p' --For position report drill on begining inverntory optimization grid
BEGIN
	
	SET @sql = CAST('' AS VARCHAR(MAX)) + '
	SELECT dbo.FNAUserDateFormat(tm.term_start, dbo.FNADBUser()) [Term Start]
		, CASE 
			WHEN ''' + CAST(@batch_flag AS VARCHAR) + ''' = 0
				THEN ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMHyperlink(10131010,'' + CAST(dd.source_deal_header_id AS VARCHAR(10)) + '',''''n'''',''''NULL'''')"><font color="#0000ff"><u>'' + CAST(dd.source_deal_header_id AS VARCHAR(10)) + ''</u></font></span>''
			ELSE CAST(dd.source_deal_header_id AS VARCHAR(10))
			END [Deal ID]
		, MAX(sml_parent_proxy.location_name) [Proxy Location]
		--, null [Proxy Location]
		--, MAX(CASE 
		--		WHEN sdht.template_name <> ''' + @transportation_template_name + '''
		--			OR dd.leg = 1
		--			THEN ISNULL(NULLIF(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + ISNULL('' ['' + mjr.location_name + '']'', '''')
		--		ELSE ISNULL(NULLIF(ca_leg_loc.location_id, ca_leg_loc.location_name) + ''-'', '''') + ca_leg_loc.location_name + ISNULL('' ['' + ca_leg_loc.location_type + '']'', '''')
		--		END) [Location]
		, MAX(ISNULL(NULLIF(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + ISNULL('' ['' + mjr.location_name + '']'', '''')) [Location]
		, MAX(CASE 
				WHEN sdht.template_name = ''' + @transportation_template_name + '''
					THEN CASE 
							WHEN mjr.location_name = ''M2''
								THEN CASE dd.leg
										WHEN 2
											THEN ''Gath Nom''
										ELSE ''Interstate Nom''
										END
							WHEN mjr.location_name = ''Storage''
								THEN ''Storage''
							ELSE ''Interstate Nom''
							END
				ELSE CASE 
						WHEN dd.buy_sell_flag = ''b''
							THEN ''Purchase''
						WHEN dd.buy_sell_flag = ''s''
							THEN ''Sales''
						END
				END) [Group]
		, MAX(sdh.description1) [Nomination Group]
		, COALESCE(TRY_CONVERT(INT, sdv_pr.code), TRY_CONVERT(INT, sdh.description2), 168) [priority]
		, MAX(sc.counterparty_name) [Counterparty]
		, MAX(sdh.deal_id) [Reference ID]
		, MAX(cg.contract_name) [Contract]
		, CAST(SUM(hp.position) AS NUMERIC(20,5))  [Position]
		, IIF(
			MAX(sdht.template_name) = ''' + @transportation_template_name + '''
			, NULL
			, CAST((SUM(hp.position) - COALESCE(MAX(opt_supply.volume_used), MAX(opt_demand.volume_used) * -1, 0)) AS NUMERIC(20,5))
		  )  [Available Volume]
		, MAX(uom.uom_name) [UOM]
	INTO #tmp_position
	FROM source_deal_detail dd --on dd.location_id=d.location_id and dd.source_deal_header_id = d.source_deal_header_id  and dd.physical_financial_flag=''p''
	INNER JOIN #deal_term_breakdown tm
		ON dd.source_deal_detail_id = tm.source_deal_detail_id
		AND tm.term_start = dd.term_start
	INNER JOIN source_minor_location from_loc
		ON from_loc.source_minor_location_id = dd.location_id
	INNER JOIN source_major_location mjr
		ON mjr.source_major_location_id = from_loc.source_major_location_id
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = dd.source_deal_header_id
		AND sdh.physical_financial_flag = ''p''
	INNER JOIN source_deal_header_template sdht
		ON sdht.template_id = sdh.template_id
	INNER JOIN source_deal_type sdt
		ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_deal_type sdt1
		ON sdt1.source_deal_type_id = sdh.deal_sub_type_type_id
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN contract_group cg
		ON cg.contract_id = sdh.contract_id
	LEFT JOIN source_uom uom
		ON uom.source_uom_id = ' + ISNULL(CAST(NULLIF(@uom, '') AS VARCHAR(100)), 'dd.deal_volume_uom_id') + '
	LEFT JOIN #deal_detail_udf dudf_priority(NOLOCK)
		ON dudf_priority.source_deal_detail_id = dd.source_deal_detail_id
		AND dudf_priority.field_label = ''Priority''
	LEFT JOIN static_data_value sdv_pr
		ON CAST(sdv_pr.value_id AS VARCHAR) = dudf_priority.udf_value
	OUTER APPLY (
		SELECT SUM(volume) vol
		FROM source_deal_detail_hour
		WHERE source_deal_detail_id = dd.source_deal_detail_id
			AND term_date = tm.term_start
			AND dd.deal_volume_frequency = ''t''
	) sddh
	OUTER APPLY (
		SELECT sdd.location_id [source_minor_location_id]
			, sml.location_name
			, smj.location_name [location_type]
			, sml.location_id
			, sml.proxy_location_id
		FROM source_deal_detail sdd
		LEFT JOIN source_minor_location sml
			ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN source_major_location smj
			ON smj.source_major_location_id = sml.source_major_location_id
		WHERE sdd.leg = CASE dd.leg
				WHEN 1
					THEN 2
				ELSE 1
				END
			AND sdd.source_deal_header_id = dd.source_deal_header_id
			AND sdd.term_start = dd.term_start
			AND sdd.physical_financial_flag = ''p''
	) ca_leg_loc
	OUTER APPLY (
		SELECT TOP 1 sml1.source_minor_location_id
			, sml1.proxy_position_type
		FROM source_minor_location sml1
		WHERE (from_loc.proxy_location_id IS NOT NULL)
			AND sml1.source_minor_location_id <> from_loc.source_minor_location_id
			AND sml1.proxy_location_id = from_loc.proxy_location_id
			AND sml1.proxy_position_type IS NOT NULL
	) indirect_proxy_pos_type_c
	OUTER APPLY (
		SELECT TOP 1 sml1.source_minor_location_id
			, sml1.proxy_position_type
		FROM source_minor_location sml1
		WHERE (from_loc.proxy_location_id IS NULL)
			AND sml1.proxy_location_id = from_loc.source_minor_location_id
			AND sml1.proxy_position_type IS NOT NULL
	) indirect_proxy_pos_type_p
	LEFT JOIN ' + @hourly_pos_info + ' hp
		ON hp.source_deal_header_id = dd.source_deal_header_id
		AND hp.term_start = tm.term_start
		AND hp.location_id = dd.location_id
		AND hp.curve_id = dd.curve_id
	OUTER APPLY (
		SELECT SUM(od1.volume_used) [volume_used]
		FROM optimizer_detail od1
		WHERE od1.source_deal_header_id = sdh.source_deal_header_id
			AND od1.flow_date = tm.term_start
			AND od1.up_down_stream = ''U''
	) opt_supply
	OUTER APPLY (
		SELECT SUM(od2.deal_volume) [volume_used]
		FROM optimizer_detail_downstream od2
		WHERE od2.source_deal_header_id = sdh.source_deal_header_id
			AND od2.flow_date = tm.term_start
	) opt_demand
	LEFT JOIN source_minor_location sml_parent_proxy
		ON sml_parent_proxy.source_minor_location_id = from_loc.proxy_location_id
	WHERE 1 = 1
		AND (
			dd.location_id = ' + @minor_location + '
			OR (
				from_loc.proxy_location_id = ' + @minor_location + '
				AND COALESCE(from_loc.proxy_position_type, indirect_proxy_pos_type_c.proxy_position_type, indirect_proxy_pos_type_p.proxy_position_type) = 110201
				)
			)
		AND sdt.source_deal_type_name NOT LIKE ''Capacity%''
		AND ISNULL(sdt1.source_deal_type_name, '''') <> ''Injection''
	GROUP BY dd.source_deal_header_id
		, COALESCE(TRY_CONVERT(INT, sdv_pr.code), TRY_CONVERT(INT, sdh.description2), 168)
		--, CASE 
		--	WHEN sdht.template_name <> ''' + @transportation_template_name + '''
		--		OR dd.leg = 1
		--		THEN ISNULL(NULLIF(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + ISNULL('' ['' + mjr.location_name + '']'', '''')
		--	ELSE ISNULL(NULLIF(ca_leg_loc.location_id, ca_leg_loc.location_name) + ''-'', '''') + ca_leg_loc.location_name + ISNULL('' ['' + ca_leg_loc.location_type + '']'', '''')
		--	END
		, ISNULL(NULLIF(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + ISNULL('' ['' + mjr.location_name + '']'', '''')
		, tm.term_start

	IF ''' + CAST(@batch_flag AS VARCHAR) + ''' = 0
	BEGIN
		
		SELECT * FROM #tmp_position ORDER BY [Term Start],[Deal ID],[Location]
	END
	ELSE
	BEGIN
		SELECT * INTO ' + @temptablename + ' FROM #tmp_position ORDER BY [Term Start],[Deal ID],[Location]
	END
	'
	--print @sql
	EXEC(@sql)
END
ELSE IF @flag IN ('m', 'n', 'pl')
BEGIN

	DECLARE @sql1 VARCHAR(MAX)

	SET @sql = CAST('' AS VARCHAR(MAX)) + '

				SELECT  
						CASE WHEN MIN(d.term_start) < ''' +  CAST(@flow_date_from AS VARCHAR(50)) + ''' THEN  ''' +  CAST(@flow_date_from AS VARCHAR(50)) + ''' ELSE min(d.term_start) end term_start,
							CASE WHEN max(d.term_end) > ''' +  CAST(@flow_date_to_temp AS VARCHAR(50)) + ''' THEN  ''' +  CAST(@flow_date_to_temp AS VARCHAR(50)) + '''  else  max(d.term_end) end  term_end,
					''<span style="cursor: pointer;" onclick="parent.parent.TRMHyperlink(10131010,''+cast(d.source_deal_header_id as varchar(10))+'',''''n'''',''''NULL'''')"><font color="#0000ff"><u>''+cast(d.source_deal_header_id as varchar(10))+''</u></font></span>'' [Deal ID]
					, case when sdht.template_name <> ''' + @transportation_template_name + ''' or d.leg = 1 
						then isnull(nullif(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + isnull('' ['' + d.location_type + '']'', '''')
						else isnull(nullif(ca_leg_loc.location_id, ca_leg_loc.location_name) + ''-'', '''') + ca_leg_loc.location_name + isnull('' ['' + ca_leg_loc.location_type + '']'', '''')
					  end [Location]
					, ISNULL(MAX(sm2.location_id),MAX(sm2.location_name)) [proxy_location]
					, max(d.[Group]) [Group]
					, max(d.nom_group) [Nomination Group]
					, cast(d.priority as int) [Priority]
					, max(sc.counterparty_name) [Counterparty]
		
					, case when sdht.template_name <> ''' + @transportation_template_name + ''' or d.leg = 1 
						then d.location_type 
						else ca_leg_loc.location_type 
					  end [Location Type]
					, case when d.leg = 1 and ca_leg_loc.location_name is not null and sdht.template_name = ''' + @transportation_template_name + '''
						then isnull(nullif(ca_leg_loc.location_id, ca_leg_loc.location_name) + ''-'', '''') + ca_leg_loc.location_name + isnull('' ['' + ca_leg_loc.location_type + '']'', '''')
						else isnull(nullif(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + isnull('' ['' + d.location_type + '']'', '''')
					  end [To Location]
					, case when d.leg = 1 and ca_leg_loc.location_name is not null and sdht.template_name = ''' + @transportation_template_name + ''' 
						then ca_leg_loc.location_type 
						else d.location_type 
					  end [To Location Type]
						--, max(from_loc.pipeline) [Location Pipeline]
						, max(scc.counterparty_desc) [Location Pipeline]
					, max(d.reference_id) [Reference ID]
					, max(d.from_deal) [From Deal]
					, max(d.to_deal) [To Deal]
					, max(cg.contract_name) [Contract]
					, ROUND(SUM(d.position), 0)  [Position]
					, max(uom.uom_name) [UOM]
					, cast(d.source_deal_header_id as varchar(10)) source_deal_header_id
					, MAX(d.location_id) location_id
					, max(sc.source_counterparty_id) [Counterparty ID]
					, MAX(sm2.source_minor_location_id) [proxy_location_id]
					, MAX(sdh.header_buy_sell_flag) header_buy_sell_flag
					, max(cg.contract_id) [Contract_ID]
					,' + IIF(@volume_conversion IS NULL,'1','max(ISNULL(rvuc.conversion_factor, 1))') + ' conversion_factor 
					, max(sc1.counterparty_name) [upstream_counterparty]
					, max(cg1.contract_name) [upstream_contract]
					INTO #temp_selected_deals
				FROM ' + @opt_deal_detail_pos + ' d
				inner join source_deal_detail dd on dd.location_id=d.location_id and dd.source_deal_header_id = d.source_deal_header_id  and dd.physical_financial_flag=''p''
				--cross apply [dbo].[FNATermBreakdown](''d'',dd.term_start ,dd.term_end) tm
				OUTER APPLY (
								SELECT DATEADD(day, n - 1, dd.term_start) term_start, DATEADD(day, n - 1, dd.term_start) term_end  
									FROM seq 
								WHERE dd.term_end >= DATEADD(day, n - 1, dd.term_start) 
							) tm
				inner join source_minor_location from_loc on from_loc.source_minor_location_id = d.location_id
				left join source_minor_location sm2 on sm2.source_minor_location_id = from_loc.proxy_location_id
				inner join source_deal_header sdh on sdh.source_deal_header_id = d.source_deal_header_id
				inner join source_deal_type sdt on sdt.source_deal_type_id=sdh.source_deal_type_id and sdt.deal_type_id IN ' + CASE WHEN @flag = 'pl' THEN '(''Physical'',''Transportation'')'  ELSE '(''Physical'', ''Storage'')' END +'
						and sdh.header_buy_sell_flag=' + CASE WHEN @flag = 'm' THEN '''b''' 
																WHEN @flag = 'pl' THEN 'sdh.header_buy_sell_flag' 
																ELSE '''s''' END + ''
				 +'
				inner join source_deal_header_template sdht on sdht.template_id = sdh.template_id
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = d.counterparty_id
				left join source_counterparty scc on scc.source_counterparty_id = from_loc.pipeline
				LEFT JOIN contract_group cg ON cg.contract_id = d.contract_id
				LEFT JOIN source_uom uom ON uom.source_uom_id = d.uom_id
				LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = dd.upstream_counterparty
				LEFT JOIN contract_group cg1 ON cg1.contract_name= dd.upstream_contract
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + CASE WHEN @flag IN ('m','n') THEN @minor_location WHEN @flag = 'pl' THEN ISNULL(@pool_id,'')+ ISNULL(',' + @pool_location_id,'') ELSE '' END + ''') t
					ON t.item = d.location_id 
					OR (from_loc.proxy_location_id = d.location_id AND ISNULL(from_loc.is_aggregate,''n'') <> ''y'')
				'
				--changes
				SET @sql += CASE WHEN @counterparty_id IS NOT NULL THEN '
						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') tc
							ON tc.item = d.counterparty_id
						' ELSE ' ' END 				
				SET @sql += 'outer apply (
					select sdd.location_id [source_minor_location_id], sml.location_name, smj.location_name [location_type], sml.location_id, sm3.location_id [proxy_location_id],
					sm3.location_name [proxy_location_name]
					from source_deal_detail sdd
					left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id
					left join source_major_location smj on smj.source_major_location_id = sml.source_major_location_id
					left join source_minor_location sm3 on sm3.source_minor_location_id = sml.proxy_location_id
					where sdd.leg = case d.leg when 1 then 2 else 1 end and sdd.source_deal_header_id = d.source_deal_header_id and sdd.term_start = d.term_start 
					 and sdd.physical_financial_flag=''p''
				) ca_leg_loc
				LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.to_source_uom_id = ' + IIF(@volume_conversion IS NULL,'rvuc.to_source_uom_id',CAST(@volume_conversion AS VARCHAR(10))) + ' AND rvuc.from_source_uom_id = dd.deal_volume_uom_id
				WHERE  tm.term_start BETWEEN ''' + CONVERT(varchar, @flow_date_from, 120) + ''' AND ''' + CONVERT(varchar, @flow_date_to_temp, 120) + ''''
				
				SET @sql += CASE WHEN NULLIF(@source_deal_header_ids, '') IS NOT NULL THEN 
									' AND d.source_deal_header_id = ' +  @source_deal_header_ids 
								ELSE 
									'' 
								END				
				SET @sql += '
				GROUP BY 
					d.source_deal_header_id
					, d.priority
					, case when sdht.template_name <> ''' + @transportation_template_name + ''' or d.leg = 1 
						then isnull(nullif(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + isnull('' ['' + d.location_type + '']'', '''')
						else isnull(nullif(ca_leg_loc.location_id, ca_leg_loc.location_name) + ''-'', '''') + ca_leg_loc.location_name + isnull('' ['' + ca_leg_loc.location_type + '']'', '''')
					  end
					--, case when sdht.template_name <> ''' + @transportation_template_name + ''' or d.leg = 1 
					--	then nullif(sm2.location_id, sm2.location_name) 
					--	else nullif(ca_leg_loc.proxy_location_id, ca_leg_loc.proxy_location_name)
					--  end  					  
					, case when sdht.template_name <> ''' + @transportation_template_name + ''' or d.leg = 1 
						then d.location_type 
						else ca_leg_loc.location_type 
					  end
					, case when d.leg = 1 and ca_leg_loc.location_name is not null and sdht.template_name = ''' + @transportation_template_name + '''
						then isnull(nullif(ca_leg_loc.location_id, ca_leg_loc.location_name) + ''-'', '''') + ca_leg_loc.location_name + isnull('' ['' + ca_leg_loc.location_type + '']'', '''')
						else isnull(nullif(from_loc.location_id, from_loc.location_name) + ''-'', '''') + from_loc.location_name + isnull('' ['' + d.location_type + '']'', '''')
					  end
					, case when d.leg = 1 and ca_leg_loc.location_name is not null and sdht.template_name = ''' + @transportation_template_name + ''' 
						then ca_leg_loc.location_type 
						else d.location_type 
					  end--,d.source_deal_detail_id
					, d.leg
					  '  +
						  CASE WHEN @show_zero_volume = 'n' 
						  THEN   ' HAVING SUM(d.position) <> 0 '
						   ELSE  ''  END 

	SET @sql1 = CAST('' AS VARCHAR(MAX)) + '
		DECLARE @from_deal_udf_id INT

		SELECT @from_deal_udf_id = uddft.udf_template_id 
		FROM source_deal_header_template sdht
			INNER JOIN user_defined_deal_fields_template uddft
				ON sdht.template_id = uddft.template_id
		WHERE sdht.template_name = ''' + @transportation_template_name + '''
			AND uddft.Field_label = ''From Deal'''

	If @flag IN ('m','n')
	BEGiN
		SET @sql1 +='
		SELECT MAX(tsc.[proxy_location]) [proxy_location],
			tsc.[Location]  [Location],
			MAX(tsc.[Counterparty]) [Counterparty],
			MAX(tsc.conversion_factor) * ' + CASE WHEN @flag = 'n' THEN 
				'IIF(
					MIN(
						dbo.FNARemoveTrailingZero(
							ROUND(
								ABS(
									tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1)
								)
								,0
							)
						)
					) < 0, 
					0, 
					MIN(
						dbo.FNARemoveTrailingZero(
							ROUND(
								ABS(
									tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1)
								)
								,0
							)
						)
					)
				) '
				ELSE 
				'MIN(
					dbo.FNARemoveTrailingZero(
						ROUND(
							ABS(
								tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1)
							)
							,0
						)
					)
				)'
			END + ' [Total Position],
			MAX(tsc.conversion_factor) * ' + CASE WHEN @flag = 'n' THEN
					'IIF(
						MIN(
							dbo.FNARemoveTrailingZero(
								ROUND(
									ABS(tsc.[Position]) - ABS(ISNULL(sch_max.avail_vol, 0))
									,0
								)
							)
						) < 0, 
						0, 
						MIN(
							dbo.FNARemoveTrailingZero(
								ROUND(
									ABS(tsc.[Position]) - ABS(ISNULL(sch_max.avail_vol, 0))
									,0
								)
							)
						)
					) '
				ELSE 
					'MIN(
						dbo.FNARemoveTrailingZero(
							ROUND(
								ABS(tsc.[Position]) - ABS(ISNULL(sch_max.avail_vol, 0))
								,0
							)
						)
					)'
				END 
				+ ' [Available Volume],
			MAX(tsc.[UOM]) [UOM],
			dbo.FNADateFormat(tsc.term_start) [Term Start],
			MAX(dbo.FNADateFormat(tsc.term_end)) [Term End],
			MAX(tsc.[Location Pipeline]) [Location Pipeline],
			MAX(tsc.[Deal ID]) [Deal ID],
			MAX(tsc.[Contract]) [Contract],
			MAX(tsc.[Nomination Group]) [Nomination Group],	
			MAX(tsc.Priority) Priority,
			MAX(tsc.[Reference ID]) [Reference ID],
			MAX(tsc.[Group]) [Group],						
			MAX(tsc.[Location Type]) [Location Type],	
			MAX(tsc.[To Location]) [To Location],		
			MAX(tsc.[To Location Type]) [To Location Type],						
			MAX(tsc.[From Deal])[From Deal],	
			MAX(tsc.[To Deal]) [To Deal],
			MAX(tsc.[location_id]) [location_id],
			MAX(tsc.[Counterparty ID]) [Counterparty ID],
			MAX(tsc.[proxy_location_id]) [proxy_location_id],
			MAX(tsc.upstream_counterparty) [upstream_counterparty],
			MAX(tsc.[upstream_contract]) [upstream_contract]
		FROM #temp_selected_deals tsc ' + 

		CASE WHEN @flag = 'm' THEN '		
		OUTER APPLY (
			SELECT SUM(volume_used) sch_vol
			from optimizer_detail 
			WHERE source_deal_header_id  = tsc.source_deal_header_id
			AND flow_date BETWEEN tsc.term_start AND tsc.term_end
				and up_down_stream = ''u''
		) sch
		OUTER APPLY (				
			SELECT SUM(volume_used) avail_vol
			FROM optimizer_detail
			WHERE source_deal_header_id = tsc.source_deal_header_id
				AND flow_date BETWEEN tsc.term_start AND tsc.term_end
				AND up_down_stream = ''u''
			GROUP BY source_deal_detail_id				
		) sch_max
		' ELSE '		
		OUTER APPLY (
			SELECT SUM(volume_used) sch_vol
			FROM (
				SELECT DISTINCT od.* 
				FROM optimizer_detail od
				INNER JOIN optimizer_detail_downstream oy ON od.optimizer_header_id = oy.optimizer_header_id
					AND od.flow_date = oy.flow_date
				WHERE oy.source_deal_header_id  = tsc.source_deal_header_id
					AND od.flow_date BETWEEN tsc.term_start AND tsc.term_end
					AND up_down_stream = ''d''
			) a
		) sch
		OUTER APPLY (
			SELECT SUM(oy.deal_volume) avail_vol
			FROM optimizer_detail od
			INNER JOIN optimizer_detail_downstream oy ON od.optimizer_header_id = oy.optimizer_header_id
				AND od.flow_date = oy.flow_date
			WHERE oy.source_deal_header_id  = tsc.source_deal_header_id
				AND od.flow_date BETWEEN tsc.term_start AND tsc.term_end
				AND up_down_stream = ''d''
			GROUP BY oy.flow_date
		) sch_max
		'
		END 
		+
		'
		WHERE 1=1
		GROUP BY [Location],tsc.term_start,[reference id]
		'  +
		CASE WHEN @show_zero_volume = 'n' THEN   
			CASE WHEN @flag = 'm'	
				THEN	
					'HAVING MIN(
						dbo.FNARemoveTrailingZero(
							ROUND(
								ABS(
									tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1)
								) - ABS(ISNULL(sch.sch_vol, 0))
								,0
							)
						)
					) <> 0 '
				ELSE  
					'HAVING MIN(
						dbo.FNARemoveTrailingZero(
							ROUND(
								ABS(tsc.[Position]) - ABS(ISNULL(sch_max.avail_vol, 0))
								,0
							)
						)
					) > 0'
			END
		ELSE  ''  
		END + 
		' ORDER BY [Location],[Term Start],[reference id] '
	END
	ELSE IF @flag = 'pl'
	BEGiN
		SET @spa = 'EXEC spa_flow_optimization ''p'', '
		+ CASE WHEN @sub IS NULL THEN 'NULL' ELSE '''' + @sub + '''' END + ',' 
		+ CASE WHEN @str IS NULL THEN 'NULL' ELSE '''' + @str + '''' END + ',' 
		+ CASE WHEN @book IS NULL THEN 'NULL' ELSE '''' + @book + '''' END + ',' 
		+ CASE WHEN @commodity IS NULL THEN 'NULL' ELSE '''' + CAST(@commodity AS VARCHAR(30)) + '''' END + ',' 
		+ CASE WHEN @receipt_delivery IS NULL THEN 'NULL' ELSE '''' + @receipt_delivery + '''' END + ',' 
		+ CASE WHEN @daily_rolling IS NULL THEN 'NULL' ELSE '''' + @daily_rolling + '''' END + ',' 
		+ CASE WHEN @round IS NULL THEN 'NULL' ELSE '''' + CAST(@round AS VARCHAR(20)) + '''' END + ','
		+ CASE WHEN @flow_date_from IS NULL THEN 'NULL' ELSE '''' + CONVERT(VARCHAR(10), @flow_date_from, 120) + '''' END + ',' 
		+ CASE WHEN NULLIF(@major_location,'') IS NULL THEN 'NULL' ELSE '''' + @major_location + '''' END + ',' 
		+ CASE WHEN @minor_location IS NULL THEN 'NULL' ELSE '''' + '#location_id#' + '''' END + ','
		+ CASE WHEN @from_location IS NULL THEN 'NULL' ELSE CAST(@from_location AS VARCHAR(30)) END + ',' 
		+ CASE WHEN @to_location IS NULL THEN 'NULL' ELSE CAST(@to_location AS VARCHAR(30)) END + ',' 
		+ CASE WHEN @path_priority IS NULL THEN 'NULL' ELSE CAST(@path_priority AS VARCHAR(30)) END + ',' 
		+ CASE WHEN @opt_objective IS NULL THEN 'NULL' ELSE '''' + CAST(@opt_objective AS VARCHAR(30)) + '''' END + ',' 
		+ CASE WHEN @process_id IS NULL THEN 'NULL' ELSE '''' + @process_id + '''' END + ',' 
		+ CASE WHEN @priority_from IS NULL THEN 'NULL' ELSE '''' + CAST(@priority_from AS VARCHAR(20)) + '''' END + ',' 
		+ CASE WHEN @priority_to IS NULL THEN 'NULL' ELSE   CAST(@priority_to AS VARCHAR(30))  END + ','
		+ CASE WHEN NULLIF(@contract_id,'') IS NULL THEN 'NULL' ELSE @contract_id END + ',' 
		+ CASE WHEN NULLIF(@pipeline_ids,'') IS NULL THEN 'NULL' ELSE @pipeline_ids END + ',' 
		+ CASE WHEN @xml_manual_vol IS NULL THEN 'NULL' ELSE @xml_manual_vol END + ',' 
		+ CASE WHEN @flow_date_to IS NULL THEN 'NULL' ELSE '''' + CONVERT(VARCHAR(10), @flow_date_to, 120) + '''' END + ',' 
		+ CASE WHEN @sub_book_id IS NULL THEN 'NULL' ELSE '''' + @sub_book_id + '''' END + ',' 
		+ CASE WHEN @uom IS NULL THEN 'NULL' ELSE '''' + CONVERT(VARCHAR(10), @uom, 120) + '''' END + ',' 
		+ CASE WHEN @source_deal_header_ids IS NULL THEN 'NULL' ELSE   '''' + @source_deal_header_ids + ''''  END + ','
		+ CASE WHEN @show_zero_volume IS NULL THEN 'NULL' ELSE CAST(@show_zero_volume AS VARCHAR(30)) END + ','
		+ CASE WHEN @delivery_path IS NULL THEN 'NULL' ELSE CAST(@delivery_path AS VARCHAR(30)) END + ',' 
		+ CASE WHEN @hide_pos_zero IS NULL THEN 'NULL' ELSE CAST(@hide_pos_zero AS VARCHAR(30)) END + ',' 
		+ CASE WHEN @reschedule IS NULL THEN 'NULL' ELSE '''' + CAST(@reschedule AS VARCHAR(30)) + '''' END


		SET @sql1 +='
		SELECT	MAX(COALESCE(mjr_proxy.location_name, tbl.[location_type])) [location_type],
				MAX(COALESCE(sml_proxy.location_name, tbl.[Location])) [Location],
				COALESCE(sml_proxy.source_minor_location_id, tbl.[location_id]) [location_id],
				MAX(tbl.[Term Start]) [Term Start],
				MAX(tbl.[Term End]) [Term End],
				''<span style="cursor: pointer;" onclick="open_spa_html_window(''''Optimizer Position Detail'''', &quot;'' + REPLACE('''+ Replace(@spa,'''','''''')+''',''#location_id#'',MAX(tbl.[location_id])) + ''&quot;, 600, 1200)"><font color="#0000ff"><u>''+[dbo].[FNANumberFormat](CAST(SUM(tbl.[Total Position]) AS NUMERIC(20,2)),''v'')+''</u></font></span>'' 
				[Total Position],
				MAX(tbl.[UOM]) [UOM],
				STUFF((SELECT DISTINCT '', '' + CAST(IIF(t1.header_buy_sell_flag= ''b'', t1.source_deal_header_id, 1*t1.source_deal_header_id) AS VARCHAR(20))
						FROM #temp_selected_deals t1
						WHERE t1.[location_id] = MAX(tbl.[location_id])
						FOR XML PATH(''''), TYPE
						).value(''.'', ''NVARCHAR(MAX)'') 
					, 1, 2, '''') [source_deal_header_id]
				INTO #location_with_deal
		FROM (
			SELECT	MAX(smj.location_name) [location_type],
					MAX(sml.[Location_Name]) [Location],
					dbo.FNADateFormat(tsc.term_start) [Term Start],
					MAX(dbo.FNADateFormat(tsc.term_end)) [Term End],
					MAX(tsc.conversion_factor) * 1 * MIN(dbo.FNARemoveTrailingZero(tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1))) [Total Position],
					MAX(tsc.[UOM]) [UOM],
					tsc.[location_id],
					MAX(tsc.source_deal_header_id) [source_deal_header_id],
					MAX(tsc.Contract_ID) [Contract_ID]					
			FROM #temp_selected_deals tsc
			INNER JOIN source_minor_location sml
				ON sml.source_minor_location_id = tsc.[location_id]
			INNER JOIN source_major_location smj
				ON smj.source_major_location_id = sml.source_major_location_id
			OUTER APPLY (
				SELECT SUM(volume_used) sch_vol
				FROM optimizer_detail 
				WHERE source_deal_header_id  = tsc.source_deal_header_id
				AND flow_date BETWEEN tsc.term_start AND tsc.term_end
					AND up_down_stream = ''u''
			) sch
			OUTER APPLY (				
				SELECT MAX(volume_used) avail_vol
				FROM optimizer_detail
				WHERE source_deal_header_id = tsc.source_deal_header_id
					AND flow_date BETWEEN tsc.term_start AND tsc.term_end
					AND up_down_stream = ''u''
				GROUP BY source_deal_detail_id				
			) sch_max
			WHERE 1=1 AND tsc.header_buy_sell_flag = ''b''
			GROUP BY tsc.[location_id], tsc.term_start, [reference id]
		' + CASE WHEN @show_zero_volume = 'n' THEN   ' HAVING MIN(dbo.FNARemoveTrailingZero(tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1))) <> 0 '			
				 ELSE ''  
			END 
		+ '
			UNION ALL
			SELECT	MAX(smj.location_name) [location_type],
					MAX(sml.[Location_Name]) [Location],
					dbo.FNADateFormat(tsc.term_start) [Term Start],
					MAX(dbo.FNADateFormat(tsc.term_end)) [Term End],
					MAX(tsc.conversion_factor) * 1 * MIN(dbo.FNARemoveTrailingZero(tsc.[Position] * (DATEDIFF ( DAY , tsc.term_start , tsc.term_end ) + 1))) [Total Position],
					MAX(tsc.[UOM]) [UOM],
					tsc.[location_id],
					MAX(tsc.source_deal_header_id) source_deal_header_id,
					MAX(tsc.Contract_ID) [Contract_ID]		 			
			FROM #temp_selected_deals tsc
			INNER JOIN source_minor_location sml
				ON sml.source_minor_location_id = tsc.[location_id]
			INNER JOIN source_major_location smj
				ON smj.source_major_location_id = sml.source_major_location_id
			OUTER APPLY (
				SELECT SUM(volume_used) sch_vol
				FROM (
					SELECT DISTINCT od.* 
					FROM optimizer_detail od
					INNER JOIN optimizer_detail_downstream oy
						ON od.optimizer_header_id = oy.optimizer_header_id
						AND od.flow_date = oy.flow_date
					WHERE oy.source_deal_header_id  = tsc.source_deal_header_id
						AND od.flow_date BETWEEN tsc.term_start AND tsc.term_end
						AND up_down_stream = ''d''
				) a
			) sch
			OUTER APPLY (
				SELECT SUM(oy.deal_volume) avail_vol
				FROM optimizer_detail od
				INNER JOIN optimizer_detail_downstream oy
					ON od.optimizer_header_id = oy.optimizer_header_id
					and od.flow_date = oy.flow_date
				WHERE oy.source_deal_header_id  = tsc.source_deal_header_id
				AND od.flow_date BETWEEN tsc.term_start AND tsc.term_end
					and up_down_stream = ''d''
				GROUP BY oy.flow_date
			) sch_max
			WHERE 1=1 AND tsc.header_buy_sell_flag = ''s''
			GROUP BY tsc.[location_id],tsc.term_start,[reference id]
		' + CASE WHEN @show_zero_volume = 'n' THEN   ' HAVING MIN(dbo.FNARemoveTrailingZero(tsc.[Position])) <> 0 '			
				 ELSE ''  
			END 
			+ '
		) tbl
		INNER JOIN source_minor_location sml_main
			ON sml_main.source_minor_location_id = tbl.[location_id]
		LEFT JOIN source_minor_location sml_proxy
			ON sml_proxy.source_minor_location_id = sml_main.proxy_location_id
		LEFT JOIN source_major_location mjr_proxy
			ON mjr_proxy.source_major_location_id = sml_proxy.source_major_location_id
		GROUP BY COALESCE(sml_proxy.source_minor_location_id, tbl.[location_id])
		
		SELECT	lwd.[location_type],
				lwd.[Location],
				lwd.[location_id],
				lwd.[Term Start],
				lwd.[Term End],
				lwd.[Total Position],
				lwd.[UOM],
				lwd.[source_deal_header_id]
		FROM #location_with_deal lwd
		UNION ALL
		SELECT	DISTINCT COALESCE(mjr_proxy.location_name, smj.location_name)
				, COALESCE(sml_proxy.location_name, sml.location_name)
				, COALESCE(sml_proxy.source_minor_location_id, sml.source_minor_location_id)
				,''' + CAST(dbo.fnadateformat(@flow_date_from) AS VARCHAR(10)) + '''
				,''' +  CAST(dbo.fnadateformat(ISNULL(@flow_date_to_temp,@flow_date_from)) AS VARCHAR(10)) + '''
				, ''0''
				, tbl.uom_id
				, NULL
		FROM 
		dbo.splitCommaSeperatedValues(''' + @pool_id +''') t
		INNER JOIN source_minor_location sml
			ON sml.source_minor_location_id = t.item
		INNER JOIN source_major_location smj
			ON smj.source_major_location_id = sml.source_major_location_id
		LEFT JOIN source_minor_location sml_proxy
			ON sml_proxy.source_minor_location_id = sml.proxy_location_id
		LEFT JOIN source_major_location mjr_proxy
			ON mjr_proxy.source_major_location_id = sml_proxy.source_major_location_id
		OUTER APPLY(
			SELECT uom_id
			FROM source_uom
			WHERE source_uom_id = ''' + CAST(ISNULL(@uom, '') AS VARCHAR(20)) + '''  
		) tbl
		WHERE sml.source_minor_location_id NOT IN (
			SELECT location_id FROM #location_with_deal --exclude locations already grabbed based on deal in #location_with_deal
			UNION
			SELECT sml1.source_minor_location_id --exclude child locations of locations that are grabbed on #location_with_deal
			FROM source_minor_location sml1
			INNER JOIN #location_with_deal lwd1 ON lwd1.location_id = sml1.proxy_location_id
		)
	'
	END
	
	--print @sql
	--print @sql1

	EXEC(@sql + @sql1)

END
ELSE IF @flag = 'x' --To get sum of other volumes on optimization grid box of given contract, path, box for contract validation
BEGIN
	SET @sql = 'SELECT  cd.contract_id, ISNULL(SUM(received), 0) compare_volume
				FROM ' + @contractwise_detail_mdq + ' cd
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @contract_id + ''') t
					ON t.item = cd.contract_id
				WHERE cd.path_id <> ' + CAST(@delivery_path AS VARCHAR(10)) + 
					' AND cd.box_id <> ' + @xml_manual_vol + '
				GROUP BY cd.contract_id'
	EXEC(@sql)
END
else if @flag = 'd' --To get destination sub book values for save schedule
begin
	declare @dest_sub_book int

	select @dest_sub_book = gmv.clm1_value 
	from generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmv.mapping_table_id 
		AND gmh.mapping_name = 'Flow Optimization Mapping'

	if OBJECT_ID('tempdb..#tmp_sub_book') is not null
		drop table #tmp_sub_book
	
	CREATE TABLE #tmp_sub_book (id INT
		, group1 VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)

	insert into #tmp_sub_book(id, group1)
	EXEC spa_GetAllSourceBookMapping @hedge_rel_type_flag='s'

	SELECT t.id [value]
		, t.group1 [text]
		, CASE WHEN @dest_sub_book = t.id THEN 'true' ELSE 'false' END [selected]
	from #tmp_sub_book t
end
ELSE IF @flag = 'w'
BEGIN
	SET @sql = CAST('' AS VARCHAR(MAX)) + '
	
	SELECT  
		tm.term_start,	
		sum(d.position)  [Position]
	--INTO ' + @avail_volume_breakdowm + '	
	FROM ' + @opt_deal_detail_pos + ' d
	INNER JOIN source_deal_detail dd 
		ON dd.location_id=d.location_id 
		AND dd.source_deal_detail_id = d.source_deal_detail_id  
		AND dd.physical_financial_flag=''p''
	INNER JOIN #deal_term_breakdown tm 
		ON dd.source_deal_detail_id=tm.source_deal_detail_id
	INNER JOIN source_minor_location from_loc 
		ON from_loc.source_minor_location_id = d.location_id
	OUTER APPLY (
				SELECT SUM(volume_used) sch_vol
				FROM optimizer_detail 
				WHERE source_deal_header_id  = d.source_deal_header_id
					AND flow_date = tm.term_start
					AND up_down_stream = ''u''
				GROUP BY source_deal_header_id, flow_date
			) sch
	WHERE d.location_id = ' + @minor_location + '-- or (from_loc.proxy_location_id = ' + @minor_location + ' and from_loc.is_aggregate = ''y'')
		AND d.term_start BETWEEN ''' + CAST(dbo.FNAGetFirstLastDayOfMonth( @flow_date_from, 'f') AS VARCHAR(20)) + ''' AND ''' + CAST(dbo.FNAGetFirstLastDayOfMonth(@flow_date_to_temp, 'l') AS VARCHAR(20)) + '''
		AND d.source_deal_header_id IN (' + @source_deal_header_ids + ')
	GROUP BY tm.term_start
	ORDER BY tm.term_start
	'
	EXEC(@sql)
END
ELSE IF @flag = 'h' --Get period_from period_to combo values on flow optimization ui as granularity value selected
BEGIN
	IF @granularity = 989 --30 min
	BEGIN
		SELECT ROW_NUMBER() OVER (
				ORDER BY n
				) [value]
			,REPLACE(STR(n - 1, 2), ' ', '0') + brk_min.label [30min]
		FROM seq s
		CROSS JOIN (
			SELECT ':00' [label]
				,0 [value]
			
			UNION ALL
			
			SELECT ':30' [label]
				,1 [value]
			) brk_min
		WHERE s.n <= 24
	END
	ELSE IF @granularity = 987 --15 min
	BEGIN
		SELECT ROW_NUMBER() OVER (
				ORDER BY n
				) [value]
			,REPLACE(STR(n - 1, 2), ' ', '0') + brk_min.label [30min]
		FROM seq s
		CROSS JOIN (
			SELECT ':00' [label]
				,0 [value]
			
			UNION ALL
			
			SELECT ':15' [label]
				,1 [value]
			
			UNION ALL
			
			SELECT ':30' [label]
				,2 [value]
			
			UNION ALL
			
			SELECT ':45' [label]
				,3 [value]
			) brk_min
		WHERE s.n <= 24
	END
	ELSE
	BEGIN --hourly
		SELECT n [value]
			,REPLACE(STR(n, 2), ' ', '0') + ':00' [label]
		FROM seq s
		WHERE s.n <= 24
	END
END
ELSE IF @flag = 'b'
BEGIN

	--DECLARE @xml_manual_vol VARCHAR(MAX) 

	--SET @xml_manual_vol = '<param flow_date_from = "2020-08-01" flow_date_to = "2020-08-01" from_group_loc_id = "3" to_group_loc_id = "3007,3008,3010" from_location = "3006" to_location= "3007,3008,3010" granularity = "981" uom = "6"></param>'


	DECLARE @xml_param INT
	DECLARE @from_group_loc VARCHAR(8000)
	DECLARE @to_group_loc VARCHAR(8000)


	EXEC sp_xml_preparedocument @xml_param OUTPUT, @xml_manual_vol
	

	SELECT @flow_date_from = flow_date_from,
		   @flow_date_to = flow_date_to,
		   @from_group_loc = from_group_loc,
		   @to_group_loc = to_group_loc,
		   @from_location = from_location,
		   @to_location = to_location,
		   @granularity = granularity,
		   @uom = uom
	FROM OPENXML(@xml_param,'/param',2)
	WITH (
		flow_date_from		DATETIME		'@flow_date_from',
		flow_date_to		DATETIME		'@flow_date_to',
		from_group_loc		VARCHAR(8000)	'@from_group_loc_id',
		to_group_loc		VARCHAR(8000)	'@from_group_loc_id',
		from_location		VARCHAR(8000)	'@from_location',
		to_location			VARCHAR(8000)	'@to_location',
		granularity			INT				'@granularity',
		uom					INT				'@uom'

	)

	EXEC spa_flow_optimization  @flag='l'
								,@receipt_delivery='FROM'
								,@flow_date_from = @flow_date_from
								,@flow_date_to = @flow_date_to
								,@major_location = @from_group_loc
								,@minor_location = @from_location
								,@from_location = @from_location
								,@to_location = @to_location
								,@uom = @uom
								,@granularity = @granularity
								,@call_from = 'HIDE_OUTPUT'
								,@output_process_id = @process_id OUTPUT
	

	EXEC spa_flow_optimization  @flag='l'
								,@receipt_delivery='TO'
								,@flow_date_from = @flow_date_from
								,@flow_date_to = @flow_date_to
								,@major_location = @to_group_loc
								,@minor_location = @to_location
								,@from_location = @from_location
								,@to_location = @to_location
								,@uom = @uom
								,@granularity = @granularity
								,@process_id = @process_id
								,@call_from = 'HIDE_OUTPUT'
	
	EXEC spa_flow_optimization  @flag='c'
								,@flow_date_from=@flow_date_from
								,@flow_date_to=@flow_date_to
								,@from_location=@from_location
								,@to_location=@to_location
								,@uom=@uom
								,@granularity=@granularity
								,@process_id=@process_id
								,@call_from = 'HIDE_OUTPUT'
								

	SELECT @process_id process_id


END
ELSE IF @flag = 'a'
BEGIN
	DROP TABLE IF EXISTS #temp_required_location_ids
	CREATE TABLE #temp_required_location_ids(location_id INT)

	-- Get Proxy Locations of the selected location
	DECLARE @child_locations VARCHAR(2000) = NULL
	SELECT @child_locations = STUFF(
				(   SELECT DISTINCT ',' + CAST(sml.source_minor_location_id AS VARCHAR(10))
					FROM source_minor_location sml
					INNER JOIN dbo.SplitCommaSeperatedValues(@minor_location) scsv
						ON scsv.item = sml.proxy_location_id
					LEFT JOIN dbo.SplitCommaSeperatedValues(@minor_location) m
						ON sml.source_minor_location_id = m.item
					WHERE m.item IS NULL   
					FOR XML PATH('')
					)
			, 1, 1, '')

	IF @child_locations IS NOT NULL
			SET @minor_location += ',' + @child_locations
	
	-- Get Releated Locations of the selected location
	SET @sql = '
		INSERT INTO #temp_required_location_ids
		SELECT DISTINCT ' + IIF(@call_from = 'receipt' , 'to_location', 'from_location') + ' [location_id]
		FROM delivery_path 
		WHERE ' + IIF(@call_from = 'receipt' , 'from_location', 'to_location') + ' IN (' + @minor_location + ')'

	IF @call_from = 'storage' OR @call_from = 'pool'
	BEGIN
		SET @sql += '
			UNION
			SELECT DISTINCT to_location
			FROM delivery_path
			WHERE from_location IN (' + @minor_location + ')
		'
	END

	EXEC(@sql)

	-- Get Proxy locations of the Related Locations
	INSERT INTO #temp_required_location_ids
	SELECT proxy_location_id
	FROM source_minor_location sml
	INNER JOIN #temp_required_location_ids trl
		ON trl.location_id = sml.source_minor_location_id

	SELECT ISNULL(STUFF(
		(
			SELECT ',' + CAST(location_id AS VARCHAR(100))
			FROM #temp_required_location_ids
			FOR XML PATH('')
		)
		, 1, 1, ''), '') [location_id]
END
ELSE IF @flag = 'e'
BEGIN
	SELECT STUFF(
				(   SELECT DISTINCT ',' + CAST(sml.source_minor_location_id AS VARCHAR(10))
					FROM source_minor_location sml
					INNER JOIN dbo.SplitCommaSeperatedValues(@from_location) scsv
						ON scsv.item = sml.proxy_location_id
					LEFT JOIN dbo.SplitCommaSeperatedValues(@from_location) m
						ON sml.source_minor_location_id = m.item
					WHERE m.item IS NULL   
					FOR XML PATH('')
					)
			, 1, 1, '') [receipt_child_location],
			STUFF(
				(   SELECT DISTINCT ',' + CAST(sml.source_minor_location_id AS VARCHAR(10))
					FROM source_minor_location sml
					INNER JOIN dbo.SplitCommaSeperatedValues(@to_location) scsv
						ON scsv.item = sml.proxy_location_id
					LEFT JOIN dbo.SplitCommaSeperatedValues(@to_location) m
						ON sml.source_minor_location_id = m.item
					WHERE m.item IS NULL   
					FOR XML PATH('')
					)
			, 1, 1, '') [delivery_child_location]
END