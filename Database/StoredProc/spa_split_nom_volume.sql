IF OBJECT_ID('dbo.spa_split_nom_volume') IS NOT NULL
	DROP PROC dbo.spa_split_nom_volume

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_split_nom_volume] 
	@flag VARCHAR(1) = 's',	  -- s=call FROM sprit volume
	@sub VARCHAR(1000) = NULL, 
	@str VARCHAR(1000) = NULL,
	@book VARCHAR(1000) =NULL,
	@term_start DATETIME,
	@location_id VARCHAR(MAX) = NULL , -- pass WHEN call FROM sprit volume
	@destination_sub_book_id INT = NULL , --23 ,
	@sub_book VARCHAR(1000) = NULL,
	@term_end DATETIME = NULL,
	@enable_paging INT = 0, --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000) = NULL

AS
SET NOCOUNT ON 
/*
--SELECT * FROM source_minor_location WHERE location_id='TEST FUEL LOSS GRP'
 DECLARE @flag VARCHAR(1) = 'c',	  -- s=call FROM sprit volume
	@sub VARCHAR(1000)=NULL, 
	@str VARCHAR(1000)=NULL,
	@book 	VARCHAR(1000) =NULL,
	@term_start DATETIME='2015-10-25',
	@location_id VARCHAR(MAX) = NULL		,
	@destination_sub_book_id INT=NULL ,
	@sub_book VARCHAR(1000)=NULL ,
	@term_end DATETIME ='2015-10-25'
	 ,@batch_process_id VARCHAR(100) = NULL
	,@batch_report_param VARCHAR(1000) = NULL
	,@enable_paging INT = 0 --'1' = enable, '0' = disable
	,@page_size INT = NULL
	,@page_no INT = NULL


drop table #primary_deal_loc_vol
drop table  #route_split_vol
drop table #detail_inserted_deal
drop table #maintain_location_routes
drop table #pipeline_rounding

--*/

SET @term_end = ISNULL(@term_end, @term_start)

DECLARE @process_id VARCHAR(30),
		@report_position VARCHAR(150),
		@user_login_id VARCHAR(30),
		@st1 VARCHAR(MAX),
		@sdh_id INT,
		@DESC VARCHAR(500),
		@err_type VARCHAR(1),
		@url VARCHAR(MAX), 
		@module VARCHAR(100),
		@gen_nomination_mapping	VARCHAR(100),
		@gen_rounding VARCHAR(100)

SET @gen_nomination_mapping = 'Nomination Mapping'

SELECT @gen_rounding = 'Pipeline Rounding Method'

SELECT	CAST(clm1_value AS INT) pipeline,  
		CAST(clm2_value AS INT) rounding_method 
	INTO #pipeline_rounding
FROM generic_mapping_header h 
INNER JOIN generic_mapping_values v 
	ON v.mapping_table_id = h.mapping_table_id
	AND h.mapping_name= @gen_rounding

--START OF INSERTING TEMPLATE DEAL
	
DECLARE @transport_template_id INT 

SELECT @transport_template_id = template_id 
FROM source_deal_header_template 
WHERE template_name = 'Transportation NG' 

IF OBJECT_ID(N'tempdb..#source_deal_header') IS NOT NULL DROP TABLE #source_deal_header
IF OBJECT_ID(N'tempdb..#source_deal_detail') IS NOT NULL DROP TABLE #source_deal_detail
IF OBJECT_ID(N'tempdb..#user_defined_deal_fields') IS NOT NULL DROP TABLE #user_defined_deal_fields

SELECT * INTO #source_deal_header FROM source_deal_header WHERE 1 = 0
SELECT * INTO #source_deal_detail FROM source_deal_detail WHERE 1 = 0
SELECT * INTO #user_defined_deal_fields FROM user_defined_deal_fields WHERE 1 = 0

INSERT INTO #source_deal_header (
	[source_system_id]
	,deal_id
	,[deal_date]
	,[ext_deal_id]
	,[physical_financial_flag]
	,[structured_deal_id]
	,[counterparty_id]
	,[entire_term_start]
	,[entire_term_end]
	,[source_deal_type_id]
	,[deal_sub_type_type_id]
	,[option_flag]
	,[option_type]
	,[option_excercise_type]
	,[description1]
	,[description2]
	,[description3]
	,[deal_category_value_id]
	,[trader_id]
	,[internal_deal_type_value_id]
	,[internal_deal_subtype_value_id]
	,[template_id]
	,[header_buy_sell_flag]
	,[broker_id]
	,[generator_id]
	,[status_value_id]
	,[status_date]
	,[assignment_type_value_id]
	,[compliance_year]
	,[state_value_id]
	,[assigned_date]
	,[assigned_by]
	,[generation_source]
	,[aggregate_environment]
	,[aggregate_envrionment_comment]
	,[rec_price]
	,[rec_formula_id]
	,[rolling_avg]
	,[contract_id]
	,[create_user]
	,[create_ts]
	,[update_user]
	,[update_ts]
	,[legal_entity]
	,[internal_desk_id]
	,[product_id]
	,[internal_portfolio_id]
	,[commodity_id]
	,[reference]
	,[deal_locked]
	,[close_reference_id]
	,[block_type]
	,[block_define_id]
	,[granularity_id]
	,[Pricing]
	,[deal_reference_type_id]
	,[unit_fixed_flag]
	,[broker_unit_fees]
	,[broker_fixed_cost]
	,[broker_currency_id]
	,[deal_status]
	,[term_frequency]
	,[option_settlement_date]
	,[verified_by]
	,[verified_date]
	,[risk_sign_off_by]
	,[risk_sign_off_date]
	,[back_office_sign_off_by]
	,[back_office_sign_off_date]
	,[book_transfer_id]
	,[confirm_status_type]
	,[deal_rules]
	,[confirm_rule]
	,[timezone_id]
	,[source_system_book_id1]
	,[source_system_book_id2]
	,[source_system_book_id3]
	,[source_system_book_id4]	
)
SELECT 
	[source_system_id]
	,'Gath Nom Template'  deal_id
	, GETDATE()
	,[ext_deal_id]
	,[physical_financial_flag]
	,[structured_deal_id]
	,[counterparty_id]
	,GETDATE()
	,GETDATE()
	,[source_deal_type_id]
	,[deal_sub_type_type_id]
	,[option_flag]
	,[option_type]
	,[option_excercise_type]
	,[description1]
	,[description2]
	,[description3]
	,[deal_category_value_id]
	,[trader_id]
	,[internal_deal_type_value_id]
	,[internal_deal_subtype_value_id]
	,[template_id]
	,[header_buy_sell_flag]
	,[broker_id]
	,[generator_id]
	,[status_value_id]
	,[status_date]
	,[assignment_type_value_id]
	,[compliance_year]
	,[state_value_id]
	,[assigned_date]
	,[assigned_by]
	,[generation_source]
	,[aggregate_environment]
	,[aggregate_envrionment_comment]
	,[rec_price]
	,[rec_formula_id]
	,[rolling_avg]
	,[contract_id]
	,[create_user]
	,[create_ts]
	,[update_user]
	,[update_ts]
	,[legal_entity]
	,[internal_desk_id]
	,[product_id]
	,[internal_portfolio_id]
	,[commodity_id]
	,[reference]
	,[deal_locked]
	,[close_reference_id]
	,[block_type]
	,[block_define_id]
	,[granularity_id]
	,[Pricing]
	,[deal_reference_type_id]
	,[unit_fixed_flag]
	,[broker_unit_fees]
	,[broker_fixed_cost]
	,[broker_currency_id]
	,[deal_status]
	, 'd'
	,[option_settlement_date]
	,[verified_by]
	,[verified_date]
	,[risk_sign_off_by]
	,[risk_sign_off_date]
	,[back_office_sign_off_by]
	,[back_office_sign_off_date]
	,[book_transfer_id]
	,17215
	,[deal_rules]
	,[confirm_rule]
	,[timezone_id]
	, -1
	, -2
	, -3
	, -4
 FROM source_deal_header_template 
 WHERE template_name = 'Transportation NG'

