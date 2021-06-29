IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_flow_optimization_hourly]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_flow_optimization_hourly]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Gas Scheduling related operations for menu Flow Optimization for hourly case.
	Parameters
	@flag						: Flag
								  'l' Extract receipt location and delivery location with positions for flow optimization grid
								  'c' Extract optimizer grid cell information(path mdq, path rmdq, etc) for flow optimization grid
								  'r' Firing run solver with SSIS solver package and filling up optimizer grid cell information
								  'y' Extracting path and contract level information to load on path list of outer popup and inner popup
								  'q' Filling up Contract Detail information on Main Popup on Optimization Grid
								  'p' For position report drill on begining inverntory optimization grid
								  'x' To get sum of other volumes on box of given contract, path, box for contract validation.
								  'd' Load combo options of subbook while manual scheduling when generic mapping 'Flow Optimization Mapping' is not defined.
								  'p1' Load path on Flow Opt hourly scheduling UI 
								  'c1' Load path on Flow Opt hourly scheduling UI 
								  'h1' Call from flow opt hourly scheduling grid load, ins
								  'h2' Call from flow opt hourly scheduling grid load
								  's1' Subgrid load on hourly scheduling flow optimization
								  's2' Save manual schedule subgrid hourly data
								  
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
	@path_ids					: Path Ids list
	@batch_process_id			: Batch Process Id
	@batch_report_param			: Batch Report Param
	@enable_paging				: Enable Paging flag
*/
CREATE PROCEDURE [dbo].[spa_flow_optimization_hourly]
	@flag VARCHAR(50),
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
	@path_ids VARCHAR(1000) = NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL   ,
	@enable_paging INT = NULL,   --'1'=enable, '0'=disable
	@dst_case TINYINT = 0
AS 
SET NOCOUNT ON
/*

declare @flag CHAR(50),
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
	@path_ids VARCHAR(1000) = NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL   ,
	@enable_paging INT = NULL,   --'1'=enable, '0'=disable
	@dst_case TINYINT = 0
	
EXEC dbo.spa_drop_all_temp_table

EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'sligal';

select @flag='s2', @process_id='8808A377_01EE_4DF9_A5FF_82DECB240017', @xml_manual_vol='<Root><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="1" is_dst="0" received="10.0000" delivered="10.0000" path_rmdq="990.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="2" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="3" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="4" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="5" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="6" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="7" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="8" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="9" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="10" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="11" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="12" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="13" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="14" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="15" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="16" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="17" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="18" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="19" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="20" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="21" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="22" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="23" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset><PSRecordset from_loc_id="2959" to_loc_id="2960" path_id="364" contract_id="8534" hour="24" is_dst="0" received="" delivered="" path_rmdq="1000.0000" storage_asset_id="26"></PSRecordset></Root>', @call_from='flow_optimization'
--*/

SELECT @sub = NULLIF(NULLIF(@sub, ''), 'NULL')
	, @str = NULLIF(NULLIF(@str, ''), 'NULL')
	, @book = NULLIF(NULLIF(@book, ''), 'NULL')
	, @sub_book_id = NULLIF(NULLIF(@sub_book_id, ''), 'NULL')
	, @contract_id = NULLIF(NULLIF(@contract_id, ''), 'NULL')
	, @counterparty_id = NULLIF(NULLIF(@counterparty_id, ''), 'NULL')    
	, @period_from = ISNULL(NULLIF(@period_from,''),'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25')
	, @pipeline_ids = NULLIF(NULLIF(@pipeline_ids, ''), 'NULL')
	, @receipt_deals_id = NULLIF(NULLIF(@receipt_deals_id, ''), 'NULL')
	, @delivery_deals_id = NULLIF(NULLIF(@delivery_deals_id, ''), 'NULL')
	, @commodity = NULLIF(NULLIF(@commodity, ''), 'NULL')
	, @from_location = NULLIF(NULLIF(@from_location, ''), 'NULL')
	, @to_location = NULLIF(NULLIF(@to_location, ''), 'NULL')
	, @pool_location_id = NULLIF(NULLIF(@pool_location_id, ''), 'NULL')
	, @pool_id = NULLIF(NULLIF(@pool_id, ''), 'NULL')

--logic flag for proxy, there are two separate logic of proxy on behalf of child proxy and behalf of parent proxy. one logic is applied according to flag.
DECLARE @proxy_logic_side CHAR(1) = 'p' --p=>parent proxy logic
DECLARE @spa VARCHAR(MAX)
DECLARE @sql VARCHAR(MAX)
DECLARE @gas_hour_display TINYINT = 1 -- gas hour starts from 7th hour
--temp fix, to minimize the change for range of terms
--2016-10-25
DECLARE @flow_date_to_temp DATETIME = @flow_date_to
--set @flow_date_to = @flow_date_from

--temp fix

DECLARE @batch_flag INT = 1

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
SELECT @priority_from = sdv.code FROM static_data_value sdv WHERE sdv.value_id = @priority_from
SELECT @priority_to = sdv.code FROM static_data_value sdv WHERE sdv.value_id = @priority_to
/* SETTING PRIORITY CODE END */

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
DECLARE @deal_detail_info VARCHAR(500) = dbo.FNAProcessTableName('deal_detail_info', @user_login_id, @process_id)
DECLARE @contractwise_detail_mdq_hourly VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq_hourly', @user_login_id, @process_id)
DECLARE @contractwise_detail_mdq_hourly_fresh VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq_hourly_fresh', @user_login_id, @process_id)
DECLARE @flag_c_result VARCHAR(500) = dbo.FNAProcessTableName('flag_c_result', @user_login_id, @process_id)

