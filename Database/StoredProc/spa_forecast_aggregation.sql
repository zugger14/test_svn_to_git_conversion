IF OBJECT_ID(N'[dbo].[spa_forecast_aggregation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_forecast_aggregation]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
 Generates aggregated forecasted deal on hub, zone, channel, product level
 
 Parameters
 @hub :  Hub IDS
 @zone :  Zone IDS 
 @channel :  Channel IDS
 @product :  Product IDS
 @call_from :  Call From flag
 @flag :  
		'MISSING_FORECAST' - Gives list of all missing forecast for UIs
 @output_process_id :  Output Process Id
*/


CREATE PROCEDURE [dbo].[spa_forecast_aggregation]
	@hub NVARCHAR(MAX) = NULL
	, @zone NVARCHAR(MAX) = NULL
	, @channel NVARCHAR(MAX) = NULL
	, @product NVARCHAR(MAX) = NULL 
	, @call_from NVARCHAR(50) = NULL 
	, @flag NVARCHAR(50) = NULL 
	, @as_of_date DATETIME = NULL
	, @committed_uncommitted NCHAR(1) = 'b' 
	, @output_process_id NVARCHAR(200) = NULL OUTPUT 								
AS

/***** TEST CODE **********

--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

DECLARE @hub NVARCHAR(MAX)
		, @zone NVARCHAR(MAX) 
		, @channel NVARCHAR(MAX) 
		, @product NVARCHAR(MAX) 
		, @call_from CHAR(50)
		, @flag VARCHAR(50) 
		, @as_of_date DATETIME
		, @committed_uncommitted CHAR(1) = 'b'
		, @output_process_id VARCHAR(200) 

--Filter: IN_CILCO_LCI_FIXED, 
--as of date: 01/14/2020


--[spa_forecast_aggregation] zone='BGE' and channel='LCI' and product='FIXED'

--SET @hub = 'WH'
SET @zone = 'jcpl'
SET @channel = 'MCI'
SET @product = NULL
SET @as_of_date = NULL


--select * from udt_monthly_uncommitted_volume where zone='PSEG' and Channel='LCI' and product='LMP' order by term asc
 

--select * from udt_customer_deals_header_info where zone = 'FEOH' and channel = 'gov ag' and product = 'fixed'  and cust_name = 'City of Toledo'


--select * from udt_customer_deals_detail where zone = 'FEOH' and channel = 'gov ag' and product = 'fixed' and cust_name = 'City of Toledo'


--hub = 'ad' and zone = 'dlco' and channel = 'lci' and product = 'fixed pt'
--Drops all temp tables created in this scope.
EXEC spa_drop_all_temp_table

--exec [spa_forecast_aggregation] NULL, 'BGE', 'LCI', FIXED', 'Fixed PT'

/*
HARDCODED VALUE LIST:
1. Deal Template - 'Physical Retail Power'
2. Subsidairy - 'Retail - Power', 'Portfolio Mgmt'
3. Sub Book - LIKE '% Committed Load%'
4. internal_portfolio_id -'Product Group'
5. uom_id - 'MW'
6. udh.status - 'Terminate'
7. 13 UDFs
8. Channel - 'Load', 'Polr', 'Muni', 'STRUCT'

--RULES:
1. Loss multiplier should not be less than 1. It should always be greater than or equal to 1 OR it should be NULL, Loss multiplier NULL means 1.


CREATE NONCLUSTERED INDEX udt_customer_hourly_volume_info s
   ON dbo.udt_customer_hourly_volume_info (uid, term_date);

--exec [spa_forecast_aggregation] 'AD', 'PP, FEOH', 'LCI', 'Fixed'

*/

-- END OF TEST CODE*/
SET NOCOUNT ON;

DECLARE @process_id VARCHAR(500) =  dbo.FNAGetNewID()
DECLARE @as_of_date_first DATETIME
DECLARE @hardcoded_product VARCHAR(100) = 'LMP'


SET @committed_uncommitted = IIF(@committed_uncommitted IN( '', 'NULL'), 'b', @committed_uncommitted)

SET @hub = REPLACE (@hub, '!', ',')
SET @zone = REPLACE (@zone, '!', ',')
SET @channel = REPLACE (@channel, '!', ',')
SET @product  = REPLACE (@product, '!', ',')

SET @as_of_date = ISNULL(@as_of_date, GETDATE())

SET @as_of_date_first = [dbo].[FNAGetFirstLastDayOfMonth](@as_of_date, 'f')


DECLARE @template_name VARCHAR(100) = 'Physical Retail Power'
		, @capacity_template_name VARCHAR(100) = 'Power Capacity'
		, @transmission_template_name VARCHAR(100) = 'Power Transmission'
		, @product_group_type_id INT
		, @template_id INT
		, @capacity_template_id INT
		, @transmission_template_id INT
		, @sql NVARCHAR(MAX) 
		, @parm_definition NVARCHAR(1024)
		, @xfer_countertparty_id INT
		, @offset_countertparty_id INT
		, @xfer_contract_id INT
		, @offset_contract_id INT
		, @has_error BIT = 0
	    , @url VARCHAR(MAX)
		, @user_login_id  VARCHAR(100)= dbo.FNADBUser()  --= 'dmanandhar' --to do change
		, @onm_curve INT
		, @onm_counterparty INT
		, @onm_contract INT
		
DECLARE
		@after_insert_process_table     VARCHAR(300),
		@job_name						VARCHAR(200),
		@user_name						VARCHAR(200) = dbo.FNADBUser(),
		@job_process_id					VARCHAR(200) = dbo.FNAGETNEWID(),
		@missing_forecast_process_table	VARCHAR(300),
		@uom_id INT

SELECT @uom_id = source_uom_id 
FROM source_uom 
WHERE uom_id = 'MW'			

DECLARE @alert_process_table VARCHAR(300)		

SELECT @template_id = template_id 
FROM source_deal_header_template 
WHERE template_name =  @template_name

SELECT @capacity_template_id = template_id 
FROM source_deal_header_template 
WHERE template_name =  @capacity_template_name

SELECT @transmission_template_id = template_id 
FROM source_deal_header_template 
WHERE template_name =  @transmission_template_name

SELECT @offset_countertparty_id  = fs.counterparty_id 
FROM [dbo].[fas_subsidiaries] fs
INNER JOIN portfolio_hierarchy ph
	ON fs.fas_subsidiary_id = ph.entity_id
WHERE ph.entity_name = 'Portfolio Mgmt'

SELECT @xfer_countertparty_id = fs.counterparty_id 
FROM [dbo].[fas_subsidiaries] fs
INNER JOIN portfolio_hierarchy ph
	ON fs.fas_subsidiary_id = ph.entity_id
WHERE ph.entity_name ='Retail - Power'

SELECT @onm_curve = spcd.source_curve_def_id 
FROM udt_forecast_mapping ufm
INNER JOIN source_price_curve_def spcd
	ON spcd.curve_id = ufm.value
WHERE type = 'Onm Curve'

SELECT @onm_counterparty = sc.source_counterparty_id
FROM udt_forecast_mapping ufm
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = ufm.value
WHERE type = 'OnM Counterparty'

SELECT @onm_contract = cg.contract_id
FROM udt_forecast_mapping ufm
INNER JOIN contract_group cg
	ON cg.contract_name = ufm.value
WHERE ufm.type = 'OnM Contract'

SELECT @offset_contract_id = contract_id
FROM counterparty_contract_address 
WHERE counterparty_id = @offset_countertparty_id

SELECT @xfer_contract_id = contract_id
FROM counterparty_contract_address 
WHERE counterparty_id = @xfer_countertparty_id

SELECT  @product_group_type_id = type_id 
FROM static_data_type 
WHERE type_name = 'Product Group'

CREATE TABLE #temp_inserted_deal_header (
	source_deal_header_id INT
	, deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT
)


CREATE TABLE #temp_updated_deal_ids (
	source_deal_header_id INT
)


CREATE TABLE #temp_inserted_deal_header_polr_muni (
	source_deal_header_id INT
	, deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT
	, source_deal_header_id_original INT
	, deal_id_original VARCHAR(200) COLLATE DATABASE_DEFAULT
)

CREATE TABLE  #temp_aggregated_deal_header(
	aggregated_deal_header_id INT
)


CREATE TABLE  #temp_aggregated_deal_detail(
	aggregated_deal_detail_id INT
)

CREATE TABLE #temp_update_deal_header_polr_muni (
		source_deal_header_id INT,
		source_deal_detail_id INT
	)

CREATE TABLE #temp_volume_missing (
	hub VARCHAR(50) COLLATE DATABASE_DEFAULT,
	zone VARCHAR(50) COLLATE DATABASE_DEFAULT,
	channel VARCHAR(50) COLLATE DATABASE_DEFAULT,
	product VARCHAR(50) COLLATE DATABASE_DEFAULT,
	uid VARCHAR(600) COLLATE DATABASE_DEFAULT,
	profile_code  VARCHAR(600) COLLATE DATABASE_DEFAULT,
	term_start DATETIME,
	term_end DATETIME,
	[volume_type] VARCHAR(50) COLLATE DATABASE_DEFAULT

)

CREATE TABLE #udt_monthly_uncommitted_volume (
	hub VARCHAR(50) COLLATE DATABASE_DEFAULT
	, zone VARCHAR(50) COLLATE DATABASE_DEFAULT
	, channel VARCHAR(50) COLLATE DATABASE_DEFAULT
	, product VARCHAR(50) COLLATE DATABASE_DEFAULT
	, term DATETIME
	, offpeak_monthly_uncommitted_mwh NUMERIC(38, 20)
	, onpeak_monthly_uncommitted_mwh NUMERIC(38, 20)	
)

CREATE TABLE #temp_updated_profile_id (
	profile_id INT
)

CREATE TABLE #temp_inserted_profile_id (
	profile_id INT
)

CREATE TABLE #temp_error(
	process_id VARCHAR(200) COLLATE DATABASE_DEFAULT
	, code VARCHAR(50) COLLATE DATABASE_DEFAULT
	, module VARCHAR(50) COLLATE DATABASE_DEFAULT
	, [source] VARCHAR(50) COLLATE DATABASE_DEFAULT
	, [type] VARCHAR(50) COLLATE DATABASE_DEFAULT
	, [description] VARCHAR(1000) COLLATE DATABASE_DEFAULT
	, recommendation VARCHAR(500) COLLATE DATABASE_DEFAULT
) 

CREATE TABLE #exclude_group(channel NVARCHAR(500) COLLATE DATABASE_DEFAULT)

CREATE TABLE #delete_sdd (source_deal_detail_id  INT)


INSERT INTO #exclude_group (channel)
SELECT channel 
FROM udt_channel_mapping 
WHERE category = 'Shaped'

SELECT * 
INTO #udt_customer_deals_header_info
FROM udt_customer_deals_header_info
WHERE 1 = 2

SELECT * 
INTO #udt_customer_deals_header_info_polr_muni 
FROM udt_customer_deals_header_info
WHERE 1 = 2

SELECT * 
INTO #udt_customer_deals_header_info_uncommitted 
FROM udt_customer_deals_header_info
WHERE 1 = 2

BEGIN /**START OF DELETING INVALID DATA**/
	/*** START OF DELETE AGGREGATED DEALS WITH NON EXISTING HUB, ZONE, CHANNEL AND PRODUCT COMBINATION **/
	
	DECLARE @delete_source_deal_header_ids NVARCHAR(MAX)

	--Collect all committed deals
	SELECT @delete_source_deal_header_ids = ISNULL(@delete_source_deal_header_ids + ',', '') + CAST(sdh.source_deal_header_id AS NVARCHAR(10))  
	FROM udt_aggregated_deal_header agg
	LEFT JOIN udt_customer_deals_header_info udh
		ON  agg.zone = udh.zone
		AND agg.channel = udh.channel
		AND agg.product = udh.product		
		AND udh.status <> 'TERMINATE'
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id =  REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_')
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_Loss'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_xfer'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_offset'
			--OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_Uncommitted'
			--OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_OnM_Uncommitted'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_OnM'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_capacity'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_transmission'			
		)
	WHERE udh.zone IS NULL
	AND NULLIF(agg.uncommitted, 'No') IS NULL
	AND @committed_uncommitted in ('b', 'c')


	--Collect all uncommitted deals	
	SELECT  @delete_source_deal_header_ids = ISNULL(@delete_source_deal_header_ids + ',', '') + 
		CAST(sdh.source_deal_header_id AS NVARCHAR(10))  
	FROM udt_aggregated_deal_header agg
	LEFT JOIN udt_customer_deals_header_info udh
		ON  agg.zone = udh.zone
		AND agg.channel = udh.channel
		--AND agg.product = udh.product	
		AND udh.status <> 'TERMINATE'
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_Uncommitted'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_OnM_Uncommitted'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_capacity_uncommitted'
			OR sdh.deal_id = REPLACE(agg.hub, ' ', '_') + '_' + REPLACE(agg.zone, ' ', '_') + '_' + REPLACE(agg.channel, ' ', '_') + '_' + REPLACE(agg.product, ' ', '_') + '_transmission_uncommitted'
			)
	WHERE udh.zone IS NULL
		AND agg.uncommitted = 'Yes'
		AND @committed_uncommitted in ('b', 'u')
	
	SELECT sdh.source_deal_header_id, sdh.deal_id 
	INTO #temp_deleted_deal
	FROM dbo.SplitCommaSeperatedValues(@delete_source_deal_header_ids) t
	INNER JOIN  source_deal_header sdh
		ON sdh.source_deal_header_id = t.item

	CREATE TABLE #resultdatatable(dummy_column INT)

	DECLARE @col INT

	SET @sql = 'EXEC spa_source_deal_header @flag=''d'', @deal_ids = ''' + @delete_source_deal_header_ids + ''', @comments=''The hub, zone, channel and product was not present in the udt_customer_deals_header_info.'''

	EXEC spa_get_output_schema_or_data @sql_query = @sql
										,@process_table_name = '#resultdatatable'
										,@data_output_col_count = @col OUTPUT
										,@flag = 'data'

	/*** END OF DELETE AGGREGATED DEALS WITH NON EXISTING HUB, ZONE, CHANNEL AND PRODUCT COMBINATION **/

	/*** START OF DELETE GRABAGE UDT DATA **/
	DELETE ugdd
	FROM [udt_aggregated_deal_detail] ugdd
	LEFT JOIN source_deal_header sdh
		ON ugdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id IS NULL

	DELETE ugdh
	FROM [udt_aggregated_deal_header] ugdh
	LEFT JOIN source_deal_header sdh
		ON ugdh.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id IS NULL

	DELETE ucdd
	FROM udt_customer_deals_detail ucdd
	LEFT JOIN source_deal_header sdh
		ON ucdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id IS NULL

	DELETE ucv
	FROM udt_monthly_committed_volume ucv
	LEFT JOIN [udt_aggregated_deal_header] ugdh
		ON ugdh.hub = ucv.hub
		AND ugdh.zone = ucv.zone
		AND ugdh.channel = ucv.channel
		AND ugdh.product = ucv.product
		AND NULLIF(ugdh.uncommitted, 'No') IS NULL
	LEFT JOIN #exclude_group eg
		ON eg.channel = ucv.channel		
	WHERE ugdh.zone IS NULL		
		
		AND @committed_uncommitted IN ('b', 'c')
		AND eg.channel IS NULL	
		
	DELETE ucv
	FROM udt_monthly_uncommitted_volume ucv
	LEFT JOIN [udt_aggregated_deal_header] ugdh
		ON ugdh.zone = ucv.zone
		AND ugdh.channel = ucv.channel
		AND ugdh.product = ucv.product
		AND ugdh.uncommitted = 'Yes'
	WHERE ugdh.zone IS NULL
		AND @committed_uncommitted IN ('b', 'u')	

	/*** END OF DELETE GRABAGE UDT DATA **/

END /**END OF DELETING INVALID DATA**/