INSERT INTO #source_deal_detail
(
	[source_deal_header_id]
	, [term_start]
	, [term_end]
	, [Leg]
	, [contract_expiration_date]
	, [fixed_float_leg]
	, [buy_sell_flag]
	, [curve_id]
	, [fixed_price]
	, [fixed_price_currency_id]
	, [option_strike_price]
	, [deal_volume]
	, [deal_volume_frequency]
	, [deal_volume_uom_id]
	, [block_description]
	, [deal_detail_description]
	, [formula_id]
	, [volume_left]
	, [settlement_volume]
	, [settlement_uom]
	, [create_user]
	, [create_ts]
	, [update_user]
	, [update_ts]
	, [price_adder]
	, [price_multiplier]
	, [settlement_date]
	, [day_count_id]
	, [location_id]
	, [meter_id]
	, [physical_financial_flag]
	, [Booked]
	, [process_deal_status]
	, [fixed_cost]
	, [multiplier]
	, [adder_currency_id]
	, [fixed_cost_currency_id]
	, [formula_currency_id]
	, [price_adder2]
	, [price_adder_currency2]
	, [volume_multiplier2]
	, [pay_opposite]
	, [capacity]
	, [settlement_currency]
	, [standard_yearly_volume]
	, [formula_curve_id]
	, [price_uom_id]
	, [category]
	, [profile_code]
	, [pv_party]
	, [status]
	, [lock_deal_detail]
)
 SELECT 
	 1
	, [term_start]
	, [term_end]
	, [Leg]
	, [contract_expiration_date]
	, [fixed_float_leg]
	, [buy_sell_flag]
	, [curve_id]
	, [fixed_price]
	, [fixed_price_currency_id]
	, [option_strike_price]
	, [deal_volume]
	, [deal_volume_frequency]
	, [deal_volume_uom_id]
	, [block_description]
	, [deal_detail_description]
	, [formula_id]
	, [volume_left]
	, [settlement_volume]
	, [settlement_uom]
	, [create_user]
	, [create_ts]
	, [update_user]
	, [update_ts]
	, [price_adder]
	, [price_multiplier]
	, [settlement_date]
	, [day_count_id]
	, [location_id]
	, [meter_id]
	, [physical_financial_flag]
	, [Booked]
	, [process_deal_status]
	, [fixed_cost]
	, [multiplier]
	, [adder_currency_id]
	, [fixed_cost_currency_id]
	, [formula_currency_id]
	, [price_adder2]
	, [price_adder_currency2]
	, [volume_multiplier2]
	, [pay_opposite]
	, [capacity]
	, [settlement_currency]
	, [standard_yearly_volume]
	, [formula_curve_id]
	, [price_uom_id]
	, [category]
	, [profile_code]
	, [pv_party]
	, [status]
	, [lock_deal_detail]
FROM source_deal_detail_template sddt
WHERE sddt.template_id = @transport_template_id

INSERT INTO #user_defined_deal_fields (
	source_deal_header_id, udf_template_id, udf_value
)
SELECT 1, udf_template_id, default_value
FROM user_defined_deal_fields_template --_main 
WHERE template_id  = @transport_template_id 
AND udf_type= 'h'

--END OF INSERTING TEMPLATE DEAL

SELECT @sdh_id = source_deal_header_id
FROM #source_deal_header
WHERE deal_id = 'Gath Nom Template'


SET @process_id = ISNULL(@batch_process_id, REPLACE(NEWID(), '-', '_'))
SET @user_login_id= dbo.FNADBUser()	


SET @report_position = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id) 
EXEC ('CREATE TABLE ' + @report_position + '( source_deal_header_id INT, action CHAR(1))')  

--IF OBJECT_ID(N'tempdb..#book_pipeline') IS NOT NULL
--	DROP TABLE #book_pipeline

--CREATE TABLE #book_pipeline (book_id INT,book_deal_type_map_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)		
	
--SET @st1='INSERT INTO #book_pipeline (book_id,book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4)		
--	SELECT book.entity_id, book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
--	FROM source_system_book_map sbm            
--		INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
--		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id --AND stra.entity_id=17 --equity gas stra..
--	WHERE 1=1 '
--		+CASE WHEN  @sub IS NULL THEN '' ELSE ' AND stra.parent_entity_id in ('+@sub+')' END
--		+CASE WHEN  @str IS NULL THEN '' ELSE ' AND stra.entity_id in ('+@str+')' END
--		+CASE WHEN  @book IS NULL THEN '' ELSE ' AND book.entity_id in ('+@book+')' END	
--		+CASE WHEN  @sub_book IS NULL THEN '' ELSE ' AND sbm.book_deal_type_map_id in ('+@sub_book+')' END	
		
--EXEC(@st1)

IF OBJECT_ID(N'tempdb..#tmp_deal_loc') IS NOT NULL
	DROP TABLE #tmp_deal_loc

CREATE TABLE  #tmp_deal_loc (
	[meter_id] INT,
	[Term] DATETIME,
	[Volume] NUMERIC(38,10),
	location_id INT
)

IF OBJECT_ID(N'tempdb..#time_series_data') IS NOT NULL
	DROP TABLE #time_series_data
 
IF OBJECT_ID(N'tempdb..#sub_book') IS NOT NULL
	DROP TABLE #sub_book

SELECT tsd.time_series_definition_id
		,sd.maturity
		,sd.value 
	INTO #time_series_data 
FROM dbo.time_series_definition tsd 
CROSS APPLY (
	SELECT maturity,	
		MAX(effective_date) effective_date 
	FROM dbo.time_series_data 
	WHERE time_series_definition_id = tsd.time_series_definition_id
		AND  effective_date <= ISNULL(maturity, @term_start)  
		AND ISNULL(maturity, @term_start) BETWEEN @term_start AND @term_end
	GROUP BY maturity 
) eff
INNER JOIN dbo.time_series_data sd 
	ON  sd.time_series_definition_id = tsd.time_series_definition_id 
	AND sd.effective_date = eff.effective_date
	AND  ISNULL(sd.maturity,'1900-01-01') = ISNULL(eff.maturity,'1900-01-01')


SELECT CAST(clm1_value AS INT) pipeline,  
	CAST(clm2_value AS INT) sub_book_id	   
INTO #sub_book
FROM generic_mapping_header h 
INNER JOIN generic_mapping_values v 
	ON v.mapping_table_id = h.mapping_table_id
	AND h.mapping_name = @gen_nomination_mapping
	