SET @sql = '
			IF OBJECT_ID(''' + @storage_position + ''') IS NULL				
			BEGIN
				CREATE TABLE  ' + @storage_position + ' (
					type			CHAR(1),				
					location_id		INT,				
					position		NUMERIC(38,20)
				
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

DECLARE @transportation_template_name VARCHAR(200) = 'Transportation NG'
DECLARE @transportation_template_id INT
DECLARE @transportation_deal_type_value_id INT = 13

SELECT @transportation_template_id = template_id  
FROM source_deal_header_template 
WHERE template_name = @transportation_template_name

--IF @delivery_path IS NOT NULL 
--BEGIN
--	SELECT	@from_location =  from_location, 
--			@to_location =  to_location 
--	FROM delivery_path 
--	WHERE path_id = @delivery_path
--END

DECLARE @deal_status_void INT
SELECT @deal_status_void = sdv.value_id
FROM static_data_value sdv
WHERE sdv.code = 'Void' 
	AND sdv.type_id = 5600

DECLARE @rounding_value VARCHAR(2) = '4'

IF @flag IN ('l','c','p')
BEGIN

	/* FILTER PORTFOLIO START */
	--print 'FILTER PORTFOLIO START: ' + convert(VARCHAR(50),getdate() ,21)
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
				+ CASE WHEN  @sub_book_id IS NULL OR @sub_book_id = '' THEN '' ELSE ' AND sbm.book_deal_type_map_id IN (' + @sub_book_id + ')' END			
		
	EXEC(@sql)

	IF @flag = 'c' OR @call_from = 'single_match'
	BEGIN
		SET @minor_location = LTRIM(RTRIM(ISNULL(@from_location, '-1') + ISNULL(',' + @to_location, '')))
		
		--remove duplicates
		SELECT @minor_location = STUFF(
			(SELECT DISTINCT ',' + item FROM dbo.SplitCommaSeperatedValues(@minor_location) FOR XML PATH(''))
		, 1, 1, '')
	END
	
	DECLARE @proxy_locs VARCHAR(2000)
	DECLARE @child_proxy_locs VARCHAR(4000)
	DECLARE @child_proxy_from VARCHAR(4000)
	DECLARE @child_proxy_to VARCHAR(4000)

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
	
	--derive child proxy locations of from and to locations separately
	IF @from_location IS NOT NULL
	BEGIN
		SELECT @child_proxy_from = STUFF(
			(SELECT DISTINCT ',' + CAST(sml.source_minor_location_id AS VARCHAR(10))
			FROM source_minor_location sml
			INNER JOIN dbo.SplitCommaSeperatedValues(@from_location) scsv
				ON scsv.item = sml.proxy_location_id
			FOR XML PATH(''))
		, 1, 1, '')
	END
	IF @to_location IS NOT NULL
	BEGIN
		SELECT @child_proxy_to = STUFF(
			(SELECT DISTINCT ',' + CAST(sml.source_minor_location_id AS VARCHAR(10))
			FROM source_minor_location sml
			INNER JOIN dbo.SplitCommaSeperatedValues(@to_location) scsv
				ON scsv.item = sml.proxy_location_id
			FOR XML PATH(''))
		, 1, 1, '')
	END

	--SELECT @minor_location,@proxy_locs, @child_proxy_locs, @child_proxy_from, @child_proxy_to
	--return
	/* FILTER PORTFOLIO END */
	--print 'FILTER PORTFOLIO END: ' + convert(VARCHAR(50),getdate() ,21)

	--deal term breakdown
	IF @flag NOT IN ('m', 'n')	
	BEGIN
		--calculate deal term breakdown and store breakdown information on temp table
		BEGIN
			CREATE TABLE #deal_term_breakdown(
				source_deal_detail_id INT
				, term_start DATETIME
				, term_end DATETIME
				, proxy_record VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
				, location_id INT NULL
				, source_deal_header_id INT
				, curve_id INT NULL
			)

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
				--print 'DETAIL TERM BREAKDOWN #source_deal_header S: ' + convert(VARCHAR(50),getdate() ,21)
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
						AND (
							(@flow_date_from BETWEEN dd.term_start AND dd.term_end) 
							OR (ISNULL(@flow_date_to, @flow_date_from) BETWEEN dd.term_start AND dd.term_end)
						)
						--AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
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
					INNER JOIN dbo.SplitCommaSeperatedValues(@commodity) com ON com.item = sdh.commodity_id
					WHERE 1 = 1
						AND dd.physical_financial_flag='p'
						AND (ISNULL(@reschedule, 0) = 0 OR (ISNULL(sdh.internal_deal_type_value_id, -1) <> @transportation_deal_type_value_id AND sdh.template_id <> @transportation_template_id))
						AND sdh.deal_status <> @deal_status_void
				END 
				--print 'DETAIL TERM BREAKDOWN #source_deal_header Rec: ' + convert(VARCHAR(50),getdate() ,21)
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
						AND (
							(@flow_date_from BETWEEN dd.term_start AND dd.term_end) 
							OR (ISNULL(@flow_date_to, @flow_date_from) BETWEEN dd.term_start AND dd.term_end)
						)
						--AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
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
					INNER JOIN dbo.SplitCommaSeperatedValues(@commodity) com ON com.item = sdh.commodity_id
					WHERE 1 = 1
						AND dd.physical_financial_flag='p'
						AND (ISNULL(@reschedule, 0) = 0 OR (ISNULL(sdh.internal_deal_type_value_id, -1) <> @transportation_deal_type_value_id AND sdh.template_id <> @transportation_template_id))
						AND sdh.deal_status <> @deal_status_void
					GROUP BY sdh.source_deal_header_id ,sdh.template_id,sdh.source_system_book_id1,sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4 ,sdh.internal_deal_type_value_id, sdh.term_frequency   
				END 
			END
			--print 'DETAIL TERM BREAKDOWN #source_deal_header Del: ' + convert(VARCHAR(50),getdate() ,21)
			
			INSERT INTO #deal_term_breakdown(source_deal_detail_id,term_start,term_end,proxy_record,location_id,source_deal_header_id,curve_id)
			
			SELECT source_deal_detail_id,tm.[term_start], tm.[term_start] [term_end],scsv.proxy_record,dd.location_id,MAX(dd.source_deal_header_id),MAX(dd.curve_id)

			--select dd.*
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
				--SELECT DATEADD(DAY, n - 1, dd.term_start) term_start, DATEADD(DAY, n - 1, dd.term_start) term_end  
				--FROM seq 
				--WHERE dd.term_end >= DATEADD(DAY, n - 1, dd.term_start) --AND dd.term_start <> dd.term_end
				--	AND (
				--		(@flow_date_from BETWEEN dd.term_start AND dd.term_end) 
				--		OR (ISNULL(@flow_date_to, @flow_date_from) BETWEEN dd.term_start AND dd.term_end)
				--	)
				--	--AND dd.term_start BETWEEN 
				--	--	CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) 
				--	--	ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
				--	AND dd.physical_financial_flag='p'

					select c.[sql_date_value] [term_start]--, c.[sql_date_value] [sql_date_value]
					from date_details c
					where c.[sql_date_value] between dd.term_start and dd.term_end
						and c.[sql_date_value] between @flow_date_from and @flow_date_to
						and dd.physical_financial_flag='p'
			) tm
			LEFT JOIN optimizer_header oh ON oh.transport_deal_id = dd.source_deal_header_id
			WHERE  tm.[term_start] BETWEEN @flow_date_from 
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
			GROUP BY source_deal_detail_id,tm.[term_start],scsv.proxy_record,dd.location_id

			--print 'DETAIL TERM BREAKDOWN Mid: ' + convert(VARCHAR(50),getdate() ,21)
			
			UNION
			SELECT source_deal_detail_id,tm.[term_start], tm.[term_start] [term_end],scsv.proxy_record,dd.location_id,MAX(dd.source_deal_header_id),MAX(dd.curve_id)
			from source_deal_detail dd (nolock)
			INNER JOIN source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = dd.source_deal_header_id
				AND (
					(@flow_date_from BETWEEN dd.term_start AND dd.term_end) 
					OR (ISNULL(@flow_date_to, @flow_date_from) BETWEEN dd.term_start AND dd.term_end)
				)
				AND dd.physical_financial_flag='p'
				AND sdh.deal_status <> @deal_status_void
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
			INNER JOIN dbo.SplitCommaSeperatedValues(@commodity) com ON com.item = sdh.commodity_id
			OUTER APPLY (
				--SELECT DATEADD(DAY, n - 1, dd.term_start) term_start, DATEADD(DAY, n - 1, dd.term_start) term_end  
				--FROM seq 
				--WHERE dd.term_end >= DATEADD(DAY, n - 1, dd.term_start) --AND dd.term_start <> dd.term_end
				--	--AND dd.term_start BETWEEN CASE WHEN sdh.term_frequency = 'm' THEN DATEADD(m, DATEDIFF(m, 0, @flow_date_from), 0) ELSE @flow_date_from END  AND ISNULL(@flow_date_to_temp,@flow_date_from)
				--	AND (
				--		(@flow_date_from BETWEEN dd.term_start AND dd.term_end) 
				--		OR (ISNULL(@flow_date_to, @flow_date_from) BETWEEN dd.term_start AND dd.term_end)
				--	)
				--	AND dd.physical_financial_flag='p'

					select c.[sql_date_value] [term_start]--, c.[sql_date_value] [sql_date_value]
					from date_details c
					where c.[sql_date_value] between dd.term_start and dd.term_end
						and c.[sql_date_value] between @flow_date_from and @flow_date_to
						and dd.physical_financial_flag='p'
			) tm
			LEFT JOIN optimizer_header oh ON oh.transport_deal_id = dd.source_deal_header_id
			WHERE  tm.[term_start] BETWEEN @flow_date_from 
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
			GROUP BY source_deal_detail_id,tm.[term_start],scsv.proxy_record,dd.location_id
			--print 'DETAIL TERM BREAKDOWN END: ' + convert(VARCHAR(50),getdate() ,21)
		END
	END

	IF @flag NOT IN ('m','n','w')
	BEGIN

		/* STORE LOCATION RANKING VALUES START */
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
		
		SELECT sdd.source_deal_header_id 
			, CASE WHEN MAX(minor_from.proxy_location_id) IS NOT NULL AND MAX(minor_from.is_aggregate) = 'n' 
				THEN MAX(minor_from.proxy_location_id)
				ELSE MAX(minor_from.source_minor_location_id) 
			  END from_loc
			, CASE WHEN MAX(minor_to.proxy_location_id) IS NOT NULL AND MAX(minor_to.is_aggregate) = 'n' 
				THEN MAX(minor_to.proxy_location_id)
				ELSE MAX(minor_to.source_minor_location_id) 
			  END to_loc
			, MAX(sdh.contract_id) contract_id
			, CAST(LEFT(sddh.hr, 2) AS INT) [hour]
			, SUM(
				CASE WHEN sdd.leg = 2 THEN sddh.volume * IIF(sdd.buy_sell_flag = 's', -1, 1)
					 ELSE 0
				END
			  ) [hourly_vol]
			--, CAST(ROUND(MIN(sdd.deal_volume), 1) AS INT) deal_volume 
			, MIN(sdd.deal_volume) deal_volume
		INTO #sch_deal_info--SELECT * FROM #sch_deal_info WHERE from_loc = 2857
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
		INNER JOIN source_deal_detail_hour sddh 
			ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
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
		GROUP BY sdd.source_deal_header_id,sddh.hr
		
		/* STORE SCHEDULED DEAL INFO END */
		--print 'SCHEDULED DEAL INFO END: ' + convert(VARCHAR(50),getdate() ,21)


		 ----print 'time01' + convert(VARCHAR(50),getdate() ,21)

		/* STORE LOSS FACTOR INFORMATION START */
		--print 'LOSS FACTOR INFORMATION START: ' + convert(VARCHAR(50),getdate() ,21)
		--extract latest effective date FOR loss factor1
		SELECT pls.path_id, pls.contract_id, MAX(pls.effective_date) effective_date
		INTO #tmp_lf1_eff_date
		FROM path_loss_shrinkage pls
		WHERE pls.effective_date <= @flow_date_from
		GROUP BY pls.path_id, pls.contract_id

		--extract value associated WITH latest effective date found FOR loss factor1
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
		SELECT tsd.time_series_definition_id, MAX(tsd.effective_date) effective_date
		INTO #tmp_lf2_eff_date
		FROM time_series_data tsd
		WHERE tsd.effective_date <= @flow_date_from
		GROUP BY tsd.time_series_definition_id

		--extract value associated WITH latest effective date found FOR loss factor2(time series data)
		SELECT t2.time_series_definition_id, t2.effective_date, ca_lf.loss_factor
		INTO #tmp_lf2
		FROM #tmp_lf2_eff_date t2
		CROSS APPLY (
			SELECT t.value loss_factor 
			FROM time_series_data t 
			WHERE t.time_series_definition_id = t2.time_series_definition_id AND t.effective_date = t2.effective_date
		) ca_lf

		--final store of loss factor information
		SELECT l1.path_id,l1.contract_id, l1.effective_date effective_date1, l1.loss_factor loss_factor1
			, l1.shrinkage_curve_id, l2.effective_date effective_date2, l2.loss_factor loss_factor2
			, COALESCE(l1.loss_factor, l2.loss_factor, 0) loss_factor
		INTO #tmp_loss_factor
		FROM #tmp_lf1 l1
		LEFT JOIN #tmp_lf2 l2 
			ON l2.time_series_definition_id = l1.shrinkage_curve_id

		/* STORE LOSS FACTOR INFORMATION END */
		--print 'LOSS FACTOR INFORMATION END: ' + convert(VARCHAR(50),getdate() ,21)

		/* STORE PATH MDQ INFORMATION START */
		--print 'PATH MDQ INFORMATION START: ' + convert(VARCHAR(50),getdate() ,21)
		--extract latest effective date FOR PATH mdq
		SELECT dpm.path_id,MAX(dpm.effective_date) effective_date
		INTO #tmp_pmdq_eff_date --SELECT * FROM #tmp_pmdq_eff_date
		FROM delivery_path_mdq dpm
		WHERE dpm.effective_date <= @flow_date_from
		GROUP BY dpm.path_id

		--extract value associated WITH latest effective date found FOR PATH mdq
		SELECT *
		INTO #tmp_pmdq --SELECT * FROM #tmp_pmdq WHERE path_id=142
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
		SELECT tcm.contract_id, MAX(tcm.effective_date) effective_date
		INTO #tmp_cmdq_eff_date
		FROM transportation_contract_mdq tcm
		WHERE tcm.effective_date <= @flow_date_from
		GROUP BY tcm.contract_id

		--extract value associated WITH latest effective date found FOR PATH mdq
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
				
		--STORE HEADER DEAL DETAIL UDF FIELD VALUES START
		--print 'UDF FIELD VALUES START: ' + convert(VARCHAR(50),getdate() ,21)
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
			SELECT dpd.path_id [parent_path_id]
				, dpd.Path_name [path_id]
				, spath_clevel.contract_id
				, spath_clevel.[contract_name]
				, ISNULL(tm.mdq, dp.mdq) [path_mdq]
				, 0 [released_mdq]
				, spath_sch_vol.deal_volume [sch_vol]
				, spath_clevel.contract_mdq
				, spath_clevel.contract_rmdq
				, lf.loss_factor
				, spath_clevel.contract_uom
			INTO #single_path_detail --SELECT * FROM #single_path_detail WHERE parent_path_id=197
			FROM delivery_path_detail dpd
			LEFT JOIN delivery_path dp ON dp.path_id = dpd.Path_name
			LEFT JOIN #tmp_pmdq tm ON tm.path_id = dpd.path_name
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
	IF @flag IN ('l','c')
	BEGIN
		--HOURLY POSITION CALC START
		BEGIN
			--print 'HOURLY POSITION CALC S: ' + convert(VARCHAR(50),getdate() ,21)
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
				, IIF(unpv.location_name = ''storage'', ABS(CAST(unpv.[position] AS NUMERIC(38,20))), CAST(unpv.[position] AS NUMERIC(38,20))) [position]
				, unpv.source_deal_detail_id
			INTO ' + @hourly_pos_info + '
			FROM (
				SELECT rhpd.source_deal_header_id, rhpd.term_start, rhpd.location_id, rhpd.curve_id
					, MAX(dtb.source_deal_detail_id) [source_deal_detail_id]
					, MAX(smj.location_name) [location_name]
					, MAX(rhpd.granularity) [granularity]
					, MAX(rhpd.period) [period] 
					, MAX(rhpd.hr1) [hr1]
					, MAX(rhpd.hr2) [hr2]
					, MAX(rhpd.hr3) [hr3]
					, MAX(rhpd.hr4) [hr4]
					, MAX(rhpd.hr5) [hr5]
					, MAX(rhpd.hr6) [hr6]
					, MAX(rhpd.hr7) [hr7]
					, MAX(rhpd.hr8) [hr8]
					, MAX(rhpd.hr9) [hr9]
					, MAX(rhpd.hr10) [hr10]
					, MAX(rhpd.hr11) [hr11]
					, MAX(rhpd.hr12) [hr12]
					, MAX(rhpd.hr13) [hr13]
					, MAX(rhpd.hr14) [hr14]
					, MAX(rhpd.hr15) [hr15]
					, MAX(rhpd.hr16) [hr16]
					, MAX(rhpd.hr17) [hr17]
					, MAX(rhpd.hr18) [hr18]
					, MAX(rhpd.hr19) [hr19]
					, MAX(rhpd.hr20) [hr20]
					, MAX(rhpd.hr21) [hr21]
					, MAX(rhpd.hr22) [hr22]
					, MAX(rhpd.hr23) [hr23]
					, MAX(rhpd.hr24) [hr24]
					, MAX(rhpd.hr25) [hr25]
	
				FROM report_hourly_position_deal rhpd (NOLOCK)
				INNER JOIN #deal_term_breakdown dtb ON dtb.source_deal_header_id = rhpd.source_deal_header_id
					AND dtb.location_id = rhpd.location_id
					AND dtb.term_start = rhpd.term_start
					AND dtb.curve_id = rhpd.curve_id
					AND dtb.source_deal_detail_id = rhpd.source_deal_detail_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = rhpd.source_deal_header_id
				INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
					AND sdt.source_deal_type_name NOT LIKE ''Capacity%''
				INNER JOIN source_minor_location sml
					ON sml.source_minor_location_id = rhpd.location_id
				INNER JOIN source_major_location smj
					ON smj.source_major_location_id = sml.source_major_location_id
				GROUP BY rhpd.source_deal_header_id, rhpd.term_start, rhpd.location_id, rhpd.curve_id

				UNION ALL
				SELECT rhpp.source_deal_header_id, rhpp.term_start, rhpp.location_id, rhpp.curve_id
					, MAX(dtb.source_deal_detail_id) [source_deal_detail_id]
					, MAX(smj.location_name) [location_name]
					, MAX(rhpp.granularity) [granularity]
					, MAX(rhpp.period) [period] 
					, MAX(rhpp.hr1) [hr1]
					, MAX(rhpp.hr2) [hr2]
					, MAX(rhpp.hr3) [hr3]
					, MAX(rhpp.hr4) [hr4]
					, MAX(rhpp.hr5) [hr5]
					, MAX(rhpp.hr6) [hr6]
					, MAX(rhpp.hr7) [hr7]
					, MAX(rhpp.hr8) [hr8]
					, MAX(rhpp.hr9) [hr9]
					, MAX(rhpp.hr10) [hr10]
					, MAX(rhpp.hr11) [hr11]
					, MAX(rhpp.hr12) [hr12]
					, MAX(rhpp.hr13) [hr13]
					, MAX(rhpp.hr14) [hr14]
					, MAX(rhpp.hr15) [hr15]
					, MAX(rhpp.hr16) [hr16]
					, MAX(rhpp.hr17) [hr17]
					, MAX(rhpp.hr18) [hr18]
					, MAX(rhpp.hr19) [hr19]
					, MAX(rhpp.hr20) [hr20]
					, MAX(rhpp.hr21) [hr21]
					, MAX(rhpp.hr22) [hr22]
					, MAX(rhpp.hr23) [hr23]
					, MAX(rhpp.hr24) [hr24]
					, MAX(rhpp.hr25) [hr25]
	
				FROM report_hourly_position_profile rhpp (NOLOCK)
				INNER JOIN #deal_term_breakdown dtb ON dtb.source_deal_header_id = rhpp.source_deal_header_id
					AND dtb.location_id = rhpp.location_id
					AND dtb.term_start = rhpp.term_start
					AND dtb.curve_id = rhpp.curve_id
					AND dtb.source_deal_detail_id = rhpp.source_deal_detail_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = rhpp.source_deal_header_id
				INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
					AND sdt.source_deal_type_name NOT LIKE ''Capacity%''
				INNER JOIN source_minor_location sml
					ON sml.source_minor_location_id = rhpp.location_id
				INNER JOIN source_major_location smj
					ON smj.source_major_location_id = sml.source_major_location_id
				GROUP BY rhpp.source_deal_header_id, rhpp.term_start, rhpp.location_id, rhpp.curve_id
			) a
			UNPIVOT ([position] FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12
			, hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24, hr25) 
			) AS unpv
			WHERE CAST(REPLACE([hour],''hr'','''') AS INT) IN (' + @period_from + ')
			'
			--print(@sql)
			EXEC(@sql)
			--print 'HOURLY POSITION CALC END: ' + convert(VARCHAR(50),getdate() ,21)

		END

		--STORAGE POSITION CALC AND STORE ON TEMP TABLE
		BEGIN
			--STORAGE POSITION EXTRACT
			DECLARE @storage_position_interim VARCHAR(500) = dbo.FNAProcessTableName('storage_position_interim', @user_login_id, @process_id)
			DECLARE @sql_mid VARCHAR(MAX)

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
					EXEC spa_storage_position_report ' + ISNULL('@book_entity_id = ''' + @book + ''', ', '') + '@location_id = ''' + @from_location + ISNULL(',' + @to_location, '') + ''', @term_start = ''' + convert(VARCHAR(50), @flow_date_from, 21)+ ''',@term_end = ''' + convert(VARCHAR(50), @flow_date_to, 21) + ''', @uom = ''' + CAST(@uom AS VARCHAR(10))+ ''', @volume_conversion = ''' + CAST(@uom AS VARCHAR(10)) + ''', @call_from=''optimization''
		
					IF OBJECT_ID(''' + @storage_position_interim + ''') IS NOT NULL drop table ' + @storage_position_interim + '
					SELECT * into ' + @storage_position_interim + ' from #storage_position_html

				END
					'
	
				EXEC(@sql_mid)
				--print 'storage sp call END: ' + convert(VARCHAR(50),getdate() ,21)
		
			END

			SELECT dbo.FNAStripHTML(sp.location) location
				, dbo.FNAStripHTML(sp.contract) contract
				, dbo.FNAClientToSqlDate(RIGHT(dbo.FNAStripHTML(sp.term), 10)) term
				, dbo.FNAStripHTML(sp.injection) injection
				, dbo.FNAStripHTML(sp.injection_amount) injection_amount
				, dbo.FNAStripHTML(sp.withdrawal) withdrawal
				, dbo.FNAStripHTML(sp.withdrawal_amount) withdrawal_amount
				, dbo.FNAStripHTML(sp.wacog) wacog
				, sp.balance balance
				, dbo.FNAStripHTML(sp.uom) uom
			INTO #storage_position --select * from #storage_position
			FROM #storage_position_html sp

		END
	END

END

IF @flag = 'l' --location plot optimization grid
BEGIN
		
	CREATE TABLE #locwise_range_total (
		location_id INT NULL,
		total_position NUMERIC(38,20),
		[beg_pos] NUMERIC(38,20)
	)

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
	--print '@from_loc @to_loc set END: ' + convert(VARCHAR(50),getdate() ,21)
	--CALCULATE TOTAL POSITION FOR RANGE OF TERMS START
	IF @receipt_delivery = 'FROM' AND OBJECT_ID(@deal_detail_info,'U') IS NOT NULL
	BEGIN
		EXEC('DROP TABLE ' + @deal_detail_info)
	END
	
	SET @sql = CASE WHEN @receipt_delivery = 'FROM' THEN '
	SELECT ''from'' [market_side], sdd.source_deal_header_id, sdd.source_deal_detail_id,sdd.curve_id, dtb.term_start, sdd.location_id, sdd.deal_volume, CAST(NULL AS NUMERIC(38,20)) total_volume, CAST(NULL AS NUMERIC(38,20)) avail_volume, GETDATE() [create_ts]
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
	--print(@sql)
	EXEC(@sql)
	--print '@deal_detail_info END: ' + convert(VARCHAR(50),getdate() ,21)
		
	--pick location wise total position and beginning position
	SET @sql = '
	DECLARE @hour_count INT
	SELECT @hour_count = COUNT(scsv.item) FROM dbo.SplitCommaSeperatedValues(''' + @period_from + ''') scsv

	SET @hour_count = IIF(@hour_count > 24, 24, @hour_count)
	--select @hour_count
		
	INSERT INTO #locwise_range_total -- select * from #locwise_range_total
	SELECT hp.location_id
		, SUM(
			(hp.position - ISNULL(dst_pos.position, 0) - IIF(dst_del.id IS NOT NULL AND hp.hour = 21, hp.position, 0))
			* ISNULL(rvuc.conversion_factor, 1)
		  ) [total_position]	
		, SUM(
			IIF(smj.location_name = ''storage'' AND sdh.template_id = ' + CAST(@transportation_template_id AS VARCHAR(10)) + '
				, 0
				, (hp.position - ISNULL(dst_pos.position, 0))
			)
		  ) / ISNULL(NULLIF(
							IIF(MAX(dst_pos.position) <> 0
							, 25
							, IIF(MAX(dst_del.id) IS NOT NULL, 23, @hour_count)
							), 0), 1) [beg_pos]	
		
	FROM ' + @hourly_pos_info + ' hp 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = hp.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.to_source_uom_id = ' + CAST(@uom AS VARCHAR(5)) + '
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN source_minor_location sml 
		ON sml.source_minor_location_id = hp.location_id
	LEFT JOIN source_major_location smj
		ON smj.source_major_location_id = sml.source_major_location_id
	LEFT JOIN ' + @hourly_pos_info + ' dst_pos
		ON dst_pos.source_deal_detail_id = hp.source_deal_detail_id
		AND dst_pos.hour = 25
		AND hp.hour = 21
	LEFT JOIN mv90_DST dst_del --delete position for dst delete case; only for total position
		ON dst_del.[date]-1 = hp.term_start
		AND dst_del.insert_delete = ''d''
	GROUP BY hp.location_id
	'
	
	EXEC(@sql)

	--round total position and begining position
	UPDATE #locwise_range_total SET [beg_pos] = ROUND([beg_pos], 0), [total_position] = ROUND([total_position], 0)
	--print(@sql)
	--return
	--CALCULATE TOTAL POSITION FOR RANGE OF TERMS END
	
	SELECT sdd.location_id
		,sml.Location_Name
		,sdd.source_deal_detail_id
		,sdd.source_deal_header_id
		,sdht.template_name
		,CASE 
			WHEN sdht.template_name = @transportation_template_name
				THEN sdh.description2
			ELSE isnull(sdv_d_pr.code, 168)
			END [priority]
		,dtb.term_start
		,ISNULL(rvuc.conversion_factor, 1) * sdd.total_volume * CASE sdd.buy_sell_flag
			WHEN 's'
				THEN - 1
			ELSE 1
			END [total_volume]
		,ISNULL(rvuc.conversion_factor, 1) * sdd.deal_volume * CASE sdd.buy_sell_flag
			WHEN 's'
				THEN - 1
			ELSE 1
			END [deal_volume]
		,sdd.Leg
		,sdd.deal_volume_frequency
		,dtb.proxy_record
		,sml.proxy_location_id
		,coalesce(sml.proxy_position_type, indirect_proxy_pos_type_c.proxy_position_type, indirect_proxy_pos_type_p.proxy_position_type) [proxy_position_type]
		--set proxy position for case where proxy_pos = self position
		,CASE 
			WHEN (
					sml.proxy_location_id IS NOT NULL
					AND coalesce(sml.proxy_position_type, indirect_proxy_pos_type_c.proxy_position_type, indirect_proxy_pos_type_p.proxy_position_type) = 110201
					)
				THEN ISNULL(rvuc.conversion_factor, 1) * sdd.deal_volume * CASE sdd.buy_sell_flag
						WHEN 's'
							THEN - 1
						ELSE 1
						END
			ELSE NULL
			END [proxy_position_value]
	INTO #tmp_sdd --select proxy_record,* from #deal_term_breakdown where location_id = 30376
	FROM source_deal_detail sdd
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		AND sdh.physical_financial_flag = 'p'
	INNER JOIN #deal_term_breakdown dtb ON dtb.source_deal_detail_id = sdd.source_deal_detail_id
		AND sdd.physical_financial_flag = 'p'
	OUTER APPLY (
		SELECT DISTINCT item
		FROM dbo.SplitCommaSeperatedValues(@minor_location) l1
		WHERE l1.item = sdd.location_id
		) loc_list
	INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
		AND bk.source_system_book_id2 = sdh.source_system_book_id2
		AND bk.source_system_book_id3 = sdh.source_system_book_id3
		AND bk.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@commodity) com ON com.item = sdh.commodity_id
	OUTER APPLY (
		SELECT SUM(volume) vol
		FROM source_deal_detail_hour
		WHERE source_deal_detail_id = sdd.source_deal_detail_id
			AND term_date = dtb.term_start
			AND sdd.deal_volume_frequency = 't'
		) sddh
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	LEFT JOIN #deal_detail_udf detail_udf ON detail_udf.source_deal_detail_id = sdd.source_deal_detail_id
	LEFT JOIN static_data_value sdv_d_pr ON CAST(sdv_d_pr.value_id AS VARCHAR(10)) = detail_udf.udf_value
	LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.to_source_uom_id = @uom
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	OUTER APPLY (
		SELECT TOP 1 sml1.source_minor_location_id
			,sml1.proxy_position_type
		FROM source_minor_location sml1
		WHERE (sml.proxy_location_id IS NOT NULL)
			AND sml1.source_minor_location_id <> sml.source_minor_location_id
			AND sml1.proxy_location_id = sml.proxy_location_id
			AND sml1.proxy_position_type IS NOT NULL
		) indirect_proxy_pos_type_c
	OUTER APPLY (
		SELECT TOP 1 sml1.source_minor_location_id
			,sml1.proxy_position_type
		FROM source_minor_location sml1
		WHERE (sml.proxy_location_id IS NULL)
			AND sml1.proxy_location_id = sml.source_minor_location_id
			AND sml1.proxy_position_type IS NOT NULL
		) indirect_proxy_pos_type_p
	WHERE 1 = 1
		AND CASE 
			WHEN sdht.template_name = @transportation_template_name
				THEN ISNULL(TRY_CONVERT(INT, sdh.description2), 168)
			ELSE ISNULL(TRY_CONVERT(INT, sdv_d_pr.code), 168)
			END BETWEEN ISNULL(@priority_from, 0)
			AND ISNULL(@priority_to, 9999)
		AND sdt.source_deal_type_name NOT LIKE 'Capacity%'
	--print '#tmp_sdd END: ' + convert(VARCHAR(50),getdate() ,21)

	SELECT ts1.location_id
		, SUM(ts1.deal_volume) deal_volume
		, MAX(ts1.proxy_location_id) proxy_location_id
		, MAX(ts1.proxy_position_type) proxy_position_type
		, NULL [proxy_pos_value_total]
		, NULL [proxy_pos_value_beg]
		, SUM(IIF(ts1.term_start = dbo.FNAGetFirstLastDayOfMonth(@flow_date_from,'f'),ts1.deal_volume,NULL)) deal_volume_beg
	INTO #loc_proxy_level
	FROM #tmp_sdd ts1 
	GROUP BY ts1.location_id

	UPDATE ts
	SET ts.proxy_pos_value_total = CASE 
			WHEN proxy_position_type IS NOT NULL
				THEN CASE 
						WHEN ts.proxy_location_id IS NOT NULL
							AND ts.proxy_position_type = 110201
							THEN (
									SELECT sum(t2.deal_volume)
									FROM #loc_proxy_level t2
									WHERE t2.proxy_location_id = ts.proxy_location_id
									)
						WHEN ts.proxy_location_id IS NOT NULL
							AND ts.proxy_position_type = 110200
							THEN (
									SELECT t1.deal_volume
									FROM #loc_proxy_level t1
									WHERE t1.location_id = ts.proxy_location_id
									)
						WHEN ts.proxy_location_id IS NULL
							AND proxy_position_type = 110200
							THEN ts.deal_volume
						WHEN ts.proxy_location_id IS NULL
							AND proxy_position_type = 110201
							THEN ts.deal_volume + (
									SELECT sum(t2.deal_volume)
									FROM #loc_proxy_level t2
									WHERE t2.proxy_location_id = ts.location_id
									)
						ELSE NULL
						END
			ELSE NULL
			END
		,ts.proxy_pos_value_beg = CASE 
			WHEN proxy_position_type IS NOT NULL
				THEN CASE 
						WHEN ts.proxy_location_id IS NOT NULL
							AND ts.proxy_position_type = 110201
							THEN (
									SELECT sum(t2.deal_volume)
									FROM #loc_proxy_level t2
									WHERE t2.proxy_location_id = ts.proxy_location_id
									)
						WHEN ts.proxy_location_id IS NOT NULL
							AND ts.proxy_position_type = 110200
							THEN (
									SELECT t1.deal_volume_beg
									FROM #loc_proxy_level t1
									WHERE t1.location_id = ts.proxy_location_id
									)
						WHEN ts.proxy_location_id IS NULL
							AND proxy_position_type = 110200
							THEN ts.deal_volume_beg
						WHEN ts.proxy_location_id IS NULL
							AND proxy_position_type = 110201
							THEN ts.deal_volume_beg + (
									SELECT sum(t2.deal_volume_beg)
									FROM #loc_proxy_level t2
									WHERE t2.proxy_location_id = ts.location_id
									)
						ELSE NULL
						END
			ELSE NULL
			END
	FROM #loc_proxy_level ts

	UPDATE ts
	SET ts.proxy_pos_value_total = (
			SELECT t1.proxy_pos_value_total
			FROM #loc_proxy_level t1
			WHERE t1.location_id = ts.proxy_location_id
			)
		,ts.proxy_pos_value_beg = (
			SELECT t1.proxy_pos_value_beg
			FROM #loc_proxy_level t1
			WHERE t1.location_id = ts.proxy_location_id
			)
	FROM #loc_proxy_level ts
	WHERE ts.proxy_location_id IS NOT NULL
		AND ts.proxy_position_type = 110201
		AND ts.proxy_pos_value_beg IS NULL

	--print 'time4' + convert(varchar(50),getdate() ,21)

	UPDATE #tmp_sdd
		SET total_volume = CASE WHEN deal_volume_frequency = 'm' 
							THEN total_volume/([dbo].[FNALastDayInMonth](term_start))
							ELSE total_volume
							END,
			deal_volume = CASE WHEN deal_volume_frequency = 'm' 
							THEN deal_volume/([dbo].[FNALastDayInMonth](term_start))
							ELSE deal_volume
							END

	SELECT @receipt_delivery [from_to]
		,minor.location_name [location_name]
		,minor.source_minor_location_id [location_id]
		,major.location_name [location_type]
		,round(CASE major.location_name
				WHEN 'storage'
					THEN isnull(max(oa_sp.storage_position), 0)
						--else ISNULL(sum(sdd.deal_volume), 0)
				ELSE ISNULL(max(beg_vol.beg_vol), 0)
				END, @round) [position]
		,round(CASE major.location_name
				WHEN 'storage'
					THEN isnull(max(oa_sp.storage_position), 0)
				ELSE ISNULL(sum(sdd.deal_volume), 0)
				END, @round) [total_position]
		,isnull(lr.[rank], 9999) [rank]
		,isnull(max(minor.proxy_location_id), minor.source_minor_location_id) [proxy_loc_id]
		,NULL [proxy_pos]
		,NULL [proxy_pos_total]
		,NULL [is_aggregate]
		,CAST(NULL AS CHAR(1)) is_unschedule
		,max(beg_vol.[proxy_position_type]) [proxy_position_type]
	INTO #tmp_location_pos_info --select * from #tmp_location_pos_info
		--select *
	FROM source_minor_location minor(NOLOCK)
	CROSS APPLY (
		SELECT DISTINCT item
		FROM dbo.SplitCommaSeperatedValues(@minor_location) l1
		WHERE l1.item = minor.source_minor_location_id
		) loc_list
	LEFT JOIN #tmp_sdd sdd --select * from #tmp_sdd
		ON ISNULL(sdd.location_id, - 1) = minor.source_minor_location_id
	LEFT JOIN source_major_location major ON major.source_major_location_ID = minor.source_major_location_ID
	LEFT JOIN #tmp_location_ranking_values2 lr ON lr.cnt = 1
		AND lr.location_id = minor.source_minor_location_id --select * from #tmp_location_ranking_values2
	OUTER APPLY (
		--changed logic to show daily balance for that term on storage location (modified on:2019-08-12, for TRMTracker_Gas_Demo, Consulted BA: Sulav Nepal, Dev: Sangam Ligal)
		SELECT
			--sum(cast(sp.injection as float) - cast(sp.withdrawal as float)) [storage_position]
			ROUND(sum(cast(sp.balance AS NUMERIC(38,20))),0) [storage_position]
		FROM #storage_position sp
		WHERE sp.location = minor.Location_Name
			AND sp.term = isnull(@flow_date_to, @flow_date_from)
		GROUP BY sp.location
		) oa_sp
	OUTER APPLY (
		SELECT sum(tsdd.deal_volume) [beg_vol]
			,max(tsdd.proxy_position_type) [proxy_position_type]
		FROM #tmp_sdd tsdd
		WHERE tsdd.term_start = @flow_date_from
			AND tsdd.location_id = sdd.location_id
		) beg_vol
	WHERE 1 = 1
		--AND IIF(@hide_pos_zero = 'y', sdd.location_id, 1) IS NOT NULL
	GROUP BY minor.location_id
		,minor.Location_Name
		,minor.source_minor_location_id
		,major.location_name
		,ISNULL(lr.[rank], 9999)
		,lr.effective_date
--print '#tmp_location_pos_info END: ' + convert(varchar(50),getdate() ,21)
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
	
	----print 'time5' + convert(varchar(50),getdate() ,21)

	----print 'time6' + convert(varchar(50),getdate() ,21)

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
	--print 'imbalance END: ' + convert(varchar(50),getdate() ,21)
	SELECT 
		CASE WHEN sml.location_id <> sml.location_name 
			THEN sml.location_id + '-' 
			ELSE '' 
		END  + sml.location_name + ISNULL(' [' + tlpi.location_type + ']', '') [location_name]
		, tlpi.location_id
		, tlpi.location_type
		, dbo.FNARemoveTrailingZero(ROUND(COALESCE(tlpi.proxy_pos, IIF(pmj.location_name = 'storage',tlpi.position,lrt.[beg_pos]),0), @round)) [position]		
		, dbo.FNARemoveTrailingZero(ROUND(ISNULL( CASE pmj.location_name WHEN 'storage' THEN tlpi.position ELSE COALESCE(tlpi.proxy_pos_total,lrt.total_position,0) END,0), @round)) [total_pos]
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
		,tlpi.is_unschedule
		,@imbalance_paths imbalance_paths
	INTO #temp_final
	FROM #tmp_location_pos_info tlpi --select * from #tmp_location_pos_info
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = tlpi.location_id
	LEFT JOIN source_minor_location pmi ON pmi.source_minor_location_id = tlpi.proxy_loc_id
	LEFT JOIN source_major_location pmj ON pmj.source_major_location_ID = pmi.source_major_location_ID
	LEFT JOIN #locwise_range_total lrt ON lrt.location_id = tlpi.location_id
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
	
	SELECT * 
	FROM #temp_final 
	order by [rank], [location_id]

	IF @receipt_delivery = 'FROM'
	BEGIN
		SET @sql = 'INSERT INTO ' + @storage_position + '
					SELECT ''w'', location_id, total_pos 
					FROM   #temp_final 
					where location_type = ''Storage'''
		EXEC(@sql)

		EXEC('
		IF OBJECT_ID(''' + @location_pos_info + ''') IS NOT NULL DROP TABLE ' + @location_pos_info + '
		SELECT ''supply'' [market_side], * INTO ' + @location_pos_info + ' FROM #temp_final
		')
	END
	ELSE IF @receipt_delivery = 'TO'
	BEGIN
		SET @sql = 'INSERT INTO ' + @storage_position + '
					SELECT ''i'', location_id, total_pos 
					FROM   #temp_final 
					where location_type = ''Storage'''
		EXEC(@sql)

		EXEC('
		INSERT INTO ' + @location_pos_info + ' 
		SELECT ''demand'', * FROM  #temp_final
		')
		
	END

END

ELSE IF @flag = 'c' --box plot,process table create optimization grid
BEGIN
	
	SET @sql = '
	INSERT INTO ' + @storage_position + '
	SELECT 
		CASE 
			WHEN sml.source_minor_location_id IN (' + @from_location + ') THEN ''w'' 
			WHEN sml.source_minor_location_id IN (' + @to_location + ') THEN ''i'' 
			ELSE '''' 
		END [type]
		, sml.source_minor_location_id [location_id]
		, SUM(CAST(sp.balance AS NUMERIC(38,20))) [total_pos] 
	FROM #storage_position sp
	INNER JOIN source_minor_location sml ON sml.location_name = sp.location
	WHERE sp.term = ''' + CONVERT(VARCHAR(10), ISNULL(@flow_date_to, @flow_date_from), 21) + '''
		AND NOT EXISTS (SELECT TOP 1 1 FROM ' + @storage_position + ' sp1 WHERE sp1.location_id = sml.source_minor_location_id)
	GROUP BY sml.source_minor_location_id
	'
	EXEC(@sql)
	
	DECLARE @all_location VARCHAR(MAX),
			@all_proxyloc VARCHAR(MAX),
			@from_to_loc VARCHAR(MAX)
	

	SET @from_to_loc = ISNULL(NULLIF(@from_location, '') + ',', '') + ISNULL(@to_location, '') 
	SET @from_to_loc = IIF(RIGHT(@from_to_loc, 1) = ',', LEFT(@from_to_loc, LEN(@from_to_loc) - 1), @from_to_loc)	


	SET @all_proxyloc = ISNULL(NULLIF(@proxy_locs, '') + ',', '') + ISNULL(@child_proxy_locs, '')
	SET @all_proxyloc = IIF(RIGHT(@all_proxyloc, 1) = ',', LEFT(@all_proxyloc, LEN(@all_proxyloc) - 1), @all_proxyloc)	

	
	SET @all_location = ISNULL(NULLIF(@from_location, '') + ',', '') + ISNULL(NULLIF(@to_location, '') + ',', '') + ISNULL(NULLIF(@pool_id, '') + ',', '') +ISNULL(NULLIF(@pool_location_id, ''), '')
	SET @all_location = IIF(RIGHT(@all_location, 1) = ',', LEFT(@all_location, LEN(@all_location) - 1), 	@all_location)	

	--DEAL DETAIL LEVEL POSITION INFO
	----print '@flag = ''c'', DEAL DETAIL LEVEL POSITION INFO START: ' + convert(varchar(50),getdate() ,21)
	SET @sql = '
	IF OBJECT_ID(''' + @opt_deal_detail_pos + ''') IS NOT NULL
		DROP TABLE ' + @opt_deal_detail_pos + '
	SELECT DISTINCT sdd.source_deal_detail_id 
		, sdd.source_deal_header_id
		, sdh.deal_id [reference_id]
		, bk.book [book]
		, NULL [from_deal]
		, NULL [to_deal]
		, NULL [nom_group]
		-- , sdh.description1 [nom_group]
		, COALESCE(TRY_CONVERT(INT, sdv_pr.code), TRY_CONVERT(INT, sdh.description2), 168) [priority]
		, sdh.counterparty_id
		, sdh.contract_id
		, major.source_major_location_ID [location_type_id]
		, minor.source_minor_location_id [location_id]
		, minor.location_name
		, major.location_name [location_type]
		, isnull(lr.rank, 9999) [location_rank]
		, lr.effective_date [lr_eff_date]
		, sdd.term_start
		, sdd.term_end
		, ISNULL(rvuc.conversion_factor, 1) * ISNULL(pos.position, 0) [position]
		, sdd.deal_volume_uom_id [uom_id]
		, sdd.leg
		, sdd.buy_sell_flag
		, CASE 
			WHEN sdht.template_name = ''' + @transportation_template_name + ''' THEN 
				CASE
					WHEN major.location_name = ''M2'' then
						case sdd.leg when 2 THEN ''Gath Nom'' 
							else ''Interstate Nom''
						end
					WHEN major.location_name = ''Storage'' THEN ''Storage''
					ELSE ''Interstate Nom''
				END
			ELSE CASE WHEN sdd.buy_sell_flag = ''b'' THEN ''Purchase'' WHEN sdd.buy_sell_flag = ''s'' THEN ''Sales'' END
		 END [Group]
		 , ISNULL(rvuc.conversion_factor, 1) [uom_conversion_factor]
		 , loc_list.is_proxy
	INTO ' + @opt_deal_detail_pos + '
	FROM source_deal_detail sdd (nolock)
	INNER JOIN #deal_term_breakdown dtb (NOLOCK) ON dtb.source_deal_detail_id = sdd.source_deal_detail_id 
		AND sdd.physical_financial_flag =''p''
		AND dtb.source_deal_header_id = sdd.source_deal_header_id
	CROSS APPLY (
		SELECT DISTINCT s.item, NULL is_proxy
		FROM dbo.SplitCommaSeperatedValues(''' + ISNULL(@all_location, '') + ''') s 
		WHERE s.item = sdd.location_id
		UNION ALL
		SELECT DISTINCT s.item, 1 is_proxy 
		FROM dbo.SplitCommaSeperatedValues(''' + ISNULL(@all_proxyloc, '') + ''') s 
		WHERE s.item = sdd.location_id
			AND s.item NOT IN (' + ISNULL(@from_to_loc, '') + ')
	) loc_list 
	INNER JOIN source_deal_header sdh (NOLOCK) ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
		and bk.source_system_book_id2 = sdh.source_system_book_id2
		and bk.source_system_book_id3 = sdh.source_system_book_id3
		and bk.source_system_book_id4 = sdh.source_system_book_id4
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
		FROM source_deal_detail_hour (NOLOCK)
		WHERE source_deal_detail_id = sdd.source_deal_detail_id 
			AND term_date = dtb.term_start 
			AND sdd.deal_volume_frequency = ''t''
	) sddh
	OUTER APPLY (
		SELECT SUM(hp.position) [position]
		FROM ' + @hourly_pos_info + ' hp (NOLOCK)
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
	--PRINT(@sql)
	EXEC(@sql)

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
		
	SELECT DISTINCT --added distinct clause so that duplicate path contract info when child proxy also has path to that locations exists, is reduced.
		CAST(f1.item AS VARCHAR) [from_loc_id],
		major_from.source_major_location_ID [from_loc_grp_id],
		major_from.location_name [from_loc_grp_name],
		major_to.source_major_location_ID [to_loc_grp_id],
		major_to.location_name [to_loc_grp_name],
		sml.Location_Name [from_loc],
		CAST(f2.item AS VARCHAR) [to_loc_id],
		sml2.Location_Name [to_loc],
		CAST(NULL AS NUMERIC(38, 18)) [received],
		CAST(NULL AS NUMERIC(38, 18)) [delivered],
		COALESCE(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id, 0) [path_id],
		spath.path_id [single_path_id],
		COALESCE(dp.path_name,dp_proxy_from.path_name,dp_child_proxy_from.path_name,dp_proxy_to.path_name,dp_child_proxy_to.path_name,dp_proxy_from_to.path_name,dp_child_proxy_from_to.path_name) [path_name],
		COALESCE(dp.groupPath,dp_proxy_from.groupPath,dp_child_proxy_from.groupPath,dp_proxy_to.groupPath,dp_child_proxy_to.groupPath,dp_proxy_from_to.groupPath,dp_child_proxy_from_to.groupPath) [group_path],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			COALESCE(spath.path_mdq, tm.mdq, COALESCE(dp.mdq,dp_proxy_from.mdq,dp_child_proxy_from.mdq,dp_proxy_to.mdq,dp_child_proxy_to.mdq,dp_proxy_from_to.mdq,dp_child_proxy_from_to.mdq))
			* ISNULL(NULLIF(uom_cv.conversion_factor, 0), 1)
		), @round), 0) [path_mdq],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			(COALESCE(spath.path_mdq, tm.mdq, COALESCE(dp.mdq,dp_proxy_from.mdq,dp_child_proxy_from.mdq,dp_proxy_to.mdq,dp_child_proxy_to.mdq,dp_proxy_from_to.mdq,dp_child_proxy_from_to.mdq)) * ISNULL(NULLIF(uom_cv.conversion_factor, 0), 1)
			 - COALESCE(spath.sch_vol, sch_vol.deal_volume,0))
			
		), @round), 0) [path_rmdq],
		COALESCE(spath.contract_id, contract_level.contract_id, dp.[CONTRACT]) [contract_id],
		COALESCE(spath.[contract_name], contract_level.[contract_name], cg.[contract_name]) [contract_name],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			COALESCE(spath.contract_mdq, contract_level.contract_mdq,dp.mdq)
			* ISNULL(NULLIF(uom_cv.conversion_factor, 0), 1)
		), @round), 0) [mdq],
		ISNULL(ROUND(dbo.FNARemoveTrailingZeroes(
			COALESCE(spath.contract_rmdq, contract_level.[contract_rmdq],COALESCE(spath.contract_mdq, contract_level.contract_mdq,dp.mdq) * ISNULL(NULLIF(uom_cv.conversion_factor, 0), 1))
		), @round), 0) [rmdq],
		COALESCE(spath.sch_vol, sch_vol.deal_volume,0) [total_sch_volume],
		COALESCE(spath.loss_factor, lf.loss_factor, 0) [loss_factor],
		sdv3.code [priority],
		sdv3.value_id [priority_id],
		CAST(ISNULL(lr.[rank], 99999) AS INT) [from_rank],
		CAST(ISNULL(lr2.[rank], 99999) AS INT) [to_rank],
		CASE WHEN major_from.location_name = 'Storage' THEN 
			'w'
		ELSE 
			CASE WHEN major_to.location_name = 'Storage' THEN
				'i'
			ELSE 'n'
			END
		END [storage_deal_type],
		NULL [storage_asset_id],
		0 [storage_volume],
		sml.proxy_location_id [from_proxy_loc_id],
		sml2.proxy_location_id [to_proxy_loc_id],
		0 [from_is_proxy],
		0 [to_is_proxy],
		NULL [parent_from_loc_id],
		NULL [parent_to_loc_id],
		ISNULL(cg.segmentation, 'n') [segmentation]
		--, sml.proxy_position_type [from_proxy_position_type]
		--, sml2.proxy_position_type [to_proxy_position_type]
		 , ISNULL(uom_cv.conversion_factor, 1) [uom_conversion_factor] 
	
	INTO #tmp_solver_decisions --select * from #tmp_solver_decisions order by 1
	--,spath.path_mdq, tm.mdq, dp.mdq
	--select dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id,*
	FROM dbo.FNASplit(@from_location, ',') f1
	CROSS JOIN dbo.FNASplit(@to_location, ',') f2 
	INNER JOIN source_minor_location sml (NOLOCK) ON sml.source_minor_location_id = f1.item
	INNER JOIN source_minor_location sml2 (NOLOCK) ON sml2.source_minor_location_id = f2.item
	LEFT JOIN delivery_path dp (NOLOCK) ON dp.from_location = f1.item 
		AND dp.to_location = f2.item 
		AND ISNULL(dp.priority, 1) = CASE WHEN dp.groupPath = 'y' THEN ISNULL(dp.priority, 1) ELSE COALESCE(@path_priority,dp.priority,1) END
		AND ISNULL(dp.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp.counterparty, -1) AS VARCHAR(100)))))		
	LEFT JOIN delivery_path dp_proxy_from (NOLOCK) ON dp_proxy_from.from_location = sml.proxy_location_id 
		AND dp_proxy_from.to_location = f2.item 
		AND ISNULL(dp_proxy_from.priority, 1) = CASE WHEN dp_proxy_from.groupPath = 'y' THEN ISNULL(dp_proxy_from.priority, 1) ELSE COALESCE(@path_priority,dp_proxy_from.priority,1) END
		AND ISNULL(dp_proxy_from.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_proxy_from.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_proxy_from.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_proxy_from.counterparty, -1) AS VARCHAR(100)))))
	LEFT JOIN delivery_path dp_child_proxy_from ON dp_child_proxy_from.to_location = f2.item
		AND dp_child_proxy_from.from_location IN (
			SELECT item 
			FROM dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp1 
			INNER JOIN source_minor_location sml1 ON sml1.source_minor_location_id = cp1.item
			WHERE sml1.proxy_location_id = f1.item
		)
	LEFT JOIN delivery_path dp_proxy_to (NOLOCK) ON dp_proxy_to.from_location = f1.item 
		AND dp_proxy_to.to_location =  sml2.proxy_location_id
		AND ISNULL(dp_proxy_to.priority, 1) = CASE WHEN dp_proxy_to.groupPath = 'y' THEN ISNULL(dp_proxy_to.priority, 1) ELSE COALESCE(@path_priority,dp_proxy_to.priority,1) END
		AND ISNULL(dp_proxy_to.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_proxy_to.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_proxy_to.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_proxy_to.counterparty, -1) AS VARCHAR(100)))))
	LEFT JOIN delivery_path dp_child_proxy_to ON dp_child_proxy_to.from_location = f1.item
			AND dp_child_proxy_to.to_location IN (
				SELECT item 
				FROM dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp1 
				INNER JOIN source_minor_location sml1 ON sml1.source_minor_location_id = cp1.item
				WHERE sml1.proxy_location_id = f2.item
			)
	LEFT JOIN delivery_path dp_proxy_from_to (NOLOCK) ON dp_proxy_from_to.from_location = sml.proxy_location_id 
		AND dp_proxy_from_to.to_location = sml2.proxy_location_id 
		AND ISNULL(dp_proxy_from_to.priority, 1) = CASE WHEN dp_proxy_from_to.groupPath = 'y' THEN ISNULL(dp_proxy_from_to.priority, 1) ELSE COALESCE(@path_priority,dp_proxy_from_to.priority,1) END
		AND ISNULL(dp_proxy_from_to.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_proxy_from_to.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_proxy_from_to.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_proxy_from_to.counterparty, -1) AS VARCHAR(100)))))
	LEFT JOIN delivery_path dp_child_proxy_from_to (NOLOCK) ON dp_child_proxy_from_to.from_location in (
			SELECT item 
			FROM dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp2 
			INNER JOIN source_minor_location sml2 ON sml2.source_minor_location_id = cp2.item
			WHERE sml2.proxy_location_id = f1.item
		) 
		AND dp_child_proxy_from_to.to_location in (
				SELECT item 
				FROM dbo.SplitCommaSeperatedValues(@child_proxy_locs) cp3 
				INNER JOIN source_minor_location sml3 ON sml3.source_minor_location_id = cp3.item
				WHERE sml3.proxy_location_id = f2.item
			) 
		AND ISNULL(dp_child_proxy_from_to.priority, 1) = CASE WHEN dp_child_proxy_from_to.groupPath = 'y' THEN ISNULL(dp_child_proxy_from_to.priority, 1) ELSE COALESCE(@path_priority,dp_child_proxy_from_to.priority,1) END 
		AND ISNULL(dp_child_proxy_from_to.contract, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(COALESCE(@counterparty_contract_id, @contract_id, CAST(ISNULL(dp_child_proxy_from_to.contract, -1) AS VARCHAR(100)))))
		AND ISNULL(dp_child_proxy_from_to.counterparty, -1) IN (SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@pipeline_ids, CAST(ISNULL(dp_child_proxy_from_to.counterparty, -1) AS VARCHAR(100)))))
	LEFT JOIN #tmp_location_ranking_values2 lr ON lr.cnt = 1 
		AND lr.location_id = sml.source_minor_location_id 
	LEFT JOIN #tmp_location_ranking_values2 lr2 ON lr2.cnt = 1 
		AND lr2.location_id = sml2.source_minor_location_id 
	LEFT JOIN static_data_value sdv3 (NOLOCK) ON dp.priority = sdv3.value_id
	LEFT JOIN contract_group cg (NOLOCK) ON cg.contract_id = dp.[contract]
	LEFT JOIN source_major_location major_from (NOLOCK)ON major_from.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN source_major_location major_to (NOLOCK) ON major_to.source_major_location_ID = sml2.source_major_location_ID
	LEFT JOIN #tmp_pmdq tm ON tm.path_id = COALESCE(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
	OUTER APPLY (
		SELECT  ccrs.path_id, dp2.path_name, cg1.contract_id, cg1.contract_name, ISNULL(tc.mdq, cg1.mdq) [contract_mdq]
			, (ISNULL(tc.mdq, cg1.mdq) * ISNULL(NULLIF(uom_cv.conversion_factor, 0), 1)) - oa_crmdq.sch_vol [contract_rmdq], cg1.volume_uom [contract_uom]
		FROM counterparty_contract_rate_schedule ccrs (nolock)
		INNER JOIN contract_group cg1 (NOLOCK) ON cg1.contract_id = ccrs.contract_id
		INNER JOIN delivery_path dp2 (NOLOCK) ON dp2.path_id = ccrs.path_id
		LEFT JOIN #tmp_cmdq tc ON tc.contract_id = cg1.contract_id
		OUTER APPLY (
			SELECT sdi.contract_id, SUM(sdi.deal_volume) sch_vol
			FROM #sch_deal_info sdi --select * from #sch_deal_info
			WHERE sdi.contract_id = cg1.contract_id
				AND ((sdi.from_loc = f1.item AND sdi.to_loc = f2.item AND ISNULL(cg1.segmentation, 'n') = 'y') OR ISNULL(cg1.segmentation, 'n') = 'n')
			GROUP BY sdi.contract_id
		) oa_crmdq
		OUTER APPLY (
			SELECT rvuc.conversion_factor
			FROM rec_volume_unit_conversion rvuc
			WHERE rvuc.from_source_uom_id = cg1.volume_uom 
				AND rvuc.to_source_uom_id = @uom
		) uom_cv
		WHERE dp2.path_id = COALESCE(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
		
	) contract_level
	OUTER APPLY (
		SELECT MIN(sdi.deal_volume) deal_volume
		FROM #sch_deal_info sdi
		WHERE sdi.from_loc = f1.item 
			and sdi.to_loc = f2.item 
			AND sdi.contract_id = contract_level.contract_id			
		GROUP BY sdi.from_loc, sdi.to_loc, sdi.contract_id
    ) sch_vol
	LEFT JOIN #single_path_detail spath ON spath.parent_path_id = COALESCE(dp.path_id,dp_proxy_from.path_id,dp_proxy_to.path_id,dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
	OUTER APPLY (
		SELECT rvuc.conversion_factor
		FROM rec_volume_unit_conversion rvuc
		WHERE rvuc.from_source_uom_id = coalesce(spath.contract_uom,contract_level.contract_uom) and rvuc.to_source_uom_id = @uom
	) uom_cv
	LEFT JOIN #tmp_loss_factor lf 
		ON lf.path_id = coalesce(dp.path_id,dp_proxy_from.path_id,dp_child_proxy_from.path_id,dp_proxy_to.path_id,dp_child_proxy_to.path_id,dp_proxy_from_to.path_id,dp_child_proxy_from_to.path_id)
		and lf.contract_id = coalesce(spath.contract_id, contract_level.contract_id, dp.CONTRACT)
--print '@flag = ''c'', #tmp_solver_decisions E: ' + convert(varchar(50),getdate() ,21)
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
	from #tmp_solver_decisions a --select * from #tmp_solver_decisions
	--print '@flag = ''c'', #tmp_filtered_data E: ' + convert(varchar(50),getdate() ,21)
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
--print '@flag = ''c'', @contractwise_detail_mdq E: ' + convert(varchar(50),getdate() ,21)
	--keep fresh table values for data just after refresh, to dump this value on contractwise_detail_mdq before solver run. (added due to issue: continoulsy decrement of prmdq value on multiple times solver run)
	EXEC('
	IF OBJECT_ID(''' + @contractwise_detail_mdq_fresh + ''') IS NOT NULL
	DROP TABLE ' + @contractwise_detail_mdq_fresh + '
	SELECT * INTO ' + @contractwise_detail_mdq_fresh + ' FROM ' + @contractwise_detail_mdq + '
	--select * from ' + @contractwise_detail_mdq_fresh + '
	')
	
--print '@flag = ''c'', @contractwise_detail_mdq_fresh E: ' + convert(varchar(50),getdate() ,21)

	--store path wise capacity deals hourly mdq (not used for now)
	/*
	if OBJECT_ID('tempdb..#path_wise_capacity_hourly_mdq') is not null
		drop table #path_wise_capacity_hourly_mdq
	select uddf.udf_value [path_id], cast(left(sddh.hr,2) as int) [hour], min(sddh.volume) [hourly_mdq]
	into #path_wise_capacity_hourly_mdq --  select * from #path_wise_capacity_hourly_mdq
	from source_deal_detail_hour sddh
	inner join source_deal_detail sdd on sdd.source_deal_detail_id = sddh.source_deal_detail_id and sdd.term_start = sddh.term_date
	inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
	inner join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
	inner JOIN user_defined_deal_fields_template uddft (NOLOCK) ON  uddft.field_label = 'Delivery Path'	-- delivery_path
		AND uddft.template_id = sdh.template_id
	inner JOIN user_defined_deal_fields uddf (NOLOCK) ON  uddf.source_deal_header_id = sdh.source_deal_header_id
		AND uddft.udf_template_id = uddf.udf_template_id
		and uddf.udf_value is not null
	where sdt.source_deal_type_name = 'Capacity'
		and sdd.term_start between @flow_date_from and isnull(@flow_date_to, @flow_date_from)
		--and sdd.leg = 2
	group by uddf.udf_value,cast(left(sddh.hr,2) as int)
	*/

	--store location wise capacity deals hourly mdq
	IF OBJECT_ID('tempdb..#loc_wise_capacity_hourly_mdq') IS NOT NULL
		DROP TABLE #loc_wise_capacity_hourly_mdq --  select * from #loc_wise_capacity_hourly_mdq order by 1,2
	SELECT MAX(sml.proxy_location_id) [proxy_location_id]
		, sdd.location_id
		, sdh.contract_id
		, CAST(LEFT(sddh.hr,2) AS INT) [hour]
		, SUM(IIF(sdh.header_buy_sell_flag = 's', -1, 1) * sddh.volume) [hourly_mdq]
		--,sdh.source_deal_header_id
	INTO #loc_wise_capacity_hourly_mdq
	FROM source_deal_detail_hour sddh (NOLOCK)
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@minor_location + ISNULL(',' + @child_proxy_locs, '')) scsv ON scsv.item = sdd.location_id
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = scsv.item
	LEFT JOIN static_data_value sdv_pg ON sdv_pg.value_id = sdh.internal_portfolio_id
	WHERE sdt.source_deal_type_name = 'Capacity'
		AND sddh.term_date BETWEEN @flow_date_from AND ISNULL(@flow_date_to, @flow_date_from)
		AND (sdv_pg.code NOT IN ('Complex-EEX', 'Complex-LTO', 'Complex-ROD') OR sdv_pg.code IS NULL) --exclude these product group capacity deals.
	GROUP by sdd.location_id, sdh.contract_id, CAST(LEFT(sddh.hr,2) AS INT)--,sdh.source_deal_header_id	

--print '@flag = ''c'', #loc_wise_capacity_hourly_mdq E: ' + convert(varchar(50),getdate() ,21)

	--store path mdq information prior Ffor performance optimization
	BEGIN
		SELECT b.*
		INTO #path_mdq_info
		FROM (
			SELECT path_id
			FROM #tmp_filtered_data
			WHERE path_id > 0
			GROUP BY path_id
			) a
		OUTER APPLY [dbo].[FNAGetPathMDQHourly](a.path_id, @flow_date_from, @flow_date_from, '') b
	END

--print '@flag = ''c'', #path_mdq_info E: ' + convert(varchar(50),getdate() ,21)
	--create hourly table
	SET @sql = '
	IF OBJECT_ID(''' + @contractwise_detail_mdq_hourly + ''') IS NOT NULL
	DROP TABLE ' + @contractwise_detail_mdq_hourly + '

	SELECT
		t.[box_id] 
		, t.[from_loc_id]
		, t.[from_loc_grp_id]
		, t.[from_loc_grp_name]
		, t.[to_loc_grp_id]
		, t.[to_loc_grp_name]
		, t.[from_loc]
		, t.[to_loc_id]
		, t.[to_loc]
		, t.[received]
		, t.[delivered]
		, t.[path_id]
		, t.[single_path_id]
		, t.[path_name]
		, t.[group_path]

		, path_mdq_info.mdq [path_mdq]
		, path_mdq_info.rmdq [path_rmdq]
		, t.[contract_id]
		, t.[contract_name]
		, t.[mdq]
		, t.[rmdq]
		
		, ISNULL(path_mdq_info.used_mdq, 0) [total_sch_volume]
		, t.[loss_factor]
		, t.[priority]
		, t.[priority_id]
		, t.[from_rank]
		, t.[to_rank]
		, t.[storage_deal_type]
		, t.[storage_asset_id]
		, t.[storage_volume]
		, t.[from_proxy_loc_id]
		, t.[to_proxy_loc_id]
		, t.[from_is_proxy]
		, t.[to_is_proxy]
		, t.[parent_from_loc_id]
		, t.[parent_to_loc_id]
		, t.[segmentation]
		, t.[uom_conversion_factor]
		, t.[box_type]
		, t.[receipt_deals]
		, t.[delivery_deals]
		, t.[match_term_start]
		, t.[match_term_end]
		, t.[uom]
		, path_mdq_info.rmdq [path_ormdq]
		, t.rmdq [ormdq]
		, ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + ''' [term_start]
		, hr_values.[hour] [hour]
		, hr_values.[is_dst]
		, ' + cast(@granularity as VARCHAR(10)) + ' [granularity]
		, pos_s.position [supply_position]
		, pos_d.position [demand_position]
		, path_mdq_info.only_path_mdq [only_path_mdq]
	INTO ' + @contractwise_detail_mdq_hourly + ' 
	FROM #tmp_filtered_data t
	CROSS JOIN (
		SELECT (CAST(left(hr_col.clm_name,2) AS INT) + 1) [hour], hr_col.is_dst
		FROM dbo.FNAGetDisplacedPivotGranularityColumn(''' + CONVERT(VARCHAR(10),@flow_date_from,21) + ''', ''' + CONVERT(VARCHAR(10),@flow_date_to,21) + ''', 982, 102201, 6) hr_col
		WHERE (CAST(left(hr_col.clm_name,2) AS INT) + 1) IN (' + @period_from + ')
	) hr_values
	LEFT JOIN #path_mdq_info path_mdq_info
		ON path_mdq_info.path_id = t.path_id
		AND path_mdq_info.[hour] = hr_values.[hour]
		AND ISNULL(path_mdq_info.is_dst, 0) = ISNULL(hr_values.is_dst, 0)
	OUTER APPLY (
		SELECT 
			IIF(hr_values.is_dst = 1
				, SUM(dst_pos.position) --for dst hour actual position
				, SUM(hp.position - ISNULL(dst_pos.position,0))
			) [position]
		FROM ' + @hourly_pos_info + ' hp
		LEFT JOIN ' + @hourly_pos_info + ' dst_pos
			ON dst_pos.source_deal_detail_id = hp.source_deal_detail_id
			AND dst_pos.hour = 25
			AND hp.hour = 21
		WHERE hp.location_id = t.from_loc_id
			AND hp.term_start = ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + '''
			AND hp.[hour] = hr_values.[hour]
		GROUP BY hp.location_id, hp.term_start, hp.[hour]
	) pos_s
	OUTER APPLY (
		SELECT 
			IIF(hr_values.is_dst = 1
				, SUM(dst_pos.position) --for dst hour actual position
				, SUM(hp.position - ISNULL(dst_pos.position,0))
			) [position]
		FROM ' + @hourly_pos_info + ' hp
		LEFT JOIN ' + @hourly_pos_info + ' dst_pos
			ON dst_pos.source_deal_detail_id = hp.source_deal_detail_id
			AND dst_pos.hour = 25
			AND hp.hour = 21
		WHERE hp.location_id = t.to_loc_id
			AND hp.term_start = ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + '''
			AND hp.[hour] = hr_values.[hour]
		GROUP BY hp.location_id, hp.term_start, hp.[hour]
	) pos_d
	'
	
	EXEC(@sql)

	--EXEC('select * from ' + @contractwise_detail_mdq_hourly)
	--PRINT(@sql)
	--RETURN

	--fresh hourly data
	EXEC('
	IF OBJECT_ID(''' + @contractwise_detail_mdq_hourly_fresh + ''') IS NOT NULL
		DROP TABLE ' + @contractwise_detail_mdq_hourly_fresh + '
	SELECT * INTO ' + @contractwise_detail_mdq_hourly_fresh + ' FROM ' + @contractwise_detail_mdq_hourly + '
	')
--print '@flag = ''c'', contractwise PT E: ' + convert(varchar(50),getdate() ,21)
	
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
			(SELECT DISTINCT ','  + cast(t1.path_id AS VARCHAR)
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
	
	----print '@flag = ''c'', #tmp_filtered_data1 E: ' + convert(varchar(50),getdate() ,21)
	--fresh hourly data
	SET @sql = '
	DECLARE @first_hour INT
	SELECT @first_hour = MIN(hp.hour) FROM ' + @contractwise_detail_mdq_hourly + ' hp

	SELECT t.box_id
		, t.from_loc_id
		, t.from_loc
		, t.to_loc_id
		, t.to_loc
		, t.from_rank
		, t.to_rank
		, dbo.FNARemoveTrailingZero(ROUND(SUM(cdh.received), ' + CAST(@round AS VARCHAR(10)) + ')) received
		, dbo.FNARemoveTrailingZero(ROUND(SUM(cdh.delivered), ' + CAST(@round AS VARCHAR(10)) + ')) delivered
		, dbo.FNARemoveTrailingZero(ROUND(SUM(t.mdq), ' + CAST(@round AS VARCHAR(10)) + ')) mdq
		, dbo.FNARemoveTrailingZero(ROUND(SUM(t.rmdq), ' + CAST(@round AS VARCHAR(10)) + ')) rmdq
		, dbo.FNARemoveTrailingZero(ROUND(SUM(t.ormdq), ' + CAST(@round AS VARCHAR(10)) + ')) ormdq
		, MAX(t.path_exists) path_exists
		, dbo.FNARemoveTrailingZero(ROUND(SUM(IIF(t.contract_id = path_mdq_info.contract_id, path_mdq_info.pmdq, 0)), ' + CAST(@round AS VARCHAR(10)) + '))  path_mdq
		, dbo.FNARemoveTrailingZero(ROUND(SUM(IIF(t.contract_id = path_mdq_info.contract_id, path_mdq_info.prmdq, 0)), ' + CAST(@round AS VARCHAR(10)) + ')) path_rmdq
		, dbo.FNARemoveTrailingZero(ROUND(SUM(IIF(t.contract_id = path_mdq_info.contract_id, path_mdq_info.prmdq, 0)), ' + CAST(@round AS VARCHAR(10)) + ')) path_ormdq
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
		, CAST(SUM(IIF(cdh.hour = @first_hour, cdh.received,  NULL)) AS NUMERIC(38,20)) [first_hour_rec_vol]
		, CAST(SUM(IIF(cdh.hour = @first_hour, cdh.delivered, NULL)) AS NUMERIC(38,20)) [first_hour_del_vol]

	FROM #tmp_filtered_data1 t
	INNER JOIN ' + @contractwise_detail_mdq_hourly + ' cdh on cdh.box_id = t.box_id
		AND cdh.path_id = t.path_id
		AND ISNULL(cdh.contract_id,0) = ISNULL(t.contract_id,0)
	OUTER APPLY (
		SELECT MAX(c1.path_mdq) [pmdq]
			, MAX(c1.path_rmdq) [prmdq]
			, MAX(c1.contract_id) [contract_id]
		FROM ' + @contractwise_detail_mdq_hourly + ' c1
		WHERE c1.box_id = t.box_id
			AND c1.path_id = t.path_id
			AND c1.hour = cdh.hour
			AND ISNULL(c1.is_dst, 0) = ISNULL(cdh.is_dst, 0)
	) path_mdq_info
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
	ORDER BY box_id
		, t.from_rank
		, t.from_loc_id
		, t.to_rank
		, t.to_loc_id
	'
	--print(@sql)
	EXEC(@sql)
	--print '@flag = ''c'', final: ' + convert(varchar(50),getdate() ,21)
END

ELSE IF @flag = 'r' --run solver
BEGIN
	SET @sql = '
	TRUNCATE TABLE ' + @contractwise_detail_mdq_hourly + '
	INSERT INTO ' + @contractwise_detail_mdq_hourly + '
	SELECT * FROM ' + @contractwise_detail_mdq_hourly_fresh + '
	'
		
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
				, CAST(NULL AS TINYINT) [is_dst]
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
				,is_dst
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
				,cast(a.path_mdq as numeric(38,20))
				,cast(a.path_rmdq as numeric(38,20))
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
				,ISNULL(a.uom_conversion_factor, 1)
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
				,a.hour
				,a.is_dst
				,a.granularity
				
			FROM ' + @contractwise_detail_mdq_hourly + ' a
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
				,a.hour
				,a.is_dst
				,a.granularity
				
			FROM ' + @contractwise_detail_mdq_hourly + ' a
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
			[is_dst] TINYINT NULL,
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
			SET cdmg.received = iif(cdmg.hour=1,50,100),
				cdmg.delivered = iif(cdmg.hour=1,50,100), 
				cdmg.path_rmdq = cdmg.path_rmdq - iif(cdmg.hour=1,50,100)
		FROM ' + @contractwise_detail_mdq_group + ' cdmg
		'
		EXEC(@sql)
		*/
	END
	
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
			
				-- FOR SINGLE PATH (HOURLY TABLE)
				UPDATE c
					SET c.received = ISNULL(g.received, 0), 
						c.delivered = ISNULL(g.delivered, 0)
				FROM ' + @contractwise_detail_mdq_hourly + ' c
				INNER JOIN ' + @contractwise_detail_mdq_group + ' g ON g.box_id = c.box_id
					AND g.path_id = c.path_id
					AND g.contract_id = c.contract_id
					AND g.term_start = c.term_start
					AND g.hour = c.hour
					AND ISNULL(g.is_dst, 0) = ISNULL(c.is_dst, 0)
				WHERE c.group_path = ''n''

				-- FOR SINGLE PATH
				UPDATE c
                    SET received =h.received, 
                        delivered = h.delivered
                FROM ' + @contractwise_detail_mdq + ' c
                CROSS APPLY(
					SELECT SUM(ch.received) [received], SUM(ch.delivered) [delivered]
					FROM ' + @contractwise_detail_mdq_hourly + ' ch
					WHERE ch.box_id = c.box_id
						AND ISNULL(ch.single_path_id, ch.path_id) = ISNULL(c.single_path_id, c.path_id)
						AND ch.contract_id = c.contract_id
					GROUP BY box_id
                ) h
					
					
				DECLARE @r_id INT, @box_id INT, @single_path_id INT, @received NUMERIC(38, 20), @delivered NUMERIC(38, 20), @loss_factor NUMERIC(38, 20), @next_path INT
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
					
					SELECT @received = received, @delivered = delivered, @loss_factor = loss_factor
					FROM ' + @contractwise_detail_mdq + '
					WHERE box_id = @box_id 
						AND single_path_id = @single_path_id 
					
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

	UPDATE ' + @contractwise_detail_mdq_hourly + '
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
	DECLARE @first_hour INT
	SELECT @first_hour = MIN(hp.hour) FROM ' + @contractwise_detail_mdq_hourly + ' hp

	SELECT 	
		box_id
		,MAX(from_loc_id)from_loc_id	 
		,MAX(from_loc)	from_loc
		,MAX(to_loc_id)to_loc_id
		,MAX(to_loc)to_loc	
		,MAX(from_rank)	from_rank
		,MAX(to_rank)	to_rank
		,dbo.FNARemoveTrailingZero(ROUND(SUM(CAST(received AS FLOAT)), 0)) received
		,dbo.FNARemoveTrailingZero(ROUND(SUM(CAST(delivered AS FLOAT)), 0))	delivered
		,dbo.FNARemoveTrailingZero(ROUND(MAX(mdq), 0))	mdq
		,dbo.FNARemoveTrailingZero(ROUND(MAX(rmdq), 0))	rmdq
		,dbo.FNARemoveTrailingZero(ROUND(MAX(total_sch_volume), 0))	total_sch_volume
		,MAX(path_exists)path_exists	
		,MAX(path_name)	path_name
		,dbo.FNARemoveTrailingZero(ROUND(SUM(CAST(path_mdq AS FLOAT)), 0))	path_mdq
		,dbo.FNARemoveTrailingZero(ROUND(SUM(CAST(path_rmdq AS FLOAT)), 0))	path_rmdq
		,dbo.FNARemoveTrailingZero(ROUND(SUM(CAST(path_ormdq AS FLOAT)), 0))	path_ormdq
		,MAX(from_loc_grp_id)	from_loc_grp_id
		,MAX(from_loc_grp_name)	from_loc_grp_name
		,MAX(to_loc_grp_id)	to_loc_grp_id
		,MAX(to_loc_grp_name)to_loc_grp_name
		,MAX(first_hour_rec_vol) [first_hour_rec_vol]
		,MAX(first_hour_del_vol) [first_hour_del_vol]
	
	FROM (
	SELECT tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.received), ' + CAST(@round AS VARCHAR(10)) + ')) [received]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.delivered), ' + CAST(@round AS VARCHAR(10)) + ')) [delivered]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.mdq), ' + CAST(@round AS VARCHAR(10)) + ')) [mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.rmdq), ' + CAST(@round AS VARCHAR(10)) + ')) [rmdq]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.total_sch_volume), ' + CAST(@round AS VARCHAR(10)) + ')) [total_sch_volume]
		, MAX(tsd.path_id) [path_exists]
		, MAX(tsd.path_name) [path_name]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.path_mdq), ' + CAST(@round AS VARCHAR(10)) + ')) [path_mdq]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.path_rmdq), ' + CAST(@round AS VARCHAR(10)) + ')) [path_rmdq] 
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.path_ormdq), ' + CAST(@round AS VARCHAR(10)) + ')) [path_ormdq]
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
		, MAX(IIF(tsd.hour = @first_hour, tsd.received, 0)) [first_hour_rec_vol]
		, MAX(IIF(tsd.hour = @first_hour, tsd.delivered, 0)) [first_hour_del_vol]
	FROM ' + @contractwise_detail_mdq_hourly + ' tsd
	WHERE ISNULL(group_path, ''n'') <> ''y''
	GROUP BY tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
	--order by from_rank asc, from_loc asc, to_rank asc, to_loc asc
	UNION ALL
	SELECT tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, dbo.FNARemoveTrailingZero(ROUND(MAX(tsd.received), ' + CAST(@round AS VARCHAR(10)) + ')) [received]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.delivered), ' + CAST(@round AS VARCHAR(10)) + ')) [delivered]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.mdq), ' + CAST(@round AS VARCHAR(10)) + ')) [mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.rmdq), ' + CAST(@round AS VARCHAR(10)) + ')) [rmdq]
		, dbo.FNARemoveTrailingZero(ROUND(SUM(tsd.total_sch_volume), ' + CAST(@round AS VARCHAR(10)) + ')) [total_sch_volume]
		, MAX(tsd.path_id) [path_exists]
		, MAX(tsd.path_name) [path_name]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_mdq), ' + CAST(@round AS VARCHAR(10)) + ')) [path_mdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_rmdq), ' + CAST(@round AS VARCHAR(10)) + '))  [path_rmdq]
		, dbo.FNARemoveTrailingZero(ROUND(MIN(tsd.path_ormdq), ' + CAST(@round AS VARCHAR(10)) + ')) [path_ormdq]
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
		, MAX(IIF(tsd.hour = @first_hour, tsd.received, 0)) [first_hour_rec_vol]
		, MAX(IIF(tsd.hour = @first_hour, tsd.delivered, 0)) [first_hour_del_vol]
	FROM ' + @contractwise_detail_mdq_hourly + ' tsd
	WHERE ISNULL(group_path, ''n'') =''y''
	GROUP BY tsd.[box_id], tsd.from_loc_id, tsd.from_loc, tsd.to_loc_id, tsd.to_loc, tsd.from_rank, tsd.to_rank
		, tsd.from_loc_grp_id, tsd.from_loc_grp_name, tsd.to_loc_grp_id, tsd.to_loc_grp_name
	)sub 
	GROUP BY sub.box_id

	ORDER BY box_id asc

	'
	--print(@sql)
	EXEC(@sql)

END
ELSE IF @flag = 'y' --Extracting path and contract level information to load on path list of outer popup and inner popup.
BEGIN
	
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
ELSE IF @flag = 'q' --Filling up Contract Detail information on Main Popup on Optimization Grid.
BEGIN
	set @sql = '
	IF OBJECT_ID(''tempdb..##path_detail_q'') IS NOT NULL
		DROP TABLE ##path_detail_q
	SELECT pt.from_loc_id [from_location], pt.to_loc_id [to_location]
		, pt.path_id [path_id], dp.path_name [path_name]
		, dpd.delivery_path_detail_id, pt.single_path_id [single_path_id]
		, pt.loss_factor [loss_factor]
		, pt.contract_id [contract_id], pt.contract_name [contract_name]
		, ISNULL(pt.mdq, 0) [contract_mdq]
		, ISNULL(pt.rmdq, 0) [contract_rmdq]
		, ISNULL(pt.rmdq, 0) [contract_ormdq]
		, ISNULL(pt.path_mdq, 0) [path_mdq]
		, ISNULL(pt.path_rmdq,0) [path_rmdq]
		, ISNULL(pt.path_ormdq,0) [path_ormdq]
		, COALESCE(first_pmdq.first_pmdq, pt.path_mdq, 0) [first_path_mdq]
		, ISNULL(pt.path_mdq, 0) [total_mdq], isnull(pt.path_rmdq, 0) [total_rmdq]
		, ISNULL(pt.received, 0) [receipt]
		, IIF(pt.group_path = ''y'', total_mdq.first_received, ISNULL(total_mdq.receipt_total, 0)) [receipt_total]
		, ISNULL(pt.delivered, 0) [delivery]
		, IIF(pt.group_path = ''y'', total_mdq.last_delivered, ISNULL(total_mdq.delivery_total, 0)) [delivery_total]
		, pt.segmentation [segmentation]
		, sc.counterparty_name [pipeline]
		, pt.group_path
		, CAST(pt.path_id AS VARCHAR(10)) + IIF(pt.group_path = ''y'', '''', ''_'' + CAST(pt.contract_id AS VARCHAR(10))) table_id
		INTO ##path_detail_q
	FROM ' + @contractwise_detail_mdq  + ' pt
	CROSS APPLY (
		SELECT SUM(pt1.received) [receipt_total] , SUM(pt1.delivered) [delivery_total], MAX(received) first_received, MIN(delivered) last_delivered
		FROM ' + @contractwise_detail_mdq + ' pt1
		WHERE pt1.box_id = pt.box_id 
			AND pt1.path_id = pt.path_id
	) total_mdq
	OUTER APPLY (
		SELECT TOP 1 dpd.path_id, dpd.delivery_path_detail_id, dpd.Path_name,cd1.path_mdq [first_pmdq]
		FROM delivery_path_detail dpd
		LEFT JOIN ' + @contractwise_detail_mdq + ' cd1 ON cd1.single_path_id = dpd.Path_name
			AND cd1.path_id = pt.path_id
		WHERE dpd.Path_id = pt.path_id
		ORDER by cd1.path_mdq asc
	) first_pmdq
	LEFT JOIN delivery_path dp ON dp.path_id = COALESCE(pt.single_path_id, pt.path_id)
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = dp.counterParty
	LEFT JOIN delivery_path_detail dpd ON dpd.Path_name = pt.single_path_id 
		AND dpd.path_id = pt.path_id
	WHERE 1=1 
		AND pt.path_id <> 0 
		AND pt.box_id = ' + @xml_manual_vol + '
		AND (pt.group_path = ''n'' OR (pt.group_path = ''y'' AND pt.contract_id=dp.CONTRACt))'

	EXEC(@sql)
	
	UPDATE pdq
	SET pdq.total_mdq = agg.total_mdq, pdq.total_rmdq = agg.total_rmdq
	FROM ##path_detail_q pdq
	CROSS APPLY (
		SELECT SUM(path_mdq) total_mdq, SUM(path_rmdq) total_rmdq
		FROM ##path_detail_q p1
		WHERE pdq.path_id = p1.path_id --and pdq.single_path_id = p1.single_path_id
		GROUP BY p1.path_id
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
			,dbo.FNARemoveTrailingZero(ROUND(contract_mdq, @round)) contract_mdq
			,dbo.FNARemoveTrailingZero(ROUND(contract_rmdq, @round)) contract_rmdq
			,dbo.FNARemoveTrailingZero(ROUND(contract_ormdq, @round)) contract_ormdq
			,dbo.FNARemoveTrailingZero(ROUND(path_mdq, @round)) path_mdq
			,dbo.FNARemoveTrailingZero(ROUND(path_rmdq, @round)) path_rmdq
			,dbo.FNARemoveTrailingZero(ROUND(path_ormdq, @round)) path_ormdq
			,dbo.FNARemoveTrailingZero(ROUND(first_path_mdq, @round)) first_path_mdq
			,dbo.FNARemoveTrailingZero(ROUND(total_mdq, @round)) total_mdq
			,dbo.FNARemoveTrailingZero(ROUND(total_rmdq, @round)) total_rmdq
			,dbo.FNARemoveTrailingZero(ROUND(receipt, @round)) receipt
			,dbo.FNARemoveTrailingZero(ROUND(receipt_total, @round)) receipt_total
			,dbo.FNARemoveTrailingZero(ROUND(delivery, @round)) delivery
			,dbo.FNARemoveTrailingZero(ROUND(delivery_total, @round)) delivery_total
			,segmentation
			,pipeline
			,group_path
			,table_id
	FROM  ##path_detail_q
	ORDER BY delivery_path_detail_id

	IF OBJECT_ID('tempdb..##path_detail_q') IS NOT NULL
		DROP TABLE ##path_detail_q
END
ELSE IF @flag = 'p' --For position report drill on begining inverntory optimization grid.
BEGIN
	DECLARE @pivot_cols VARCHAR(2000)
	DECLARE @pivot_cols_alias VARCHAR(2000)
	DECLARE @dynamic_sql NVARCHAR(max)
	DROP TABLE IF EXISTS #tmp_report_data

	CREATE TABLE #tmp_report_data (
		[term_start] DATE NULL,
		[source_deal_header_id] INT NULL,
		[deal_id] VARCHAR(1000) NULL,
		[deal_ref_id] VARCHAR(200) NULL,
		[location] VARCHAR(200) NULL,
		[counterparty_name] VARCHAR(200) NULL,
		[to_location] VARCHAR(200) NULL,
		[curve_id] INT NULL,
		[contract_name] VARCHAR(200) NULL,
		[uom_name] VARCHAR(10) NULL,
		[hour] VARCHAR(10) NULL,
		[gas_hour] VARCHAR(10) NULL,
		[position] NUMERIC(30,4) NULL,
		[total_position] NUMERIC(30,4) NULL
	)

	SET @sql = '
	INSERT INTO #tmp_report_data
	SELECT ddi.term_start
		, ddi.source_deal_header_id
		, ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMHyperlink(10131010,'' + cast(ddi.source_deal_header_id as varchar(10)) + '',''''n'''',''''NULL'''')"><font color="#0000ff"><u>'' + cast(ddi.source_deal_header_id as varchar(10)) + ''</u></font></span>'' deal_id
		, sdh.deal_id [deal_ref_id]
		, IIF(sdd.leg = 1, sml.Location_Name + '' ['' + smj.location_name + '']'', ca_leg_loc.location_id) [location]
		, sc.counterparty_name
		, IIF(sdd.leg = 2, sml.Location_Name + '' ['' + smj.location_name + '']'', ca_leg_loc.location_id) [to_location]
		, sdd.curve_id
		, cg.contract_name
		, uom.uom_name
		, ca_pos.hour
		, hr_col.[alias_name] [gas_hour] 
		, ca_pos.position [position]
		--, ca_total_pos.total_position [total_position]
		, SUM(ca_pos.position) OVER (
			PARTITION BY ddi.term_start, ddi.source_deal_header_id, sml.Location_Name, sc.counterparty_name, cg.contract_name 
			ORDER BY ddi.source_deal_header_id
		  ) [total_position]
		 
	FROM ' + @deal_detail_info + ' ddi
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ddi.source_deal_detail_id
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = ddi.location_id
	INNER JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ddi.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	CROSS JOIN dbo.FNAGetDisplacedPivotGranularityColumn(''' + convert(VARCHAR(50), @flow_date_from, 21) + ''', ''' + convert(VARCHAR(50), @flow_date_from, 21)+ ''', 982, 102201, 6) hr_col 
	OUTER APPLY (
		SELECT RIGHT(''0'' + CAST(p.hour AS VARCHAR(2)), 2) + '':00'' + IIF(hr_col.is_dst = 1, ''DST'', '''') [hour]
			, IIF(hr_col.is_dst = 1, dst_pos.position, (p.position - ISNULL(dst_pos.position, 0))) [position]
		FROM ' + @hourly_pos_info + ' p
		LEFT JOIN ' + @hourly_pos_info + ' dst_pos
			ON dst_pos.source_deal_detail_id = p.source_deal_detail_id
			AND dst_pos.hour = 25
			AND p.hour = 21
		WHERE p.source_deal_detail_id = sdd.source_deal_detail_id
			AND p.hour = CAST(LEFT(hr_col.clm_name, 2) AS INT) + 1
				
	) ca_pos
	OUTER APPLY (
		SELECT sdd1.leg, sdd1.location_id [source_minor_location_id], sml.location_name, smj.location_name [location_type], sml.location_id
		FROM source_deal_detail sdd1
		LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd1.location_id
		LEFT JOIN source_major_location smj ON smj.source_major_location_id = sml.source_major_location_id
		WHERE sdd1.leg = case sdd.leg when 1 then 2 else 1 end 
			AND sdd1.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd1.term_start = sdd.term_start
	) ca_leg_loc
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	LEFT JOIN source_uom uom ON uom.source_uom_id = ' + cast(isnull(nullif(@uom,''),'sdd.deal_volume_uom_id') as varchar(10)) + '

	WHERE sdd.location_id = ' + ISNULL(@minor_location, '''''') + ' 
		AND sdt.source_deal_type_name <> ''Capacity Power''
		AND ddi.market_side = ''' + @receipt_delivery + '''
	'
	EXEC(@sql)
	--print(@sql)
	--select * from #tmp_report_data
	--return
	SELECT @pivot_cols = STUFF(( SELECT '],[' + [hour]
		FROM #tmp_report_data 
		GROUP BY [hour] 
		ORDER BY [hour]
		FOR XML PATH('')),1,2,'') + ']'
		
		
	SELECT @pivot_cols_alias = STUFF(( 
		SELECT ',MAX([' + [hour] + ']) AS [' + MAX([gas_hour]) + ']'
		FROM #tmp_report_data
		GROUP BY [hour] 
		ORDER BY [hour]
		FOR XML PATH('')	
	),1,1,'')	

	--print @pivot_cols
	--print @pivot_cols_alias
	--return

	SET @sql = '
	SELECT dbo.FNADateFormat(piv.term_start) [Term]
		, piv.deal_id [Deal ID]
		, piv.deal_ref_id [Reference ID]
		, piv.location [From Location]
		, ISNULL(piv.to_location, piv.location) [To Location]
		, piv.counterparty_name [Counterparty]
		, piv.contract_name [Contract]
		, piv.uom_name [UOM]
		' + ISNULL(',' + @pivot_cols_alias, '') + '
		, MAX(piv.total_position) [Total]
		' + IIF(@batch_flag = 1, 'INTO' + @temptablename,'')+ '
	FROM (
		SELECT * FROM #tmp_report_data
	) '
	+ CASE WHEN @pivot_cols IS NOT NULL THEN ' a
	PIVOT (
		SUM(a.position) FOR a.hour IN (' + @pivot_cols + ')
	) AS piv '
	  ELSE ' piv' 
	  END + '
	GROUP BY piv.term_start
		, piv.deal_id 
		, piv.deal_ref_id 
		, piv.location 
		, ISNULL(piv.to_location, piv.location) 
		, piv.counterparty_name
		, piv.contract_name 
		, piv.uom_name
	' 
	+ IIF(@batch_flag = 0, ' ORDER BY [Term], [From Location]', '')
	--print(@sql)
	EXEC(@sql)
	
END
ELSE IF @flag = 'x' --To get sum of other volumes on box of given contract, path, box for contract validation.
BEGIN
	SET @sql = 'SELECT  cd.contract_id, ISNULL(SUM(received), 0) compare_volume
				FROM ' + @contractwise_detail_mdq + ' cd
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @contract_id + ''') t ON t.item = cd.contract_id
				WHERE cd.path_id <> ' + CAST(@delivery_path AS VARCHAR(10)) + 
					' AND cd.box_id <> ' + @xml_manual_vol + '
				GROUP BY cd.contract_id'
	EXEC(@sql)
END
ELSE IF @flag = 'd' --Load combo options of subbook while manual scheduling when generic mapping 'Flow Optimization Mapping' is not defined.
BEGIN
	DECLARE @dest_sub_book INT

	SELECT @dest_sub_book = gmv.clm1_value 
	FROM generic_mapping_values gmv 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id 
		AND gmh.mapping_name = 'Flow Optimization Mapping'
	
	CREATE TABLE #tmp_sub_book (id INT
		, group1 VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #tmp_sub_book(id, group1)
	EXEC spa_GetAllSourceBookMapping @hedge_rel_type_flag='s'

	SELECT t.id [value]
		, t.group1 [text]
		, CASE WHEN @dest_sub_book = t.id THEN 'true' ELSE 'false' END [selected]
	FROM #tmp_sub_book t
END
ELSE IF @flag = 'p1' --Load path on Flow Opt hourly scheduling UI 
BEGIN
	SET @sql = '
	SELECT cd.path_id, dp.path_name
	FROM ' + @contractwise_detail_mdq_hourly + ' cd
	INNER JOIN delivery_path dp ON dp.path_id = cd.path_id
	WHERE cd.from_loc_id IN (' + @from_location + ')
		AND cd.to_loc_id IN (' + @to_location + ')
	GROUP BY cd.path_id, dp.path_name
	'
	EXEC(@sql)
END
ELSE IF @flag = 'c1' --Load contract on Flow Opt hourly scheduling UI 
BEGIN
	SET @sql = '
	SELECT cd.contract_id, cd.contract_name
	FROM ' + @contractwise_detail_mdq_hourly + ' cd
	WHERE cd.from_loc_id IN (' + @from_location + ')
		AND cd.to_loc_id IN (' + @to_location + ')
		' + ISNULL('AND cd.path_id = ' + @path_ids, '') + '
	GROUP BY cd.contract_id, cd.contract_name
	'
	EXEC(@sql)
END
ELSE IF @flag = 'h1' --Call from flow opt hourly scheduling grid load, insert row case
BEGIN  
	
	SET @sql = '
	SELECT TOP 1 1 sub
		, cd.path_id [path_id]
		, cd.contract_id [contract]
		, cd.storage_asset_id [storage_contract]
		, NULL book
		, ''' + CONVERT(VARCHAR(10),@flow_date_from,21) + ''' term_from
		, ''' + CONVERT(VARCHAR(10),@flow_date_to,21) + ''' term_to
		, ''y'' new  
	FROM ' + @contractwise_detail_mdq_hourly + ' cd 
	WHERE cd.from_loc_id IN (' + @from_location + ')
		AND cd.to_loc_id IN (' + @to_location + ')
	' + ISNULL(' AND cd.contract_id = ' + @contract_id, '')
	--print(@sql)
	EXEC(@sql)
  
END  
ELSE IF @flag = 'h2' --Call from flow opt hourly scheduling grid load
BEGIN  
	INSERT INTO #sch_deals_hourly (source_deal_header_id)  
	SELECT DISTINCT transport_deal_id   
	FROM optimizer_detail od  
	INNER JOIN dbo.SplitCommaSeperatedValues(@receipt_deals_id) t ON t.item = od.source_deal_header_id  
	WHERE up_down_stream='u'  
	  
	SELECT   1 sub
		, uddf.udf_value path_id
		, NULL [contract]
		, NULL storage_contract
		, MAX(sdh.sub_book) book
		, MIN(sdd.term_start) term_from
		, MAX(sdd.term_end) term_to
		, 'n' [new]
	FROM  #sch_deals_hourly sd  
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sd.source_deal_header_id    
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id    
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id  
	INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id   
		AND uddft.udf_template_id = uddf.udf_template_id    
	INNER JOIN dbo.SplitCommaSeperatedValues(@path_ids) scsv ON scsv.item = uddf.udf_value 
	WHERE uddft.field_label = 'Delivery Path'  
		AND sdd.term_start BETWEEN @flow_date_from AND ISNULL(@flow_date_to, @flow_date_from) 
	GROUP BY uddf.udf_value   
END 
ELSE IF @flag = 's1' --Subgrid load on hourly scheduling flow optimization
BEGIN
	IF @call_from = 'get_subgrid_definition'
	BEGIN
		DECLARE @hour_column_headers VARCHAR(500)
			,@hour_column_ids VARCHAR(500)
			,@hour_count TINYINT
			,@hour_column_types VARCHAR(500)
			,@hour_column_widths VARCHAR(100)

		DROP TABLE IF EXISTS #function_data
		SELECT f.*
		INTO #function_data
		FROM dbo.FNAGetDisplacedPivotGranularityColumn(@flow_date_from, @flow_date_from, @granularity, 102201, 6) f-- 102201=dst group value id, 6=gas hour shift value
		INNER JOIN dbo.SplitCommaSeperatedValues(@period_from) scsv 
			ON scsv.item = f.rowid
		
		IF EXISTS (SELECT TOP 1 1 FROM #function_data WHERE is_dst = 1)
		BEGIN
			SET @dst_case = 1
		END

		SELECT @hour_count = COUNT(*)
		FROM #function_data

		SELECT @hour_column_headers = STUFF((
					SELECT ',' + alias_name
					FROM #function_data
					ORDER BY rowid
					FOR XML path('')
					), 1, 1, '')

		SELECT @hour_column_ids = STUFF((
					SELECT ',hr' + CAST(CAST(left(clm_name, 2) AS INT) + 1 AS VARCHAR(10)) + IIF(is_dst = 1, '_DST', '')
					FROM #function_data
					ORDER BY rowid
					FOR XML path('')
					), 1, 1, '')

		SELECT @hour_column_types = STUFF((REPLICATE(',ro', @hour_count)), 1, 1, '')

		SELECT @hour_column_widths = STUFF((REPLICATE(',150', @hour_count)), 1, 1, '')

		SELECT 'delivery_path_detail_id,path_id,path,contract_id,contract,group_path_id,volume,' + @hour_column_ids [column_ids]
			,'Path Detail ID,Path ID,Path,Contract ID,Contract,Group Path ID,Volume,' + @hour_column_headers [column_headers]
			,'ro,ro,ro,ro,ro,ro,ro,' + @hour_column_types [column_types]
			,'70,70,166,100,100,100,100,' + @hour_column_widths [column_widths]
			, @dst_case [dst_case]
		RETURN;

	END ELSE IF @call_from = 'clear_adj'
	BEGIN
		--flush and reload hourly contractwise table
		EXEC('
		DELETE cdh FROM ' +  @contractwise_detail_mdq_hourly + ' cdh
		WHERE cdh.from_loc_id IN (' + @from_location + ')
			AND cdh.to_loc_id IN (' + @to_location + ')

		INSERT INTO ' +  @contractwise_detail_mdq_hourly + ' 
		SELECT * FROM ' + @contractwise_detail_mdq_hourly_fresh + ' cdf
		WHERE cdf.from_loc_id IN (' + @from_location + ')
			AND cdf.to_loc_id IN (' + @to_location + ')
		')

		--flush and reload daily contractwise table
		EXEC('
		DELETE cd FROM ' +  @contractwise_detail_mdq + ' cd
		WHERE cd.from_loc_id IN (' + @from_location + ')
			AND cd.to_loc_id IN (' + @to_location + ')

		INSERT INTO ' +  @contractwise_detail_mdq + ' 
		SELECT * FROM ' + @contractwise_detail_mdq_fresh + ' cdf
		WHERE cdf.from_loc_id IN (' + @from_location + ')
			AND cdf.to_loc_id IN (' + @to_location + ')
		')
	END
	ELSE 
	DECLARE @pivot_hr_cols VARCHAR(200)
		

	IF @dst_case = 1 AND CHARINDEX('21', @period_from, 0) > 0
	BEGIN
		SET @period_from = REPLACE(@period_from, '21', '21,21_DST')		
	END

	DECLARE @period_from_temp VARCHAR(200) = @period_from

	SET @period_from_temp = '''' + REPLACE(@period_from_temp, ',', ''',''') + ''''
	
	DROP TABLE IF EXISTS #tmp_subgrid_data
	CREATE TABLE #tmp_subgrid_data (
		[delivery_path_detail_id] INT NULL,
		[path_id] INT NULL,
		[path_name] VARCHAR(200) NULL,
		[contract_id] INT NULL,
		[contract] VARCHAR(400) NULL,
		[group_path_id] INT NULL,
		[hour] VARCHAR(10) NULL,
		[volume] VARCHAR(10) NULL,
		[value] VARCHAR(100) NULL
	)
	SET @sql = '
	INSERT INTO #tmp_subgrid_data
	SELECT 
		dpd.delivery_path_detail_id
		, IIF(v.item = ''PMDQ/PRMDQ'', ISNULL(cd.single_path_id,cd.path_id), NULL) [path_id]
		, IIF(v.item = ''PMDQ/PRMDQ'', dp.path_name, NULL) [path_name]
		, IIF(v.item = ''PMDQ/PRMDQ'', cd.contract_id, NULL) [contract_id]
		, IIF(v.item = ''PMDQ/PRMDQ'', cd.contract_name, NULL) [contract]
		, IIF(cd.group_path = ''y'', cd.path_id, NULL) [group_path_id]
		, CASE 
			WHEN cd.[is_dst] = 1
				THEN CAST(cd.[hour] AS VARCHAR(10)) + ''_DST''
			ELSE CAST(cd.[hour] AS VARCHAR(10))
			END [hour]
		, v.item [volume]
		, CASE v.item 
			WHEN ''PMDQ/PRMDQ'' 
				THEN  dbo.FNANumberFormat(cd.path_mdq, ''v'') + ''/'' 
						+ dbo.FNANumberFormat(
							(
								cd.path_ormdq 
								-
								COALESCE (
									cd.received
									, IIF(to_loc_grp_name = ''storage'', 0, [dbo].[FNAGetGasSupplyDemandVol](supply_pos.position, demand_pos.position,''''))
									, 0
								)
							)
							, ''v'') 
			WHEN ''Fuel'' THEN CAST(cd.loss_factor AS VARCHAR(100))
			WHEN ''Rec'' THEN	CAST(
									CAST(
										ISNULL(cd.received,
											[dbo].[FNAGetGasSupplyDemandVol](supply_pos.position, demand_pos.position, IIF(to_loc_grp_name = ''storage'', ''storage_injection'', ''''))
										) 
										AS NUMERIC(38, ' + CAST(@round AS VARCHAR(10)) + ')
									)
									AS VARCHAR(50)
								)
																

			WHEN ''Del'' THEN	CAST(
									CAST(
										ISNULL(cd.delivered,
											[dbo].[FNAGetGasSupplyDemandVol](supply_pos.position, demand_pos.position, IIF(to_loc_grp_name = ''storage'', ''storage_injection'', ''''))
										) 
										AS NUMERIC(38, ' + CAST(@round AS VARCHAR(10)) + ')
									)
									AS VARCHAR(50)
								)
			ELSE NULL END [value]
			
	FROM ' + @contractwise_detail_mdq_hourly + ' cd
	INNER JOIN delivery_path dp ON dp.path_id = ISNULL(cd.single_path_id,cd.path_id)
	LEFT JOIN delivery_path_detail dpd ON dpd.path_id = cd.path_id and dpd.path_name = cd.single_path_id
	CROSS JOIN (values(''PMDQ/PRMDQ''),(''Rec''),(''Fuel''),(''Del'')) v (item)
	OUTER APPLY (
		SELECT 
			IIF(cd.is_dst = 1
				, SUM(dst_pos.position) --for dst hour actual position
				, SUM(hp.position - ISNULL(dst_pos.position,0))
			) [position]
		FROM ' + @hourly_pos_info +  ' hp
		LEFT JOIN ' + @hourly_pos_info +  ' dst_pos
			ON dst_pos.source_deal_detail_id = hp.source_deal_detail_id
			AND dst_pos.hour = 25
			AND hp.hour = 21			
		WHERE hp.hour = cd.hour
			AND hp.term_start = cd.term_start
			AND hp.location_id = cd.from_loc_id
			' + ISNULL('AND hp.source_deal_header_id IN (' + @receipt_deals_id + ')', '') + '
		GROUP BY hp.location_id, hp.term_start, hp.[hour]
	) supply_pos
	OUTER APPLY (
		SELECT 
			IIF(cd.is_dst = 1
				, SUM(dst_pos.position) --for dst hour actual position
				, SUM(hp.position - ISNULL(dst_pos.position,0))
			) [position]
		FROM ' + @hourly_pos_info +  ' hp
		LEFT JOIN ' + @hourly_pos_info +  ' dst_pos
			ON dst_pos.source_deal_detail_id = hp.source_deal_detail_id
			AND dst_pos.hour = 25
			AND hp.hour = 21
		WHERE hp.hour = cd.hour
			AND hp.term_start = cd.term_start
			AND hp.location_id = cd.to_loc_id
			' + ISNULL('AND hp.source_deal_header_id IN (' + @delivery_deals_id + ')', '') + '
		GROUP BY hp.location_id, hp.term_start, hp.[hour]
	) demand_pos
	WHERE cd.from_loc_id IN (' + @from_location + ')
		AND cd.to_loc_id IN (' + @to_location + ')
		AND cd.path_id = ' + CAST(@delivery_path AS VARCHAR(10)) + '
		AND (cd.group_path = ''y'' OR cd.contract_id = ' + CAST(ISNULL(@contract_id, '''''') AS VARCHAR(10)) + ')
		AND CAST(cd.hour AS VARCHAR(10)) IN (' + @period_from_temp + ')
	'
	EXEC(@sql)
	--print(@sql)
	--select * from #tmp_subgrid_data
	--return

	SELECT @pivot_hr_cols = STUFF(( SELECT '],[' + [hour]
		FROM #tmp_subgrid_data
		GROUP BY [hour]
		ORDER BY CAST(LEFT([hour],2) AS INT)
		FOR XML PATH('')),1,2,'') + ']'

	SET @sql = '
	SELECT * 
	FROM (
		SELECT * FROM #tmp_subgrid_data
	) s
	PIVOT (
		MAX(VALUE)
		FOR [hour] in (' + @pivot_hr_cols + ')
	) AS pvt
	ORDER BY delivery_path_detail_id,CASE [volume] WHEN ''PMDQ/PRMDQ'' THEN 1 WHEN ''Rec'' THEN 3 WHEN ''Fuel'' THEN 4 WHEN ''Del'' THEN 5 END
	' 
	--PRINT(@sql)
	EXEC(@sql)

END
ELSE IF @flag = 's2' --Save/Update manual schedule subgrid hourly data
BEGIN
	BEGIN TRY
		DECLARE @idoc_s2 INT
		IF OBJECT_ID('tempdb..#hourly_schd_vol') IS NOT NULL 
			DROP TABLE #hourly_schd_vol
		EXEC sp_xml_preparedocument @idoc_s2 OUTPUT, @xml_manual_vol
	
		SELECT *
		INTO #hourly_schd_vol
		FROM OPENXML(@idoc_s2,'/Root/PSRecordset',2)
		WITH (
			from_loc_id			INT			'@from_loc_id',
			to_loc_id			INT			'@to_loc_id',
			path_id				INT			'@path_id',
			contract_id			INT			'@contract_id',
			[hour]				VARCHAR(10)	'@hour',
			[is_dst]			INT			'@is_dst',
			received			FLOAT		'@received',
			delivered			FLOAT		'@delivered',
			path_rmdq			FLOAT		'@path_rmdq',
			storage_asset_id	INT			'@storage_asset_id'		
		)
		
		--update hourly contractwise table
		SET @sql = '
		UPDATE cd
			SET cd.received = scv.received, 
				cd.delivered = scv.delivered,
				cd.path_rmdq = scv.path_rmdq,
				cd.storage_asset_id = scv.storage_asset_id
		FROM ' + @contractwise_detail_mdq_hourly + ' cd
		INNER JOIN #hourly_schd_vol scv 
			ON cd.from_loc_id = scv.from_loc_id
			AND cd.to_loc_id = scv.to_loc_id
			AND scv.path_id = cd.path_id 
			AND scv.contract_id = cd.contract_id
			AND scv.[hour] = cd.[hour] 
			AND ISNULL(scv.[is_dst], 0) = ISNULL(cd.[is_dst], 0)
		'
		--print(@sql)
		EXEC(@sql)
		
		
		--update daily contractwise table
		SET @sql = '
		UPDATE cd
		SET cd.received = cd_hrly.received
			, cd.delivered = cd_hrly.delivered
			, cd.path_rmdq = cd_hrly.path_rmdq
			, cd.storage_asset_id = cd_hrly.storage_asset_id
		FROM ' + @contractwise_detail_mdq + ' cd
		CROSS APPLY (
			SELECT  SUM(cdh.received) [received]
				, SUM(cdh.delivered) [delivered]
				, SUM(cdh.path_rmdq) [path_rmdq]
				, NULLIF(MIN(ISNULL(cdh.storage_asset_id, -1)), -1) [storage_asset_id]
			FROM ' + @contractwise_detail_mdq_hourly + ' cdh
			WHERE cdh.from_loc_id = cd.from_loc_id
				AND cdh.to_loc_id = cd.to_loc_id
				AND cdh.path_id = cd.path_id 
				AND cdh.contract_id = cd.contract_id
			GROUP BY cdh.from_loc_id, cdh.to_loc_id, cdh.path_id, cdh.contract_id
		) cd_hrly
		'

		--print @sql
		EXEC(@sql)

		DECLARE @return_data_json NVARCHAR(2000) = ''
		
		--box id used when saving deal from flow deal match
		DECLARE @query NVARCHAR(2000) = '
		SET @result = (
			SELECT MAX(cdh.box_id) [box_id]
				, CAST(SUM(cdh.received) AS NUMERIC(20,4)) [box_total_rec]
				, CAST(SUM(cdh.delivered) AS NUMERIC(20,4)) [box_total_del]
				, CAST(AVG(cdh.delivered) AS NUMERIC(20,4)) [box_avg_rec]
				, CAST(AVG(cdh.delivered) AS NUMERIC(20,4)) [box_avg_del]
			FROM ' + @contractwise_detail_mdq_hourly + ' cdh
			INNER JOIN #hourly_schd_vol hsv
				ON cdh.from_loc_id = hsv.from_loc_id
				AND cdh.to_loc_id = hsv.to_loc_id 
				AND cdh.hour = hsv.hour
			FOR JSON PATH
			, INCLUDE_NULL_VALUES
			, WITHOUT_ARRAY_WRAPPER
		)
		'		
		EXEC sp_executesql @query, N'@result VARCHAR(2000) OUTPUT',@result = @return_data_json OUTPUT
		
		EXEC spa_ErrorHandler 0,
			'Flow Optimization',
			'spa_flow_optimization_hourly',
			'Success',
			'Changes have been saved successfully.',
			@return_data_json
	END TRY
	BEGIN CATCH
		DECLARE @err_msg varchar(5000) = ERROR_MESSAGE()
		EXEC spa_ErrorHandler 1,
			'Flow Optimization',
			'spa_flow_optimization_hourly',
			'Error',
			@err_msg,
			''
	END CATCH
END
ELSE IF @flag = 'VOL_LIMIT'
BEGIN		

	SET @sql  = '
		DECLARE @vol_limit_json NVARCHAR(MAX)
		SET @vol_limit_json = (
								SELECT pvt.[hr]
									, CAST(pvt.is_dst AS TINYINT) [is_dst]
									, IIF(pvt.[supply_position] > 0, ABS(pvt.[supply_position]), 0) [supply_position]
									, IIF(pvt.[demand_position] < 0, ABS(pvt.[demand_position]), 0) [demand_position]
									, pvt.[path_ormdq]
								FROM (
									SELECT ''supply_position'' [value_type]
										, sp.hour [hr]
										, cdh.is_dst
										, IIF(cdh.is_dst = 1, dst_pos.position, CAST(sp.position AS NUMERIC(38,20)) - ISNULL(dst_pos.position, 0)) [value]
									FROM ' + @hourly_pos_info + ' sp
									INNER JOIN ' + @contractwise_detail_mdq_hourly + ' cdh
										ON cdh.term_start = sp.term_start
										AND cdh.hour = sp.hour
										AND cdh.from_loc_id = sp.location_id
									LEFT JOIN ' + @hourly_pos_info +  ' dst_pos
										ON dst_pos.source_deal_detail_id = sp.source_deal_detail_id
										AND dst_pos.hour = 25
										AND sp.hour = 21
									WHERE 1 = 1 ' 
										+ ISNULL(' AND sp.source_deal_header_id IN (' + @receipt_deals_id + ')', '')
										+ ISNULL(' AND sp.location_id IN (' + @from_location + ')', '')
										+ ISNULL(' AND sp.term_start = ''' + CONVERT(VARCHAR(10), @flow_date_from, 21) + '''', '')
										+ '
									UNION ALL
									SELECT ''demand_position''
										, dp.hour
										, cdh.is_dst
										, IIF(cdh.is_dst = 1, dst_pos.position, CAST(dp.position AS NUMERIC(38,20)) - ISNULL(dst_pos.position, 0))
									FROM ' + @hourly_pos_info + ' dp
									INNER JOIN ' + @contractwise_detail_mdq_hourly + ' cdh
										ON cdh.term_start = dp.term_start
										AND cdh.hour = dp.hour
										AND cdh.to_loc_id = dp.location_id
									LEFT JOIN ' + @hourly_pos_info + ' dst_pos
										ON dst_pos.source_deal_detail_id = dp.source_deal_detail_id
										AND dst_pos.hour = 25
										AND dp.hour = 21
									WHERE 1 = 1' 
										+ ISNULL(' AND dp.source_deal_header_id IN (' + @delivery_deals_id + ')', '')
										+ ISNULL(' AND dp.location_id IN (' + @to_location + ')', '')
										+ ISNULL(' AND dp.term_start = ''' + CONVERT(VARCHAR(10), @flow_date_from, 21) + '''', '')
										+ '
									UNION ALL
									SELECT ''path_ormdq''
										, cd.hour
										, cd.is_dst
										, CAST(MAX(cd.path_ormdq) AS NUMERIC(38,20))
									FROM ' + @contractwise_detail_mdq_hourly + ' cd
									WHERE 1 = 1' 
										+ ISNULL(' AND cd.box_id = ' + @xml_manual_vol, '')
										+ ISNULL(' AND cd.path_id = ' + @path_ids, '')
										+ ISNULL(' AND cd.term_start = ''' + CONVERT(VARCHAR(10), @flow_date_from, 21) + '''', '')
										+ '
									GROUP BY cd.[hour], cd.is_dst, cd.path_id
								) src
								PIVOT (
									SUM([value]) FOR [value_type] IN ([supply_position], [demand_position], [path_ormdq])
								) AS pvt
								ORDER BY pvt.[hr]

								FOR JSON PATH   
								, INCLUDE_NULL_VALUES
								
							)
		SELECT @vol_limit_json [json]'
	EXEC(@sql)
	--print(@sql)
END

----------------------------------
