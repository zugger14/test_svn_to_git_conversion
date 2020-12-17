BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '493F3F94_FEC0_4027_B750_7ADED2C35ED9'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Generation_Gas_ST_Forecast'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Generation_Gas_ST_Forecast' ,
					'N' ,
					NULL ,
					'
UPDATE a
SET [Term] = CAST(dbo.FNAClientToSqlDate([Term]) AS DATE)
FROM [temp_process_table] a

DROP TABLE IF EXISTS [temp_process_table]_calc
SELECT * INTO [temp_process_table]_calc
FROM [temp_process_table]

IF OBJECT_ID(N''tempdb..#generic_mapping_values'') IS NOT NULL
DROP TABLE #generic_mapping_values

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header 
WHERE mapping_name = ''Update Volume Profile Mapping''

SELECT gmv.[mapping_table_id]	 
	   , gmv.[clm1_value] [process]
	   , gmv.[clm2_value] [sub_book]
	   , gmv.[clm3_value] [counterparty]
	   , gmv.[clm4_value] [source_profile1]
	   , gmv.[clm5_value] [source_profile2]
	   , gmv.[clm6_value] [dest_buy_profile]
	   , gmv.[clm7_value] [dest_sell_profile]
INTO #generic_mapping_values
FROM  generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
CROSS APPLY (
	SELECT clm1_value, clm2_value, clm3_value, clm4_value, clm5_value
	FROM generic_mapping_values gmv 
	WHERE gmv.mapping_table_id = gmh.mapping_table_id
	GROUP BY clm1_value, clm2_value, clm3_value, clm4_value, clm5_value
) mx
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
	AND gmv.clm1_value = mx.clm1_value
	AND gmv.clm2_value = mx.clm2_value
	AND ISNULL(gmv.clm3_value, 1) = ISNULL(mx.clm3_value, 1)
	AND gmv.clm4_value = mx.clm4_value
	AND ISNULL(gmv.clm5_value, 1) = ISNULL(mx.clm5_value, 1)
WHERE gmh.mapping_name = ''Update Volume Profile Mapping'' 
	and gmv.clm1_value = 112705
	and gmv.mapping_table_id = @mapping_table_id

DECLARE @dst_group_value_id INT 

IF OBJECT_ID(N''tempdb..#deal_max_term'') IS NOT NULL
	DROP TABLE #deal_max_term
-- DEAL List
CREATE TABLE #deal_max_term (
	  source_deal_header_id INT
	, block_define_id INT
	, term_start DATE
	, term_end DATE
	, profile_name NVARCHAR(200) COLLATE DATABASE_DEFAULT
	, dest_buy_profile INT
	, dest_sell_profile INT
)

INSERT INTO #deal_max_term (source_deal_header_id, block_define_id, term_start, term_end, profile_name, dest_buy_profile, dest_sell_profile)
SELECT sdh.source_deal_header_id, MAX(sdh.block_define_id), MIN(a.Term) term_start, MAX(a.Term) term_end, fp.external_id
	, max(gmv.dest_buy_profile), max(gmv.dest_sell_profile)
FROM #generic_mapping_values gmv
INNER JOIN forecast_profile fp
	ON gmv.source_profile1 = fp.profile_id
INNER JOIN [temp_process_table]_calc a
	ON fp.external_id = a.[Profile Name]
INNER JOIN source_deal_header sdh
	ON  sdh.sub_book = gmv.sub_book
WHERE sdh.deal_reference_type_id IN (12500) and sdh.commodity_id=-1 and sdh.source_deal_type_id=2261
GROUP BY sdh.source_deal_header_id, fp.external_id

--select * from source_deal_type -- where value_id=12500

IF OBJECT_ID(N''tempdb..#collect_deals'') IS NOT NULL
DROP TABLE #collect_deals

SELECT DISTINCT sdh.source_deal_header_id, sdh.deal_id,sdh.counterparty_id,sdh.source_deal_type_id, sdh.deal_sub_type_type_id
	, sdh.template_id
	, sdh.header_buy_sell_flag
	, sdh.contract_id
	, sdh.internal_desk_id
	, sdh.commodity_id
	, sdh.close_reference_id
	, ISNULL(sdh.block_define_id, -10000298) block_define_id
	, sdh.physical_financial_flag
	, sdh.profile_granularity
	, sdh.sub_book
	, sdh.internal_counterparty
	, sdh.pricing_type
	, sdd.source_deal_detail_id
	, sdd.term_start
	, sdd.term_end
	, sdd.leg
	, sdd.curve_id
	, sdd.fixed_price
	, sdd.deal_volume
	, sdd.deal_volume_frequency	
	, sdd.location_id
	, sdd.buy_sell_flag
	, dmt.profile_name
	, dmt.dest_buy_profile
	, dmt.dest_sell_profile
INTO #collect_deals	
FROM #deal_max_term dmt
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = dmt.source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND ((sdd.term_start >= dmt.term_start or dmt.term_start between sdd.term_start and sdd.term_end)
		AND (sdd.term_end <= dmt.term_end or dmt.term_end between sdd.term_start and sdd.term_end))
CREATE INDEX indx_collect_deals_ps ON #collect_deals(source_deal_header_id, term_start, term_end)

SELECT @dst_group_value_id = tz.dst_group_value_id
FROM adiha_default_codes_values adcv
INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adcv.default_code_id = 36

IF OBJECT_ID(N''tempdb..#mv90_dst'') IS NOT NULL
DROP TABLE #mv90_dst

SELECT [year]
	, [date]
	, [hour]
INTO #mv90_dst
FROM mv90_dst
WHERE insert_delete = ''i''
AND dst_group_value_id = @dst_group_value_id 


DROP TABLE IF EXISTS  #temp_position
SELECT rs.term_start [Term]
	, rs.hr
	, rs.period
	, rs.is_dst
	, SUM(rs.volume) position
	, rs.profile_name
	, MAX(rs.dest_buy_profile) dest_buy_profile
	, MAX(rs.dest_sell_profile) dest_sell_profile
INTO #temp_position
	FROM ( SELECT 
		  source_deal_header_id
		, source_deal_detail_id
		, term_start
		, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
		, [period]
		, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
		, val volume
		, granularity
		, profile_name
		, dest_buy_profile
		, dest_sell_profile
	FROM (
	SELECT rhpd.source_deal_header_id
			, d.source_deal_detail_id
 			, rhpd.term_start
			, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
			, rhpd.[period]
			, rhpd.granularity
			, d.profile_name
			, d.dest_buy_profile
			, d.dest_sell_profile
		FROM #collect_deals d
		INNER JOIN report_hourly_position_deal	rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
			AND rhpd.term_start BETWEEN d.term_start AND d.term_end
			AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
			AND rhpd.curve_id = d.curve_id
			AND rhpd.physical_financial_flag = ''p''
			AND rhpd.period = 0
			) rs
		UNPIVOT
			(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
	) upv
	OUTER APPLY(SELECT dst.date,dst.[hour]
		FROM #mv90_dst dst 
		WHERE dst.date = upv.term_start
		GROUP BY dst.date,dst.[hour]
		) dst
	UNION all
	SELECT 
		  source_deal_header_id
		, source_deal_detail_id
		, term_start
		, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
		, [period]
		, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
		, val volume
		, granularity
		, profile_name
		, dest_buy_profile
		, dest_sell_profile
	FROM (
		SELECT rhpd.source_deal_header_id
			, d.source_deal_detail_id
 			, rhpd.term_start
			, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
			, rhpd.[period]
			, rhpd.granularity
			, d.profile_name
			, d.dest_buy_profile
			, d.dest_sell_profile
		FROM #collect_deals d
		INNER JOIN report_hourly_position_profile rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
			AND rhpd.term_start BETWEEN d.term_start AND d.term_end
			AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
			AND rhpd.curve_id = d.curve_id
			AND rhpd.physical_financial_flag = ''p''
			AND rhpd.period = 0
			) rs
		UNPIVOT
			(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
	) upv
	OUTER APPLY(SELECT dst.date,dst.[hour]
		FROM #mv90_dst dst 
		WHERE dst.date = upv.term_start
		GROUP BY dst.date,dst.[hour]
		) dst
) rs
GROUP BY rs.profile_name, rs.term_start, rs.hr, rs.period, rs.is_dst

-- Shift DATE
UPDATE tp
SET [Term] = CAST(DATEADD(DD,+1, [Term]) AS DATE) 
FROM #temp_position tp
WHERE 1 = 1
	AND ([hr] BETWEEN 19 AND 24)

-- Shift Hour		
UPDATE tp
SET [hr] = CASE WHEN [hr] BETWEEN  1 AND 18 THEN [hr] + 6
		WHEN [hr] BETWEEN 19 AND 24 THEN [hr] - 18
	ELSE [hr]
	END
FROM #temp_position tp

UPDATE tp
SET position = (tp.position - tpd.position)
FROM #temp_position tp
INNER JOIN #mv90_dst dst ON tp.[Term] = dst.DATE
	AND tp.Hr = dst.hour
	AND tp.is_dst = 0
LEFT JOIN (
	SELECT *
	FROM #temp_position tp2
	INNER JOIN #mv90_dst dst ON tp2.[Term] = dst.DATE
		AND tp2.Hr = dst.hour
		AND tp2.is_dst = 1
	) tpd ON tp.Term = tpd.Term
	AND tp.profile_name = tpd.profile_name
	AND tp.hr = tpd.hour
	AND tp.period = tpd.period

UPDATE tp
SET [hr] = ([hr] - 1)
FROM #temp_position tp
WHERE ISNULL([period], 61) <> 0  

UPDATE a
SET [Volume] = (ABS(ISNULL(tp.position,0)) - a.Volume) 
FROM [temp_process_table]_calc a
INNER JOIN #temp_position tp
	ON a.[profile Name] = tp.profile_name
	AND a.[Term] = tp.[Term]
	AND a.[Hour] = ISNULL(tp.[hr], -1)
	AND ISNULL(a.[Minute],0) = tp.[period]
	AND a.[Is DST] = tp.[is_dst]
LEFT JOIN forecast_profile fp_buy
	ON tp.dest_buy_profile = fp_buy.profile_id
LEFT JOIN forecast_profile fp_sell
	ON tp.dest_sell_profile = fp_sell.profile_id
    
INSERT INTO [temp_process_table](
    	[Profile Name]
    , [Term]
    , [Hour]
    , [Minute]
    , [Is DST]
    , [Volume]
)
SELECT 
	IIF(cast(calc.[Volume] as numeric(38,20)) >= 0.00, fp_buy.external_id, fp_sell.external_id)
    , calc.[Term]
    , calc.[Hour]
    , calc.[Minute]
    , calc.[Is DST]
    , ABS(CAST(calc.[Volume] AS NUMERIC(38,20)))
FROM [temp_process_table]_calc calc
INNER JOIN #temp_position tp
	ON calc.[Profile Name] = tp.[profile_name]
	AND calc.Term = tp.Term
	AND calc.hour = tp.hr
	AND ISNULL(calc.Minute,0) = tp.period
	AND calc.[Is DST] = tp.is_dst
LEFT JOIN forecast_profile fp_buy
	ON tp.dest_buy_profile = fp_buy.profile_id
LEFT JOIN forecast_profile fp_sell
	ON tp.dest_sell_profile = fp_sell.profile_id
UNION
SELECT 
	IIF(cast(calc.[Volume] as numeric(38,20)) < 0.00, fp_buy.external_id, fp_sell.external_id)
    , calc.[Term]
    , calc.[Hour]
    , calc.[Minute]
    , calc.[Is DST]
	, ''0.00''
FROM [temp_process_table]_calc calc
INNER JOIN #temp_position tp
	ON calc.[Profile Name] = tp.[profile_name]
	AND calc.Term = tp.Term
	AND calc.hour = tp.hr
	AND ISNULL(calc.Minute,0) = tp.period
	AND calc.[Is DST] = tp.is_dst
LEFT JOIN forecast_profile fp_buy
	ON tp.dest_buy_profile = fp_buy.profile_id
LEFT JOIN forecast_profile fp_sell
	ON tp.dest_sell_profile = fp_sell.profile_id
UNION
SELECT IIF(CAST(a.Volume AS NUMERIC(38,20)) >= 0.00, gm.dest_sell_profile, gm.dest_buy_profile) [profile name]
	, a.Term
	, a.[Hour]
	, a.[Minute]
	, a.[Is DST]
	, ABS(CAST(a.[Volume] AS NUMERIC(38,20)))
FROM [temp_process_table] a
INNER JOIN forecast_profile fp 
		ON a.[Profile Name] = fp.external_id
LEFT JOIN #temp_position tp
	ON a.[Profile Name] = tp.profile_name
	AND a.Term = tp.Term
	AND a.Hour = tp.hr
	AND ISNULL(a.Minute,0) = tp.period
	AND a.[Is DST] = tp.is_dst
OUTER APPLY (
	SELECT gmv.source_profile1 [source_profile1]
		from #generic_mapping_values gmv
		INNER JOIN forecast_profile fp
    		ON gmv.source_profile1 = fp.profile_id
		WHERE a.[Profile Name] = fp.external_id
		GROUP BY gmv.source_profile1
	) gm_profile
OUTER APPLY (
		SELECT MAX(fp_buy.external_id) [dest_buy_profile], MAX(fp_sell.external_id) [dest_sell_profile]
		from #generic_mapping_values gmv
		LEFT JOIN forecast_profile fp_buy
    		ON gmv.dest_buy_profile = fp_buy.profile_id
		LEFT JOIN forecast_profile fp_sell
    		ON gmv.dest_sell_profile = fp_sell.profile_id
		WHERE gmv.source_profile1 = fp.profile_id
		GROUP BY dest_buy_profile, dest_sell_profile
	) gm
WHERE tp.Term IS NULL
AND gm_profile.source_profile1 IS NOT NULL',
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'493F3F94_FEC0_4027_B750_7ADED2C35ED9'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'Generation_Gas_ST_Forecast'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = '
UPDATE a
SET [Term] = CAST(dbo.FNAClientToSqlDate([Term]) AS DATE)
FROM [temp_process_table] a

DROP TABLE IF EXISTS [temp_process_table]_calc
SELECT * INTO [temp_process_table]_calc
FROM [temp_process_table]

IF OBJECT_ID(N''tempdb..#generic_mapping_values'') IS NOT NULL
DROP TABLE #generic_mapping_values

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header 
WHERE mapping_name = ''Update Volume Profile Mapping''

SELECT gmv.[mapping_table_id]	 
	   , gmv.[clm1_value] [process]
	   , gmv.[clm2_value] [sub_book]
	   , gmv.[clm3_value] [counterparty]
	   , gmv.[clm4_value] [source_profile1]
	   , gmv.[clm5_value] [source_profile2]
	   , gmv.[clm6_value] [dest_buy_profile]
	   , gmv.[clm7_value] [dest_sell_profile]
INTO #generic_mapping_values
FROM  generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
CROSS APPLY (
	SELECT clm1_value, clm2_value, clm3_value, clm4_value, clm5_value
	FROM generic_mapping_values gmv 
	WHERE gmv.mapping_table_id = gmh.mapping_table_id
	GROUP BY clm1_value, clm2_value, clm3_value, clm4_value, clm5_value
) mx
INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
	AND gmv.clm1_value = mx.clm1_value
	AND gmv.clm2_value = mx.clm2_value
	AND ISNULL(gmv.clm3_value, 1) = ISNULL(mx.clm3_value, 1)
	AND gmv.clm4_value = mx.clm4_value
	AND ISNULL(gmv.clm5_value, 1) = ISNULL(mx.clm5_value, 1)
WHERE gmh.mapping_name = ''Update Volume Profile Mapping'' 
	and gmv.clm1_value = 112705
	and gmv.mapping_table_id = @mapping_table_id

DECLARE @dst_group_value_id INT 

IF OBJECT_ID(N''tempdb..#deal_max_term'') IS NOT NULL
	DROP TABLE #deal_max_term
-- DEAL List
CREATE TABLE #deal_max_term (
	  source_deal_header_id INT
	, block_define_id INT
	, term_start DATE
	, term_end DATE
	, profile_name NVARCHAR(200) COLLATE DATABASE_DEFAULT
	, dest_buy_profile INT
	, dest_sell_profile INT
)

INSERT INTO #deal_max_term (source_deal_header_id, block_define_id, term_start, term_end, profile_name, dest_buy_profile, dest_sell_profile)
SELECT sdh.source_deal_header_id, MAX(sdh.block_define_id), MIN(a.Term) term_start, MAX(a.Term) term_end, fp.external_id
	, max(gmv.dest_buy_profile), max(gmv.dest_sell_profile)
FROM #generic_mapping_values gmv
INNER JOIN forecast_profile fp
	ON gmv.source_profile1 = fp.profile_id
INNER JOIN [temp_process_table]_calc a
	ON fp.external_id = a.[Profile Name]
INNER JOIN source_deal_header sdh
	ON  sdh.sub_book = gmv.sub_book
WHERE sdh.deal_reference_type_id IN (12500) and sdh.commodity_id=-1 and sdh.source_deal_type_id=2261
GROUP BY sdh.source_deal_header_id, fp.external_id

--select * from source_deal_type -- where value_id=12500

IF OBJECT_ID(N''tempdb..#collect_deals'') IS NOT NULL
DROP TABLE #collect_deals

SELECT DISTINCT sdh.source_deal_header_id, sdh.deal_id,sdh.counterparty_id,sdh.source_deal_type_id, sdh.deal_sub_type_type_id
	, sdh.template_id
	, sdh.header_buy_sell_flag
	, sdh.contract_id
	, sdh.internal_desk_id
	, sdh.commodity_id
	, sdh.close_reference_id
	, ISNULL(sdh.block_define_id, -10000298) block_define_id
	, sdh.physical_financial_flag
	, sdh.profile_granularity
	, sdh.sub_book
	, sdh.internal_counterparty
	, sdh.pricing_type
	, sdd.source_deal_detail_id
	, sdd.term_start
	, sdd.term_end
	, sdd.leg
	, sdd.curve_id
	, sdd.fixed_price
	, sdd.deal_volume
	, sdd.deal_volume_frequency	
	, sdd.location_id
	, sdd.buy_sell_flag
	, dmt.profile_name
	, dmt.dest_buy_profile
	, dmt.dest_sell_profile
INTO #collect_deals	
FROM #deal_max_term dmt
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = dmt.source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND ((sdd.term_start >= dmt.term_start or dmt.term_start between sdd.term_start and sdd.term_end)
		AND (sdd.term_end <= dmt.term_end or dmt.term_end between sdd.term_start and sdd.term_end))
CREATE INDEX indx_collect_deals_ps ON #collect_deals(source_deal_header_id, term_start, term_end)

SELECT @dst_group_value_id = tz.dst_group_value_id
FROM adiha_default_codes_values adcv
INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adcv.default_code_id = 36

IF OBJECT_ID(N''tempdb..#mv90_dst'') IS NOT NULL
DROP TABLE #mv90_dst

SELECT [year]
	, [date]
	, [hour]
INTO #mv90_dst
FROM mv90_dst
WHERE insert_delete = ''i''
AND dst_group_value_id = @dst_group_value_id 


DROP TABLE IF EXISTS  #temp_position
SELECT rs.term_start [Term]
	, rs.hr
	, rs.period
	, rs.is_dst
	, SUM(rs.volume) position
	, rs.profile_name
	, MAX(rs.dest_buy_profile) dest_buy_profile
	, MAX(rs.dest_sell_profile) dest_sell_profile
INTO #temp_position
	FROM ( SELECT 
		  source_deal_header_id
		, source_deal_detail_id
		, term_start
		, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
		, [period]
		, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
		, val volume
		, granularity
		, profile_name
		, dest_buy_profile
		, dest_sell_profile
	FROM (
	SELECT rhpd.source_deal_header_id
			, d.source_deal_detail_id
 			, rhpd.term_start
			, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
			, rhpd.[period]
			, rhpd.granularity
			, d.profile_name
			, d.dest_buy_profile
			, d.dest_sell_profile
		FROM #collect_deals d
		INNER JOIN report_hourly_position_deal	rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
			AND rhpd.term_start BETWEEN d.term_start AND d.term_end
			AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
			AND rhpd.curve_id = d.curve_id
			AND rhpd.physical_financial_flag = ''p''
			AND rhpd.period = 0
			) rs
		UNPIVOT
			(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
	) upv
	OUTER APPLY(SELECT dst.date,dst.[hour]
		FROM #mv90_dst dst 
		WHERE dst.date = upv.term_start
		GROUP BY dst.date,dst.[hour]
		) dst
	UNION all
	SELECT 
		  source_deal_header_id
		, source_deal_detail_id
		, term_start
		, IIF(cast(substring(upv.hr,3,2) AS INT) = 25, dst.hour , cast(substring(upv.hr,3,2) AS INT)) Hr
		, [period]
		, IIF(cast(substring(upv.hr,3,2) AS INT) <> 25,0,1)  is_dst
		, val volume
		, granularity
		, profile_name
		, dest_buy_profile
		, dest_sell_profile
	FROM (
		SELECT rhpd.source_deal_header_id
			, d.source_deal_detail_id
 			, rhpd.term_start
			, hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25
			, rhpd.[period]
			, rhpd.granularity
			, d.profile_name
			, d.dest_buy_profile
			, d.dest_sell_profile
		FROM #collect_deals d
		INNER JOIN report_hourly_position_profile rhpd ON rhpd.source_deal_header_id = d.source_deal_header_id
			AND rhpd.term_start BETWEEN d.term_start AND d.term_end
			AND ISNULL(rhpd.location_id, -1) = ISNULL(d.location_id, -1)
			AND rhpd.curve_id = d.curve_id
			AND rhpd.physical_financial_flag = ''p''
			AND rhpd.period = 0
			) rs
		UNPIVOT
			(val for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)	
	) upv
	OUTER APPLY(SELECT dst.date,dst.[hour]
		FROM #mv90_dst dst 
		WHERE dst.date = upv.term_start
		GROUP BY dst.date,dst.[hour]
		) dst
) rs
GROUP BY rs.profile_name, rs.term_start, rs.hr, rs.period, rs.is_dst

-- Shift DATE
UPDATE tp
SET [Term] = CAST(DATEADD(DD,+1, [Term]) AS DATE) 
FROM #temp_position tp
WHERE 1 = 1
	AND ([hr] BETWEEN 19 AND 24)

-- Shift Hour		
UPDATE tp
SET [hr] = CASE WHEN [hr] BETWEEN  1 AND 18 THEN [hr] + 6
		WHEN [hr] BETWEEN 19 AND 24 THEN [hr] - 18
	ELSE [hr]
	END
FROM #temp_position tp

UPDATE tp
SET position = (tp.position - tpd.position)
FROM #temp_position tp
INNER JOIN #mv90_dst dst ON tp.[Term] = dst.DATE
	AND tp.Hr = dst.hour
	AND tp.is_dst = 0
LEFT JOIN (
	SELECT *
	FROM #temp_position tp2
	INNER JOIN #mv90_dst dst ON tp2.[Term] = dst.DATE
		AND tp2.Hr = dst.hour
		AND tp2.is_dst = 1
	) tpd ON tp.Term = tpd.Term
	AND tp.profile_name = tpd.profile_name
	AND tp.hr = tpd.hour
	AND tp.period = tpd.period

UPDATE tp
SET [hr] = ([hr] - 1)
FROM #temp_position tp
WHERE ISNULL([period], 61) <> 0  

UPDATE a
SET [Volume] = (ABS(ISNULL(tp.position,0)) - a.Volume) 
FROM [temp_process_table]_calc a
INNER JOIN #temp_position tp
	ON a.[profile Name] = tp.profile_name
	AND a.[Term] = tp.[Term]
	AND a.[Hour] = ISNULL(tp.[hr], -1)
	AND ISNULL(a.[Minute],0) = tp.[period]
	AND a.[Is DST] = tp.[is_dst]
LEFT JOIN forecast_profile fp_buy
	ON tp.dest_buy_profile = fp_buy.profile_id
LEFT JOIN forecast_profile fp_sell
	ON tp.dest_sell_profile = fp_sell.profile_id
    
INSERT INTO [temp_process_table](
    	[Profile Name]
    , [Term]
    , [Hour]
    , [Minute]
    , [Is DST]
    , [Volume]
)
SELECT 
	IIF(cast(calc.[Volume] as numeric(38,20)) >= 0.00, fp_buy.external_id, fp_sell.external_id)
    , calc.[Term]
    , calc.[Hour]
    , calc.[Minute]
    , calc.[Is DST]
    , ABS(CAST(calc.[Volume] AS NUMERIC(38,20)))
FROM [temp_process_table]_calc calc
INNER JOIN #temp_position tp
	ON calc.[Profile Name] = tp.[profile_name]
	AND calc.Term = tp.Term
	AND calc.hour = tp.hr
	AND ISNULL(calc.Minute,0) = tp.period
	AND calc.[Is DST] = tp.is_dst
LEFT JOIN forecast_profile fp_buy
	ON tp.dest_buy_profile = fp_buy.profile_id
LEFT JOIN forecast_profile fp_sell
	ON tp.dest_sell_profile = fp_sell.profile_id
UNION
SELECT 
	IIF(cast(calc.[Volume] as numeric(38,20)) < 0.00, fp_buy.external_id, fp_sell.external_id)
    , calc.[Term]
    , calc.[Hour]
    , calc.[Minute]
    , calc.[Is DST]
	, ''0.00''
FROM [temp_process_table]_calc calc
INNER JOIN #temp_position tp
	ON calc.[Profile Name] = tp.[profile_name]
	AND calc.Term = tp.Term
	AND calc.hour = tp.hr
	AND ISNULL(calc.Minute,0) = tp.period
	AND calc.[Is DST] = tp.is_dst
LEFT JOIN forecast_profile fp_buy
	ON tp.dest_buy_profile = fp_buy.profile_id
LEFT JOIN forecast_profile fp_sell
	ON tp.dest_sell_profile = fp_sell.profile_id
UNION
SELECT IIF(CAST(a.Volume AS NUMERIC(38,20)) >= 0.00, gm.dest_sell_profile, gm.dest_buy_profile) [profile name]
	, a.Term
	, a.[Hour]
	, a.[Minute]
	, a.[Is DST]
	, ABS(CAST(a.[Volume] AS NUMERIC(38,20)))
FROM [temp_process_table] a
INNER JOIN forecast_profile fp 
		ON a.[Profile Name] = fp.external_id
LEFT JOIN #temp_position tp
	ON a.[Profile Name] = tp.profile_name
	AND a.Term = tp.Term
	AND a.Hour = tp.hr
	AND ISNULL(a.Minute,0) = tp.period
	AND a.[Is DST] = tp.is_dst
OUTER APPLY (
	SELECT gmv.source_profile1 [source_profile1]
		from #generic_mapping_values gmv
		INNER JOIN forecast_profile fp
    		ON gmv.source_profile1 = fp.profile_id
		WHERE a.[Profile Name] = fp.external_id
		GROUP BY gmv.source_profile1
	) gm_profile
OUTER APPLY (
		SELECT MAX(fp_buy.external_id) [dest_buy_profile], MAX(fp_sell.external_id) [dest_sell_profile]
		from #generic_mapping_values gmv
		LEFT JOIN forecast_profile fp_buy
    		ON gmv.dest_buy_profile = fp_buy.profile_id
		LEFT JOIN forecast_profile fp_sell
    		ON gmv.dest_sell_profile = fp_sell.profile_id
		WHERE gmv.source_profile1 = fp.profile_id
		GROUP BY dest_buy_profile, dest_sell_profile
	) gm
WHERE tp.Term IS NULL
AND gm_profile.source_profile1 IS NOT NULL'
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'y'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-T-SQL01\shared_docs_TRMTracker_Enercity_Test\temp_Note\0',
						   NULL,
						   ';',
						   2,
						   'fv',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   '',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   NULL,
						   NULL
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'fv.[Profile Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_detail_hour_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'fv.[Term]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_detail_hour_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'fv.[Hour]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_detail_hour_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'fv.[Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_detail_hour_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'fv.[Is DST]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_detail_hour_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_dst' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'fv.[Minute]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_detail_hour_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'interval' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
END