IF @flag = 'c'
BEGIN
	IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL
		DROP TABLE #tmp_deals

	CREATE TABLE #tmp_deals (row_id INT, source_deal_header_id INT NULL)

	INSERT INTO #tmp_deals (row_id, source_deal_header_id) --SELECT * FROM #tmp_deals
	SELECT  ROW_NUMBER() OVER(ORDER BY sdh.source_deal_header_id)
			, sdh.source_deal_header_id 
	FROM source_deal_header sdh 
	INNER JOIN source_system_book_map ssbm 
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		AND sdh.entire_term_start BETWEEN @term_start AND @term_end 
		AND sdh.source_deal_header_id <> @sdh_id
	INNER JOIN 	#sub_book sb 
		ON ssbm.book_deal_type_map_id = sb.sub_book_id
	

	IF EXISTS(SELECT TOP 1 1 FROM #tmp_deals)
	BEGIN
		DELETE ngs 
		FROM nom_group_schedule_deal ngs
		INNER JOIN #tmp_deals td 
			ON td.source_deal_header_id = ngs.schedule_deal_id

		DECLARE @user_login_id1 VARCHAR(20)
		DECLARE @process_id1 VARCHAR(200)

		SET @user_login_id1 = dbo.FNADBUser()
		SET @process_id1 = dbo.FNAGetNewID()

		DECLARE @delete_deals_table1 VARCHAR(100)
		SET @delete_deals_table1 = dbo.FNAProcessTableName('delete_deals', @user_login_id1, @process_id1)

		EXEC('CREATE TABLE ' + @delete_deals_table1 + '(source_deal_header_id INT, status VARCHAR(20), description VARCHAR(500))')
		EXEC('INSERT INTO ' + @delete_deals_table1 +  ' (source_deal_header_id) SELECT source_deal_header_id FROM #tmp_deals')

		EXEC spa_sourcedealheader 'd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @process_id1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'y' 

	END
	ELSE
	BEGIN
		DELETE ngs 
		FROM nom_group_schedule_deal ngs
		INNER JOIN delete_source_deal_header dsdh 
			ON dsdh.source_deal_header_id = ngs.schedule_deal_id
	END
END

DECLARE    @location_type INT, @meter_type INT
SELECT @location_type = source_major_location_id 
FROM source_major_location 
WHERE location_name = 'Gathering System'   --9

SELECT @meter_type = value_id 
FROM static_data_value 
WHERE code='Wellhead'   --9

SET @st1 = '
	INSERT INTO #tmp_deal_loc ([Term] ,[Volume] ,location_id,meter_id)
	SELECT mdh.prod_date 
		, SUM(
				ISNULL(mdh.Hr1, 0) + ISNULL(mdh.Hr2, 0) +ISNULL(mdh.Hr3, 0) + ISNULL(mdh.Hr4, 0) + ISNULL(mdh.Hr5, 0) + 
				ISNULL(mdh.Hr6, 0) + ISNULL(mdh.Hr7, 0) +ISNULL(mdh.Hr8, 0) + ISNULL(mdh.Hr9, 0) + ISNULL(mdh.Hr10, 0) + 
				ISNULL(mdh.Hr11, 0) + ISNULL(mdh.Hr12, 0) + ISNULL(mdh.Hr13, 0) + ISNULL(mdh.Hr14, 0) + ISNULL(mdh.Hr15, 0) + 
				ISNULL(mdh.Hr16, 0) + ISNULL(mdh.Hr17, 0) + ISNULL(mdh.Hr18, 0) + ISNULL(mdh.Hr19, 0) + ISNULL(mdh.Hr20, 0) + 
				ISNULL(mdh.Hr21, 0) + ISNULL(mdh.Hr22, 0) + ISNULL(mdh.Hr23, 0) + ISNULL(mdh.Hr24, 0)
		) volume
		, sml.source_minor_location_id,
		MAX(smlm.meter_id) meter_id 
	FROM source_minor_location sml 
	INNER JOIN source_minor_location_meter smlm
		ON sml.source_minor_location_id = smlm.source_minor_location_id 
		AND meter_type = ' + CAST(@meter_type AS VARCHAR) + '  --Wellhead
		AND  sml.source_major_location_id = ' + CAST(@location_type AS VARCHAR) + '
	INNER JOIN mv90_data mvd 
		ON mvd.meter_id = smlm.meter_id 	
		AND mvd.channel = 1
	INNER JOIN mv90_data_hour mdh 
		ON mdh.meter_data_id = mvd.meter_data_id
		AND mdh.prod_date BETWEEN mvd.from_date AND mvd.to_date
		AND mdh.prod_date BETWEEN ''' + CONVERT(VARCHAR(10),@term_start ,120) + ''' AND ''' + CONVERT(VARCHAR(10),@term_end,120) + '''
	LEFT JOIN dbo.nom_group_schedule_deal ngsd 
		ON sml.source_minor_location_id = ngsd.location_id 
		AND ngsd.term_start = mdh.prod_date
	WHERE  ngsd.rowid IS NULL ' + CASE WHEN @location_id IS NULL THEN '' ELSE ' 
		AND sml.source_minor_location_id  IN (' + @location_id + ')'  END +'
	GROUP BY sml.source_minor_location_id, mdh.prod_date
'


EXEC spa_print @st1
EXEC(@st1)

IF OBJECT_ID(N'tempdb..#tmp_nom_location') IS NOT NULL
	DROP TABLE #tmp_nom_location

SELECT [rowid] = IDENTITY(INT, 1, 1)
	, tu.Term
	, tu.location_id from_location
	, SUM(tu.Volume) Volume
	, MAX(tu.meter_id)  meter_from
	, MAX(dp.group_id) route_id
	, MAX(nom.group_id) group_id
INTO #tmp_nom_location
FROM #tmp_deal_loc tu
--LEFT JOIN source_deal_header sdh ON tu.[Deal ID] = sdh.source_deal_header_id
--LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
--	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
--	AND ssbm.source_system_book_id3=sdh.source_system_book_id3
--	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
--LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
--LEFT JOIN portfolio_hierarchy st ON st.entity_id = book.parent_entity_id
--LEFT JOIN fas_subsidiaries sb ON sb.fas_subsidiary_id = st.parent_entity_id
--LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tu.location_id
CROSS APPLY (
	SELECT TOP(1) * 
	FROM  source_minor_location_nomination_group ng 
	WHERE ng.source_minor_location_id = tu.location_id	
		AND ng.effective_date <= @term_start 
		AND info_type = 'r'
	ORDER BY  effective_date DESC
) dp 
OUTER APPLY (
	SELECT TOP(1) * 
	FROM  source_minor_location_nomination_group ng 
	WHERE ng.source_minor_location_id = tu.location_id	
		AND ng.effective_date <= @term_start 
		AND info_type <> 'r'
	ORDER BY effective_date DESC
) nom 
GROUP BY tu.Term,tu.location_id
HAVING SUM(tu.Volume) <> 0	;

 --assumation: there will be always only one primary route in volume split route group
 --   drop table #maintain_location_routes

SELECT  DISTINCT r.route_id 
		, r.time_series_definition_id
		, r.[maintain_location_routes_id]
		, r.delivery_location
		, COALESCE(r.fuel_loss, tsd.value, 0) fuel_loss
		, r.route_order_in
		, r.[primary_secondary]
		, r.is_group
		, r.pipeline
		, r.contract_id
INTO #maintain_location_routes
FROM  dbo.maintain_location_routes r 
LEFT JOIN #tmp_nom_location p  
	ON p.route_id = r.route_id  
LEFT JOIN #time_series_data tsd 
	ON r.time_series_definition_id = tsd.time_series_definition_id 
	AND p.Term = ISNULL(tsd.maturity, p.Term)
	
--- taking all the primary route only

;WITH primary_deal_loc_vol(
	maintain_location_routes_id
	, route_id
	, from_location
	, delivery_location
	, from_volume
	, delivery_volume
	, route_order_in
	, is_split_vol
	, original_location
	, term
) 
AS 
(
    SELECT DISTINCT r.[maintain_location_routes_id]
		, p.route_id
		, p.from_location
		, r.delivery_location
		, p.volume from_volume
		, CAST(p.volume * (1 - COALESCE(r.fuel_loss, 0)) AS NUMERIC(38, 10)) delivery_volume
		, ISNULL(r.route_order_in, 1) route_order_in
		, 0 is_split_vol
		, from_location [original_location]
		, p.term
	 FROM #tmp_nom_location p 
	 INNER JOIN #maintain_location_routes r 
		ON p.route_id = r.route_id  
		AND r.[primary_secondary] = 'p'
		INNER JOIN 
		( 
			SELECT a.route_id, MIN(a.route_order_in) route_order_in 
			FROM #tmp_nom_location b 
			INNER JOIN #maintain_location_routes a 
				ON b.route_id = a.route_id  
				AND a.[primary_secondary] = 'p'
			GROUP BY a.route_id
		) m 
			ON m.route_id = p.route_id
		WHERE (
				(r.is_group = 'y' AND r.route_order_in = m.route_order_in) 
				OR  r.is_group = 'n'
				)
    UNION ALL
	SELECT e.[maintain_location_routes_id]
			, e.route_id
			, d.delivery_location from_location
			, e.delivery_location 
			, d.delivery_volume from_volume
			, CAST(d.delivery_volume * (1 - COALESCE(e.fuel_loss, 0)) AS NUMERIC(38,10))  delivery_volume
			, e.route_order_in
			, 0 is_split_vol
			, d.[original_location]
			, d.term	
    FROM #maintain_location_routes e																															   
    INNER JOIN primary_deal_loc_vol d 
		ON e.route_id = d.route_id 
		AND ISNULL(e.route_order_in, 1) = d.route_order_in + 1	
		AND e.[primary_secondary] = 'p'
)

SELECT  rowid = IDENTITY(INT, 1, 1),
	a.* 
INTO #primary_deal_loc_vol 
FROM primary_deal_loc_vol a 
ORDER BY route_id, route_order_in

--SELECT rt.*,v.from_volume INTO #route_split_vol	 -- all the primary route that need to be splitted volumn(route having secondary route) 
--FROM 	
--( 
--	SELECT route_id,MAX(ISNULL(route_order_in,1)) route_order_in FROM  #primary_deal_loc_vol GROUP BY route_id	 
--) rt
--CROSS APPLY
--( 
--	SELECT TOP(1)  1 exist_data FROM  #maintain_location_routes WHERE  [primary_secondary]='s'	
--		AND	 rt.route_order_in >ISNULL(route_order_in,1) AND route_id=rt.route_id
--) existance_checking
--CROSS APPLY 
--( 
--	SELECT TOP(1) from_volume  FROM  #primary_deal_loc_vol WHERE route_id=rt.route_id AND	route_order_in=rt.route_order_in 
--) v

SELECT rt.* INTO #route_split_vol	 -- all the primary route that need to be splitted volumn(route having secondary route) 
FROM 	
( 
	SELECT route_id, MAX(ISNULL(route_order_in,1)) route_order_in 
	FROM  #primary_deal_loc_vol 
	GROUP BY route_id	 
) rt
CROSS APPLY
( 
	SELECT TOP(1)  1 exist_data 
	FROM  #maintain_location_routes 
	WHERE [primary_secondary]='s'	
		AND	ISNULL(route_order_in, 1) = rt.route_order_in + 1	 
		AND route_id = rt.route_id
) existance_checking
ORDER BY rt.route_id, rt.route_order_in

IF ISNULL(@flag, 'c') = 's'
BEGIN
	SELECT mlr.route_id
		, tnl.from_location gathering_loc
		, mlr.[delivery_location] [delivery_loc]
		, mlr.[primary_secondary]
		, tnl.group_id	
		, CASE WHEN mlr.[primary_secondary] = 's' THEN 0 ELSE tnl.Volume /*rsv.from_volume*/	END	  Volume  
		, mlr.contract_id
	FROM #tmp_nom_location  tnl 
	INNER JOIN	#route_split_vol rsv 
		ON rsv.route_id = tnl.route_id   
	INNER JOIN [dbo].maintain_location_routes mlr 
		ON mlr.route_id = tnl.route_id 
		AND ISNULL( mlr.route_order_in, 1) >= rsv.route_order_in
	ORDER BY tnl.from_location, mlr.route_order_in
	
	RETURN

END

IF NOT EXISTS (SELECT 1 FROM #tmp_nom_location	)
BEGIN
	--SELECT 'There IS no volume uploaded to run Auto Nom.' [Status], dbo.FNADateFormat(@term_start) term_start
	SET @err_type = 'e'
	
	SET @DESC =	'There IS no volume uploaded to run Auto Nom.'

	GOTO msg_level
	--EXEC spa_message_board 'i', @user_login_id,NULL,'Split NOM Volume',@DESC,NULL,NULL, 'e'  ,NULL,NULL, @batch_process_id
	--RETURN
End

CREATE TABLE #detail_inserted_deal (source_deal_header_id INT)

IF OBJECT_ID(N'tempdb..#tmp_header') IS NOT NULL
	DROP TABLE #tmp_header

SELECT [source_system_id]
    ,[deal_id]
    ,[deal_date]
    ,[ext_deal_id]
    ,[physical_financial_flag]
    ,[structured_deal_id]
    ,[counterparty_id]
    ,[entire_term_start]
    ,[entire_term_end]
    ,[source_deal_type_id]
    ,[deal_sub_type_type_id]
    ,[option_flag]
    ,[option_type]
    ,[option_excercise_type]
    ,[source_system_book_id1]
    ,[source_system_book_id2]
    ,[source_system_book_id3]
    ,[source_system_book_id4]
    ,[description1]
    ,[description2]
    ,[description3]
    ,[deal_category_value_id]
    ,[trader_id]
    ,[INTernal_deal_type_value_id]
    ,[INTernal_deal_subtype_value_id]
    ,[template_id]
    ,[header_buy_sell_flag]
    ,[broker_id]
    ,[generator_id]
    ,[status_value_id]
    ,[status_date]
    ,[assignment_type_value_id]
    ,[compliance_year]
    ,[state_value_id]
    ,[assigned_date]
    ,[assigned_by]
    ,[generation_source]
    ,[aggregate_environment]
    ,[aggregate_envrionment_comment]
    ,[rec_price]
    ,[rec_formula_id]
    ,[rolling_avg]
    ,[contract_id]
    ,[create_user]
    ,[create_ts]
    ,[update_user]
    ,[update_ts]
    ,[legal_entity]
    ,[INTernal_desk_id]
    ,[product_id]
    ,[INTernal_portfolio_id]
    ,[commodity_id]
    ,[reference]
    ,[deal_locked]
    ,[close_reference_id]
    ,[block_type]
    ,[block_define_id]
    ,[granularity_id]
    ,[Pricing]
    ,[deal_reference_type_id]
    ,[unit_fixed_flag]
    ,[broker_unit_fees]
    ,[broker_fixed_cost]
    ,[broker_currency_id]
    ,[deal_status]
    ,[term_frequency]
    ,[option_settlement_date]
    ,[verified_by]
    ,[verified_date]
    ,[risk_sign_off_by]
    ,[risk_sign_off_date]
    ,[back_office_sign_off_by]
    ,[back_office_sign_off_date]
    ,[book_transfer_id]
    ,[confirm_status_type]
    ,[sub_book]
    ,[deal_rules]
    ,[confirm_rule]
    ,[description4]
    ,[timezone_id]
	,CAST(0 AS INT) source_deal_header_id
INTO #tmp_header
FROM [dbo].[source_deal_header] 
WHERE 1 = 2

--BEGIN try
--BEGIN tran

EXEC spa_print 'INSERT INTO [dbo].[source_deal_header]'

INSERT INTO [dbo].[source_deal_header]
           ([source_system_id]
           ,[deal_id]
           ,[deal_date]
           ,[ext_deal_id]
           ,[physical_financial_flag]
           ,[structured_deal_id]
           ,[counterparty_id]
           ,[entire_term_start]
           ,[entire_term_end]
           ,[source_deal_type_id]
           ,[deal_sub_type_type_id]
           ,[option_flag]
           ,[option_type]
           ,[option_excercise_type]
           ,[source_system_book_id1]
           ,[source_system_book_id2]
           ,[source_system_book_id3]
           ,[source_system_book_id4]
           ,[description1]
           ,[description2]
           ,[description3]
           ,[deal_category_value_id]
           ,[trader_id]
           ,[INTernal_deal_type_value_id]
           ,[INTernal_deal_subtype_value_id]
           ,[template_id]
           ,[header_buy_sell_flag]
           ,[broker_id]
           ,[generator_id]
           ,[status_value_id]
           ,[status_date]
           ,[assignment_type_value_id]
           ,[compliance_year]
           ,[state_value_id]
           ,[assigned_date]
           ,[assigned_by]
           ,[generation_source]
           ,[aggregate_environment]
           ,[aggregate_envrionment_comment]
           ,[rec_price]
           ,[rec_formula_id]
           ,[rolling_avg]
           ,[contract_id]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts]
           ,[legal_entity]
           ,[INTernal_desk_id]
           ,[product_id]
           ,[INTernal_portfolio_id]
           ,[commodity_id]
           ,[reference]
           ,[deal_locked]
           ,[close_reference_id]
           ,[block_type]
           ,[block_define_id]
           ,[granularity_id]
           ,[Pricing]
           ,[deal_reference_type_id]
           ,[unit_fixed_flag]
           ,[broker_unit_fees]
           ,[broker_fixed_cost]
           ,[broker_currency_id]
           ,[deal_status]
           ,[term_frequency]
           ,[option_settlement_date]
           ,[verified_by]
           ,[verified_date]
           ,[risk_sign_off_by]
           ,[risk_sign_off_date]
           ,[back_office_sign_off_by]
           ,[back_office_sign_off_date]
           ,[book_transfer_id]
           ,[confirm_status_type]
           ,[sub_book]
           ,[deal_rules]
           ,[confirm_rule]
           ,[description4]
           ,[timezone_id]
)
	OUTPUT 
			inserted.[source_system_id]
           ,inserted.[deal_id]
           ,inserted.[deal_date]
           ,inserted.[ext_deal_id]
           ,inserted.[physical_financial_flag]
           ,inserted.[structured_deal_id]
           ,inserted.[counterparty_id]
           ,inserted.[entire_term_start]
           ,inserted.[entire_term_end]
           ,inserted.[source_deal_type_id]
           ,inserted.[deal_sub_type_type_id]
           ,inserted.[option_flag]
           ,inserted.[option_type]
           ,inserted.[option_excercise_type]
           ,inserted.[source_system_book_id1]
           ,inserted.[source_system_book_id2]
           ,inserted.[source_system_book_id3]
           ,inserted.[source_system_book_id4]
           ,inserted.[description1]
           ,inserted.[description2]
           ,inserted.[description3]
           ,inserted.[deal_category_value_id]
           ,inserted.[trader_id]
           ,inserted.[INTernal_deal_type_value_id]
           ,inserted.[INTernal_deal_subtype_value_id]
           ,inserted.[template_id]
           ,inserted.[header_buy_sell_flag]
           ,inserted.[broker_id]
           ,inserted.[generator_id]
           ,inserted.[status_value_id]
           ,inserted.[status_date]
           ,inserted.[assignment_type_value_id]
           ,inserted.[compliance_year]
           ,inserted.[state_value_id]
           ,inserted.[assigned_date]
           ,inserted.[assigned_by]
           ,inserted.[generation_source]
           ,inserted.[aggregate_environment]
           ,inserted.[aggregate_envrionment_comment]
           ,inserted.[rec_price]
           ,inserted.[rec_formula_id]
           ,inserted.[rolling_avg]
           ,inserted.[contract_id]
           ,inserted.[create_user]
           ,inserted.[create_ts]
           ,inserted.[update_user]
           ,inserted.[update_ts]
           ,inserted.[legal_entity]
           ,inserted.[INTernal_desk_id]
           ,inserted.[product_id]
           ,inserted.[INTernal_portfolio_id]
           ,inserted.[commodity_id]
           ,inserted.[reference]
           ,inserted.[deal_locked]
           ,inserted.[close_reference_id]
           ,inserted.[block_type]
           ,inserted.[block_define_id]
           ,inserted.[granularity_id]
           ,inserted.[Pricing]
           ,inserted.[deal_reference_type_id]
           ,inserted.[unit_fixed_flag]
           ,inserted.[broker_unit_fees]
           ,inserted.[broker_fixed_cost]
           ,inserted.[broker_currency_id]
           ,inserted.[deal_status]
           ,inserted.[term_frequency]
           ,inserted.[option_settlement_date]
           ,inserted.[verified_by]
           ,inserted.[verified_date]
           ,inserted.[risk_sign_off_by]
           ,inserted.[risk_sign_off_date]
           ,inserted.[back_office_sign_off_by]
           ,inserted.[back_office_sign_off_date]
           ,inserted.[book_transfer_id]
           ,inserted.[confirm_status_type]
           ,inserted.[sub_book]
           ,inserted.[deal_rules]
           ,inserted.[confirm_rule]
           ,inserted.[description4]
           ,inserted.[timezone_id]
		   ,inserted.[source_deal_header_id]
	INTO #tmp_header

SELECT 
	h.[source_system_id]
    ,@process_id + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(mlr.maintain_location_routes_id AS VARCHAR),'')
    ,@term_start [deal_date]
    ,h.[ext_deal_id]
    ,h.[physical_financial_flag]
    ,h.[structured_deal_id]
    ,mlr.pipeline --change
    ,p.term
    ,p.term
    ,h.[source_deal_type_id]
    ,h.[deal_sub_type_type_id]
    ,h.[option_flag]
    ,h.[option_type]
    ,h.[option_excercise_type]
    ,b.source_system_book_id1
    ,b.source_system_book_id2
    ,b.source_system_book_id3
    ,b.source_system_book_id4
    ,COALESCE(sdv_ng.[description], sdv_ng.code, h.[description1]) -- sdv.description because sdv.code has interger id, value id = 304829
    ,COALESCE(sdv_priority.[description], sdv_priority.code, h.[description2])
    ,h.[description3]
    ,h.[deal_category_value_id]
    ,h.[trader_id]
    ,h.[INTernal_deal_type_value_id]
    ,h.[INTernal_deal_subtype_value_id]
    ,h.[template_id]
    ,h.[header_buy_sell_flag]
    ,h.[broker_id]
    ,h.[generator_id]
    ,h.[status_value_id]
    ,h.[status_date]
    ,h.[assignment_type_value_id]
    ,h.[compliance_year]
    ,h.[state_value_id]
    ,h.[assigned_date]
    ,h.[assigned_by]
    ,h.[generation_source]
    ,h.[aggregate_environment]
    ,h.[aggregate_envrionment_comment]
    ,h.[rec_price]
    ,h.[rec_formula_id]
    ,h.[rolling_avg]
    ,mlr.[contract_id] --change
    ,h.[create_user]
    ,GETDATE()
    ,h.[update_user]
    ,GETDATE()
    ,h.[legal_entity]
    ,h.[INTernal_desk_id]
    ,h.[product_id]
    ,h.[INTernal_portfolio_id]
    ,h.[commodity_id]
    ,h.[reference]
    ,'n' [deal_locked]
    ,h.[close_reference_id]
    ,h.[block_type]
    ,h.[block_define_id]
    ,h.[granularity_id]
    ,h.[Pricing]
    ,h.[deal_reference_type_id]
    ,h.[unit_fixed_flag]
    ,h.[broker_unit_fees]
    ,h.[broker_fixed_cost]
    ,h.[broker_currency_id]
    ,h.[deal_status]
    ,h.[term_frequency]
    ,h.[option_settlement_date]
    ,h.[verified_by]
    ,h.[verified_date]
    ,h.[risk_sign_off_by]
    ,h.[risk_sign_off_date]
    ,h.[back_office_sign_off_by]
    ,h.[back_office_sign_off_date]
    ,h.[book_transfer_id]
    ,h.[confirm_status_type]
    ,sb.sub_book_id
    ,h.[deal_rules]
    ,h.[confirm_rule]
    ,h.[description4]
    ,h.[timezone_id]