SET @sql = N'INSERT INTO #udt_customer_deals_header_info (
				status
				,agent_fee
				,ancillaries
				,arr_ftr
				,basis
				,capacity
				,channel
				,customer_count
				,cust_name
				,deal_date
				,energy
				,energy_lmp
				,entire_term_end
				,entire_term_start
				,green
				,hub
				,loss_multiplier
				,losses
				,manual_cost_adj
				,margin
				,nits_tec
				,priority_code
				,Product
				,risk
				,sales_rate
				,tax
				,uid
				,volume_multiplier
				,wpa
				,zone
				,profile_code
				,index_multiplier
				,create_user
				,create_ts
				,update_user
				,update_ts
				,capacityMW
				,transmissionMW	
				,uncommitted
			)
			SELECT 
				status
				,agent_fee
				,ancillaries
				,arr_ftr
				,basis
				,capacity
				,channel
				,customer_count
				,cust_name
				,deal_date
				,energy
				,energy_lmp
				,entire_term_end
				,entire_term_start
				,green
				,hub
				,loss_multiplier
				,losses
				,manual_cost_adj
				,margin
				,nits_tec
				,priority_code
				,Product
				,risk
				,sales_rate
				,tax
				,uid
				,volume_multiplier
				,wpa
				,zone				
				,profile_code
				,index_multiplier
				,create_user
				,create_ts
				,update_user
				,update_ts 
				,capacityMW
				,transmissionMW	
				,uncommitted
			FROM [dbo].[udt_customer_deals_header_info] udh
			'
			+ CASE WHEN @hub IS NULL THEN '' 
					ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@hub) h
								ON h.item = udh.hub
						'
				END
			+ CASE WHEN @zone IS NULL THEN '' 
					ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@zone) z
								ON z.item = udh.zone 
						'
				END
			+ CASE WHEN @channel IS NULL THEN '' 
					ELSE' INNER JOIN dbo.SplitCommaSeperatedValues(@channel) c
								ON c.item = udh.channel 
						'
				END
			+ CASE WHEN @product IS NULL THEN '' 
					ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@product) p
								ON p.item = udh.product 
						'
				END
			+ ' WHERE udh.status <> ''Terminate'''

			+ CASE @committed_uncommitted 
				WHEN 'b' THEN ''
				WHEN 'c' THEN ' AND NULLIF(uncommitted, ''No'') IS NULL ' 
				WHEN 'u' THEN ' AND ISNULL(uncommitted, ''No'') = ''Yes'' ' 
			 END
			+ CASE WHEN @as_of_date IS NULL THEN '' 
				ELSE ' AND udh.entire_term_end >= ''' + CAST(@as_of_date AS VARCHAR(50))+ ''''							
			END

SET @parm_definition = N'@hub VARCHAR(MAX), @zone VARCHAR(MAX), @channel VARCHAR(MAX), @product VARCHAR(MAX)';  

EXECUTE sp_executesql @sql, @parm_definition, @hub = @hub, @zone = @zone, @channel = @channel, @product = @product

--UPDATE REGION OF LOCATION BY HUB
UPDATE sml
	SET region = sdv.value_id
FROM static_data_value sdv
INNER JOIN udt_customer_deals_header_info udh
	ON udh.hub = sdv.code	
INNER JOIN source_minor_location sml
	ON sml.location_id = udh.zone
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE type_name  =  'Region'
AND sml.region IS NULL

--UPDATE HUB FROM ZONe
UPDATE udh 
	SET hub = sdv.code
FROM #udt_customer_deals_header_info udh
INNER JOIN source_minor_location sml
	ON sml.location_id = udh.zone
INNER JOIN static_data_value sdv
	ON sdv.value_id = sml.region

SELECT  hub
	, zone
	, channel
	, product
	, uncommitted 
	, MIN(entire_term_start) entire_term_start
	, MAX(entire_term_end) entire_term_end
INTO #temp_group
FROM #udt_customer_deals_header_info 
GROUP BY hub, zone, channel, product, uncommitted 

DELETE ddh
FROM #temp_group  tg
INNER JOIN forecast_profile fp
	ON tg.zone + '_' + REPLACE(tg.channel, ' ', '_') + '_' +  @hardcoded_product + '_UC' = fp.profile_name
INNER JOIN deal_detail_hour ddh
	ON ddh.profile_id = fp.profile_id
WHERE tg.uncommitted = 'yes'
	AND ddh.term_date > tg.entire_term_end

DELETE ddh
FROM #temp_group  tg
INNER JOIN forecast_profile fp
	ON hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') = fp.profile_name
INNER JOIN deal_detail_hour ddh
	ON ddh.profile_id = fp.profile_id
WHERE tg.uncommitted IS NULL
	AND ddh.term_date > tg.entire_term_end
		
--TO DO: add issue logs for subbook and others hardcoded values
BEGIN  /***START OF LOGGING ISSUES IN DATA**/
	SELECT ucdh.hub
		, ucdh.zone
		, ucdh.channel
		, ucdh.product
		, MAX(ucdh.energy_lmp) energy_lmp
	INTO #temp_check_for_issue
	FROM #udt_customer_deals_header_info ucdh
	LEFT JOIN #exclude_group eg
		ON eg.channel = ucdh.channel
	WHERE status <> 'terminate'
		AND eg.channel IS NULL
	GROUP BY ucdh.hub, ucdh.zone, ucdh.channel, ucdh.product


	INSERT INTO #temp_error (
		process_id
		, code
		, module
		, source
		, type
		, [description]
		, recommendation
	) 
	SELECT	DISTINCT @process_id,
			 'Warning'
			, 'Forecast Aggregation'
			, 'Missing Book'
			, 'Missing Book'
			,  tcfi.channel  --'"' + tcfi.channel + '" book under strategy "' + tcfi.hub + '" does not exists in the system.'
			, tcfi.hub --'Please check data.'
	FROM #temp_check_for_issue tcfi
	LEFT JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Retail - Power'
	LEFT JOIN portfolio_hierarchy stra
		ON stra.entity_name = 'Load'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level =1
	LEFT JOIN portfolio_hierarchy book
		ON tcfi.channel = book.entity_name
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	WHERE book.entity_id IS NULL
	UNION ALL
	SELECT DISTINCT @process_id,
			 'Warning'
			, 'Forecast Aggregation'
			, 'Missing Product'
			, 'Missing Product'
			,  tcfi.product --'Product "' + tcfi.product + '" does not present in the system.'
			, 'Please check product in Setup Static Data.'

	FROM #temp_check_for_issue tcfi
	LEFT JOIN static_data_value sdv_p
		ON sdv_p.code = tcfi.Product
		AND sdv_p.type_id = 39800 
	WHERE sdv_p.value_id IS NULL
	UNION ALL 
	SELECT DISTINCT @process_id,
			 'Warning'
			, 'Forecast Aggregation'
			, 'Missing Location'
			, 'Missing Location'
			, tcfi.zone  --'Location "' + tcfi.zone + '" does not present in the system.'
			, 'Please check location in Setup Location.'
	FROM #temp_check_for_issue tcfi
	LEFT JOIN source_minor_location sml
			ON sml.location_id = tcfi.zone
	WHERE sml.source_minor_location_id IS NULL
	UNION ALL
	SELECT  DISTINCT @process_id,
			 'Warning'
			, 'Forecast Aggregation'
			, 'Missing Index'
			, 'Missing Index'
			, tcfi.energy_lmp --'Index "' + tcfi.energy_lmp + '" does not present in the system.'
			, 'Please check index in Setup Price Curve.'
		
	FROM #temp_check_for_issue tcfi
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcfi.energy_lmp
	WHERE spcd.source_curve_type_value_id IS NULL
		AND tcfi.energy_lmp IS NOT NULL
	UNION ALL
	SELECT DISTINCT @process_id,
			 'Warning'
			, 'Forecast Aggregation'
			, 'Missing Customer'
			, 'Missing Customer'
			, ISNULL(udh.profile_code, udh.uid) --'Customer "' + ISNULL(udh.profile_code, udh.uid) + '" is missing from the imported data.'
			, 'Please check data.'

	FROM  #udt_customer_deals_header_info udh 
	LEFT JOIN #exclude_group eg
		ON eg.channel = udh.channel
	LEFT JOIN  (
		SELECT DISTINCT uid
		FROM [dbo].[udt_customer_hourly_volume_info] uhv
		UNION 
		SELECT DISTINCT uid
		FROM [dbo].[udt_customer_monthly_volume_info]
	) uhv
		ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
	WHERE uhv.uid IS NULL
		AND eg.channel IS NULL
	UNION ALL
	SELECT DISTINCT @process_id,
			 'Info'
			, 'Forecast Aggregation'
			, 'Deleted Deal'
			, 'Deleted Deal'
			, tdd.deal_id --'Customer "' + ISNULL(udh.profile_code, udh.uid) + '" is missing from the imported data.'
			, NULL
	FROM  #temp_deleted_deal tdd 

	SELECT DISTINCT hub, zone, channel, product 
	INTO #temp_excluded_group
	FROM #temp_error te
	INNER JOIN #udt_customer_deals_header_info udh
		ON te.description = udh.hub
	WHERE source = 'Missing Strategy'
	UNION
	SELECT DISTINCT  hub, zone, channel, product 
	FROM #temp_error te
	INNER JOIN #udt_customer_deals_header_info udh
		ON te.description = udh.channel
		AND te.recommendation = udh.hub
	WHERE source = 'Missing Book'
	UNION
	SELECT DISTINCT  hub, zone, channel, product 
	FROM #temp_error te
	INNER JOIN #udt_customer_deals_header_info udh
		ON te.description = udh.Product
	WHERE source = 'Missing Product'
	UNION
	SELECT DISTINCT hub, zone, channel, product 
	FROM #temp_error te
	INNER JOIN #udt_customer_deals_header_info udh
		ON te.description = udh.zone
	WHERE source = 'Missing Location'
	UNION
	SELECT DISTINCT  hub, zone, channel, product 
	FROM #temp_error te
	INNER JOIN #udt_customer_deals_header_info udh
		ON te.description = udh.energy_lmp
	WHERE source = 'Missing Index'

	INSERT INTO #temp_error (
		process_id
		, code
		, module
		, source
		, type
		, [description]
		, recommendation
	) 
	SELECT DISTINCT @process_id,
			 'Warning'
			, 'Forecast Aggregation'
			, 'Excluded Group'
			, 'Excluded Group'
			, 'Hub: <B>' + hub + '</B> zone: <B>' + zone + ' </B> Channel:  <B>' + Channel + ' </B> Product:  <B>' + Product + ' </B>'
			, 'Please check data.'
	FROM #temp_excluded_group

	DELETE udh
	FROM #udt_customer_deals_header_info udh
	INNER JOIN #temp_excluded_group teg
		ON udh.zone = teg.zone
		AND udh.channel = teg.channel
		AND udh.Product = teg.Product

	INSERT INTO source_system_data_import_status(
		process_id
		, code
		, module
		, source
		, type
		, [description]
		, recommendation
	) 
	SELECT MAX(process_id)
		, MAX(code)
		, MAX(module)
		, MAX(source)
		,  type
		, CAST(COUNT(1) AS VARCHAR(10) ) + ' ' + type + IIF(COUNT(1) > 1 , 's', '')
		, MAX(IIF(type = 'Missing Book', 'Please check data', recommendation ))
	FROM #temp_error
	GROUP BY type

	INSERT INTO source_system_data_import_status_detail(process_id,source,[type],[description]) 
	SELECT process_id
		, source
		, type
		, CASE type  
			WHEN 'Missing Strategy' THEN 'Strategy <B>' + [description] + '</B> does not exists in the system.'
			WHEN 'Missing Book' THEN '<B>' + [description] + '</B> book under strategy <B>' + [recommendation] + '</B> does not exists in the system.'
			WHEN 'Missing Product' THEN 'Product <B>' + [description] + '</B> does not present in the system.'
			WHEN 'Missing Location' THEN 'Location <B>' +[description] + '</B> does not present in the system.'
			WHEN 'Missing Index' THEN 'Index <B>' + [description] + '</B> does not present in the system.'
			WHEN 'Missing Customer' THEN 'Customer <B>' + [description] + '</B> is missing from the imported data.'
			WHEN 'Excluded Group' THEN  [description] 
			WHEN 'Deleted Deal' THEN  'Deal <B>' + [description] + '</B> is deleted.'
		END

	FROM #temp_error

	IF NOT EXISTS (SELECT 1 FROM #udt_customer_deals_header_info WHERE [status] <> 'TERMINATE')
	BEGIN

		INSERT INTO source_system_data_import_status(
			process_id
			, code
			, module
			, source
			, type
			, [description]
			, recommendation

		)
		SELECT @process_id,
			 'Info'
			, 'Forecast Aggregation'
			, 'Forecast Aggregation'
			, 'Forecast Aggregation'
			, 'No valid data to run forecast aggregation.'
			, NULL
		IF EXISTS(SELECT 1 FROM #temp_error)
		BEGIN
			SET @has_error = 1
		END

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
						'&spa=EXEC spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
		SELECT @url = '<a target="_blank" href="' + @url + '">' 

					+ 'No valid data to run forecast aggregation. </a>'
	
		EXEC  spa_message_board 'i', @user_login_id, NULL, 'Forecast Aggregation', @url, '', '', 's', NULL, NULL, @process_id

		EXEC spa_ErrorHandler 0,
				'Forecast Aggregation',
				'spa_forecast_aggregation',
				'Success',
				'No valid data to run forecast aggregation.',
				''

		RETURN;

	END
END /***END OF LOGGING ISSUES IN DATA**/

BEGIN /* START OF SEPARATING POLR, MUNI... AND UNCOMMITED DATA FROM REST OF DATA*/
	
	--Move polr, muni and struct data into new temp table
	DELETE udh 
	OUTPUT deleted.status
		,deleted.agent_fee
		,deleted.ancillaries
		,deleted.arr_ftr
		,deleted.basis
		,deleted.capacity
		,deleted.channel
		,deleted.customer_count
		,deleted.cust_name
		,deleted.deal_date
		,deleted.energy
		,deleted.energy_lmp
		,deleted.entire_term_end
		,deleted.entire_term_start
		,deleted.green
		,deleted.hub
		,deleted.loss_multiplier
		,deleted.losses
		,deleted.manual_cost_adj
		,deleted.margin
		,deleted.nits_tec
		,deleted.priority_code
		,deleted.Product
		,deleted.risk
		,deleted.sales_rate
		,deleted.tax
		,deleted.uid
		,deleted.volume_multiplier
		,deleted.wpa
		,deleted.zone				
		,deleted.profile_code
		,deleted.index_multiplier
		,deleted.create_user
		,deleted.create_ts
		,deleted.update_user
		,deleted.update_ts 
		,deleted.capacityMW
		,deleted.transmissionMW	
		,deleted.uncommitted
	INTO #udt_customer_deals_header_info_polr_muni
	FROM #udt_customer_deals_header_info udh
	INNER JOIN #exclude_group eg
		ON eg.channel = udh.channel

		--Move uncommitted data into new temp table
	DELETE udh 
	OUTPUT deleted.status
		,deleted.agent_fee
		,deleted.ancillaries
		,deleted.arr_ftr
		,deleted.basis
		,deleted.capacity
		,deleted.channel
		,deleted.customer_count
		,deleted.cust_name
		,deleted.deal_date
		,deleted.energy
		,deleted.energy_lmp
		,deleted.entire_term_end
		,deleted.entire_term_start
		,deleted.green
		,deleted.hub
		,deleted.loss_multiplier
		,deleted.losses
		,deleted.manual_cost_adj
		,deleted.margin
		,deleted.nits_tec
		,deleted.priority_code
		,deleted.Product
		,deleted.risk
		,deleted.sales_rate
		,deleted.tax
		,deleted.uid
		,deleted.volume_multiplier
		,deleted.wpa
		,deleted.zone				
		,deleted.profile_code
		,deleted.index_multiplier
		,deleted.create_user
		,deleted.create_ts
		,deleted.update_user
		,deleted.update_ts 
		,deleted.capacityMW
		,deleted.transmissionMW	
		,deleted.uncommitted
	INTO #udt_customer_deals_header_info_uncommitted
	FROM #udt_customer_deals_header_info udh
	WHERE uncommitted = 'Yes'

END /*END OF SEPARATING POLR, MUNI... AND UNCOMMITED DATA FROM REST OF DATA */

BEGIN  /** Start of getting book mapping **/
	
	--Original, Loss
	SELECT 
		b.hub,
		b.channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4
	INTO #temp_book_map --select * from #temp_book_map
	FROM (SELECT DISTINCT hub
						, channel
			FROM #udt_customer_deals_header_info
		) b
	LEFT JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Retail - Power'
	LEFT JOIN portfolio_hierarchy stra
		ON stra.entity_name = 'Load'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level = 1
	LEFT JOIN portfolio_hierarchy book
		ON book.entity_name = b.channel 
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name LIKE '%' + Channel + ' Committed Load'

	--O&M, O&M_uncommitted
	SELECT 
		b.channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4,
		IIF(CHARINDEX(' uncommitted', ssbm.logical_name) = 0, 'onm', 'onm_uncommitted' ) committed_uncommitted 
	INTO #temp_book_map_onm 
	FROM (SELECT DISTINCT  channel
			FROM #udt_customer_deals_header_info
			UNION 
			SELECT DISTINCT channel
			FROM #udt_customer_deals_header_info_uncommitted
			UNION 
			SELECT DISTINCT channel
			FROM #udt_customer_deals_header_info_polr_muni
		) b
	LEFT JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Retail - Power'
	LEFT JOIN portfolio_hierarchy stra
		ON stra.parent_entity_id = sub.entity_id
		AND stra.entity_name = 'O&M Costs'
		AND stra.hierarchy_level = 1
	LEFT JOIN portfolio_hierarchy book
		ON  book.entity_name = b.channel
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name IN ('O&M ' + b.channel + ' Committed', 'O&M ' + b.channel + ' Uncommitted' )
	
	--uncommitted
	SELECT 
		--b.hub,
		b.channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4
	INTO #temp_book_map_uncommitted
	FROM (SELECT DISTINCT  channel
			FROM #udt_customer_deals_header_info_uncommitted	
			UNION 
			SELECT DISTINCT channel
			FROM #udt_customer_deals_header_info_polr_muni pm
			WHERE pm.uncommitted = 'Yes'
		) b
	LEFT JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Retail - Power'
	LEFT JOIN portfolio_hierarchy stra
		ON stra.entity_name = 'Load'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level =1
	LEFT JOIN portfolio_hierarchy book
		ON book.entity_name = b.channel
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name LIKE '%' + Channel + ' Uncommitted Load'

	--Offset
	SELECT 
		b.hub,
		b.channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4
	INTO #temp_offset_book_map
	FROM (SELECT DISTINCT hub
						, channel
			FROM #udt_customer_deals_header_info
			UNION  
			SELECT DISTINCT hub
							, channel
			FROM #udt_customer_deals_header_info_polr_muni
		) b
	LEFT JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Retail - Power'
	LEFT JOIN portfolio_hierarchy stra
		ON stra.entity_name = 'Load'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level =1
	LEFT JOIN portfolio_hierarchy book
		ON book.entity_name = b.channel 
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name LIKE '%' + Channel + ' Xfer To PM'

	--Transfer
	SELECT 
		b.hub,
		'Load' channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4
	INTO #temp_transfer_book_map
	FROM (	SELECT DISTINCT hub							
			FROM #udt_customer_deals_header_info
			UNION  
			SELECT DISTINCT hub						
			FROM #udt_customer_deals_header_info_polr_muni
		) b
	INNER JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Portfolio Mgmt'
	INNER JOIN portfolio_hierarchy stra
		ON stra.entity_name = 'Portfolio Mgmt'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level =1
	INNER JOIN portfolio_hierarchy book
		ON  book.entity_name = 'Load'
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name = 'Load Xfer from Retail'  --Load here is book
	
	--Capacity, Capacity_uncommitted
	SELECT 
		b.zone,
		b.channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4,
		IIF(CHARINDEX(' Uncommitted', ssbm.logical_name) = 0, 'capacity', 'capacity_uncommitted' ) committed_uncommitted
	INTO #temp_capacity_book_map   
	FROM (	SELECT DISTINCT zone, channel 					
			FROM #udt_customer_deals_header_info   
			WHERE NULLIF(capacityMW, '') IS NOT NULL
			UNION 
			SELECT DISTINCT zone, channel 					
			FROM #udt_customer_deals_header_info_uncommitted   
			--WHERE NULLIF(capacityMW, '') IS NOT NULL
			UNION 
			SELECT DISTINCT zone, channel	
			FROM #udt_customer_deals_header_info_polr_muni
			WHERE( (uncommitted IS NULL AND  NULLIF(capacityMW, '') IS NOT NULL)
				OR (uncommitted = 'yes'))
		) b
	INNER JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Capacity'
	INNER JOIN portfolio_hierarchy stra
		ON  stra.entity_name = 'Obligation'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy book
		ON  book.entity_name = b.Channel
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name LIKE  '%Committed Obligation'
	

	--Transmission, Transmission_uncommitted
	SELECT 
		b.zone,
		b.channel,
		ssbm.book_deal_type_map_id sub_book,	
		ssbm.source_system_book_id1,	
		ssbm.source_system_book_id2,	
		ssbm.source_system_book_id3,	
		ssbm.source_system_book_id4,
		IIF(CHARINDEX(' Uncommitted', ssbm.logical_name) = 0, 'Transmission', 'Transmission_uncommitted' ) committed_uncommitted
	INTO #temp_transmission_book_map
	FROM (	SELECT DISTINCT zone, channel 					
			FROM #udt_customer_deals_header_info
			WHERE NULLIF(transmissionMW, '') IS NOT NULL			
			UNION 
			SELECT DISTINCT zone, channel 					
			FROM #udt_customer_deals_header_info_uncommitted   
			--WHERE NULLIF(transmissionMW, '') IS NOT NULL
			UNION 
			SELECT DISTINCT zone, channel 				
			FROM #udt_customer_deals_header_info_polr_muni
			WHERE( (uncommitted IS NULL  AND  NULLIF(transmissionMW, '') IS NOT NULL)
					OR (uncommitted = 'yes'))
			
		) b
	INNER JOIN portfolio_hierarchy sub
		ON sub.entity_name = 'Transmission'
	INNER JOIN portfolio_hierarchy stra
		ON stra.entity_name = 'Obligation'
		AND stra.parent_entity_id = sub.entity_id
		AND stra.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy book
		ON  book.entity_name = b.channel
		AND book.parent_entity_id = stra.entity_id
		AND book.hierarchy_level = 0
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.entity_id
	WHERE ssbm.logical_name LIKE '%committed Obligation' 


END /** End of getting book mapping **/

/**
Different type of deals i.e.
	1. Original
	2. Loss
	3. transfer 
	4. offset
	5. OnM
	6. capacity
	7. Transmission
	8. uncommitted
	9. OnM_Uncommitted
	10. capacity_uncommitted
	11. Transmission_uncommitted
are needed to be created for each combination of hub, zone, channel and product

**/

SELECT  dbo.fnagetnewid() id		
		, l.type	
		, ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, ucdh.product 
		, MAX(sdv_p.value_id) internal_portfolio_id
		, MIN(ucdh.deal_date) deal_date		
		, MIN(ucdh.entire_term_start) entire_term_start
		, MAX(EOMONTH(ucdh.entire_term_end)) entire_term_end
		, hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') deal_id
		, MAX(energy_lmp) formula_curve_id
INTO #temp_customer_deals_header_info
FROM #udt_customer_deals_header_info ucdh  
INNER JOIN static_data_value sdv_p
	ON sdv_p.code = ucdh.Product
	AND sdv_p.type_id = 39800 --@product_group_type_id
CROSS JOIN (
	SELECT 'Loss' type
	UNION ALL
	SELECT 'Original'
	UNION ALL
	SELECT 'OnM'
) l
WHERE ucdh.status <> 'Terminate'
GROUP BY ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, ucdh.product
		, l.type

UNION ALL 
SELECT  dbo.fnagetnewid() id		
		, l.type type	
		, ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, ucdh.product 
		, MAX(sdv_p.value_id) internal_portfolio_id
		, MIN(ucdh.deal_date) deal_date		
		, MIN(ucdh.entire_term_start) entire_term_start
		, MAX(EOMONTH(ucdh.entire_term_end)) entire_term_end
		, hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') deal_id
		, MAX(energy_lmp) formula_curve_id
FROM #udt_customer_deals_header_info_uncommitted ucdh 
INNER JOIN static_data_value sdv_p
	ON sdv_p.code = ucdh.Product
	AND sdv_p.type_id = 39800 --@product_group_type_id
CROSS JOIN (
	SELECT 'uncommitted' type
	UNION ALL
	SELECT 'onm_uncommitted'
) l
WHERE ucdh.status <> 'Terminate'
GROUP BY ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, ucdh.product
		, l.type

SELECT dbo.fnagetnewid() id		
		, t.type
		, zone
		, hub
		, channel
		, product 
		, internal_portfolio_id
		, deal_date		
		, entire_term_start
		, entire_term_end
		, hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') deal_id
		, formula_curve_id
INTO #temp_customer_deals_header_info_transfer
FROM #temp_customer_deals_header_info tdh
CROSS JOIN (
	SELECT 'xfer' type
	UNION ALL
	SELECT 'offset'
) t
WHERE tdh.type = 'Loss' 
	AND formula_curve_id IS NULL 

SELECT DISTINCT dbo.fnagetnewid() id		
		, 'capacity' type
		, tdh.zone
		, tdh.hub
		, tdh.channel
		, tdh.product 
		, tdh.internal_portfolio_id
		, tdh.deal_date		
		, tdh.entire_term_start
		, tdh.entire_term_end
		, REPLACE(tdh.hub, ' ', '_') + '_' + REPLACE(tdh.zone, ' ', '_') + '_' + REPLACE(tdh.channel, ' ', '_') + '_' + REPLACE(tdh.product, ' ', '_') deal_id
		, formula_curve_id		
INTO #temp_customer_deals_header_info_ct
FROM #temp_customer_deals_header_info tdh  
CROSS APPLY( 
	SELECT DISTINCT hub, zone , channel,product 
	FROM #udt_customer_deals_header_info udh
	WHERE tdh.hub = udh.hub
		AND tdh.zone = udh.zone
		AND tdh.channel = udh.channel
		AND tdh.Product = udh.Product
		AND capacityMW IS NOT NULL
)a
WHERE type = 'loss'
UNION ALL
SELECT DISTINCT dbo.fnagetnewid() id		
		, 'transmission'
		, tdh.zone
		, tdh.hub
		, tdh.channel
		, tdh.product 
		, tdh.internal_portfolio_id
		, tdh.deal_date		
		, tdh.entire_term_start
		, tdh.entire_term_end
		, REPLACE(tdh.hub, ' ', '_') + '_' + REPLACE(tdh.zone, ' ', '_') + '_' + REPLACE(tdh.channel, ' ', '_') + '_' + REPLACE(tdh.product, ' ', '_') deal_id
		, formula_curve_id		
FROM #temp_customer_deals_header_info tdh  
CROSS APPLY( 
	SELECT DISTINCT hub, zone , channel,product 
	FROM #udt_customer_deals_header_info udh
	WHERE tdh.hub = udh.hub
		AND tdh.zone = udh.zone
		AND tdh.channel = udh.channel
		AND tdh.Product = udh.Product
		AND transmissionMW IS NOT NULL
)a
WHERE type = 'loss'
UNION ALL
SELECT DISTINCT dbo.fnagetnewid() id		
		, 'capacity_uncommitted'
		, tdh.zone
		, tdh.hub
		, tdh.channel
		, tdh.product 
		, tdh.internal_portfolio_id
		, tdh.deal_date		
		, tdh.entire_term_start
		, tdh.entire_term_end
		, REPLACE(tdh.hub, ' ', '_') + '_' + REPLACE(tdh.zone, ' ', '_') + '_' + REPLACE(tdh.channel, ' ', '_') + '_' + REPLACE(tdh.product, ' ', '_') deal_id
		, formula_curve_id		
FROM #temp_customer_deals_header_info tdh  
CROSS APPLY( 
	SELECT DISTINCT hub, zone , channel,product 
	FROM #udt_customer_deals_header_info_uncommitted udh
	WHERE tdh.hub = udh.hub
		AND tdh.zone = udh.zone
		AND tdh.channel = udh.channel
		AND tdh.Product = udh.Product
		--AND capacityMW IS NOT NULL

)a
WHERE type = 'uncommitted'
UNION ALL
SELECT DISTINCT dbo.fnagetnewid() id		
		, 'transmission_uncommitted'
		, tdh.zone
		, tdh.hub
		, tdh.channel
		, tdh.product 
		, tdh.internal_portfolio_id
		, tdh.deal_date		
		, tdh.entire_term_start
		, tdh.entire_term_end
		, REPLACE(tdh.hub, ' ', '_') + '_' + REPLACE(tdh.zone, ' ', '_') + '_' + REPLACE(tdh.channel, ' ', '_') + '_' + REPLACE(tdh.product, ' ', '_') deal_id
		, formula_curve_id		
FROM #temp_customer_deals_header_info tdh  
CROSS APPLY( 
	SELECT DISTINCT hub, zone , channel,product 
	FROM #udt_customer_deals_header_info_uncommitted udh
	WHERE tdh.hub = udh.hub
		AND tdh.zone = udh.zone
		AND tdh.channel = udh.channel
		AND tdh.Product = udh.Product
		--AND transmissionMW IS NOT NULL
)a
WHERE type = 'uncommitted'


SELECT  dbo.fnagetnewid() id		
		, l.type
		, ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, ucdh.product 
		, MAX(sdv_p.value_id) internal_portfolio_id
		, MIN(ucdh.deal_date) deal_date		
		, MIN(ucdh.entire_term_start) entire_term_start
		, MAX(EOMONTH(ucdh.entire_term_end)) entire_term_end
		, uid deal_id
		, MAX(energy_lmp) formula_curve_id
		, MIN(ucdh.sales_rate) sales_rate
		, MIN(ucdh.energy) energy
		, MAX(ucdh.capacityMW) capacityMW
		, MAX(ucdh.transmissionMW) transmissionMW
INTO #temp_customer_deals_header_info_polr_muni
FROM #udt_customer_deals_header_info_polr_muni ucdh 
INNER JOIN source_deal_header sdh
	ON ucdh.uid = sdh.deal_id	
INNER JOIN static_data_value sdv_p
	ON sdv_p.code = ucdh.Product
	AND sdv_p.type_id = 39800 --@product_group_type_id
CROSS JOIN (
	SELECT 'Loss' type
	UNION ALL
	SELECT 'Xfer' 
	UNION ALL
	SELECT 'Offset'
	UNION ALL
	SELECT 'Capacity' type
	UNION ALL
	SELECT 'Transmission'
	UNION ALL
	SELECT 'OnM'
	
) l
WHERE ucdh.status <> 'Terminate'
	AND (
			(
				l.type = 'Loss' 
				AND ucdh.loss_multiplier IS NOT NULL
			)
			OR 
			(
				l.type IN ('xfer', 'Offset') 
				AND energy_lmp IS NULL
			)
			OR l.type IN (	'Capacity'
							, 'Transmission'
							, 'OnM'
							)
		) 
		AND NULLIF(ucdh.uncommitted, 'No') IS NULL
		
GROUP BY ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, ucdh.product
		, l.type
		, uid


SELECT  dbo.fnagetnewid() id		
		, l.type
		, ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, @hardcoded_product product 
		, MAX(sdv_p.value_id) internal_portfolio_id
		, MIN(ucdh.deal_date) deal_date		
		, MIN(ucdh.entire_term_start) entire_term_start
		, MAX(EOMONTH(ucdh.entire_term_end)) entire_term_end
		, REPLACE(ucdh.hub, ' ', '_') + '_' + REPLACE(ucdh.zone, ' ', '_') + '_' + REPLACE(ucdh.channel, ' ', '_') + '_' + @hardcoded_product deal_id
		, NULL formula_curve_id
		, NULL sales_rate
		, AVG(ucdh.energy) energy
		, MAX(ucdh.energy_lmp) energy_lmp
		, MAX(ucdh.capacityMW) capacityMW
		, MAX(ucdh.transmissionMW) transmissionMW
INTO #temp_customer_deals_header_info_polr_muni_uncommitted
FROM #udt_customer_deals_header_info_polr_muni ucdh 
INNER JOIN static_data_value sdv_p
	ON sdv_p.code = ucdh.Product
	AND sdv_p.type_id = 39800 --@product_group_type_id
CROSS JOIN (
	SELECT 'Capacity_uncommitted' type
	UNION ALL
	SELECT 'Transmission_uncommitted'
	UNION ALL
	SELECT 'OnM_uncommitted'
	UNION ALL 
	SELECT 'uncommitted' type
	
) l
WHERE ucdh.status <> 'Terminate'
		AND ucdh.uncommitted = 'Yes'		
GROUP BY ucdh.zone
		, ucdh.hub
		, ucdh.channel
		, l.type

SELECT 
	zone
	, hub
	, channel
	, product
	, MIN(entire_term_start) term_start
	, MAX(EOMONTH(entire_term_end)) term_end,
    STUFF((SELECT ', ' + uid
           FROM #udt_customer_deals_header_info b 
           WHERE  a.zone = b.zone 
				AND a.hub = b.hub
				AND a.channel = b.channel
				AND a.product = b.product
          FOR XML PATH('')), 1, 2, '') uids
INTO #temp_agg_uid
FROM #udt_customer_deals_header_info a
GROUP BY zone, hub, channel, product

IF @flag = 'MISSING_FORECAST'
BEGIN
	--Check missing volume for Profile
	INSERT INTO #temp_volume_missing (
		hub 
		,zone 
		,channel 
		,product
		,uid
		,profile_code
		,term_start
		,term_end
		,[volume_type]
	)
	SELECT  udh.hub
			, udh.zone
			, udh.channel
			, udh.product
			, udh.uid 
			, udh.profile_code
			, DATEADD (MONTH , n-1 , t.term_start ) term_start
			, EOMONTH(DATEADD (MONTH , n-1 , t.term_start )) term_end
			, 'Profile' [volume_type]
	FROM #udt_customer_deals_header_info udh
	INNER JOIN #temp_agg_uid t
		ON udh.hub = t.hub
		AND udh.zone = t.zone
		AND udh.channel = t.channel
		AND udh.product = t.Product
	CROSS JOIN seq s
	LEFT JOIN [dbo].[udt_customer_hourly_volume_info] uhv
		ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
		AND DATEADD (MONTH , n-1 , t.term_start ) = uhv.term_date
		AND ISNULL(uhv.forecast_received, 'Y') = 'Y'
	WHERE profile_code IS NOT NULL
		AND DATEADD (MONTH , s.n-1 , t.term_start ) <= t.term_end
		AND uhv.customer_hourly_volume_info_id IS NULL	

	--Check missing volume for forecast
	INSERT INTO #temp_volume_missing (
		hub 
		,zone 
		,channel 
		,product
		,uid
		,profile_code
		,term_start
		,term_end
		,[volume_type]
	)
	SELECT  udh.hub
			, udh.zone
			, udh.channel
			, udh.product
			, udh.uid 
			, udh.profile_code
			, DATEADD (MONTH , n-1 , t.term_start ) term_start
			, EOMONTH(DATEADD (MONTH , n-1 , t.term_start )) term_end
			, 'Forecast' [volume_type]
	FROM #udt_customer_deals_header_info udh
	INNER JOIN #temp_agg_uid t
		ON udh.hub = t.hub
		AND udh.zone = t.zone
		AND udh.channel = t.channel
		AND udh.product = t.Product
	CROSS JOIN seq s
	LEFT JOIN [dbo].[udt_customer_hourly_volume_info] uhv
		ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
		AND DATEADD (MONTH , n-1 , t.term_start ) = uhv.term_date
	LEFT JOIN udt_customer_monthly_volume_info umv
		ON  udh.uid = umv.uid
		AND DATEADD (MONTH , n-1 , t.term_start ) = umv.term 
	WHERE udh.profile_code IS NULL
		AND DATEADD (MONTH , s.n-1 , t.term_start ) <= t.term_end
		AND umv.customer_monthly_volume_info_id IS NULL 
		AND	uhv.customer_hourly_volume_info_id IS NULL 

	SET @missing_forecast_process_table = dbo.FNAProcessTableName('missing_forecast_process_table', @user_name, @job_process_id)
			
	IF OBJECT_ID(@missing_forecast_process_table) IS NOT NULL
	BEGIN
		EXEC('DROP TABLE ' + @missing_forecast_process_table)
	END
				
	EXEC ('CREATE TABLE ' + @missing_forecast_process_table + '(	
			hub VARCHAR(50) ,
			zone VARCHAR(50) ,
			channel VARCHAR(50) ,
			product VARCHAR(50) ,
			uid VARCHAR(600) ,
			profile_code  VARCHAR(600) ,
			term_start DATETIME,
			term_end DATETIME,
			[volume_type] VARCHAR(50) 				
		)')

	
	SET @sql = 'INSERT INTO ' + @missing_forecast_process_table + '
				SELECT 
					hub 
					,zone 
					,channel 
					,product
					,uid
					,profile_code
					,term_start
					,term_end
					,[volume_type]				
				FROM #temp_volume_missing
				--ORDER BY [UID/Profile ID] , [Term Start]
				'
	EXEC(@sql)

	SET @output_process_id = @job_process_id

	RETURN; 
		
END 
BEGIN TRY	
	BEGIN TRAN

	UPDATE sdd	
		SET sdd.fixed_price = IIF(spcd.source_curve_def_id IS NULL, udhc.energy, NULL)
			, sdd.formula_curve_id =  spcd.source_curve_def_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #udt_customer_deals_header_info_polr_muni udhc
		ON udhc.uid = sdh.deal_id
	LEFT JOIN source_price_curve_def spcd
				ON spcd.curve_id = udhc.energy_lmp
				
	UPDATE sdh	
		SET sdh.pricing_type = IIF(spcd.source_curve_def_id IS NULL,sdh.pricing_type, 46701) --Indexed Price
			, sdh.description4 = udhc.sales_rate
	FROM source_deal_header sdh 
	INNER JOIN #udt_customer_deals_header_info_polr_muni udhc
		ON udhc.uid = sdh.deal_id
	LEFT JOIN source_price_curve_def spcd
				ON spcd.curve_id = udhc.energy_lmp

	UPDATE sdh 
		SET  sdh.description4 = pm.sales_rate 
	FROM #temp_customer_deals_header_info_polr_muni pm
	INNER JOIN source_deal_header sdh
		ON pm.deal_id + '_' + pm.type = sdh.deal_id

    UPDATE sdh
		SET sdh.description1 = sdh_o.description1
	FROM #temp_customer_deals_header_info_polr_muni pm
	INNER JOIN source_deal_header sdh
		ON pm.deal_id + '_' + pm.type = sdh.deal_id
	INNER JOIN source_deal_header sdh_o
		ON pm.deal_id = sdh_o.deal_id
	
	UPDATE sdd	
		SET  sdd.fixed_price = IIF(spcd.source_curve_def_id IS NULL, pm.energy, NULL)
			, sdd.formula_curve_id = spcd.source_curve_def_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #temp_customer_deals_header_info_polr_muni pm
		ON pm.deal_id + '_' + pm.type = sdh.deal_id	
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = pm.formula_curve_id

	----COPY SHAPED VOLUME FROM LOSS, XFER AND OFFSET DEAL
	DELETE sddh
	FROM #temp_customer_deals_header_info_polr_muni pm
	INNER JOIN source_deal_header sdh
		ON pm.deal_id + '_' + pm.type = sdh.deal_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd.source_deal_detail_id

	----COPY SHAPED VOLUME FROM ORIGINAL POLR AND MUNI TO LOSS, XFER AND OFFSET 
	INSERT INTO source_deal_detail_hour (
		source_deal_detail_id
		, term_date
		, hr
		, is_dst
		, volume
		, price
		, formula_id
		, granularity
		, schedule_volume
		, actual_volume
		, contractual_volume
		, period
	)
	OUTPUT INSERTED.source_deal_detail_id INTO #temp_update_deal_header_polr_muni(source_deal_detail_id)
	SELECT 
		sdd.source_deal_detail_id
		, sddh.term_date
		, sddh.hr
		, sddh.is_dst
		, sddh.volume
		, sddh.price
		, sddh.formula_id
		, sddh.granularity
		, sddh.schedule_volume
		, sddh.actual_volume
		, sddh.contractual_volume
		, sddh.period
	FROM #temp_customer_deals_header_info_polr_muni pm
	INNER JOIN source_deal_header sdh
		ON pm.deal_id + '_' + pm.type = sdh.deal_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_header sdh_o
		ON pm.deal_id = sdh_o.deal_id
	INNER JOIN source_deal_detail sdd_o
		ON sdd_o.source_deal_header_id = sdh_o.source_deal_header_id
		AND sdd_o.term_start = sdd.term_start
		AND sdd_o.term_end = sdd.term_end
		AND sdd_o.leg = sdd.leg
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd_o.source_deal_detail_id
		
	UPDATE sdd
	SET multiplier = IIF(RIGHT(sdh.deal_id,4) = 'Loss'
							, IIF((ISNULL(upm.loss_multiplier, 1) -1) < 0, 0, (ISNULL(upm.loss_multiplier, 1) -1))
							, (ISNULL(sdd_o.multiplier, 1) + IIF((ISNULL(upm.loss_multiplier, 1) -1) < 0, 0, (ISNULL(upm.loss_multiplier, 1) -1)) )
						) 
	OUTPUT deleted.source_deal_header_id INTO #temp_update_deal_header_polr_muni(source_deal_header_id)
	FROM #udt_customer_deals_header_info_polr_muni upm
	INNER JOIN #temp_customer_deals_header_info_polr_muni pm
		ON upm.uid = pm.deal_id
	INNER JOIN source_deal_header sdh
	ON (
			sdh.deal_id = pm.deal_id + '_' + pm.type
				
		)
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_header sdh_o
		ON sdh_o.deal_id = pm.deal_id
	INNER JOIN source_deal_detail sdd_o
		ON sdh_o.source_deal_header_id = sdd_o.source_deal_header_id
		and sdd_o.term_start = sdd.term_start
		AND sdd_o.term_end = sdd.term_end
		AND sdd_o.Leg = sdd.leg
		
	UPDATE t
	SET t.source_deal_header_id = sdd.source_deal_header_id 
	FROM  #temp_update_deal_header_polr_muni	t
	INNER JOIN source_deal_detail sdd
		ON t.source_deal_detail_id = sdd.source_deal_detail_id

	INSERT INTO forecast_profile(external_id,	profile_type,	available,	profile_name,	uom_id,	granularity)
	SELECT zone + '_' + REPLACE(channel, ' ', '_') + '_' +  @hardcoded_product + '_UC' external_id
			,  17500 profile_type
			, 1 available
			, zone + '_' + REPLACE(channel, ' ', '_') + '_' + @hardcoded_product + '_UC' profile_name
			, @uom_id uom_id
			, 982 granularity
	FROM  (SELECT DISTINCT hub,zone, channel, product, 0 is_polr  FROM #udt_customer_deals_header_info_uncommitted
			UNION 
			SELECT DISTINCT hub,zone, channel, product, 1 is_polr  FROM #udt_customer_deals_header_info_polr_muni
			WHERE uncommitted = 'Yes'
	) tau
	LEFT JOIN forecast_profile fp
		ON fp.profile_name =   zone + '_' + REPLACE(channel, ' ', '_') + '_' + IIF(tau.is_polr = 1, @hardcoded_product,  REPLACE(product, ' ', '_')) + '_UC'
	WHERE fp.profile_name IS NULL
	
	
	--inserts original, loss, xfer,offset,onm deals
	INSERT INTO source_deal_header(
		deal_id
		, deal_date	
		, entire_term_start
		, entire_term_end
		, internal_portfolio_id	
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4 
		, sub_book
		, contract_id
		, counterparty_id
		, deal_category_value_id
		, deal_sub_type_type_id
		, header_buy_sell_flag
		, option_flag
		, physical_financial_flag
		, source_deal_type_id
		, source_system_id
		, template_id
		, trader_id
		, commodity_id
		, deal_status
		, term_frequency
		, confirm_status_type
		, pricing_type
		, internal_desk_id
		, description4	
		, description1
		, profile_granularity
	) 
	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_deal_header --select * from #temp_inserted_deal_header
	
	SELECT --tcdh.type ,  
		tcdh.id
		, tcdh.deal_date	
		, tcdh.entire_term_start	
		, tcdh.entire_term_end
		, tcdh.internal_portfolio_id	
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id1
			WHEN 'offset' THEN tobm.source_system_book_id1
			WHEN 'onm' THEN onm.source_system_book_id1
			ELSE tbm.source_system_book_id1
		END
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id2
			WHEN 'offset' THEN tobm.source_system_book_id2
			WHEN 'onm' THEN onm.source_system_book_id2
			ELSE tbm.source_system_book_id2
		END
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id3
			WHEN 'offset' THEN tobm.source_system_book_id3
			WHEN 'onm' THEN onm.source_system_book_id3
			ELSE tbm.source_system_book_id3
		END
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id4
			WHEN 'offset' THEN tobm.source_system_book_id4
			WHEN 'onm' THEN onm.source_system_book_id4
			ELSE tbm.source_system_book_id4
		END
		, CASE tcdh.type 
			WHEN 'xfer'	THEN ttbm.sub_book
			WHEN 'offset' THEN tobm.sub_book
			WHEN 'onm' THEN onm.sub_book
			ELSE tbm.sub_book
		END
		, CASE tcdh.type 
			WHEN 'xfer' THEN
				ISNULL(@xfer_contract_id, sdht.contract_id)
			WHEN 'offset' THEN 
				ISNULL(@offset_contract_id, sdht.contract_id)
			WHEN 'onm' THEN 
				ISNULL(@onm_contract, sdht.contract_id)				
			ELSE sdht.contract_id
		  END 
		, CASE tcdh.type 
			WHEN 'xfer' THEN 
				ISNULL(@xfer_countertparty_id, sdht.counterparty_id)
			WHEN 'offset' THEN 				
				ISNULL(@offset_countertparty_id, sdht.counterparty_id)
			WHEN 'onm' THEN 
				ISNULL(@onm_counterparty, sdht.counterparty_id)
			ELSE sdht.counterparty_id 
		  END 
		, sdht.deal_category_value_id
		, sdht.deal_sub_type_type_id
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sdht.header_buy_sell_flag = 'b', 's', 'b') 
			ELSE sdht.header_buy_sell_flag 
		  END
		, sdht.option_flag
		, ISNULL(sdht.physical_financial_flag, 'p')
		, sdht.source_deal_type_id
		, sdht.source_system_id
		, sdht.template_id
		, sdht.trader_id
		, sdht.commodity_id
		, sdht.deal_status
		, sdht.term_frequency
		, sdht.confirm_status_type
		, IIF(tcdh.formula_curve_id IS NULL, sdht.pricing_type, 46701)
		, ISNULL(sdht.internal_desk_id, 17301) --IS NULL FORECASTED
		, NULL description4
		, NULL description1
		, NULL profile_granularity
	FROM 
	(
		SELECT id
			, deal_id
			, type
			, zone
			, hub
			, channel
			, product 
			, internal_portfolio_id
			, deal_date		
			, entire_term_start
			, entire_term_end
			, formula_curve_id
		FROM #temp_customer_deals_header_info 
		WHERE type NOT IN ('onm_uncommitted','uncommitted')
		UNION ALL
		SELECT id		
				, deal_id
				, type
				, zone
				, hub
				, channel
				, product 
				, internal_portfolio_id
				, deal_date		
				, entire_term_start
				, entire_term_end
				, formula_curve_id
		FROM #temp_customer_deals_header_info_transfer	
	) tcdh
	LEFT JOIN #temp_book_map tbm
		ON tcdh.hub = tbm.hub
		AND tcdh.channel = tbm.channel
		AND tcdh.type IN( 'Loss', 'Original')
	LEFT JOIN #temp_book_map_onm onm  --select * from #temp_book_map_onm
		ON tcdh.channel = onm.channel
		AND tcdh.type IN( 'onm')
		AND onm.committed_uncommitted = 'onm'
	LEFT JOIN #temp_transfer_book_map ttbm 
		ON tcdh.hub = ttbm.hub
		AND ttbm.channel = 'Load'
		AND tcdh.type = 'xfer'
	LEFT JOIN #temp_offset_book_map tobm
		ON tcdh.hub = tobm.hub
		AND tcdh.channel = tobm.channel 
		AND tcdh.type = 'offset'
	CROSS JOIN source_deal_header_template sdht
	LEFT JOIN source_deal_header sdh1
		ON sdh1.deal_id = tcdh.deal_id + IIF (tcdh.type = 'Original' , '',  '_' + tcdh.type) --TO DO: Change logic to avoid this join condition
	WHERE sdht.template_id = @template_id -- 2752 --
		AND sdh1.source_deal_header_id IS NULL	
	 
	 --inserts Uncommitted, onm_uncommitted Deals 
	 INSERT INTO source_deal_header(
		deal_id
		, deal_date	
		, entire_term_start
		, entire_term_end
		, internal_portfolio_id	
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4 
		, sub_book
		, contract_id
		, counterparty_id
		, deal_category_value_id
		, deal_sub_type_type_id
		, header_buy_sell_flag
		, option_flag
		, physical_financial_flag
		, source_deal_type_id
		, source_system_id
		, template_id
		, trader_id
		, commodity_id
		, deal_status
		, term_frequency
		, confirm_status_type
		, pricing_type
		, internal_desk_id
		, description4	
		, description1
		, profile_granularity
	) 
	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_deal_header
	SELECT  --tcdh.type ,
		tcdh.id
		, tcdh.deal_date	
		, tcdh.entire_term_start	
		, tcdh.entire_term_end
		, tcdh.internal_portfolio_id	
		, CASE  tcdh.type 
			
			WHEN 'uncommitted' THEN tbmu.source_system_book_id1
			WHEN 'onm_uncommitted' THEN onm.source_system_book_id1
		END
		, CASE  tcdh.type 
			WHEN 'uncommitted' THEN tbmu.source_system_book_id2			
			WHEN 'onm_uncommitted' THEN onm.source_system_book_id2
		END
		, CASE  tcdh.type 
			WHEN 'uncommitted' THEN tbmu.source_system_book_id3
			WHEN 'onm_uncommitted' THEN onm.source_system_book_id3
		END
		, CASE  tcdh.type 
			WHEN 'uncommitted' THEN tbmu.source_system_book_id4
			WHEN 'onm_uncommitted' THEN onm.source_system_book_id4
		END
		, CASE tcdh.type 
			WHEN 'uncommitted' THEN tbmu.sub_book
			WHEN 'onm_uncommitted' THEN onm.sub_book
		END
		, CASE tcdh.type 
			--WHEN 'xfer' THEN 
			--	IIF(@xfer_contract_id IS NULL, sdht.contract_id , @xfer_contract_id) 
			--WHEN 'offset' THEN 
			--	IIF(@offset_contract_id IS NULL, sdht.contract_id , @offset_contract_id) 
			WHEN 'onm_uncommitted' THEN 
				ISNULL(@onm_contract, sdht.contract_id)
			ELSE sdht.contract_id
		  END 
		, CASE tcdh.type 
			--WHEN 'xfer' THEN 
			--	IIF(@xfer_countertparty_id IS NULL, sdht.counterparty_id , @xfer_countertparty_id) 
			--WHEN 'offset' THEN 
			--	IIF(@offset_countertparty_id IS NULL, sdht.counterparty_id , @offset_countertparty_id) 
			WHEN 'onm_uncommitted' THEN 
				ISNULL(@onm_counterparty, sdht.counterparty_id)
			ELSE sdht.counterparty_id 
		  END 
		, sdht.deal_category_value_id
		, sdht.deal_sub_type_type_id
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sdht.header_buy_sell_flag = 'b', 's', 'b') 
			ELSE sdht.header_buy_sell_flag 
		  END
		, sdht.option_flag
		, ISNULL(sdht.physical_financial_flag, 'p')
		, sdht.source_deal_type_id
		, sdht.source_system_id
		, sdht.template_id
		, sdht.trader_id
		, sdht.commodity_id
		, sdht.deal_status
		, sdht.term_frequency
		, sdht.confirm_status_type
		, CASE tcdh.type 
			WHEN 'onm_uncommitted' THEN 46700  
			ELSE IIF(tcdh.formula_curve_id IS NULL, sdht.pricing_type, 46701)
		 END pricing_type
		, ISNULL(sdht.internal_desk_id, 17301) --IS NULL FORECASTED
		, NULL description4
		, NULL description1
		, NULL profile_granularity
	 FROM 
	(
		SELECT id	
			, deal_id
			, type
			, zone
			, hub
			, channel
			, product 
			, internal_portfolio_id
			, deal_date		
			, entire_term_start
			, entire_term_end
			, formula_curve_id
		FROM #temp_customer_deals_header_info
		WHERE type IN ('onm_uncommitted','uncommitted')
	) tcdh
	LEFT JOIN #temp_book_map_uncommitted tbmu   
		ON tcdh.channel = tbmu.channel
		AND tcdh.type = 'uncommitted'
	LEFT JOIN #temp_book_map_onm onm  
		ON tcdh.channel = onm.channel
		AND tcdh.type IN( 'onm_uncommitted')
		AND onm.committed_uncommitted = 'onm_uncommitted'
	CROSS JOIN source_deal_header_template sdht
	LEFT JOIN source_deal_header sdh1
		ON sdh1.deal_id = tcdh.deal_id + '_' + tcdh.type
	WHERE sdht.template_id = @template_id -- 2752 --
		AND sdh1.source_deal_header_id IS NULL
	
	--INSERT POLR AND MUNI DEALS
	INSERT INTO source_deal_header(
		deal_id
		, deal_date	
		, entire_term_start
		, entire_term_end
		, internal_portfolio_id	
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4 
		, sub_book
		, contract_id
		, counterparty_id
		, deal_category_value_id
		, deal_sub_type_type_id
		, header_buy_sell_flag
		, option_flag
		, physical_financial_flag
		, source_deal_type_id
		, source_system_id
		, template_id
		, trader_id
		, commodity_id
		, deal_status
		, term_frequency
		, confirm_status_type
		, pricing_type
		, internal_desk_id
		, description4	
		, description1
		, profile_granularity
	) 
	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_deal_header
	SELECT --tcdh.type,
		tcdh.deal_id + '_' + tcdh.type deal_id
		, tcdh.deal_date	
		, tcdh.entire_term_start	
		, tcdh.entire_term_end
		, tcdh.internal_portfolio_id	
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id1
			WHEN 'offset' THEN tobm.source_system_book_id1
			WHEN 'onm'  THEN tnbm.source_system_book_id1			
			ELSE sdh.source_system_book_id1
		END source_system_book_id1
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id2
			WHEN 'offset' THEN tobm.source_system_book_id2
			WHEN 'onm'  THEN tnbm.source_system_book_id2		
			ELSE sdh.source_system_book_id2
		END source_system_book_id2
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id3
			WHEN 'offset' THEN tobm.source_system_book_id3
			WHEN 'onm'  THEN tnbm.source_system_book_id3			
			ELSE sdh.source_system_book_id3
		END source_system_book_id3
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.source_system_book_id4
			WHEN 'offset' THEN tobm.source_system_book_id4
			WHEN 'onm'  THEN tnbm.source_system_book_id4
			ELSE sdh.source_system_book_id4
		END source_system_book_id4
		, CASE  tcdh.type 
			WHEN 'xfer'  THEN ttbm.sub_book
			WHEN 'offset' THEN tobm.sub_book
			WHEN 'onm'  THEN tnbm.sub_book			
			ELSE sdh.sub_book
		END sub_book
		, CASE tcdh.type 
			WHEN 'xfer' THEN 
				ISNULL(@xfer_contract_id, sdh.contract_id)
			WHEN 'offset' THEN 
				ISNULL(@offset_contract_id, sdh.contract_id)
			WHEN 'onm' THEN
				ISNULL(@onm_contract, sdh.contract_id)
			ELSE sdh.contract_id
		  END  contract_id
		, CASE tcdh.type 
			WHEN 'xfer' THEN 
				ISNULL(@xfer_countertparty_id, sdh.counterparty_id)
			WHEN 'offset' THEN 
				ISNULL(@offset_countertparty_id, sdh.counterparty_id)
			WHEN 'onm' THEN
				ISNULL(@onm_counterparty, sdh.counterparty_id) 
			ELSE sdh.counterparty_id 
		  END counterparty_id
		, sdh.deal_category_value_id
		, sdh.deal_sub_type_type_id
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sdh.header_buy_sell_flag = 'b', 's', 'b') 
			ELSE sdh.header_buy_sell_flag 
		  END header_buy_sell_flag
		, sdh.option_flag
		, sdh.physical_financial_flag
		, sdh.source_deal_type_id --TO DO: change source_deal_type_id for capacity and transmission
		, sdh.source_system_id
		, sdh.template_id  --TO DO: change template for capacity and transmission
		, sdh.trader_id
		, sdh.commodity_id --TO DO: all fiels like of C T
		, sdh.deal_status
		, sdh.term_frequency
		, sdh.confirm_status_type
		, IIF(tcdh.formula_curve_id IS NULL, sdh.pricing_type, 46701) formula_curve_id
		, ISNULL(sdh.internal_desk_id, 17301) internal_desk_id --IS NULL FORECASTED 
		, sdh.description4
		, sdh.description1
		, sdh.profile_granularity
	--select tcdh.deal_id ,* 
	FROM #temp_customer_deals_header_info_polr_muni tcdh--select * from #temp_customer_deals_header_info_polr_muni
	INNER JOIN source_deal_header sdh 
		ON sdh.deal_id = tcdh.deal_id  --select * from #udt_customer_deals_header_info_polr_muni
	LEFT JOIN #temp_book_map tbm
		ON tcdh.hub = tbm.hub
		AND tcdh.channel = tbm.channel
		AND tcdh.type = 'Loss'
	LEFT JOIN #temp_transfer_book_map ttbm -- select * from #temp_transfer_book_map
		ON tcdh.hub = ttbm.hub
		AND ttbm.channel = 'Load'
		AND tcdh.type = 'xfer'
	LEFT JOIN #temp_offset_book_map tobm --select * from #temp_offset_book_map
		ON tcdh.hub = tobm.hub
		AND tcdh.channel = tobm.channel 
		AND tcdh.type = 'offset'
	LEFT JOIN #temp_book_map_onm tnbm --select * from #temp_book_map_onm
		ON tcdh.channel = tnbm.channel 
		AND tnbm.committed_uncommitted = 'onm'
		AND tcdh.type = 'onm'	
	LEFT JOIN source_deal_header sdh1
		ON sdh1.deal_id = tcdh.deal_id + '_' + tcdh.type
	WHERE sdh1.source_deal_header_id IS NULL
		AND tcdh.type NOT IN ('capacity', 'transmission')
	
	--INSERT POLR AND MUNI DEALS UNCOMMITTED
	INSERT INTO source_deal_header(
		deal_id
		, deal_date	
		, entire_term_start
		, entire_term_end
		, internal_portfolio_id	
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4 
		, sub_book
		, contract_id
		, counterparty_id
		, deal_category_value_id
		, deal_sub_type_type_id
		, header_buy_sell_flag
		, option_flag
		, physical_financial_flag
		, source_deal_type_id
		, source_system_id
		, template_id
		, trader_id
		, commodity_id
		, deal_status
		, term_frequency
		, confirm_status_type
		, pricing_type
		, internal_desk_id
		, description4	
		, description1
		, profile_granularity
	) 
	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_deal_header
	SELECT --tcdh.type ,
		tcdh.deal_id + '_' + tcdh.type deal_id
		, tcdh.deal_date	
		, tcdh.entire_term_start	
		, tcdh.entire_term_end
		, tcdh.internal_portfolio_id	
		, CASE  tcdh.type 
			WHEN 'OnM_uncommitted'  THEN tnbm.source_system_book_id1			
			ELSE tbmu.source_system_book_id1
		END source_system_book_id1
		, CASE  tcdh.type 
			WHEN 'OnM_uncommitted'  THEN tnbm.source_system_book_id2		
			ELSE tbmu.source_system_book_id2
		END source_system_book_id2
		, CASE  tcdh.type 
			WHEN 'OnM_uncommitted'  THEN tnbm.source_system_book_id3
			ELSE tbmu.source_system_book_id3
		END source_system_book_id3
		, CASE  tcdh.type 
			WHEN 'OnM_uncommitted'  THEN tnbm.source_system_book_id4
			ELSE tbmu.source_system_book_id4
		END source_system_book_id4
		, CASE tcdh.type 
			WHEN 'OnM_uncommitted'  THEN tnbm.sub_book
			ELSE tbmu.source_system_book_id3
		END sub_book
		, CASE tcdh.type 
			--WHEN 'xfer' THEN 
			--	IIF(@xfer_contract_id IS NULL, sdh.contract_id , @xfer_contract_id) 
			--WHEN 'offset' THEN 
			--	IIF(@offset_contract_id IS NULL, sdh.contract_id , @offset_contract_id) 
			WHEN 'OnM_uncommitted' THEN
				ISNULL(@onm_contract, sdh.contract_id) 
			ELSE sdh.contract_id
		  END  contract_id
		, CASE tcdh.type 
			--WHEN 'xfer' THEN 
			--	IIF(@xfer_countertparty_id IS NULL, sdh.counterparty_id , @xfer_countertparty_id) 
			--WHEN 'offset' THEN 
			--	IIF(@offset_countertparty_id IS NULL, sdh.counterparty_id , @offset_countertparty_id) 
			WHEN 'OnM_uncommitted' THEN
				ISNULL(@onm_counterparty, sdh.counterparty_id) 
			ELSE sdh.counterparty_id 
		  END counterparty_id
		, sdh.deal_category_value_id
		, sdh.deal_sub_type_type_id
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sdh.header_buy_sell_flag = 'b', 's', 'b') 
			ELSE sdh.header_buy_sell_flag 
		  END header_buy_sell_flag
		, sdh.option_flag
		, sdh.physical_financial_flag
		, sdh.source_deal_type_id
		, sdh.source_system_id
		, sdh.template_id
		, sdh.trader_id
		, sdh.commodity_id
		, sdh.deal_status
		, sdh.term_frequency
		, sdh.confirm_status_type
		--, IIF(tcdh.formula_curve_id IS NULL, sdh.pricing_type, 46701) formula_curve_id 
		, CASE tcdh.type 
			WHEN 'onm_uncommitted' THEN 46700  
			ELSE 46701 
		  END pricing_type 
		, ISNULL(sdh.internal_desk_id, 17301) internal_desk_id --IS NULL FORECASTED
		, sdh.description4
		, sdh.description1
		, sdh.profile_granularity
	FROM #temp_customer_deals_header_info_polr_muni_uncommitted tcdh --select * from #temp_customer_deals_header_info_polr_muni_uncommitted

	LEFT JOIN #temp_book_map_onm tnbm --select * from #temp_book_map_onm
		ON tcdh.channel = tnbm.channel 
		AND tnbm.committed_uncommitted = 'onm_uncommitted'
		AND tcdh.type = 'onm_uncommitted'	
	LEFT JOIN #temp_book_map_uncommitted tbmu --select * from #temp_book_map_uncommitted
		ON tcdh.channel = tbmu.channel 
		AND tcdh.type = 'uncommitted'	
	LEFT JOIN source_deal_header sdh1
		ON sdh1.deal_id = tcdh.deal_id + '_' + tcdh.type
	CROSS JOIN source_deal_header_template sdh
	WHERE sdh1.source_deal_header_id IS NULL
		AND sdh.template_id = @template_id -- 2752 --
		AND tcdh.type NOT IN ('capacity_uncommitted', 'transmission_uncommitted')
	
	--INSERT Capacity, capacity_uncommitted for polr and others
	INSERT INTO source_deal_header(
		deal_id
		, deal_date	
		, entire_term_start
		, entire_term_end
		, internal_portfolio_id	
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4 
		, sub_book
		, contract_id
		, counterparty_id
		, deal_category_value_id
		, deal_sub_type_type_id
		, header_buy_sell_flag
		, option_flag
		, physical_financial_flag
		, source_deal_type_id
		, source_system_id
		, template_id
		, trader_id
		, commodity_id
		, deal_status
		, term_frequency
		, confirm_status_type
		, pricing_type
		, internal_desk_id
		, description4	
		, description1
		, profile_granularity
	) 
	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_deal_header
	SELECT --tcdh.type ,
		IIF(tcdh.is_polr = 1 ,  tcdh.deal_id + '_' + tcdh.type, tcdh.id) deal_id	 
		, tcdh.deal_date	
		, tcdh.entire_term_start	
		, tcdh.entire_term_end
		, tcdh.internal_portfolio_id	 
		, tbm.source_system_book_id1
		, tbm.source_system_book_id2		
		, tbm.source_system_book_id3
		, tbm.source_system_book_id4
		, tbm.sub_book
		, ISNULL(cg.contract_id, sdht.contract_id) contract_id
		, ISNULL(sc.source_counterparty_id, sdht.counterparty_id) counterparty_id 
		, ISNULL(sdv_r.value_id, sdht.deal_category_value_id) deal_category_value_id
		, sdht.deal_sub_type_type_id
		, 's' header_buy_sell_flag 
		, ISNULL(sdht.option_flag, 'n') option_flag 
		, ISNULL(sdht.physical_financial_flag, 'p') physical_financial_flag
		, ISNULL(sdt.source_deal_type_id, sdht.source_deal_type_id) source_deal_type_id
		, sdht.source_system_id
		, sdht.template_id
		, sdht.trader_id
		, ISNULL(sco.source_commodity_id, sdht.commodity_id) commodity_id
		, 5604 deal_status --'New'
		, 'm' term_frequency -- sdht.term_frequency
		, 17200 confirm_status_type --'Not Confirmed'
		, 46701 pricing_type --'Indexed Priced'          
		, ISNULL(17300, sdht.internal_desk_id) internal_desk_id --internal_deal_id "Deal Volume"
		, NULL description4
		, tcdh.channel description1
		, NULL profile_granularity
	 FROM  (
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start, entire_term_end, deal_id, formula_curve_id, 0 is_polr
			FROM #temp_customer_deals_header_info_ct
			UNION ALL 
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start, entire_term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni
			WHERE type IN ('capacity')
				AND capacityMW iS NOT NULL
			UNION ALL 
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start, entire_term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni_uncommitted  
			WHERE type IN ( 'capacity_uncommitted')
		)  tcdh 
	INNER JOIN #temp_capacity_book_map tbm
		ON tcdh.zone = tbm.zone
		AND tcdh.channel = tbm.channel	
		AND tcdh.type = tbm.committed_uncommitted
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Capacity'
	LEFT JOIN static_data_value sdv_c
		ON sdv_c.value_id = spcd.market_value_desc
	LEFT JOIN source_deal_type sdt
		ON deal_type_id = 'Capacity'		
	LEFT JOIN source_counterparty sc
		ON sc.counterparty_id = sdv_c.code
	OUTER APPLY (
		SELECT cg.contract_id 
		FROM counterparty_contract_address cca		
		INNER JOIN contract_group cg
			ON cg.contract_id = cca.contract_id 			
		WHERE cca.counterparty_id = sc.source_counterparty_id
		AND cg.contract_name = 'FES E Bilateral'
	) cg
	LEFT JOIN static_data_value sdv_r
		ON sdv_r.value_id = 475 --deal categoriy "Real"
	LEFT JOIN source_commodity sco
		on sco.source_commodity_id = 123 --'Power'
	CROSS JOIN source_deal_header_template sdht
	--LEFT JOIN udt_aggregated_deal_header uagh
	--	ON uagh.zone = tcdh.zone
	--	AND uagh.hub = tcdh.hub
	--	AND uagh.channel = tcdh.channel
	--	AND uagh.product = tcdh.product
	--	AND NULLIF(uagh.uncommitted, 'No')  IS NULL
	LEFT JOIN source_deal_header sdh1
		ON sdh1.deal_id = tcdh.deal_id + '_' + tcdh.type	
	WHERE sdht.template_id = @capacity_template_id -- 2761 -- select * from source_deal_header_template where template_name = 'power capacity'
		AND sdh1.source_deal_header_id IS NULL 
		--AND ((uagh.source_deal_header_id IS NULL AND tcdh.is_polr = 0)
		--		OR
		--		(sdh1.source_deal_header_id IS NULL AND tcdh.is_polr = 1)
		--	)
		AND tcdh.type IN ('capacity', 'capacity_uncommitted')
		
	--inserts transmission and Transmission_uncommitted for polr and others
	INSERT INTO source_deal_header(
		deal_id
		, deal_date	
		, entire_term_start
		, entire_term_end
		, internal_portfolio_id	
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4 
		, sub_book
		, contract_id
		, counterparty_id
		, deal_category_value_id
		, deal_sub_type_type_id
		, header_buy_sell_flag
		, option_flag
		, physical_financial_flag
		, source_deal_type_id
		, source_system_id
		, template_id
		, trader_id
		, commodity_id
		, deal_status
		, term_frequency
		, confirm_status_type
		, pricing_type
		, internal_desk_id
		, description4	
		, description1
		, profile_granularity
	) 
	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_deal_header
	SELECT --tcdh.type , 
		IIF(tcdh.is_polr = 1 ,  tcdh.deal_id + '_' + tcdh.type, tcdh.id) deal_id
		, tcdh.deal_date	
		, tcdh.entire_term_start	
		, tcdh.entire_term_end
		, tcdh.internal_portfolio_id	 
		, tbm.source_system_book_id1
		, tbm.source_system_book_id2		
		, tbm.source_system_book_id3
		, tbm.source_system_book_id4
		, tbm.sub_book
		, ISNULL(cg.contract_id, sdht.contract_id) contract_id
		, ISNULL(sc.source_counterparty_id, sdht.counterparty_id) counterparty_id 
		, ISNULL(sdv_r.value_id, sdht.deal_category_value_id) deal_category_value_id
		, sdht.deal_sub_type_type_id
		, 's' header_buy_sell_flag 
		, ISNULL(sdht.option_flag, 'n') option_flag 
		, ISNULL(sdht.physical_financial_flag, 'p') physical_financial_flag
		, ISNULL(sdt.source_deal_type_id, sdht.source_deal_type_id) source_deal_type_id
		, sdht.source_system_id
		, sdht.template_id
		, sdht.trader_id
		, ISNULL(sco.source_commodity_id, sdht.commodity_id) commodity_id
		, 5604 deal_status --'New'
		, 'm' term_frequency -- sdht.term_frequency
		, 17200 confirm_status_type --'Not Confirmed'
		, 46701 pricing_type --'Indexed Priced'
		, ISNULL(17300, sdht.internal_desk_id) internal_desk_id --internal_deal_id "Deal Volume"
		, NULL description4
		, tcdh.channel description1
		, NULL profile_granularity
		FROM  (
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start, entire_term_end, deal_id, formula_curve_id, 0 is_polr
			FROM #temp_customer_deals_header_info_ct
			UNION ALL 
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start, entire_term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni
			WHERE type IN ('Transmission')
				AND transmissionMW IS NOT NULL
			UNION ALL 
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start, entire_term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni_uncommitted
			WHERE type IN ('Transmission_uncommitted')
		)  tcdh 
	INNER JOIN #temp_transmission_book_map tbm
		ON tcdh.zone = tbm.zone
		AND tcdh.channel = tbm.channel	
		AND tcdh.type = tbm.committed_uncommitted

	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Transmission Cost'
	LEFT JOIN static_data_value sdv_c
		ON sdv_c.value_id = spcd.market_value_desc
	LEFT JOIN source_deal_type sdt
		ON deal_type_id = 'Transmission'		
	LEFT JOIN source_counterparty sc
		ON sc.counterparty_id = sdv_c.code
	OUTER APPLY (
		SELECT cg.contract_id 
		FROM counterparty_contract_address cca		
		INNER JOIN contract_group cg
			ON cg.contract_id = cca.contract_id 			
		WHERE cca.counterparty_id = sc.source_counterparty_id
		AND cg.contract_name = 'FES E Bilateral'
	) cg
	LEFT JOIN static_data_value sdv_r
		ON sdv_r.value_id = 475 --deal categoriy "Real"
	LEFT JOIN source_commodity sco
		on sco.source_commodity_id = 123 --'Power'
	CROSS JOIN source_deal_header_template sdht
	--LEFT JOIN udt_aggregated_deal_header uagh
	--	ON uagh.zone = tcdh.zone
	--	AND uagh.hub = tcdh.hub
	--	AND uagh.channel = tcdh.channel
	--	AND uagh.product = tcdh.product
	--	AND NULLIF(uagh.uncommitted, 'No')  IS NULL
	LEFT JOIN source_deal_header sdh1
		ON sdh1.deal_id = tcdh.deal_id + '_' + tcdh.type			
	WHERE sdht.template_id = @transmission_template_id -- 2766 -- select * from source_deal_header_template where template_name = 'power transmission'
		AND sdh1.source_deal_header_id IS NULL 
		AND tcdh.type IN('transmission', 'transmission_uncommitted')
		
	-- SOURCE DEAL GROUPS
	INSERT INTO source_deal_groups(source_deal_groups_name, source_deal_header_id, leg)
	SELECT dbo.FNADateFormat(entire_term_start) + ' - ' + dbo.FNADateFormat(entire_term_end)
		, sdh.source_deal_header_id
		, 1 leg 
	FROM #temp_inserted_deal_header t
	INNER JOIN source_deal_header sdh
		ON t.source_deal_header_id = sdh.source_deal_header_id

	--SEPARATE POLR AND MUNI FOR OTHER INSERTED DEALS 
	DELETE FROM #temp_inserted_deal_header -- select * from #temp_inserted_deal_header
	OUTPUT	deleted.source_deal_header_id
			, deleted.deal_id
	INTO #temp_inserted_deal_header_polr_muni(source_deal_header_id, deal_id) --select * from #temp_inserted_deal_header_polr_muni
	WHERE deal_id LIKE '%Loss'
		OR deal_id LIKE '%xfer'
		OR deal_id LIKE '%offset'
		OR deal_id LIKE '%capacity'
		OR deal_id LIKE '%capacity_uncommitted'
		OR deal_id LIKE '%transmission'
		OR deal_id LIKE '%transmission_uncommitted'
		OR deal_id LIKE '%onm'
		OR deal_id LIKE '%onm_uncommitted'
		OR deal_id LIKE '%uncommitted'

	UPDATE pm
	SET pm.source_deal_header_id_original = sdh.source_deal_header_id
		, pm.deal_id_original = sdh.deal_id
	FROM  #temp_inserted_deal_header_polr_muni pm
	INNER JOIN source_deal_header sdh
		ON ( pm.deal_id = sdh.deal_id + '_Loss'
			OR pm.deal_id = sdh.deal_id + '_xfer'
			OR pm.deal_id = sdh.deal_id + '_offset'
			OR pm.deal_id = sdh.deal_id + '_capacity'
			OR pm.deal_id = sdh.deal_id + '_capacity_uncommitted'
			OR pm.deal_id = sdh.deal_id + '_transmission'
			OR pm.deal_id = sdh.deal_id + '_transmission_uncommitted'
			OR pm.deal_id = sdh.deal_id + '_onm'
			OR pm.deal_id = sdh.deal_id + '_onm_uncommitted'
			OR pm.deal_id = sdh.deal_id + '_uncommitted'

		)	

	--DEAL DETAIL
	--ADD NEW DEAL DETAIL
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT 
			tidh.source_deal_header_id
		, IIF(n = 1, DATEADD (MONTH , n - 1 , tcdh.entire_term_start ), DATEADD (MONTH , n - 1 , tcdh.term_start_f)) term_start
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.entire_term_start )) term_end
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sddt.buy_sell_flag = 'b', 's', 'b') 
			ELSE sddt.buy_sell_flag
		  END
		, EOMONTH(DATEADD (MONTH , n-1, tcdh.entire_term_start)) contract_expiration_date
		, IIF(tcdh.type IN('onm', 'onm_uncommitted'),@onm_curve, ISNULL(sml.term_pricing_index, sddt.curve_id)) curve_id
		, sddt.deal_volume
		, sddt.deal_volume_frequency
		, sddt.deal_volume_uom_id
		, sddt.fixed_float_leg
		, IIF(tcdh.type IN('onm', 'onm_uncommitted'), NULL, sddt.fixed_price) fixed_price
		, sddt.Leg
		, sml.source_minor_location_id location_id
		, sddt.physical_financial_flag
		, sddt.fixed_price_currency_id
		, sdg.source_deal_groups_id
		, sddt.position_uom
		, NULL profile_id
		, IIF(tcdh.type IN('onm', 'onm_uncommitted'),NULL, spcd.source_curve_def_id)  formula_curve_id
		, sddt.pay_opposite
		, sddt.volume_left
		, sddt.price_multiplier
		, sddt.detail_commodity_id
		, sddt.multiplier
	 FROM 	 (
		SELECT id		
			, type
			, zone
			, hub
			, channel
			, product 
			, internal_portfolio_id
			, deal_date		
			, entire_term_start
			, [dbo].[FNAGetFirstLastDayOfMonth](entire_term_start, 'f') term_start_f
			, entire_term_end
			, formula_curve_id
		FROM #temp_customer_deals_header_info
		UNION ALL
		SELECT id		
				, type 
				, zone
				, hub
				, channel
				, product 
				, internal_portfolio_id
				, deal_date		
				, entire_term_start
				, [dbo].[FNAGetFirstLastDayOfMonth](entire_term_start, 'f') term_start_f
				, entire_term_end
				, formula_curve_id
		FROM #temp_customer_deals_header_info_transfer	
	)  tcdh
	CROSS JOIN seq s	
	INNER JOIN #temp_inserted_deal_header tidh
		ON  tcdh.id = tidh.deal_id
	INNER JOIN source_deal_detail_template sddt
		ON sddt.template_id = @template_id --2752 -- @template_id --
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = tidh.source_deal_header_id
	LEFT JOIN source_minor_location sml
		ON sml.location_id =tcdh.zone
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.formula_curve_id
	WHERE DATEADD (MONTH , s.n-1 , tcdh.entire_term_start ) <= tcdh.entire_term_end
	
	--ADD UPDATED DEAL DETAIL FOR NEW TERM END FOR COMMITTED
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT 
		  sdh.source_deal_header_id
		  , DATEADD(DAY, 1, EOMONTH(DATEADD(MONTH , s.n-1 , sdh.entire_term_end))) term_start
		, EOMONTH(DATEADD(MONTH , s.n , sdh.entire_term_end)) term_end		
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sdd.buy_sell_flag = 'b', 's', 'b') 
			ELSE sdd.buy_sell_flag
		  END
		, DATEADD(MONTH , s.n , sdh.entire_term_end) contract_expiration_date
		, IIF(tcdh.type = 'onm', @onm_curve, sdd.curve_id)
		, sdd.deal_volume
		, sdd.deal_volume_frequency
		, sdd.deal_volume_uom_id
		, sdd.fixed_float_leg
		, NULL fixed_price
		, sdd.Leg
		, sdd.location_id
		, sdd.physical_financial_flag
		, sdd.fixed_price_currency_id
		, sdd.source_deal_group_id
		, sdd.position_uom
		, sdd.profile_id	
		, IIF(tcdh.type = 'onm', NULL, sdd.formula_curve_id) formula_curve_id
		, sdd.pay_opposite
		, sdd.volume_left
		, sdd.price_multiplier
		, sdd.detail_commodity_id
		, sdd.multiplier
	FROM #temp_customer_deals_header_info tcdh 
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
		)
		AND tcdh.type = 'Original'
	
	CROSS APPLY (
		SELECT TOP 1 * 
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) sdd
	CROSS APPLY (
		SELECT MAX(term_end) term_end
		FROM source_deal_detail s 
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) t
	CROSS JOIN seq s
	WHERE t.term_end < tcdh.entire_term_end
		AND DATEADD(MONTH , s.n ,  t.term_end) <= tcdh.entire_term_end	
	
	--ADD UPDATED DEAL DETAIL FOR NEW TERM END for uncommitted
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT --sdh.deal_id,
		  sdh.source_deal_header_id
		, DATEADD(DAY, 1, EOMONTH(DATEADD(MONTH , s.n-1 , sdh.entire_term_end))) term_start
		, EOMONTH(DATEADD(MONTH , s.n , sdh.entire_term_end)) term_end		
		, sdd.buy_sell_flag
		, DATEADD(MONTH , s.n , sdh.entire_term_end) contract_expiration_date
		, IIF(tcdh.type = 'onm_uncommitted', @onm_curve , sdd.curve_id) curve_id  	 
		, sdd.deal_volume
		, sdd.deal_volume_frequency
		, sdd.deal_volume_uom_id
		, sdd.fixed_float_leg
		, NULL fixed_price
		, sdd.Leg
		, sdd.location_id
		, sdd.physical_financial_flag
		, sdd.fixed_price_currency_id
		, sdd.source_deal_group_id
		, sdd.position_uom
		, sdd.profile_id	
		, IIF(tcdh.type = 'onm_uncommitted', NULL, sdd.formula_curve_id) formula_curve_id
		, sdd.pay_opposite
		, sdd.volume_left
		, sdd.price_multiplier
		, sdd.detail_commodity_id
		, sdd.multiplier
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON ( sdh.deal_id = tcdh.deal_id + '_onm_uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
		)
		AND tcdh.type = 'uncommitted'
	CROSS JOIN seq s
	CROSS APPLY (
		SELECT TOP 1 * 
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) sdd
	CROSS APPLY (
		SELECT MAX(term_end) term_end 
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) t
	WHERE t.term_end < tcdh.entire_term_end
		AND DATEADD(MONTH , s.n ,  t.term_end) <= tcdh.entire_term_end	
	
	--ADD UPDATED DEAL DETAIL FOR NEW TERM START FOR COMMITTED
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT 
		sdh.source_deal_header_id
		, IIF(n = 1, DATEADD (MONTH , n - 1 , tcdh.entire_term_start ), [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, n - 1, tcdh.entire_term_start), 'f')) term_start
		--, DATEADD(MONTH ,  s.n - 1  , tcdh.entire_term_start ) term_start
		, EOMONTH(DATEADD(MONTH ,  s.n - 1  , tcdh.entire_term_start )) term_end		
		, CASE WHEN tcdh.type = 'offset' THEN 
			IIF(sdd.buy_sell_flag = 'b', 's', 'b') 
			ELSE sdd.buy_sell_flag
		  END
		, EOMONTH(DATEADD(MONTH ,  s.n -1 , tcdh.entire_term_start )) contract_expiration_date
		, IIF(tcdh.type = 'onm', @onm_curve, sdd.curve_id) curve_id
		, sdd.deal_volume
		, sdd.deal_volume_frequency
		, sdd.deal_volume_uom_id
		, sdd.fixed_float_leg
		, NULL fixed_price
		, sdd.Leg
		, sdd.location_id
		, sdd.physical_financial_flag
		, sdd.fixed_price_currency_id
		, sdd.source_deal_group_id
		, sdd.position_uom
		, sdd.profile_id	
		, IIF(tcdh.type = 'onm', NULL, sdd.formula_curve_id) formula_curve_id 
		, sdd.pay_opposite
		, sdd.volume_left
		, sdd.price_multiplier
		, sdd.detail_commodity_id
		, sdd.multiplier
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
		)
		AND tcdh.type = 'Original'
	CROSS JOIN seq s
	CROSS APPLY (
		SELECT TOP 1 * 
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) sdd
	CROSS APPLY (
		SELECT [dbo].[FNAGetFirstLastDayOfMonth](MIN(term_start), 'f') term_start
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) t
	WHERE  DATEADD(MONTH ,  s.n -1  , tcdh.entire_term_start ) < t.term_start

	--ADD UPDATED DEAL DETAIL FOR NEW TERM START FOR UNCOMMITTED
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT 
		sdh.source_deal_header_id		
		, IIF(n = 1, DATEADD (MONTH , n - 1 , tcdh.entire_term_start ), [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, n - 1, tcdh.entire_term_start), 'f')) term_start
		, EOMONTH(DATEADD(MONTH ,  s.n - 1  , tcdh.entire_term_start )) term_end		
		, sdd.buy_sell_flag
		, EOMONTH(DATEADD(MONTH ,  s.n -1 , tcdh.entire_term_start )) contract_expiration_date
		, IIF(tcdh.type = 'onm_uncommitted', @onm_curve, sdd.curve_id) curve_id
		, sdd.deal_volume
		, sdd.deal_volume_frequency
		, sdd.deal_volume_uom_id
		, sdd.fixed_float_leg
		, NULL fixed_price
		, sdd.Leg
		, sdd.location_id
		, sdd.physical_financial_flag
		, sdd.fixed_price_currency_id
		, sdd.source_deal_group_id
		, sdd.position_uom
		, sdd.profile_id	
		, IIF(tcdh.type = 'onm_uncommitted', NULL, sdd.formula_curve_id) formula_curve_id 
		, sdd.pay_opposite
		, sdd.volume_left
		, sdd.price_multiplier
		, sdd.detail_commodity_id
		, sdd.multiplier
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (
			 sdh.deal_id = tcdh.deal_id + '_onm_uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_uncommitted'			
			OR sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
		)
		AND tcdh.type = 'uncommitted'
	CROSS JOIN seq s
	CROSS APPLY (
		SELECT TOP 1 * 
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) sdd
	CROSS APPLY (
		SELECT [dbo].[FNAGetFirstLastDayOfMonth](MIN(term_start), 'f') term_start
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) t
	WHERE  DATEADD(MONTH ,  s.n -1  , tcdh.entire_term_start ) < t.term_start
	
	--ADDED POLR AND MUNI DEALS FOR COMMITTED  
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT  pm.source_deal_header_id
		, sdd.term_start
		, sdd.term_end
		, CASE WHEN RIGHT(pm.deal_id, 6) = 'offset' THEN 
			IIF(sdd.buy_sell_flag = 'b', 's', 'b') 
			ELSE sdd.buy_sell_flag
		  END
		--, sdd.buy_sell_flag
		, sdd.contract_expiration_date
		, IIF(RIGHT(pm.deal_id, 3) = 'onm', @onm_curve,sdd.curve_id) curve_id
		, sdd.deal_volume
		, sdd.deal_volume_frequency
		, sdd.deal_volume_uom_id
		, sdd.fixed_float_leg
		, IIF(RIGHT(pm.deal_id, 3) = 'onm', NULL,sdd.fixed_price) fixed_price
		, sdd.Leg
		, sdd.location_id
		, sdd.physical_financial_flag
		, sdd.fixed_price_currency_id
		, sdg.source_deal_groups_id
		, sdd.position_uom
		, sdd.profile_id
		, IIF(RIGHT(pm.deal_id, 3) = 'onm', NULL, sdd.formula_curve_id) formula_curve_id 
		, sdd.pay_opposite
		, sdd.volume_left
		, sdd.price_multiplier
		, sdd.detail_commodity_id
		, IIF(RIGHT(pm.deal_id,4) = 'Loss'
				, IIF((ISNULL(upm.loss_multiplier, 1) -1) < 0, 0, (ISNULL(upm.loss_multiplier, 1) -1))
				, (ISNULL(sdd.multiplier, 1) + IIF((ISNULL(upm.loss_multiplier, 1) -1) < 0, 0, (ISNULL(upm.loss_multiplier, 1) -1)) )
			) multiplier		
    FROM source_deal_detail sdd
	INNER JOIN #temp_inserted_deal_header_polr_muni pm  -- select * from #temp_inserted_deal_header_polr_muni
		ON sdd.source_deal_header_id = pm.source_deal_header_id_original
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = pm.source_deal_header_id
	INNER JOIN #udt_customer_deals_header_info_polr_muni upm -- select * from #udt_customer_deals_header_info_polr_muni
		ON upm.uid = pm.deal_id_original
	WHERE pm.deal_id NOT IN (
								pm.deal_id_original + '_capacity'
								, pm.deal_id_original + '_capacity_uncommitted'
								, pm.deal_id_original + '_transmission'
								, pm.deal_id_original + '_transmission_uncommitted'
							)
		AND NULLIF(upm.uncommitted, 'No') IS NULL
	
	--ADDED POLR AND MUNI DEALS FOR UNCOMMITTED  
	 INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT  tidh.source_deal_header_id
		, DATEADD(MONTH ,  s.n - 1  , tcdh.entire_term_start ) term_start
		, EOMONTH(DATEADD(MONTH ,  s.n - 1  , tcdh.entire_term_start )) term_end		
		, sdd.buy_sell_flag
		--, sdd.buy_sell_flag
		, sdd.contract_expiration_date
		, IIF(tcdh.type = 'onm_uncommitted', @onm_curve, ISNULL(sml.term_pricing_index, sdd.curve_id)) curve_id 
		, sdd.deal_volume
		, sdd.deal_volume_frequency
		, sdd.deal_volume_uom_id
		, sdd.fixed_float_leg
		, IIF(tcdh.type = 'onm_uncommitted', NULL, sdd.fixed_price) fixed_price
		, sdd.Leg
		, sdd.location_id
		, sdd.physical_financial_flag
		, sdd.fixed_price_currency_id
		, sdg.source_deal_groups_id
		, sdd.position_uom
		, fp.profile_id
		, IIF(tcdh.type = 'onm_uncommitted', NULL, ISNULL(spcd.source_curve_def_id, sdd.formula_curve_id)) formula_curve_id
		, sdd.pay_opposite
		, sdd.volume_left
		, sdd.price_multiplier
		, sdd.detail_commodity_id
		, sdd.multiplier
	--select tidh.deal_id_original, tidh.deal_id , *
	FROM #temp_customer_deals_header_info_polr_muni_uncommitted tcdh -- select * from #temp_customer_deals_header_info_polr_muni_uncommitted
	INNER JOIN #temp_inserted_deal_header_polr_muni tidh  --select * from #temp_inserted_deal_header_polr_muni
		ON  tcdh.deal_id + '_' + tcdh.type = tidh.deal_id
	INNER JOIN source_deal_detail_template sdd
		ON sdd.template_id =  @template_id --2752 -- @template_id --2752--
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = tidh.source_deal_header_id
	LEFT JOIN source_minor_location sml
		ON sml.location_id =tcdh.zone
	LEFT JOIN forecast_profile fp
		ON ( zone + '_' + REPLACE(channel, ' ', '_') + '_' + @hardcoded_product + '_UC') = fp.profile_name
	LEFT JOIN  source_price_curve_def spcd
		ON spcd.curve_id = tcdh.energy_lmp
	CROSS JOIN seq s
	

	WHERE DATEADD (MONTH, s.n-1, tcdh.entire_term_start ) <= tcdh.entire_term_end	
	AND tcdh.type  IN (
							'uncommitted'
							, 'onm_uncommitted'
					 )
				 
	--Add Capacity Deal
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT  tidh.source_deal_header_id
		, IIF(n = 1, DATEADD (MONTH, n-1, tcdh.entire_term_start), [dbo].[FNAGetFirstLastDayOfMonth](DATEADD (MONTH , n-1 , tcdh.entire_term_start), 'f'))  term_start
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.entire_term_start )) term_end
		, 's' buy_sell_flag
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.entire_term_start )) contract_expiration_date
		, ISNULL(spcd.source_curve_def_id , sddt.curve_id) curve_id
		, NULL deal_volume--a.deal_volume * cs.curve_value
		, 'd' deal_volume_frequency --'Daily'
		, ISNULL(su.source_uom_id, sddt.deal_volume_uom_id) deal_volume_uom_id
		, 't' fixed_float_leg --'float'
		,  NULL fixed_price --Need to be discussed
		, 1 Leg
		, sml.source_minor_location_id location_id
		, 'p' physical_financial_flag
		, ISNULL(scu.source_currency_id, sddt.fixed_price_currency_id) fixed_price_currency_id
		, sdg.source_deal_groups_id
		, ISNULL(sup.source_uom_id, sddt.position_uom) position_uom
		, NULL profile_id
		, ISNULL(spcd.source_curve_def_id , sddt.curve_id) formula_curve_id
		, ISNULL(sddt.pay_opposite, 'y') pay_opposite
		, sddt.volume_left
		, sddt.price_multiplier
		, ISNULL(sco.source_commodity_id, sddt.detail_commodity_id) detail_commodity_id
		, sddt.multiplier
	FROM #temp_customer_deals_header_info_ct tcdh   --select * from #temp_customer_deals_header_info_ct	
	INNER JOIN #temp_inserted_deal_header tidh
		ON  tcdh.id = tidh.deal_id
	INNER JOIN source_deal_detail_template sddt
		ON sddt.template_id = @capacity_template_id -- 2761 --@capacity_template_id --2761--
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = tidh.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Capacity'
	LEFT JOIN  source_currency scu
		ON scu.currency_id = 'USD'
	LEFT JOIN source_minor_location sml
		ON sml.location_id = tcdh.zone
	LEFT JOIN source_uom su
		ON su.uom_id = 'mw'
	LEFT JOIN source_uom sup    
		ON sup.uom_id = 'MW-Day'
	LEFT JOIN source_commodity sco
		ON sco.commodity_id = 'Power'	
	CROSS JOIN seq s
	WHERE DATEADD (MONTH , s.n-1 , tcdh.entire_term_start ) <= tcdh.entire_term_end
		AND tcdh.type IN ('Capacity', 'Capacity_Uncommitted')  
	
	--polr capacity and capacity_uncommitted
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT tidh.source_deal_header_id
		, IIF(n = 1, DATEADD (MONTH , n-1 , tcdh.term_start ), DATEADD (MONTH , n-1 , tcdh.term_start_f )) term_start
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.term_start )) term_end
		, 's' buy_sell_flag
		, EOMONTH(DATEADD (MONTH , n-1 ,tcdh.term_start )) contract_expiration_date
		, ISNULL(spcd.source_curve_def_id , sddt.curve_id) curve_id
		, NULL deal_volume--a.deal_volume * cs.curve_value
		, 'd' deal_volume_frequency --'Daily'
		, ISNULL(su.source_uom_id, sddt.deal_volume_uom_id) deal_volume_uom_id
		, 't' fixed_float_leg --'float'
		,  NULL fixed_price --Need to be discussed
		, 1 Leg
		, sml.source_minor_location_id location_id
		, 'p' physical_financial_flag
		, ISNULL(scu.source_currency_id, sddt.fixed_price_currency_id) fixed_price_currency_id
		, sdg.source_deal_groups_id
		, ISNULL(sup.source_uom_id, sddt.position_uom) position_uom
		, NULL profile_id
		, ISNULL(spcd.source_curve_def_id , sddt.curve_id) formula_curve_id
		, ISNULL(sddt.pay_opposite, 'y') pay_opposite
		, sddt.volume_left
		, sddt.price_multiplier
		, ISNULL(sco.source_commodity_id, sddt.detail_commodity_id) detail_commodity_id
		, sddt.multiplier
	 FROM (		
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start term_start, [dbo].[FNAGetFirstLastDayOfMonth](entire_term_start, 'f') term_start_f,  entire_term_end term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni
			WHERE type IN ('Capacity')
			UNION ALL 
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start term_start, [dbo].[FNAGetFirstLastDayOfMonth](entire_term_start, 'f') term_start_f, entire_term_end term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni_uncommitted
			WHERE type IN ('Capacity_uncommitted')	
	
	)   tcdh  

	INNER JOIN #temp_inserted_deal_header_polr_muni tidh
		ON  tcdh.deal_id + '_' + tcdh.type = tidh.deal_id
	INNER JOIN source_deal_detail_template sddt
		ON sddt.template_id = @capacity_template_id -- 2761 --@capacity_template_id --2761--
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = tidh.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Capacity'
	LEFT JOIN  source_currency scu
		ON scu.currency_id = 'USD'
	LEFT JOIN source_minor_location sml
		ON sml.location_id = tcdh.zone
	LEFT JOIN source_uom su
		ON su.uom_id = 'mw'
	LEFT JOIN source_uom sup    
		ON sup.uom_id = 'MW-Day'
	LEFT JOIN source_commodity sco
		ON sco.commodity_id = 'Power'

	CROSS JOIN seq s
	WHERE DATEADD (MONTH , s.n-1 , tcdh.term_start ) <= tcdh.term_end
		AND tcdh.type IN ('Capacity', 'Capacity_Uncommitted')   
	
	--Add Transmission Deal
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT tidh.source_deal_header_id
		, IIF(n = 1, DATEADD (MONTH , n-1 ,tcdh.entire_term_start),[dbo].[FNAGetFirstLastDayOfMonth](DATEADD (MONTH, n - 1, tcdh.entire_term_start ), 'f')) term_start
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.entire_term_start)) term_end
		, 's' buy_sell_flag
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.entire_term_start)) contract_expiration_date
		, ISNULL(spcd.source_curve_def_id , sddt.curve_id) curve_id
		, NULL deal_volume --a.deal_volume
		, 'd' deal_volume_frequency --'Daily'
		, ISNULL(su.source_uom_id, sddt.deal_volume_uom_id) deal_volume_uom_id
		, 't' fixed_float_leg --'float'
		,  NULL fixed_price --Need to be discussed
		, 1 Leg
		, sml.source_minor_location_id location_id
		, 'p' physical_financial_flag
		, ISNULL(scu.source_currency_id, sddt.fixed_price_currency_id) fixed_price_currency_id
		, sdg.source_deal_groups_id
		, ISNULL(sup.source_uom_id, sddt.position_uom) position_uom
		, NULL profile_id
		, ISNULL(spcd.source_curve_def_id, sddt.formula_curve_id) formula_curve_id
		, ISNULL(sddt.pay_opposite, 'y') pay_opposite
		, sddt.volume_left
		, sddt.price_multiplier
		, ISNULL(sco.source_commodity_id, sddt.detail_commodity_id) detail_commodity_id
		, sddt.multiplier
	FROM  #temp_customer_deals_header_info_ct  tcdh	
	INNER JOIN #temp_inserted_deal_header tidh
		ON  tcdh.id = tidh.deal_id
	INNER JOIN source_deal_detail_template sddt
		ON sddt.template_id = @transmission_template_id --2766 -- --2766--
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = tidh.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Transmission Cost'
	LEFT JOIN  source_currency scu
		ON scu.currency_id = 'USD'
	LEFT JOIN source_minor_location sml
		ON sml.location_id = tcdh.zone
	LEFT JOIN source_uom su
		ON su.uom_id = 'mw'
	LEFT JOIN source_uom sup
		ON sup.uom_id = 'MW-Day'
	LEFT JOIN source_commodity sco
		ON sco.commodity_id = 'Power'
	CROSS JOIN seq s
	WHERE DATEADD (MONTH , s.n-1 , tcdh.entire_term_start ) <= tcdh.entire_term_end
		AND tcdh.type IN ('Transmission', 'Transmission_Uncommitted')
	
	--Add polr Transmission Deal
	INSERT INTO source_deal_detail (
		source_deal_header_id
		, term_start
		, term_end
		, buy_sell_flag
		, contract_expiration_date
		, curve_id
		, deal_volume
		, deal_volume_frequency
		, deal_volume_uom_id
		, fixed_float_leg
		, fixed_price
		, Leg
		, location_id
		, physical_financial_flag
		, fixed_price_currency_id
		, source_deal_group_id
		, position_uom
		, profile_id
		, formula_curve_id
		, pay_opposite
		, volume_left
		, price_multiplier
		, detail_commodity_id
		, multiplier
	)
	SELECT tidh.source_deal_header_id
		, IIF(n = 1, DATEADD (MONTH , n-1 , tcdh.term_start ),DATEADD (MONTH , n-1 , tcdh.term_start_f)) term_start
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.term_start )) term_end
		, 's' buy_sell_flag
		, EOMONTH(DATEADD (MONTH , n-1 , tcdh.term_start )) contract_expiration_date
		, ISNULL(spcd.source_curve_def_id , sddt.curve_id) curve_id
		, NULL deal_volume --a.deal_volume
		, 'd' deal_volume_frequency --'Daily'
		, ISNULL(su.source_uom_id, sddt.deal_volume_uom_id) deal_volume_uom_id
		, 't' fixed_float_leg --'float'
		,  NULL fixed_price --Need to be discussed
		, 1 Leg
		, sml.source_minor_location_id location_id
		, 'p' physical_financial_flag
		, ISNULL(scu.source_currency_id, sddt.fixed_price_currency_id) fixed_price_currency_id
		, sdg.source_deal_groups_id
		, ISNULL(sup.source_uom_id, sddt.position_uom) position_uom
		, NULL profile_id
		, ISNULL(spcd.source_curve_def_id, sddt.formula_curve_id) formula_curve_id
		, ISNULL(sddt.pay_opposite, 'y') pay_opposite
		, sddt.volume_left
		, sddt.price_multiplier
		, ISNULL(sco.source_commodity_id, sddt.detail_commodity_id) detail_commodity_id
		, sddt.multiplier
	FROM (		
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start term_start, [dbo].[FNAGetFirstLastDayOfMonth](entire_term_start, 'f') term_start_f,  entire_term_end term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni
			WHERE type IN ('Transmission')
			UNION ALL 
			SELECT id, type, zone, hub, channel, product, internal_portfolio_id, deal_date
				, entire_term_start term_start, [dbo].[FNAGetFirstLastDayOfMonth](entire_term_start, 'f') term_start_f, entire_term_end term_end, deal_id, formula_curve_id, 1 is_polr
			FROM #temp_customer_deals_header_info_polr_muni_uncommitted
			WHERE type IN ('Transmission_uncommitted')		
	)  tcdh  
	
	INNER JOIN #temp_inserted_deal_header_polr_muni tidh
		ON  tcdh.deal_id + '_' + tcdh.type = tidh.deal_id
	INNER JOIN source_deal_detail_template sddt
		ON sddt.template_id = @transmission_template_id --2766 -- --2766--
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = tidh.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Transmission Cost'
	LEFT JOIN  source_currency scu
		ON scu.currency_id = 'USD'
	LEFT JOIN source_minor_location sml
		ON sml.location_id = tcdh.zone
	LEFT JOIN source_uom su
		ON su.uom_id = 'mw'
	LEFT JOIN source_uom sup
		ON sup.uom_id = 'MW-Day'
	LEFT JOIN source_commodity sco
		ON sco.commodity_id = 'Power'
	CROSS JOIN seq s
	WHERE DATEADD (MONTH , s.n-1 , tcdh.term_start ) <= tcdh.term_end
		AND tcdh.type IN ('Transmission', 'Transmission_Uncommitted')

	--UPDATE MIDDLE OF MONTH BY FIRST DAY OF MONTH WHICH IS NOT MINIUM DATE
	UPDATE sdd
		SET term_start = [dbo].[FNAGetFirstLastDayOfMonth](sdd.term_start, 'f')
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
			OR sdh.deal_id = tcdh.deal_id + '_onm_uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_uncommitted'			
			OR sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
		)
		AND tcdh.type = 'Original'
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	CROSS APPLY (
		SELECT MIN(term_start) term_start
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) t
	WHERE sdd.term_start <> t.term_start	
		AND DAY(sdd.term_start) <> 1
	
	--UPDATE MIDDLE OF MONTH OF FIRST DATE BY NEW FIRST DATE OF THE SAME MONTH
	UPDATE sdd
		SET term_start = tcdh.entire_term_start
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
			OR sdh.deal_id = tcdh.deal_id + '_onm_uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_uncommitted'			
			OR sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
		)
		AND tcdh.type = 'Original'
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	CROSS APPLY (
		SELECT MIN(term_start) term_start
		FROM source_deal_detail s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
	) t
	WHERE tcdh.entire_term_start <	t.term_start 
		AND MONTH(sdd.term_start) = MONTH(tcdh.entire_term_start )
		AND YEAR(sdd.term_start) = YEAR(tcdh.entire_term_start )

	--DELETE OUT OF TERM DEAL DETAIL	
	INSERT INTO #delete_sdd(source_deal_detail_id)
	SELECT sdd.source_deal_detail_id
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
		)
		AND tcdh.type = 'Original'
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE ( sdd.term_end > EOMONTH(tcdh.entire_term_end)
			OR 
			sdd.term_start < [dbo].[FNAGetFirstLastDayOfMonth](tcdh.entire_term_start , 'f') 
		)
	UNION ALL
	SELECT sdd.source_deal_detail_id
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (
			 sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_OnM_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Uncommitted'
		)
		AND tcdh.type = 'Uncommitted'
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE ( sdd.term_end > EOMONTH(tcdh.entire_term_end)
			OR 
			sdd.term_start < [dbo].[FNAGetFirstLastDayOfMonth](tcdh.entire_term_start , 'f') 
		)

	DELETE udddf
	FROM #delete_sdd ds
	INNER JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = ds.source_deal_detail_id

	DELETE p 
	FROM deal_position_break_down p
	INNER JOIN #delete_sdd sdd
		ON p.source_deal_detail_id = sdd.source_deal_detail_id

	DELETE h
	FROM #delete_sdd sdd
	INNER JOIN source_deal_detail_hour h
		ON h.source_deal_detail_id = sdd.source_deal_detail_id

	DELETE sdd
	FROM #delete_sdd ds
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = ds.source_deal_detail_id

	--ADD UPDATED DEAL DETAIL
	--TO DO: Update new term_start and term_end in sdd as well (it is gives issue in case of middle of month)
	UPDATE sdh 
		SET sdh.entire_term_start = tcdh.entire_term_start 
		, sdh.entire_term_end = tcdh.entire_term_end
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
			OR sdh.deal_id = tcdh.deal_id + '_OnM_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Uncommitted'
		)
	WHERE (
			sdh.entire_term_start <> tcdh.entire_term_start
			OR  sdh.entire_term_end <> tcdh.entire_term_end
		)

	UPDATE sdh 
		SET contract_id = CASE tcdh.type 
							WHEN 'xfer' THEN 
								IIF(@xfer_contract_id IS NULL, sdh.contract_id , @xfer_contract_id) 
							WHEN 'offset' THEN 
								IIF(@offset_contract_id IS NULL, sdh.contract_id , @offset_contract_id) 
							ELSE sdh.contract_id
						  END, 
			counterparty_id = CASE tcdh.type 
							WHEN 'xfer' THEN 
								IIF(@xfer_countertparty_id IS NULL, sdh.counterparty_id , @xfer_countertparty_id) 
							WHEN 'offset' THEN 
								IIF(@offset_countertparty_id IS NULL, sdh.counterparty_id , @offset_countertparty_id) 
							ELSE sdh.counterparty_id 
						  END 
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM( 
			SELECT * FROM #temp_customer_deals_header_info 
			UNION ALL
			SELECT * FROM #temp_customer_deals_header_info_transfer
	)tcdh	
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = tcdh.deal_id + IIF(type = 'Original', '', '_' + tcdh.type)
				
	UPDATE sdg 
	SET source_deal_groups_name = dbo.FNADateFormat(sdh.entire_term_start) + ' - ' + dbo.FNADateFormat(sdh.entire_term_end) 
	FROM #temp_customer_deals_header_info tcdh
	INNER JOIN source_deal_header sdh
		ON (sdh.deal_id = tcdh.deal_id 
			OR sdh.deal_id = tcdh.deal_id + '_Loss'
			OR sdh.deal_id = tcdh.deal_id + '_Offset'
			OR sdh.deal_id = tcdh.deal_id + '_Xfer'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission'
			OR sdh.deal_id = tcdh.deal_id + '_Transmission_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity'
			OR sdh.deal_id = tcdh.deal_id + '_Capacity_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_OnM'
			OR sdh.deal_id = tcdh.deal_id + '_OnM_Uncommitted'
			OR sdh.deal_id = tcdh.deal_id + '_Uncommitted'
		)
	INNER JOIN source_deal_groups sdg
		ON sdg.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.entire_term_end <> tcdh.entire_term_end		
	
	INSERT INTO udt_aggregated_deal_header (
		channel
		, hub
		, product
		, zone 
		, source_deal_header_id
		, uncommitted
	) OUTPUT INSERTED.aggregated_deal_header_id INTO #temp_aggregated_deal_header(aggregated_deal_header_id)
	SELECT 	channel
		, hub
		, product
		, zone 
		, sdh.source_deal_header_id
		, IIF(type = 'original', NULL, 'Yes')
	FROM #temp_customer_deals_header_info i
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = i.id 
	WHERE type IN('Original', 'uncommitted')
	UNION ALL
	SELECT channel
		, hub
		, product
		, zone 
		, sdh.source_deal_header_id
		, 'Yes'
	FROM #temp_customer_deals_header_info_polr_muni_uncommitted i
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = i.id 
	WHERE type = 'uncommtted'
	
	INSERT INTO udt_aggregated_deal_detail(
		cust_name
		, entire_term_end
		, entire_term_start
		, source_deal_header_id
		, profile_code
		, uid
	) OUTPUT INSERTED.aggregated_deal_detail_id INTO #temp_aggregated_deal_detail(aggregated_deal_detail_id)
	SELECT 
		 hi.cust_name
		, hi.entire_term_end
		, hi.entire_term_start	
		, uh.source_deal_header_id
		, hi.profile_code
		, hi.uid
	FROM #udt_customer_deals_header_info hi  
	INNER JOIN udt_aggregated_deal_header uh
		ON hi.hub = uh.hub
		AND hi.product = uh.product
		AND hi.zone = uh.zone
		AND hi.channel = uh.channel
	LEFT JOIN udt_aggregated_deal_detail ud
		ON ud.uid = hi.uid
	WHERE ud.uid IS NULL
	
	INSERT INTO udt_aggregated_deal_header_audit (
		channel
		, hub
		, product
		, source_deal_header_id
		, uncommitted
		, zone
		, user_action	
	)
	SELECT channel
		, hub
		, product
		, source_deal_header_id
		, uncommitted
		, zone
		, 'Insert' user_action
	FROM udt_aggregated_deal_header udh
	INNER JOIN #temp_aggregated_deal_header tdh
		ON udh.aggregated_deal_header_id = tdh.aggregated_deal_header_id
		
	INSERT INTO udt_aggregated_deal_detail_audit (
		cust_name
		, entire_term_end
		, entire_term_start
		, source_deal_header_id
		, profile_code
		, uid
		, user_action
	)
	SELECT cust_name
		, entire_term_end
		, entire_term_start
		, source_deal_header_id
		, profile_code
		, uid
		, 'Insert' user_action
	FROM udt_aggregated_deal_detail udd
	INNER JOIN #temp_aggregated_deal_detail tdd
		ON udd.aggregated_deal_detail_id = tdd.aggregated_deal_detail_id

		
	--COPY SHAPED VOLUME FROM ORIGINAL POLR AND MUNI TO LOSS,XFER AND OFFSET 
	-- TO DO: add for onm, onm_uncommitted, uncommitted
	INSERT INTO source_deal_detail_hour (
		source_deal_detail_id
		, term_date
		, hr
		, is_dst
		, volume
		, price
		, formula_id
		, granularity
		, schedule_volume
		, actual_volume
		, contractual_volume
		, period
	)
	SELECT sdd.source_deal_detail_id
		, sddh.term_date
		, sddh.hr
		, sddh.is_dst
		, sddh.volume
		, sddh.price
		, sddh.formula_id
		, sddh.granularity
		, sddh.schedule_volume
		, sddh.actual_volume
		, sddh.contractual_volume
		, sddh.period
	FROM #temp_inserted_deal_header_polr_muni pm
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = pm.source_deal_header_id
	INNER JOIN source_deal_detail sdd_o
		ON sdd_o.source_deal_header_id = pm.source_deal_header_id_original
		AND sdd_o.term_start = sdd.term_start
		AND sdd_o.term_end = sdd.term_end
		AND sdd_o.leg = sdd.leg
	INNER JOIN source_deal_detail_hour sddh
		ON sddh.source_deal_detail_id = sdd_o.source_deal_detail_id
	WHERE pm.deal_id NOT LIKE '%capacity%' 
		AND	deal_id NOT LIKE '%transmission%'		
	
	IF OBJECT_ID('tempdb..#tmp_agg_monthly_volume') IS NOT NULL
		DROP TABLE #tmp_agg_monthly_volume

	SELECT 
			 v.uid
			, v.term
			, SUM(peak_volume)/MAX(peak.hrs) peak_hr_volume
			, SUM(offpeak_volume)/MAX(offpeak.hrs) offpeak_hr_volume
			, MAX(peak.hrs) peak_hrs
			, MAX(offpeak.hrs) offpeak_hrs
			, SUM(peak_volume) peak_volume
			, SUM(offpeak_volume) offpeak_volume
		INTO #tmp_agg_monthly_volume
		FROM #temp_agg_uid tau
		CROSS APPLY dbo.SplitCommaSeperatedValues(tau.uids) t
		INNER JOIN udt_customer_monthly_volume_info v
			ON t.item = v.uid
		INNER JOIN #udt_customer_deals_header_info uh
			ON v.uid = uh.uid
			AND v.term BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](uh.entire_term_start , 'f') AND EOMONTH(uh.entire_term_end) --TODO: use data table 
		OUTER APPLY (
			SELECT SUM(volume_mult) hrs
			FROM hour_block_term 
			WHERE YEAR(term_date) = YEAR(v.term) 
				AND block_define_id = 10000134 --peak 
				AND MONTH(term_date) = MONTH(v.term)
				AND dst_group_value_id = 102200
			) peak
		OUTER APPLY (
			SELECT SUM(volume_mult) hrs
			FROM hour_block_term 
			WHERE YEAR(term_date) = YEAR(v.term) 
				AND block_define_id = 10000135--offpeak 
				AND MONTH(term_date) = MONTH(v.term)
				AND dst_group_value_id = 102200
				AND uh.profile_code IS NULL
			) offpeak
	
		WHERE uh.status <> 'Terminate'
		GROUP BY v.uid,v.term
	
	CREATE INDEX indx_tmp_agg_monthly_volume_term_uid ON #tmp_agg_monthly_volume(uid, term)

	IF OBJECT_ID('tempdb..#tmp_agg_hourly_volume_info') IS NOT NULL
		DROP TABLE #tmp_agg_hourly_volume_info

	SELECT  p.uid
		,hbt.term_date	
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr1) Hr1
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr2) Hr2
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr3) Hr3
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr4) Hr4
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr5) Hr5
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr6) Hr6
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr7) Hr7
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr8) Hr8
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr9) Hr9
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr10) Hr10
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr11) Hr11
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr12) Hr12
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr13) Hr13
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr14) Hr14
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr15) Hr15
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr16) Hr16
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr17) Hr17
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr18) Hr18
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr19) Hr19
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr20) Hr20
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr21) Hr21
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr22) Hr22
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr23) Hr23
		, MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr24) Hr24
		, CASE MAX(dst.hour) 
			WHEN 2 THEN MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr2) 
			WHEN 3 THEN MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr3) 
			ELSE NULL 
			END Hr25
		, 'N' AS forecast_received
	INTO #tmp_agg_hourly_volume_info
	FROM #tmp_agg_monthly_volume p 
	INNER JOIN hour_block_term hbt
		ON  YEAR(hbt.term_date) = YEAR(p.term) 
		AND hbt.block_define_id IN(10000134, 10000135)
		AND MONTH(hbt.term_date) = MONTH(p.term)
		AND hbt.dst_group_value_id = 102200
	LEFT JOIN udt_customer_hourly_volume_info uchvi
		ON uchvi.uid = p.uid
		AND uchvi.term_date = hbt.term_date
	LEFT JOIN MV90_dst dst
		ON dst.date = hbt.term_date	
		AND dst.dst_group_value_id=102200
		AND dst.insert_delete = 'i'	
	WHERE uchvi.uid IS NULL 	
		AND hbt.term_date >=  @as_of_date --'2020-01-14'--
	GROUP BY p.uid
			 , hbt.term_date
			 
	INSERT INTO udt_customer_hourly_volume_info (uid, term_date
											, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10
											, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19
											, hr20, hr21, hr22, hr23, hr24, hr25, forecast_received
											)
	SELECT * FROM #tmp_agg_hourly_volume_info


	IF OBJECT_ID('tempdb..#tmp_agg_monthly_volume_one') IS NOT NULL
		DROP TABLE #tmp_agg_monthly_volume_one

	SELECT
		v.uid
		, v.term
		, SUM(peak_volume)/MAX(peak.hrs) peak_hr_volume
		, SUM(offpeak_volume)/MAX(offpeak.hrs) offpeak_hr_volume
		, MAX(peak.hrs) peak_hrs
		, MAX(offpeak.hrs) offpeak_hrs
		, SUM(peak_volume) peak_volume
		, SUM(offpeak_volume) offpeak_volume
	INTO  #tmp_agg_monthly_volume_one
	FROM #temp_agg_uid tau
	CROSS APPLY dbo.SplitCommaSeperatedValues(tau.uids) t
	INNER JOIN udt_customer_monthly_volume_info v
		ON t.item = v.uid
	INNER JOIN #udt_customer_deals_header_info uh
		ON v.uid = uh.uid
		AND v.term BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](uh.entire_term_start , 'f') AND EOMONTH(uh.entire_term_end) 
	OUTER APPLY (
		SELECT SUM(volume_mult) hrs
		FROM hour_block_term 
		WHERE YEAR(term_date) = YEAR(v.term) 
			AND block_define_id = 10000134 --peak 
			AND MONTH(term_date) = MONTH(v.term)
			AND dst_group_value_id = 102200
		) peak
	OUTER APPLY (
		SELECT SUM(volume_mult) hrs
		FROM hour_block_term 
		WHERE YEAR(term_date) = YEAR(v.term) 
			AND block_define_id = 10000135--offpeak 
			AND MONTH(term_date) = MONTH(v.term)
			AND dst_group_value_id = 102200
		) offpeak
	WHERE uh.status <> 'Terminate'
		AND uh.profile_code IS NULL	
		AND v.term >= @as_of_date
	GROUP BY v.uid,v.term

	CREATE INDEX indx_tmp_agg_monthly_volume_one_term_uid ON #tmp_agg_monthly_volume_one(uid, term)

	IF OBJECT_ID('tempdb..#tmp_agg_hourly_volume_info_one') IS NOT NULL
		DROP TABLE #tmp_agg_hourly_volume_info_one

	SELECT  p.uid
			,hbt.term_date	
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr1) Hr1
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr2) Hr2
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr3) Hr3
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr4) Hr4
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr5) Hr5
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr6) Hr6
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr7) Hr7
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr8) Hr8
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr9) Hr9
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr10) Hr10
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr11) Hr11
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr12) Hr12
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr13) Hr13
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr14) Hr14
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr15) Hr15
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr16) Hr16
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr17) Hr17
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr18) Hr18
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr19) Hr19
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr20) Hr20
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr21) Hr21
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr22) Hr22
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr23) Hr23
			, MAX(IIF(block_define_id =10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr24) Hr24
			, CASE MAX(dst.hour) 
				WHEN 2 THEN MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr2) 
				WHEN 3 THEN MAX(IIF(block_define_id = 10000134, peak_hr_volume, offpeak_hr_volume) * hbt.Hr3) 
				ELSE NULL 
				END Hr25
	INTO #tmp_agg_hourly_volume_info_one		--drop table #tmp_b	
	FROM #tmp_agg_monthly_volume_one p
	INNER JOIN hour_block_term hbt
		ON  YEAR(hbt.term_date) = YEAR(p.term) 
		AND hbt.block_define_id IN(10000134, 10000135)
		AND MONTH(hbt.term_date) = MONTH(p.term)
		AND hbt.dst_group_value_id = 102200
	LEFT JOIN MV90_dst dst
		ON dst.date = hbt.term_date	
		AND dst.dst_group_value_id=102200
		AND dst.insert_delete = 'i'	
	INNER JOIN udt_customer_hourly_volume_info uchvi
		ON uchvi.uid = p.uid
		AND uchvi.term_date = hbt.term_date
		AND uchvi.term_date >= @as_of_date
	WHERE ISNULL(uchvi.forecast_received, 'Y') = 'N'
	GROUP BY p.uid, hbt.term_date

	CREATE INDEX indx_tmp_agg_hourly_volume_info_one_term_date_uid 
	ON #tmp_agg_hourly_volume_info_one(uid, term_date)

	UPDATE uv
	SET uv.Hr1 = a.Hr1
		, uv.Hr2 = a.Hr2
		, uv.Hr3 = a.Hr3
		, uv.Hr4 = a.Hr4
		, uv.Hr5 = a.Hr5
		, uv.Hr6 = a.Hr6
		, uv.Hr7 = a.Hr7
		, uv.Hr8 = a.Hr8
		, uv.Hr9 = a.Hr9
		, uv.Hr10 = a.Hr10
		, uv.Hr11 = a.Hr11
		, uv.Hr12 = a.Hr12
		, uv.Hr13 = a.Hr13
		, uv.Hr14 = a.Hr14
		, uv.Hr15 = a.Hr15
		, uv.Hr16 = a.Hr16
		, uv.Hr17 = a.Hr17
		, uv.Hr18 = a.Hr18
		, uv.Hr19 = a.Hr19
		, uv.Hr20 = a.Hr20
		, uv.Hr21 = a.Hr21
		, uv.Hr22 = a.Hr22
		, uv.Hr23 = a.Hr23
		, uv.Hr24 = a.Hr24
		, uv.Hr25 = a.Hr25
		FROM #tmp_agg_hourly_volume_info_one a
		INNER JOIN udt_customer_hourly_volume_info uv
			ON a.uid = uv.uid
			AND a.term_date = uv.term_date
		WHERE  uv.term_date >= @as_of_date

	INSERT INTO forecast_profile(external_id,	profile_type,	available,	profile_name,	uom_id,	granularity)
	SELECT hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') external_id
			,  17500 profile_type
			, 1 available
			, hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') profile_name
			, @uom_id uom_id
			, 982 granularity
	FROM  #temp_agg_uid tau
	LEFT JOIN forecast_profile fp
		ON fp.profile_name = hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')
	WHERE fp.profile_name IS NULL

	--SET HOURLY VOLUME TO NULL IF ALL UID ARE TERMINATED
	UPDATE ddh 
	SET		ddh.Hr1   = NULL
		   , ddh.Hr2  = NULL
		   , ddh.Hr3  = NULL
		   , ddh.Hr4  = NULL
		   , ddh.Hr5  = NULL
		   , ddh.Hr6  = NULL
		   , ddh.Hr7  = NULL
		   , ddh.Hr8  = NULL
		   , ddh.Hr9  = NULL
		   , ddh.Hr10 = NULL
		   , ddh.Hr11 = NULL
		   , ddh.Hr12 = NULL
		   , ddh.Hr13 = NULL
		   , ddh.Hr14 = NULL
		   , ddh.Hr15 = NULL
		   , ddh.Hr16 = NULL
		   , ddh.Hr17 = NULL
		   , ddh.Hr18 = NULL
		   , ddh.Hr19 = NULL
		   , ddh.Hr20 = NULL
		   , ddh.Hr21 = NULL
		   , ddh.Hr22 = NULL
		   , ddh.Hr23 = NULL
		   , ddh.Hr24 = NULL
		   , ddh.Hr25 = NULL
	 OUTPUT INSERTED.profile_id INTO #temp_updated_profile_id(profile_id)
	FROM deal_detail_hour ddh
	INNER JOIN 
		(
			SELECT DISTINCT  sdd.profile_id
			FROM udt_customer_deals_header_info uo
			OUTER APPLY (
				SELECT   1 terminated
				FROM udt_customer_deals_header_info ui		
				WHERE status <> 'Terminate'
					AND uo.hub = ui.hub
					AND uo.zone = ui.zone
					AND uo.channel = ui.channel
					AND uo.Product = ui.Product
			) sub
			INNER JOIN udt_aggregated_deal_header uadh
				ON	 uadh.hub = uo.hub
				AND  uadh.zone = uo.zone
				AND  uadh.channel = uo.channel
				AND  uadh.Product = uo.Product
			INNER JOIN source_deal_detail sdd
				ON sdd.source_deal_header_id = uadh.source_deal_header_id
			WHERE sub.terminated IS NULL
		) terminated_profile
			ON terminated_profile.profile_id = ddh.profile_id

	UPDATE ddh
	SET ddh.Hr1 = a.Hr1
		, ddh.Hr2 = a.Hr2
		, ddh.Hr3 = a.Hr3
		, ddh.Hr4 = a.Hr4
		, ddh.Hr5 = a.Hr5
		, ddh.Hr6 = a.Hr6
		, ddh.Hr7 = a.Hr7
		, ddh.Hr8 = a.Hr8
		, ddh.Hr9 = a.Hr9
		, ddh.Hr10 = a.Hr10
		, ddh.Hr11 = a.Hr11
		, ddh.Hr12 = a.Hr12
		, ddh.Hr13 = a.Hr13
		, ddh.Hr14 = a.Hr14
		, ddh.Hr15 = a.Hr15
		, ddh.Hr16 = a.Hr16
		, ddh.Hr17 = a.Hr17
		, ddh.Hr18 = a.Hr18
		, ddh.Hr19 = a.Hr19
		, ddh.Hr20 = a.Hr20
		, ddh.Hr21 = a.Hr21
		, ddh.Hr22 = a.Hr22
		, ddh.Hr23 = a.Hr23
		, ddh.Hr24 = a.Hr24
		, ddh.Hr25 = a.Hr25
	OUTPUT INSERTED.profile_id INTO #temp_updated_profile_id(profile_id)
    FROM (
		SELECT  uhv.term_date
			, fp.profile_id
			, SUM(uhv.Hr1 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))  Hr1 
			, SUM(uhv.Hr2 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
			+ CASE MAX(dst.hour) 
				WHEN 2 THEN SUM(uhv.Hr25 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))					
				ELSE 0 
				END Hr2 
			, SUM(uhv.Hr3 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	
			+ CASE MAX(dst.hour) 
				WHEN 3 THEN SUM(uhv.Hr25 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))					
				ELSE 0 
				END Hr3 
			, SUM(uhv.Hr4 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr4 
			, SUM(uhv.Hr5 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr5 
			, SUM(uhv.Hr6 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr6 
			, SUM(uhv.Hr7 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr7 
			, SUM(uhv.Hr8 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr8 
			, SUM(uhv.Hr9 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr9 
			, SUM(uhv.Hr10 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr10
			, SUM(uhv.Hr11 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr11
			, SUM(uhv.Hr12 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr12
			, SUM(uhv.Hr13 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr13
			, SUM(uhv.Hr14 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr14
			, SUM(uhv.Hr15 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr15
			, SUM(uhv.Hr16 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr16
			, SUM(uhv.Hr17 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr17
			, SUM(uhv.Hr18 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr18
			, SUM(uhv.Hr19 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr19
			, SUM(uhv.Hr20 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr20
			, SUM(uhv.Hr21 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr21
			, SUM(uhv.Hr22 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr22
			, SUM(uhv.Hr23 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr23
			, SUM(uhv.Hr24 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr24
			, SUM(uhv.Hr25 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))	Hr25			
		FROM #udt_customer_deals_header_info udh
		INNER JOIN forecast_profile fp
			ON (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) = fp.profile_name
		INNER JOIN udt_customer_hourly_volume_info uhv
			ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
			AND uhv.term_date BETWEEN udh.entire_term_start AND udh.entire_term_end
		INNER JOIN deal_detail_hour ddh
			ON ddh.term_date = uhv.term_date
			AND ddh.profile_id = fp.profile_id
		LEFT JOIN MV90_dst dst
			ON dst.date = uhv.term_date
			AND dst.dst_group_value_id = 102200
			AND dst.insert_delete = 'i'	
		WHERE  udh.status <> 'Terminate'
			AND uhv.term_date >= @as_of_date
		GROUP BY  uhv.term_date, fp.profile_id
	) a
	INNER JOIN deal_detail_hour ddh
		ON ddh.term_date = a.term_date
		AND ddh.profile_id = a.profile_id
		 
	--SELECT ddh.*	
	--	INTO #temp_deal_detail_hour
	--FROM #udt_customer_deals_header_info udh
	--INNER JOIN forecast_profile fp
	--	ON (hub + '_' + zone + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) = fp.profile_name
	--INNER JOIN deal_detail_hour ddh
	--	ON ddh.profile_id = fp.profile_id
	--WHERE udh.status <> 'Terminate'

	INSERT INTO deal_detail_hour (
			term_date
			, profile_id
			, Hr1
			, Hr2
			, Hr3
			, Hr4
			, Hr5
			, Hr6
			, Hr7
			, Hr8
			, Hr9
			, Hr10
			, Hr11
			, Hr12
			, Hr13
			, Hr14
			, Hr15
			, Hr16
			, Hr17
			, Hr18
			, Hr19
			, Hr20
			, Hr21
			, Hr22
			, Hr23
			, Hr24
			, Hr25			
	)
	 OUTPUT INSERTED.profile_id INTO #temp_inserted_profile_id(profile_id)

	SELECT  uhv.term_date
		, fp.profile_id
		, SUM(uhv.Hr1 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr2 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1)) 
		+ CASE MAX(dst.hour) 
				WHEN 2 THEN SUM(uhv.Hr25 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1)) 				
				ELSE 0 
				END 
		, SUM(uhv.Hr3 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		+ CASE MAX(dst.hour) 
				WHEN 3 THEN SUM(uhv.Hr25 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1)) 				
				ELSE 0 
				END 
		, SUM(uhv.Hr4 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr5 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr6 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr7 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr8 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr9 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr10 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr11 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr12 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr13 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr14 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr15 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr16 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr17 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr18 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr19 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr20 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr21 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr22 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr23 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr24 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
		, SUM(uhv.Hr25 * ISNULL(udh.customer_count, 1) * ISNULL(udh.volume_multiplier, 1))
	FROM #udt_customer_deals_header_info udh
	INNER JOIN forecast_profile fp
		ON (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) = fp.profile_name
	INNER JOIN udt_customer_hourly_volume_info uhv
		ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
		AND uhv.term_date BETWEEN udh.entire_term_start AND udh.entire_term_end
	LEFT JOIN deal_detail_hour ddh
		ON ddh.term_date = uhv.term_date
		AND ddh.profile_id = fp.profile_id
	LEFT JOIN MV90_dst dst
			ON dst.date = uhv.term_date
			AND dst.dst_group_value_id = 102200
			AND dst.insert_delete = 'i'	
	WHERE ddh.profile_id IS NULL
		AND udh.status <> 'Terminate'
		--AND  uhv.term_date >= @as_of_date
	GROUP BY  uhv.term_date, fp.profile_id

	SELECT DISTINCT source_deal_header_id 
	INTO #temp_updated_deal_header
	FROM source_deal_detail sdd
	INNER JOIN (
		SELECT DISTINCT * FROM #temp_updated_profile_id
		UNION 
		SELECT DISTINCT * FROM #temp_inserted_profile_id
	) tup
		ON sdd.profile_id  = tup.profile_id

	UPDATE sdd	
		SET sdd.profile_id =  IIF(uh.type IN('uncommitted', 'onm_uncommitted'), fpu.profile_id, fp.profile_id) 
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM (
		SELECT * FROM #temp_customer_deals_header_info
		UNION ALL
		SELECT * FROM #temp_customer_deals_header_info_transfer	
	) uh
	LEFT JOIN forecast_profile fp
		ON uh.deal_id  = fp.profile_name 
	LEFT JOIN forecast_profile fpu
		ON uh.zone + '_' + REPLACE(uh.channel, ' ', '_') + '_' + REPLACE(@hardcoded_product, ' ', '_') + '_UC'  = fpu.profile_name
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = uh.id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id

	SELECT DISTINCT uhv.uid
		, CAST(YEAR(term_date) AS VARCHAR(10)) + '-' + CAST(MONTH(term_date) AS VARCHAR(10)) term
		, SUM(ISNULL(uhv.Hr1, 0))  
		+ SUM(ISNULL(uhv.Hr2, 0))  
		+ SUM(ISNULL(uhv.Hr3, 0))  
		+ SUM(ISNULL(uhv.Hr4, 0))  
		+ SUM(ISNULL(uhv.Hr5, 0))  
		+ SUM(ISNULL(uhv.Hr6, 0))  
		+ SUM(ISNULL(uhv.Hr7, 0))  
		+ SUM(ISNULL(uhv.Hr8, 0))  
		+ SUM(ISNULL(uhv.Hr9, 0))  
		+ SUM(ISNULL(uhv.Hr10, 0)) 
		+ SUM(ISNULL(uhv.Hr11, 0)) 
		+ SUM(ISNULL(uhv.Hr12, 0)) 
		+ SUM(ISNULL(uhv.Hr13, 0)) 
		+ SUM(ISNULL(uhv.Hr14, 0)) 
		+ SUM(ISNULL(uhv.Hr15, 0)) 
		+ SUM(ISNULL(uhv.Hr16, 0)) 
		+ SUM(ISNULL(uhv.Hr17, 0)) 
		+ SUM(ISNULL(uhv.Hr18, 0)) 
		+ SUM(ISNULL(uhv.Hr19, 0)) 
		+ SUM(ISNULL(uhv.Hr20, 0)) 
		+ SUM(ISNULL(uhv.Hr21, 0)) 
		+ SUM(ISNULL(uhv.Hr22, 0)) 
		+ SUM(ISNULL(uhv.Hr23, 0)) 
		+ SUM(ISNULL(uhv.Hr24, 0)) 
		+ SUM(ISNULL(uhv.Hr25, 0)) monthly_volume	
	INTO #temp_monthly_volume 
	FROM udt_customer_hourly_volume_info uhv
	INNER JOIN #udt_customer_deals_header_info udh
		ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
	--where  CAST(YEAR(term_date) AS VARCHAR(10)) + '-' + CAST(MONTH(term_date) AS VARCHAR(10)) = '2019-9'
	WHERE udh.status <> 'Terminate'
		AND term_date BETWEEN udh.entire_term_start AND udh.entire_term_end		
	GROUP BY uhv.uid,udh.uid, CAST(YEAR(term_date) AS VARCHAR(10)) + '-' + CAST(MONTH(term_date) AS VARCHAR(10))

	--weighted average cost
	SELECT source_deal_header_id
			, term	
			, udf
			, udf_value
	INTO  #temp_wac_udf		
	FROM   
	   (
			SELECT	 udh.hub
					, udh.zone
					, udh.channel
					, udh.Product
					, tmv.term	
					, sdh.source_deal_header_id
					, SUM(agent_fee * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) agent_fee
					, SUM(ancillaries * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) ancillaries
					, SUM(arr_ftr * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) arr_ftr
					, SUM(basis * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) basis
					, SUM(capacity * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) capacity
					, SUM(green * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) green
					, SUM(losses * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) losses
					, SUM(manual_cost_adj * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) manual_cost_adj
					, SUM(margin * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) margin
					, SUM(nits_tec * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) nits_tec
					, SUM(risk * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) risk
					, SUM(tax * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) tax
					, SUM(wpa * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) wpa
			 FROM #temp_monthly_volume tmv
			INNER JOIN #udt_customer_deals_header_info udh
				ON tmv.uid = ISNULL(udh.profile_code, udh.uid)
				AND CAST(tmv.term + '-01' AS DATETIME) BETWEEN  [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start, 'f') AND EOMONTH(udh.entire_term_end) --TODO: use data table
			INNER JOIN(
					SELECT * FROM #temp_customer_deals_header_info WHERE type IN ('Loss', 'Original')
					UNION ALL
					SELECT * FROM #temp_customer_deals_header_info_transfer	
				)	uadh
				ON uadh.hub = udh.hub
				AND uadh.zone = udh.zone
				AND uadh.product = udh.product
				AND uadh.channel = udh.channel
			INNER JOIN source_deal_header sdh
				ON (sdh.deal_id = uadh.id
				OR
					(		
						sdh.deal_id = uadh.deal_id 
						OR sdh.deal_id = uadh.deal_id + '_Loss'
						OR sdh.deal_id = uadh.deal_id + '_Offset'
						OR sdh.deal_id = uadh.deal_id + '_Xfer'
					)
				)
			WHERE udh.status <> 'Terminate'
			GROUP BY udh.hub, udh.zone, udh.channel, udh.Product,sdh.source_deal_header_id, tmv.term

	) p  
	UNPIVOT  
	   (udf_value FOR udf IN   
		  (agent_fee
			, ancillaries
			, arr_ftr
			, basis
			, capacity
			, green
			, losses
			, manual_cost_adj
			, margin
			, nits_tec
			, risk
			, tax 
			, wpa
			)  
	)AS unpvt

	UPDATE user_defined_deal_detail_fields
		SET udf_value = twu.udf_value
	FROM source_deal_detail sdd
	INNER JOIN  (	
		SELECT source_deal_header_id FROM #temp_inserted_deal_header
		UNION ALL
		SELECT source_deal_header_id FROM #temp_updated_deal_header
	) tidh
		ON sdd.source_deal_header_id = tidh.source_deal_header_id
	CROSS JOIN (SELECT udf_template_id , field_label
				FROM user_defined_deal_fields_template 
				WHERE template_id =  @template_id --2749 
					--AND udf_template_id < 0 
					AND udf_type = 'd'
					AND  REPLACE(field_label, ' ', '_') IN (
															'agent_fee', 
															'ancillaries', 
															'arr_ftr',
															'basis',
															'capacity',
															'green',
															'losses',
															'manual_cost_adj',
															'margin',
															'nits_tec',
															'risk',
															'tax',
															'wpa'
															)
	) a 
	INNER JOIN #temp_wac_udf twu
		ON twu.source_deal_header_id = sdd.source_deal_header_id
		AND twu.term = CAST(YEAR(sdd.term_start) AS VARCHAR(10)) + '-' + CAST(MONTH(sdd.term_start) AS VARCHAR(10))
		AND twu.udf = REPLACE(a.field_label, ' ', '_')
	INNER JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND udddf.udf_template_id = a.udf_template_id 

	UPDATE user_defined_deal_detail_fields
		SET udf_value = unpvt.udf_value
	FROM 
	(	SELECT udhc.*, sdd.source_deal_header_id, sdh.template_id, sdd.source_deal_detail_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #udt_customer_deals_header_info_polr_muni udhc
			ON udhc.uid = sdh.deal_id		
	  ) a
	  UNPIVOT  
		   (udf_value FOR udf IN (agent_fee
									, ancillaries
									, arr_ftr
									, basis
									, capacity
									, green
									, losses
									, manual_cost_adj
									, margin
									, nits_tec
									, risk
									, tax
									, wpa
									)  
	)AS unpvt
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.template_id = unpvt.template_id
		AND udf_type = 'd'
		AND REPLACE(field_label, ' ', '_') = unpvt.udf
	INNER JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = unpvt.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id 

	--uncommitted 
	UPDATE udddf
		SET udf_value = unpvt.udf_value
	FROM																		
	(	SELECT sdh.source_deal_header_id
			, sdd.source_deal_detail_id 
			, max(term_start) term_start
			, MAX(template_id) template_id
			, udhc.hub					
			, udhc.zone
			, udhc.channel
			, udhc.product
			, AVG(agent_fee)		agent_fee			
			, AVG(ancillaries)		ancillaries
			, AVG(arr_ftr)			arr_ftr
			, AVG(basis)			basis
			, AVG(udhc.capacity)			capacity
			, AVG(green)			green
			, AVG(losses)			losses
			, AVG(manual_cost_adj)	manual_cost_adj
			, AVG(margin)			margin
			, AVG(nits_tec)			nits_tec
			, AVG(risk)				risk
			, AVG(tax)				tax
			, AVG(wpa)				wpa
			
		--select udhc.entire_term_start, udhc.entire_term_end, sdd.term_start, sdd.term_end  
		FROM source_deal_header sdh 	
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN  #temp_customer_deals_header_info uadh  
			ON type = 'Uncommitted'	
			AND (sdh.deal_id = uadh.id
				OR
				sdh.deal_id = uadh.deal_id + '_Uncommitted'
				)
		INNER JOIN #udt_customer_deals_header_info_uncommitted udhc 
			ON udhc.hub = uadh.hub
			AND udhc.zone = uadh.zone
			AND udhc.channel = uadh.channel
			AND udhc.product = uadh.product
			AND udhc.uncommitted = 'Yes'
			AND sdd.term_start BETWEEN udhc.entire_term_start AND udhc.entire_term_end
		GROUP BY sdh.source_deal_header_id,
				 sdd.source_deal_detail_id,
				udhc.hub,
				udhc.zone,
				udhc.channel,
				udhc.product
	  ) a
	  UNPIVOT  
		   (udf_value FOR udf IN (	  agent_fee
									, ancillaries
									, arr_ftr
									, basis
									, capacity
									, green
									, losses
									, manual_cost_adj
									, margin
									, nits_tec
									, risk
									, tax
									, wpa
									)  
	)AS unpvt

	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.template_id = unpvt.template_id
		AND udf_type = 'd'
		AND REPLACE(field_label, ' ', '_') = unpvt.udf
	INNER JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = unpvt.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id 

	--uncommitted polr
	UPDATE udddf
		SET udf_value = unpvt.udf_value
	FROM																		
	(	SELECT sdh.source_deal_header_id,
			MAX(template_id) template_id
			, udhc.hub					
			, udhc.zone
			, udhc.channel
			, udhc.product
			, AVG(agent_fee)		agent_fee			
			, AVG(ancillaries)		ancillaries
			, AVG(arr_ftr)			arr_ftr
			, AVG(basis)			basis
			, AVG(capacity)			capacity
			, AVG(green)			green
			, AVG(losses)			losses
			, AVG(manual_cost_adj)	manual_cost_adj
			, AVG(margin)			margin
			, AVG(nits_tec)			nits_tec
			, AVG(risk)				risk
			, AVG(tax)				tax
			, AVG(wpa)				wpa
	FROM source_deal_header sdh 		
		INNER JOIN  #temp_customer_deals_header_info_polr_muni_uncommitted uadh  -- select * from #temp_customer_deals_header_info_polr_muni_uncommitted
			ON type = 'Uncommitted'	
			AND (sdh.deal_id = uadh.id
				OR
				sdh.deal_id = uadh.deal_id + '_Uncommitted'
				)
		INNER JOIN #udt_customer_deals_header_info_polr_muni udhc  
			ON udhc.hub = uadh.hub
			AND udhc.zone = uadh.zone
			AND udhc.channel = uadh.channel
			--AND udhc.product = uadh.product
			AND udhc.uncommitted = 'Yes'
		GROUP BY sdh.source_deal_header_id,
				udhc.hub,
				udhc.zone,
				udhc.channel
				,udhc.product
	  ) a
	  UNPIVOT  
		   (udf_value FOR udf IN (	  agent_fee
									, ancillaries
									, arr_ftr
									, basis
									, capacity
									, green
									, losses
									, manual_cost_adj
									, margin
									, nits_tec
									, risk
									, tax
									, wpa
									)  
	)AS unpvt
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = unpvt.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.template_id = unpvt.template_id
		AND udf_type = 'd'
		AND REPLACE(field_label, ' ', '_') = unpvt.udf
	INNER JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id 

	/**FACT: Costs (udfs) are only in original and uncommitted deals only
			For committed deal cost is weight average
			for uncommitted deal cost is average
			for polr committed deal cost it same as individual customer
	**/



	INSERT INTO user_defined_deal_detail_fields(
		source_deal_detail_id
		, udf_template_id
		, udf_value
	)
	SELECT  sdd.source_deal_detail_id
		, a.udf_template_id
		, twu.udf_value
	FROM source_deal_detail sdd
	INNER JOIN (	
		SELECT source_deal_header_id 
		FROM #temp_inserted_deal_header
		UNION ALL
		SELECT tudh.source_deal_header_id 
		FROM #temp_updated_deal_header tudh
		INNER JOIN udt_aggregated_deal_header uadh
			ON tudh.source_deal_header_id = uadh.source_deal_header_id
		WHERE uncommitted IS NULL	
	)tidh
		ON sdd.source_deal_header_id = tidh.source_deal_header_id
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #temp_customer_deals_header_info tdh           
		ON ( tdh.id = sdh.deal_id
			OR 
			tdh.deal_id = sdh.deal_id
		)
	CROSS JOIN (SELECT uddft.udf_template_id
						, uddft.field_label
				FROM user_defined_deal_fields_template uddft
				INNER JOIN static_data_value sdv
					ON sdv.value_id = uddft.field_name
					AND sdv.type_id = 5500
				WHERE uddft.template_id = @template_id --2752 
					AND uddft.udf_type = 'd'
					AND REPLACE(sdv.code, ' ', '_') IN (
															'agent_fee', 
															'ancillaries', 
															'arr_ftr',
															'basis',
															'capacity',
															'green',
															'losses',
															'manual_cost_adj',
															'margin',
															'nits_tec',
															'risk',
															'tax',
															'wpa' 
														)
	) a 
	LEFT JOIN #temp_wac_udf twu
		ON twu.source_deal_header_id = sdd.source_deal_header_id
		AND twu.term = CAST(YEAR(sdd.term_start) AS VARCHAR(10)) + '-' + CAST(MONTH(sdd.term_start) AS VARCHAR(10))
		AND twu.udf = REPLACE(a.field_label, ' ', '_')
	LEFT JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND udddf.udf_template_id = a.udf_template_id 
	WHERE udddf.source_deal_detail_id IS NULL
		AND tdh.type = 'original'

		--order by term_start
	UNION ALL --Polr Muni deal
	SELECT unpvt.source_deal_detail_id
		, uddft.udf_template_id
		, unpvt.udf_value--, unpvt.template_id
	FROM 
	(	SELECT udhc.*, sdd.source_deal_header_id, sdh.template_id, sdd.source_deal_detail_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #udt_customer_deals_header_info_polr_muni udhc
			ON udhc.uid = sdh.deal_id --for original deal only
	  ) a
	  UNPIVOT  
		   (udf_value FOR udf IN (agent_fee
									, ancillaries
									, arr_ftr
									, basis
									, capacity
									, green
									, losses
									, manual_cost_adj
									, margin
									, nits_tec
									, risk
									, tax
									, wpa
									)  
	)AS unpvt
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.template_id = unpvt.template_id
		AND udf_type = 'd'
		AND REPLACE(field_label, ' ', '_') = unpvt.udf
	LEFT JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = unpvt.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id 
	WHERE udddf.source_deal_detail_id IS NULL
	UNION ALL --Uncommittted Deals
	SELECT sdd.source_deal_detail_id
		, uddft.udf_template_id
		, unpvt.udf_value
	FROM																		
	(	SELECT sdh.source_deal_header_id,
			MAX(template_id) template_id
			, udhc.hub					
			, udhc.zone
			, udhc.channel
			, udhc.product
			, AVG(agent_fee)		agent_fee			
			, AVG(ancillaries)		ancillaries
			, AVG(arr_ftr)			arr_ftr
			, AVG(basis)			basis
			, AVG(capacity)			capacity
			, AVG(green)			green
			, AVG(losses)			losses
			, AVG(manual_cost_adj)	manual_cost_adj
			, AVG(margin)			margin
			, AVG(nits_tec)			nits_tec
			, AVG(risk)				risk
			, AVG(tax)				tax
			, AVG(wpa)				wpa
		FROM source_deal_header sdh 		
		INNER JOIN  #temp_customer_deals_header_info uadh 
			ON type = 'Uncommitted'	
			AND (sdh.deal_id = uadh.id
				OR
				sdh.deal_id = uadh.deal_id + '_Uncommitted'
				)
		INNER JOIN #udt_customer_deals_header_info_uncommitted udhc  
			ON udhc.hub = uadh.hub
			AND udhc.zone = uadh.zone
			AND udhc.channel = uadh.channel
			AND udhc.product = uadh.product
			AND udhc.uncommitted = 'Yes'
		GROUP BY sdh.source_deal_header_id,
				udhc.hub,
				udhc.zone,
				udhc.channel,
				udhc.product
	  ) a
	  UNPIVOT  
		   (udf_value FOR udf IN (	  agent_fee
									, ancillaries
									, arr_ftr
									, basis
									, capacity
									, green
									, losses
									, manual_cost_adj
									, margin
									, nits_tec
									, risk
									, tax
									, wpa
									)  
	)AS unpvt
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = unpvt.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.template_id = unpvt.template_id
		AND udf_type = 'd'
		AND REPLACE(field_label, ' ', '_') = unpvt.udf
	LEFT JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id 
	WHERE udddf.source_deal_detail_id IS NULL
	UNION ALL --Uncommittted Deals polr
	SELECT sdd.source_deal_detail_id
		, uddft.udf_template_id
		, unpvt.udf_value
	FROM																		
	(	SELECT sdh.source_deal_header_id,
			MAX(template_id) template_id
			, udhc.hub					
			, udhc.zone
			, udhc.channel
			, udhc.product
			, AVG(agent_fee)		agent_fee			
			, AVG(ancillaries)		ancillaries
			, AVG(arr_ftr)			arr_ftr
			, AVG(basis)			basis
			, AVG(capacity)			capacity
			, AVG(green)			green
			, AVG(losses)			losses
			, AVG(manual_cost_adj)	manual_cost_adj
			, AVG(margin)			margin
			, AVG(nits_tec)			nits_tec
			, AVG(risk)				risk
			, AVG(tax)				tax
			, AVG(wpa)				wpa
	FROM source_deal_header sdh 		
		INNER JOIN  #temp_customer_deals_header_info_polr_muni_uncommitted uadh  -- select * from #temp_customer_deals_header_info_polr_muni_uncommitted
			ON type = 'Uncommitted'	
			AND (sdh.deal_id = uadh.id
				OR
				sdh.deal_id = uadh.deal_id + '_Uncommitted'
				)
		INNER JOIN #udt_customer_deals_header_info_polr_muni udhc  
			ON udhc.hub = uadh.hub
			AND udhc.zone = uadh.zone
			AND udhc.channel = uadh.channel
			--AND udhc.product = uadh.product
			AND udhc.uncommitted = 'Yes'
		GROUP BY sdh.source_deal_header_id,
				udhc.hub,
				udhc.zone,
				udhc.channel
				,udhc.product
	  ) a
	  UNPIVOT  
		   (udf_value FOR udf IN (	  agent_fee
									, ancillaries
									, arr_ftr
									, basis
									, capacity
									, green
									, losses
									, manual_cost_adj
									, margin
									, nits_tec
									, risk
									, tax
									, wpa
									)  
	)AS unpvt
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = unpvt.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.template_id = unpvt.template_id
		AND udf_type = 'd'
		AND REPLACE(field_label, ' ', '_') = unpvt.udf
	LEFT JOIN user_defined_deal_detail_fields udddf
		ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND udddf.udf_template_id = uddft.udf_template_id 
	WHERE udddf.source_deal_detail_id IS NULL
	--order by 1, 2


	UPDATE sdd
		SET sdd.formula_curve_id =  spcd.source_curve_def_id
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM( 
			SELECT * FROM #temp_customer_deals_header_info 
			UNION ALL
			SELECT * FROM #temp_customer_deals_header_info_transfer
	)tcdh	
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = tcdh.deal_id + IIF(type = 'Original', '', '_' + tcdh.type)
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id 
	OUTER APPLY (
		SELECT MAX(energy_lmp)  energy_lmp
		FROM #udt_customer_deals_header_info u
		WHERE u.hub = tcdh.hub
			AND u.zone = tcdh.zone
			AND u.channel = tcdh.channel
			AND u.product = tcdh.product
		GROUP BY u.hub, u.zone, u.channel, u.product
	)udhc
	LEFT JOIN source_price_curve_def spcd
		ON spcd.curve_id = udhc.energy_lmp

	UPDATE sdd
	SET sdd.fixed_price = IIF(sdd.formula_curve_id IS NULL, energy, NULL)
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM (		
		SELECT
				--MAX(sdh.source_deal_header_id) source_deal_header_id
				sdh.source_deal_header_id
				, tmv.term					
				, SUM(energy * tmv.monthly_volume)/SUM(NULLIF(tmv.monthly_volume, 0)) energy
		FROM #temp_monthly_volume tmv
		INNER JOIN #udt_customer_deals_header_info udh
			ON tmv.uid = ISNULL(udh.profile_code, udh.uid)
			AND CAST(tmv.term + '-01' AS DATETIME) BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start, 'f') AND EOMONTH(udh.entire_term_end) --TODO: use data table
		INNER JOIN(
					SELECT * FROM #temp_customer_deals_header_info WHERE type IN ('Loss', 'original')
					UNION ALL
					SELECT * FROM #temp_customer_deals_header_info_transfer	
				) uadh
			ON uadh.hub = udh.hub
			AND uadh.zone = udh.zone
			AND uadh.product = udh.product
			AND uadh.channel = udh.channel
		INNER JOIN source_deal_header sdh
			ON (
					sdh.deal_id = uadh.id
					OR 
					(		
						sdh.deal_id = uadh.deal_id 
						OR sdh.deal_id = uadh.deal_id + '_Loss'
						OR sdh.deal_id = uadh.deal_id + '_Offset'
						OR sdh.deal_id = uadh.deal_id + '_Xfer'
					)				
				)
		WHERE udh.status <> 'Terminate'
		GROUP BY udh.hub, udh.zone, udh.channel, udh.Product, tmv.term,sdh.source_deal_header_id
	) a
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = a.source_deal_header_id 
		AND a.term = CAST(YEAR(sdd.term_start) AS VARCHAR(10)) + '-' + CAST(MONTH(sdd.term_start) AS VARCHAR(10))
		
	--average fixed price calc for uncommitted deal
	UPDATE sdd
		SET sdd.fixed_price = IIF(sdd.formula_curve_id IS NULL, fp.energy, NULL),
			 sdd.price_multiplier = IIF(sdd.formula_curve_id IS NULL, NULL, fp.index_multiplier)
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM source_deal_detail sdd
	INNER JOIN  (
		SELECT sdh.source_deal_header_id,  AVG(energy) energy, AVG(index_multiplier) index_multiplier
		FROM #temp_customer_deals_header_info tcdh
		INNER JOIN #udt_customer_deals_header_info_uncommitted udhu  
			ON tcdh.hub = udhu.hub
			AND tcdh.zone = udhu.zone
			AND tcdh.channel = udhu.channel
			AND tcdh.product = udhu.product
		INNER JOIN source_deal_header sdh
			ON (	sdh.deal_id = tcdh.id
					OR sdh.deal_id = tcdh.deal_id + '_Uncommitted' 
					--OR sdh.deal_id = tcdh.deal_id + '_OnM_Uncommitted' 
				)
		WHERE type IN ( 'uncommitted') --, '_OnM_Uncommitted' )
			AND udhu.status <> 'Terminate'
		GROUP BY sdh.source_deal_header_id,udhu.hub, udhu.zone, udhu.channel, udhu.product
	) fp
		ON fp.source_deal_header_id = sdd.source_deal_header_id

	UPDATE sdh
	SET deal_id =  (i.hub + '_' + REPLACE(i.zone, ' ', '_') + '_' + REPLACE(i.channel, ' ', '_') + '_' + REPLACE(i.product, ' ', '_')) 
					+ CASE i.type 
						WHEN 'Loss' THEN '_Loss' 
						WHEN 'xfer' THEN '_Xfer' 
						WHEN 'offset' THEN '_Offset' 
						WHEN 'Capacity' THEN '_Capacity'
						WHEN 'Transmission' THEN '_Transmission'
						WHEN 'Capacity_uncommitted' THEN '_Capacity_Uncommitted'
						WHEN 'Transmission_uncommitted' THEN '_Transmission_Uncommitted'
						WHEN 'Uncommitted' THEN '_Uncommitted'
						WHEN 'onm_uncommitted' THEN '_OnM_Uncommitted'
						WHEN 'onm' THEN '_OnM'
						ELSE ''
					END	 
	FROM source_deal_header sdh		
	INNER JOIN(
					SELECT * FROM #temp_customer_deals_header_info
					UNION ALL
					SELECT * FROM #temp_customer_deals_header_info_transfer	
					UNION ALL 
					SELECT * FROM #temp_customer_deals_header_info_ct
				) i
		ON sdh.deal_id = i.id
	INNER JOIN #temp_inserted_deal_header tdh
		ON i.id = tdh.deal_id

	UPDATE sdd
		SET multiplier = CASE WHEN sub.deal_id liKE  '%[_]Loss' 
							THEN  NULLIF(sub.agg_loss_multiplier, 0) - 1 
							WHEN sub.deal_id liKE  '%[_]OnM' 
							THEN  NULLIF(sub.agg_loss_multiplier, 0) 
							ELSE NULL 
						END
		, price_multiplier = NULLIF(sub.agg_index_multiplier, 0)
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM
	(
		SELECT --sdh.source_deal_header_id
			 MAX(sdh.deal_id) deal_id
			, CAST(tmv.term + '-01' AS DATE) term
			, SUM(tmv.monthly_volume * udh.loss_multiplier)/SUM(NULLIF(IIF(udh.loss_multiplier >= 1, tmv.monthly_volume, 0), 0)) agg_loss_multiplier
			, SUM(tmv.monthly_volume * udh.index_multiplier)/SUM(NULLIF(IIF(udh.loss_multiplier >= 1, tmv.monthly_volume, 0), 0)) agg_index_multiplier
		FROM #temp_customer_deals_header_info t 
		INNER JOIN source_deal_header sdh			
			ON (
					sdh.deal_id = (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) 
					OR sdh.deal_id = (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) + '_Loss'
					OR sdh.deal_id = (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) + '_Offset'
					OR sdh.deal_id = (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) + '_Xfer'
					OR sdh.deal_id = (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) + '_OnM'
				)
		INNER JOIN #udt_customer_deals_header_info udh
			ON udh.hub = t.hub
			AND udh.zone = t.zone
			AND udh.product = t.product
			AND udh.channel = t.channel
		INNER JOIN #temp_monthly_volume tmv
			ON tmv.uid = ISNULL(udh.profile_code, udh.uid)
			AND CAST(tmv.term + '-01' AS DATETIME) BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start, 'f') AND EOMONTH(udh.entire_term_end) --TODO: use data table
		WHERE udh.status <> 'Terminate'		
		GROUP BY sdh.source_deal_header_id, tmv.term
	) sub
	INNER JOIN source_deal_header sdh
		ON sub.deal_id  = sdh.deal_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
		AND YEAR(sdd.term_start) = YEAR(sub.term)
		AND MONTH(sdd.term_start) = MONTH(sub.term)

	
	SELECT DISTINCT  sdh.source_deal_header_id 
					, sdh.deal_id
					, x.source_deal_header_id source_deal_header_id_transfer
					, x.deal_id deal_id_transfer
	INTO #temp_transfer_deal_mapping	
	FROM #temp_customer_deals_header_info tdh
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id =  (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')+ '_xfer') 
			OR 
			sdh.deal_id =  (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') + '_offset') 
	CROSS APPLY (
			SELECT  sdhx.source_deal_header_id, deal_id 
			FROM source_deal_header sdhx			
			WHERE sdhx.deal_id =  (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) 
				OR 
				sdhx.deal_id =  (hub + '_' + REPLACE(zone, ' ', '_') + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') + '_Loss') 			  	 
	) x	
		
	UPDATE sdd
		SET multiplier = sub.multiplier	
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM source_deal_detail sdd
	INNER JOIN (
		SELECT sdd.source_deal_detail_id, SUM(a.multiplier) multiplier
		FROM #temp_transfer_deal_mapping t
		INNER JOIN source_deal_detail sdd
			ON t.source_deal_header_id = sdd.source_deal_header_id
		CROSS APPLY (
			SELECT  sdd.source_deal_header_id, sddx.term_start , ISNULL(multiplier, 1) multiplier
			FROM source_deal_detail sddx
			WHERE sddx.source_deal_header_id  = t.source_deal_header_id_transfer
				AND sddx.term_start = sdd.term_start
				AND sddx.term_end = sdd.term_end
		) a
		GROUP BY sdd.source_deal_detail_id
	) sub
	ON sub.source_deal_detail_id = sdd.source_deal_detail_id

	IF @committed_uncommitted IN ('c', 'b')
	BEGIN
		SET @sql = N'DELETE udh
					FROM udt_monthly_committed_volume udh
					'
					+ CASE WHEN @zone IS NULL THEN '' 
							ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@zone) z
										ON z.item = udh.zone 
								'
						END
					+ CASE WHEN @channel IS NULL THEN '' 
							ELSE' INNER JOIN dbo.SplitCommaSeperatedValues(@channel) c
										ON c.item = udh.channel 
								'
						END
					+ CASE WHEN @product IS NULL THEN '' 
							ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@product) p
										ON p.item = udh.product 
								'
						END
					+ ' WHERE term >= @as_of_date_first' 
		SET @parm_definition = N' @zone VARCHAR(MAX), @channel VARCHAR(MAX), @product VARCHAR(MAX),@as_of_date_first DATETIME';  

		EXECUTE sp_executesql @sql, @parm_definition,  @zone = @zone, @channel = @channel, @product = @product, @as_of_date_first = @as_of_date_first




		SELECT hub, zone, channel, product, sdd.term_start term,
			1 + sdd.multiplier [Loss_multiplier] 		
		INTO #temp_loss_mul
		FROM source_deal_header sdh
		INNER JOIN #temp_customer_deals_header_info tcdh
			ON sdh.deal_id = tcdh.deal_id + '_Loss'
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN (
			SELECT source_deal_header_id FROM #temp_inserted_deal_header
			UNION 
			SELECT source_deal_header_id FROM #temp_updated_deal_header
		) loss
			ON loss.source_deal_header_id = sdh.source_deal_header_id

		WHERE tcdh.type = 'Loss'
		AND sdd.term_start >= @as_of_date_first --'2020-02-01'-


		SELECT tcdh.hub,
				tcdh.zone,
				tcdh.channel,
				tcdh.Product,	
				DATEFROMPARTS(YEAR(ddh.term_date),  MONTH(ddh.term_date), 1) term 
				, SUM( 
					ddh.hr1 * hbt_p.hr1 + 
					ddh.hr2 * hbt_p.hr2 + 
					ddh.hr3 * hbt_p.hr3 + 
					ddh.hr4 * hbt_p.hr4 + 
					ddh.hr5 * hbt_p.hr5 + 
					ddh.hr6 * hbt_p.hr6 + 
					ddh.hr7 * hbt_p.hr7 + 
					ddh.hr8 * hbt_p.hr8 + 
					ddh.hr9 * hbt_p.hr9 + 
					ddh.hr10 * hbt_p.hr10 + 
					ddh.hr11 * hbt_p.hr11 + 
					ddh.hr12 * hbt_p.hr12 + 
					ddh.hr13 * hbt_p.hr13 + 
					ddh.hr14 * hbt_p.hr14 + 
					ddh.hr15 * hbt_p.hr15 + 
					ddh.hr16 * hbt_p.hr16 + 
					ddh.hr17 * hbt_p.hr17 + 
					ddh.hr18 * hbt_p.hr18 + 
					ddh.hr19 * hbt_p.hr19 + 
					ddh.hr20 * hbt_p.hr20 + 
					ddh.hr21 * hbt_p.hr21 + 
					ddh.hr22 * hbt_p.hr22 +
					ddh.hr23 * hbt_p.hr23 +
					ddh.hr24 * hbt_p.hr24 				
		) onpeak_monthly_committed_mwh,
		SUM( 
					ddh.hr1 * hbt_o.hr1  + 
					ddh.hr2 * hbt_o.hr2  + 
					ddh.hr3 * hbt_o.hr3 + 
					ddh.hr4 * hbt_o.hr4 + 
					ddh.hr5 * hbt_o.hr5 + 
					ddh.hr6 * hbt_o.hr6 + 
					ddh.hr7 * hbt_o.hr7 + 
					ddh.hr8 * hbt_o.hr8 + 
					ddh.hr9 * hbt_o.hr9 + 
					ddh.hr10 * hbt_o.hr10  + 
					ddh.hr11 * hbt_o.hr11  + 
					ddh.hr12 * hbt_o.hr12  + 
					ddh.hr13 * hbt_o.hr13  + 
					ddh.hr14 * hbt_o.hr14  + 
					ddh.hr15 * hbt_o.hr15  + 
					ddh.hr16 * hbt_o.hr16  + 
					ddh.hr17 * hbt_o.hr17  + 
					ddh.hr18 * hbt_o.hr18  + 
					ddh.hr19 * hbt_o.hr19  + 
					ddh.hr20 * hbt_o.hr20  + 
					ddh.hr21 * hbt_o.hr21  + 
					ddh.hr22 * hbt_o.hr22  +
					ddh.hr23 * hbt_o.hr23  +
					ddh.hr24 * hbt_o.hr24  				
		) offpeak_monthly_committed_mwh	
	INTO  #temp_peak_off_peak
	FROM source_deal_header sdh	
		INNER JOIN (
			SELECT source_deal_header_id FROM #temp_inserted_deal_header
			UNION 
			SELECT source_deal_header_id FROM #temp_updated_deal_header
		) org
			ON org.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #temp_customer_deals_header_info tcdh
			ON sdh.deal_id = tcdh.deal_id
		INNER JOIN forecast_profile fp
			ON profile_name = sdh.deal_id
		INNER JOIN deal_detail_hour ddh 
			ON fp.profile_id = ddh.profile_id
		INNER JOIN hour_block_term hbt_p
			ON hbt_p.term_date = ddh.term_date
			AND hbt_p.block_define_id IN(10000134)
			AND hbt_p.dst_group_value_id = 102200 
		INNER JOIN hour_block_term hbt_o
			ON hbt_o.term_date = ddh.term_date
			AND hbt_o.block_define_id IN( 10000135)
			AND hbt_o.dst_group_value_id = 102200 
		WHERE tcdh.type = 'original'
			AND ddh.term_date >= @as_of_date_first -- '2020-02-01' 
		GROUP BY tcdh.hub, tcdh.zone, tcdh.channel, tcdh.Product, YEAR(ddh.term_date), MONTH(ddh.term_date)


		SELECT hub, zone, channel, product, DATEFROMPARTS(YEAR(term_start),  MONTH(term_start), 1) term, 	
				MAX([agent fee]) agent_fee ,  
				MAX(ancillaries) ancillaries, 
				MAX([arr ftr]) arr_ftr,
				MAX(basis) basis,
				MAX(capacity) capacity,
				MAX(green) green,
				MAX(losses) losses,
				MAX([manual cost adj]) manual_cost_adj,
				MAX(margin) margin,
				MAX([nits tec]) nits_tec,
				MAX(risk) risk,
				MAX(tax) tax,
				MAX(wpa) wpa,
				MAX(energy) energy,
				MAX([index_multiplier]) [index_multiplier],
				MAX([energy_lmp]) [energy_lmp]
		INTO #temp_cost
		FROM   
		(
			SELECT tcdh.hub
				, tcdh.zone
				, tcdh.channel
				, tcdh.product
				, sdd.term_start
				, sdd.fixed_price energy
				, sdd.price_multiplier [index_multiplier]
				, sdd.formula_curve_id [energy_lmp]
				, uddft.Field_label
				---handle udf_value with scientific notation
				, IIF(CHARINDEX('e',udddf.udf_value)>0, CAST(CAST(udddf.udf_value AS FLOAT) AS NUMERIC(38,20)), CAST(udddf.udf_value AS NUMERIC(38,20))) udf_value 

			FROM source_deal_header sdh
			INNER JOIN (
				SELECT source_deal_header_id FROM #temp_inserted_deal_header
				UNION 
				SELECT source_deal_header_id FROM #temp_updated_deal_header
			) org
				ON org.source_deal_header_id =  sdh.source_deal_header_id
			INNER JOIN #temp_customer_deals_header_info tcdh
				ON sdh.deal_id = tcdh.deal_id		
			INNER JOIN source_deal_detail sdd
				ON sdh.source_deal_header_id = sdd.source_deal_header_id

			INNER JOIN user_defined_deal_detail_fields udddf
				ON sdd.source_deal_detail_id = udddf.source_deal_detail_id
			INNER JOIN user_defined_deal_fields_template uddft
				ON uddft.template_id = sdh.template_id
				AND uddft.udf_type = 'd'
				AND uddft.udf_template_id = udddf.udf_template_id
			WHERE  tcdh.type = 'original'
				AND sdd.term_start >= @as_of_date_first --'2020-02-01' --
	
			AND REPLACE(uddft.Field_label, ' ', '_') IN (
																	'agent_fee', 
																	'ancillaries', 
																	'arr_ftr',
																	'basis',
																	'capacity',
																	'green',
																	'losses',
																	'manual_cost_adj',
																	'margin',
																	'nits_tec',
																	'risk',
																	'tax',
																	'wpa' 
			)
		) sub
		PIVOT  
		(  
		SUM(udf_value) FOR Field_label IN ([agent fee], 
									ancillaries, 
									[arr ftr],
									basis,
									capacity,
									green,
									losses,
									[manual cost adj],
									margin,
									[nits tec],
									risk,
									tax,
									wpa 
									)
			) AS udf  
			GROUP BY hub, zone, channel, product, YEAR(term_start),  MONTH(term_start)


			INSERT INTO udt_monthly_committed_volume (
				hub
				,zone
				,channel
				,product
				,term
				,offpeak_monthly_committed_mwh
				,onpeak_monthly_committed_mwh
				,loss_multiplier
				,agent_fee
				,ancillaries
				,arr_ftr
				,basis
				,capacity
				,energy
				,energy_lmp
				,green
				,index_multiplier
				,losses
				,manual_cost_adj
				,margin
				,nits_tec
				,risk
				,tax
				,wpa 
		)

		SELECT peak_off.hub, peak_off.zone, peak_off.channel, peak_off.Product, peak_off.term
			, peak_off.offpeak_monthly_committed_mwh
			, peak_off.onpeak_monthly_committed_mwh
			, loss.loss_multiplier
			, cost.agent_fee
			, cost.ancillaries
			, cost.arr_ftr
			, cost.basis
			, cost.capacity
			, cost.energy
			, cost.energy_lmp
			, cost.green
			, cost.index_multiplier
			, cost.losses
			, cost.manual_cost_adj
			, cost.margin
			, cost.nits_tec
			, cost.risk
			, cost.tax
			, cost.wpa

		FROM  #temp_peak_off_peak peak_off
		INNER JOIN #temp_loss_mul loss
			ON peak_off.hub = loss.hub
			AND peak_off.zone = loss.zone
			AND peak_off.channel = loss.channel
			AND peak_off.Product = loss.Product
			AND peak_off.term = loss.term
		INNER JOIN #temp_cost cost--for cost calc (UDF)	
			ON peak_off.hub = cost.hub
			AND peak_off.zone = cost.zone
			AND peak_off.channel = cost.channel
			AND peak_off.Product = cost.Product
			AND peak_off.term = cost.term
		LEFT JOIN udt_monthly_committed_volume umcv
			ON peak_off.hub = umcv.hub
			AND peak_off.zone = umcv.zone
			AND peak_off.channel = umcv.channel
			AND peak_off.Product = umcv.Product
			AND peak_off.term = umcv.term
		WHERE umcv.zone IS NULL	
		


		SELECT
				hub, zone, channel, product,   term_start ,
				AVG([agent fee]) agent_fee ,  
				AVG(ancillaries) ancillaries, 
				AVG([arr ftr]) arr_ftr,
				AVG(basis) basis,
				AVG(capacity) capacity,
				AVG(green) green,
				AVG(losses) losses,
				AVG([manual cost adj]) manual_cost_adj,
				AVG(margin) margin,
				AVG([nits tec]) nits_tec,
				AVG(risk) risk,
				AVG(tax) tax,
				AVG(wpa) wpa,
				AVG(energy) energy,
				AVG([index_multiplier]) [index_multiplier],
				AVG([energy_lmp]) [energy_lmp]
			INTO #temp_cost_polr
			FROM 
			(
				SELECT 
					pm.hub
					, pm.zone
					, pm.channel
					, pm.product
					, sdd.term_start
					, sdd.fixed_price energy
					, sdd.price_multiplier [index_multiplier]
					, sdd.formula_curve_id [energy_lmp]
					, uddft.Field_label 
					,IIF(CHARINDEX('e',udddf.udf_value)>0, CAST(CAST(udddf.udf_value AS FLOAT) AS NUMERIC(38,20)), CAST(udddf.udf_value AS NUMERIC(38,20)))  udf_value
				FROM #udt_customer_deals_header_info_polr_muni pm
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = pm.uid
				INNER JOIN source_deal_detail sdd
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN user_defined_deal_detail_fields udddf
					ON sdd.source_deal_detail_id = udddf.source_deal_detail_id
				INNER JOIN user_defined_deal_fields_template uddft
					ON uddft.template_id = sdh.template_id
					AND uddft.udf_type = 'd'
					AND uddft.udf_template_id = udddf.udf_template_id
					AND NULLIF(pm.uncommitted, 'No') IS NULL				
					AND REPLACE(uddft.Field_label, ' ', '_') IN (
																		'agent_fee', 
																		'ancillaries', 
																		'arr_ftr',
																		'basis',
																		'capacity',
																		'green',
																		'losses',
																		'manual_cost_adj',
																		'margin',
																		'nits_tec',
																		'risk',
																		'tax',
																		'wpa'
																	)		

			) sub
			PIVOT  
			(  
			SUM(udf_value) FOR Field_label IN ([agent fee], 
												ancillaries, 
												[arr ftr],
												basis,
												capacity,
												green,
												losses,
												[manual cost adj],
												margin,
												[nits tec],
												risk,
												tax,
												wpa 
												)
			) AS udf  
			WHERE udf.term_start >= @as_of_date_first -- '2020-02-01'-- 
			GROUP BY  hub, zone, channel, product, term_start 
		
		----FOR Polr
		
			INSERT INTO udt_monthly_committed_volume (
				hub
				,zone
				,channel
				,product
				,term
				,offpeak_monthly_committed_mwh
				,onpeak_monthly_committed_mwh
				,loss_multiplier
				,agent_fee
				,ancillaries
				,arr_ftr
				,basis
				,capacity
				,energy
				,energy_lmp
				,green
				,index_multiplier
				,losses
				,manual_cost_adj
				,margin
				,nits_tec
				,risk
				,tax
				,wpa 
		)
		SELECT pvt.hub, pvt.zone, pvt.channel, pvt.product, DATEFROMPARTS(YEAR(pvt.term_date),  MONTH(pvt.term_date), 1) term_date
			, SUM([01:00] * hbt_o.hr1 + [02:00] * hbt_o.hr2 + [03:00] * hbt_o.hr3 + [04:00] * hbt_o.hr4 + [05:00] * hbt_o.hr5 + [06:00] * hbt_o.hr6 + [07:00] * hbt_o.hr7 + [08:00] * hbt_o.hr8 +
				[09:00] * hbt_o.hr9 + [10:00] * hbt_o.hr10 + [11:00] * hbt_o.hr11 + [12:00] * hbt_o.hr12 + [13:00] * hbt_o.hr13 + [14:00] * hbt_o.hr14 + [15:00] * hbt_o.hr15 + [16:00] * hbt_o.hr16 +
				[17:00] * hbt_o.hr17 + [18:00] * hbt_o.hr18 + [19:00] * hbt_o.hr19 + [20:00] * hbt_o.hr20 + [21:00] * hbt_o.hr21 + [22:00] * hbt_o.hr22 + [23:00] * hbt_o.hr23 + [24:00] * hbt_o.hr24 
			) offpeak_monthly_committed_mwh

			, SUM([01:00] * hbt_p.hr1 + [02:00] * hbt_p.hr2 + [03:00] * hbt_p.hr3 + [04:00] * hbt_p.hr4 + [05:00] * hbt_p.hr5 + [06:00] * hbt_p.hr6 + [07:00] * hbt_p.hr7 + [08:00] * hbt_p.hr8 +
				[09:00] * hbt_p.hr9 + [10:00] * hbt_p.hr10 + [11:00] * hbt_p.hr11 + [12:00] * hbt_p.hr12 + [13:00] * hbt_p.hr13 + [14:00] * hbt_p.hr14 + [15:00] * hbt_p.hr15 + [16:00] * hbt_p.hr16 +
				[17:00] * hbt_p.hr17 + [18:00] * hbt_p.hr18 + [19:00] * hbt_p.hr19 + [20:00] * hbt_p.hr20 + [21:00] * hbt_p.hr21 + [22:00] * hbt_p.hr22 + [23:00] * hbt_p.hr23 + [24:00] * hbt_p.hr24 
			) onpeak_monthly_committed_mwh
			, AVG(pvt.multiplier) loss_multiplier
			,AVG(agent_fee) agent_fee
			,AVG(ancillaries) ancillaries
			,AVG(arr_ftr) arr_ftr
			,AVG(basis) basis
			,AVG(capacity) capacity
			,AVG(energy ) energy
			,AVG(energy_lmp) energy_lmp
			,AVG(green) green
			,AVG(index_multiplier) index_multiplier
			,AVG(losses) losses
			,AVG(manual_cost_adj) manual_cost_adj
			,AVG(margin) margin
			,AVG(nits_tec) nits_tec
			,AVG(risk) risk
			,AVG(tax) tax
			,AVG(wpa) wpa
		
		
		FROM 
		(
			SELECT pm.hub, pm.zone, pm.channel, pm.product, sddh.source_deal_detail_id, sddh.term_date, hr, volume, ISNULL(sdd.multiplier, 1) multiplier
			FROM #udt_customer_deals_header_info_polr_muni pm
			INNER JOIN source_deal_header sdh
				ON sdh.deal_id = pm.uid
			INNER JOIN source_deal_detail sdd
				ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh
				ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			WHERE NULLIF(uncommitted, 'No') IS NULL
			AND sdd.term_start >=  @as_of_date_first -- '2020-02-01' --
			
		) p
		PIVOT
		(
			MAX(volume)
			FOR hr IN ([01:00], [02:00], [03:00], [04:00], [05:00], [06:00], [07:00], [08:00]
					, [09:00], [10:00], [11:00], [12:00], [13:00], [14:00], [15:00], [16:00]
					, [17:00], [18:00], [19:00], [20:00], [21:00], [22:00], [23:00], [24:00]
			)
		) pvt
		INNER JOIN hour_block_term hbt_p
			ON hbt_p.term_date = pvt.term_date
			AND hbt_p.block_define_id IN(10000134)
			AND hbt_p.dst_group_value_id = 102200 
		INNER JOIN hour_block_term hbt_o
			ON hbt_o.term_date = pvt.term_date
			AND hbt_o.block_define_id IN( 10000135)
			AND hbt_o.dst_group_value_id = 102200 

		INNER JOIN #temp_cost_polr cost --for costs(UDFs)
			ON cost.zone = pvt.zone
			AND cost.channel = pvt.channel
			AND cost.product =  pvt.product
			AND YEAR(cost.term_start) = YEAR(pvt.term_date)
			AND MONTH(cost.term_start) = MONTH(pvt.term_date)

		GROUP BY pvt.hub,pvt.zone, pvt.channel, pvt.Product, YEAR(pvt.term_date), MONTH(pvt.term_date)

	END

	IF @committed_uncommitted IN ('u', 'b')
	BEGIN
		SET @sql = N'DELETE udh
					FROM udt_monthly_uncommitted_volume udh
					'
					+ CASE WHEN @zone IS NULL THEN '' 
							ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@zone) z
										ON z.item = udh.zone 
								'
						END
					+ CASE WHEN @channel IS NULL THEN '' 
							ELSE' INNER JOIN dbo.SplitCommaSeperatedValues(@channel) c
										ON c.item = udh.channel 
								'
						END
		
					+ ' WHERE term >= @as_of_date_first' 
		SET @parm_definition = N' @zone VARCHAR(MAX), @channel VARCHAR(MAX), @product VARCHAR(MAX), @as_of_date_first DATETIME';  

		EXECUTE sp_executesql @sql, @parm_definition,  @zone = @zone, @channel = @channel, @product = @product, @as_of_date_first = @as_of_date_first 

		--to do add logic for polr uncommitted
		INSERT INTO udt_monthly_uncommitted_volume (
			 zone
			, channel
			, product
			, term
			, offpeak_monthly_uncommitted_mwh
			, onpeak_monthly_uncommitted_mwh	
		)
		OUTPUT INSERTED.zone, INSERTED.channel, INSERTED.product, INSERTED.term, INSERTED.offpeak_monthly_uncommitted_mwh, INSERTED.onpeak_monthly_uncommitted_mwh 
		INTO #udt_monthly_uncommitted_volume( zone, channel, product, term, offpeak_monthly_uncommitted_mwh, onpeak_monthly_uncommitted_mwh)
		SELECT 
	 			utv.zone,
				utv.channel,
				@hardcoded_product product, 
				utv.term,
				IIF((ISNULL(utv.offpeak_monthly_target_mwh, 0) - ISNULL(ucv.offpeak_monthly_committed_mwh, 0)) <= 0 , 0, (ISNULL(utv.offpeak_monthly_target_mwh, 0) - ISNULL(ucv.offpeak_monthly_committed_mwh, 0))) offpeak_monthly_uncommitted_mwh,
				IIF((ISNULL(utv.onpeak_monthly_target_mwh, 0) - ISNULL(ucv.onpeak_monthly_committed_mwh, 0)) <= 0, 0, (ISNULL(utv.onpeak_monthly_target_mwh, 0) - ISNULL(ucv.onpeak_monthly_committed_mwh, 0))) onpeak_monthly_uncommitted_mwh
		FROM udt_monthly_target_volume utv 
		INNER JOIN 
		(	
			SELECT 
				ucv.zone
				, ucv.channel
				, SUM(ucv.offpeak_monthly_committed_mwh) offpeak_monthly_committed_mwh
				, SUM(ucv.onpeak_monthly_committed_mwh) onpeak_monthly_committed_mwh
				, term
			FROM udt_monthly_committed_volume ucv 
			INNER JOIN (
				SELECT DISTINCT zone, channel FROM #udt_customer_deals_header_info
				UNION 
				SELECT DISTINCT zone, channel FROM #udt_customer_deals_header_info_polr_muni	
				UNION  
				SELECT DISTINCT zone, channel FROM #udt_customer_deals_header_info_uncommitted
			) sub
				ON ucv.zone = sub.zone
				AND ucv.channel = sub.channel		
			WHERE ucv.term >= @as_of_date_first --'2020-02-01' --
			GROUP BY ucv.zone, ucv.channel, ucv.term
		) ucv	
			ON  ucv.zone = utv.zone
			AND ucv.channel = utv.channel
			AND ucv.term = utv.term
	END 
	--SELECT ddh.*	
	--	INTO #temp_deal_detail_hour_uncommitted
	--FROM #udt_customer_deals_header_info udh
	--INNER JOIN forecast_profile fp
	--	ON ( zone + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) = fp.profile_name
	--INNER JOIN deal_detail_hour ddh
	--	ON ddh.profile_id = fp.profile_id
	--WHERE udh.status <> 'Terminate'
	--UNION ALL
	--SELECT ddh.*	
	--FROM #udt_customer_deals_header_info_polr_muni udh
	--INNER JOIN forecast_profile fp
	--	ON ( zone + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_')) + '_UC' = fp.profile_name
	--INNER JOIN deal_detail_hour ddh
	--	ON ddh.profile_id = fp.profile_id
	--WHERE udh.status <> 'Terminate'


	UPDATE ddh
		SET hr1 = sub.hr1 
			,hr2 = sub.hr2 
			,hr3 = sub.hr3 
			,hr4 = sub.hr4 
			,hr5 = sub.hr5 
			,hr6 = sub.hr6 
			,hr7 = sub.hr7 
			,hr8 = sub.hr8 
			,hr9 = sub.hr9 
			,hr10= sub.hr10
			,hr11= sub.hr11
			,hr12= sub.hr12
			,hr13= sub.hr13
			,hr14= sub.hr14
			,hr15= sub.hr15
			,hr16= sub.hr16
			,hr17= sub.hr17
			,hr18= sub.hr18
			,hr19= sub.hr19
			,hr20= sub.hr20
			,hr21= sub.hr21
			,hr22= sub.hr22
			,hr23= sub.hr23
			,hr24= sub.hr24
	FROM deal_detail_hour ddh
	INNER JOIN  (	
		SELECT hbt.term_date, op.profile_id
			,SUM(hbt.hr1 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr1 
			,SUM(hbt.hr2 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr2 
			,SUM(hbt.hr3 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr3 
			,SUM(hbt.hr4 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr4 
			,SUM(hbt.hr5 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr5 
			,SUM(hbt.hr6 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr6 
			,SUM(hbt.hr7 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr7 
			,SUM(hbt.hr8 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr8 
			,SUM(hbt.hr9 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr9 
			,SUM(hbt.hr10 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr10
			,SUM(hbt.hr11 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr11
			,SUM(hbt.hr12 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr12
			,SUM(hbt.hr13 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr13
			,SUM(hbt.hr14 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr14
			,SUM(hbt.hr15 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr15
			,SUM(hbt.hr16 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr16
			,SUM(hbt.hr17 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr17
			,SUM(hbt.hr18 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr18
			,SUM(hbt.hr19 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr19
			,SUM(hbt.hr20 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr20
			,SUM(hbt.hr21 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr21
			,SUM(hbt.hr22 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr22
			,SUM(hbt.hr23 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr23
			,SUM(hbt.hr24 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr24
		FROM (
			SELECT fp.profile_id
				, uuv.term term_start, EOMONTH(uuv.term) term_end
				, IIF(p.volume_mult = 0, 0, uuv.onpeak_monthly_uncommitted_mwh/p.volume_mult) peak_vol
				, IIF(o.volume_mult = 0, 0, uuv.offpeak_monthly_uncommitted_mwh/o.volume_mult) offpeak_vol
		
			FROM #udt_monthly_uncommitted_volume uuv 
			INNER JOIN forecast_profile fp 
				ON fp.profile_name = zone + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') + '_UC'
			OUTER APPLY
			(	SELECT SUM(volume_mult) volume_mult
				FROM hour_block_term hbt_p
				WHERE hbt_p.term_date between uuv.term and EOMONTH(uuv.term)
				AND hbt_p.block_define_id IN(10000134)
				AND hbt_p.dst_group_value_id = 102200 
				GROUP by YEAR(hbt_p.term_date), MONTH(hbt_p.term_date)
			) p
			OUTER APPLY
			(	SELECT SUM(volume_mult) volume_mult
				FROM hour_block_term hbt_o
				WHERE hbt_o.term_date BETWEEN uuv.term AND EOMONTH(uuv.term)
				AND hbt_o.block_define_id IN(10000135)
				AND hbt_o.dst_group_value_id = 102200 
				GROUP by YEAR(hbt_o.term_date), MONTH(hbt_o.term_date)
			) o
		) op
		INNER JOIN hour_block_term hbt
			ON hbt.term_start BETWEEN op.term_start AND op.term_end
	
		WHERE hbt.block_define_id IN(10000134, 10000135)
			AND hbt.dst_group_value_id = 102200	
		GROUP BY op.profile_id, hbt.term_date
	) sub
		ON ddh.term_date = sub.term_date
		AND ddh.profile_id = sub.profile_id

	
	INSERT INTO deal_detail_hour(
		term_date
		, profile_id
		, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8 
		, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16
		, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
				
	)
	SELECT hbt.term_date, op.profile_id
		,SUM(hbt.hr1 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr1 
		,SUM(hbt.hr2 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr2 
		,SUM(hbt.hr3 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr3 
		,SUM(hbt.hr4 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr4 
		,SUM(hbt.hr5 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr5 
		,SUM(hbt.hr6 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr6 
		,SUM(hbt.hr7 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr7 
		,SUM(hbt.hr8 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr8 
		,SUM(hbt.hr9 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol))  hr9 
		,SUM(hbt.hr10 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr10
		,SUM(hbt.hr11 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr11
		,SUM(hbt.hr12 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr12
		,SUM(hbt.hr13 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr13
		,SUM(hbt.hr14 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr14
		,SUM(hbt.hr15 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr15
		,SUM(hbt.hr16 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr16
		,SUM(hbt.hr17 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr17
		,SUM(hbt.hr18 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr18
		,SUM(hbt.hr19 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr19
		,SUM(hbt.hr20 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr20
		,SUM(hbt.hr21 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr21
		,SUM(hbt.hr22 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr22
		,SUM(hbt.hr23 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr23
		,SUM(hbt.hr24 * IIF(hbt.block_define_id = 10000134, op.peak_vol, op.offpeak_vol)) hr24
	FROM (
		SELECT fp.profile_id
			, uuv.term term_start, EOMONTH(uuv.term) term_end
			, IIF(p.volume_mult = 0, 0, uuv.onpeak_monthly_uncommitted_mwh/p.volume_mult) peak_vol
			, IIF(o.volume_mult = 0, 0, uuv.offpeak_monthly_uncommitted_mwh/o.volume_mult) offpeak_vol
	FROM #udt_monthly_uncommitted_volume uuv
		INNER JOIN forecast_profile fp
			ON fp.profile_name = zone + '_' + REPLACE(channel, ' ', '_') + '_' + REPLACE(product, ' ', '_') + '_UC'
		OUTER APPLY
		(	SELECT SUM(volume_mult) volume_mult
			FROM hour_block_term hbt_p
			WHERE hbt_p.term_date between uuv.term and EOMONTH(uuv.term)
			AND hbt_p.block_define_id IN(10000134)
			AND hbt_p.dst_group_value_id = 102200 
			GROUP by YEAR(hbt_p.term_date), MONTH(hbt_p.term_date)
		) p
		OUTER APPLY
		(	SELECT SUM(volume_mult) volume_mult
			FROM hour_block_term hbt_o
			WHERE hbt_o.term_date BETWEEN uuv.term AND EOMONTH(uuv.term)
			AND hbt_o.block_define_id IN(10000135)
			AND hbt_o.dst_group_value_id = 102200 
			GROUP by YEAR(hbt_o.term_date), MONTH(hbt_o.term_date)
		) o
	) op
	INNER JOIN hour_block_term hbt
		ON hbt.term_start BETWEEN op.term_start AND op.term_end
	LEFT JOIN deal_detail_hour ddh --select * from deal_detail_hour where profile_id = 254
		ON ddh.term_date = hbt.term_start
		AND ddh.profile_id = op.profile_id
	WHERE hbt.block_define_id IN(10000134, 10000135)
		AND hbt.dst_group_value_id = 102200
		AND ddh.profile_id IS NULL		
		--and  hbt.term_date = '2020-01-01'
	GROUP BY op.profile_id,hbt.term_date

	SET @sql = N'DELETE udh
				FROM udt_customer_deals_detail udh
				'
				+ CASE WHEN @zone IS NULL THEN '' 
						ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@zone) z
									ON z.item = udh.zone 
							'
					END
				+ CASE WHEN @channel IS NULL THEN '' 
						ELSE' INNER JOIN dbo.SplitCommaSeperatedValues(@channel) c
									ON c.item = udh.channel 
							'
					END
				+ CASE WHEN @product IS NULL THEN '' 
						ELSE ' INNER JOIN dbo.SplitCommaSeperatedValues(@product) p
									ON p.item = udh.product 
							'
					END
	SET @parm_definition = N' @zone VARCHAR(MAX), @channel VARCHAR(MAX), @product VARCHAR(MAX)';  

	EXECUTE sp_executesql @sql, @parm_definition,  @zone = @zone, @channel = @channel, @product = @product

	--insert data in udt_customer_deals_detail for reporting purpose
	IF OBJECT_ID('tempdb..#tmp_udf_header_info') IS NOT NULL
		DROP TABLE #tmp_udf_header_info

	SELECT 
		DATEFROMPARTS(YEAR(uhv.term_date), MONTH(uhv.term_date), 1) term
		, udh.profile_code
		, udh.uid uid
		, MAX(ugdh.source_deal_header_id) source_deal_header_id
		, MAX(udh.agent_fee) agent_fee							
		, MAX(udh.ancillaries) ancillaries
		, MAX(udh.arr_ftr) arr_ftr
		, MAX(udh.basis)  basis
		, MAX(udh.capacity) capacity						
		, MAX(udh.channel) channel							
		, MAX(udh.customer_count) customer_count			
		, MAX(udh.cust_name) cust_name						
		, MAX(udh.deal_date) deal_date						
		, MAX(udh.energy) energy							
		, MAX(udh.energy_lmp) energy_lmp					
		, MAX(udh.entire_term_end) entire_term_end
		, MAX(udh.entire_term_start) entire_term_start
		, MAX(udh.green) green
		, MAX(udh.hub) hub
		, MAX(udh.index_multiplier)	index_multiplier
		, MAX(udh.loss_multiplier) loss_multiplier
		, MAX(udh.losses) losses
		, MAX(udh.manual_cost_adj) manual_cost_adj
		, MAX(udh.margin) margin
		, MAX(udh.nits_tec) nits_tec
		, MAX(udh.priority_code) priority_code
		, MAX(udh.Product) Product
		, MAX(udh.risk) risk
		, MAX(udh.sales_rate) sales_rate
		, MAX(udh.status) status
		, MAX(udh.tax) tax
		, MAX(udh.volume_multiplier)volume_multiplier
		, MAX(udh.wpa) wpa
		, MAX(udh.zone) zone
		, MAX(udh.capacitymw) capacitymw
		, MAX(udh.transmissionmw) transmissionmw
		,SUM(uhv.Hr1 * IIF(hbt.block_define_id = 10000135, hbt.Hr1, 0)
				+uhv.Hr2 * IIF(hbt.block_define_id = 10000135, hbt.Hr2, 0)
				+uhv.Hr3 * IIF(hbt.block_define_id = 10000135, hbt.Hr3, 0)
				+uhv.Hr4 * IIF(hbt.block_define_id = 10000135, hbt.Hr4, 0) 
				+uhv.Hr5 * IIF(hbt.block_define_id = 10000135, hbt.Hr5, 0) 
				+uhv.Hr6 * IIF(hbt.block_define_id = 10000135, hbt.Hr6, 0)
				+uhv.Hr7 * IIF(hbt.block_define_id = 10000135, hbt.Hr7, 0)
				+uhv.Hr8 * IIF(hbt.block_define_id = 10000135, hbt.Hr8, 0)  
				+uhv.Hr9 * IIF(hbt.block_define_id = 10000135, hbt.Hr9, 0)
				+uhv.Hr10 * IIF(hbt.block_define_id = 10000135, hbt.Hr10, 0)
				+uhv.Hr11 * IIF(hbt.block_define_id = 10000135, hbt.Hr11, 0)
				+uhv.Hr12 * IIF(hbt.block_define_id = 10000135, hbt.Hr12, 0)
				+uhv.Hr13 * IIF(hbt.block_define_id = 10000135, hbt.Hr13, 0)
				+uhv.Hr14 * IIF(hbt.block_define_id = 10000135, hbt.Hr14, 0) 
				+uhv.Hr15 * IIF(hbt.block_define_id = 10000135, hbt.Hr15, 0)
				+uhv.Hr16 * IIF(hbt.block_define_id = 10000135, hbt.Hr16, 0)
				+uhv.Hr17 * IIF(hbt.block_define_id = 10000135, hbt.Hr17, 0)
				+uhv.Hr18 * IIF(hbt.block_define_id = 10000135, hbt.Hr18, 0)
				+uhv.Hr19 * IIF(hbt.block_define_id = 10000135, hbt.Hr19, 0)
				+uhv.Hr20 * IIF(hbt.block_define_id = 10000135, hbt.Hr10, 0)
				+uhv.Hr21 * IIF(hbt.block_define_id = 10000135, hbt.Hr21, 0) 
				+uhv.Hr22 * IIF(hbt.block_define_id = 10000135, hbt.Hr22, 0)
				+uhv.Hr23 * IIF(hbt.block_define_id = 10000135, hbt.Hr23, 0)
				+uhv.Hr24 * IIF(hbt.block_define_id = 10000135, hbt.Hr24, 0) 
				+ IIF(mdst.insert_delete = 'i' AND uhv.hr25 IS NOT NULL, uhv.hr25, 0) * IIF(hbt.block_define_id = 10000135, hbt.Hr2, 0)
		) offpeak_vol
		,SUM(uhv.Hr1 * IIF(hbt.block_define_id = 10000134, hbt.Hr1, 0)
				+uhv.Hr2 * IIF(hbt.block_define_id = 10000134, hbt.Hr2, 0)
				+uhv.Hr3 * IIF(hbt.block_define_id = 10000134, hbt.Hr3, 0)
				+uhv.Hr4 * IIF(hbt.block_define_id = 10000134, hbt.Hr4, 0) 
				+uhv.Hr5 * IIF(hbt.block_define_id = 10000134, hbt.Hr5, 0) 
				+uhv.Hr6 * IIF(hbt.block_define_id = 10000134, hbt.Hr6, 0)
				+uhv.Hr7 * IIF(hbt.block_define_id = 10000134, hbt.Hr7, 0)
				+uhv.Hr8 * IIF(hbt.block_define_id = 10000134, hbt.Hr8, 0)  
				+uhv.Hr9 * IIF(hbt.block_define_id = 10000134, hbt.Hr9, 0)
				+uhv.Hr10 * IIF(hbt.block_define_id = 10000134, hbt.Hr10, 0)
				+uhv.Hr11 * IIF(hbt.block_define_id = 10000134, hbt.Hr11, 0)
				+uhv.Hr12 * IIF(hbt.block_define_id = 10000134, hbt.Hr12, 0)
				+uhv.Hr13 * IIF(hbt.block_define_id = 10000134, hbt.Hr13, 0)
				+uhv.Hr14 * IIF(hbt.block_define_id = 10000134, hbt.Hr14, 0) 
				+uhv.Hr15 * IIF(hbt.block_define_id = 10000134, hbt.Hr15, 0)
				+uhv.Hr16 * IIF(hbt.block_define_id = 10000134, hbt.Hr16, 0)
				+uhv.Hr17 * IIF(hbt.block_define_id = 10000134, hbt.Hr17, 0)
				+uhv.Hr18 * IIF(hbt.block_define_id = 10000134, hbt.Hr18, 0)
				+uhv.Hr19 * IIF(hbt.block_define_id = 10000134, hbt.Hr19, 0)
				+uhv.Hr20 * IIF(hbt.block_define_id = 10000134, hbt.Hr10, 0)
				+uhv.Hr21 * IIF(hbt.block_define_id = 10000134, hbt.Hr21, 0) 
				+uhv.Hr22 * IIF(hbt.block_define_id = 10000134, hbt.Hr22, 0)
				+uhv.Hr23 * IIF(hbt.block_define_id = 10000134, hbt.Hr23, 0)
				+uhv.Hr24 * IIF(hbt.block_define_id = 10000134, hbt.Hr24, 0) 
				+ IIF(mdst.insert_delete = 'i'  AND uhv.hr25 IS NOT NULL, uhv.hr25,0) * IIF(hbt.block_define_id = 10000134, hbt.Hr2, 0)
		) onpeak_vol
	INTO  #tmp_udf_header_info	
	--select top 10  * --ucdd.zone, ucdd.channel, ucdd.product,*  
	FROM #udt_customer_deals_header_info udh
	INNER JOIN [udt_customer_hourly_volume_info] uhv
		ON ISNULL(udh.profile_code, udh.uid) = uhv.uid
		--AND uhv.term_date BETWEEN  [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start, 'f') AND EOMONTH(udh.entire_term_end)
		AND uhv.term_date BETWEEN udh.entire_term_start AND udh.entire_term_end 
		AND NULLIF(udh.uncommitted, 'No') IS NULL
		--AND udh.cust_name = 'city of toledo'
	INNER JOIN hour_block_term hbt
		ON hbt.term_date = uhv.term_date
		AND block_define_id IN(10000134,10000135) --peak 						
		AND dst_group_value_id = 102200
	INNER JOIN udt_aggregated_deal_header ugdh
		ON ugdh.hub = udh.hub
		AND ugdh.zone = udh.zone
		AND ugdh.channel = udh.channel
		AND ugdh.product = udh.product
		AND NULLIF(ugdh.uncommitted, 'No') IS NULL
	LEFT JOIN udt_customer_deals_detail ucdd
		ON ucdd.zone = udh.zone
		AND ucdd.channel = udh.channel
		AND ucdd.product = udh.product		
	LEFT JOIN mv90_DST mdst 
		ON mdst.date = uhv.term_date  
		AND mdst.dst_group_value_id = 102200 --DST Group
		--AND ucdd.term_start = DATEFROMPARTS(YEAR(uhv.term_date), MONTH(uhv.term_date), 1)
	WHERE ucdd.uid IS NULL 
	GROUP BY  udh.profile_code,  udh.uid, YEAR(uhv.term_date), MONTH(uhv.term_date)


	INSERT INTO udt_customer_deals_detail (
		term_start
		,profile_code
		,uid
		,source_deal_header_id
		,agent_fee
		,ancillaries
		,arr_ftr
		,basis
		,capacity
		,channel
		,customer_count
		,cust_name
		,deal_date
		,energy
		,energy_lmp
		,entire_term_end
		,entire_term_start
		,green
		,hub
		,index_multiplier
		,loss_multiplier
		,losses
		,manual_cost_adj
		,margin
		,nits_tec
		,priority_code
		,Product
		,risk
		,sales_rate
		,status
		,tax	
		,volume_multiplier
		,wpa
		,zone
		,capacityMW
		,transmissionMW
		,offpeak
		,onpeak		
	)
	SELECT * FROM #tmp_udf_header_info 

	SET @alert_process_table = 'adiha_process.dbo.alert_forecast_aggregation_' + @job_process_id + '_fa'
	
	EXEC ('CREATE TABLE ' + @alert_process_table + '(			
			hub VARCHAR(200) NULL,
			zone  VARCHAR(200) NULL,
			channel VARCHAR(200) NULL,
			product VARCHAR(200) NULL,
			as_of_date DATETIME  NULL,
			source_deal_header_id INT
		)')

	SET @sql = '
	
	DECLARE @source_deal_header_id INT 
	SELECT TOP 1 @source_deal_header_id = source_deal_header_id FROM source_deal_header

	INSERT INTO ' + @alert_process_table + ' ( 
					hub 
					, zone
					, channel
					, product
					, source_deal_header_id
				)
				SELECT  @hub
						, @zone
						, @channel
						, @product
						, @source_deal_header_id
				'
	SET @parm_definition = N'@hub VARCHAR(MAX), @zone VARCHAR(MAX), @channel VARCHAR(MAX), @product VARCHAR(MAX)';  
  
	EXECUTE sp_executesql @sql, @parm_definition, @hub = @hub, @zone = @zone, @channel = @channel, @product = @product

	--Mapping zone with curve alone with max as_of_date
	SELECT zone, spc.source_curve_def_id, MAX(spc.as_of_date) as_of_date 
		INTO #temp_zone_curve_map
	FROM (
		SELECT zone, type FROM #temp_customer_deals_header_info_ct
		UNION ALL
		SELECT zone, type FROM #temp_customer_deals_header_info_polr_muni WHERE type = 'capacity'
	) tcdh
	INNER JOIN  source_price_curve_def spcd
		ON spcd.curve_id = tcdh.zone + ' Capacity Scalar' -- 'aep Capacity Scalar' --
	INNER JOIN source_price_curve spc
		ON spcd.source_curve_def_id = spc.source_curve_def_id 
	WHERE type = 'capacity'
	GROUP BY zone, spc.source_curve_def_id

	--calculate deal_volume for capacity deal 
	UPDATE sdd
		SET deal_volume = sub.deal_volume
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM source_deal_detail sdd
	INNER JOIN ( --for committed
				SELECT sdd.source_deal_detail_id, 
					SUM(udh.capacityMW * ISNULL(customer_count, 1) *  ISNULL(spc.curve_value, 1)) deal_volume
				FROM source_deal_header sdh
				INNER JOIN #temp_customer_deals_header_info_ct tcdh
					ON (tcdh.id = sdh.deal_id
						OR tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
						)
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN #udt_customer_deals_header_info udh   
					ON udh.hub = tcdh.hub
					AND udh.zone = tcdh.zone
					AND udh.channel = tcdh.channel
					AND udh.product = tcdh.product
					AND NULLIF(udh.uncommitted, 'No') IS NULL
				LEFT JOIN #temp_zone_curve_map zm
					ON zm.zone = tcdh.zone
				LEFT JOIN source_price_curve spc
					ON spc.source_curve_def_id = zm.source_curve_def_id
					AND spc.as_of_date =  zm.as_of_date
					AND spc.maturity_date = [dbo].[FNAGetFirstLastDayOfMonth](sdd.term_start, 'f') --[dbo].[FNAGetFirstLastDayOfMonth](DATEADD (MONTH , n-1 , a.term_start ), 'f')
				WHERE tcdh.type= 'capacity'
					AND sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start , 'f') 
					AND DATEDIFF(MONTH, sdd.term_end, udh.entire_term_end) >=0
				GROUP BY source_deal_detail_id
				UNION ALL --for uncommitted
				SELECT sdd.source_deal_detail_id,
					SUM(IIF(uclf.lfc =0, 0,	(((offpeak_monthly_committed_mwh + onpeak_monthly_committed_mwh)*  ISNULL(spc.curve_value, 1)) / ISNULL(uclf.lfc, 1))/ (DAY(EOMONTH(sdd.term_start)) *24))) deal_volume
				FROM source_deal_header sdh
				INNER JOIN #temp_customer_deals_header_info_ct tcdh
					ON (tcdh.id = sdh.deal_id
						OR tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
						)
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN udt_monthly_committed_volume udh   
					ON udh.zone = tcdh.zone
					AND udh.channel = tcdh.channel					
				LEFT JOIN #temp_zone_curve_map zm
					ON zm.zone = tcdh.zone
				LEFT JOIN source_price_curve spc
					ON spc.source_curve_def_id = zm.source_curve_def_id
					AND spc.as_of_date =  zm.as_of_date
					AND spc.maturity_date = [dbo].[FNAGetFirstLastDayOfMonth](sdd.term_start, 'f') --[dbo].[FNAGetFirstLastDayOfMonth](DATEADD (MONTH , n-1 , a.term_start ), 'f')
				LEFT JOIN udt_capacity_load_factor uclf
					ON uclf.zone = udh.zone
					AND uclf.channel = udh.channel
					AND uclf.term = sdd.term_start
				WHERE tcdh.type= 'capacity_uncommitted'
					AND sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.term , 'f') 
					AND DATEDIFF(MONTH, sdd.term_end, udh.term) >=0
				GROUP BY source_deal_detail_id
	) sub
		ON sdd.source_deal_detail_id = sub.source_deal_detail_id
		
	--calculate deal_volume for capacity deal polr 
	UPDATE sdd
		SET deal_volume = sub.deal_volume
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM source_deal_detail sdd
	INNER JOIN ( --for committed
				SELECT sdd.source_deal_detail_id,
					SUM(udh.capacityMW * ISNULL(customer_count, 1) *  ISNULL(spc.curve_value, 1)) deal_volume				
				--select sdh.deal_id--, sdd.source_deal_detail_id,1
				FROM source_deal_header sdh
				INNER JOIN #temp_customer_deals_header_info_polr_muni tcdh  
					ON  tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
					AND	tcdh.type= 'capacity'
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN  #udt_customer_deals_header_info_polr_muni udh    
					ON udh.hub = tcdh.hub
					AND udh.zone = tcdh.zone
					AND udh.channel = tcdh.channel
					AND udh.product = tcdh.product
					AND NULLIF(udh.uncommitted, 'No')  IS NULL
				LEFT JOIN #temp_zone_curve_map zm
					ON zm.zone = tcdh.zone
				LEFT JOIN source_price_curve spc
					ON spc.source_curve_def_id = zm.source_curve_def_id
					AND spc.as_of_date =  zm.as_of_date
					AND spc.maturity_date = [dbo].[FNAGetFirstLastDayOfMonth](sdd.term_start, 'f') --[dbo].[FNAGetFirstLastDayOfMonth](DATEADD (MONTH , n-1 , a.term_start ), 'f')
				WHERE sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start , 'f') 
					AND DATEDIFF(MONTH, sdd.term_end, udh.entire_term_end) >=0
					--AND NULLIF(udh.uncommitted, 'No') IS NULL
				GROUP BY source_deal_detail_id
				UNION ALL --for uncommitted
				SELECT sdd.source_deal_detail_id,
					SUM(IIF(uclf.lfc = 0, 0, (((offpeak_monthly_committed_mwh + onpeak_monthly_committed_mwh) *  ISNULL(spc.curve_value, 1)) / ISNULL(uclf.lfc, 1) )/ (DAY(EOMONTH(sdd.term_start)) *24))) deal_volume
				FROM source_deal_header sdh
				INNER JOIN #temp_customer_deals_header_info_polr_muni_uncommitted tcdh -- select * from #temp_customer_deals_header_info_polr_muni_uncommitted
					ON tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
					AND tcdh.type = 'capacity_uncommitted'
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN udt_monthly_committed_volume udh   
					ON 
					--udh.hub = tcdh.hub
					--AND 
					udh.zone = tcdh.zone
					AND udh.channel = tcdh.channel
					--AND udh.product = tcdh.product
					--AND udh.uncommitted = 'Yes'
				
				LEFT JOIN #temp_zone_curve_map zm -- select * from #temp_zone_curve_map
					ON zm.zone = tcdh.zone
				LEFT JOIN source_price_curve spc
					ON spc.source_curve_def_id = zm.source_curve_def_id
					AND spc.as_of_date =  zm.as_of_date
					AND spc.maturity_date = [dbo].[FNAGetFirstLastDayOfMonth](sdd.term_start, 'f') --[dbo].[FNAGetFirstLastDayOfMonth](DATEADD (MONTH , n-1 , a.term_start ), 'f')
				LEFT JOIN udt_capacity_load_factor uclf
					ON uclf.zone = udh.zone
					AND uclf.channel = udh.channel
					AND uclf.term = sdd.term_start
				WHERE  sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.term , 'f') 
					AND DATEDIFF(MONTH, sdd.term_end, udh.term) >=0
				GROUP BY source_deal_detail_id


	) sub
		ON sdd.source_deal_detail_id = sub.source_deal_detail_id

	--calculate deal_volume for transmission deal
	UPDATE sdd
		SET deal_volume = sub.deal_volume
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM source_deal_detail sdd
	INNER JOIN (
			SELECT  source_deal_detail_id,
				SUM(udh.transmissionMW * ISNULL(customer_count, 1)) deal_volume --, sdd.deal_volume, sdd.* 
			 FROM source_deal_header sdh
			INNER JOIN #temp_customer_deals_header_info_ct tcdh 
				ON (tcdh.id = sdh.deal_id
					OR tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
				)
			INNER JOIN source_deal_detail sdd
				ON sdd.source_deal_header_id = sdh.source_deal_header_id 
			INNER JOIN #udt_customer_deals_header_info udh   
				ON udh.hub = tcdh.hub
				AND udh.zone = tcdh.zone
				AND udh.channel = tcdh.channel
				AND udh.product = tcdh.product
				AND NULLIF(udh.uncommitted, 'No')  IS NULL
			WHERE tcdh.type= 'Transmission'
				AND sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start , 'f') 
				AND DATEDIFF(MONTH, sdd.term_end, udh.entire_term_end) >=0
			GROUP BY source_deal_detail_id
			UNION ALL --for uncommitted
			SELECT  source_deal_detail_id,
				SUM(IIF(uclf.lft = 0, 0, (((offpeak_monthly_committed_mwh + onpeak_monthly_committed_mwh  ))/ ISNULL(uclf.lft, 1))/ (DAY(EOMONTH(sdd.term_start)) *24))) deal_volume --, sdd.deal_volume, sdd.* 
			FROM source_deal_header sdh
			INNER JOIN #temp_customer_deals_header_info_ct tcdh 
				ON (tcdh.id = sdh.deal_id
						OR tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
					)
			INNER JOIN source_deal_detail sdd
				ON sdd.source_deal_header_id = sdh.source_deal_header_id 
			LEFT JOIN udt_monthly_committed_volume udh   
				ON  udh.zone = tcdh.zone
				AND udh.channel = tcdh.channel
			LEFT JOIN udt_transmission_load_factor uclf
				ON uclf.zone = udh.zone
				AND uclf.channel = udh.channel
				AND uclf.term = sdd.term_start
			WHERE tcdh.type= 'Transmission_uncommitted'
				AND sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.term , 'f') 
				AND DATEDIFF(MONTH, sdd.term_end, udh.term) >=0
			GROUP BY source_deal_detail_id
	) sub
		ON sdd.source_deal_detail_id = sub.source_deal_detail_id

	--calculate deal_volume for transmission deal polr
	UPDATE sdd
		SET deal_volume = sub.deal_volume
	OUTPUT deleted.source_deal_header_id INTO #temp_updated_deal_ids
	FROM source_deal_detail sdd
	INNER JOIN (
			SELECT  source_deal_detail_id,
				SUM(udh.transmissionMW * ISNULL(customer_count, 1)) deal_volume --, sdd.deal_volume, sdd.* 
			 FROM source_deal_header sdh
			INNER JOIN  #temp_customer_deals_header_info_polr_muni  tcdh 
				ON  tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
				AND tcdh.type = 'transmission'		
			INNER JOIN source_deal_detail sdd
				ON sdd.source_deal_header_id = sdh.source_deal_header_id 
			INNER JOIN  #udt_customer_deals_header_info_polr_muni udh 
				ON uid + '_Transmission' = sdh.deal_id
			WHERE sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.entire_term_start , 'f') 
				AND DATEDIFF(MONTH, sdd.term_end, udh.entire_term_end) >=0
			GROUP BY source_deal_detail_id
			UNION ALL -- for Uncommitted
			SELECT  source_deal_detail_id, 
				SUM(IIF(uclf.lft = 0, 0, ((offpeak_monthly_committed_mwh + onpeak_monthly_committed_mwh  )/ ISNULL(uclf.lft, 1)) / (DAY(EOMONTH(sdd.term_start)) *24))) deal_volume --, sdd.deal_volume, sdd.* 
			FROM source_deal_header sdh
			INNER JOIN #temp_customer_deals_header_info_polr_muni_uncommitted tcdh 
				ON tcdh.deal_id + '_' + tcdh.type = sdh.deal_id
				AND tcdh.type = 'transmission_uncommitted'
			INNER JOIN source_deal_detail sdd
				ON sdd.source_deal_header_id = sdh.source_deal_header_id 
			INNER JOIN  udt_monthly_committed_volume udh   
				ON  udh.zone = tcdh.zone
				AND udh.channel = tcdh.channel
				--AND udh.product = tcdh.product
				--AND udh.uncommitted = 'Yes'
			LEFT JOIN udt_transmission_load_factor uclf
				ON uclf.zone = udh.zone
				AND uclf.channel = udh.channel
				AND uclf.term = sdd.term_start
			WHERE tcdh.type= 'Transmission_uncommitted'
				AND sdd.term_start >= [dbo].[FNAGetFirstLastDayOfMonth](udh.term , 'f') 
				AND DATEDIFF(MONTH, sdd.term_end, udh.term) >=0
			GROUP BY source_deal_detail_id 
	) sub
		ON sdd.source_deal_detail_id = sub.source_deal_detail_id	

	SELECT source_deal_header_id 
	INTO #temp_inserted_deal 
	FROM #temp_inserted_deal_header
	UNION 
	SELECT source_deal_header_id 
	FROM #temp_inserted_deal_header_polr_muni	

	SELECT source_deal_header_id 
	INTO #temp_updated_deal
	FROM #temp_updated_deal_header
	UNION	
	SELECT DISTINCT source_deal_header_id 
	FROM #temp_update_deal_header_polr_muni
	UNION
	SELECT DISTINCT source_deal_header_id
	FROM #temp_updated_deal_ids
	
	SET @sql = 'spa_register_event 20601, 20595, ''' + @alert_process_table + ''', 1, ''' + @job_process_id + ''''
	SET @job_name = 'forecast_aggregation_alert_job_' + @job_process_id
	EXEC spa_run_sp_as_job @job_name, @sql, 'forecast_aggregation_alert_job', @user_name

	SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
	IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
	BEGIN
		EXEC('DROP TABLE ' + @after_insert_process_table)
	END
	
	EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

	SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
				SELECT source_deal_header_id FROM #temp_inserted_deal
				UNION 
				SELECT source_deal_header_id FROM #temp_updated_deal
				'
	EXEC(@sql)

	SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
	SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id 		
	EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name

	INSERT INTO source_system_data_import_status(
		process_id
		, code
		, module
		, source
		, type
		, [description]
		, recommendation
	) 
	SELECT @process_id,
		 'Info'
		, 'Forecast Aggregation'
		, 'Inserted Deal'
		, 'Inserted Deal'
		, CAST(COUNT(1) AS VARCHAR(10) ) + ' Deal' + IIF(COUNT(1) > 1 , 's are', ' is') + ' inserted.'
		, NULL
	FROM #temp_inserted_deal
	HAVING COUNT(1) > 0
	UNION ALL
	SELECT @process_id,
		 'Info'
		, 'Forecast Aggregation'
		, 'Updated Deal'
		, 'Updated Deal'
		, CAST(COUNT(1) AS VARCHAR(10) ) + ' Deal' + IIF(COUNT(1) > 1 , 's are', 'is') + ' updated.'
		, NULL
	FROM #temp_updated_deal
	HAVING COUNT(1) > 0


	INSERT INTO source_system_data_import_status_detail(process_id,source,[type],[description]) 
	SELECT @process_id
		, 'Inserted Deal'
		, 'Inserted Deal'
		, 'Deal <B>' + deal_id + '</B> is inserted.'
	FROM #temp_inserted_deal tid
	INNER JOIN source_deal_header sdh
		ON tid.source_deal_header_id = sdh.source_deal_header_id
	UNION ALL
	SELECT @process_id,
		 'Updated Deal'
		, 'Updated Deal'
		, 'Deal <B>' + deal_id + '</B> is updated.'
	FROM #temp_updated_deal tid
	INNER JOIN source_deal_header sdh
		ON tid.source_deal_header_id = sdh.source_deal_header_id


	IF EXISTS(SELECT 1 FROM #temp_error)
	BEGIN
		SET @has_error = 1
	END


	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
					'&spa=EXEC spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
	SELECT @url = '<a target="_blank" href="' + @url + '">' 
				+ 'Forecast Aggregation run successfully' + IIF(@has_error = 0, '', ' with errors')+ '. </a>'
	
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'Forecast Aggregation', @url, '', '', 's', NULL, NULL, @process_id

	EXEC spa_ErrorHandler 0,
			'Forecast Aggregation',
			'spa_forecast_aggregation',
			'Success',
			'Data Successfully Updated.',
			''
COMMIT
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1,
				'Forecast Aggregation',
				'spa_forecast_aggregation',
				'Error',
				'Fail to update data.',
				''

	DECLARE @error VARCHAR(150) = 'Job ' + @job_name + ' failed.'
	EXEC spa_message_board 'i', @user_name,  NULL, 'Forecast Aggregation', @error, '', '', '',  @job_name, NULL, @job_process_id, '', '', '', 'y'

	DECLARE @catch_error NVARCHAR(MAX)
	SET @catch_error = ERROR_MESSAGE()

	EXEC spa_print @catch_error
	EXEC spa_Print 'Rolling Back...'

	IF @@TRANCOUNT > 0 ROLLBACK

END CATCH