FROM #source_deal_header h
CROSS JOIN #tmp_nom_location p
INNER JOIN #maintain_location_routes mlr 
	ON mlr.route_id=p.route_id 
INNER JOIN #sub_book sb 
	ON sb.pipeline=mlr.pipeline
INNER JOIN source_system_book_map b 
	ON b.book_deal_type_map_id=sb.sub_book_id
OUTER APPLY (
	SELECT TOP(1) * 
	FROM nomination_group ng 
	WHERE ng.effective_date <= @term_start 
		AND ng.nomination_group = p.group_id
	ORDER BY effective_date DESC
) ng
LEFT JOIN static_data_value sdv_ng 
	ON sdv_ng.value_id = ng.nomination_group
LEFT JOIN static_data_value sdv_priority 
	ON sdv_priority.value_id = ng.[priority]
WHERE (mlr.is_group = 'y' AND  mlr.route_order_in IS NOT NULL) 
	OR  mlr.is_group='n'
ORDER BY mlr.route_id, p.from_location, mlr.route_order_in;

--creating deal detail of all the primary route except split volume route.

INSERT INTO [dbo].[source_deal_detail]
           ([source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts]
           ,[price_adder]
           ,[price_multiplier]
           ,[settlement_date]
           ,[day_count_id]
           ,[location_id]
           ,[meter_id]
           ,[physical_financial_flag]
           ,[Booked]
           ,[process_deal_status]
           ,[fixed_cost]
           ,[multiplier]
           ,[adder_currency_id]
           ,[fixed_cost_currency_id]
           ,[formula_currency_id]
           ,[price_adder2]
           ,[price_adder_currency2]
           ,[volume_multiplier2]
           ,[pay_opposite]
           ,[capacity]
           ,[settlement_currency]
           ,[standard_yearly_volume]
           ,[formula_curve_id]
           ,[price_uom_id]
           ,[category]
           ,[profile_code]
           ,[pv_party]
           ,[status]
           ,[lock_deal_detail])
	OUTPUT 
		inserted.source_deal_header_id
	INTO #detail_inserted_deal
SELECT	th.[source_deal_header_id]
    ,p.term
    ,p.term
    ,s.[Leg]
    ,s.[contract_expiration_date]
    ,s.[fixed_float_leg]
    ,s.[buy_sell_flag]
    ,s.[curve_id]
    ,s.[fixed_price]
    ,s.[fixed_price_currency_id]
    ,s.[option_strike_price]
    ,dbo.FNAPipelineRound(1, CASE WHEN s.[Leg]=1 THEN pri_deal.from_volume  ELSE pri_deal.delivery_volume END, 0)  [deal_volume]
    ,s.[deal_volume_frequency]
    ,s.[deal_volume_uom_id]
    ,s.[block_description]
    ,s.[deal_detail_description]
    ,s.[formula_id]
    ,dbo.FNAPipelineRound(1,CASE WHEN s.[Leg]=1 THEN pri_deal.from_volume  ELSE pri_deal.delivery_volume END, 0)  [volume_left]
    ,s.[settlement_volume]
    ,s.[settlement_uom]
    ,s.[create_user]
    ,GETDATE() [create_ts]
    ,s.[update_user]
    ,GETDATE() [update_ts]
    ,s.[price_adder]
    ,s.[price_multiplier]
    ,s.[settlement_date]
    ,s.[day_count_id]
    ,CASE WHEN s.[Leg]=1 THEN pri_deal.from_location  ELSE pri_deal.delivery_location END [location_id] --change/managed FROM above
    ,s.[meter_id] --change/managed FROM above
    ,s.[physical_financial_flag]
    ,s.[Booked]
    ,s.[process_deal_status]
    ,s.[fixed_cost]
    ,s.[multiplier]
    ,s.[adder_currency_id]
    ,s.[fixed_cost_currency_id]
    ,s.[formula_currency_id]
    ,s.[price_adder2]
    ,s.[price_adder_currency2]
    ,s.[volume_multiplier2]
    ,s.[pay_opposite]
    ,s.[capacity]
    ,s.[settlement_currency]
    ,s.[standard_yearly_volume]
    ,s.[formula_curve_id]
    ,s.[price_uom_id]
    ,s.[category]
    ,s.[profile_code]
    ,s.[pv_party]
    ,s.[status]
    ,s.[lock_deal_detail]
FROM #source_deal_detail s
CROSS JOIN #tmp_nom_location p 
INNER JOIN #primary_deal_loc_vol pri_deal 
	ON pri_deal.route_id=p.route_id 
	AND p.from_location = pri_deal.original_location 	
	AND p.term=pri_deal.term
INNER JOIN #tmp_header th 
	ON th.deal_id = @process_id + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(pri_deal.maintain_location_routes_id AS VARCHAR),'')
LEFT JOIN #route_split_vol  rsv 
	ON pri_deal.route_id = rsv.route_id	  
	AND pri_deal.route_order_in = rsv.route_order_in
LEFT JOIN  #pipeline_rounding pr 
	ON pr.pipeline=th.counterparty_id --rounding_method
WHERE rsv.route_order_in IS NULL --creating deal detail of all the primary route except split volume route.

-- creating deal detail of all the split volume route( it could be primary AND secondary).

INSERT INTO [dbo].[source_deal_detail]
           ([source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts]
           ,[price_adder]
           ,[price_multiplier]
           ,[settlement_date]
           ,[day_count_id]
           ,[location_id]
           ,[meter_id]
           ,[physical_financial_flag]
           ,[Booked]
           ,[process_deal_status]
           ,[fixed_cost]
           ,[multiplier]
           ,[adder_currency_id]
           ,[fixed_cost_currency_id]
           ,[formula_currency_id]
           ,[price_adder2]
           ,[price_adder_currency2]
           ,[volume_multiplier2]
           ,[pay_opposite]
           ,[capacity]
           ,[settlement_currency]
           ,[standard_yearly_volume]
           ,[formula_curve_id]
           ,[price_uom_id]
           ,[category]
           ,[profile_code]
           ,[pv_party]
           ,[status]
           ,[lock_deal_detail])
	OUTPUT 
		inserted.source_deal_header_id
	INTO #detail_inserted_deal
	SELECT	th.[source_deal_header_id]
           ,p.term
           ,p.term
           ,s.[Leg]
           ,s.[contract_expiration_date]
           ,s.[fixed_float_leg]
           ,s.[buy_sell_flag]
           ,s.[curve_id]
           ,s.[fixed_price]
           ,s.[fixed_price_currency_id]
           ,s.[option_strike_price]
		  --  ,CASE WHEN s.[Leg]=1 THEN ROUND(pri_deal.from_volume*ISNULL(ega.split_percentage,1), 0)  ELSE ROUND(pri_deal.delivery_volume*ISNULL(ega.split_percentage,1), 0) END  [deal_volume]
   		    ,dbo.FNAPipelineRound(1,CASE WHEN s.[Leg]=1 THEN pri_deal.from_volume*ISNULL(ega.split_percentage,1)  ELSE pri_deal.from_volume*ISNULL(ega.split_percentage,1)*(1-ISNULL(mlr.fuel_loss,1)) END, 0) [deal_volume]
           --,CASE WHEN s.[Leg]=1 THEN ISNULL(ega.volume,pri_deal.from_volume)  ELSE ROUND(ISNULL(ega.volume*(1-ISNULL(mlr.fuel_loss,1)),pri_deal.delivery_volume), 0) END  [deal_volume]
           ,s.[deal_volume_frequency]
           ,s.[deal_volume_uom_id]
           ,s.[block_description]
           ,s.[deal_detail_description]
           ,s.[formula_id]
   		    ,dbo.FNAPipelineRound(1,CASE WHEN s.[Leg]=1 THEN pri_deal.from_volume*ISNULL(ega.split_percentage,1)  ELSE pri_deal.from_volume*ISNULL(ega.split_percentage,1)*(1-ISNULL(mlr.fuel_loss,1)) END, 0)  [left_volume]
           ,s.[settlement_volume]
           ,s.[settlement_uom]
           ,s.[create_user]
           ,GETDATE() [create_ts]
           ,s.[update_user]
           ,GETDATE() [update_ts]
           ,s.[price_adder]
           ,s.[price_multiplier]
           ,s.[settlement_date]
           ,s.[day_count_id]
           ,CASE WHEN s.[Leg]=1 THEN pri_deal.from_location  ELSE mlr.[delivery_location] END [location_id] 
           ,s.[meter_id]
           ,s.[physical_financial_flag]
           ,s.[Booked]
           ,s.[process_deal_status]
           ,s.[fixed_cost]
           ,s.[multiplier]
           ,s.[adder_currency_id]
           ,s.[fixed_cost_currency_id]
           ,s.[formula_currency_id]
           ,s.[price_adder2]
           ,s.[price_adder_currency2]
           ,s.[volume_multiplier2]
           ,s.[pay_opposite]
           ,s.[capacity]
           ,s.[settlement_currency]
           ,s.[standard_yearly_volume]
           ,s.[formula_curve_id]
           ,s.[price_uom_id]
           ,s.[category]
           ,s.[profile_code]
           ,s.[pv_party]
           ,s.[status]
           ,s.[lock_deal_detail]
FROM #tmp_nom_location p 
INNER JOIN #primary_deal_loc_vol pri_deal 
	ON pri_deal.route_id=p.route_id 
	AND p.from_location = pri_deal.original_location  
	AND p.term=pri_deal.term
INNER JOIN #route_split_vol  rsv 
	ON pri_deal.route_id= rsv.route_id	  
	AND  pri_deal.route_order_in= rsv.route_order_in
INNER JOIN #maintain_location_routes mlr 
	ON mlr.route_id = rsv.route_id 
	AND  ISNULL(mlr.route_order_in,1)>=rsv.route_order_in
--INNER JOIN [dbo].maintain_location_routes mlr ON mlr.route_id = rsv.route_id AND  ISNULL(mlr.route_order_in,1)>=rsv.route_order_in
INNER JOIN #tmp_header th 
	ON th.deal_id = @process_id + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(mlr.maintain_location_routes_id AS VARCHAR),'')
CROSS JOIN #source_deal_detail s
LEFT JOIN dbo.equity_gas_allocation ega 
		ON ega.location_id = p.from_location 
		AND ega.del_location_id= mlr.[delivery_location]
		AND ega.term_start =p.term --AND ISNULL(ega.split_percentage , 0)<>0	
		AND ega.contract_id=th.contract_id
LEFT JOIN  #pipeline_rounding pr 
	ON pr.pipeline=th.counterparty_id --rounding_method
WHERE (ega.location_id IS NOT NULL AND mlr.primary_secondary = 's' AND ega.split_percentage<>0 ) 
	OR (ega.location_id IS NULL AND mlr.primary_secondary = 'p') 
	OR (ega.location_id IS NOT NULL AND  ega.split_percentage <> 0 AND mlr.primary_secondary = 'p')

 --DELETE inserted deal header that do NOT define volume split for secondary route
DELETE  [dbo].[source_deal_header]  
FROM [dbo].[source_deal_header] h 
INNER JOIN #tmp_header t 
	ON h.source_deal_header_id = t.source_deal_header_id
LEFT JOIN (SELECT DISTINCT * FROM #detail_inserted_deal) sdd 
	ON t.source_deal_header_id = sdd.source_deal_header_id
WHERE  sdd.source_deal_header_id IS NULL

/**********************INSERT INTO *[user_defined_deal_fields]*****************************************************/
DECLARE @from_deal_id VARCHAR(30)

SELECT @from_deal_id = value_id
FROM static_data_value sdv
WHERE code = 'From Deal'	

--SELECT @loss =value_id
--	FROM static_data_value sdv
--	WHERE code = 'Loss'	

EXEC spa_print 'INSERT INTO [dbo].[user_defined_deal_fields] '

INSERT INTO [dbo].[user_defined_deal_fields]
		([source_deal_header_id]
		,[udf_template_id]
		,[udf_value]
		,[create_user]
		,[create_ts])
SELECT	th.source_deal_header_id 
		,u.[udf_template_id]
		, CASE u.Field_id WHEN '-5614' THEN mlr.fuel_loss 
				WHEN @from_deal_id THEN 
					CASE WHEN  th.source_deal_header_id<>COALESCE(th_p.source_deal_header_id,th1.source_deal_header_id,-1) 
					AND th.source_deal_header_id>COALESCE(th_p.source_deal_header_id,th1.source_deal_header_id,-1)	
						THEN ISNULL(th_p.source_deal_header_id,th1.source_deal_header_id) ELSE NULL END
				ELSE nullif(u.[udf_value],'') END
		,dbo.fnadbuser()
		,GETDATE()							 
 FROM (
	SELECT uddf.*, uddft.Field_id 
	FROM #user_defined_deal_fields uddf
	INNER JOIN user_defined_deal_fields_template uddft 
		ON uddft.udf_template_id = uddf.udf_template_id
	WHERE uddf.[source_deal_header_id] = @sdh_id
) u
CROSS JOIN #tmp_nom_location p 
INNER JOIN #maintain_location_routes mlr 
	ON mlr.route_id=p.route_id   
	AND ( mlr.route_order_in IS NOT NULL  OR mlr.is_group='n')
INNER JOIN #tmp_header th 
	ON th.deal_id = @process_id + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(mlr.maintain_location_routes_id AS VARCHAR),'')
INNER JOIN 	(SELECT DISTINCT * FROM #detail_inserted_deal) sdd 
	ON	th.source_deal_header_id=sdd.source_deal_header_id
OUTER APPLY
(	--taking prior primary than primary in split volume allocation group
	SELECT TOP(1) m.* 
	FROM #route_split_vol	rsv --primary in split volume allocation group
	INNER JOIN #maintain_location_routes m 
		ON m.route_id = rsv.route_id 
		AND m.route_order_in IS NOT NULL	
		AND m.route_order_in < rsv.route_order_in   
		AND m.route_id = mlr.route_id  
		AND m.[primary_secondary] = 'p' 
		AND m.is_group = 'y'
	ORDER BY m.route_order_in DESC
)	mlr_p
LEFT JOIN #tmp_header th_p 
	ON th_p.deal_id = @process_id + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(mlr_p.maintain_location_routes_id AS VARCHAR),'')
OUTER APPLY  --when not have split volume and only primary
(
	 SELECT TOP(1) *
	 FROM #maintain_location_routes m 
	 WHERE m.route_order_in IS NOT NULL	
		  AND m.route_order_in < mlr.route_order_in   
		  AND  m.route_id=mlr.route_id  
		  AND m.[primary_secondary]='p' 
		  AND m.is_group='y'
	ORDER BY m.route_order_in DESC
)	mlr1
LEFT JOIN #tmp_header th1 
	ON th1.deal_id = @process_id + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(mlr1.maintain_location_routes_id AS VARCHAR), '')

EXEC spa_print 'Delete existing record in table:	dbo.nom_group_schedule_deal '

DELETE dbo.nom_group_schedule_deal 
FROM nom_group_schedule_deal n 
INNER JOIN #tmp_nom_location l 
	ON n.location_id=l.from_location 
	AND n.[term_start] = l.term
INNER JOIN #maintain_location_routes mlr 
	ON mlr.route_id=l.route_id

INSERT INTO dbo.nom_group_schedule_deal (location_id, term_start, create_ts , create_user, schedule_deal_id)
SELECT from_location, p.term, GETDATE(), dbo.FNADBUser(), th.source_deal_header_id
FROM  #maintain_location_routes mlr
INNER JOIN #tmp_nom_location p	 
	ON mlr.route_id=p.route_id
INNER JOIN #tmp_header th 
	ON th.deal_id = @process_id1 + '_' + CAST(p.rowid AS VARCHAR) + '_' + ISNULL(CAST(mlr.maintain_location_routes_id AS VARCHAR), '')

UPDATE [dbo].[source_deal_header] 
	SET deal_id = 'SCHD_' + CAST(h.source_deal_header_id AS VARCHAR) 
FROM [dbo].[source_deal_header] h 
INNER JOIN #tmp_header t 
	ON h.source_deal_header_id = t.source_deal_header_id

IF EXISTS(SELECT 1 FROM #tmp_header)
BEGIN
	DECLARE @spa VARCHAR(MAX)
		, @job_name VARCHAR(150)

	SET @job_name = 'calc_deal_position_breakdown' + @process_id

	SET @st1 = 'INSERT INTO ' + @report_position + '(source_deal_header_id, action) SELECT source_deal_header_id, ''i'' FROM #tmp_header'
	EXEC spa_print @st1   
	EXEC (@st1) 

	SET @spa = 'spa_update_deal_total_volume NULL, ''' + @process_id + ''', 0, 1, ''' + @user_login_id + ''', NULL, NULL, ' + ISNULL('' + NULL + '', 'NULL') + ''	
	EXEC spa_print @spa
	EXEC spa_run_sp_as_job @job_name,  @spa, 'generating_report_table', @user_login_id

END

IF ISNULL(@flag, 'c') = 'c'
BEGIN
	--SELECT TOP 1 'Auto Nomination Process Completed' [Status], dbo.FNADateFormat(@term_start) term_start
	SET @DESC = 'Auto Nomination Process Completed for term ' + dbo.FNADateFormat(@term_start) + '.'
	--EXEC spa_message_board 'i', @user_login_id,NULL,'Split NOM Volume',@st1,NULL,NULL, 's'  ,NULL,NULL, @batch_process_id

END
--EXEC spa_message_board 'i', @user_login_id,NULL,'Split NOM Volume','Auto Nom calculation IS done successfully',NULL,NULL, 's'

msg_level:

SET @module = 'Auto Nomination' 

SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=EXEC spa_get_mtm_test_run_log ''' + @process_id  + ''''

IF @err_type = 'e'
BEGIN
	INSERT INTO MTM_TEST_RUN_LOG(process_id, code, module, source, type, [description], nextsteps)  
	SELECT ISNULL(@batch_process_id,@process_id)
		, CASE WHEN @err_type='e' THEN  'Error' ELSE 'Success' END 
		, @module
		, @module
		, CASE WHEN @err_type='e' THEN  'Error' ELSE 'Success' END
		, @DESC AS status_description
		, 'Please verify data.'

	SET  @DESC  ='Auto Nomination Process did NOT Completed for term ' + dbo.FNADateFormat(@term_start) + '.'
	SET @DESC = '<a target="_blank" href="' + @url + '">' + @DESC   +'.</a>'
END

EXEC  spa_message_board 'u', @user_login_id, NULL, @module,  @DESC, '', '', 'e', @job_name, NULL, @batch_process_id 

GO